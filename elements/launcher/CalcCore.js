/** @param {string} char */
function isBlank(char) {
	return /\s/.test(char)
}

/** @param {string} char */
function isNumber(char) {
	return /\d/.test(char)
}

/** @param {string} char */
function isWord(char) {
	return char ? /\w/.test(char) : false
}

function execUnary(value, operation) {
	if (typeof value === "number") return operation(value);
	const {unit, type, value: v} = value;
	return { unit, type, value: operation(v) };
}

function execBinary(a, b, operation) {
	if (typeof a === "number") {
		if (typeof b === "number") return operation(a, b);
		else {
			const {unit, type, value} = b;
			return { unit, type, value: operation(a, value) }
		}
	} else {
		if (typeof b === "number")  {
			const {unit, type, value} = a;
			return { unit, type, value: operation(value, b) }
		} else {
			if (a.type !== b.type) throw new Error("Invalid conversion unit")
			switch (a.type) {
				case DataType.LENGTH:
				case DataType.AREA: {
					const lookup = [lengthLookup, areaLookup][a.type];
					return { unit: b.unit, type: b.type, value: operation(a.value * lookup[a.unit] / lookup[b.unit], b.value) }
				};
				case DataType.ANGULAR: {
					if (a.unit === b.unit) return { unit: b.unit, type: b.type, value: operation(a.value, b.value) }
					return {
						unit: b.unit,
						type: b.type,
						value: operation(a.value * ((b.unit === "rad") ? (Math.PI / 180) : (180 / Math.PI)), b.value)
					}
				};
			}
		}
	}
}

function resMathFunc(value, func) {
	if (typeof input === "number") return func(value);
	const { unit, type, value: v } = value;
	return { unit, type, value: func(v) }
}

function resTrigonometricMathFunc(func, value) {
    if (typeof value === "number") return func(value);

    if (value.type !== DataType.ANGULAR) throw Error("Invalid value!");

    const num = value.value;
    const unit = value.unit;

    const radians = (unit === "rad") ? num : num * (Math.PI / 180);

    return func(radians);
}

const func = {
	abs: v => resMathFunc(v, Math.abs),

	sqrt: v => resMathFunc(v, Math.sqrt),
	cbrt: v => resMathFunc(v, Math.cbrt),
	pow: Math.pow,
	hypot: Math.hypot,

	floor: v => resMathFunc(v, Math.floor),
	ceil: v => resMathFunc(v, Math.ceil),
	round: v => resMathFunc(v, Math.round),
	trunc: v => resMathFunc(v, Math.trunc),
	sign: v => resMathFunc(v, Math.sign),

	sin: v => resTrigonometricMathFunc(Math.sin, v),
	cos: v => resTrigonometricMathFunc(Math.cos, v),
	tan: v => resTrigonometricMathFunc(Math.tan, v),
	asin: v => resTrigonometricMathFunc(Math.asin, v),
	acos: v => resTrigonometricMathFunc(Math.acos, v),
	atan: v => resTrigonometricMathFunc(Math.atan, v),
	atan2: Math.atan2,

	log: v => resMathFunc(v, Math.log),
	log10: v => resMathFunc(v, Math.log10),
	log2: v => resMathFunc(v, Math.log2),
	exp: v => resMathFunc(v, Math.exp),

	max: Math.max,
	min: Math.min,
	random: Math.random,
}

const constant = {
	e: Math.E,
	ln10: Math.LN10,
	ln2: Math.LN2,
	log10e: Math.LOG10E,
	log2e: Math.LOG2E,
	pi: Math.PI,
	sqrt1_2: Math.SQRT1_2,
	sqrt2: Math.SQRT2,
	random: Math.random,
}

const keywords = new Set(["to"])
const lengthUnits = new Set(["km", "hm", "dam", "m", "dm", "cm", "mm"])
const areaUnits = new Set(["km2", "hm2", "dam2", "a", "ha", "m2", "dm2", "cm2", "mm2"])
const angularUnits = new Set(["deg", "rad"])

const lengthLookup = {
    km: 1000,
    hm: 100,
    dam: 10,
    m: 1,
    dm: 0.1,
    cm: 0.01,
    mm: 0.001
};

const areaLookup = {
    km2: 1000000,
    hm2: 10000, ha: 10000,
    dam2: 100, a: 100,
    m2: 1,
    dm2: 0.01,
    cm2: 0.0001,
    mm2: 0.000001
};

