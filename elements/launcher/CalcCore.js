/** @param {string} char */
function isBlank(char) { return /\s/.test(char); }

/** @param {string} char */
function isNumber(char) { return /\d/.test(char); }

/** @param {string} char */
function isWord(char) { return char ? /\w/.test(char) : false; }

const constant = {
    e: Math.E,
    ln10: Math.LN10,
    ln2: Math.LN2,
    log10e: Math.LOG10E,
    log2e: Math.LOG2E,
    pi: Math.PI,
    sqrt1_2: Math.SQRT1_2,
    sqrt2: Math.SQRT2
};

const func = {
    abs: Math.abs,
    sqrt: Math.sqrt,
    cbrt: Math.cbrt,
    pow: Math.pow,
    hypot: Math.hypot,
    
    floor: Math.floor,
    ceil: Math.ceil,
    round: Math.round,
    trunc: Math.trunc,
    sign: Math.sign,

    sin: Math.sin,
    cos: Math.cos,
    tan: Math.tan,
    asin: Math.asin,
    acos: Math.acos,
    atan: Math.atan,
    atan2: Math.atan2,

    log: Math.log,
    log10: Math.log10,
    log2: Math.log2,
    exp: Math.exp,

    max: Math.max,
    min: Math.min,
    random: Math.random,
};

/**
 * @readonly
 * @enum {number}
 */
const TokenKind = {
    NUMBER: 0,
    WORD: 1,

    OPERATOR: 50,

    COMMA: 99,
    OPEN_PARENTHESIS: 100,
    CLOSE_PARENTHESIS: 101,
    
    EOF: 1000
};

/**
 * @typedef {Object} Token
 * @property {TokenKind} tokenKind
 * @property {string} token
 * 
 * @param {string} input
 * @returns {string} 
 */
function calc(input) {
    let position = 0;
    const tokens = lexer(input);

    function at() { return tokens[position]; }
    function eat() { return tokens[position++]; }
    function last() { return tokens[tokens.length - 1]; }

    function expression() { return bitwiseExpression(); }

    function bitwiseExpression() {
        /** @type {Token} */
        let current;
        while (
            (current = at()) &&
            (current.tokenKind === TokenKind.OPERATOR) &&
            (current.token === "!")
        ) {
            eat();
            const ret = bitwiseExpression();
            return ~ret;
        }

        let left = bitshiftExpression();

        while (
            (current = at()) &&
            (current.tokenKind === TokenKind.OPERATOR) &&
            (["&", "^", "|"].includes(current.token))
        ) {
            const operator = eat();
            const right = bitwiseExpression();

            switch (operator.token) {
                case "&": return left & right;
                case "^": return left ^ right;
                case "|": return left | right;
            }
        }

        return left;
    }

    function bitshiftExpression() {
        let left = additiveExpression();

        /** @type {Token} */
        let current;

        while (
            (current = at()) &&
            (current.tokenKind === TokenKind.OPERATOR) &&
            (["<<", ">>", ">>>"].includes(current.token))
        ) {
            const operator = eat();
            const right = bitshiftExpression();

            switch (operator.token) {
                case "<<": return left << right;
                case ">>": return left >> right;
                case ">>>": return left >>> right;
            }
        }

        return left;
    }
    
    function additiveExpression() {
        let left = multiplicativeExpression();

        /** @type {Token} */
        let current;

        while (
            (current = at()) &&
            (current.tokenKind === TokenKind.OPERATOR) &&
            (["+", "-"].includes(current.token))
        ) {
            const operator = eat();
            const right = additiveExpression();

            switch (operator.token) {
                case "+": return left + right;
                case "-": return left - right;
            }
        }

        return left;
    }
    
    function multiplicativeExpression() {
        let left = openParenthesisMultilicationExpression();
        
        /** @type {Token} */
        let current;

        while (
            (current = at()) &&
            (current.tokenKind === TokenKind.OPERATOR) &&
            (["*", "/", "%"].includes(current.token))
        ) {
            const operator = eat();
            const right = openParenthesisMultilicationExpression();

            if ((operator.token === "/" || operator.token === "%") && right === 0) {
                throw new Error(`Division by zero: Cannot perform '${operator.token}' when the divisor is 0.`);
            }

            switch (operator.token) {
                case "*": return left * right;
                case "/": return left / right;
                case "%": return left % right;
            }
        }

        return left;
    }

    function openParenthesisMultilicationExpression() {
        let left = powerExpression();

        /** @type {Token} */
        let current;

        while (
            (current = at()) &&
            (current.tokenKind === TokenKind.OPEN_PARENTHESIS)
        ) {
            const right = powerExpression();
            return left * right;
        }

        return left;
    }

    function powerExpression() {
        let left = factorialExpression();
        
        /** @type {Token} */
        let current;

        while (
            (current = at()) &&
            (current.tokenKind === TokenKind.OPERATOR) &&
            (current.token === "**")
        ) {
            eat();
            const right = factorialExpression();
            return Math.pow(left, right)
        }

        return left;
    }

    function factorialExpression() {
        let left = primaryExpression();

        /** @type {Token} */
        let current;

        while (
            (current = at()) &&
            (current.tokenKind === TokenKind.OPERATOR) &&
            (current.token === "!")
        ) {
            eat();
            
            if (left < 0 || !Number.isInteger(left)) {
                throw new Error("Factorial is only defined for non-negative integers.");
            }

            let factorial = 1;
            for (let i = 1; i <= left; i++) factorial *= i;
            return factorial;
        }

        return left;
    }

    function primaryExpression() {
        let left = at();

        if (!left) return 0;

        switch (left.tokenKind) {
            case TokenKind.NUMBER: {
                let ret = Number(eat().token)
                if (at()?.tokenKind === TokenKind.WORD) ret *= primaryExpression();
                return ret;
            };

            case TokenKind.WORD: {
                const name = eat().token.toLowerCase();
                
                if (at()?.tokenKind === TokenKind.OPEN_PARENTHESIS) {
                    eat();

                    const args = [];
                    if (at()?.tokenKind !== TokenKind.CLOSE_PARENTHESIS) {
                        args.push(expression());
                        while (at()?.tokenKind === TokenKind.COMMA) {
                            eat();
                            args.push(expression());
                        }
                    }

                    if (at()?.tokenKind !== TokenKind.CLOSE_PARENTHESIS) {
                        throw Error("Expected closing parenthesis after function arguments");
                    }
                    eat(); 

                    const functionToCall = func[name];
                    if (!functionToCall) throw Error(`Unknown function: ${name}`);
                    
                    return functionToCall(...args);
                }

                const constValue = constant[name];
                if (constValue === undefined) throw Error(`Invalid constant or function name: ${name}`);
                
                return constValue;
            };

            case TokenKind.OPEN_PARENTHESIS: {
                eat();
                const output = expression();
                eat();
                switch (at()?.tokenKind) {
                    case TokenKind.NUMBER:
                    case TokenKind.WORD: {
                        const right = multiplicativeExpression();
                        return output * right;
                    }
                    case TokenKind.OPEN_PARENTHESIS: {
                        const right = primaryExpression();
                        return output * right;
                    }
                }
                return output;
            };

            case TokenKind.OPERATOR: {
                if (["+", "-"].includes(left.token)) {
                    eat();

                    if (left.token === "-") return -1 * primaryExpression();
                    return primaryExpression();
                }
            };
        }

        return 0;
    }

    const output = expression();

    if (at() && at()?.tokenKind !== TokenKind.OPERATOR) return;

    return output;
}

