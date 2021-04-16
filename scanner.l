%{
    #include "nutshell.h"
    #include <string.h>
    #include "parser.tab.h"
%}

%option noyywrap
%x string_condition env_var_condition
%s alias_condition

CHAR               [.?*A-Za-z0-9!\/_-][.:A-Za-z0-9!\/_-]*
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
{TILDE}{CHAR}+                  {   
                                    char* iter;
                                    iter = strdup(yytext);
                                    iter++;

                                    struct passwd *pwd = calloc(1, sizeof(struct passwd));
                                    size_t buffer_len = sysconf(_SC_GETPW_R_SIZE_MAX) * sizeof(char);
                                    char *buffer = malloc(buffer_len);
                                    getpwnam_r(iter, pwd, buffer, buffer_len, &pwd);
                                    if(pwd != NULL)
                                    {
                                        yylval.string = pwd->pw_dir;
                                    }
                                    else
                                    {
                                        printf("User not found.\n");
                                        yylval.string = varTable.word[0];
                                    }

                                    return WORD;
                                }
{TILDE}                         { yylval.string = varTable.word[1];
                                return HOME;  }
<alias_condition>{CHAR}+        {yylval.string = strdup(yytext);
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

"&"                             { return AND; }                                   
"2>&1"                            { return TWO_GT_AND_ONE; }
"2>"                            { return TWO_GT; }
">>"                            { return MET_GT_GT; }
">"                             { return MET_GT; }
"<"                             { return MET_LT; }
"|"                             { return MET_OR; }
{METACHARACTER}                 { return METACHARACTER; }
.                               { return BAD; }
%%
