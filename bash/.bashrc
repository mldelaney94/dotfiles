alias tmux='tmux -u' #opens tmux with unicode by default

# add conda env
PS1="${PS1/\\n\$/\\n\(\$(basename \"\$CONDA_PREFIX)\"\) \$}"

# load miniconda
. C:/tools/miniconda3/etc/profile.d/conda.sh

#Aliases
alias gotoanki="cd C:/Users/Matthew/AppData/Roaming/Anki2/addons21/test"

#default editor
export VISUAL=vim
export EDITOR="$VISUAL"

_nvmrc_hook() {
  if [[ $PWD == $PREV_PWD ]]; then
    return
  fi
  
  PREV_PWD=$PWD
  [[ -f ".nvmrc" ]] && nvm use
}

if ! [[ "${PROMPT_COMMAND:-}" =~ _nvmrc_hook ]]; then
  PROMPT_COMMAND="_nvmrc_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
