%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "nutshell.h"

int yylex(void);
int yyerror(char *s);
int cdHome(void);
int runCD(char* arg);
int runSetAlias(char* name, char* word);
void displayAlias();
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD WORD ALIAS HOME END

%%
cmd_line    :
    BYE END					{exit (1); return 1; }
	| END					{exit(1); return 1; }
    | CD WORD END 			{runCD($2); return 1; }
	| CD HOME END			{cdHome(); return 1; }
	| CD END				{cdHome(); return 1; }
	| ALIAS WORD WORD END	{runSetAlias($2, $3); return 1; }
	| ALIAS END				{displayAlias(); return 1; }

%%
int yyerror(char *s) {
    printf("An error has occurred: %s\n", s);
	recover_from_errors();
    return 0;
}
//project specification: cd with no arguments brings to home directory.
int cdHome() {
	if (chdir(varTable.word[1]) == 0) {
		getcwd(cwd, sizeof(cwd));
		strcpy(varTable.word[0], cwd); //reset current directory
		return 1;
	}
	else {
		printf("Failure: home directory not found\n");
		return 1;
	}
}

int runCD(char* arg) {
    if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);
		if(chdir(varTable.word[0]) == 0) {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd); //reset current directory
			return 1;
		}
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found.\n");
			return 1;
		}
	}
	else { //arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found.\n");
                       	return 1;
		}
	}

}
int runSetAlias(char* name, char* word){
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;
	return 1;
}
void displayAlias(){
	for (int i = 0; i < aliasIndex; i++) {
		printf("alias %s=%s\n", aliasTable.name[i], aliasTable.word[i]);
	}
}