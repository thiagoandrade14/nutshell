%{
    #include "nutshell.h"
    #include <string.h>
    #include "parser.tab.h"
%}

%option noyywrap
%x string_condition


CHAR            [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/_*=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/_*=~ -]*

%%
<string_condition>{ANYCHAR}+    { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);}


bye             { return BYE;   }
cd              { return CD;    }
"\n"            { return END;   }
[\"]                 { BEGIN(string_condition); }
{CHAR}+   { printf("yytext: %s\n", yytext);
            yylval.string = strdup(yytext);
            return STRING; }

%%