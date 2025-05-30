#include <stdio.h>
#include "core.h"

void main(int argc,char **argv)
{
    if (get_filename(argc,argv))
        load();
}
