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
int runCommands(char* command, char* command2);
int runCommandin(char* command, char* file);
extern char** environ;
void builtins(char* built);
char builtinargs[3][128];
char* builtinargz[10];
char* builtinargzz[10];
void add_arg(char* arg);
void add_argz(char* arg);
void reverse(char** argz, int size);
char** parsePATH();
void add_argzz(char* arg);
int writecommand(char* command);
int writecommand_e(char* command);
int writecommand_error(char* command, char* file);
%}

%union {char *string;}
%start cmd_line
%token <string> BYE CD WORD HOME END METACHARACTER BUILTIN MET_GT MET_OR MET_LT MET_GT_GT TWO_GT_AND_ONE TWO_GT

%%
cmd_line :
    CD WORD END         {runCD($2); return 1;}
    |   CD HOME END     {cdHome(); return 1;}
    |   CD END          {cdHome(); return 1;}
    |   BYE END         {exit(1); return 1;}
    |   END             {return 1;}
    |   line END        {printf("line\n"); return 1;}
    |   line MET_GT WORD END {printf("gt\n"); writecommand($3); return 1;} 
    |   line MET_GT_GT WORD END {writecommand_e($3); return 1;}
    |   error END       {return 1;}
    ;
line :
    BUILTIN arg         {builtins($1);}
    |   WORD argz       {add_argz($1); runCommand($1);}
    |   line_MET
    ;
arg :
    %empty
    |   WORD arg        {add_arg($1);}
    ; 
argz :
    %empty
    |   WORD argz        {add_argz($1);}
    ; 
argzz :
    %empty
    |   WORD argzz      {add_argzz($1);}
line_MET :
    WORD argz TWO_GT WORD { add_argz($1); writecommand_error($1, $4);}
//    |   WORD argz MET_GT WORD TWO_GT_AND_ONE { add_argz($1); writecommand_error($1, $4);} //Functions, but gives shift/reduce conflict
    |   WORD argz MET_OR WORD argzz   {add_argz($1); add_argzz($4); runCommands($1, $4);}
    |   WORD argz MET_LT WORD   {add_argz($1); runCommandin($1, $4);}
    ;
%%
void yyerror(char *s) {
    char iter[256];
    sprintf(iter, "An error has occurred: %s\n", s);
    strcat(buff, iter);
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
        char iter[256];
		sprintf(iter, "Failure: home directory not found\n");
        strcat(buff, iter);
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
            char iter[256];
			sprintf(iter, "Directory not found.\n");
            strcat(buff, iter);
			return 1;
		}
	}
	else { //arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
            char iter[256];
			sprintf(iter, "Directory not found.\n");
            strcat(buff, iter);
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
        char iter[512];
		sprintf(iter, "%s=%s\n", current->name, current->word);
        strcat(buff, iter);
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
        char iter[256];
        sprintf(iter, "Environemental variables full. \n");
        strcat(buff, iter);
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
        strcpy(varTable.word[2], "Nutshell DEV 0.5");
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
            char iter[256];
            sprintf(iter, "Could not locate environemental variable.\n");
            strcat(buff, iter);
            return 1;
        }
    }
}

