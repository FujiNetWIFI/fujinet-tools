/**
 * @brief Read an input line.
 * @param s The output buffer.
 */

#include <ctype.h>
#include <conio.h>
#include <stdio.h>

#include "readline.h"

#ifndef CH_DEL
#define CH_DEL 0x7F
#endif

void readline(char *s)
{
    unsigned int i = 0;
    char c;

    cursor(1);

    do {
        c = cgetc();

        if (isprint(c)) {
            putchar(c);
            s[i++] = c;
        }
        else if ((c == CH_CURS_LEFT) || (c == CH_DEL)) {
            if (i) {
                putchar(CH_CURS_LEFT);
                putchar(' ');
                putchar(CH_CURS_LEFT);
                --i;
            }
        }
    } while (c != CH_ENTER);

    putchar('\n');
    s[i] = '\0';

    cursor(0);
}
