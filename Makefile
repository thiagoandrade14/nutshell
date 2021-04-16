CC=/usr/bin/cc

all:  bison-config flex-config shell

bison-config:
	bison -d parser.y

flex-config:
	flex scanner.l

shell:
	$(CC) nutshell.c parser.tab.c lex.yy.c -o nutshell

clean:
	rm parser.tab.c parser.tab.h lex.yy.c nutshell
