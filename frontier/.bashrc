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
export LMOD_EXPERT=1        # Supresses new lmod errors. 
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

# # cray_cpu.
# module load cpu-env/cray-1.0.0
# # module load cpu-env/cray-2.0.0
# conda activate cray_cpu

# cray_gpu
# module load gpu-env/cray-1.0.0
module load gpu-env/cray-2.0.0
conda activate cray_gpu
