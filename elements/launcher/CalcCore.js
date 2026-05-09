.pragma library


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

const keywords = new Set(["to", "in"])
const lengthUnits = new Set(["km", "hm", "dam", "m", "dm", "cm", "mm"])
const areaUnits = new Set(["km2", "hm2", "dam2", "a", "ha", "m2", "dm2", "cm2", "mm2"])
const volumeUnits = new Set(["km3", "hm3", "dam3", "m3", "dm3", "l", "cm3", "ml", "mm3"]);
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
	km2: 1_000_000,
	hm2: 10_000, ha: 10_000,
	dam2: 100, a: 100,
	m2: 1,
	dm2: 0.01,
	cm2: 0.0001,
	mm2: 0.000001
};

const volumeLookup = {
	km3: 1_000_000_000,
	hm3: 1_000_000,
	dam3: 1_000,
	m3: 1,
	dm3: 0.001, l: 0.001,
	cm3: 0.000001, ml: 0.000001,
	mm3: 0.000000001
};

/**
 * @readonly
 * @enum {number}
 */
const DataType = {
	LENGTH: 0,
	AREA: 1,
	VOLUME: 2,
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
	VOLUME_UNIT_KEYWORD: 55,

	COMMA: 99,
	OPEN_PARENTHESIS: 100,
	CLOSE_PARENTHESIS: 101,

	EOF: 1000,
}

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
			if (b === undefined) 
				throw new Error("Invalid unit object: missing unit, type, or value");

			const {unit, type, value} = b;
			return { unit, type, value: operation(a, value) }
		}
	} else {
		if ([a, b].includes(undefined)) 
			throw new Error("Invalid unit object: missing unit, type, or value");

		if (typeof b === "number")  {
			const {unit, type, value} = a;
			return { unit, type, value: operation(value, b) }
		} else {
			if (a.type !== b.type) throw new Error("Invalid conversion unit")
			switch (a.type) {
				case DataType.LENGTH: 
				case DataType.AREA:
				case DataType.VOLUME: {
					const lookup = [lengthLookup, areaLookup, volumeLookup][a.type];
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
	if (typeof value === "number") return func(value);
	const { unit, type, value: v } = value;
	return { unit, type, value: func(v) }
}

function resTrigonometricMathFunc(func, value) {
    if (typeof value === "number") return func(value);

    if (!value || value.type !== DataType.ANGULAR)
        throw Error("Invalid value: Expected an angular data type.");

    const { value: num, unit } = value;
    const radians = (unit === "rad") ? num : num * (Math.PI / 180);
    const result = func(radians);
    return Math.abs(result) < 1e-15 ? 0 : result;
}

const ensureNumber = (v, name = "value") => {
	if (typeof v !== "number" || Number.isNaN(v)) {
		throw new TypeError(`${name} must be a valid number, got ${v}`);
	}
};

const ensureNonNegative = (v, name = "value") => {
	if (v < 0) {
		throw new RangeError(`${name} must be >= 0, got ${v}`);
	}
};

const ensurePositive = (v, name = "value") => {
	if (v <= 0) {
		throw new RangeError(`${name} must be > 0, got ${v}`);
	}
};

function multiplicative(left, right) {
	const output = execBinary(left, right, (l, r) => l * r)
	if (left.type === DataType.LENGTH && right.type === DataType.LENGTH) {
		output.type = DataType.AREA;
		output.unit += "2";
	} else if (
		typeof left !== "number" && left.type === right.type) throw new Error(`Cannot multiply two values of the same type!'`);
	return output;
}

const func = {
	abs: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.abs(v);
	}),

	sqrt: v => resMathFunc(v, v => {
		ensureNumber(v);
		ensureNonNegative(v, "sqrt input");
		return Math.sqrt(v);
	}),

	cbrt: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.cbrt(v);
	}),

	root: (input, base) => {
		ensureNumber(input);
		return Math.pow(input, 1 / base)
	},

	pow: (a, b) => {
		ensureNumber(a, "base");
		ensureNumber(b, "exponent");
		return Math.pow(a, b);
	},

	hypot: (...args) => {
		args.forEach((v, i) => ensureNumber(v, `arg[${i}]`));
		return Math.hypot(...args);
	},

	floor: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.floor(v);
	}),

	ceil: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.ceil(v);
	}),

	tofixed: (v, i) => resMathFunc(v, v => {
		ensureNumber(v);
		if (typeof i !== "number" || i < 0 || !Number.isInteger(i)) {
			throw new RangeError(`Precision must be a non-negative integer, got ${i}`);
		}
		const fixed = 10 ** i;
		return Math.trunc(v * fixed) / fixed;
	}),

	round: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.round(v);
	}),

	trunc: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.trunc(v);
	}),

	sign: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.sign(v);
	}),

	sin: v => resTrigonometricMathFunc(Math.sin, v),
	cos: v => resTrigonometricMathFunc(Math.cos, v),
	tan: v => resTrigonometricMathFunc(Math.tan, v),

	asin: v => resMathFunc(v, v => {
		ensureNumber(v);
		if (v < -1 || v > 1) throw new RangeError(`asin domain is [-1, 1], got ${v}`);
		return Math.asin(v);
	}),

	acos: v => resMathFunc(v, v => {
		ensureNumber(v);
		if (v < -1 || v > 1) throw new RangeError(`acos domain is [-1, 1], got ${v}`);
		return Math.acos(v);
	}),

	atan: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.atan(v);
	}),

	atan2: (y, x) => {
		ensureNumber(y, "y");
		ensureNumber(x, "x");
		return Math.atan2(y, x);
	},

	log: (input, base) => {
		ensureNumber(input, "x");
		if (base === undefined) return Math.log(input);
		else ensureNumber(base, "base");
		if (base === 2) return Math.log2(input);
		if (base === 10) return Math.log10(input);
		return Math.log(input) / Math.log(base);
	},

	exp: v => resMathFunc(v, v => {
		ensureNumber(v);
		return Math.exp(v);
	}),

	max: (...args) => {
		if (args.length === 0) throw new Error("max requires at least 1 argument");
		args.forEach((v, i) => ensureNumber(v, `arg[${i}]`));
		return Math.max(...args);
	},

	min: (...args) => {
		if (args.length === 0) throw new Error("min requires at least 1 argument");
		args.forEach((v, i) => ensureNumber(v, `arg[${i}]`));
		return Math.min(...args);
	},

	number: (input) => {
		if (typeof input === "number") return input;
		else return input.value; 
	},

	eml: (x, y) => Math.exp(x) - Math.log(y),
	
	random: () => Math.random(),
};

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
			case TokenKind.VOLUME_UNIT_KEYWORD: return DataType.VOLUME;
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
				case "*": return multiplicative(left, right);
				case "/": {
					const output = execBinary(left, right, (l, r) => l / r)
					if (left.type === DataType.AREA && right.type === DataType.AREA) {
						output.type = DataType.LENGTH;
						if (output.unit === "a") output.unit = "dam";
						else if (output.unit === "ha") output.unit = "hm";
						else output.unit = output.unit.substring(0, output.unit.length - 1);
					} else if (typeof left !== "number" && left.type === right.type) throw new Error(`Invalid operation: division between same types!`);
					return output;
				};
				case "%": return execBinary(left, right, (l, r) => l % r);
			}
		}

		return left
	}

	function openParenthesisMultilicationExpression() {
		let left = unitNumberMultilicationExpression()

		/** @type {Token} */
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPEN_PARENTHESIS)
			return multiplicative(left, openParenthesisMultilicationExpression());

		return left
	}

	function unitNumberMultilicationExpression() {
		let left = powerExpression();

		/** @type {Token} */
		let current
		while ((current = at()) && current.tokenKind === TokenKind.NUMBER)
			return multiplicative(left, unitNumberMultilicationExpression());

		return left;
	}

	function powerExpression() {
		let left = factorialExpression()

		/** @type {Token} */
		let current

		if ((current = at()) && current?.tokenKind === TokenKind.OPERATOR && current?.token === "**") {
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
			if (left === undefined) return left;
			
			eat()
			if (left < 0 || !Number.isInteger(typeof left === "number" ? left : left.value)) {
				throw new Error("Factorial is only defined for non-negative integers.")
			}

			return execUnary(left, (value) => {
				let factorial = 1;
				for (let i = 2; i <= value; i++) factorial *= i;
				return factorial;
			})
		}

		return left
	}

	function unitConversion() {
		let left = unitExpression();

		/** @type {Token} */
		let current

		while ((current = at()) && (current.tokenKind === TokenKind.KEYWORD) && (["to", "in"], current.token)) {
			const operator = eat();
			if (!at()) throw new Error(`Missing target unit after '${operator.token}'`); 
			const targetDatatype = getDataType(at().tokenKind);

			if (typeof left === "number") throw new Error("Cannot convert a raw number!");
       		if (left.type !== targetDatatype) throw new Error("Mismatched units!");
			
			switch (targetDatatype) {
				case DataType.LENGTH:
				case DataType.VOLUME:
				case DataType.AREA: {
					const unit = eat().token;
					const lookup = [lengthLookup, areaLookup, volumeLookup][targetDatatype];
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

				default: throw new Error("Unsupported unit type");
			}
		}

		return left;
	}

	function unitExpression() {
		let left = primaryExpression();

		/** @type {Token} */
		let current
		
		while ((current = at()) && [
			TokenKind.LENGTH_UNIT_KEYWORD, 
			TokenKind.AREA_UNIT_KEYWORD, 
			TokenKind.ANGULAR_UNIT_KEYWORD,
			TokenKind.VOLUME_UNIT_KEYWORD
		].includes(current.tokenKind)) {
			if (left === undefined) throw new Error("Missing value for conversion");
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

		if (!left) return undefined

		switch (left.tokenKind) {
			case TokenKind.NUMBER: {
				let ret = Number(eat().token)

				if (
					at()?.tokenKind === TokenKind.WORD ||
					at()?.tokenKind === TokenKind.OPEN_PARENTHESIS
				) ret *= primaryExpression()

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
					return multiplicative(output, primaryExpression());
				}

				return output
			}

			case TokenKind.OPERATOR: {
				if (["+", "-"].includes(left.token)) {
					eat()
					if (left.token === "-") return execUnary(primaryExpression(), v => -1 * v);
					return primaryExpression()
				} else if (left.token === "!") return bitwiseExpression();
			}
		}

		return undefined
	}

	const output = expression();

    if (at()) throw Error("Invalid token");

    if (typeof output === "number") return output;
	
    switch (output.type) {
        case DataType.LENGTH:
        case DataType.ANGULAR:
            return `${output.value}${output.unit}`;

        case DataType.AREA: {
            const specialUnits = ["ha", "a"];
            const isSpecial = specialUnits.includes(output.unit);
            const unitDisplay = isSpecial ? output.unit : `${output.unit.substring(0, output.unit.length - 1)}\u00B2`;
            return `${output.value}${unitDisplay}`;
        }

		case DataType.VOLUME: {
			const specialUnits = ["l", "ml"];
            const isSpecial = specialUnits.includes(output.unit);
            const unitDisplay = isSpecial ? output.unit : `${output.unit.substring(0, output.unit.length - 1)}\u00B3`;
            return `${output.value}${unitDisplay}`;
		}
        
        default: return output.value;
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
							case volumeUnits.has(token): pushToken(TokenKind.VOLUME_UNIT_KEYWORD, startIndex, index, token); break;
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
