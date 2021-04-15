%{
    #include "nutshell.h"
    #include <string.h>
    #include "parser.tab.h"
%}

%option noyywrap
%x string_condition env_var_condition
%s alias_condition

CHAR            [.A-Za-z0-9!\/_-][.:A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/_*~:= -][)(*&%$#@!`;,\.a-zA-Z0-9'/_*~= -]*
TILDE               ~
WHITESPACE          [ \t]+
METACHARACTER       [|\&]+
BUILTIN             setenv|unsetenv|printenv

%%
<string_condition>{ANYCHAR}+            { yylval.string = strdup(yytext); return WORD;}
<string_condition>[\"]                  {BEGIN(INITIAL);}
<env_var_condition>{ANYCHAR}+           { yylval.string = strdup(yytext); return ENV_VAR;}
<env_var_condition>[}]                  {BEGIN(INITIAL);}
<alias_condition>"\n"                   {BEGIN(INITIAL); return END;}

bye                             { return BYE; }
cd                              { return CD; }
{WHITESPACE}+                   { /*ignore whitespace*/  }
alias                           {BEGIN(alias_condition); 
                                yylval.string = strdup(yytext);
                                return BUILTIN;}
unalias                         { yylval.string = strdup(yytext);
                                BEGIN(alias_condition);
                                return BUILTIN;}
{BUILTIN}                       {yylval.string = strdup(yytext); 
                                return BUILTIN; }
"\n"                            {return END; }
[\"]                            { BEGIN(string_condition); }
"${"                            { BEGIN(env_var_condition); }
{TILDE}                         { yylval.string = varTable.word[1];
                                return HOME;  }
<alias_condition>{CHAR}+        {yylval.string = strdup(yytext); //prevents alias substitution if calling alias or unalias
                                return WORD; }
{CHAR}+                         { if(isAlias(yytext)) {
                                    char *yycopy = strdup( subAlias(yytext) );
                                    for (int i = strlen(subAlias(yytext)) - 1; i >= 0; --i) {
                                        unput( yycopy[i] );
                                    }
                                    free(yycopy);
                                    BEGIN(alias_condition); //prevents further substitutions in the line.
                                } 
                                else {
                                    yylval.string = strdup(yytext);
                                    return WORD; }  }
                                    
"2>&1"                          { return TWO_GT_AND_ONE; }
"2>"                            { return TWO_GT; }
">>"                            { return MET_GT_GT; }
">"                             { return MET_GT; }
"<"                             { return MET_LT; }
"|"                             { return MET_OR; }
{METACHARACTER}                 { return METACHARACTER; }
%%
