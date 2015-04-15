## commKernel
MPI left-right communication kernel for performance testing on Stampede

## contents
- envImpi.sh - environment file for Intel MPI
- envMvapich.sh - environment file for Mvapich2-mic
- envMvapich2.sh - environment file for Mvapich2-mic v2.0
- build.sh - build script 
- getTimeImpi.sh - run script for Intel MPI
- getTimeMvapich.sh - run script Mvapich2-mic
- getTimeMvapich2.sh - run script Mvapich2-mic
- kernelComm.c - communication kernel
- kernel.h - kernel header
- mpiWork.c - mpi driver
- README.md - this file 
- threadWork.c - threaded mpi driver

## build
    source env<Impi|Mvapich|Mvapich2>.sh
    ./build.sh <threadsPerCore=1|2|4>

## run
From an interactive idev session:

    ./getTime<Impi|Mvapich|Mvapich2>.sh

## Mvapich2-MIC v2.0
Mvapich2-MIC v2.0 is not installed on Stampede.  To install it follow the instructions below:

### download
    wget http://mvapich.cse.ohio-state.edu/download/mvapich/mic/mvapich2-mic-2.0_mpss-3.3.run

### run installer
    ./mvapich2-mic-2.0_mpss-3.3.run
    #set the install path to something in your home/work directory
    #accept defaults for library paths 
edit the 'ins' variable in the environment file ‘envMvapichMic2.sh’ to point at the chosen install path

### sanity check the install by running the latency benchmark

    source envMvapich2.sh
create file ‘config’ 

    echo “-n 2 : $MV2_MIC_INSTALL_PATH/libexec/mvapich2/osu_latency” >> config
create file ‘hosts’

    echo “mic0:2” >> hosts
run

    mpirun_rsh -config ./config -hostfile ./hosts
