# ProyectoCompiladoresQ12026


## Grammar 
program → program declaration
        | E

declaration → varDecl
            | funcDecl

statementList → statementList statement
              | E

statement → varDecl
          | assignment
          | ifStmt
          | whileStmt
          | printStmt
          | returnStmt
          | exprStmt
          | block

varDecl → "int" IDENTIFIER optVarDecl ";"

optVarDecl → "=" expression
           | E

funcDecl → "def" IDENTIFIER "(" optParamList ")" "->" returnType optBlock

optParamList → paramList
             | E

paramList → paramList "," param
          | param

param → "int" IDENTIFIER
      | "int" "ref" IDENTIFIER

returnType → "int"
           | "void"

optBlock → block
         | E

assignment → IDENTIFIER "=" expression ";"

ifStmt → "if" "(" expression ")" statement optElse

optElse → "else" statement
        | E

whileStmt → "while" "(" expression ")" statement

printStmt → "print" "(" expression ")" ";"

returnStmt → "return" ";"
           | "return" expression ";"

exprStmt → funcCall ";"

block → "{" statementList "}"

expression → logicalOr

logicalOr → logicalOr "||" logicalAnd
          | logicalAnd

logicalAnd → logicalAnd "&&" equality
           | equality

equality → equality "==" comparison
         | equality "!=" comparison
         | comparison

comparison → comparison "<" term
           | comparison ">" term
           | comparison "<=" term
           | comparison ">=" term
           | term

term → term "+" factor
     | term "-" factor
     | factor

factor → factor "*" unary
       | factor "/" unary
       | factor "%" unary
       | unary

unary → "!" unary
      | "-" unary
      | primary

primary → INTEGER
        | IDENTIFIER
        | IDENTIFIER "(" optArgList ")"
        | "(" expression ")"

optArgList → argList
           | E

argList → argList "," expression
        | expression