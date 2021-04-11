#ifndef NUTSHELL_H
#define NUTSHELL_H

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<string.h>
#include<stdbool.h>

//environment table
//We will use it save importat values such as PWD, HOME, PATH, etc.
struct evTable {
    char var[128][100];
    char word[128][100];
};

//alias table
//implemented as a linked list
struct aTable {
    char name[128];
    char word[128];
    struct aTable* next;
};


//function declarations
void shell_init();
void printPrompt();
void pushAlias(char* name, char* word);
char* subAliases(char* name);
bool ifAlias(char* name);

//globals
struct evTable varTable;
struct aTable* aliasHead;
int varIndex;
char cwd[1024];

#endif