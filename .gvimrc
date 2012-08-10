set columns=120
set lines=80
set wrap

set guifont=Inconsolata_for_Powerline:h14
set guifontwide=M+_2m_regular:h14

scriptencoding utf-8
set nolist
augroup highlightIdeographicSpace
  autocmd!
  autocmd Colorscheme * highlight IdeographicSpace term=underline ctermbg=DarkGray "guibg=#333333
  autocmd VimEnter,WinEnter * match IdeographicSpace /　/
augroup END
"highlight SpecialKey gui=underline guifg=darkgray
"colorscheme Inkpot
"colorscheme lucius_mod
set bg=dark
colorscheme solarized

set noeb
set vb t_vb

set guicursor=a:blinkon0
set guioptions-=T " no icons on the top of window
set guioptions-=r " no right-hand scrollbar at any time
set guioptions-=l " no left-hand scrollbar at any time
"set transparency=5
set imdisable
set iminsert=1
set number


" <F2>, <F3> で background を切り替える - gVim のみ
nnoremap <F2> :<C-u>set bg=light<Return>
nnoremap <F3> :<C-u>set bg=dark<Return>

" macvim specific {{{
if has('gui_running') && has('macvim')
  nnoremap <SwipeLeft> :bp
  nnoremap <SwipeRight> :bn
endif
" }}}

" http://vim-users.jp/2011/10/hack234/ {{{
augroup hack234
  autocmd!
  if has('mac')
    autocmd FocusGained * set transparency=0
    autocmd FocusLost * set transparency=25
  endif
augroup END
" }}}

"set fuoptions=maxvert,maxhorz
"au GUIEnter * set fullscreen

" vim: foldmethod=marker
