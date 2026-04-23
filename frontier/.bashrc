# init
# Add color to the command prompt
PS1='\[\e[0;32m\]\u@\h:\[\e[0;34m\]\w\[\e[0m\]\$ '
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33;40:cd=1;33;40:su=37;41:sg=30;43:tw=30;42:ow=30;43'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# variables and aliases.
export HOME=/ccs/home/krishnaa423
export WORK=/lustre/orion/mat280/proj-shared
export SCRATCH=/lustre/orion/mat280/scratch/krishnaa423
export MODULEPATH="$SCRATCH/opt/modulefiles:$MODULEPATH"
export CONDA_ROOT=$SCRATCH/opt/miniconda
alias cdw='cd $WORK'
alias cds='cd $SCRATCH'
alias cdh='cd $HOME'
alias status="clear && squeue -u krishnaa423"
alias cup="conda deactivate && conda activate"
alias si='sinfo -S+P -o "%18P %8a %20F"'
alias cancel='scancel -u krishnaa423'
alias la='ls -la'
alias rmrf='rm -rf ./*'
alias icpu='salloc --account=mat280 --partition=batch --nodes=4 --time=01:00:00'
alias igpu='salloc --account=mat280 --partition=batch --nodes=4 --time=01:00:00'

# miniconda
if [ -f $CONDA_ROOT/etc/profile.d/conda.sh ]; then
    . $CONDA_ROOT/etc/profile.d/conda.sh
fi

# module loads. 

# cray_cpu.
# module load cpu-env/cray-1.0.0
# # module load cpu-env/cray-2.0.0
# 

# cray_gpu
module load gpu-env/cray-1.0.0
# petsc
# slepc
# libxc
# qe
# hipfort
# bgw
conda activate cray_cpu











# # cray_gpu
# export MPICH_GPU_SUPPORT_ENABLED=0
# module load PrgEnv-cray/8.3.3
# # module load cpe/23.03
# module load cce/15.0.1
# module load rocm/5.3.0
# module load craype-accel-amd-gfx90a
# export HCC_AMDGPU_TARGET=gfx90a
# module load cray-hdf5-parallel/1.12.2.3
# module load cray-libsci/23.02.1.1
# module load cray-fftw/3.3.10.9
# export LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LIBRARY_PATH
# export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
# # # elpa
# # module load petsc-cray-gpu/3.24.4
# # export PETSC_OPTIONS="-use_gpu_aware_mpi 0"
# # module load slepc-cray-gpu/3.24.2
# # module load libxc-cray-gpu/7.0.0 
# # module load hipfort-cray-gpu/5.3.0
# # module load bgw-cray-gpu/4.0.0
# conda activate cray_gpu

# # cray cpu: general
# module load general-gpu-env/1.0.0
# module load petsc-cray-cpu/3.24.4
# module load slepc-cray-cpu/3.24.2
# module load libxc-cray-cpu/7.0.0 
# module load qe-cray-cpu/7.3.1
# # qe 7.5. Did not compile. 
# module load bgw-cray-cpu/4.0.0
# conda activate cray_cpu

# # cray gpu: bgw 
# module load bgw-gpu-env/1.0.0
# module load hipfort-cray-gpu/5.3.0
# module load bgw-cray-gpu/4.0.0
# export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
# conda activate cray_gpu

# # cray gpu: general
# module load general-gpu-env/1.0.0
# module load petsc-cray-gpu/3.24.4
# module load slepc-cray-gpu/3.24.2
# module load libxc-cray-gpu/7.0.0 
# module load hipfort-cray-gpu/6.2.4
# module load qe-general-gpu/7.3.1
# # module load bgw-general-gpu/4.0.0
# conda activate cray_gpu