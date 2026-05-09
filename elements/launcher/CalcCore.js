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

    tau: Math.PI * 2,
    phi: (1 + Math.sqrt(5)) / 2,

    c: 299792458,
    g: 9.80665,
    g_const: 6.67430e-11,
    h: 6.62607015e-34,
    k: 1.380649e-23,
    avogadro: 6.02214076e23,

	sw: undefined,
	sh: undefined,
};

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
	ANGULAR: 3,

	VECTOR: 100
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
			if (b === undefined) throw new Error("Invalid unit object: missing unit, type, or value");

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
		ensureNumber(input, "input");
		ensureNumber(base, "base");
		if (base === 2) return Math.sqrt(input);
		if (base === 3) return Math.cbrt(input);
		return input ** (1/base);
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

	eml: (x, y) => {
		ensureNumber(x, "x");
		ensureNumber(y, "y");
		return Math.exp(x) - Math.log(y)
	},

	mod: (x, y) => {
		ensureNumber(x, "x");
		ensureNumber(y, "y");
		return x % y;
	},

	clamp: (x, min, max) => {
        ensureNumber(x);
        ensureNumber(min);
        ensureNumber(max);
        if (min > max) throw new Error("clamp: min cannot be greater than max");
        return Math.min(Math.max(x, min), max);
    },

	lerp: (a, b, t) => {
		ensureNumber(a);
		ensureNumber(b);
		ensureNumber(t);
		return a + (b - a) * t;
	},

	fract: (x) => {
		ensureNumber(x);
		return x - Math.floor(x);
	},

	factorial: (x) => {
		let factorial = 1;
		for (let i = 2; i <= x; i++) factorial *= i;
		return factorial;
	},

	ncr: (n, r) => {
        ensureNumber(n, "n");
        ensureNumber(r, "r");
        if (r < 0 || r > n) return 0;
        if (!Number.isInteger(n) || !Number.isInteger(r)) throw new Error("nCr arguments must be integers");
        let res = 1;
        for (let i = 1; i <= r; i++) 
            res = res * (n - r + i) / i;
        return Math.round(res);
    },

	npr: (n, r) => {
        ensureNumber(n, "n");
        ensureNumber(r, "r");
        if (r < 0 || r > n) return 0;
        if (!Number.isInteger(n) || !Number.isInteger(r)) throw new Error("nPr arguments must be integers");
        let res = 1;
        for (let i = 0; i < r; i++) {
            res *= (n - i);
        }
        return res;
    },

	gcd: (...args) => {
        if (args.length < 2) throw new Error("gcd requires at least 2 arguments");
        args.forEach((v, i) => {
            ensureNumber(v, `arg[${i}]`);
            if (!Number.isInteger(v)) throw new TypeError(`gcd arguments must be integers, got ${v}`);
        });

        const _gcd2 = (a, b) => {
            a = Math.abs(a);
            b = Math.abs(b);
            while (b) {
                a %= b;
                [a, b] = [b, a];
            }
            return a;
        };

        return args.reduce((acc, curr) => _gcd2(acc, curr));
    },

	lcm: (...args) => {
        if (args.length < 2) throw new Error("lcm requires at least 2 arguments");
        args.forEach((v, i) => {
            ensureNumber(v, `arg[${i}]`);
            if (!Number.isInteger(v)) throw new TypeError(`lcm arguments must be integers, got ${v}`);
        });

        const _gcd2 = (a, b) => {
            a = Math.abs(a);
            b = Math.abs(b);
            while (b) {
                a %= b;
                [a, b] = [b, a];
            }
            return a;
        };

        const _lcm2 = (a, b) => {
            if (a === 0 || b === 0) return 0;
            return Math.abs(a) * (Math.abs(b) / _gcd2(a, b));
        };

        return args.reduce((acc, curr) => _lcm2(acc, curr));
    },

	mean: (...args) => {
        if (args.length === 0) throw new Error("mean requires at least 1 argument");
        args.forEach((v, i) => ensureNumber(v, `arg[${i}]`));
        
        const sum = args.reduce((acc, curr) => acc + curr, 0);
        return sum / args.length;
    },

    median: (...args) => {
        if (args.length === 0) throw new Error("median requires at least 1 argument");
        args.forEach((v, i) => ensureNumber(v, `arg[${i}]`));

        const sorted = [...args].sort((a, b) => a - b);
        const mid = Math.floor(sorted.length / 2);

        if (sorted.length % 2 === 0) {
            return (sorted[mid - 1] + sorted[mid]) / 2;
        }
        return sorted[mid];
    },

    std: (...args) => {
        if (args.length === 0) throw new Error("std requires at least 1 argument");
        args.forEach((v, i) => ensureNumber(v, `arg[${i}]`));

        const n = args.length;
        const mean = args.reduce((acc, curr) => acc + curr, 0) / n;
        
        const variance = args.reduce((acc, curr) => acc + Math.pow(curr - mean, 2), 0) / n;
        
        return Math.sqrt(variance);
    },

    sum: (...args) => {
        args.forEach((v, i) => ensureNumber(v, `arg[${i}]`));
        return args.reduce((acc, curr) => acc + curr, 0);
    },

	// vec: (x, y, z) => {
	// 	ensureNumber(x);	
	// 	ensureNumber(y);	
	// 	if (z !== undefined) ensureNumber(z);
		
	// 	return  {
	// 		unit: (z === undefined) ? 2 : 3,
	// 		type: DataType.VECTOR,
	// 		value: [x, y, z]
	// 	}	
	// },
	
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
				case "&": left = execBinary(left, right, (l, r) => l & r); break;
				case "^": left = execBinary(left, right, (l, r) => l ^ r); break;
				case "|": left = execBinary(left, right, (l, r) => l | r); break;
			}
		}
		
		return left
	}

	function bitshiftExpression() {
		let left = additiveExpression()
		let current

		while (
			(current = at()) &&
			current.tokenKind === TokenKind.OPERATOR &&
			["<<", ">>", ">>>"].includes(current.token)
		) {
			const operator = eat()
			const right = additiveExpression()

			switch (operator.token) {
				case "<<": left = execBinary(left, right, (l, r) => l << r); break;
				case ">>": left = execBinary(left, right, (l, r) => l >> r); break;
				case ">>>": left = execBinary(left, right, (l, r) => l >>> r); break;
			}
		}

		return left
	}

	function additiveExpression() {
		let left = multiplicativeExpression()
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPERATOR && ["+", "-"].includes(current.token)) {
			const operator = eat()
			const right = multiplicativeExpression()

			switch (operator.token) {
				case "+": left = execBinary(left, right, (l, r) => l + r); break;
				case "-": left = execBinary(left, right, (l, r) => l - r); break;
			}
		}

		return left
	}

	function multiplicativeExpression() {
		let left = openParenthesisMultilicationExpression()
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPERATOR && ["*", "/", "%"].includes(current.token)) {
			const operator = eat()
			const right = openParenthesisMultilicationExpression()

			if ((operator.token === "/" || operator.token === "%") && right === 0) {
				throw new Error(`Division by zero: Cannot perform '${operator.token}' when the divisor is 0.`)
			}

			switch (operator.token) {
				case "*": left = multiplicative(left, right); break;
				case "/": {
					const output = execBinary(left, right, (l, r) => l / r)
					if (left.type === DataType.AREA && right.type === DataType.AREA) {
						output.type = DataType.LENGTH;
						if (output.unit === "a") output.unit = "dam";
						else if (output.unit === "ha") output.unit = "hm";
						else output.unit = output.unit.substring(0, output.unit.length - 1);
					} else if (typeof left !== "number" && left.type === right.type) {
						throw new Error(`Invalid operation: division between same types!`);
					}
					left = output;
					break;
				}
				case "%": left = execBinary(left, right, (l, r) => l % r); break;
			}
		}

		return left
	}

	function openParenthesisMultilicationExpression() {
		let left = unitNumberMultilicationExpression()
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPEN_PARENTHESIS) {
			const right = unitNumberMultilicationExpression()
			left = multiplicative(left, right)
		}

		return left
	}

	function unitNumberMultilicationExpression() {
		let left = powerExpression()
		let current

		while ((current = at()) && current.tokenKind === TokenKind.NUMBER) {
			const right = powerExpression()
			left = multiplicative(left, right)
		}

		return left
	}

	function powerExpression() {
		let left = factorialExpression()
		let current

		if ((current = at()) && current.tokenKind === TokenKind.OPERATOR && current.token === "**") {
			eat()
			const right = powerExpression()
			return execBinary(left, right, (l, r) => Math.pow(l, r));
		}

		return left
	}

	function factorialExpression() {
		let left = unitConversion()
		let current

		while ((current = at()) && current.tokenKind === TokenKind.OPERATOR && current.token === "!") {
			eat()
			if (left < 0 || !Number.isInteger(typeof left === "number" ? left : left.value)) {
				throw new Error("Factorial is only defined for non-negative integers.")
			}
			left = execUnary(left, func.factorial)
		}

		return left
	}

	function unitConversion() {
		let left = unitExpression()
		let current

		while ((current = at()) && current.tokenKind === TokenKind.KEYWORD && (current.token === "to" || current.token === "in")) {
			const operator = eat()
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
					left = {
						unit: unit,
						type: targetDatatype,
						value: left.value * lookup[left.unit] / lookup[unit]
					}
					break;
				}

				case DataType.ANGULAR: {
					const unit = eat().token
					if (left.unit === unit) {
						left = { unit, type: targetDatatype, value: left.value };
					} else {
						left = {
							unit, type: targetDatatype,
							value: left.value * ((unit === "rad") ? (Math.PI / 180) : (180 / Math.PI))
						}
					}
					break;
				}

				default: throw new Error("Unsupported unit type");
			}
		}

		return left;
	}

	function unitExpression() {
		let left = primaryExpression()
		let current
		
		while ((current = at()) && [
			TokenKind.LENGTH_UNIT_KEYWORD, 
			TokenKind.AREA_UNIT_KEYWORD, 
			TokenKind.ANGULAR_UNIT_KEYWORD,
			TokenKind.VOLUME_UNIT_KEYWORD
		].includes(current.tokenKind)) {
			if (left === undefined) throw new Error("Missing value for conversion");
			left = {
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
				) ret = multiplicative(ret, primaryExpression())

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

					let output = functionToCall(...args);

                    if ([TokenKind.WORD, TokenKind.NUMBER].includes(at()?.tokenKind)) {
						output = multiplicative(output, primaryExpression())
					}

                    return output;
				} else {
					const constValue = constant[name]
					if (constValue === undefined) throw Error(`Invalid constant or function name: ${name}`)
					if (typeof constValue === "function") return constValue()
					return constValue
				}
			}

			case TokenKind.OPEN_PARENTHESIS: {
				eat()
				let output = expression()

				if (at()?.tokenKind !== TokenKind.CLOSE_PARENTHESIS) throw Error("Expected closing parenthesis ')'")
				eat()

				if (
					at()?.tokenKind === TokenKind.NUMBER ||
					at()?.tokenKind === TokenKind.WORD ||
					at()?.tokenKind === TokenKind.OPEN_PARENTHESIS
				) {
					output = multiplicative(output, primaryExpression());
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

		case DataType.VECTOR: {
			if (output.unit === 2) return `vector(${output.value[0]}, ${output.value[1]})`;
			else return `vector(${output.value[0]}, ${output.value[1]}, ${output.value[2]})`;
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
