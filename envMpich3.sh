#!/bin/bash -e
module swap intel intel/15.0.2
module unload mvapich2
ins=/work/02422/cwsmith/software/mpich-3.2b2/install
export PATH=$ins/bin:$PATH
export LD_LIBRARY_PATH=$ins/lib/:$LD_LIBRARY_PATH
