%language "C++" 
%require "3.2" 

%token R_INT R_VOID
%token R_IF R_ELSE
%token R_WHILE
%token R_PRINT
%token R_DEF
%token R_RETURN
%token R_REF

%token OP_PLUS OP_SUBS OP_MULT OP_DIV OP_MOD

%token OPEN_PAR CLOSE_PAR
%token OPEN_BRAC CLOSE_BRAC
%token SEMICOL COMMA ARROW

%token OP_AND OP_OR OP_NOT ASSIGN

%token OP_EQUAL OP_N_EQUAL 
%token OP_LS OP_GR OP_LS_EQUAL OP_GR_EQUAL

%token <int> NUMBER 
%token <std::string> IDENT


%nterm <AstNode*> input expr term factor

%define api.value.type variant

%define parse.error verbose 
%define api.namespace {ExprParser}
%define api.parser.class {Parser} 

%parse-param {ExprLexer& lexer}
%parse-param {std::unordered_map<std::string, int>& vars}
%parse-param {std::vector<AstNode*>& Ast}

%code requires {
    #include <unordered_map>
    #include <string>
    #include <iostream>
    #include <stdexcept>
    #include "tree.hpp" 

    class ExprLexer;
}

%code {
    #include "ExprLexer.hpp"

    #define yylex(v) lexer.getNextToken(v)

    namespace ExprParser {
        void Parser::error(const std::string& msg) {
            std::cerr << "Error: " << msg << '\n';
        }
    }
}

%% 

input: expr { 
    Ast.push_back($1);    
    $$ = $1; 
}
;

program: declaration program { } 
	| 		{ $$ = nullptr; } 

declaration: statement	{ $$ = $1}
	| funcDecl 	{ $$ = $1}

statementList: statement statementList {}
	| 		{ $$ = nullptr; } 


statement: varDecl 	{ $$ = $1}
	| assignment 	{ $$ = $1}
	| ifStmt 	{ $$ = $1}
	| whileStmnt 	{ $$ = $1}
	| printStmnt 	{ $$ = $1}
	| returnStmnt 	{ $$ = $1}
	| exprStmnt 	{ $$ = $1}
	| block 	{ $$ = $1}


varDecl: R_INT IDENT optVarDecl SEMICOL {}

optVarDecl: ASSIGN expr { $$ = $2; } 
	| 		{ $$ = nullptr; } 

funcDecl: R_DEF IDENT OPEN_PAR optParamList CLOSE_PAR ARROW returnType optBlock {}

optParamList: paramList { $$ = $1; }
	| 		{ $$ = nullptr; } 

paramList: param paramListExtra {}

paramListExtra: COMMA param paramListExtra {}
	| 		{ $$ = nullptr; } 

param: R_INT IDENT {}
	| R_INT R_REF IDENT {}

returnType: R_INT {}
	| R_VOID {}

optBlock: block 	{ $$ = $1}
	| 		{ $$ = nullptr; } 

assignment: IDENT ASSIGN expr SEMICOL {}

ifStmnt: R_IF OPEN_PAR expr CLOSE_PAR statement optElse {}

optElse: R_ELSE statement { $$ = $2}
	| 		{ $$ = nullptr; } 

whileStmnt: R_WHILE OPEN_PAR expr CLOSE_PAR statement {}

printStmnt: R_PRINT OPEN_PAR expr CLOSE_PAR SEMICOL {}

returnStmnt: R_RETURN SEMICOL {}
	| R_RETURN expr SEMICOL { $$ = $2}

exprStmnt: funcCall SEMICOL { $$ = $1}

block: OPEN_BRAC statementList CLOSE_BRAC { $$ = $2}


//input: expr { std::cout << "Value " << $1->toString() << "\n"; }
//;

expr: expr OP_PLUS term { $$ = new AddExpr($1, $3);}
    | expr OP_SUBS term { $$ = new SubExpr($1, $3);}
    | term              { $$ = $1; }
; 

term: term OP_MULT factor   { $$ = new MultExpr($1, $3); }
    | term OP_DIV factor    { $$ = new DivExpr($1, $3); }
    | factor                { $$ = $1; }
;

factor: OPEN_PAR expr CLOSE_PAR { $$ = $2; }
      | NUMBER                  { $$ = new Number($1); }
      | IDENT                   { $$ = new Ident($1); }
%%