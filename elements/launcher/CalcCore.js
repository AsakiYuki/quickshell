/** @param {string} char */
function isBlank(char) { return /\s/.test(char); }

/** @param {string} char */
function isNumber(char) { return /\d/.test(char); }

/** @param {string} char */
function isWord(char) { return char ? /\w/.test(char) : false; }

/**
 * @readonly
 * @enum {number}
 */
const TokenKind = {
    NUMBER: 0,
    WORD: 1,

    OPERATOR: 50,

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

    function expression() { return additiveExpression(); }
    
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
            case TokenKind.NUMBER: return Number(eat().token);
            case TokenKind.WORD: {
                switch (eat().token.toLowerCase()) {
                    case "pi": return Math.PI;
                    case "e": return Math.E;
                    default: throw Error ("Invalid word!");
                }
            };

            case TokenKind.OPEN_PARENTHESIS: {
                eat();
                const output = additiveExpression();
                eat();
                switch (at()?.tokenKind) {
                    case TokenKind.NUMBER: {
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
            case "+": case "-": case "/": case "%": case "!": pushToken(TokenKind.OPERATOR, index++, 1); break;

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