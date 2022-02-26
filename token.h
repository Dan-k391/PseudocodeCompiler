#ifndef TOKEN_H
#define TOKEN_H

#include <stdio.h>

typedef enum {
    T_Declare = 256, T_Lm, T_Integer, T_Real, T_Boolean, T_Le, T_Ge,
    T_True, T_False, T_Ne, T_Mod, T_And,
    T_Or, T_IntConstant, T_BoolConstant, T_StringConstant, T_Identifier,
    T_For, T_Next, T_While, T_If, T_Else, T_Then, T_Endif, T_Return,
    T_Input, T_Output
} TokenType;

static void print_token(int token) {
    static char* token_strs[] = {
        "T_Declare", "T_Lm", "T_Integer", "T_Real", "T_Boolean", "T_Le", "T_Ge",
        "T_True", "T_False", "T_Ne", "T_Mod", "T_And", 
        "T_Or", "T_IntConstant", "T_BoolConstant", "T_StringConstant", "T_Identifier", 
        "T_For", "T_Next", "T_While", "T_If", "T_Else", "T_Then", "T_Endif", "T_Return",
        "T_Input", "T_Output"
    };

    if (token < 256) {
        printf("%-20c", token);
    } else {
        printf("%-20s", token_strs[token-256]);
    }
}

#endif