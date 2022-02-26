%{
#include "token.h"
int cur_line_num = 1;
void init_scanner();
void lex_error(char* msg, int line);
%}

/* Definitions, note: \042 is '"' */
INTEGER             ([0-9]+)
BOOL                ("TRUE""FALSE")
UNTERM_STRING       (\042[^\042\n]*)
STRING              (\042[^\042\n]*\042)
IDENTIFIER          ([_a-zA-Z][_a-zA-Z0-9]*)
OPERATOR            ([+*-/%=,:!<>(){}])
SINGLE_COMMENT1     ("//"[^\n]*)
%%

[\n]                { cur_line_num++;                       }
[ \t\r\a]+          { /* ignore all spaces */               }
{SINGLE_COMMENT1}   { /* skip for single line comment */    }

{OPERATOR}          { return yytext[0];         }   

"DECLARE"           { return T_Declare;         }
"<-"                { return T_Lm;              }
"INTEGER"           { return T_Integer;         }
"REAL"              { return T_Real;            }
"BOOLEAN"           { return T_Boolean;         }
"<="                { return T_Le;              }
">="                { return T_Ge;              }
"<>"                { return T_Ne;              }
"MOD"               { return T_Mod;             }
"AND"               { return T_And;             }
"OR"                { return T_Or;              }
"FOR"               { return T_For;             }
"NEXT"              { return T_Next;            }
"WHILE"             { return T_While;           }
"IF"                { return T_If;              }
"ELSE"              { return T_Else;            }
"THEN"              { return T_Then;            }
"ENDIF"             { return T_Endif;           }
"RETURN"            { return T_Return;          }
"INPUT"             { return T_Input;           }
"OUTPUT"            { return T_Output;          }

{INTEGER}           { return T_IntConstant;     }
{BOOL}              { return T_BoolConstant;    }
{STRING}            { return T_StringConstant;  }
{IDENTIFIER}        { return T_Identifier;      }

<<EOF>>             { return 0; }

{UNTERM_STRING}     { lex_error("Unterminated string constant", cur_line_num);  }
.                   { lex_error("Unrecognized character", cur_line_num);        }

%%

int main(int argc, char* argv[]) {
    int token;
    init_scanner();
    while (token = yylex()) {
        print_token(token);
        puts(yytext);
    }
    return 0;
}

void init_scanner() {
    printf("%-20s%s\n", "TOKEN-TYPE", "TOKEN-VALUE");
    printf("-------------------------------------------------\n");
}

void lex_error(char* msg, int line) {
    printf("\nError at line %-3d: %s\n\n", line, msg);
}

int yywrap(void) {
    return 1;
}