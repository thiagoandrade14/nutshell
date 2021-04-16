# nutshell
Version: 0.8 (April 15th, 2021)
Thiago de Andrade (UFID 0767-6652)
Hailee Bacon (UFID xxxx-xxxx)

## Work division ##
### Thiago ### 
- Initial syntax (parser rules).
- Most of the lexer rules.
- Built-in commands: cd, alias, unalias
- Initial implementation of non built-in commands
- Environment variable expansion

### Hailee ###
- Expanded and reorganized most of the parser syntax rules
- Several lexer rules, particularly with metacharacters (> < |, etc.)
- Built-in commands: setenv, unsetenv, printenv
- Expanded non-built in functions to support both I/O redirection (i. e. writing to files) and piping
-  2>file and 2>&1 expansion
-  Wildcard expansion (pending)

## Not implemented features ##
File name completion

## Implemented features ##
The other features are implemented to some extent.

## Installation ##
Run "make" command in the main directory.

## Description ##
The program prints a message and the username when initialized. It defaults its initialization to the directory of the shell executable. Then, it asks for input while also displaying the prompt message and current directory. 
If the current directory is HOME or is a subdirectory of HOME, then display tilde character instead. 
The following built-in commands are supported:
"bye"
"cd"
"alias"
"unalias"
"setenv name word"
"usetenv name"

Unix supported commands in the bin directory should also run (e.g. ls, pwd, etc.).

## Design ##
This unix Shell is implemented using Flex and Bison. It scans for input that is fed into flex (lexer), creating tokens according to a set of semantic rules. These tokens are sent the parser, which has a set of syntax rules of what is considered a valid command.
The parser, after analyzing the command, decides what to do with it. Built-in commands (cd, alias, unalias, setenv, unsetenv, printenv) are implemented within the shell, by making system calls. The remaining commands are called using execve, a system call that looks for the directories located in the PATH environment variable for a executable that matches the command parsed. 

## Verification ##
Start the shell by typing ./nutshell while in the main directory.
