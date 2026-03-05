#include "ExprParser.hpp"
#include "ExprLexer.hpp"
#include "tree.hpp"
#include <iostream>
#include <fstream>
#include <unordered_map>

int main()
{
    std::ifstream input("input.txt");

    if (!input.is_open())
    {
        std::cerr << "Error: could not open input.txt\n";
        return 1;
    }

    ExprLexer my_lexer(input);
    std::unordered_map<std::string, int> vars{
        {"x", 10},
        {"y", 2},
    };

    std::vector<AstNode *> nodes;

    ExprParser::Parser my_parser(my_lexer, vars, nodes);

    try
    {
        int result = my_parser.parse();
        if (result == 0)
        {
            std::cout << "\n Parsing \n";
            if (!nodes.empty())
            {
                AstNode *root = nodes[0];
                std::cout << root->toString() << std::endl;
            }
        }
        else
        {
            std::cout << "\n Parsing failed\n";
        }
        std::cout << "Syntax Correct\n";
    }
    catch (const ExprParser::Parser::syntax_error &err)
    {
        std::cerr << err.what() << "\n";
    }
}