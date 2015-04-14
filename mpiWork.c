#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#include "kernel.h"

int main(int argc, char** argv) {
    int rank;
    int worldSz;
#ifdef THREAD_MULTIPLE
    int provided;
    MPI_Init_thread(&argc, &argv, MPI_THREAD_MULTIPLE, &provided);
    if( provided != MPI_THREAD_MULTIPLE ) {
      fprintf(stderr, "Error: MPI MPI_THREAD_MULTIPLE not supported\n");
      return 0;
    } 
#else
    MPI_Init(&argc, &argv);
#endif
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &worldSz);
    thdata* data = (thdata*) calloc(1,sizeof(thdata));
    data->rank = rank;
    data->commsz = worldSz;
    data->id = rank;
    data->peers = 1;
    kernelComm((void*) data);
    MPI_Barrier(MPI_COMM_WORLD);
    free(data);
    MPI_Finalize();
    return 0;
}
