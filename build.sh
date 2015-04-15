#!/bin/bash -e
[ $# -ne 1 ] && echo "Usage: $0 <threadsPerCore=1|2|4>" && exit 0
tpc=$1
flags="-DTHREADS_PER_CORE=$tpc -mmic -Wall -g -O3 -fno-omit-frame-pointer "
src="kernelComm.c"
set -x
mpicc $flags threadWork.c $src -o threadWorkComm -lpthread $LDFLAGS $THREAD_MULTIPLE
mpicc $flags mpiWork.c $src -o mpiWork -lpthread $LDFLAGS
mpicc -DTHREAD_MULTIPLE $flags mpiWork.c $src \
  -o mpiWorkThreadMult -lpthread $LDFLAGS $THREAD_MULTIPLE
