#include "nutshell.h"


int yyparse();
//                                                                                           Shell Init - Initializes the shell
/*
*   init all variables
*   define (allocate storage) for some var/tables
*   init all tables (e.g., alias table, command table)
*   get PATH env variable (getenv())
*   get HOME env variable (getenv())
*   disable anything that may kill the shell
*   any other tasks to be completed in init
*/

void shell_init() {
	printf("Nutshell is initializing...\n");
	aliasHead = NULL;
	varIndex = 0;
	getcwd(cwd, sizeof(cwd));
	strcpy(varTable.var[varIndex], "PWD");
	strcpy(varTable.word[varIndex], cwd);
	varIndex++;
    char* homev = getenv("HOME");
	strcpy(varTable.var[varIndex], "HOME");
	strcpy(varTable.word[varIndex], homev); //fixme: home directory should be home/"username"
	varIndex++;
	strcpy(varTable.var[varIndex], "PROMPT");
	strcpy(varTable.word[varIndex], "Nutshell DEV 0.2");
	varIndex++;
    char* pathv = getenv("PATH");
	strcpy(varTable.var[varIndex], "PATH");
	strcpy(varTable.word[varIndex], pathv);
	varIndex++;
    char* username = getenv("USER");
    strcpy(varTable.var[varIndex], "USER");
    strcpy(varTable.word[varIndex], username);
	varIndex++;
	printf("Initialization complete. Username is %s\n", username);
}
//                                                                                         Print Prompt - Prints cwd
/*
* If the CWD is HOME, then display tilde character in the prompt instead
*/
void printPrompt() {
	if (strcmp(varTable.word[0], varTable.word[1]) == 0) { //compare PWD and HOME
		printf("%s:~$ ", varTable.word[2]); //print prompt + ~
	}
	else {
		printf("%s:%s$ ", varTable.word[2], varTable.word[0]); //print prompt + PWD
	}
}

void pushAlias(char* name, char* word) {
	struct aTable* current = aliasHead;
	//first check for loops and for matching alias names...
	while (current != NULL) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return;
		}
		else if((strcmp(current->name, name) == 0) && (strcmp(current->word, word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return;
		}
		else if(strcmp(current->name, name) == 0) {
			strcpy(current->word, word);
			return;
		}
		current = current->next;
	}
	//if no matching name was found, allocate and create new alias name and word
	struct aTable* newAlias = (struct aTable*)malloc(sizeof(struct aTable));
	strcpy(newAlias->name, name);
	strcpy(newAlias->word, word);
	newAlias->next = NULL;
	if (aliasHead == NULL) {
		aliasHead = newAlias;
	}
	else {
		current = aliasHead;
		while (current->next != NULL) {
			current = current->next;
		}
		current->next = newAlias;
	}	
}
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

int main() {
	shell_init();
	while (1) {
        printPrompt();
		yyparse();
	}
}
