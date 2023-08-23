set nocompatible

" => Plugins
    filetype off                  " required
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()

    " let Vundle manage Vundle, required
    Plugin 'VundleVim/Vundle.vim'
    Plugin 'morhetz/gruvbox'
    Plugin 'vim-airline/vim-airline'
    Plugin 'vim-airline/vim-airline-themes'
    Plugin 'christoomey/vim-tmux-navigator'
    Plugin 'vimwiki/vimwiki'
    Plugin 'chemzqm/vim-jsx-improve'
    Plugin 'pangloss/vim-javascript'
    " All of your Plugins must be added before the following line
    call vundle#end()            " required
    filetype plugin indent on    " required

" => Colors and text

    set background=dark
    syntax enable
    set encoding=utf-8

    " gruvbox settings
    let g:gruvbox_contrast_dark='hard' " must be set first (no explanation)
    colorscheme gruvbox
    let g:airline_theme='base16_gruvbox_dark_hard'

" => Set default behaviour for key presses

    set backspace=indent,eol,start " Allows bs to remove indents, eol's and previously inserted text

    set tabstop=4 " size of tabs in spaces
    set softtabstop=4 " number of spaces removed when tab is backspaced
    set expandtab " tabs are spaces
    set shiftwidth=4 " '>' or '<' in visual mode is 4 spaces

    set clipboard=unnamedplus

    " Let's save undo info!
    if !isdirectory($HOME."/.vim")
        call mkdir($HOME."/.vim", "", 0770)
    endif
    if !isdirectory($HOME."/.vim/undo-dir")
        call mkdir($HOME."/.vim/undo-dir", "", 0700)
    endif
    set undofile " Maintains undo history between settings
    set undodir=~/.vim/undo-dir " set where to save undos

    set noesckeys " In insert mode, don't check <ESC> as part of a longer function, instant escape from insert mode

" => UI Config
    set number relativenumber
    set cursorline " enables line highlighting
    set showmatch " highlights matching {[()]}
    set wildmenu
    set wildmode=longest,full
    set wildignorecase
    set shortmess+=I " disables splash screen on startup
    set shortmess+=A " disables swap file warning
    set breakindent " wrapped text is indented
    set breakindentopt=shift:4 " indented wrapped text wrapped with a 4 space indent
    set autoindent " apply prev line indent to line below
    set smartindent " adds automatic indenting after things like {
    set cpoptions+=n " when text wraps, does not highlight indents - create some wrapped text to see - 'compatible-options'
    set belloff=all " disables bell sound
    set laststatus=2 " status bar always enabled in last window
    set autoread " when a change is detected to a file outside of the VIM session, auto reload
    set shiftround " rounds indenting to the nearest 'shiftwidth'

    set hlsearch " turns search highlighting on
    set incsearch " search as characters are entered
    set ignorecase " case insensitive searching

    " Apparently this makes cursor block in command mode and line in
    " insert mode
    " https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-Functions-using-CSI-_-ordered-by-the-final-character_s_
    " CSI Ps SP q
    "   Set cursor style (DECSCUSR), VT520.
    "     Ps = 0  ⇒  blinking block.
    "     Ps = 1  ⇒  blinking block (default).
    "     Ps = 2  ⇒  steady block.
    "     Ps = 3  ⇒  blinking underline.
    "     Ps = 4  ⇒  steady underline.
    "     Ps = 5  ⇒  blinking bar, xterm.
    "     Ps = 6  ⇒  steady bar, xterm.
    "https://vimhelp.org/term.txt.html#t_TI
    " t_SI start insert
    " t_EI end insert
    let &t_SI.="\e[6 q"
    let &t_EI.="\e[2 q"

    " Airline settings
        let g:airline#extensions#tabline#enabled=1 " applies airline style to tabs (esp. nice in gvim)
        let g:airline#extensions#branch#empty_message='NBD' " fugitive functionality: no branch detected
        let g:airline#extensions#syntastic#enabled=0 " disables syntastic integration - superfluous
        " controls layout, a=mode, b=branch, z=currposition, x=filetype, y=encoding, c=filepath
        let g:airline#extensions#default#layout=[
            \ [ 'a', 'b', 'z', 'x' ],
            \ [ 'y', 'c' ]
            \ ]
        let g:airline#extensions#tagbar#enabled=1 " enables tagbar functionality
        let g:airline#extensions#tagbar#flags = 'f' " Displays the full hierarchy of the tag in airline
        let g:airline_detect_spell=0 " disables adding 'spelllang' to airline
        set noshowmode " stops --INSERT-- from appearing beneath airline

    " Tagbar settings
        let g:tagbar_compact=1 " gets rid of lines above tagbar
        let g:tagbar_autofocus=1 " autofocus on open

    " netrw settings
        let g:netrw_browse_split=3 " opens files in a new tab
        let g:netrw_liststyle=3 " tree visual style
        let g:netrw_banner=0 " removes banner
        let g:netrw_altv=1 " netrw, on Vexplore, will open on the right 
        let g:netrw_winsize=17 " split only takes up 17% of the screen
        let g:netrw_sort_by=" name" " sorts alphabetically and by case and type, files, folders then folders with a Capital
        let g:netrw_sort_direction=" reverse"

    " VimWiki
        let g:vimwiki_global_ext = 0 " if you change the filetype vimwiki uses, it will only read wiki files as different
        hi VimwikiBold term=bold cterm=bold ctermfg=Cyan guifg=#80a0ff gui=bold | " changes vimwiki *bold* to cyan, and keeps boldness

    " Tmux-navigator settings

