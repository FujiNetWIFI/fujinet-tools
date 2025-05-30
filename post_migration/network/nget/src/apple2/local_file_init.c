/**
 * @brief Do any local filesystem housekeeping, like getting file type.
 */

#include <apple2.h>
#include <apple2_filetype.h>
#include <stdio.h>
#include <string.h>
#include "readline.h"

#include "local_file_init.h"

static char ft[16];
static char aux[16];

void local_file_init(void)
{
    printf("Enter Destination Filetype:\n$");
    readline(ft);

    if (ft[0])
        sscanf(ft,"%x", &_filetype);


    printf("Enter Destination Auxtype:\n$");
    readline(aux);

    if (aux[0])
        sscanf(aux,"%x", &_auxtype);
}
