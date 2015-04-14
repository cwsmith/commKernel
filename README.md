## commKernel
communication kernel for performance testing on Stampede

## contents
- build.sh - build script 
- getTime.sh - run script
- kernelComm.c - communication kernel
- kernel.h - kernel header
- mpiWork.c - mpi driver
- README - this file 
- threadWork.c - threaded mpi driver

## build
./build.sh <threadsPerCore=1|2|4>

## run
./getTime.sh
