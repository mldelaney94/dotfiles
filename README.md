# dotfiles
Dotfile configurations

# New computer
for all of my vim files

Step by step guide for myself on how to get back to where I am if I swap computers:

get colemak, run file for registry changing capslock to backspace

Get Git bash and setup Git (SSH key)

Add gvim to path, check python filetype plugin for colorcolumn=79

Get Vundle

coc, requires node.js and visual studio c++ tools, when complete, if javascript error, call :call coc#util#install()

install python3 and add to path
install NUMpy

install mingw for C and C++ 64 bit (64 bit is important)

install jdk

make sure all this is added to path

should have choco by now run choco install make to get make

Then you can make universal-ctags

set PYTHONIOENCODING=utf8 think of this. https://stackoverflow.com/questions/3578685/how-to-display-utf-8-in-windows-console/3580165#3580165 related SO

https://www.quora.com/Why-doesnt-Microsoft-use-UTF-8-on-Windows-10 change region settings to use UNICODE UTF-8 (potentially change back)

Add global gitignore file
touch ~/.gitignore
git config --global core.excludesFile ~/.gitignore
