---
id: "compiler"
---

@import "style.less"

# The Pseudocode Compiler

## 1. Introduction
I have chosen to study Computer Science at AS level. Students were taught to write programs with a language named Pseudocode during this subject. "Pseudocode is a plain language description of the steps in an algorithm or another system." (Wikipedia definition)

However, due to helping students to master high-level languages, CAIE(Cambridge Assessment International Education) developed a particular syntax and content for the Pseudocode language. The language's syntax is based on Microsoft Visual Basic, but not the same. Therefore, Pseudocode could not be compiled into an executable file and run on the computer. Meaning that the code could only be written on paper and checked by the teacher whether or not it is valid. In my opinion, this technique of evaluating code does not match the aim of learning programming. Moreover, it is easy for human to make mistakes when judging code compared with the computer. 

Therefore, I decided to develop an open-source basic compiler for CAIE pseudocode. A compiler is a program that translates a specific high-level language into machine code that a computer can execute. With the help of this compiler, each student could run Pseudocode programs and improve their coding skills. It could also assist teachers in judging students' code. Besides, I thought that making the compiler open source has many advantages, too. For example, helping them learn the bases of compiling and giving students that want to develop a compiler a reference.

RESEARCH METHODS. (need to be added)

I believe working on this project could significantly improve my coding skills, enhance my understanding of programming languages, and comprehend fundamental computer technologies. Additionally, searching for useful information through books and papers about compilers is also a great challenge.  

This report acts as a guide to building a compiler, combining both theory and practice. The report goes through the procedure of developing a basic compiler. Starting from lexical analyzers to parsers and generation of code. 

I thought using frameworks such as LLVM (Low-Level Virtual Machine, A type of compiler framework) would not give me such experience. Therefore, I chose to use tools based on C such as flex and bison, for they are very convenient and they do not highly depend on frameworks.

## 2. The Full Compiling Process
1. Input the source code (CAIE Pseudocode).  
2. Convert source code into IR (Intermediate Representation).  
3. Convert IR into Assembly (RISC-V Assembly).  
(And the Assembler will turn Assembly Language into executable machine code)  

## 3. About CAIE Pseudocode

### 3.1. Variables and Data types

#### 3.1.1. Data types
The following keywords are used to designate some basic data types:
<table>
	<tr>
		<th>Data Type</th>
		<th>Keyword</th>
	</tr>
	<tr>
		<td>INTEGER</td>
		<td>a whole number</td>
	</tr>
	<tr>
		<td>REAL</td>
		<td>a number capable of containing a fractional part</td>
	</tr>
	<tr>
		<td>CHAR</td>
		<td>a single character</td>
	</tr>
	<tr>
		<td>STRING</td>
		<td>a sequence of zero or more characters</td>
	</tr>
	<tr>
		<td>BOOLEAN</td>
		<td>the logical values TRUE and FALSE</td>
	</tr>
</table>

#### 3.1.2. Literals
Literals of the above data types are written as follows:
<table>
	<tr>
		<th>Data Type</th>
		<th>Literal</th>
		<th>Example</th>
	</tr>
	<tr>
		<td>INTEGER</td>
		<td>Integer Written as normal in the denary system</td>
		<td>5, -3</td>
	</tr>
	<tr>
		<td>REAL</td>
		<td>Always written with at least one digit on either side of the decimal point, zeros being added if necessary</td>
		<td>4.7, 0.3, -4.0, 0.0</td>
	</tr>
	<tr>
		<td>CHAR</td>
		<td>A single character delimited by single quotes</td>
		<td>ꞌxꞌ, ꞌCꞌ, ꞌ@ꞌ</td>
	</tr>
	<tr>
		<td>STRING</td>
		<td>Delimited by double quotes. A string may contain no characters (i.e. the empty string)</td>
		<td>"This is a string", ""</td>
	</tr>
	<tr>
		<td>BOOLEAN</td>
		<td>TRUE, FALSE</td>
		<td>TRUE, FALSE</td>
	</tr>
</table>

#### 3.1.3. Identifiers
Identifiers (the names given to variables, constants, procedures and functions) are in mix case. They can only
contain letters (A–Z, a–z), digits (0–9) and the underscore character ( _ ). They must start with a letter and not
a digit.

#### 3.1.4. Variable declaration
Declarations are made as follows:
```
DECLARE <identifier> : <data type>
```

### 3.2. Common operations

#### 3.2.1. Input and output
Values are input using the INPUT command and output using the OUTPUT command as follows:
```
INPUT <identifier>
OUTPUT <value(s)>
```
e.g.
```
INPUT Answer
OUTPUT Score
OUTPUT "You have ", Lives, " lives left"
```

#### 3.2.2. Arithmetic operations
Standard arithmetic operator symbols are used:
- \+ Addition
- \- Subtraction
- \* Multiplication
- \ Division

#### 3.2.3. Relational operations
The following symbols are used for relational operators (also known as comparison operators):
<table>
	<tr>
		<th>Symbol</th>
		<th>Relational operator</th>
	</tr>
	<tr>
		<td>></td>
		<td>Greater than</td>
	</tr>
	<tr>
		<td><</td>
		<td>Less than</td>
	</tr>
	<tr>
		<td>>=</td>
		<td>Greater than or equal to</td>
	</tr>
	<tr>
		<td><=</td>
		<td>Less than or equal to</td>
	</tr>
	<tr>
		<td>=</td>
		<td>Equal to</td>
	</tr>
	<tr>
		<td><></td>
		<td>Not equal to</td>
	</tr>
