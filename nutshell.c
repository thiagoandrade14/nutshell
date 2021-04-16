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
	argbin = 0;
	argzbin = 0;
	argzzbin = 0;
	getcwd(cwd, sizeof(cwd));
	strcpy(varTable.var[varIndex], "PWD");
	strcpy(varTable.word[varIndex], cwd);
	varIndex++;
    char* homev = getenv("HOME");
	strcpy(varTable.var[varIndex], "HOME");
	strcpy(varTable.word[varIndex], homev);
	varIndex++;
	strcpy(varTable.var[varIndex], "PROMPT");
	strcpy(varTable.word[varIndex], "Nutshell DEV 0.5");
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
* If the CWD is HOME or one of its subdirectories,
then display tilde character in the prompt instead
*/
void printPrompt() {
	if (strcmp(varTable.word[0], varTable.word[1]) == 0) { //compare PWD and HOME
		printf("%s:~$ ", varTable.word[2]); //print prompt + ~
	}
	else {
        char temp[128];
        char rest[128];
        for(unsigned int i = 0; i < strlen(varTable.word[1]); i++)
        {
            temp[i + 1] = 0;
            temp[i] =  varTable.word[0][i];
        }
        if(!strcmp(temp, varTable.word[1]))
        {
            for(unsigned int i = strlen(temp) + 1; i < 128; i++)
            {
                rest[i - strlen(temp) - 1] = varTable.word[0][i];
            }
            printf("%s:~/%s$ ", varTable.word[2], rest);
        }
        else
        {
		    printf("%s:%s$ ", varTable.word[2], varTable.word[0]); //print prompt + PWD
        }
	}
}

void pushAlias(char* name, char* word) {
	struct aTable* current = aliasHead;
	char* oldWord = (char*) malloc(sizeof(word));
	bool removedFromList = false;
	//to improve circular loop detection, first check
	//check if alias name exists and remove it from the list
	while (current != NULL) {
		if (strcmp(current->name, name) == 0) {
			oldWord = current->word;
			removeAlias(current->name);
			removedFromList = true;
		}
		current = current->next;
	}
	//Now detect possible infinite loops
	current = aliasHead;
	char* curr = (char*) malloc(sizeof(word));
	strcpy(curr, word);
	while (isAlias(curr)) {
		curr = subAlias(curr);
	}
	if (strcmp(curr, name) == 0) {
		printf("Error, expansion of \"%s\" would create a loop.\n", name);
		if (removedFromList) {
			pushAlias(name, oldWord);
		}
		return;
	}
	while (current != NULL) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			if (removedFromList) {
				pushAlias(name, oldWord);
			}
			return;
		}
		else if((strcmp(current->name, name) == 0) && (strcmp(current->word, word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			if (removedFromList) {
				pushAlias(name, oldWord);
			}
			return;
		}
		else if((strcmp(current->word, name) == 0) && (strcmp(current->name, word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			if (removedFromList) {
				pushAlias(name, oldWord);
			}
			return;
		}
		current = current->next;
	}
	//if no infinite loop or matching name was found, allocate and create new alias name and word
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
	struct aTable* current = aliasHead;
    struct aTable* previous = NULL;
	if (current != NULL && strcmp(current->name, name) == 0) { //head is to be removed
        aliasHead = current->next;
        free(current);
        return 1;
    }
	else {
        while (current != NULL && strcmp(current->name, name) != 0) { //search for alias to be removed
            previous = current;
            current = current->next;
        }
        if (current == NULL) { //reached the end of the list without finding alias...
            return 1;
        }
        previous->next = current->next;
        free(current);
        return 1;
	}
}
char* subAlias(char* name) {
    struct aTable* current = aliasHead;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current->word;
        }
        current = current->next;
    }
    return name;
}
bool isAlias(char* name){
    struct aTable* current = aliasHead;
    while (current != NULL) {
        if(strcmp(current->name, name) == 0) {
            return true;
        }
        current = current->next;
    }
    return false;
}
int findVar(char* name) {
    for (int i = 0; varTable.var[i] != NULL; i++) {
        if (strcmp(varTable.var[i], name) == 0) {
            return i;
        }
    }
    printf("\n\nVariable %s not found. \n", name);
    return -1;
}

void clearbuff()
{
	for(unsigned int i = 0; i < 2056; i++)
	{
		buff[i] = 0;
	}
}

int main() {
	shell_init();
	clearbuff();
	while (1) {
        printPrompt();
		clearbuff();
		yyparse();
		printf("%s", buff);
		clearbuff();
	}
}
