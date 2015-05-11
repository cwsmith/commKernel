#!/bin/bash -e
threadWorkComm() { 
  affinity=$1
  workers=$2
  echo "$SLURM_NODELIST-mic0" > hosts
  mpiexec \
    -f hosts \
    -np 1 \
    $PWD/threadWorkComm.${affinity} $workers &>> work${workers}.log
}

getAvg() {
  t=$(awk '/realTime/ {sum+=$2; cnt+=1;} END {print sum/cnt}' work${1}.log)
  echo -n ", $t "
}

declare -a fns
fns[1]="threadWorkComm"

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
