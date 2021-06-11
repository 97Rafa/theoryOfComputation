%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdarg.h>
    #include <string.h>
    #include "cgen.h"
    
    extern int yylex(void);
    extern int line_num;
%}

%union
{
    char* str;
    int num;
}
 
%define parse.trace
%debug

%define parse.error verbose

%token <str> IDENTIFIER
%token <str> POSINT 
%token <str> REAL 
%token <str> STRING

%token KW_BOOL
%token RD_STR
%token RD_INT
%token RD_REAL
%token WR_REAL
%token WR_STR
%token WR_INT
%token KW_TRUE
%token KW_FALSE
%token KW_REAL
%token KW_INT
%token KW_STRING
%token KW_BEGIN
%token KW_VAR
%token KW_CONST
%token KW_FOR
%token KW_CONTINUE
%token KW_WHILE
%token KW_IF
%token KW_ELSE
%token KW_RETURN
%token KW_LOGIC_NOT
%token KW_LOGIC_OR
%token KW_LOGIC_AND
%token KW_BREAK
%token KW_NIL
%token KW_FUNC
%token UMINUS
%token UPLUS
%token TAB_CH
%token RESET_LINE_CH
%token BACKSLASH_CH
%token QUOTE_CH
%token NEW_LINE
%token NOT_EQUAL_OP
%token SMALLER_OR_EQUAL_OP
%token GREATER_OR_EQUAL_OP
%token EQUAL
%token MOD
%token EXP

%start program

%left '-' '+'
%left '*' '/'
%left '%'
%left  KW_LOGIC_AND
%left  KW_LOGIC_OR
%right KW_LOGIC_NOT
%right UMINUS
%right UPLUS
%right EXP
%left  '='
%left '<'
%left '>'
%left NOT_EQUAL_OP
%left SMALLER_OR_EQUAL_OP EQUAL
%left GREATER_OR_EQUAL_OP


%type <str> mult_declar body declaration
%type <str> const_decl_syntax const_mult_declar const_declaration
%type <str> var_decl_syntax var_mult_declar var_declar_assign declar_id
%type <str> datatype functiontype variables
%type <str> operations procedure_call
%type <str> library_procedures
%type <str> read read_str read_number  read_real
%type <str> write write_str write_number write_real
%type <str> cmd_list cmd_separated
%type <str> main procedure_list procedure procedure_call_args
%type <str> definition_arguments definition_argument_token_list definition_argument_token
%type <str> assign


%%

program: mult_declar procedure_list main { 
/* We have a successful parse! 
  Check for any errors and generate output. */

	if (yyerror_count == 0) {
    // include the mslib.h file
	  puts(c_prologue); 
	  printf("/* program */  \n\n");
	  printf("%s\n", $1);
    printf("%s\n", $2);
    printf("%s\n", $3);
	}
}
;

main : %empty { $$ = " " ;}
| KW_FUNC KW_BEGIN '('  ')' '{' body '}'     { $$=template("int main() {\n \t%s\n} \n", $6);}
;

mult_declar: %empty { $$ = " " ;}
| mult_declar declaration { $$ = template("%s\n%s", $1, $2); }
;

declaration: KW_CONST const_decl_syntax { $$ = template("%s", $2); }
| KW_VAR var_decl_syntax   { $$ = template("%s",$2);}
;

/* VARIABLES */
var_decl_syntax: var_mult_declar datatype ';' {  $$ = template("%s %s;", $2, $1); }
;

var_mult_declar: var_mult_declar ',' var_declar_assign { $$ = template("%s, %s", $1, $3 );}
| var_declar_assign { $$ = $1;}
;

var_declar_assign: declar_id { $$ = $1; }
| declar_id '=' operations { $$ = template("%s=%s", $1, $3); }
; 

declar_id: IDENTIFIER { $$ = $1; } 
| IDENTIFIER '[' POSINT ']' { $$ = template("%s[%s]", $1, $3); }
| IDENTIFIER '[' IDENTIFIER ']' { $$ = template("%s[%s]", $1, $3); }
;

/*Constants*/
const_decl_syntax: const_mult_declar datatype ';' {  $$ = template("%s %s;", $2, $1); }


const_mult_declar: 
const_mult_declar ',' const_declaration { $$ = template("%s, %s", $1, $3); }
| const_declaration { $$ = template("%s", $1); }
;

const_declaration: 
declar_id '=' operations { $$ = template("%s =%s", $1, $3);}
;


/* Definition Arguments*/
definition_arguments : %empty {$$="";}
	 | definition_argument_token_list {$$=$1;}
;

definition_argument_token_list : definition_argument_token_list ',' definition_argument_token {$$=template("%s, %s",$1,$3);}
		    | definition_argument_token {$$=$1;}
