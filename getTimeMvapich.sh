#!/bin/bash -e
run() {
  ibrun.symm -m "$1" &>> work${2}.log
}
threadWorkComm() { 
  export MIC_MY_NSLOTS=1
  export MIC_PPN=1
  export MV2_ENABLE_AFFINITY=0
  run "./threadWorkComm.${1} $2" $2
}
mpiWork() { 
  export MIC_MY_NSLOTS=$1
  export MIC_PPN=$1
  run "./mpiWork.${1}" $2
}
mpiWorkThreadMult() { 
  export MIC_MY_NSLOTS=$1
  export MIC_PPN=$1
  export MV2_ENABLE_AFFINITY=0
  run "./mpiWorkThreadMult.${1}" $2
}
getAvg() {
  t=$(awk '/realTime/ {sum+=$2; cnt+=1;} END {print sum/cnt}' work${1}.log)
  echo -n ", $t "
}

declare -a fns
fns[1]="threadWorkComm"
fns[2]="mpiWork"
fns[3]="mpiWorkThreadMult"

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
