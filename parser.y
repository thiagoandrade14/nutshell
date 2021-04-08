%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "nutshell.h"

int yylex(void);
int yyerror(char *s);
int runCD(char* arg);
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD STRING END

%%
cmd_line    :
    BYE END         {exit (1); return 1; }
    | CD STRING END {runCD($2); return 1; }

%%
int yyerror(char *s) {
    printf("%s\n", s);
    return 0;
}

int runCD(char* arg) {
    if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			return 1;
		}
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}

}