;

definition_argument_token : IDENTIFIER datatype {$$= template("%s %s",$2,$1) ;}
;

/*Procedures*/
procedure_list: %empty { $$ = " " ;}
| procedure_list procedure { $$=template("%s\n%s\n", $1,$2);}
;

procedure : KW_FUNC IDENTIFIER '('definition_arguments ')' functiontype '{' body '}'    { $$=template("%s %s(%s) {%s\n}",$6,$2,$4,$8);}
;



datatype: KW_INT { $$ = "int"; }
| KW_STRING { $$ = "char*" ;}
| KW_REAL { $$ = "double"; }
| KW_BOOL { $$ = "int"; }
| '['']' datatype { $$ = template("%s*", $3);}
;

functiontype:  
 %empty { $$ = " ";}
| KW_REAL { $$ = "double"; }
| KW_INT 		{ $$ = "int"; }
| KW_STRING 	{ $$ = "char*"; }
| KW_BOOL 		{ $$ = "int"; } 
| '['']' KW_BOOL    { $$ = "int*"; }
| '['']' KW_INT 		{ $$ = "int*"; }
| '['']' KW_STRING 		{ $$ = "char*"; }
; 


body: %empty { $$="";}
    | cmd_list{ $$ = $1; }
;

cmd_list : %empty { $$="";}
	 | cmd_separated cmd_list { $$ = template("%s\n%s",$1,$2); }
;

cmd_separated :  ';' { $$ = template(";"); }
           | library_procedures ';' { $$ = template("%s;", $1);}
           | declaration { $$ = $1;}
           | assign ';'   { $$ = template("%s;", $1); }
           | KW_IF '(' operations ')' '{' body '}'  { $$ = template("if (%s) {\n %s \n}",$3,$6); }
	         | KW_IF '(' operations ')' '{' body '}' KW_ELSE '{' body '}'  { $$ = template("if (%s) {\n %s \n}\n else {\n%s\n}",$3,$6, $10); }
           | KW_IF '(' operations ')' '{' body '}' KW_ELSE cmd_separated  { $$ = template("if (%s) {\n %s \n}\n else %s",$3,$6, $9); }
	         | KW_FOR '(' assign ';' operations ';' assign ')' '{' body '}' { $$ = template("for(%s; %s; %s){\n%s \n}\n", $3, $5, $7, $10);}
           | KW_WHILE '(' operations ')' '{' body '}'  	{ $$ = template("while(%s){\n%s \n}\n", $3, $6); }
           | KW_BREAK ';'{ $$ = template("\nbreak;"); }
           | KW_CONTINUE ';'{ $$ = template("\ncontinue;"); }
           | KW_RETURN ';' {$$ = template("\nreturn;");}
           | KW_RETURN operations ';' {$$ = template("\nreturn %s;",$2);}
           | procedure_call ';' { $$ = template("%s", $1);}
;

assign: IDENTIFIER '=' operations  {$$ = template("%s = %s",$1,$3);}
| IDENTIFIER '['POSINT']' '=' operations  {$$ = template("%s[%s] = %s",$1,$3,$6);}
| IDENTIFIER '['IDENTIFIER']' '=' operations  {$$ = template("%s[%s] = %s",$1,$3,$6);}
| IDENTIFIER '=' procedure_call  {$$ = template("%s = %s",$1,$3);}
| IDENTIFIER '['POSINT']' '=' procedure_call  {$$ = template("%s[%s] = %s",$1,$3,$6);}
| IDENTIFIER '['IDENTIFIER']' '=' procedure_call  {$$ = template("%s[%s] = %s",$1,$3,$6);}
;

/*Call Procedure*/
procedure_call: IDENTIFIER '=' IDENTIFIER '(' procedure_call_args ')' {$$ = template( "%s = %s(%s);",$1, $3, $5);}
| IDENTIFIER '(' procedure_call_args ')' {$$ = template( "%s(%s)",$1, $3);}
;

procedure_call_args: procedure_call_args ',' operations { $$ = template("%s, %s", $1, $3); }
| operations { $$ = $1; }
;

variables: KW_LOGIC_NOT operations %prec KW_LOGIC_NOT            {$$=template( "!(%s)", $2);}
| POSINT      { $$ = $1; }
| IDENTIFIER '['POSINT']' { $$ = template("%s[%s]", $1,$3);}
| IDENTIFIER '['IDENTIFIER']' { $$ = template("%s[%s]", $1,$3);}
| REAL        { $$ = $1; }
| KW_NIL      { $$ = template("null"); }
| STRING      {$$ = $1; }
| IDENTIFIER  { $$ = $1; }
| KW_TRUE {$$ = template("true");}
| KW_FALSE  {$$ = template("false");}
 ;


