%language "C++" 
%require "3.2" 

%token OP_PLUS "+" 
%token OP_MULT "*"
%token OP_DIV "/"
%token OP_SUBS "-"
%token OPEN_PAR "("
%token CLOSE_PAR ")"
%token <int> NUMBER 
%token <std::string> IDENT

%nterm <AstNode*> input
%nterm <Expr*> expr term factor

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