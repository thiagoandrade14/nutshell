#include "nutshell.h"

//Initializes the shell
//For now, it simply gets and prints the username. 
void shell_init() {
	std::string username = getenv("USER");
	std::cout << "Username is " << username << "." << std::endl;
}

//prints directory and asks for command input
std::string printPrompt() {
	std::string userInput;
	char cwd[1024];
	getcwd(cwd, 1024);
	std::cout << cwd << ": ";
	getline(std::cin, userInput);
	return userInput;
}

int main() {
	shell_init();
	while (1) {
		std::string userInput = printPrompt();
		if (userInput == "bye") {
			exit(0);
		}
	}
}