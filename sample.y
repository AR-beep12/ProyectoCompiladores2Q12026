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


%nterm <AstNode*> program statementList
%nterm <AstNode*> declaration statement
%nterm <AstNode*> varDecl optVarDecl
%nterm <AstNode*> funcDecl optParamList paramList paramListExtra param  returnType optBlock
%nterm <AstNode*> ifStmnt optElse
%nterm <AstNode*> whileStmnt assignment printStmnt returnStmnt exprStmnt 
%nterm <AstNode*> block funcCall


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

program: program declaration {}
    |              { $$ = nullptr; }
;

declaration: statement         { $$ = $1; }
    | funcDecl                 { $$ = $1; }
;

statementList: statementList statement {}
    |              { $$ = nullptr; }
;

statement: varDecl             { $$ = $1; }
    | assignment               { $$ = $1; }
    | ifStmnt                  { $$ = $1; }
    | whileStmnt               { $$ = $1; }
    | printStmnt               { $$ = $1; }
    | returnStmnt              { $$ = $1; }
    | exprStmnt                { $$ = $1; }
    | block                    { $$ = $1; }
;

varDecl: R_INT IDENT optVarDecl SEMICOL {}
;

optVarDecl: ASSIGN expr        { $$ = $2; }
    |              { $$ = nullptr; }
;

funcDecl: R_DEF IDENT OPEN_PAR optParamList CLOSE_PAR ARROW returnType optBlock {}
;

optParamList: paramList                { $$ = $1; }
    |              { $$ = nullptr; }
;

paramList: param {}
    | paramList COMMA param {}
;

param: R_INT IDENT {}
    | R_INT R_REF IDENT {}
;

returnType: R_INT {}
    | R_VOID {}
;

optBlock: block    { $$ = $1; }
    |              { $$ = nullptr; }
;

assignment: IDENT ASSIGN expr SEMICOL {}
;

ifStmnt: R_IF OPEN_PAR expr CLOSE_PAR statement optElse {}
;

optElse: R_ELSE statement         { $$ = $2; }
    |              { $$ = nullptr; }
;

whileStmnt: R_WHILE OPEN_PAR expr CLOSE_PAR statement {}
;

printStmnt: R_PRINT OPEN_PAR expr CLOSE_PAR SEMICOL {}
;

returnStmnt: R_RETURN SEMICOL {}
    | R_RETURN expr SEMICOL   {}
;

exprStmnt: funcCall SEMICOL         { $$ = $1; }
;

block: OPEN_BRAC statementList CLOSE_BRAC { $$ = $2; }
;


/* ================= EXPRESSIONS ================= */

expr: logicalOr                { $$ = $1; }
;

logicalOr: logicalOr OP_OR logicalAnd 	{}
    | logicalAnd 		  	{ $$=$1; }
;

logicalAnd: logicalAnd OP_AND equality 	{}
    | equality				{ $$=$1; }
;

equality: equality OP_EQUAL comparison 	{}
    | equality OP_N_EQUAL comparison 	{}
    | comparison    			{ $$=$1; }
;

comparison: comparison OP_LS term 	{}
    | comparison OP_GR term		{}
    | comparison OP_LS_EQUAL term 	{}
    | comparison OP_GR_EQUAL term 	{}
    | term				{ $$=$1; }
;

term: term OP_PLUS factor		{}
    | term OP_SUBS factor		{}
    | factor 				{ $$=$1; }
;

factor: factor OP_MULT unary 		{}
    | factor OP_DIV unary		{}
    | factor OP_MOD unary		{}
    | unary				{ $$=$1; }
;

unary: OP_NOT unary 	{}
    | OP_SUBS unary	{}
    | primary		{ $$=$1;}
;

primary: NUMBER         { $$ = new Number($1); }
    | IDENTIFIER        { $$ = new Ident($1);  }
    | IDENTIFIER OPEN_PAR optArgList CLOSE_PAR {$$ = new FuncCall($1,$3); }
    | OPEN_PAR expr CLOSE_PAR  { $$ = $2; }
;

optArgList: argList 	{}
    |              { $$ = nullptr; }
;

argList: expr 	{}
    | argList COMMA expr {}
;

%%