</table>
The result of these operations is always of data type BOOLEAN.  

In complex expressions it is advisable to use parentheses to make the order of operations explicit.

## 4. Lexer (Lexical Analyzer or Scanner)

What the lexer/scanner does is scanning the stream of input characters and separating it into strings called tokens. *[9]*  

In most programming languages there are these token categories. *[2]*  
- Keywords are words in the language structure itself, like WHILE, IF or TRUE.
- Identifiers are the name of variables, FUNCTIONs, PROCEDUREs or other code elements.
- Numbers could be formatted as INTEGER or REAL values.
- Strings are literal character sequences that must be clearly distinguished from keywords and identifiers. The data type char could be stated as a string.

### 4.1. Flex
I used flex to do lexical analysis because it was intuitionistic and convenient.  

Flex is a fast lexical analyzer generator. Meaning that you can specify the pattern to match and actions to apply for each token. Flex takes the specification (input file) and generates a C source file that will implement it.

Each flex rule has a regular expression (called the pattern) and an associated set of statements (called the action). *[1]*  
Basically, when the scanner is run, it looks for strings matching the pattern. After the match is determined, the action(s) corresponding to the matched pattern is then executed. *[6]*  

___*Tip: All regular expressions (patterns) in this article will be bold and italic. (The same font as this sentence)___

Flex input files are structured as followed. *[10]*
```flex
%{
Declarations
%}
Definitions
%%
Rules
%%
User subroutines
```
Among the input file: *[10]* *[11]*
1. Between **%{** and **%}** is the segment **Declarations**, this part is all writen in ordinary C code and will be copied to the generated C file (lex.yy.c).
2. Between **%{** and **%}** is the **Definitions** section where you specify options for the scanner and can set up definitions to give names to regular expressions as a simple substitution mechanism that allows for more readable entries in the Rules section that follows
3.  **"Rules"**, which is between **%%** and **%%** is where you specify the patterns that identify your tokens and the action to perform upon 
recognizing each token.
4. Under **%%** is the part **"User subroutines"** which is also written in C code and will be copied to the generated C file.

### 4.2. Source code

#### scanner.l
```{.line-numbers}
%{
/* Declarations */
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
/* Rules */
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
/* User subroutines */
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

### 4.3. INTEGER
The pattern of integers is at line 9 in scanner.l.  
___[0-9]+___ includes all integers. *[1]*  
X+ means that X is repeated once or more.  
- ___[0-9]___ means the alternation of the characters in a ranged list (in this case [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).  
- This pattern matches digit characters.  
- e.g. 2345 would match this pattern.

### 4.4. REAL

### 4.5. CHAR
In the same way, a char is a single character that is delimited by single quotes could be expressed with the pattern ___'[^'\n]'___.  
Meaning that the object scanned starts and ends with a single quote and Contains any character except single quote or a line break.  
Single quotes could exist in regular expressions so there is no need to convert them into ASCII codes.  

### 4.6. STRING
According to the CAIE Pseudocode guide, a string is a sequence of zero or more characters, and should be delimited by double quotes.  

The final pattern for string constant is ___\042[^\042\n]*\042___.  
This technique is also used when matching square brackets because they also could not appear in regular expressions.  
In the pattern of operators ___[+*-/%=,:!<>()\133\135{}]___: \133 is the left square bracket and \135 is the right square bracket.  

### 4.7. BOOLEAN
The pattern of booleans takes place at line 10 in scanner.l.  
The pattern of boolean is ___"TRUE"\|"FALSE"___.  
- ___X \| Y___ means either an X or a Y.  

Either "TRUE" or "FALSE" would match this pattern.

### 4.8. Errors
The lexer could report basic syntax errors.  
1. A string or char starting with a quote but does not end with one.  
	e.g. "Hello or 'A.  
	In the source code, I gave the definition UNTERM_STRING and UNTERM_CHAR to them standing for unterminated_string and unterminated_char.  
	UNTERM_STRING and UNTERM_CHAR are simply the pattern of a normal string or char without the finishing quotes. (line 11 and line 13 in scanner.l) 
	Both actions of these matches are to call the function lex_error() which outputs an error line and the error character.
2. Unrecognized character  
   

## 5. Parser

## Reference
1. http://web.stanford.edu/class/archive/cs/cs143/cs143.1128/handouts/050%20Flex%20In%20A%20Nutshell.pdf flex Rules  
2. https://www3.nd.edu/~dthain/compilerbook/compilerbook.pdf Chapter3 Kinds of Tokens  
3. https://holub.com/goodies/compiler/compilerDesignInC.pdf  
4. https://www.cs.virginia.edu/~cr4bd/flex-manual/Patterns.html#Patterns
5. https://www.csdn.net/wakooong.io/silly_project/psudocodecompiler.html#Showing
6. https://www.cs.virginia.edu/~cr4bd/flex-manual/Matching.html#Matching
7. http://web.stanford.edu/class/archive/cs/cs143/cs143.1128/handouts/050%20Flex%20In%20A%20Nutshell.pdf A flex input file
8. https://www.cambridgeinternational.org/Images/639920-2021-pseudocode-guide-for-teachers.pdf
9. https://compilers.iecc.com/crenshaw/tutor7.txt PART 7 Lexical Scanning
10. http://web.stanford.edu/class/archive/cs/cs143/cs143.1128/handouts/050%20Flex%20In%20A%20Nutshell.pdf A flex input file
11. https://pandolia.net/tinyc/ch8_flex.html Chapter8 Lexical Analysis with flex
