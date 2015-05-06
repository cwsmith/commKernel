#!/bin/bash -e
module swap intel intel/15.0.2
module swap mvapich2 impi/5.0.2
export THREAD_MULTIPLE="-mt_mpi"