void displayEnv()
{
    for(unsigned int i = 0; i < varIndex; i++)
    {
        char iter[256];
        sprintf(iter, "%s=%s\n", varTable.var[i], varTable.word[i]);
        strcat(buff, iter);
    }
}
int runCommand(char* command) {
        int pipefd[2];
        pipe(pipefd);

        reverse(builtinargz, argzbin);
        char* binaryAddress = (char*) malloc(128*sizeof(char));
        pid_t pid = fork();
        if (pid == -1) {
            printf("\nFork failed.\n");
        }
        else if (pid == 0) { //child process
            char** current = parsePATH();       //parse PATH variable into an array of strings.
            close(pipefd[0]);
            dup2(pipefd[1], 1);
            //dup2(pipefd[1], 2);
            close(pipefd[1]);
            //builds the entire path of the executable, trying the
            //directories found in the PATH variable
            for (int i = 0; current[i] != NULL; i++) {
                strcpy(binaryAddress, current[i]);
                strcat(binaryAddress, "/");
                strcat(binaryAddress, builtinargz[0]);
                if (access(binaryAddress, F_OK) == 0) { //checks if the executable was found, then breaks the loop
                    break;
                }
            }
            if (execve(binaryAddress, builtinargz, environ) < 0) {
                if (execve(binaryAddress, builtinargz, environ) < 0) {
                    printf("Error running %s.\n Program not found.\n", builtinargz[0]);
                }
                exit(0);
            }
            argzbin = 0;
            return 1;
        }
        else { //parent process
            wait(NULL);
            for (int i = 0; builtinargz[i] != NULL; i++) {
                free(builtinargz[i]);
                builtinargz[i] = NULL;
            }
            close(pipefd[1]);
            while(read(pipefd[0], buff, sizeof(buff)) != 0);
            argzbin = 0;
            return 1;
        }
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
void reverse(char** argz, int size) {
    char* temp;
    int j = size - 1;
    for (int i = 0; i < j; i++) {
        temp = argz[i];
        argz[i] = argz[j];
        argz[j] = temp;
        j--;
    }
}
void add_argz(char* arg)
{
    builtinargz[argzbin] = (char*) malloc(32*(sizeof(char)));
    strcpy(builtinargz[argzbin], arg);
    argzbin++;
}

char** parsePATH() {
    char* newPATH = varTable.word[3];
    int i;
    int length = strlen(newPATH);
    char delimiter = ':';
    int delimiterCount = 0;
    int currentDelimiter = 0;
    for (i = 0; i < length; i++) {
        if (newPATH[i] == delimiter) {
            delimiterCount++;
            newPATH[i] = '\0';
        }
    }
    char** pathArray = malloc((delimiterCount+1)*32*sizeof(char));
    pathArray[0] = newPATH;
    for (i = 0; i < length; i++) {
        if (newPATH[i] == '\0') {
            currentDelimiter++;
            pathArray[currentDelimiter] = newPATH + i + 1;
            if (pathArray[currentDelimiter][0] == '\0') {
                pathArray[currentDelimiter] = ".";
            }
        }
    }
    return pathArray;
}

void add_argzz(char* arg)
{
    builtinargzz[argzzbin] = (char*) malloc(32*(sizeof(char)));
    strcpy(builtinargzz[argzzbin], arg);
    argzzbin++;
}

int runCommands(char* command, char* command2) 
{
    int pipefd[2];
    pipe(pipefd);
    int pipefk[2];
    pipe(pipefk);

    reverse(builtinargz, argzbin);
    reverse(builtinargzz, argzzbin);
    char* binaryAddress = (char*) malloc(128*sizeof(char));
    pid_t pid = fork();
    if (pid == -1) {
        printf("\nFork failed.\n");
    }
    else if (pid == 0) { //child process
        char** current = parsePATH();       //parse PATH variable into an array of strings.
        dup2(pipefd[1], STDOUT_FILENO);
        close(pipefd[0]);
        close(pipefk[0]);
        close(pipefk[1]);
        //builds the entire path of the executable, trying the
        //directories found in the PATH variable
        for (int i = 0; current[i] != NULL; i++) {
            strcpy(binaryAddress, current[i]);
            strcat(binaryAddress, "/");
            strcat(binaryAddress, builtinargz[0]);
            if (access(binaryAddress, F_OK) == 0) { //checks if the executable was found, then breaks the loop
                break;
            }
        }
        if (execve(binaryAddress, builtinargz, environ) < 0) {
            if (execve(binaryAddress, builtinargz, environ) < 0) {
                printf("Error running %s.\n Program not found.\n", builtinargz[0]);
            }
            exit(0);
        }
        argzbin = 0;
        argzzbin = 0;
        return 1;
    }
    else { //parent process

        pid_t pid2 = fork();
        if(pid2 == -1)
        {
            printf("Fork failed\n");
        }
        if(pid2 == 0)
        {
            char** current = parsePATH();       //parse PATH variable into an array of strings.

            dup2(pipefd[0], STDIN_FILENO);
            dup2(pipefk[1], STDOUT_FILENO);
            close(pipefd[1]);
            close(pipefk[0]);

            //builds the entire path of the executable, trying the
            //directories found in the PATH variable
            for (int i = 0; current[i] != NULL; i++) {
                strcpy(binaryAddress, current[i]);
                strcat(binaryAddress, "/");
                strcat(binaryAddress, builtinargzz[0]);
                if (access(binaryAddress, F_OK) == 0) { //checks if the executable was found, then breaks the loop
                    break;
                }
            }
            if (execve(binaryAddress, builtinargzz, environ) < 0) {
                if (execve(binaryAddress, builtinargzz, environ) < 0) {
                    printf("Error running %s.\n Program not found.\n", builtinargzz[0]);
                }
                exit(0);
            }
            argzbin = 0;
            argzzbin = 0;
            return 1;
        }
        else
        {
            wait(NULL);
            close(pipefk[1]);
            close(pipefd[1]);
            close(pipefd[0]);
            while(read(pipefk[0], buff, sizeof(buff)) != 0);
            close(pipefk[0]);
            argzbin = 0;
            argzzbin = 0;
            return 1;
        }
    }
}

int writecommand(char* command)
{
    argzbin = 0;
    //printf("not-executable\n");
    //Write buffer to file
    FILE *fp;
    fp = fopen(command, "w");
    if(fputs(buff, fp) >= 0)
    {
        //success!
    }
    else
    {
        //failure
    }
    clearbuff();
    fclose(fp);
}

int writecommand_e(char* command)
{
    argzbin = 0;
    //printf("not-executable\n");
    //Write buffer to file
    FILE *fp;
    fp = fopen(command, "a+");
    if(fputs(buff, fp) >= 0)
    {
        //success!
    }
    else
    {
        //failure
    }
    clearbuff();
    fclose(fp);
}

int runCommandin(char* command, char* file)
{
    int pipefd[2];
    pipe(pipefd);
    reverse(builtinargz, argzbin);
    char* binaryAddress = (char*) malloc(128*sizeof(char));
    pid_t pid = fork();
    if(pid == -1)
    {
        printf("\nFork failed.\n");
    }
    else if(pid == 0) //child process
    {
        char** current = parsePATH();
        FILE *fp;
        fp = fopen(file, "a+");
        dup2(fileno(fp), STDIN_FILENO);
        dup2(pipefd[1], STDOUT_FILENO);
        close(pipefd[0]);
        for (int i = 0; current[i] != NULL; i++) {
            strcpy(binaryAddress, current[i]);
            strcat(binaryAddress, "/");
            strcat(binaryAddress, builtinargz[0]);
            if (access(binaryAddress, F_OK) == 0) { //checks if the executable was found, then breaks the loop
                break;
            }
        }
        if (execve(binaryAddress, builtinargz, environ) < 0) {
            if (execve(binaryAddress, builtinargz, environ) < 0) {
                printf("Error running %s.\n Program not found.\n", builtinargz[0]);
            }
            exit(0);
        }
        argzbin = 0;
        return 1;
    }
    else //parent process
    {
        wait(NULL);
        close(pipefd[1]);
        while(read(pipefd[0], buff, sizeof(buff)) != 0);
        close(pipefd[0]);
        argzbin = 0;
        return 1;
    }
}

int writecommand_error(char* command, char* file)
{
    int pipefd[2];
    pipe(pipefd);
    reverse(builtinargz, argzbin);
    char* binaryAddress = (char*) malloc(128*sizeof(char));
    pid_t pid = fork();
    if(pid == -1)
    {
        printf("\nFork failed\n");
    }
    else if(pid == 0)
    {
        char** current = parsePATH();
        close(pipefd[0]);
        dup2(pipefd[1], STDERR_FILENO);
        close(pipefd[1]);
        for (int i = 0; current[i] != NULL; i++) {
            strcpy(binaryAddress, current[i]);
            strcat(binaryAddress, "/");
            strcat(binaryAddress, builtinargz[0]);
            if (access(binaryAddress, F_OK) == 0) { //checks if the executable was found, then breaks the loop
                break;
            }
        }
        if (execve(binaryAddress, builtinargz, environ) < 0) {
            if (execve(binaryAddress, builtinargz, environ) < 0) {
                printf("Error running %s.\n Program not found.\n", builtinargz[0]);
            }
            exit(0);
        }
        argzbin = 0;
        return 1;
    }
    else
    {
        wait(NULL);
        close(pipefd[1]);
        while(read(pipefd[0], buff, sizeof(buff)) != 0);
        FILE *fp;
        fp = fopen(file, "w");
        if(fputs(buff, fp) >= 0)
        {
            //success!
        }
        else
        {
            //failure
        }
        clearbuff();
        fclose(fp);
        argzbin = 0;
        return 1;
    }
}
