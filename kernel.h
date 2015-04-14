#ifndef WORK_KERNEL_H_
#define WORK_KERNEL_H_
typedef struct str_thdata {
  int rank;
  int commsz;
  int id;
  int peers;
} thdata;
void kernelComm(void*);
#endif
