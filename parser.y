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
void displayEnv();
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
	| PRINTENV END			{ displayEnv(); return 1; }

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
	while (isAlias(arg)) {
		arg = subAlias(arg);
	}
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
int runSetAlias(char* name, char* word) {
	pushAlias (name, word);
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
int setEnvVariable(char* variable, char* word)
{
	for(unsigned int i = 0; i < varIndex; i++)
    {
        if(!strcmp(varTable.var[i], variable))
        {
            strcpy(varTable.word[i], word);
            return 1;
        }
    }
    if(varIndex < 128)
    {
        strcpy(varTable.var[varIndex], variable);
        strcpy(varTable.word[varIndex], word);
        varIndex++;
        return 1;
    }
    else
    {
        printf("Environemental variables full. \n");
        return 1;
    }
}
//unset will restore to the default value of the variable.
int unsetEnvVariable(char* variable)
{
	if(!strcmp("HOME", variable))
    {
        char* homev = getenv("HOME");
    	strcpy(varTable.word[1], homev);
    }
    else if(!strcmp("USER", variable))
    {
        char* username = getenv("USER");
        strcpy(varTable.word[4], username);
    }
    else if(!strcmp("PATH", variable))
    {
        char* pathv = getenv("PATH");
	    strcpy(varTable.word[3], pathv);
    }
    else if(!strcmp("PWD", variable))
    {
        getcwd(cwd, sizeof(cwd));
	    strcpy(varTable.word[0], cwd);
    }
    else if(!strcmp("PROMPT", variable))
    {
        strcpy(varTable.word[2], "Nutshell DEV 0.3");
    }
    else
    {
        int found = 0;
        for(unsigned int i = 0; i < varIndex; i++)
        {
            if(!found)
            {
                if(!strcmp(variable, varTable.var[i]))
                {
                    found = 1;
                    strcpy(varTable.var[i], "");
                    strcpy(varTable.word[i], "");
                }
            }
            if(found)
            {
                strcpy(varTable.var[i], varTable.var[i+1]);
                strcpy(varTable.word[i], varTable.word[i+1]);
                strcpy(varTable.var[i+1], "");
                strcpy(varTable.word[i+1], "");
            }
        }
        if(found)
        {
            varIndex--;
            return 1;
        }
        else
        {
            printf("Could not locate environemental variable.\n");
            return 1;
        }
    }
}

void displayEnv()
{
    for(unsigned int i = 0; i < varIndex; i++)
    {
        printf("%s=%s\n", varTable.var[i], varTable.word[i]);
    }
}
