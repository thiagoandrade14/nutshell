# nutshell
Version: 0.2 (April 11th, 2021)

## Installation ##
Run make command in the main directory. Run executable file named "shell".

## Functionality ##
The program prints a message and the username when initialized. Then, it asks for input while also displaying the prompt message and current directory. 
If the current directory is HOME, then display tilde character instead. 
The only commands that run are:
"bye"
"cd"
"alias"*, not properly working.*
"setenv name word"*, not properly working.*
"usetenv name"*, not properly working.*

## Known BUGS ##
1. HOME directory substitution with the tilde character (~) only works when PWD == HOME. If PWD is (for instance) HOME/foo, the prompt with PWD does not display "~/foo".
2. If a syntax error occur, the shell unexpectedly exits. This must be fixed.
3. Several bugs involving reassigning an existing alias or nested alias. 