operations: variables { $$ = $1; }
| '+' operations %prec UMINUS          {$$=template( "-(%s)", $2);}
| '-' operations %prec UPLUS            {$$=template( "+(%s)", $2);}
| operations KW_LOGIC_AND operations   { $$ = template("%s && %s", $1, $3); }
| operations KW_LOGIC_OR operations    { $$ = template("%s || %s", $1, $3);  }
| '(' operations ')' { $$ = template("(%s)", $2); }
| operations '+' operations { $$ = template("%s + %s", $1, $3); }
| operations '-' operations { $$ = template("%s - %s", $1, $3); }
| operations '*' operations { $$ = template("%s * %s", $1, $3); }
| operations '/' operations { $$ = template("%s / %s", $1, $3); }
/* | operations MOD operations { $$ = template("%s mod %s", $1, $3); } */
| operations EXP operations { $$ = template("%s ^ %s", $1, $3); }
| operations '<' operations { $$ = template("%s < %s", $1, $3); } 
| operations '>' operations { $$ = template("%s > %s", $1, $3); }
| operations EQUAL operations { $$ = template("%s == %s", $1, $3); } 
| operations NOT_EQUAL_OP operations { $$ = template("%s != %s", $1, $3); } 
| operations SMALLER_OR_EQUAL_OP operations { $$ = template("%s <= %s", $1, $3); } 
| operations GREATER_OR_EQUAL_OP operations { $$ = template("%s >= %s", $1, $3); } 
| procedure_call {$$ = $1;}
;


/*Default procedures*/

library_procedures : read  {$$= $1;}
  | write            {$$= $1;}
;

read : read_str 	{$$= $1;}
     | read_number   	{$$= $1;}
     | read_real   	{$$= $1;}  
;

write : write_str {$$= $1;}
  | write_number    {$$ = $1;}
  | write_real    {$$ = $1;}
;

read_str : IDENTIFIER '=' RD_STR '(' ')' {$$ = template( "%s = readString()",$1);}
| IDENTIFIER '['POSINT']'  '=' RD_STR '(' ')' {$$ = template( "%s[%s] = readString()",$1, $3);}
| IDENTIFIER '['IDENTIFIER']' '=' RD_STR '(' ')' {$$ = template( "%s[%s] = readString()",$1, $3);}

;

read_number : IDENTIFIER '=' RD_INT '(' ')' {$$ = template( "%s = readInt()", $1);}
| IDENTIFIER '['POSINT']' '=' RD_INT '(' ')' {$$ = template( "%s[%s] = readInt()", $1, $3);}
| IDENTIFIER '['IDENTIFIER']' '=' RD_INT '(' ')' {$$ = template( "%s[%s] = readInt()", $1, $3);}
;

read_real : IDENTIFIER '=' RD_REAL '(' ')' {$$ = template( "%s = readReal()", $1);}
| IDENTIFIER '['POSINT']' '=' RD_REAL '(' ')' {$$ = template( "%s[%s] = readReal()", $1,$3);}
| IDENTIFIER '['IDENTIFIER']' '=' RD_REAL '(' ')' {$$ = template( "%s[%s] = readReal()", $1,$3);}
;


write_str : WR_STR '(' operations ')'	  {  $$ = template( "writeString(%s)",$3); }
/* | WR_STR '(' IDENTIFIER '['IDENTIFIER']' ')'	  {  $$ = template( "writeString(%s[%s])",$3,$5); }
| WR_STR '(' IDENTIFIER '['POSINT']' ')'	  {  $$ = template( "writeString(%s[%s])",$3,$5); }
| WR_STR '(' STRING ')'	  {  $$ = template( "writeString(%s)", $3); } */
;

write_number : WR_INT '(' operations ')'      {  $$ = template( "writeInt(%s)",$3); }
/* | WR_INT '(' IDENTIFIER '['IDENTIFIER']' ')'      {  $$ = template( "writeInt(%s[%s])",$3,$5); }
| WR_INT '(' IDENTIFIER '['POSINT']' ')'      {  $$ = template( "writeInt(%s[%s])",$3,$5); } */
;

write_real : WR_REAL '(' operations  ')'      {  $$ = template( "writeReal(%s)",$3); }
/* | WR_REAL '(' IDENTIFIER '['IDENTIFIER']' ')'      {  $$ = template( "writeReal(%s[%s])",$3,$5); }
| WR_REAL '(' IDENTIFIER '['POSINT']' ')'      {  $$ = template( "writeReal(%s[%s])",$3,$5); } */
;


%%


int main () {
  if ( yyparse() == 0 )
    printf("/*Accepted!*/\n");
  else
    printf("/*Rejected!*/\n");
}
