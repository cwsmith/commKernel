#!/bin/bash -ex
module reset
module unload mvapich2
module unload intel
bd=/work/01187/bmatth/intel_tools/2016_beta1
source $bd/bin/compilervars.sh intel64
source $bd/impi/*/bin64/mpivars.sh
export I_MPI_CC=$bd/compilers_and_libraries_2016.0.042/linux/bin/intel64_mic/icc
export I_MPI_CXX=$bd/compilers_and_libraries_2016.0.042/linux/bin/intel64_mic/icpc
export I_MPI_FC=$bd/compilers_and_libraries_2016.0.042/linux/bin/intel64_mic/ifort
export THREAD_MULTIPLE="-mt_mpi"
