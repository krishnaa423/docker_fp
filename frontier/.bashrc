# init
# Add color to the command prompt
PS1='\[\e[0;32m\]\u@\h:\[\e[0;34m\]\w\[\e[0m\]\$ '
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33;40:cd=1;33;40:su=37;41:sg=30;43:tw=30;42:ow=30;43'
alias ls='ls --color=auto'
# variables and aliases.
export HOME=/ccs/home/krishnaa423
export WORK=/lustre/orion/mat280/proj-shared
export SCRATCH=/lustre/orion/mat280/scratch/krishnaa423
export SCRATCH_CRAY_CPU="$SCRATCH/cray_cpu"
export SCRATCH_CRAY_GPU="$SCRATCH/cray_gpu"
export MP_API="m6jL2Vf3fBHPxw6hWVtv3UYfMsmuYY1Z"
export MODULEPATH="$SCRATCH/modulefiles:$MODULEPATH"
export CONDA_ROOT=$SCRATCH/other_codes/miniconda
alias cdw='cd $WORK'
alias cds='cd $SCRATCH'
alias cdh='cd $HOME'
alias status="clear && squeue -u krishnaa"
alias cancel='scancel -u krishnaa423'
alias cup="conda deactivate && conda activate"
alias si='sinfo -S+P -o "%18P %8a %20F"'

# miniconda
if [ -f $CONDA_ROOT/etc/profile.d/conda.sh ]; then
    . $CONDA_ROOT/etc/profile.d/conda.sh
fi

# modules 

# cray_cpu
export MPICH_GPU_SUPPORT_ENABLED=0
module load PrgEnv-cray/8.6.0 
module load cray-hdf5-parallel/1.12.2.11
module load cray-libsci/24.11.0
module load cray-fftw/3.3.10.9
# elpa
module load petsc-cray-cpu/3.24.4
module load slepc-cray-cpu/3.24.2
module load libxc-cray-cpu/7.0.0 
# qe
# bgw
conda activate cray_cpu

# # cray_gpu
# export MPICH_GPU_SUPPORT_ENABLED=0
# module load PrgEnv-cray
# module load craype-accel-amd-gfx90a
# module load rocm
# module load cray-hdf5-parallel
# module load cray-libsci
# module load cray-fftw
# # elpa
# # petsc
# # slepc
# # libxc
# # qe
# # bgw