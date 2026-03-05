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

%token <long> NUMBER 
%token <std::string> IDENT

%nterm <AstNode*> input program statementList
%nterm <AstNode*> declaration statement
%nterm <AstNode*> varDecl optVarDecl
%nterm <AstNode*> funcDecl optParamList paramList paramListExtra param  returnType optBlock
%nterm <AstNode*> ifStmnt optElse
%nterm <AstNode*> whileStmnt assignment printStmnt returnStmnt exprStmnt 
%nterm <AstNode*> block funcCall
%nterm <AstNode*> expr 
%nterm <AstNode*> logicalOr logicalAnd equality comparison
%nterm <AstNode*> term factor unary primary
%nterm <AstNode*> optArgList argList

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

input: program { $$ = $1; }
;

program: program declaration {  $$ = $1;
                                if($2) $$->Statements.push_back($2); }
    |                        {  $$ = new Program(); }
;

declaration: statement         { $$ = $1; }
    | funcDecl                 { $$ = $1; }
;


statementList : statementList statement { $$ = $1; 
                                          if($2) $$->statements.push_back($2); } 
    |                                   {   $$ = new Block(); }
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

varDecl: R_INT IDENT optVarDecl SEMICOL { $$ = new VarDeclStmnt(Type::Int, $2, static_cast<AstNode*>($3)); }
;

optVarDecl: ASSIGN expr  { $$ = $2; }
    |                    { $$ = nullptr; }
;

funcDecl: R_DEF IDENT OPEN_PAR optParamList CLOSE_PAR ARROW returnType optBlock { $$ = new FuncDeclStmnt($2, $7, $4, static_cast<AstNode*>($8)); }
;

optParamList: paramList  { $$ = $1; }
    |                    { $$ = new std::vector<AstNode*>(); }
;

paramList: paramList COMMA param { $$ = $1;
                                   $$->push_back($3); }
    |   param                    { $$ = new std::vector<AstNode*>();
                                   $$->push_back($1); }
;

param: R_INT IDENT { $$ = new Ident($2,0); }
    | R_INT R_REF IDENT { $$ = new Ident($3,1);}
;

returnType: R_INT { $$ = Type::Int;}
    | R_VOID { $$ = Type::Void;}
;

optBlock: block    { $$ = $1; }
    |              { $$ = new Block(); }
;

assignment: IDENT ASSIGN expr SEMICOL                   { $$ = new Assignment($1, static_cast<AstNode*>($3)); }
;

ifStmnt: R_IF OPEN_PAR expr CLOSE_PAR statement optElse { $$ = new IfStmnt(static_cast<AstNode*>($3), static_cast<AstNode*>($5), static_cast<AstNode*>($6)); }
;

optElse: R_ELSE statement   { $$ = $2; }
    |                       { $$ = nullptr; }
;

whileStmnt: R_WHILE OPEN_PAR expr CLOSE_PAR statement { $$ = new WhileStmnt(static_cast<AstNode*>($3), static_cast<AstNode*>($5));}
;

printStmnt: R_PRINT OPEN_PAR expr CLOSE_PAR SEMICOL { $$ = new PrintStmnt(static_cast<AstNode*>($3));}
;

returnStmnt: R_RETURN SEMICOL { $$ = new ReturnStmnt(nullptr); }
    | R_RETURN expr SEMICOL   { $$ = new ReturnStmnt(static_cast<AstNode*>($2));}
;

exprStmnt: funcCall SEMICOL         { $$ = $1; }
;

block: OPEN_BRAC statementList CLOSE_BRAC { $$ = $2; }
;


/* ================= EXPRESSIONS ================= */

expr: logicalOr                { $$ = $1; }
;

logicalOr: logicalOr OP_OR logicalAnd 	{ $$ = new OrExpr($1, $3); }
    | logicalAnd 		  	{ $$ = $1; }
;

logicalAnd: logicalAnd OP_AND equality 	{ $$ = new AndExpr($1, $3); }
    | equality				{ $$ = $1; }
;

equality: equality OP_EQUAL comparison 	{ $$ = new EqualExpr($1, $3); }
    | equality OP_N_EQUAL comparison 	{ $$ = new NotEqualExpr($1, $3); }
    | comparison    			{ $$ = $1; }
;

comparison: comparison OP_LS term 	{ $$ = new LessExpr($1, $3); }
    | comparison OP_GR term		    { $$ = new GreaterExpr($1, $3); }
    | comparison OP_LS_EQUAL term 	{ $$ = new LessEqualExpr($1, $3); }
    | comparison OP_GR_EQUAL term 	{ $$ = new GreaterEqualExpr($1, $3); }
    | term				            { $$ = $1; }
;

term: term OP_PLUS factor	{ $$ = new AddExpr($1, $3); }
    | term OP_SUBS factor	{ $$ = new SubExpr($1, $3); }
    | factor 				{ $$ = $1; }
;

factor: factor OP_MULT unary 	{ $$ = new MultExpr($1, $3); }
    | factor OP_DIV unary		{ $$ = new DivExpr($1, $3); }
    | factor OP_MOD unary		{ $$ = new ModExpr($1, $3); }
    | unary				        { $$ = $1; }
;

unary: OP_NOT unary 	{ $$ = new NotExpr($2); }
    | OP_SUBS unary	    { $$ = new NegExpr($2); }
    | primary		    { $$ = $1;}
;

primary: NUMBER         { $$ = new Number($1); }
    | IDENT        { $$ = new Ident($1,0);  }
    | IDENT OPEN_PAR optArgList CLOSE_PAR {$$ = new FuncCall($1,$3); }
    | OPEN_PAR expr CLOSE_PAR  { $$ = $2; }
;

optArgList: argList 	{ $$ = $1; }
    |                   { $$ = new std::vector<AstNode*>(); }
;

argList: expr            { $$ = new std::vector<AstNode*>();
                           $$->push_back($1)}
    | argList COMMA expr { $$ = $1;
                           $$-> push_back($3)}
;

%%