#!/bin/bash -e
module swap intel intel/14.0.1.106
module swap mvapich2 impi/4.1.3.049
export THREAD_MULTIPLE="-mt_mpi"
