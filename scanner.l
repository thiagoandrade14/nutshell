%{
    #include "nutshell.h"
    #include <string.h>
    #include "parser.tab.h"
//FIXME: Accept linked list instead of array.
char* subAliases(char* name) {
    struct aTable* current = aliasHead;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current->word;
        }
        current = current->next;
    }
    return name;
}
//FIXME: Accept linked list instead of array.
bool ifAlias(char* name){
    struct aTable* current = aliasHead;
    while (current != NULL) {
        if(strcmp(current->name, name) == 0) {
            return true;
        }
        current = current->next;
    }
    return false;
}
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
{CHAR}+         {   if(ifAlias(yytext)) {
                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                        char *yycopy = strdup(subAliases(yytext) );
                        for (int i = strlen(subAliases(yytext)) - 1; i >= 0; --i ) {
                            unput( yycopy[i] );
                        }
                        free( yycopy );
                    }
                    else {
                        yylval.string = strdup(yytext);
                        return WORD; 
                    }
                }
{METACHARACTER} {       }
{WHITESPACE}+   {      }
%%