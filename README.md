# nutshell
Version: 0.3 (April 11th, 2021)

## Installation ##
Run "make" command in the main directory. Then run executable file named "shell".

## Functionality ##
The program prints a message and the username when initialized. Then, it asks for input while also displaying the prompt message and current directory. 
If the current directory is HOME, then display tilde character instead. 
The following built-in commands are supported:
"bye"
"cd"
"alias"
"unalias"
"setenv name word"
"usetenv name"

## Known BUGS ##
1. HOME directory substitution with the tilde character ~ only works when PWD = HOME. If PWD is (for instance) HOME/foo, the prompt with PWD does not display "~/foo".
2. Syntax errors causes remaining tokens to be automatically entered in the next shell iteration. Ex: the input is "hello goodbye\n", the syntax error will be detected after "hello". Then the parser will try to run " goodbye", throwing another syntax error. We must figure out a way of handling these errors to flush the input.