#include <string.h>
#include <stdio.h>
#include <conio.h>
#include <cc65.h>
#include "nput.h"
#include "readline.h"

#include "main.h"

const char *version = "1.0.0";

static char source[256];
static char dest[256];

static void quit(void)
{
    printf("Press any key to continue.\n");
    cgetc();
}

static void get_parms(void)
{
    printf("Enter Source Filename: \n");
    readline(source);

    if (!source[0])
        return;
    
    printf("Enter Destination URL: \n");
    readline(dest);

    if (!dest[0])
        return;
}

int main(int argc, char* argv[])
{
#ifdef __APPLE2__
    if (get_ostype() == APPLE_IIIEM)
        allow_lowercase(1);
#endif

    if (doesclrscrafterexit())
    {
        clrscr();
        atexit(quit);
    }

    if (argc < 2)
        get_parms();
    else
    {
        strcpy(source, argv[1]);
        strcpy(dest, argv[2]);
    }
    
    if (!source[0])
    {
        printf("Source not specified. Exiting.\n");
        return 1;
    }

    if (!dest[0])
    {
        printf("Destination not specified. Exiting.\n");
        return 1;
    }

    return nput(source, dest);
}
