#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE (1024 * 1024 * 1024)

int main(void){
	int *buf;

	buf = (int*)malloc(SIZE);
	if(buf==NULL){
		printf("Memory alloc error.\n");
		return 1;
	}
	memset(buf,0,SIZE);
	free(buf);
	return 0;
}
