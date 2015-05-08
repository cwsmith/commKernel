#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <mpi.h>

#include "kernel.h"

int main(int argc, char** argv) {
    int i, threadCnt;
    int rank;
    int worldSz;
    int provided;
    double t0;
    MPI_Init_thread(&argc, &argv, MPI_THREAD_MULTIPLE, &provided);
    if( provided != MPI_THREAD_MULTIPLE ) {
      fprintf(stderr, "Error: MPI MPI_THREAD_MULTIPLE not supported\n");
      return 0;
    } 
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &worldSz);
    if( worldSz != 1 ) {
      fprintf(stderr, "Error: Only one mpi rank is allowed\n");
      return 0;
    } 
    if( argc != 2 ) {
      fprintf(stderr, "Usage: %s <num threads>\n", argv[0]);
      return 0;
    }
    threadCnt = atoi(argv[1]);
    thdata* data = (thdata*) calloc(threadCnt,sizeof(thdata));
    pthread_t* threads = (pthread_t*) calloc(threadCnt,sizeof(pthread_t));

    t0 = MPI_Wtime();
    for(i=0; i<threadCnt; i++) {
      data[i].rank = rank;
      data[i].commsz = worldSz;
      data[i].id = (rank*threadCnt)+i;
      data[i].peers = threadCnt;
      pthread_create (&(threads[i]), NULL, (void*) &kernelComm, (void *) &(data[i]));
    }

    for(i=0; i<threadCnt; i++)
      pthread_join(threads[i], NULL);

    if( !rank )
      fprintf(stderr, "realTime %.3f\n", MPI_Wtime()-t0);

    free(data);
    free(threads);
    MPI_Finalize();
    return 0;
}
