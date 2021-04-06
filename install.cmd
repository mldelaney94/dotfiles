pushd %userprofile%

del .bashrc
mklink .bashrc dotfiles\bash\.bashrc

del .gvimrc
mklink .gvimrc dotfiles\vim\.gvimrc
del .vimrc
mklink .vimrc dotfiles\vim\.vimrc

del .minttyrc
mklink .minttyrc dotfiles\bash\.minttyrc

del .tmux.conf
mklink .tmux.conf dotfiles\tmux\.tmux.conf

del .gitconfig
mklink .gitconfig dotfiles\git\.gitconfig
del .gitignore
mklink .gitignore dotfile\git\.gitignore

del %appdata%\Code\User\settings.json
mklink %appdata%\Code\User\settings.json dotfiles\vscode\settings.json

popd
