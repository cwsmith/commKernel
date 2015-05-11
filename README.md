## commKernel
MPI left-right communication kernel for performance testing on Stampede.  Three binaries are used for testing:

threadWorkComm

Only 1 MPI task is ran and the number of workers corresponds to the number of pthreads that are created. Data is exchanged between pthreads. This code is using MPI_THREAD_MULTIPLE

mpiWork

Here workers are representing MPI tasks. Data is exhchanged between MPI tasks. The code is using MPI_INIT.

mpiWorkThreadMult

Here workers are representing MPI tasks. Data is exhchanged between MPI tasks. The code is using MPI_THREAD_MULTIPLE.

## contents
- envImpi.sh - environment file for Intel MPI 4
- envImpi5.sh - environment file for Intel MPI 5
- envImpi51.sh - environment file for Intel 16 and Intel MPI 5.1 (beta)
- envMvapich.sh - environment file for Mvapich2-mic
- envMvapich2.sh - environment file for Mvapich2-mic v2.0 - edit the install path
- envMpich3.sh - environment file for MPICH 3.2b2 - edit the install path
- build.sh - build script 
- getTimeImpi.sh - run script for Intel MPI 4 and 5
- getTimeImpi51.sh - run script for Intel MPI 5.1
- getTimeMvapich.sh - run script Mvapich2-mic
- getTimeMvapich2.sh - run script Mvapich2-mic
- getTimeMpich3.sh - run script MPICH 3.2b2
- kernelComm.c - communication kernel
- kernel.h - kernel header
- mpiWork.c - mpi driver
- README.md - this file 
- threadWork.c - threaded mpi driver

## build
    source env<Impi|Impi51|Mvapich|Mvapich2|Mpich3>.sh
    for i in 1 2 4; do ./build.sh $i; done

## run
From an interactive idev session:

    ./getTime<Impi|Mvapich|Mvapich2|Mpich3>.sh

## Performance Results

The following tests used MPSS 3.3 as installed on Stampede.
see performance.csv

## Mvapich2-MIC v2.0
Mvapich2-MIC v2.0 is not installed on Stampede.  To install it follow the instructions below:

### download
    wget http://mvapich.cse.ohio-state.edu/download/mvapich/mic/mvapich2-mic-2.0_mpss-3.3.run

### run installer
    ./mvapich2-mic-2.0_mpss-3.3.run
    #set the install path to something in your home/work directory
    #accept defaults for library paths 
edit the 'ins' variable in the environment file 'envMvapichMic2.sh' to point at the chosen install path

### sanity check the install by running the latency benchmark

    source envMvapich2.sh
create file 'config'

    echo "-n 2 : $MV2_MIC_INSTALL_PATH/libexec/mvapich2/osu_latency" > config
create file 'hosts'

    echo 'mic0:2' >> hosts
run

    mpirun_rsh -config ./config -hostfile ./hosts

## MPICH3 
MPICH 3.2b is not installed on Stampede.  To install it follow the instructions below:

### download 
    wget http://www.mpich.org/static/downloads/3.2b2/mpich-3.2b2.tar.gz

### unpack, configure, and build
    tar xzf mpich-3.2b2.tar.gz
    cd mpich-3.2b2
    mkdir buildIntel15
    cd buildIntel15
    ./doConfigIntel15.sh <install prefix absolute path>
    make 
    make install
