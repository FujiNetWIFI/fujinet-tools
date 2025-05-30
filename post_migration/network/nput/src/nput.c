/**
 * @brief NPUT - Copy from local to network
 * @author Thomas Cherryhomes
 * @email thom dot cherryhomes at gmail dot com
 * @license gpl v. 3, see LICENSE for details.
 */

#include <fujinet-network.h>
#include <stdio.h>

#define NET_EOF 136

static unsigned char buf[1024];

/**
 * @brief Do network transfer to network endpoint
 * @param source The source filename
 * @param dest The destination URL
 * @return error code
 */
int nput(char *source, char *dest)
{
    unsigned char err = 0xFF;
    FILE *fp = NULL;
    unsigned char c = 0, nerr = 0;
    unsigned int bw = 0;
    unsigned long total = 0;
    int retval = 1;

    fp = fopen(source, "r");
    if (!fp)
    {
        perror("Could not open source file. Aborting");
        goto nput_close;
    }

    err = network_init();
    if (err != FN_ERR_OK)
    {
        printf("Could not find Fujinet. Aborting.\n");
        goto nput_close;
    }

    err = network_open(dest, OPEN_MODE_WRITE, OPEN_TRANS_NONE);
    if (err != FN_ERR_OK)
    {
        printf("Could not open %s, error #%u. Aborting.\n", dest, err);
        goto nput_close;
    }

    while (!feof(fp))
    {
        unsigned short wlen = 0;
        int rlen = 0;

        rlen = fread(buf, sizeof(unsigned char), sizeof(buf), fp);

        if (rlen)
        {
            err = network_write(dest, buf, rlen);
            if (err != FN_ERR_OK)
            {
                printf("Could not write to network, error #%u\n", err);
                network_status(dest,&bw,&c,&nerr);
                printf("Network Status Error #%u. Aborting.\n", err);
                goto nput_close;
            }
        }
	printf(".");
    }

    printf("Done.\n");
    retval = 0;

nput_close:
    network_close(dest);

    if (fp)
        fclose(fp);

    return retval;
}
