#include <stdio.h>
#include <syslog.h>

int main(int argc, char **argv)
{
	FILE *file;
	openlog(NULL, LOG_PID|LOG_CONS , LOG_USER);

	if (argc<3 || argc>3){
		syslog(LOG_ERR, "ERROR: Wrong number of arguments");
		return 1;
	} else {
		file = fopen(*(argv+1), "wb");
		syslog(LOG_DEBUG, "DEBUG: Writing %s to file %s", *(argv+2), *(argv+1));
		if (file != NULL){
			fprintf(file, *(argv+2));
		} else {
			syslog(LOG_ERR, "ERROR: File open error: %m");
		}
	}

	closelog();
	fclose(file);

	return 0;
}
