alias tmux='tmux -u' #opens tmux with unicode by default

#default editor
export VISUAL=vim
export EDITOR="$VISUAL"

# Apple Silicon brew prefix. The installer only writes this to ~/.zprofile, so
# without it /opt/homebrew/bin is missing from PATH in non-login shells.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# => History
    HISTFILE=~/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt HIST_IGNORE_ALL_DUPS # drop an older duplicate of the command just entered
    setopt HIST_IGNORE_SPACE    # leading space keeps a command out of the history
    setopt HIST_REDUCE_BLANKS
    setopt SHARE_HISTORY        # history is live across concurrent shells

# => Completion
    autoload -Uz compinit && compinit
    zstyle ':completion:*' menu select
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive
    setopt AUTO_CD

# => Prompt
    # Deliberately no %n@%m: 'matthewdelaney@Matthews-MBP' is noise on a
    # machine I never share. Layout is: <cwd> (<branch>) (<conda env>) $
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git:*' formats '(%b)'
    zstyle ':vcs_info:git:*' actionformats '(%b|%a)' # e.g. (main|rebase-i)
    precmd_functions+=(vcs_info)

    setopt PROMPT_SUBST
    PROMPT='%F{blue}%~%f'
    PROMPT+='${vcs_info_msg_0_:+ %F{red}${vcs_info_msg_0_}%f}'
    PROMPT+='${CONDA_PREFIX:+ (${CONDA_PREFIX:t})}'
    PROMPT+='$ '

# => nvm
    # nvm itself is sourced by whatever installed it; only react to .nvmrc if
    # the function actually exists in this shell.
    _nvmrc_hook() {
      [[ -f .nvmrc ]] || return
      (( $+functions[nvm] )) || return
      nvm use
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _nvmrc_hook
    _nvmrc_hook
