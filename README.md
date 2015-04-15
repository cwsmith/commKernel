## commKernel
communication kernel for performance testing on Stampede

## contents
- envImpi.sh - environment file for Intel MPI
- envMvapich.sh - environment file for Mvapich2-mic
- build.sh - build script 
- getTimeImpi.sh - run script for Intel MPI
- getTimeMvapich.sh - run script Mvapich2-mic
- kernelComm.c - communication kernel
- kernel.h - kernel header
- mpiWork.c - mpi driver
- README.md - this file 
- threadWork.c - threaded mpi driver

## build
    source env<Impi|Mvapich>.sh
    ./build.sh <threadsPerCore=1|2|4>

## run
    ./getTime<Impi|Mvapich>.sh
