cmake_minimum_required(VERSION 3.10)
project(ExprProj)

set (CMAKE_CXX_STANDARD 17)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

find_package(Reflex REQUIRED)
find_package(BISON REQUIRED)
find_package(TreeCC REQUIRED)

message(STATUS "source dir ${CMAKE_SOURCE_DIR}")
message(STATUS "binary dir ${CMAKE_BINARY_DIR}")

#all about lexer--------------------------------------
set (LEXER_SOURCE_FILE "${CMAKE_SOURCE_DIR}/lexer.l")

add_custom_command(
    OUTPUT ExprLexer.cpp ExprLexer.hpp
    COMMAND Reflex::Reflex -o ExprLexer.cpp --header-file=ExprLexer.hpp ${LEXER_SOURCE_FILE}
    DEPENDS ${LEXER_SOURCE_FILE}
    COMMENT "building lexer"
)

#all about parser-------------------------------------
set (PARSER_SOURCE_FILE "${CMAKE_SOURCE_DIR}/parser.y")

BISON_TARGET(ExprParser ${PARSER_SOURCE_FILE} ${CMAKE_BINARY_DIR}/ExprParser.cpp
              DEFINES_FILE ${CMAKE_BINARY_DIR}/ExprParser.hpp
              COMPILE_FLAGS "-Wconflicts-sr -Wcounterexamples") 


#all about ast-------------------------------------
set (AST_SOURCE_FILE "${CMAKE_SOURCE_DIR}/ast.tc")
message(STATUS "TreeCC found: ${TREECC_EXECUTABLE}")
message(STATUS "TreeCC version: ${TREECC_VERSION}")

add_custom_command(
	OUTPUT tree.cpp tree.hpp
	COMMAND ${TREECC_EXECUTABLE} -o tree.cpp -h tree.hpp ${AST_SOURCE_FILE}
    DEPENDS ${AST_SOURCE_FILE}
    COMMENT "building Ast"
    )

#general --------------------------------
add_executable(${PROJECT_NAME} ExprLexer.cpp ExprLexer.hpp
                               ExprParser.cpp ExprParser.hpp
                               tree.cpp tree.hpp
                               main.cpp)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} )

target_link_libraries(${PROJECT_NAME} PRIVATE Reflex::ReflexLibStatic)