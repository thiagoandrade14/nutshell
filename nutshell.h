#ifndef NUTSHELL_H
#define NUTSHELL_H

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<string.h>

//environment table
//We will use it save importat values such as PWD, HOME, PATH, etc.
struct evTable {
    char var[128][100];
    char word[128][100];
};

struct aTable {
    char name[128][100];
    char word[128][100];
};


//function declarations
void shell_init();
void recover_from_errors();
void processCommand();
void do_it();
void execute_it();
void printPrompt();


//globals
struct evTable varTable;
struct aTable aliasTable;
int varIndex, aliasIndex;
char cwd[1024];

#endif