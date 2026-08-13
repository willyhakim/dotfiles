" ~/.vimrc — managed by github.com/willyhakim/dotfiles (stow package: vim)
"
" Tracked as-is. Note this is pure Vundle scaffolding with an EMPTY plugin
" list — it bootstraps a plugin manager to manage zero plugins. See
" legacy/NOTES.md; worth either adding real plugins or dropping Vundle.
"
" Vundle itself is not vendored here. Install with:
"   git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim

set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