/**
 * @param {string} input
 * @returns {Token[]}
 */
function lexer(input) {
    /** @type {Token[]} */
    const tokens = [];
    
    /**
     * @param {TokenKind} kind
     * @param {number} start 
     * @param {number} length
     * @returns {Token}
     */
    function pushToken(kind, start, length) {
        tokens.push({
            tokenKind: kind,
            token: input.substring(start, start + length)
        })
    }

    let index = 0;
    while (index < input.length) {
        let char = input[index];
        if (isBlank(char)) {
            index++;
            continue;
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
                pushToken(TokenKind.OPERATOR, index++, 1);
                break;

            case ">":
            case "<": {
                if (input[++index] === char) {
                    if (input[index + 1] === ">") pushToken(TokenKind.OPERATOR, ((index += 2) - 3), 3);
                    else pushToken(TokenKind.OPERATOR, (index++) - 1, 2);
                } else throw Error("Invalid token!");
            } break;
            
            case ",": pushToken(TokenKind.COMMA, index++, 1); break;

            case "*": {
                if (input[++index] === char) pushToken(TokenKind.OPERATOR, (index++) - 1, 2)
                else pushToken(TokenKind.OPERATOR, index - 1, 1);
            } break;

            case "(": pushToken(TokenKind.OPEN_PARENTHESIS, index++, 1); break;
            case ")": pushToken(TokenKind.CLOSE_PARENTHESIS, index++, 1); break;
            
            default: {
                const startIndex = index;
                
                if (isNumber(char)) {
                    index++;
                    while (isNumber(input[index])) index++;
                    
                    if (input[index] === ".") {
                        index++;
                        while (isNumber(input[index])) index++;
                    }

                    if (input[index]?.toLowerCase() === "e") {
                        index++;
                        if (input[index] === "-") index++;
                        while (isNumber(input[index])) index++;
                    }

                    pushToken(TokenKind.NUMBER, startIndex, index - startIndex);
                    continue;
                } else if (isWord(char)) {
                    index++;
                    while (isWord(input[index])) index++;
                    pushToken(TokenKind.WORD, startIndex, index - startIndex);
                    continue;
                }
                
                throw "Invalid character!";
            } break;
        }
    }

    return tokens;
}