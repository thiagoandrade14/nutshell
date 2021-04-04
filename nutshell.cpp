#include "nutshell.h"

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
	getcwd(cwd, sizeof(cwd));
	std::string username = getenv("USER");
	strcpy(varTable.var[varIndex], "PWD");
	strcpy(varTable.word[varIndex], cwd);
	varIndex++;
	strcpy(varTable.var[varIndex], "HOME");
	strcpy(varTable.word[varIndex], cwd);
	varIndex++;
	strcpy(varTable.var[varIndex], "PROMPT");
	strcpy(varTable.word[varIndex], "nutshell");
	varIndex++;
	strcpy(varTable.var[varIndex], "PATH");
	strcpy(varTable.word[varIndex], "./bin");
	varIndex++;
	printf("Initialization complete. Username is %s\n", username.c_str());	
}


//                                                                                          Get Command - Gets command line/parses
/*
*   init_scanner_and_parser();
*   if(yyparse())
*       understand_errors();
*   else
*       return (OK);
*/
std::string getCommand()
{
    std::string command;
    getline(std::cin, command);
    return command;
}


//                                                                                         Recover From Errors - Handling erroneous command line
/*
*   Find out if error occurred in middle of command,
*   (if it has a "Tail")
*   In this case you have to recover by "eating"
*   the rest of the command.
*   To do this: you may want to use yylex() directly, or
*   handle clear things up in any other way.
*/
void recover_from_errors()
{

}


//                                                                                         Proccess Command - Process your commands
/*
*   if(builtin)
*       do_it();  run built-in commands - no fork
*                 no exec; only your code + unix
*                 system call.
*   else
*       execute_it(); execute general commands
*                     using fork and exec        
*/
void processCommand()
{

}


//                                                                                         Do it - Processes a built-in command
/*
*   switch(builtin)
*       case ALIAS
*       case CDHome
*       case CDPath
*       case UNALIAS
*       case SETENV
*       case PRINTENV
*/
void do_it()
{

}


//                                                                                         Execute it - processing a command line
/*
*      Handle command execution, pipelining, i/o redirection, and background processing
*      Utilize a command table whose components are plugged in during parsing by yacc
*      Check command accessibility and executability
*      if(!Executable())
*      {
*           Use access() system call
*           nuterr("Command not Found")
*           return;
*      }
*      Check io file existence in case of io-redirection
*      if(check_in_file()==SYSERR)
*      {
*           nuterr("Can't read from : %s", srcf);
*           return;
*      }
*      if(check_out_file()==SYSERR)
*      {
*           nuterr("Can't write to : %s", distf);
*           return;
*      }
*      Build up the pipeline (create and set up pipe end points (using pipe, dup))
*      Process background
*/
void execute_it()
{

}


//                                                                                         Print Prompt - Prints cwd
/*
* If the CWD is HOME, then display tilde character in the prompt instead
*/
void printPrompt() {
	if (strcmp(cwd, varTable.word[1]) == 0) {
		printf("%s: ~$ ", varTable.word[2]); 
	}
	else {
		printf("%s: %s$ ", varTable.word[2], cwd);
	}
	
}



int main() {
	shell_init();
	while (1) {
        printPrompt();
		std::string userInput = getCommand();
		if (userInput == "bye") {
			exit(0);
		}
	}
}
