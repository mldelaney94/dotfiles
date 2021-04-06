alias tmux='tmux -u' #opens tmux with unicode by default

# add conda env
PS1="${PS1/\\n\$/\\n\(\$(basename \"\$CONDA_PREFIX)\"\) \$}"

# load miniconda
. C:/tools/miniconda3/etc/profile.d/conda.sh

#Aliases
alias gotoanki="cd C:/Users/Matthew/AppData/Roaming/Anki2/addons21/test"
