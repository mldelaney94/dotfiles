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
