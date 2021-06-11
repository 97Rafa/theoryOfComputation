%{
    #include <assert.h>
    #include <stdio.h>
    #include <string.h>
    #include "Pi_parser.tab.h"
    #include "cgen.h"

    int line_num = 1;

    // #define DEBUG 1
    // #ifdef DEBUG
    // #define DEBUG_PRINT(fmt, args...)    fprintf(stderr, fmt, ## args)
    // #else
    // #define DEBUG_PRINT(fmt, args...)    /* Don't do anything in release builds */
    // #endif
%}


/* Variables patterns*/
ID      [a-zA-Z_][0-9a-zA-Z_]*
DIGIT   [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ([+-]?"."{NUMBER})|([+-]?{NUMBER}("."{NUMBER}?)?)
REAL    {DECIMAL}([eE][+-]?{NUMBER})?
STRING  \"[^'\n]*\"

%x comment


%%


bool          {return KW_BOOL;}   /* Keywords*/
readString    {return RD_STR;}
readInt       {return RD_INT;}
readReal      {return RD_REAL;}
writeReal     {return WR_REAL;}
writeString   {return WR_STR;}
writeInt      {return WR_INT;}
true          {return KW_TRUE;}
false         {return KW_FALSE;}
real          {return KW_REAL ;}
int           {return KW_INT;}
string        {return KW_STRING;}
begin         {return KW_BEGIN;}
var           {return KW_VAR;}
const         {return KW_CONST;}
for           {return KW_FOR;}
continue      {return KW_CONTINUE;}
while         {return KW_WHILE;}
if            {return KW_IF;}
else          {return KW_ELSE;}
return        {return KW_RETURN;}
not           {return KW_LOGIC_NOT;}
or            {return KW_LOGIC_OR;}
and           {return KW_LOGIC_AND;}
break         {return KW_BREAK;}
nil           {return KW_NIL;}
func          {return KW_FUNC;}


"-"/{REAL}      {return UMINUS;}        /* Signs*/
"+"/{REAL}      {return UPLUS;}


{STRING}    {yylval.str=strdup(yytext); /* Constants*/
             return STRING;}
{ID}        {yylval.str=strdup(yytext);
              return IDENTIFIER;}
{NUMBER}    {yylval.str=strdup(yytext);
              return POSINT ;}
{REAL}      {yylval.str=strdup(yytext);
              return REAL;}

\n     {line_num++;
        }                  /* Escape characters*/
\t     {return TAB_CH;}
\r     {return RESET_LINE_CH;}
\\     {return BACKSLASH_CH;}
\"     {return QUOTE_CH;}



"="         {return '=';}                   /* Operators*/
"!="        {return NOT_EQUAL_OP;}
"<="        {return SMALLER_OR_EQUAL_OP;}
">="        {return GREATER_OR_EQUAL_OP;}
"<"         {return '<';}
"=="        {return EQUAL;}
">"         {return '>';}
"+"         {return '+';}
"-"         {return '-';}
"*"         {return '*';}
"**"        {return EXP;}
"/"         {return '/';}
"%"         {return MOD;}


";"       {return ';';}                  /* Delimiters*/
"("       {return '(';}
")"       {return ')';}
","       {return ',';}
"["       {return '[';}
"]"       {return ']';}
"{"       {return '{';}
"}"       {return '}';}



[ \r\t]


"//"[^\n]*  	/* eat line comments */


"/*"                    BEGIN(comment);

<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
<comment>\n             line_num++;
<comment>"*"+"/"        BEGIN(INITIAL); 

<<EOF>> 	return EOF;
.               { yyerror("lexical error: unrecognized literal '%s'\n", yytext); }


%%

