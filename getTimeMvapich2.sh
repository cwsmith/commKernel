#!/bin/bash -e
threadWorkComm() { 
  workers=$1
  echo "mic0:1" > ./hostsThreadWorkComm
  echo "export MV2_ENABLE_AFFINITY=0" > ./threadWorkCommMvapich2.sh
  echo "$PWD/threadWorkComm $workers" >> ./threadWorkCommMvapich2.sh
  chmod +x ./threadWorkCommMvapich2.sh
  echo "-n 1 : $PWD/threadWorkCommMvapich2.sh " > ./configThreadWorkComm
  /usr/bin/time -f "realTime %e" mpirun_rsh \
    -config ./configThreadWorkComm \
    -hostfile ./hostsThreadWorkComm &>> work${1}.log
}

getAvg() {
  awk '/realTime/ {sum+=$2; cnt+=1;} END {print "average " sum/cnt}' work${1}.log 
}

declare -a fns
fns[1]="threadWorkComm"

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
