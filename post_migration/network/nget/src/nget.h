/**
 * @brief NGET - Copy from network to local
 * @author Thomas Cherryhomes
 * @email thom dot cherryhomes at gmail dot com
 * @license gpl v. 3, see LICENSE for details.
 */

#ifndef NGET_H
#define NGET_H

/**
 * @brief Do network transfer to local filesystem
 * @param source The source N: URL
 * @param dest The destination local file
 * @return error code
 */
int nget(const char *source, const char *dest);

#endif 
