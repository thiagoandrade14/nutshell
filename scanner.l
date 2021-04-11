%{
    #include "nutshell.h"
    #include <string.h>
    #include "parser.tab.h"
%}

%option noyywrap
%x string_condition


CHAR            [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/_*= -][)(*&%$#@!`;,\.a-zA-Z0-9'/_*= -]*
TILDE               ~+
WHITESPACE          [ \t]+
METACHARACTER       [<>"|\&]+

%%
<string_condition>{ANYCHAR}+    { yylval.string = strdup(yytext); return WORD;}
<string_condition>[\"]          {BEGIN(INITIAL);}


bye             { return BYE;   }
cd              { return CD;    }
alias           { return ALIAS; }
unalias         { return UNALIAS; }
setenv          { return SETENV; }
unsetenv        { return UNSETENV; }
printenv        { return PRINTENV; }
"\n"            { return END;   }
[\"]            { BEGIN(string_condition); }
{TILDE}         { return HOME;  }
{CHAR}+         {
                    yylval.string = strdup(yytext);
                    return WORD; 
                }
{METACHARACTER} {       }
{WHITESPACE}+   {      }
%%