/**
 * @readonly
 * @enum {number}
 */
const DataType = {
	LENGTH: 0,
	AREA: 1,
	ANGULAR: 3
}

/**
 * @readonly
 * @enum {number}
 */
const TokenKind = {
	NUMBER: 0,
	WORD: 1,

	OPERATOR: 50,
	KEYWORD: 51,
	LENGTH_UNIT_KEYWORD: 52,
	AREA_UNIT_KEYWORD: 53,
	ANGULAR_UNIT_KEYWORD: 54,

	COMMA: 99,
	OPEN_PARENTHESIS: 100,
	CLOSE_PARENTHESIS: 101,

	EOF: 1000,
}

/**
 * @typedef {Object} Token
 * @property {TokenKind} tokenKind
 * @property {string} token
 *
 * @param {string} input
 * @returns {number}
 */
function calc(input) {
	let position = 0
	const tokens = lexer(input)

	function prev() { return tokens[position - 1] }
	function at() { return tokens[position] }
	function eat() { return tokens[position++] }
	function next() { return tokens[position + 1] }
	function last() { return tokens[tokens.length - 1] }
	
	function getDataType(kind) {
		switch (kind) {
			case TokenKind.LENGTH_UNIT_KEYWORD: return DataType.LENGTH;
			case TokenKind.AREA_UNIT_KEYWORD: return DataType.AREA;
			case TokenKind.ANGULAR_UNIT_KEYWORD: return DataType.ANGULAR;
		}
	}
	
	function expression() { return bitwiseExpression() }

	function bitwiseExpression() {
		/** @type {Token} */
		let current = at()
		if (current && current.tokenKind === TokenKind.OPERATOR && current.token === "!") {
			eat()
			return execUnary(bitwiseExpression(), (ret) => ~ret)
		}

		let left = bitshiftExpression()

		while ((current = at()) && current.tokenKind === TokenKind.OPERATOR && ["&", "^", "|"].includes(current.token)) {
			// if (current.token === "|") {
			// 	let nxt = next()
			// 	if (
			// 		!nxt ||
			// 		nxt.tokenKind === TokenKind.OPERATOR ||
			// 		nxt.tokenKind === TokenKind.CLOSE_PARENTHESIS ||
			// 		nxt.tokenKind === TokenKind.COMMA
			// 	) {
			// 		break
			// 	}
			// }

			const operator = eat()
			const right = bitshiftExpression()

			switch (operator.token) {
				case "&": return execBinary(left, right, (l, r) => l & r)
				case "^": return execBinary(left, right, (l, r) => l ^ r)
				case "|": return execBinary(left, right, (l, r) => l | r)
			}
		}
		
		return left
	}

	function bitshiftExpression() {
		let left = additiveExpression()

		/** @type {Token} */
		let current

		while (
			(current = at()) &&
			current.tokenKind === TokenKind.OPERATOR &&
			["<<", ">>", ">>>"].includes(current.token)
		) {
			const operator = eat()
			const right = additiveExpression()

			switch (operator.token) {
				case "<<": return execBinary(left, right, (l, r) => l << r);
				case ">>": return execBinary(left, right, (l, r) => l >> r);
				case ">>>": return execBinary(left, right, (l, r) => l  >>> r);
			}
		}

		return left
	}

	function additiveExpression() {
		let left = multiplicativeExpression()

		/** @type {Token} */
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPERATOR && ["+", "-"].includes(current.token)) {
			const operator = eat()
			const right = additiveExpression()

			switch (operator.token) {
				case "+": return execBinary(left, right, (l, r) => l + r);
				case "-": return execBinary(left, right, (l, r) => l - r);
			}
		}

		return left
	}

	function multiplicativeExpression() {
		let left = openParenthesisMultilicationExpression()

		/** @type {Token} */
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPERATOR && ["*", "/", "%"].includes(current.token)) {
			const operator = eat()
			const right = multiplicativeExpression()

			if ((operator.token === "/" || operator.token === "%") && right === 0) {
				throw new Error(`Division by zero: Cannot perform '${operator.token}' when the divisor is 0.`)
			}

			switch (operator.token) {
				case "*": return execBinary(left, right, (l, r) => l * r);
				case "/": return execBinary(left, right, (l, r) => l / r);
				case "%": return execBinary(left, right, (l, r) => l % r);
			}
		}

		return left
	}

	function openParenthesisMultilicationExpression() {
		let left = powerExpression()

		/** @type {Token} */
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPEN_PARENTHESIS)
			return execBinary(left, openParenthesisMultilicationExpression(), (l, r) => l * r);

		return left
	}

	function powerExpression() {
		let left = factorialExpression()

		/** @type {Token} */
		let current

		if ((current = at()) && current.tokenKind === TokenKind.OPERATOR && current.token === "**") {
			eat()
			return execBinary(left, powerExpression(), (l, r) => Math.pow(l, r));
		}

		return left
	}

	function factorialExpression() {
		let left = unitConversion()

		/** @type {Token} */
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPERATOR && current.token === "!") {
			eat()

			if (left < 0 || !Number.isInteger(left)) {
				throw new Error("Factorial is only defined for non-negative integers.")
			}

			return execUnary(left, (value) => {
				let factorial = 1;
				for (let i = 2; i <= left; i++) factorial *= i;
				return factorial;
			})
		}

		return left
	}

	function unitConversion() {
		let left = unitExpression();

		/** @type {Token} */
		let current

		while ((current = at()) && (current.tokenKind === TokenKind.KEYWORD) && (current.token === "to")) {
			eat();
			const targetDatatype = getDataType(at().tokenKind);
			
			if (typeof left === "number") throw new Error("Cannot convert a number!");
			if (left.type !== targetDatatype) throw new Error("Invalid unit conversion!");
			
			switch (targetDatatype) {
				case DataType.LENGTH:
				case DataType.AREA: {
					const unit = eat().token;
					const lookup = [lengthLookup, areaLookup][targetDatatype];
					return {
						unit: unit,
						type: targetDatatype,
						value: left.value * lookup[left.unit] / lookup[unit]
					}
				}

				case DataType.ANGULAR: {
					const unit = eat().token
					if (left.unit === unit) return { unit, type: targetDatatype, value: left.value };

					return {
						unit, type: targetDatatype,
						value: left.value * ((unit === "rad") ? (Math.PI / 180) : (180 / Math.PI))
					}
				}
			}
		}

		return left;
	}

	function unitExpression() {
		let left = primaryExpression();

		/** @type {Token} */
		let current
		
		while ((current = at()) && [TokenKind.LENGTH_UNIT_KEYWORD, TokenKind.AREA_UNIT_KEYWORD, TokenKind.ANGULAR_UNIT_KEYWORD].includes(current.tokenKind)) {
			return {
				unit: at().token,
				type: getDataType(eat().tokenKind),
				value: left
			};
		}

		return left;
	}

	function primaryExpression() {
		let left = at()

		if (!left) return 0

		switch (left.tokenKind) {
			case TokenKind.NUMBER: {
				let ret = Number(eat().token)

				if (at()?.tokenKind === TokenKind.WORD || at()?.tokenKind === TokenKind.OPEN_PARENTHESIS) {
					ret *= primaryExpression()
				}
				return ret
			}

			case TokenKind.WORD: {
				const name = eat().token.toLowerCase()

				if (at()?.tokenKind === TokenKind.OPEN_PARENTHESIS) {
					eat()

					const args = []
					if (at()?.tokenKind !== TokenKind.CLOSE_PARENTHESIS) {
						args.push(expression())
						while (at()?.tokenKind === TokenKind.COMMA) {
							eat()
							args.push(expression())
						}
					}

					if (at()?.tokenKind !== TokenKind.CLOSE_PARENTHESIS) {
						throw Error("Expected closing parenthesis after function arguments")
					}
					eat()

					const functionToCall = func[name]
					if (!functionToCall) throw Error(`Unknown function: ${name}`)

					const output = functionToCall(...args);
                    if ([TokenKind.WORD, TokenKind.NUMBER].includes(at()?.tokenKind)) return output * primaryExpression();
                    else return output;
				} else {
					const constValue = constant[name]
					if (constValue === undefined) throw Error(`Invalid constant or function name: ${name}`)
					if (typeof constValue === "function") return constValue()
					return constValue
				}
			}

			case TokenKind.OPEN_PARENTHESIS: {
				eat()
				const output = expression()

				if (at()?.tokenKind !== TokenKind.CLOSE_PARENTHESIS) throw Error("Expected closing parenthesis ')'")
				eat()

				if (
					at()?.tokenKind === TokenKind.NUMBER ||
					at()?.tokenKind === TokenKind.WORD ||
					at()?.tokenKind === TokenKind.OPEN_PARENTHESIS
				) {
					return execBinary(output, right, (l, r) => l * r)
				}

				return output
			}

			case TokenKind.OPERATOR: {
				if (["+", "-"].includes(left.token)) {
					eat()
					if (left.token === "-") return execUnary(primaryExpression(), v => -1 * v);
					return primaryExpression()
				}
				// else if (
				// 	(left.token === "|" && prev()?.tokenKind === TokenKind.OPERATOR) ||
				// 	!prev() ||
				// 	prev()?.tokenKind === TokenKind.OPEN_PARENTHESIS
				// ) {
				// 	eat()
				// 	const ret = expression()
				// 	if (eat()?.token !== "|") throw Error("Invalid abs expression!")
				// 	return Math.abs(ret)
				// }
			}
		}

		return 0
	}

	const output = expression()

	if (at()) throw Error("Invalid token")

	if (typeof output === "number") return output;

	switch (output.type) {
		case DataType.LENGTH:
		case DataType.AREA: 
		case DataType.ANGULAR:
			return `${output.value}${output.unit}`;
	}
}

