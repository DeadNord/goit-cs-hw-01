class LexicalError(Exception):
    """Exception raised for errors in the lexical analysis."""

    pass


class ParsingError(Exception):
    """Exception raised for errors in the parsing process."""

    pass


class TokenType:
    """Defines possible types of tokens in the arithmetic expressions."""

    INTEGER = "INTEGER"
    PLUS = "PLUS"
    MINUS = "MINUS"
    MUL = "MUL"
    DIV = "DIV"
    LPAREN = "("
    RPAREN = ")"
    EOF = "EOF"  # Indicates the end of the input string


class Token:
    """Represents a token in the arithmetic expression."""

    def __init__(self, type, value):
        self.type = type
        self.value = value

    def __str__(self):
        return f"Token({self.type}, {repr(self.value)})"


class Lexer:
    """Performs lexical analysis to divide the input string into tokens."""

    def __init__(self, text):
        self.text = text
        self.pos = 0
        self.current_char = self.text[self.pos]

    def advance(self):
        """Move the 'pointer' to the next character in the input string."""
        self.pos += 1
        self.current_char = (
            None if self.pos > len(self.text) - 1 else self.text[self.pos]
        )

    def skip_whitespace(self):
        """Skip whitespace characters."""
        while self.current_char is not None and self.current_char.isspace():
            self.advance()

    def integer(self):
        """Return a (multidigit) integer consumed from the input."""
        result = ""
        while self.current_char is not None and self.current_char.isdigit():
            result += self.current_char
            self.advance()
        return int(result)

    def get_next_token(self):
        """Lexical analyzer that breaks the input string into tokens."""
        while self.current_char is not None:
            if self.current_char.isspace():
                self.skip_whitespace()
                continue
            if self.current_char.isdigit():
                return Token(TokenType.INTEGER, self.integer())
            if self.current_char in "+-*/()":
                token_type = self._assign_token_type(self.current_char)
                self.advance()
                return Token(token_type, self.current_char)
            raise LexicalError("Lexical analysis error")
        return Token(TokenType.EOF, None)

    def _assign_token_type(self, char):
        """Assign token type based on the single character."""
        token_mapping = {
            "+": TokenType.PLUS,
            "-": TokenType.MINUS,
            "*": TokenType.MUL,
            "/": TokenType.DIV,
            "(": TokenType.LPAREN,
            ")": TokenType.RPAREN,
        }
        return token_mapping.get(char, TokenType.EOF)


class AST:
    """Base class for all nodes in the abstract syntax tree."""

    pass


class BinOp(AST):
    """Binary operator node in the AST."""

    def __init__(self, left, op, right):
        self.left = left
        self.op = op
        self.right = right


class Num(AST):
    """Numeric literal node in the AST."""

    def __init__(self, token):
        self.token = token
        self.value = token.value


class Parser:
    """Parses a list of tokens into an abstract syntax tree."""

    def __init__(self, lexer):
        self.lexer = lexer
        self.current_token = self.lexer.get_next_token()

    def error(self):
        raise ParsingError("Parsing error")

    def eat(self, token_type):
        """Compare the current token type with the passed token type and if they match then 'consume' the current token and proceed to the next token."""
        if self.current_token.type == token_type:
            self.current_token = self.lexer.get_next_token()
        else:
            self.error()

    def factor(self):
        """Parse factors (integers and expressions in parentheses)."""
        token = self.current_token
        if token.type == TokenType.INTEGER:
            self.eat(TokenType.INTEGER)
            return Num(token)
        elif token.type == TokenType.LPAREN:
            self.eat(TokenType.LPAREN)
            node = self.expr()
            self.eat(TokenType.RPAREN)
            return node

    def term(self):
        """Parse terms (factors possibly multiplied or divided by other factors)."""
        node = self.factor()
        while self.current_token.type in (TokenType.MUL, TokenType.DIV):
            token = self.current_token
            if token.type in (TokenType.MUL, TokenType.DIV):
                self.eat(token.type)
            node = BinOp(left=node, op=token, right=self.factor())
        return node

    def expr(self):
        """Arithmetic expression parser / interpreter."""
        node = self.term()
        while self.current_token.type in (TokenType.PLUS, TokenType.MINUS):
            token = self.current_token
            if token.type in (TokenType.PLUS, TokenType.MINUS):
                self.eat(token.type)
            node = BinOp(left=node, op=token, right=self.term())
        return node


class Interpreter:
    """Interpreter for arithmetic expressions represented as an AST."""

    def __init__(self, parser):
        self.parser = parser

    def visit(self, node):
        """Visit a node in the AST."""
        method_name = f"visit_{type(node).__name__}"
        visitor = getattr(self, method_name, self.generic_visit)
        return visitor(node)

    def visit_BinOp(self, node):
        if node.op.type == TokenType.PLUS:
            return self.visit(node.left) + self.visit(node.right)
        elif node.op.type == TokenType.MINUS:
            return self.visit(node.left) - self.visit(node.right)
        elif node.op.type == TokenType.MUL:
            return self.visit(node.left) * self.visit(node.right)
        elif node.op.type == TokenType.DIV:
            return self.visit(node.left) / self.visit(node.right)

    def visit_Num(self, node):
        return node.value

    def interpret(self):
        """Interpret the expression represented by the AST."""
        tree = self.parser.expr()
        return self.visit(tree)

    def generic_visit(self, node):
        raise Exception(f"No visit_{type(node).__name__} method")


def main():
    """Main function to run the interpreter."""
    while True:
        try:
            text = input('Enter expression (or "exit" to quit): ')
            if text.lower() == "exit":
                print("Exiting the program.")
                break
            lexer = Lexer(text)
            parser = Parser(lexer)
            interpreter = Interpreter(parser)
            result = interpreter.interpret()
            print(result)
        except Exception as e:
            print(e)


if __name__ == "__main__":
    main()
