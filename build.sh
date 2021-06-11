#!/bin/bash

bison -d -v -r all Pi_parser.y
flex Pi_lexer.l
gcc -o mycompiler Pi_parser.tab.c lex.yy.c cgen.c -lfl