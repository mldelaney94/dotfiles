#!/usr/bin/env bash
# One-time macOS install for bash, claude, git, mac-terminal, tmux, vim, and vscode.
# Copies files into place (does not symlink). Refuses to run on non-macOS.

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "error: this installer is macOS-only (uname was: $(uname -s))" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".dotfiles-backup.$(date +%Y%m%d%H%M%S)"

install_file() {
  local src="$1"
  local dest="$2"

  if [[ ! -f "$src" ]]; then
    echo "error: missing source: $src" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    mv "$dest" "${dest}${BACKUP_SUFFIX}"
    echo "backed up: $dest -> ${dest}${BACKUP_SUFFIX}"
  fi

  cp "$src" "$dest"
  echo "installed: $dest"
}

echo "Installing dotfiles from: $ROOT"
echo

# --- bash ---
# macOS Terminal runs login shells, so ~/.bash_profile must source ~/.bashrc.
install_file "$ROOT/bash/.bashrc" "$HOME/.bashrc"
BASH_PROFILE="$HOME/.bash_profile"
SOURCE_LINE='[ -f ~/.bashrc ] && source ~/.bashrc'
if [[ ! -f "$BASH_PROFILE" ]]; then
  printf '%s\n' "$SOURCE_LINE" >"$BASH_PROFILE"
  echo "installed: $BASH_PROFILE (sources ~/.bashrc)"
elif ! grep -qE 'source[[:space:]]+(~/|\$HOME/)?\.bashrc|\.[[:space:]]+(~/|\$HOME/)?\.bashrc' "$BASH_PROFILE"; then
  if [[ -e "$BASH_PROFILE" || -L "$BASH_PROFILE" ]]; then
    cp "$BASH_PROFILE" "${BASH_PROFILE}${BACKUP_SUFFIX}"
    echo "backed up: $BASH_PROFILE -> ${BASH_PROFILE}${BACKUP_SUFFIX}"
  fi
  printf '\n%s\n' "$SOURCE_LINE" >>"$BASH_PROFILE"
  echo "updated: $BASH_PROFILE (appended source ~/.bashrc)"
else
  echo "kept: $BASH_PROFILE (already sources ~/.bashrc)"
fi

# --- tmux ---
install_file "$ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"

# --- vim ---
install_file "$ROOT/vim/.vimrc" "$HOME/.vimrc"
install_file "$ROOT/vim/.gvimrc" "$HOME/.gvimrc"

# --- git ---
install_file "$ROOT/git/.gitconfig" "$HOME/.gitconfig"
install_file "$ROOT/git/.gitignore" "$HOME/.gitignore"

# --- claude ---
install_file "$ROOT/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# --- vscode ---
install_file \
  "$ROOT/vscode/settings.json" \
  "$HOME/Library/Application Support/Code/User/settings.json"

# --- mac-terminal (Terminal.app profile) ---
PROFILE_SRC="$ROOT/mac-terminal/gruvbox.terminal"
if [[ ! -f "$PROFILE_SRC" ]]; then
  echo "error: missing source: $PROFILE_SRC" >&2
  exit 1
fi

# Import the profile into Terminal.app, then set it as default/startup.
open "$PROFILE_SRC"
defaults write com.apple.Terminal "Default Window Settings" -string "gruvbox"
defaults write com.apple.Terminal "Startup Window Settings" -string "gruvbox"
echo "installed: Terminal.app profile 'gruvbox' (imported + set as default)"

echo
echo "Done. Existing files were renamed with suffix ${BACKUP_SUFFIX}."
echo "Fill in git user.name / user.email in ~/.gitconfig if needed."
echo "Restart Terminal.app (or open a new window) to use the gruvbox profile."
