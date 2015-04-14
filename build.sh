#!/bin/bash -e
module swap intel intel/14.0.1.106
module swap mvapich2 impi/4.1.3.049

tpc=$1
flags="-DTHREADS_PER_CORE=$tpc -mmic -Wall -g -O3 -fno-omit-frame-pointer "
src="kernelComm.c"
set -x
mpicc $flags threadWork.c $src -o threadWorkComm -lpthread -mt_mpi
mpicc $flags mpiWork.c $src -o mpiWork
mpicc -DTHREAD_MULTIPLE $flags mpiWork.c $src \
  -o mpiWorkThreadMult -mt_mpi
