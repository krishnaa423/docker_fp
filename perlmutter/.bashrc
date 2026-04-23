# Add color to the command prompt.
PS1='\[\e[0;32m\]\u@\h:\[\e[0;34m\]\w\[\e[0m\]\$ '
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33;40:cd=1;33;40:su=37;41:sg=30;43:tw=30;42:ow=30;43'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# variables. 
export COMMON=/global/common/software/m3571
export MODULEPATH="$SCRATCH/opt/modulefiles:$MODULEPATH"
export CONDA_ROOT=$SCRATCH/opt/miniconda
export LMOD_EXPERT=1        # Supresses new lmod errors. 
alias cdw='cd $COMMON'
alias cds='cd $SCRATCH'
alias cdh='cd $HOME'
alias status="clear && squeue -u krishnaa"
alias cup="conda deactivate && conda activate"
alias si='sinfo -S+P -o "%18P %8a %20F"'
alias cancel='scancel -u krishnaa'
alias la='ls -la'
alias rmrf='rm -rf ./*'
alias icpu='salloc --account=m3571 --qos=interactive --constraint=cpu --nodes=4 --time=03:00:00'
alias igpu='salloc --account=m3571 --qos=interactive --constraint=gpu --nodes=4 --time=03:00:00'

# miniconda.
if [ -f $CONDA_ROOT/etc/profile.d/conda.sh ]; then
    . $CONDA_ROOT/etc/profile.d/conda.sh
fi

# module loads. 

# gnu_cpu. 
# module load cpu-env/gnu-1.0.0
# module load cpu-env/gnu-2.0.0
# conda activate gnu_cpu

# nvhpc_gpu. 
module load gpu-env/nvhpc-1.0.0
# module load gpu-env/nvhpc-2.0.0
conda activate nvhpc_gpu