" => Remappings

    let mapleader=',' " Where you see <leader> in remaps, replace mentally with this

    " allows for navigating wrapped lines with default controls, look up gj and gk's use
    nnoremap j gj
    nnoremap k gk

    nnoremap <leader><space> :nohlsearch<CR>| " <leader> followed by space turns off highlights from previous search
    map <leader>e :tabe ~/.vimrc<CR>| " Quick open vimrc
    map <leader>t :TagbarToggle<CR>| " Toggles tagbar
    map <leader>n :Lexplore<CR>| " Toggles load/leave netrw - Lexplore takes up whole left side
    " remap ,x to close buffers
    nnoremap <leader>x :bdelete<CR>

    " Ctrl j to move between splits.
    " Overwritten if bind is used for TMUX splits.
    " Pressing c-j at end of split will not go
    " to first split
    nnoremap <C-J> <C-W><C-J>
    nnoremap <C-K> <C-W><C-K>
    nnoremap <C-L> <C-W><C-L>
    nnoremap <C-H> <C-W><C-H>

    " I regularly make mistakes when exiting or saving. These attempt to stop
    " that
        " Wq is not automatically mapped, map to update
        command! Wq wq
        " Same for Q
        command! Q q
        " map W to update
        command! W w
        " remap nn to escape in insert mode
        inoremap <leader>i <esc>
        " remap w to <leader>w
        nnoremap <leader>w :w

    " => NETRW
        " This function allows calling shift-V to highlight files in netrw, and
        " call j to go down and highlight more as a group, and then call T to open
        " all the files at once
        function! s:show_documentation()
          if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
          else
            call CocAction('doHover')
          endif
        endfunction

        function! NetrwOpenMultiTab(current_line,...) range
            " Get the number of lines.
            let n_lines= a:lastline - a:firstline + 1

            " This is the command to be built up.
            let command="normal "

            " Iterator.
            let i=1

            " Virtually iterate over each line and build the command.
            while i < n_lines
                let command .= "tgT:" . ( a:firstline + i ) . "\<CR>:+tabmove\<CR>"
                let i += 1
            endwhile
            let command .= "tgT"

            " Restore the Explore tab position.
            if i != 1
                let command .= ":tabmove -" . ( n_lines - 1 ) . "\<CR>"
            endif

            " Restore the previous cursor line.
            let command .= ":" . a:current_line  . "\<CR>"

            " Check function arguments
            if a:0 > 0
                if a:1 > 0 && a:1 <= n_lines
                    " The current tab is for the nth file.
                    let command .= ( tabpagenr() + a:1 ) . "gt"
                else
                    " The current tab is for the last selected file.
                    let command .= (tabpagenr() + n_lines) . "gt"
                endif
            endif
            " The current tab is for the Explore tab by default.

            " Execute the custom command.
            execute command
        endfunction

        " Define mappings.
        augroup NetrwOpenMultiTabGroup
        autocmd!
        autocmd Filetype netrw vnoremap <buffer> <silent> <expr> t ":call NetrwOpenMultiTab(" . line(".") . "," . "v:count)\<CR>"
        autocmd Filetype netrw vnoremap <buffer> <silent> <expr> T ":call NetrwOpenMultiTab(" . line(".") . "," . (( v:count == 0) ? '' : v:count) . ")\<CR>"
        augroup END

    " When moving between windows, VIM will go right until no more right
    " windows, and then stay there, this allows it to wrap around to the first
    " window on the left
    " ATM doesn't work with C-J remappings
    "
    function! s:GotoNextWindow( direction, count )
      let l:prevWinNr = winnr()
      execute a:count . 'wincmd' a:direction
      return winnr() != l:prevWinNr
    endfunction

    function! s:JumpWithWrap( direction, opposite )
      if ! s:GotoNextWindow(a:direction, v:count1)
        call s:GotoNextWindow(a:opposite, 999)
      endif
    endfunction

    nnoremap <silent> <C-w>h :<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
    nnoremap <silent> <C-w>j :<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
    nnoremap <silent> <C-w>k :<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
    nnoremap <silent> <C-w>l :<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
    nnoremap <silent> <C-w><Left> :<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
    nnoremap <silent> <C-w><Down> :<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
    nnoremap <silent> <C-w><Up> :<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
    nnoremap <silent> <C-w><Right> :<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
