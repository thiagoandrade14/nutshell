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
int removeAlias(char* name);
int setEnvVariable(char* variable, char* word);
int unsetEnvVariable(char* variable);
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD WORD ALIAS UNALIAS HOME SETENV UNSETENV PRINTENV END

%%
cmd_line    :
    BYE END					{exit(1); return 1; }
    | CD WORD END 			{runCD($2); return 1; }
	| CD HOME END			{cdHome(); return 1; }
	| CD END				{cdHome(); return 1; }
	| ALIAS WORD WORD END	{runSetAlias($2, $3); return 1; }
	| ALIAS END				{displayAlias(); return 1; }
	| UNALIAS WORD END 		{removeAlias($2); return 1;	}
	| SETENV WORD WORD END	{setEnvVariable($2, $3); return 1; }
	| UNSETENV WORD END		{unsetEnvVariable($2); return 1; }
	| PRINTENV END			{		}

%%
int yyerror(char *s) {
    printf("An error has occurred: %s\n", s);
    return 1;
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
	//checks for loop conditions. FIXME
	struct aTable* current = aliasHead;
	while (current != NULL) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(current->name, name) == 0) && (strcmp(current->word, word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(current->name, name) == 0) {
			strcpy(current->word, word);
			return 1;
		}
		current = current->next;
	}
	pushAlias (aliasHead, name, word);
	return 1;
}
void displayAlias(){
	struct aTable* current = aliasHead;
	while (current != NULL) {
		printf("%s=%s\n", current->name, current->word);
		current = current->next;
	}
}
int removeAlias(char* name) {
	if (aliasHead != NULL) {
		if (strcmp(aliasHead->name, name) == 0) {
			if (aliasHead->next != NULL) {
				struct aTable* temp = aliasHead;
				aliasHead = aliasHead->next;
				free(temp);
			}
			else {
				free(aliasHead);
				aliasHead = NULL;
			}
		}
		struct aTable* current = aliasHead;
		while (current != NULL && current->next != NULL) {
			if (strcmp(current->next->name, name) == 0) {
				struct aTable* temp = current->next->next;
				free(current->next);
				current->next = temp;
			}
			current = current->next;
		}
	}
}
int setEnvVariable(char* variable, char* word){
	if (strcmp(variable, varTable.var[0]) == 0) {
		strcpy(varTable.word[0], word); //PWD
		return 1;
	}
	else if (strcmp(variable, varTable.var[1]) == 0) {
		strcpy(varTable.word[1], word);//HOME
		return 1;
	}
	else if (strcmp(variable, varTable.var[2]) == 0) {
		strcpy(varTable.word[2], word);//PROMPT
		return 1;
	}
	else if (strcmp(variable, varTable.var[3]) == 0) {
		strcpy(varTable.word[3], word);//PATH
		return 1;
	}
	else {
		return 1; //no variable found
	}
}
//unset will restore to the default value of the variable.
int unsetEnvVariable(char* variable){
	if (strcmp(variable, varTable.var[0]) == 0) {
		strcpy(varTable.word[0], getcwd(cwd, sizeof(cwd)));//PWD
	}
	else if (strcmp(variable, varTable.var[1]) == 0) {
		strcpy(varTable.word[1], getcwd(cwd, sizeof(cwd)));//HOME. FIXME: home directory reassignment should not be to current directory.
	}
	else if (strcmp(variable, varTable.var[2]) == 0) {
		strcpy(varTable.word[2], "Nutshell DEV 0.15");//PROMPT
	}
	else if (strcmp(variable, varTable.var[3]) == 0) {
		strcpy(varTable.word[3], "/bin");//PATH
	}
	else {
		return 1;//no variable found
	}
}