#!/bin/bash -e

setup() {
  ulimit -l unlimited
  echo "memlock ulimit:" `ulimit -l`

  for i in `env | grep I_MPI| cut -f 1 -d '='`; do unset $i; done
  for i in `env | grep DAPL | cut -f 1 -d '='`; do unset $i; done
  for i in `env | grep TACC | cut -f 1 -d '='`; do unset $i; done

  beta=/work/01187/bmatth/intel_tools/2016_beta1
  compiler=$beta/compilers_and_libraries_2016.0.042
  mpi=$beta/impi/5.1.0.042
  export SINK_LD_LIBRARY_PATH=$compiler/linux/compiler/lib/mic/:$mpi/mic/lib/:$SINK_LD_LIBRARY_PATH
  export SINK_PATH=$mpi/mic/bin:$SINK_PATH

  . $beta/bin/compilervars.sh intel64
  . $mpi/bin64/mpivars.sh
  export I_MPI_CC=$compiler/linux/bin/intel64_mic/icc
  export I_MPI_CXX=$compiler/linux/bin/intel64_mic/icpc
  export I_MPI_FC=$compiler/linux/bin/intel64_mic/ifort
}

mpirun() {
#EDIT THESE
  hostnp=0 #tasks per host
  micnp=1 #tasks per accelerator
  n_mics=1 #accelerators per host
  app=$1

#The rest of this script should be safe to ignore
#(Give or take performance)
  tmpdir=`mktemp -d`

  hosts=()
  for i in $SLURM_NODELIST; do
    for j in `scontrol show hostname $i`; do
      hosts+=($j)
    done
  done
  echo "-genv I_MPI_DEBUG 5" > $tmpdir/mpi_conf
  echo "-genv I_MPI_FABRICS 'shm:dapl'" >> $tmpdir/mpi_conf
  echo "-genv I_MPI_FALLBACK 0" >> $tmpdir/mpi_conf
  echo "-genv I_MPI_MIC 1" >> $tmpdir/mpi_conf
  echo "-genv I_MPI_MIC_PREFIX ./" >> $tmpdir/mpi_conf
  echo "-genv I_MPI_EXTRA_FILE_SYSTEM 1" >> $tmpdir/mpi_conf
  echo "-genv I_MPI_EXTRA_FILE_SYSTEM_LLIST lustre" >> $tmpdir/mpi_conf
  echo "-genv I_MPI_MIC_PROXY_PATH $mpi/mic/bin" >> $tmpdir/mpi_conf
  MIC_ENVS="-genv PATH $SINK_PATH -genv LD_LIBRARY_PATH $SINK_LD_LIBRARY_PATH"

  for h in "${hosts[@]}"; do
    for i in `seq 0 $(( $n_mics-1 ))`; do
      printf -- "$MIC_ENVS -n %d -host %s %s\n" $micnp "$h-mic$i" "$app" >> $tmpdir/mpi_conf
    done
    printf -- "$HOST_ENVS -n %d -host %s %s\n" $hostnp "$h-br0" "$app" >> $tmpdir/mpi_conf
  done

  cat $tmpdir/mpi_conf
  which mpirun
  export I_MPI_MIC=1
  export I_MPI_MIC_PROXY_PATH=$mpi/mic/bin
  mpiexec.hydra -iface br0 -configfile $tmpdir/mpi_conf
  cp $tmpdir/mpi_conf ./
  rm -rf $tmpdir
}

run() {
  mpirun "$1" &>> work${2}.log
}
threadWorkComm() { 
  run "./threadWorkComm.${1} $2" $2
}
getAvg() {
  t=$(awk '/realTime/ {sum+=$2; cnt+=1;} END {print sum/cnt}' work${1}.log)
  echo -n ", $t "
}

declare -a fns
fns[1]="threadWorkComm"

setup

for fnIdx in "${!fns[@]}"; do
  for affinity in 1 2 4; do 
    echo -n "${fns[$fnIdx]}, $affinity"
    for workers in 2 4 8 16 32; do
      cat /dev/null > work${workers}.log
      for j in {0..4}; do 
        ${fns[$fnIdx]} $affinity $workers
      done
      getAvg $workers
    done
    echo ""
  done
done
