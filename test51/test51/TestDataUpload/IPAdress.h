/*
 *  IPAdress.h
 *
 *
 */

#ifndef IPAdress_h
#define IPAdress_h


#define MAXADDRS	32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

extern void InitAddresses();
extern void FreeAddresses();
extern void GetIPAddresses();
extern void GetHWAddresses();

#endif