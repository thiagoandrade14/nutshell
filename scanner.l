%{
    #include "nutshell.h"
    #include <string.h>
    #include "parser.tab.h"
%}

%option noyywrap
%x string_condition
%x env_var_condition
%x unalias_condition


CHAR            [.A-Za-z0-9!\/_-][.:A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/_*~:= -][)(*&%$#@!`;,\.a-zA-Z0-9'/_*~= -]*
TILDE               ~
WHITESPACE          [ \t]+
METACHARACTER       [|\&]+
BUILTIN             alias|setenv|unsetenv|printenv

%%
<string_condition>{ANYCHAR}+    { yylval.string = strdup(yytext); return WORD;}
<string_condition>[\"]          {BEGIN(INITIAL);}
<env_var_condition>{ANYCHAR}+      { yylval.string = strdup(yytext); return ENV_VAR;}
<env_var_condition>[}]             {BEGIN(INITIAL);}
<unalias_condition>{CHAR}+      { yylval.string = strdup(yytext); return UNALIAS;}
<unalias_condition>[\n]             {BEGIN(INITIAL);}


bye                             { return BYE;   }
cd                              { return CD; }
{WHITESPACE}+                   { /*ignore whitespace*/  }
unalias                         { yylval.string = strdup(yytext);
                                BEGIN(unalias_condition);}
{BUILTIN}                       {yylval.string = strdup(yytext); 
                                return BUILTIN; }
"\n"                            {return END; }
[\"]                            { BEGIN(string_condition); }
"${"                            { BEGIN(env_var_condition); }
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
