#!/bin/bash

# init
# Add color to the command prompt
PS1='\[\e[0;32m\]\u@\h:\[\e[0;34m\]\w\[\e[0m\]\$ '
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33;40:cd=1;33;40:su=37;41:sg=30;43:tw=30;42:ow=30;43'
alias ls='ls --color=auto'
# variables and aliases.
export COMMON=/global/common/software/m3571
export SCRATCH_GCC_CPU="$SCRATCH/gcc_cpu"
export SCRATCH_GCC_GPU="$SCRATCH/gcc_gpu"
export SCRATCH_NVHPC_GPU="$SCRATCH/nvhpc_gpu"
export MP_API="m6jL2Vf3fBHPxw6hWVtv3UYfMsmuYY1Z"
export MODULEPATH="$SCRATCH/modulefiles:$MODULEPATH"
export CONDA_ROOT=$SCRATCH/other_codes/miniconda
alias cdw='cd $COMMON'
alias cds='cd $SCRATCH'
alias cdh='cd $HOME'
alias status="clear && squeue -u krishnaa"
alias cup="conda deactivate && conda activate"

# miniconda
if [ -f $CONDA_ROOT/etc/profile.d/conda.sh ]; then
    . $CONDA_ROOT/etc/profile.d/conda.sh
fi

# modules 

# gcc_cpu
module load PrgEnv-gnu/8.6.0
module load cray-hdf5-parallel/1.12.2.9
module load cray-libsci/25.09.0
module load cray-fftw/3.3.10.11
module load petsc-gcc-cpu/3.24.4
module load slepc-gcc-cpu/3.24.2
module load libxc-gcc-cpu/7.0.0
module load qe-gcc-cpu/7.3.1
module load elpa-gcc-cpu/2025.06.002
module load bgw-gcc-cpu/4.0.0
conda activate gcc_cpu

# # gcc_gpu
# module load PrgEnv-gnu/8.6.0
# conda activate gcc_gpu

# # nvhpc_gpu
# module load PrgEnv-nvidia
# conda activate nvhpc_gpu