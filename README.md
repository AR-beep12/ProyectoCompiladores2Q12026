# ProyectoCompiladoresQ12026


## Grammar 
program → declaration program 
	| E

declaration →   statement
		| funcDecl

statementList → statement statementList
		| E

statement → 	 varDecl
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
             | ε

paramList → param paramListExtra

paramListExtra → "," param paramListExtra
		| ε

param → "int" IDENTIFIER
	| "int" "ref" IDENTIFIER

returnType → "int"
	   | "void"

optBlock → block
   	 | ε


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

logicalOr → logicalAnd logicalOrExtra

logicalOrExtra → "||" logicalAnd logicalOrExtra
		| E

logicalAnd → equality logicalAndExtra

logicalAndExtra → "&&" equality logicalAndExtra
		  |E

equality → comparison equalityExtra
	
equalityExtra → "==" comparison equalityExtra
		| "!=" comparison equalityExtra
		| E

comparison → term comparisonExtra 

comparisonExtra → LogOp term comparisonExtra
		| E

LogOp → "<"
	| ">" 
	| "<=" 
	| ">="
	
term → factor termExtra

termExtra → termOp factor termExtra
	  | E

termOp → "+" 
	| "-"

factor → unary factorExtra
factorExtra → factorOp unary factorExtra
	    | E

factorOp → "*" 
	| "/" 
	| "%"

unary → "!" unary
	| "-" unary
	| primary

primary → INTEGER 
	| IDENTIFIER primaryExtra
	| "(" expression ")"

primaryExtra → "(" optArgList ")"
	      | E

optArgList → argList
	   | E

argList → expression argListExtra

argListExtra → "," expression argListExtra
	     | E
