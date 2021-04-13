# nutshell
Version: 0.45 (April 13th, 2021)

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

Unix supported commands in the bin directory should also run (e.g. ls, pwd, etc.).

## Known BUGS ##
Will have to figure out what to do with our output; I was attempting to write it to an intermediate buffer so that we could choose that buffer to either write to a file and clear or print outside the parser, but was unable to make this work so I reverted the changes. 

ALIAS does not work properly (it only prints the alias table so far), since I had to remove its functionality to test other code a while back. Working on implementing it again now.

## Internal notes ##
Updated parser to have better time understanding recursive nature of general command layout.
Built-in commands are now all interpreted in the same manner (excluding cd)
General commands set as words so that ./ executables can be treated the same in general command layout.
  All command arguments will be written to add_argz() to be indexed with argzbin.
New parsing architecture allows for commands/builtins with arguments to be understood with a metacharacter to separate.