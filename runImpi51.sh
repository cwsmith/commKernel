#!/bin/bash -l
#SBATCH --time=10
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --exclusive
#SBATCH -p development

#NOTE -n passed to shut up TACC's submit filter, it's not correct/used
#16x number of hosts should work
#(-N is number of hosts)
#Please also edit the variables below!

#For info on runscript contact Ben Matthews <matthews@ucar.edu>
#https://wiki.ucar.edu/display/hss/Xeon+Phi

ulimit -l unlimited
echo "memlock ulimit:" `ulimit -l`

#Try to avoid the worst of the TACC crazy
module purge
for i in `env | grep I_MPI| cut -f 1 -d '='`; do unset $i; done
for i in `env | grep DAPL | cut -f 1 -d '='`; do unset $i; done
for i in `env | grep TACC | cut -f 1 -d '='`; do unset $i; done

beta=/work/01187/bmatth/intel_tools/2016_beta1
compiler=$beta/compilers_and_libraries_2016.0.042
mpi=$beta/impi/5.1.0.042
export SINK_LD_LIBRARY_PATH=$compiler/linux/compiler/lib/mic/:$mpi/mic/lib/:$SINK_LD_LIBRARY_PATH
export SINK_PATH=$mpi/mic/bin:$SINK_PATH

#export LM_LICENSE_FILE="28518@128.117.177.41"
. $beta/bin/compilervars.sh intel64
. $mpi/bin64/mpivars.sh
export I_MPI_CC=$compiler/linux/bin/intel64_mic/icc
export I_MPI_CXX=$compiler/linux/bin/intel64_mic/icpc
export I_MPI_FC=$compiler/linux/bin/intel64_mic/ifort
#export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi.so

#EDIT THESE

hostnp=0 #tasks per host
#micnp=240
micnp=1 #tasks per accelerator
n_mics=1 #accelerators per host
app="threadWorkComm"
args="16"

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
#MIC_ENVS=" -env I_MPI_ROOT /lustre/system/phi/intel/2015_update1/impi/5.0.2.044/mic"

for h in "${hosts[@]}"; do
	for i in `seq 0 $(( $n_mics-1 ))`; do
		printf -- "$MIC_ENVS -n %d -host %s %s\n" $micnp "$h-mic$i" "$app $args" >> $tmpdir/mpi_conf
	done
		printf -- "$HOST_ENVS -n %d -host %s %s\n" $hostnp "$h-br0" "$app $args" >> $tmpdir/mpi_conf
done

cat $tmpdir/mpi_conf
which mpirun
export I_MPI_MIC=1
export I_MPI_MIC_PROXY_PATH=$mpi/mic/bin
mpiexec.hydra -iface br0 -configfile $tmpdir/mpi_conf
cp $tmpdir/mpi_conf ./
rm -rf $tmpdir
