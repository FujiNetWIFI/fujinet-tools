/**
 * Simple CIO GETCHR/PUTCHR wrappers
 */

#ifndef BLOCKIO_H
#define BLOCKIO_H

#define D_DEVICE_DATA 2
#define D_DEVICE_DIRECTORY 3

void open(unsigned char channel, unsigned char aux1, char* buf, unsigned short len);
void close(unsigned char channel);
void get(unsigned char channel, char* buf, unsigned short len);
void put(unsigned char channel, char* buf, unsigned short len);

#endif /* BLOCKIO_H */
