#!/usr/bin/env bash
# One-time macOS install for bash, claude, git, mac-terminal, tmux, vim, vscode, and zsh.
# Copies files into place (does not symlink). Refuses to run on non-macOS.
# Assumes Apple Silicon throughout, so brew lives at /opt/homebrew.

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "error: this installer is macOS-only (uname was: $(uname -s))" >&2
  exit 1
fi

# uname -m reports x86_64 under Rosetta, so run this with a native bash.
if [[ "$(uname -m)" != "arm64" ]]; then
  echo "error: this installer assumes Apple Silicon (uname -m was: $(uname -m))" >&2
  exit 1
fi

# Running as root leaves every installed dotfile owned by root, which makes them
# unwritable by the account that actually uses them (vim ':w' on ~/.vimrc fails).
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "error: do not run this with sudo; it would leave your dotfiles owned by root" >&2
  echo "       re-run as yourself: ./install-macos.sh" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".dotfiles-backup.$(date +%Y%m%d%H%M%S)"

# Overridable for apps installed outside /Applications (e.g. ~/Applications).
CURSOR_CLI="${CURSOR_CLI:-/Applications/Cursor.app/Contents/Resources/app/bin/cursor}"
VSCODE_CLI="${VSCODE_CLI:-/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code}"

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

# Neither CLI is on PATH by default on macOS; both ship inside the app bundle.
install_extensions() {
  local label="$1"
  local bundle_cli="$2"
  local path_name="$3"
  local list="$ROOT/vscode/extensions.txt"
  local cli=""
  local id ok=0 failed=0

  if [[ -x "$bundle_cli" ]]; then
    cli="$bundle_cli"
  elif command -v "$path_name" >/dev/null 2>&1; then
    cli="$(command -v "$path_name")"
  else
    echo "warning: no $label CLI found; skipping its extensions" >&2
    return 0
  fi

  if [[ ! -f "$list" ]]; then
    echo "error: missing extension list: $list" >&2
    exit 1
  fi

  # A bad id or a dropped network should not abort the whole install, so each
  # failure is reported and counted rather than propagated.
  while IFS= read -r id || [[ -n "$id" ]]; do
    id="${id%%#*}"
    id="$(printf '%s' "$id" | tr -d '[:space:]')"
    [[ -z "$id" ]] && continue

    if "$cli" --install-extension "$id" --force >/dev/null 2>&1; then
      echo "  $label extension: $id"
      ok=$((ok + 1))
    else
      echo "  $label extension FAILED: $id" >&2
      failed=$((failed + 1))
    fi
  done <"$list"

  echo "$label extensions: $ok installed, $failed failed"
  return 0
}

echo "Installing dotfiles from: $ROOT"
echo

# --- editor choice ---
# Cursor is a VS Code fork with a separate config dir, and settings.json is
# compatible between them. Asked up front so the prompt does not wait behind the
# brew and PluginInstall steps. Override non-interactively with EDITOR_TARGET.
install_vscode=no
install_cursor=no
EDITOR_CHOICE_FILE="$HOME/.config/dotfiles/editor-target"

editor_target="${EDITOR_TARGET:-}"
saved_target=""
if [[ -f "$EDITOR_CHOICE_FILE" ]]; then
  saved_target="$(tr -d '[:space:]' <"$EDITOR_CHOICE_FILE")"
fi

if [[ -z "$editor_target" ]]; then
  if [[ -t 0 ]]; then
    if [[ -n "$saved_target" ]]; then
      printf 'Editor for settings.json + extensions? [cursor/vscode/all/none] (enter keeps %s) ' \
        "$saved_target"
    else
      printf 'Editor for settings.json + extensions? [cursor/vscode/all/none] '
    fi
    # read fails on EOF (ctrl-d, or piped input that ran out). Under 'set -e' an
    # unguarded read would abort the installer here with no explanation.
    if ! read -r editor_target; then
      editor_target=""
      echo
    fi
    # A bare enter reuses the saved answer rather than re-asking every run.
    editor_target="${editor_target:-${saved_target:-none}}"
  else
    editor_target="${saved_target:-none}"
    echo "no tty: using editor target '$editor_target'"
  fi
fi

case "$editor_target" in
  cursor) install_cursor=yes; editor_target=cursor ;;
  vscode | code) install_vscode=yes; editor_target=vscode ;;
  all | both) install_cursor=yes; install_vscode=yes; editor_target=all ;;
  none | skip | "") editor_target=none ;;
  *)
    echo "error: unrecognised editor '$editor_target' (want cursor/vscode/all/none)" >&2
    exit 1
    ;;
esac

# Persist only after validating, so a typo never overwrites a good answer.
mkdir -p "$(dirname "$EDITOR_CHOICE_FILE")"
printf '%s\n' "$editor_target" >"$EDITOR_CHOICE_FILE"
echo "editor target: $editor_target (saved to $EDITOR_CHOICE_FILE)"

# --- git identity ---
# Asked here, applied after ~/.gitconfig is copied (the copy would overwrite it).
# Defaults come from the current ~/.gitconfig, read before that copy happens, so
# a re-run only needs enter and no extra state file is required. A work machine
# can just answer differently, or override later with 'git config --global'.
existing_git_name="$(git config --global user.name 2>/dev/null || true)"
existing_git_email="$(git config --global user.email 2>/dev/null || true)"

