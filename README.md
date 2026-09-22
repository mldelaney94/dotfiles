# dotfiles
Repo contains my dotfile (.vim etc.) configurations
The rest of this readme contains information on relatively obscure changes I made to my pc to make things work over time, and as such is not meant to be well-written.

# New computer
for all of my vim files

Step by step guide for myself on how to get back to where I am if I swap computers:

get colemak, run file for registry changing capslock to backspace

Get Git bash and setup Git (SSH key)

Add gvim to path, check python filetype plugin for colorcolumn=79

Get miniconda, and create environments as needed

set PYTHONIOENCODING=utf8 think of this. https://stackoverflow.com/questions/3578685/how-to-display-utf-8-in-windows-console/3580165#3580165 related SO

https://www.quora.com/Why-doesnt-Microsoft-use-UTF-8-on-Windows-10 change region settings to use UNICODE UTF-8 (potentially change back)

Add python.vim to C:\Users\Matthew\.vim\ftplugin

Add global gitignore file
touch ~/.gitignore
git config --global core.excludesFile ~/.gitignore


## macOS install
`./install-macos.sh` copies the dotfiles into place (backing up anything it
overwrites), installs Homebrew and tmux if they are missing, and clones Vundle
before running `:PluginInstall`. It is idempotent, so re-running is safe. Assumes
Apple Silicon, and refuses to run under sudo (that leaves dotfiles root-owned).

It also enables Colemak and makes it the active layout. Colemak ships with macOS
(layout id 12825), so nothing is downloaded; log out and back in to apply. Caps
lock is left alone — System Settings cannot map it to backspace, and the hidutil
alternative does not survive a reboot without a LaunchAgent.

It prompts for `user.name` and `user.email` and writes them into `~/.gitconfig`
after copying it, so the real values stay out of this repo. Defaults come from
whatever is already configured, so a re-run only needs enter; answer differently
on a work machine, or override later with `git config --global`. Non-interactively,
use `GIT_NAME` and `GIT_EMAIL`.

It asks once whether to configure Cursor, VS Code, both, or neither, then writes
`settings.json` and installs the extensions in `vscode/extensions.txt` for the
editors chosen. The answer is saved to `~/.config/dotfiles/editor-target`, so
later runs just need enter. Non-interactively, use `EDITOR_TARGET=cursor`.
`CURSOR_CLI` / `VSCODE_CLI` override where the editor CLIs are looked up.

## To do
