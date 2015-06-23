#!/bin/bash -e
[ $# -ne 1 ] && echo "Usage: $0 <threadsPerCore=1|2|4>" && exit 0
tpc=$1
flags="-DTHREADS_PER_CORE=$tpc -Wall -g -O3 -fno-omit-frame-pointer "
src="kernelComm.x86.c"
unset THREAD_MULTIPLE
set -x
mpicc $flags threadWork.c $src -o threadWorkComm.${tpc} -lpthread $LDFLAGS $THREAD_MULTIPLE
mpicc $flags mpiWork.c $src -o mpiWork.${tpc} -lpthread $LDFLAGS
mpicc -DTHREAD_MULTIPLE $flags mpiWork.c $src \
  -o mpiWorkThreadMult.${tpc} -lpthread $LDFLAGS $THREAD_MULTIPLE