ask_identity() { # ask_identity <varname> <label> <existing>
  local __var="$1"
  local label="$2"
  local existing="$3"
  local reply=""

  if [[ -t 0 ]]; then
    if [[ -n "$existing" ]]; then
      printf 'Git %s? (enter keeps %s) ' "$label" "$existing"
    else
      printf 'Git %s? ' "$label"
    fi
    # read fails on EOF; unguarded, 'set -e' would abort the installer here.
    if ! read -r reply; then
      reply=""
      echo
    fi
  fi

  printf -v "$__var" '%s' "${reply:-$existing}"
}

git_name="${GIT_NAME:-}"
git_email="${GIT_EMAIL:-}"
[[ -z "$git_name" ]] && ask_identity git_name "user.name" "$existing_git_name"
[[ -z "$git_email" ]] && ask_identity git_email "user.email" "$existing_git_email"

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

# --- zsh ---
# Unlike bash, zsh reads ~/.zshrc for interactive login shells, so Terminal.app
# needs no ~/.zprofile glue here.
install_file "$ROOT/zsh/.zshrc" "$HOME/.zshrc"

# --- homebrew ---
if command -v brew >/dev/null 2>&1; then
  echo "kept: homebrew (already installed at $(brew --prefix))"
else
  echo "installing: homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # The installer does not touch this shell's PATH.
  if [[ ! -x /opt/homebrew/bin/brew ]]; then
    echo "error: homebrew installed but /opt/homebrew/bin/brew is missing" >&2
    exit 1
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "installed: homebrew ($(brew --prefix))"
fi

# --- tmux ---
if brew list --formula tmux >/dev/null 2>&1; then
  echo "kept: tmux (already installed via brew)"
else
  echo "installing: tmux"
  brew install tmux
fi
install_file "$ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"

# --- vim ---
install_file "$ROOT/vim/.vimrc" "$HOME/.vimrc"
install_file "$ROOT/vim/.gvimrc" "$HOME/.gvimrc"

# Vundle must exist before .vimrc is sourced, since .vimrc calls vundle#begin().
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"
if [[ -d "$VUNDLE_DIR/.git" ]]; then
  echo "kept: vundle (already cloned at $VUNDLE_DIR)"
else
  git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
  echo "installed: vundle -> $VUNDLE_DIR"
fi

# On the first run .vimrc references plugins that are still being fetched (most
# visibly `colorscheme gruvbox`), so vim can exit non-zero without having failed.
if vim +PluginInstall +qall; then
  echo "installed: vim plugins (:PluginInstall)"
else
  echo "warning: vim exited non-zero during :PluginInstall; re-run 'vim +PluginInstall +qall'" >&2
fi

# --- git ---
install_file "$ROOT/git/.gitconfig" "$HOME/.gitconfig"
install_file "$ROOT/git/.gitignore" "$HOME/.gitignore"

# Fills the empty user.name / user.email left in the tracked .gitconfig, so the
# real values never need committing. Must run after the copy above.
if [[ -n "$git_name" ]]; then
  git config --global user.name "$git_name"
  echo "installed: git user.name = $git_name"
else
  echo "skipped: git user.name (left blank)"
fi
if [[ -n "$git_email" ]]; then
  git config --global user.email "$git_email"
  echo "installed: git user.email = $git_email"
else
  echo "skipped: git user.email (left blank)"
fi

# --- claude ---
install_file "$ROOT/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# --- editor settings ---
# Neither app is required to be installed; both read this path on next launch.
# The theme and vim keybindings in settings.json still need their extensions.
if [[ "$install_cursor" == yes ]]; then
  install_file \
    "$ROOT/vscode/settings.json" \
    "$HOME/Library/Application Support/Cursor/User/settings.json"
  install_extensions "cursor" "$CURSOR_CLI" "cursor"
fi
if [[ "$install_vscode" == yes ]]; then
  install_file \
    "$ROOT/vscode/settings.json" \
    "$HOME/Library/Application Support/Code/User/settings.json"
  install_extensions "vscode" "$VSCODE_CLI" "code"
fi
if [[ "$install_cursor" == no && "$install_vscode" == no ]]; then
  echo "skipped: editor settings.json and extensions"
fi

# --- keyboard layout (colemak) ---
# Colemak ships with macOS as layout id 12825, so there is nothing to download;
# it only needs enabling and selecting. The id must be an <integer>: an
# old-style plist literal writes it as a <string>, which the input system
# ignores, hence the XML. These go through 'defaults' rather than PlistBuddy so
# that cfprefsd, which caches this domain, does not overwrite them afterwards.
COLEMAK_SOURCE='<dict>'
COLEMAK_SOURCE+='<key>InputSourceKind</key><string>Keyboard Layout</string>'
COLEMAK_SOURCE+='<key>KeyboardLayout ID</key><integer>12825</integer>'
COLEMAK_SOURCE+='<key>KeyboardLayout Name</key><string>Colemak</string>'
COLEMAK_SOURCE+='</dict>'

if defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null |
  grep -q Colemak; then
  echo "kept: colemak (already an enabled input source)"
else
  defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add "$COLEMAK_SOURCE"
  echo "installed: colemak added to input sources"
fi

# Selected is the layout actually in use; replacing the array is the point here.
defaults write com.apple.HIToolbox AppleSelectedInputSources -array "$COLEMAK_SOURCE"
defaults write com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID \
  -string com.apple.keylayout.Colemak
echo "installed: colemak set as the active layout"

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
echo "Log out and back in for the Colemak layout to take effect."
echo "Restart Terminal.app (or open a new window) to use the gruvbox profile."
