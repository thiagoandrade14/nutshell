%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "nutshell.h"

int yylex(void);
void yyerror(char *s);
int cdHome(void);
int runCD(char* arg);
int runSetAlias(char* name, char* word);
void displayAlias();
int removeAlias(char* name);
int setEnvVariable(char* variable, char* word);
int unsetEnvVariable(char* variable);
void displayEnv();
int runCommand(char* command);
extern char** environ;
void builtins(char* built);
char builtinargs[3][128];
char builtinargz[10][128];
void add_arg(char* arg);
void add_argz(char* arg);
void test();
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD WORD HOME COMMAND END METACHARACTER BUILTIN

%%
cmd_line :
    CD WORD END         {runCD($2); return 1;}
    |   CD HOME END     {cdHome(); return 1;}
    |   CD END          {cdHome(); return 1;}
    |   BYE END         {exit(1); return 1;}
    |   END             {return 1;}
    |   line END        {return 1;}
    |   line METACHARACTER line {test(); return 1;}
    |   error END       {return 1;}
    ;
line :
    BUILTIN arg         {builtins($1);}
    |   WORD argz       {runCommand($1);}
    ;
arg :
    %empty
    |   WORD arg        {add_arg($1);}
    ; 
argz :
    %empty
    |   WORD argz        {add_argz($1);}
    ; 

%%
void yyerror(char *s) {
    printf("An error has occurred: %s\n", s);
    return;
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
        strcpy(varTable.word[2], "Nutshell DEV 0.4");
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
//FIXME: it only works with no arguments so far.
int runCommand(char* command) {
    char* args[] = { command, varTable.word[0], NULL};
    char* binaryAddress = (char*) malloc(128*sizeof(char));
    strcpy(binaryAddress, "/bin/");
    strcat(binaryAddress, command);
    pid_t pid = fork();
    if (pid == -1) {
        printf("\nFork failed.\n");
    }
    else if (pid == 0) {
        printf("Request for command %s received by child.\nTrying to process command...\n", command);
        if (execve(binaryAddress, args, environ) < 0) {
            printf("Error running %s\n", args[0]);
        }
        exit(0);
    }
    else {
        wait(NULL);
        printf("Returning to parent process.\n");
        return 1;
    }
    argzbin = 0;
}

void builtins(char* built)
{
    if((!strcmp(built, "alias")))
    {
        if(argbin == 0)
        {
            displayAlias();
        }
        else if(argbin == 2)
        {   
            runSetAlias(builtinargs[1], builtinargs[0]);
        }
        else //Error
        {
            
        }
    }
    else if(!strcmp(built, "unalias"))
    {
        if(argbin == 1)
        {
            removeAlias(builtinargs[0]);
        }
        else //Error
        {
            
        }
    }
    else if(!strcmp(built, "setenv"))
    {
        if(argbin == 2)
        {
            setEnvVariable(builtinargs[1], builtinargs[0]);
        }
        else //Error
        {
            
        }
    }
    else if(!strcmp(built, "unsetenv"))
    {
        if(argbin == 1)
        {
            unsetEnvVariable(builtinargs[0]);
        }
        else //Error
        {
            
        }
    }
    else if(!strcmp(built, "printenv"))
    {
        if(argbin == 0)
        {
            displayEnv();
        }
        else //Error
        {
            
        }
    }
    argbin = 0;
}

void add_arg(char* arg)
{
    strcpy(builtinargs[argbin], arg);
    argbin++;
}

void add_argz(char* arg)
{
    strcpy(builtinargz[argzbin], arg);
    argzbin++;
}

void test()
{
    
}
