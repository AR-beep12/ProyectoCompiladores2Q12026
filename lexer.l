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
[0-9]+ {yylval.emplace<long>(std::stoi(text())); return Token::NUMBER;}
[a-zA-Z_][a-zA-Z0-9_]* {yylval.emplace<std::string>(text()); return Token::IDENT;}
"+" {return Token::OP_PLUS;}
"-" {return Token::OP_SUBS; }
"/" {return Token::OP_DIV; }
"*" {return Token::OP_MULT;}
")" {return Token::CLOSE_PAR;}
"(" {return Token::OPEN_PAR;}
[\t\r\n] /*no action: ignore all white space*/
<<EOF>> {return 0;}
%%