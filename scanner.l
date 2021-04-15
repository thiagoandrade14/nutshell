%{
    #include "nutshell.h"
    #include <string.h>
    #include "parser.tab.h"
%}

%option noyywrap
%x string_condition env_var_condition string_env_var
%s alias_condition

CHAR            [.A-Za-z0-9!\/_-][.:A-Za-z0-9!\/_-]*
ANYCHAR            [)(}{*&%$#@!`;,\.a-zA-Z0-9'/_*~:= -][)(}{*&%$#@!`;,\.a-zA-Z0-9'/_*~= -]*
TILDE               ~
WHITESPACE          [ \t]+
METACHARACTER       [|\&]+
BUILTIN             setenv|unsetenv|printenv

%%
<string_condition>{ANYCHAR}+            { yylval.string = strdup(yytext); return WORD;}
<string_condition>[\"]                  {BEGIN(INITIAL);}
<env_var_condition>{CHAR}+              { yylval.string = varTable.word[findVar(strdup(yytext))]; return WORD;}
<string_env_var>{CHAR}+                 { yylval.string = varTable.word[findVar(strdup(yytext))]; return WORD;}
<env_var_condition>[}]                  {BEGIN(INITIAL);}
<string_env_var>[}]                     {BEGIN(string_condition);}
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
<string_condition>"${"          { yylval.string = strdup(yytext);
                                BEGIN(string_env_var);
                                return WORD; }
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
