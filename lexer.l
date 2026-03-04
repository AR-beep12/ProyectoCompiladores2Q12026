%option lexer="ExprLexer"
%option lex="getNextToken"

%option bison-cc
%option bison-cc-namespace = "ExprParser"
%option bison-cc-parser = "Parser"

%top{
#include "ExprParser.hpp"
using Token = ExprParser::Parser::token;
}

%%
"int" {return Token::R_INT;}
"void" {return Token::R_VOID;}
"if" {return Token::R_IF;}
"else" {return Token::R_ELSE;}
"while" {return Token::R_WHILE;}
"print" {return Token::R_PRINT;}
"def" {return Token::R_DEF;}
"return" {return Token::R_RETURN;}
"ref" {return Token::R_REF;}

[a-zA-Z_][a-zA-Z0-9_]* {yylval.emplace<std::string>(text()); return Token::IDENT;}
(-|+)?[0-9]+ {yylval.emplace<long>(std::stoi(text())); return Token::NUMBER;}


"+" {return Token::OP_PLUS;}
"-" {return Token::OP_SUBS; }
"*" {return Token::OP_MULT;}
"/" {return Token::OP_DIV; }
"%" {return Token::OP_MOD;}

"(" {return Token::OPEN_PAR;}
")" {return Token::CLOSE_PAR;}
"{" {return Token::OPEN_BRAC;}
"}" {return Token::CLOSE_BRAC;}
";" {return Token::SEMICOL;}
"," {return Token::COMMA;}
"->"{return Token::ARROW;}

"&&" {return Token::OP_AND; }
"||" {return Token::OP_OR; }
"!" {return Token::OP_NOT;}
"=" {return Token::ASSIGN;}

"==" {return Token::OP_EQUAL;}
"!=" {return Token::OP_N_EQUAL;}
"<" {return Token::OP_LS; }
">" {return Token::OP_GR; }
"<=" {return Token::OP_LS_EQUAL;}
">=" {return Token::OP_GR_EQUAL;}

\/\/[^\r\n]* /*no action: ignore all white space*/
[\t\r\n] /*no action: ignore all white space*/
<<EOF>> {return 0;}
%%