<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="github-markdown.css">
<link href="https://cdn.bootcss.com/highlight.js/9.6.0/styles/atelier-lakeside-dark.min.css" rel="stylesheet"/>

<script src="https://cdn.bootcss.com/highlight.js/9.11.0/highlight.min.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
<script src="https://cdn.bootcss.com/highlightjs-line-numbers.js/1.1.0/highlightjs-line-numbers.min.js"></script>
<script>hljs.initLineNumbersOnLoad();</script>


<h1 style="color: #E21951; font-weight: bold">The Pseudocode Compiler</h1>

<h2 style="color: #E21951; font-weight: bold">The Full Compiling Process</h2>

1. Input the source code(CAIE Pseudocode).  
2. Convert source code into IR(Intermediate representation).  
3. Convert IR into Assembly(RISC-V Assembly).
(And the Assembler will turn Assembly Language into machine code which is executable)  

<h2 style="color: #E21951; font-weight: bold">Lexer(Lexical Analyzer)</h2>

<h3 style="color: #E21951">Source code(scanner.l)</h3>

```
 %{
     #include "token.h"
     int cur_line_num = 1;
     void init_scanner();
     void lex_error(char* msg, int line);
 %}

 /* Definitions, note: \042 is '"' */
 INTEGER             ([0-9]+)
 BOOLEAN             ("TRUE"|"FALSE")
 UNTERM_STRING       (\042[^\042\n]*)
 STRING              (\042[^\042\n]*\042)
 UNTERM_CHAR         ('[^'\n])
 CHAR                ('[^'\n]')
 IDENTIFIER          ([_a-zA-Z][_a-zA-Z0-9]*)
 OPERATOR            ([+-*/%=,:!<>()\133\135{}])
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
 "ENDWHILE"          { return T_Endwhile;        }
 "IF"                { return T_If;              }
 "ELSE"              { return T_Else;            }
 "THEN"              { return T_Then;            }
 "ENDIF"             { return T_Endif;           }
 "RETURN"            { return T_Return;          }
 "INPUT"             { return T_Input;           }
 "OUTPUT"            { return T_Output;          }

 {INTEGER}           { return T_IntConstant;     }
 {BOOLEAN}           { return T_BoolConstant;    }
 {STRING}            { return T_StringConstant;  }
 {CHAR}              { return T_CharConstant;    }
 {IDENTIFIER}        { return T_Identifier;      }

 <<EOF>>             { return 0; }


 {UNTERM_STRING}     { lex_error("Unterminated string constant", cur_line_num);  }
 {UNTERM_CHAR}       { lex_error("Unterminated char constant", cur_line_num);    }
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
```

What the lexer(scanner) does is to convert raw text source code into tokens.  

In most programming languages there are these token categories. *[2]*
- Keywords are words in the language structure itself, like WHILE or IF or TRUE.
- Identifiers are the name of variables, FUNCTIONs, PROCEDUREs or other code elements.
- Numbers could be formatted as INTEGER or REAL values.
- Strings are literal character sequences that must be clearly distinguished from keywords and identifiers. The data type char could stated as string.

I used flex to do lexical analysis, because it was intuitionistic and convenient.

Flex is a fast lexical analyzer generator.   
Each flex rule has a regular expression(called the pattern) and an associated set of statements(called the action). *[1]*  

Basically when the scanner is run, it looks for strings matching the pattern. After match is determined, the action(s) corresponding to the matched pattern is then executed. *[5]*  

___*Tip: All regular expressions(patterns) in this article will be bold and italic.(The same font as this sentence)___

<h3 style="color: #E21951">INTEGER</h3>

___[0-9]+___ includes all integers. *[1]*  
X+ means that X is repeated once or more.  
- ___[0-9]___ means the alternation of the characters in a ranged list(in this case [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).  
- This pattern matches digit characters.  
- e.g: 2345 would match this pattern.

<h3 style="color: #E21951">BOOLEAN</h3>

The pattern of boolean is ___"TRUE"\|"FALSE"___.  
- ___X \| Y___ means either an X or a Y.  

Either "TRUE" or "FALSE" would match this pattern.


<h3 style="color: #E21951">STRING</h3>

According to the CAIE Pseudocode guide, a string is a sequence of zero or more characters, and should be delimited by double quotes.  

In this case, the pattern ___"[^"\n]*"___ would work.  
- The symbol ___^___ means not this this character.  
- e.g: ___[^0-9]___ matches non-digit characters. *[1]*  
- The symbol \n represents a line break(new line).  
- ___X*___ means X is repeated zero or many times. *[4]*  

The meaning of this pattern is the object scanned starts and ends with a double qoute and Contains any character except double quote or a line break.  

However, double quotes can not be used in regular expression because they somtimes need to be used to express string objects.  
Therefore, the double quotes need to be converted into octonary ASCII code(American Standard Code for Information Interchange) which is \042.  
The final pattern for string constant is ___\042[^\042\n]*\042___.  

This technique is also used when matching square brackets because they also could not appear in regular expressions.  
In the pattern of operators ___[+*-/%=,:!<>()\133\135{}]___: \133 is the left square bracket and \135 is the right square bracket.  

<h3 style="color: #E21951">CHAR</h3>

In the same way, a char is a single character which is delimited by single quotes could be expressed with the pattern ___'[^'\n]'___.  
Meaning that the object scanned starts and ends with a single qoute and Contains any character except single quote or a line break.  
Single quotes could exist in regular expressions so there is no need to convert them into ASCII codes.  

<h3 style="color: #E21951">Errors</h3>

Basic syntax errors could be reported by the lexer.  
1. Unrecognized character 

<h2 style="color: #E21951; font-weight: bold">Parser</h2>

<h2 style="color: #E21951; font-weight: bold">Reference</h2>

1. http://web.stanford.edu/class/archive/cs/cs143/cs143.1128/handouts/050%20Flex%20In%20A%20Nutshell.pdf flex Rules  
2. https://www3.nd.edu/~dthain/compilerbook/compilerbook.pdf Chapter3 Kinds of Tokens  
3. https://holub.com/goodies/compiler/compilerDesignInC.pdf  
4. https://www.cs.virginia.edu/~cr4bd/flex-manual/Patterns.html#Patterns
5. https://www.cs.virginia.edu/~cr4bd/flex-manual/Matching.html#Matching
6. http://web.stanford.edu/class/archive/cs/cs143/cs143.1128/handouts/050%20Flex%20In%20A%20Nutshell.pdf 
