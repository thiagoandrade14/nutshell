#include<stdio.h>
#include<string.h>
#include<iostream>
#include<stdlib.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<string>

void shell_init();
std::string getCommand();
void recover_from_errors();
void processCommand();
void do_it();
void execute_it();
void printPrompt();
