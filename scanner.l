%{
    #include "nutshell.h"
    #include <string.h>
    #include "parser.tab.h"
%}

%option noyywrap
%x string_condition
%x path_condition


CHAR            [.A-Za-z0-9!\/_-][.:A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/_*~:= -][)(*&%$#@!`;,\.a-zA-Z0-9'/_*~= -]*
TILDE               ~
WHITESPACE          [ \t]+
METACHARACTER       [|\&]+
/*COMMAND             ls|pwd|date|rm|ssh|ping|cat|mkdir|rmdir|wc|grep|echo*/
BUILTIN             alias|unalias|setenv|unsetenv|printenv

%%
<string_condition>{ANYCHAR}+    { yylval.string = strdup(yytext); return WORD;}
<string_condition>[\"]          {BEGIN(INITIAL);}
<path_condition>{ANYCHAR}+      { yylval.string = strdup(yytext); return ENV_VAR;}
<path_condition>[}]             {BEGIN(INITIAL);}


bye                             { return BYE;   }
cd                              { return CD; }
{BUILTIN}                       {yylval.string = strdup(yytext); 
                                return BUILTIN; }
"\n"                            {return END; }
{WHITESPACE}+                   { /*ignore whitespace*/  }
[\"]                            { BEGIN(string_condition); }
"${"                            { BEGIN(path_condition); }
{TILDE}                         { yylval.string = varTable.word[1];
                                return HOME;  }

{CHAR}+                         { if(isAlias(yytext)) {
                                    char *yycopy = strdup( subAlias(yytext) );
                                    for ( int i = strlen(subAlias(yytext)) - 1; i >= 0; --i )
                                        unput( yycopy[i] );
                                    free( yycopy );
                                } else {
                                yylval.string = strdup(yytext);
                                return WORD; }
                                }
">"                             { return MET_GT; }
{METACHARACTER}                 { return METACHARACTER; }
%%