/**
 * @param {string} input
 * @returns {Token[]}
 */
function lexer(input) {
	/** @type {Token[]} */
	const tokens = []

	function pushToken(kind, start, length, token) {
		tokens.push({
			tokenKind: kind,
			token: token || input.substring(start, start + length),
		})
	}

	let index = 0
	while (index < input.length) {
		let char = input[index]
		if (isBlank(char)) {
			index++
			continue
		}

		switch (char) {
			case "+":
			case "-":
			case "/":
			case "%":
			case "!":
			case "&":
			case "|":
			case "^":
				pushToken(TokenKind.OPERATOR, index++, 1)
				break

			case ">":
			case "<":
				{
					if (input[++index] === char) {
						if (input[index + 1] === ">") pushToken(TokenKind.OPERATOR, (index += 2) - 3, 3)
						else pushToken(TokenKind.OPERATOR, index++ - 1, 2)
					} else throw Error("Invalid token!")
				}
				break

			case ",":
				pushToken(TokenKind.COMMA, index++, 1)
				break

			case "*":
				{
					if (input[++index] === char) pushToken(TokenKind.OPERATOR, index++ - 1, 2)
					else pushToken(TokenKind.OPERATOR, index - 1, 1)
				}
				break

			case "(":
				pushToken(TokenKind.OPEN_PARENTHESIS, index++, 1)
				break
			case ")":
				pushToken(TokenKind.CLOSE_PARENTHESIS, index++, 1)
				break

			default:
				{
					const startIndex = index

					if (isNumber(char) || (char === "." && isNumber(input[index + 1]))) {
						if (char === ".") {
							index++
							while (isNumber(input[index])) index++
						} else {
							while (isNumber(input[index])) index++
							if (input[index] === ".") {
								index++
								while (isNumber(input[index])) index++
							}
						}

						if (input[index]?.toLowerCase() === "e") {
							let savedIndex = index
							index++

							if (input[index] === "-" || input[index] === "+") index++

							if (isNumber(input[index])) {
								while (isNumber(input[index])) index++
							} else {
								index = savedIndex
							}
						}

						pushToken(TokenKind.NUMBER, startIndex, index - startIndex)
						continue
					} else if (isWord(char)) {
						index++
						while (isWord(input[index])) index++
						const token = input.substring(startIndex, index).toLowerCase();
						switch (true) {
							case keywords.has(token): pushToken(TokenKind.KEYWORD, startIndex, index, token); break;
							case lengthUnits.has(token): pushToken(TokenKind.LENGTH_UNIT_KEYWORD, startIndex, index, token); break;
							case areaUnits.has(token): pushToken(TokenKind.AREA_UNIT_KEYWORD, startIndex, index, token); break;
							case angularUnits.has(token): pushToken(TokenKind.ANGULAR_UNIT_KEYWORD, startIndex, index, token); break;
							default: pushToken(TokenKind.WORD, startIndex, index, token); break;
						}
						continue
					}

					throw "Invalid character!"
				}
				break
		}
	}

	return tokens
}
