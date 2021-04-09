# nutshell
Version: 0.15 (April 9th, 2021)

## Installation ##
Run make command in the main directory. Run executable file named "shell".

## Functionality ##
The program prints a message and the username when initialized. Then, it asks for input while also displaying the prompt message and current directory. 
If the current directory is HOME, then display tilde character instead. 
The only commands currently working are "bye", "alias" and "cd", with or without parameters.

## Known BUGS ##
1. HOME directory substitution with the tilde character (~) only works when PWD == HOME. If PWD is (for instance) HOME/foo, the prompt with PWD does not display "~/foo".
2. If a syntax error occur, the shell unexpectedly exits. This must be fixed.