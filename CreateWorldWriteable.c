// Useful to compile as binary for security pen testing
// Compile this code to a binary that executes with priv esc
// It will create a bash script that executes PoC code

#include <fcntl.h>
#include <unistd.h>


int main(int argc, char *argv[]) {
	char* filename="filename.bash";

	umask(0);

	int filehandle=open(filename,O_WRONLY|O_CREAT, 0777);

	write(filehandle, "#!/bin/bash", 11);
	write(filehandle, "\n", 1);
	write(filehandle, "echo Rodney > /tmp/RODNEY_TEST", 30);

	close(filehandle);
}