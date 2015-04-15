#!/bin/bash -e
unset LDFLAGS
unset THREAD_MULTIPLE
export LDFLAGS="-Wl,-rpath -Wl,/opt/apps/intel/13/composer_xe_2013.2.146/compiler/lib/mic "
ins=/work/02422/cwsmith/software/mvapich2-mic-2.0
export MV2_MIC_INSTALL_PATH=$ins/k1om
export LD_LIBRARY_PATH=$ins/intel64/lib:$MV2_MIC_INSTALL_PATH/lib:$LD_LIBRARY_PATH
export PATH=$ins/intel64/bin:$PATH
