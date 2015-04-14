#!/bin/bash -e
module swap intel intel/14.0.1.106
module swap mvapich2 impi/4.1.3.049

run() {
  /usr/bin/time -f "realTime %e" ibrun.symm -m "$1" &>> work${2}.log
}
threadWorkComm() { 
  export MIC_MY_NSLOTS=1
  export MIC_PPN=1
  run "./threadWorkComm $1" $1
}
mpiWork() { 
  export MIC_MY_NSLOTS=$1
  export MIC_PPN=$1
  run "./mpiWork"
}
mpiWorkThreadMult() { 
  export MIC_MY_NSLOTS=$1
  export MIC_PPN=$1
  run "./mpiWorkThreadMult"
}
getAvg() {
  awk '/realTime/ {sum+=$2; cnt+=1;} END {print "average " sum/cnt}' work${1}.log 
}

declare -a fns
fns[1]="threadWorkComm"
fns[2]="mpiWork"
fns[3]="mpiWorkThreadMult"

for workers in 2 4 8 16 32; do
  for i in "${!fns[@]}"; do   
    cat /dev/null > work${workers}.log
    echo -n "${fns[i]} workers $workers "
    for j in {0..4}; do 
      ${fns[$i]} $workers
    done
    getAvg $workers
  done
done
