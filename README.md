# nutshell
Version: 0.8 (April 15th, 2021)
Thiago de Andrade (UFID 0767-6652)
Hailee Bacon (UFID xxxx-xxxx)

## Work division ##
Thiago: 
- Initial syntax (parser rules).
- Most of the lexer rules.
- Built-in commands: cd, alias, unalias
- Initial implementation of non built-in commands
- Environment variable expansion
- Wildcard expansion (pending)

Hailee:
- Expanded and reorganized most of the parser syntax rules
- Several lexer rules, particularly with metacharacters (> < |, etc.)
- Built-in commands: setenv, unsetenv, printenv
- Expanded non-built in functions to support both I/O redirection (i. e. writing to files) and piping
-  2>file and 2>&1 expansion

## Not implemented features ##
File name completion

## Implemented features ##
The other features are implemented to some extent.

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

## Internal notes ##
Updated parser to have better time understanding recursive nature of general command layout.
Built-in commands are now all interpreted in the same manner (excluding cd)
General commands set as words so that ./ executables can be treated the same in general command layout.
  All command arguments will be written to add_argz() to be indexed with argzbin.
New parsing architecture allows for commands/builtins with arguments to be understood with a metacharacter to separate.

Replaced most of the print statements with output to the buffer. The buffer will print if not emptied by the end of the parsing.
Otherwise buffer can be used when metacharacter is called.
Determines whether command (ex. the fn in "ex > fn") is executable or not (important in decided whether to write to the file or use as input (unsure how to use as input))
This logic (for the executable) is done within the command method

Finished > operator, >> operator, and < operator. Partial completed | operator (only 2 operands)
Also in progress: 2>&1 and 2> operators
