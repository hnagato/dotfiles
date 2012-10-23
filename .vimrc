" neobundle {{{
set nocompatible
filetype off
filetype plugin indent off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

NeoBundle 'genutils'
NeoBundle 'netrw.vim'
NeoBundle 'smartword'
NeoBundle 'smartchr'
NeoBundle 'YankRing.vim'
NeoBundle 'AutoClose'

NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'kana/vim-textobj-indent'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-line'
NeoBundle 'othree/html5.vim'
NeoBundle 'othree/eregex.vim'
NeoBundle 'thinca/vim-template'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'tyru/urilib.vim'
NeoBundle 'vim-scripts/L9'
NeoBundle 't9md/vim-textmanip'
NeoBundle 'quickhl.vim'
NeoBundle 'vim-jp/vimdoc-ja'
NeoBundle 'sudo.vim'

" html
NeoBundle 'ZenCoding.vim'

" javascript & node
NeoBundle 'IndentAnything'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'teramako/jscomplete-vim'

" errormarker
NeoBundle 'errormarker.vim'

" ruby
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'tpope/vim-rails'

" unite
NeoBundle 'Shougo/unite.vim'
NeoBundle 'h1mesuke/unite-outline'
NeoBundle 'tsukkee/unite-help'
NeoBundle 'thinca/vim-ref'

" comment
NeoBundle 'tyru/caw.vim'

" Statusline
NeoBundle 'Lokaltog/vim-powerline'

" align
NeoBundle 'h1mesuke/vim-alignta'

" syntax
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'scrooloose/syntastic'

" tree
NeoBundle 'scrooloose/nerdtree'

" gist
NeoBundle 'mattn/gist-vim'
NeoBundle 'mattn/webapi-vim'

" nginx
NeoBundle 'chase/nginx.vim'

" Rooter
NeoBundle 'airblade/vim-rooter'

" Obsolete
"NeoBundle 'scrooloose/nerdcommenter'
"NeoBundle 'vim-scripts/AutoComplPop'
"NeoBundle 'The-NERD-tree'
"NeoBundle 'FuzzyFinder'


filetype plugin indent on

" }}}

" base {{{
" set autochdir
set noswapfile
set nobackup
" .viminfo の上限設定
set viminfo='50,<1000,s100,\"50
if has('viminfo')
  set vi^=!
endif
set history=1000

" view
set laststatus=2
set cmdheight=1
set ambiwidth=double
set display+=lastline
set number
set ruler
set lazyredraw
set modeline
set modelines=10
set showcmd
set scrolloff=5
set noequalalways
set splitbelow
set splitright

" indedent
set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0
set autoindent
set nosmartindent
set nocindent
set formatoptions+=mM
set backspace=indent,eol,start

"set textwidth=0
set nowrap

set ignorecase
set smartcase
set wrapscan
set incsearch
set hlsearch

let loaded_matchparen = 1
"set showmatch
set nrformats-=octal
set hidden
set autoread

set encoding=utf-8
set termencoding=utf-8
"set fileencodings=guess,ucs-bom,latin1,iso-2022-jp-3,utf-8,euc-jisx0213,euc-jp
set fileencodings=fileencodings=iso-2022-jp,utf-8,cp932,euc-jp,default,latin1
set fileformats=unix,dos,mac

set title
set wildmode=list:longest

" Hilight cursor-line {{{
set cursorline cursorcolumn
 augroup cch
   autocmd! cch
   autocmd WinLeave * set nocursorline nocursorcolumn
   autocmd WinEnter,BufRead * set cursorline cursorcolumn
 augroup END
" }}}

"set helpfile=$VIMRUNTIME/doc/help.txt
set helplang=ja,en

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" persistent_undo {{{
" http://vim-users.jp/2010/07/hack162/
if has('persistent_undo')
  set undodir=~/.vimundo
  augroup vimrc-undofile
    autocmd!
    autocmd BufReadPre ~/* setlocal undofile
  augroup END
endif
" }}}

"set tags
"if has("autochdir")
"  set autochdir
"  set tags=tags;
"else
"  set tags=./tags,./../tags,./*/tags,./../../tags,./../../../tags,./../../../../tags,./../../../../../tags
"endif
set tags=~/.tags,tags

syntax enable

" 無名レジスタに入るデータを、*レジスタにも入れる。
"set clipboard+=unnamed
" }}}

" listchars {{{
scriptencoding utf-8
set list
set listchars=tab:»\ ,extends:<,trail:\ ,eol:¬
"highlight SpecialKey cterm=underline ctermfg=darkgray

function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=red
  silent! match ZenkakuSpace /　\+/
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd VimEnter,BufEnter * call ZenkakuSpace()
  augroup END
endif
" }}}

" colors {{{
if &term =~ "256color"
  set t_Co=256
  "colorscheme z256
  "colorscheme lucius_mod
  "colorscheme proton
  "colorscheme pyte

  if $COLORFGBG =~ "11;15" || $COLORFGBG =~ "12;8"
    colorscheme solarized
    let g:solarized_termcolors=256
    let g:solarized_termtrans=1
    let g:solarized_contrast="high"
    let g:solarized_visibility="high"

  else
    colorscheme Tomorrow-Night

  endif

" 16 Colors
else
  set t_Co=16
  set t_Sf=[3%dm
  set t_Sb=[4%dm
endif
" }}}

" autocmd {{{

" バッファ切替時にredraw!"
au BufEnter * redraw!

" 前回終了したカーソル行に移動
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" git のコミットログは72文字で折り返す
" refs. http://keijinsonyaban.blogspot.com/2011/01/git.html
au FileType gitcommit :set textwidth=72

" gf で探すパス
"au FileType html :setlocal path+=W:/project/sample/WebContent
au FileType html setlocal includeexpr=substitute(v:fname,'^\\/','','') | setlocal path+=;/
au FileType jsp  setlocal includeexpr=substitute(v:fname,'^\\/','','') | setlocal path+=;/

" ↓キーでシンタックスチェック
au FileType html :compiler tidy
au FileType html :setlocal makeprg=tidy\ -raw\ -quiet\ -errors\ --gnu-emacs\ yes\ \"%\"
au FileType html :map <down> <esc>:make<cr>
au FileType css :compiler css
au FileType css :map <down> <esc>:make<cr>
"au FileType javascript :compiler javascriptlint
"au FileType javascript :map <down> <esc>:make<cr>
au FileType php        :map <down> <esc>:!php  -l %<cr>
au FileType perl       :map <down> <esc>:!perl -c %<cr>
au FileType ruby       :map <down> <esc>:!ruby -c %<cr>
au FileType javascript :map <down> <esc>:make %<cr>

" ↑キーで実行
au FileType php        :map <up> <esc>:!php  %<cr>
au FileType perl       :map <up> <esc>:!perl %<cr>
au FileType ruby       :map <up> <esc>:!ruby %<cr>
au FileType javascript :map <up> <esc>:!node %<cr>

" filetype aliases {{{
" http://vim-users.jp/2010/04/hack138/
augroup FiletypeAliases
  autocmd!
  autocmd FileType js  set filetype=javascript ts=4 sw=4 sts=4 noet
  autocmd FileType ejs set filetype=html       ts=4 sw=4 sts=4 et
  autocmd FileType cf  set filetype=coffee     ts=2 sw=2 sts=2 et
augroup END
" }}}

" #! で始まるファイルには保存時に実行権限を付ける
au BufWritePost * :call AddExecmod()
function AddExecmod()
  let line = getline(1)
  if strpart(line, 0, 2) == "#!"
    call system("chmod +x ". expand("%"))
  endif
endfunction

" tabstop, shiftwidth, softtabstop
au FileType *     set ts=4 sw=4 sts=4 noet
au FileType html  set ts=4 sw=4 sts=4 et
au FileType xhtml set ts=4 sw=4 sts=4 et
au FileType rhtml set ts=4 sw=4 sts=4 et
au FileType ruby  set ts=2 sw=2 sts=2 et
au FileType yaml  set ts=2 sw=2 sts=2 et
au FileType sh    set ts=2 sw=2 sts=2 et
au FileType zsh   set ts=2 sw=2 sts=2 et
au FileType txt   set ts=2 sw=2 sts=2 et
au FileType vim   set ts=2 sw=2 sts=2 et
au FileType json  set ts=4 sw=4 sts=4 et
au FileType ejs   set ts=4 sw=4 sts=4 et
au FileType js    set ts=4 sw=4 sts=4 et
au FileType javascript set ts=4 sw=4 sts=4 et

au FileType git setlocal foldlevel=99

" テキストファイルは markdown 形式で開く
au BufNewFile,BufReadPost **/*.txt set ft=markdown

" json
au BufNewFile,BufRead,BufEnter **/*.json setfiletype json
" ejs
au BufNewFile,BufRead,BufEnter **/*.ejs setfiletype html
" markdown
au BufNewFile,BufRead,BufEnter **/*.md setfiletype markdown

" crontab -e と chpass ではバックアップ作らない
au BufWrite /private/tmp/crontab.* set nowritebackup
au BufWrite /private/etc/pw.* set nowritebackup

" makeとかgrepとかvimgrepの後に勝手に cw
au QuickfixCmdPost make,grep,grepadd,vimgrep if len(getqflist()) != 0 | copen | endif

" BinaryXXD {{{
augroup BinaryXXD
  autocmd!
  autocmd BufReadPre  *.bin let &binary =1
  autocmd BufReadPost * if &binary | silent %!xxd -g 1
  autocmd BufReadPost * set ft=xxd | endif
  autocmd BufWritePre * if &binary | %!xxd -r | endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END
" }}}

" }}}

" mappings {{{

" Y で * レジスタに yank (=clipboard)
vnoremap Y "*y

" 不可視文字の表示切り替え
nnoremap <Space>l :<C-u>set list!<Return>
" 行番号表示の切り替え
nnoremap <Space>n :<C-u>set nu!<Return>

" <Space>q で強制終了
nnoremap <Space>q :<C-u>q!<Return>

" smartword
map w  <Plug>(smartword-w)
map b  <Plug>(smartword-b)
map e  <Plug>(smartword-e)
map ge <Plug>(smartword-ge)
noremap W  w
noremap B  b
noremap E  e
noremap gE ge

" ESC*2 でハイライトやめる
nnoremap <Esc><Esc> :<C-u>set nohlsearch<Return>
nnoremap / :<C-u>set hlsearch<Return>/
nnoremap ? :<C-u>set hlsearch<Return>?
nnoremap * :<C-u>set hlsearch<Return>*
nnoremap # :<C-u>set hlsearch<Return>#

" command mode 時 tcsh風のキーバインドに
cmap <C-A> <Home>
cmap <C-F> <Right>
cmap <C-B> <Left>
cmap <C-D> <Delete>
cmap <Esc>b <S-Left>
cmap <Esc>f <S-Right>

" command mode でファイルパスを保管
" expand path
cmap <C-x> <C-r>=expand('%:p:h')<CR>/
" expand file (not ext)
cmap <C-z> <C-r>=expand('%:p:r')<CR>

" 表示行単位で行移動する
nmap j gj
nmap k gk
vmap j gj
vmap k gk

" インデント＋改行
imap <C-j> <ESC>==o

" フレームサイズを怠惰に変更する
map <kPlus> <C-W>+
map <kMinus> <C-W>-

" 矢印なキーでバッファ移動
map <Right> :bn<CR>
map <Left> :bp<CR>

" *とか#とかした時に次の検索候補に飛ぶな
nmap * *N
nmap # #N

" ,e でコマンドとして実行
nmap ,e :execute '!' &ft ' %'<CR>

" YankRing.vim
nmap ,y :YRShow<CR>

" ChangeLog
nmap ,m :e ~/ChangeLog<CR>

" hlsearch切替
nmap ,h :set hlsearch!<CR>

" ペーストしたいときに使うアレ
nmap ,P :r!cat<CR>

" バッファ関連
nnoremap ,c :new<CR>
nnoremap ,k :bd!<CR>
nnoremap ,q :only<CR>

" C-]でtjと同等の効果
nmap <C-]> g<C-]>

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" encoding
nmap ,U :set encoding=utf-8<CR>
nmap ,E :set encoding=euc-jp<CR>
nmap ,S :set encoding=cp932<CR>
nmap ,J :set fileencoding=iso-2022-jp<CR>

" fileencoding
nmap ,fU :set fileencoding=utf-8<CR>
nmap ,fE :set fileencoding=euc-jp<CR>
nmap ,fS :set fileencoding=cp932<CR>
nmap ,fJ :set fileencoding=iso-2022-jp<CR>

" fileformat
nmap ,fu :set fileformat=unix<CR>
nmap ,fd :set fileformat=dos<CR>
nmap ,fm :set fileformat=mac<CR>

" emacs の tabify みたいなの
nmap <Space>st :set noexpandtab<CR>:retab!<CR>
nmap <Space>ss :set expandtab<CR>:retab!<CR>

" switch indent depth
nmap <Space>2 :set sts=2 ts=2 sw=2<CR>
nmap <Space>4 :set sts=4 ts=4 sw=4<CR>

" redraw!
nmap ,r :redraw!<CR>

" open で開く
nmap <silent> ,o :silent !open "%:p"<CR>

" 連番作成
command! -count -nargs=1 ContinuousNumber let c = col('.')|for n in range(1, <count>?<count>-line('.'):1)|exec 'normal! j' . n . <q-args>|call cursor('.', c)|endfor 
vnoremap <silent> <C-a> :ContinuousNumber <C-a><CR>
vnoremap <silent> <C-x> :ContinuousNumber <C-x><CR>

" 検索時に勝手にエスケープさせる
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ?  getcmdtype() == '?' ? '\?' : '?'

" Write with sudo
cnoremap w!! w !sudo tee % >/dev/null

" Better command-line editing
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" toggle nerdtree
nnoremap <F4> :<C-u>NERDTreeToggle<CR>

" caw.vim {{{2
nmap <Space>/ <Plug>(caw:I:toggle)
vmap <Space>/ <Plug>(caw:I:toggle)
" }}}

" alignta.vim {{{2
let g:unite_source_alignta_preset_arguments = [
      \ ["Align at '='", '=>\='],  
      \ ["Align at ':'", '01 :'],
      \ ["Align at '|'", '|'   ],
      \ ["Align at ')'", '0 )' ],
      \ ["Align at ']'", '0 ]' ],
      \ ["Align at '}'", '}'   ],
      \]

let s:comment_leadings = '^\s*\("\|#\|/\*\|//\|<!--\)'
let g:unite_source_alignta_preset_options = [
      \ ["Justify Left",      '<<' ],
      \ ["Justify Center",    '||' ],
      \ ["Justify Right",     '>>' ],
      \ ["Justify None",      '==' ],
      \ ["Shift Left",        '<-' ],
      \ ["Shift Right",       '->' ],
      \ ["Shift Left  [Tab]", '<--'],
      \ ["Shift Right [Tab]", '-->'],
      \ ["Margin 0:0",        '0'  ],
      \ ["Margin 0:1",        '01' ],
      \ ["Margin 1:0",        '10' ],
      \ ["Margin 1:1",        '1'  ],
      \
      \ 'v/' . s:comment_leadings,
      \ 'g/' . s:comment_leadings,
      \]
unlet s:comment_leadings
nnoremap <silent> [unite]a :<C-u>Unite alignta:options<CR>
xnoremap <silent> [unite]a :<C-u>Unite alignta:arguments<CR>
vnoremap <Space>a          :Alignta =
" }}}

" }}}

" folding {{{
" set viewdir=~/.vim/vimview
" au BufWritePost * mkview
" au BufReadPost * loadview

au FileType *     :set fdm=marker
au FileType xhtml :set fdm=syntax
au FileType html  :set fdm=syntax
au FileType xml   :set fdm=syntax

" Set a nicer foldtext function
" refs. http://vim.wikia.com/wiki/Customize_text_for_closed_folds
set foldtext=MyFoldText()
function! MyFoldText()
  let line = getline(v:foldstart)
  if match( line, '^[ \t]*\(\/\*\|\/\/\)[*/\\]*[ \t]*$' ) == 0
    let initial = substitute( line, '^\([ \t]\)*\(\/\*\|\/\/\)\(.*\)', '\1\2', '' )
    let linenum = v:foldstart + 1
    while linenum < v:foldend
      let line = getline( linenum )
      let comment_content = substitute( line, '^\([ \t\/\*]*\)\(.*\)$', '\2', 'g' )
      if comment_content != ''
        break
      endif
      let linenum = linenum + 1
    endwhile
    let sub = initial . ' ' . comment_content
  else
    let sub = line
    let startbrace = substitute( line, '^.*{[ \t]*$', '{', 'g')
    if startbrace == '{'
      let line = getline(v:foldend)
      let endbrace = substitute( line, '^[ \t]*}\(.*\)$', '}', 'g')
      if endbrace == '}'
        let sub = sub.substitute( line, '^[ \t]*}\(.*\)$', '...}\1', 'g')
      endif
    endif
  endif
  let n = v:foldend - v:foldstart + 1
  let info = " " . n . " lines"
  let sub = sub . "                                                                                                                  "
  let num_w = getwinvar( 0, '&number' ) * getwinvar( 0, '&numberwidth' )
  let fold_w = getwinvar( 0, '&foldcolumn' )
  let sub = strpart( sub, 0, winwidth(0) - strlen( info ) - num_w - fold_w - 1 )
  return sub . info
endfunction

" }}}

" neocomplcache {{{

" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
    \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
imap <C-k> <Plug>(neocomplcache_snippets_expand)
smap <C-k> <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g> neocomplcache#undo_completion()
inoremap <expr><C-l> neocomplcache#complete_common_string()

" Snippets dir
let g:neocomplcache_snippets_dir = '~/.vim/snippets'
" SuperTab like snippets behavior.
imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"

" Recommended key-mappings.
" <CR>: close popup and save indent.
"inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
inoremap <expr><C-j>  neocomplcache#smart_close_popup() . "\<CR>"
" <TAB>: completion.
"inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS>  neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplcache#close_popup()
inoremap <expr><C-e> neocomplcache#cancel_popup()

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1

" インクルードパスの指定
let g:neocomplcache_include_paths = {
      \ 'ruby' : '/usr/local/lib/ruby/1.9.1'
      \ }

" インクルード文のパターン指定
let g:neocomplcache_include_patterns = {
      \ 'cpp'  : '^\s*#\s*include',
      \ 'ruby' : '^\s*require',
      \ 'perl' : '^\s*use',
      \ }

"インクルード先のファイル名の解析パターン
let g:neocomplcache_include_exprs = {
      \ 'ruby' : substitute(substitute(v:fname,'::','/','g'),'$','.rb','')
      \ }

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
" autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType javascript setlocal omnifunc=jscomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
" let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
" }}}

" fugitive {{{
" git-status での key-mappings
"  : カーソル下にあるファイルを edit
" -: カーソル下にあるファイルを git add
" p: カーソル下にあるファイルを git add -p
" D: カーソル下にあるファイルを git diff[ --cached]
" C: git commit
nnoremap <Space>gs :<C-u>Gstatus<Enter>
nnoremap <Space>gr :<C-u>Gread<Enter>
nnoremap <Space>gc :<C-u>Gcommit -v<Enter>
nnoremap <Space>gd :<C-u>Gdiff<Enter>
nnoremap <Space>gb :<C-u>Gblame<Enter>
nnoremap <Space>gg :<C-u>Ggrep 
nnoremap <Space>gm :<C-u>Gmove
nnoremap <Space>gl :<C-u>Glog<Enter>
nnoremap <Space>gw :<C-u>Gwrite<Enter>
" }}}

" git-diff-aware version of gf commands. {{{
" refs http://labs.timedia.co.jp/2011/04/git-diff-aware-gf-commands-for-vim.html
nnoremap <expr> gf  <SID>do_git_diff_aware_gf('gf')
nnoremap <expr> gF  <SID>do_git_diff_aware_gf('gF')
nnoremap <expr> <C-w>f  <SID>do_git_diff_aware_gf('<C-w>f')
nnoremap <expr> <C-w><C-f>  <SID>do_git_diff_aware_gf('<C-w><C-f>')
nnoremap <expr> <C-w>F  <SID>do_git_diff_aware_gf('<C-w>F')
nnoremap <expr> <C-w>gf  <SID>do_git_diff_aware_gf('<C-w>gf')
nnoremap <expr> <C-w>gF  <SID>do_git_diff_aware_gf('<C-w>gF')
function! s:do_git_diff_aware_gf(command)
  let target_path = expand('<cfile>')
  if target_path =~# '^[ab]/'  " with a peculiar prefix of git-diff(1)?
    if filereadable(target_path) || isdirectory(target_path)
      return a:command
    else
      " BUGS: Side effect - Cursor position is changed.
      let [_, c] = searchpos('\f\+', 'cenW')
      return c . '|' . 'v' . (len(target_path) - 2 - 1) . 'h' . a:command
    endif
  else
    return a:command
  endif
endfunction
"}}}

" git-grep {{{
" refs. http://subtech.g.hatena.ne.jp/secondlife/20101129/1291031478
" refs. https://gist.github.com/719707#file_git_grep.vim
function! Ggrep(arg)
  setlocal grepprg=git\ grep\ --no-color\ -n\ $*
  silent execute ':grep '.a:arg
  setlocal grepprg=git\ --no-pager\ submodule\ --quiet\ foreach\ 'git\ grep\ --full-name\ -n\ --no-color\ $*\ ;true'
  silent execute ':grepadd '.a:arg
  silent cwin
  redraw!
endfunction
command! -nargs=1 -complete=buffer Gg call Ggrep(<q-args>)
command! -nargs=1 -complete=buffer Ggrep call Ggrep(<q-args>)
nnoremap <unique> gG :exec ':silent Ggrep ' . expand('<cword>')<CR>
"}}}

" auto reload {{{
" refs. ~/bin/autoreload.rb
if exists('g:browser_auto_reload')
  finish
endif
command -nargs=0 AutoReload :call AutoReload()
function! AutoReload()
  if exists('g:browser_auto_reload')
    autocmd! browserautoreload
    unlet g:browser_auto_reload
    echo "\"Browser-Autoreload\" of augroup has been deleted."
  else
    augroup browserautoreload
      autocmd BufWritePost *.xhtml,*.html,*.htm,*.erb,*.jsp,*.js,*.ejs,*.css silent exec "!autoreload.rb"
    augroup END
    let g:browser_auto_reload=1
  endif
endfunction
" }}}

" Allargs.vim {{{
" refs. http://d.hatena.ne.jp/secondlife/20060203/113897866re
" ex)
" :Allargs %s/foo/bar/ge|update
" 使う時。foo を bar に置換しまくる。
" :Allargs %s/foo/bar/ge|update
" eオプションをつけないと foo が無いというメッセージがのんびり表示されて、いつま
" でたっても置換が終わらないので気をつけよう(それに気づかずに密かにハマった)
" コマンドは | で連続で実行できて、update は変更のあったバッファだけを保存。と。
" カレントの *.cpp を置換する場合は予め、
" :ar *.cpp
" ってやっとくと全部読み込まれる。
" 確認するには
" :ar
function! Allargs(command)
  let i = 0
  while i < argc()
    if filereadable(argv(i))
      execute "e " . argv(i)
      execute a:command
    endif
    let i = i + 1
  endwhile
endfunction
command! -nargs=+ -complete=command Allargs call Allargs(<q-args>)
" }}}

" HtmlEscape & Unescape {{{
function! s:HtmlEscape()
  silent s/&/\&amp;/eg
  silent s/</\&lt;/eg
  silent s/>/\&gt;/eg
endfunction
function! s:HtmlUnEscape()
  silent s/&lt;/</eg
  silent s/&gt;/>/eg
  silent s/&amp;/\&/eg
endfunction
vnoremap <silent> <space>he :call <SID>HtmlEscape()<CR>
vnoremap <silent> <space>hu :call <SID>HtmlUnEscape()<CR>
" }}}

" netrw {{{ 
" netrw-ftp
let g:netrw_ftp_cmd="netkit-ftp"
" netrw-http
let g:netrw_http_cmd="wget -qO"

" via. http://blog.tojiru.net/article/234400966.html
" netrwは常にtree view
let g:netrw_liststyle = 3
" CVSと.で始まるファイルは表示しない
"let g:netrw_list_hide = 'CVS,\(^\|\s\s\)\zs\.\S\+'
let g:netrw_list_hide = '\.svn'
" 'v'でファイルを開くときは右側に開く。(デフォルトが左側なので入れ替え)
let g:netrw_altv = 1
" 'o'でファイルを開くときは下側に開く。(デフォルトが上側なので入れ替え)
let g:netrw_alto = 1
" }}}

" Grep {file} ... {pattern} {{{
command! -complete=file -nargs=+ Grep  call s:grep([<f-args>])
function! s:grep(args)
  execute 'vimgrep' '/'.a:args[-1].'/' join(a:args[:-2])
endfunction
" }}}

" unite.vim {{{
"let g:unite_winheight=15
let g:unite_enable_start_insert   = 1
let g:unite_source_file_mru_limit = 200

nnoremap [unite] <Nop>
nmap <Space>u [unite]
nnoremap <silent> [unite]e :<C-u>UniteWithBufferDir -buffer-name=files file buffer file_mru bookmark<CR>
nnoremap <silent> [unite]f :<C-u>Unite -buffer-name=files buffer file file_mru bookmark<CR>
nnoremap <silent> [unite]m :<C-u>Unite -buffer-name=files file_mru<CR>
nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]o :<C-u>Unite outline<CR>
nnoremap <silent> [unite]u :<C-u>Unite source<CR>
nnoremap <silent> [unite]h :<C-u>UniteWithCursorWord help<CR>
nnoremap <silent> [unite]r :<C-u>UniteResume files<CR>
"nnoremap <C-e> :<C-u>Unite -buffer-name=files buffer file file_mru bookmark<CR>

nnoremap <silent> <C-e> :<C-u>UniteWithBufferDir -buffer-name=files file buffer file_mru bookmark<CR>
nnoremap <silent> <C-f> :<C-u>Unite -buffer-name=files buffer<CR>
nnoremap <silent> <C-b> :<C-u>Unite -buffer-name=files file_mru<CR>
" }}}

" open-browser {{{
" refs http://d.hatena.ne.jp/tyru/20100619/git_push_vim_plugins_to_github
nmap <Space>w <Plug>(openbrowser-open)
vmap <Space>w <Plug>(openbrowser-open)
"}}}

" quick fix {{{
if has('mac')
  " Macではデフォルトの'iskeyword'がcp932に対応しきれていないので修正
  set iskeyword=@,48-57,_,128-167,224-235

  " Vimで 保存した UTF-8 なファイルが QuickLook で見られない問題に対処する
  " http://d.hatena.ne.jp/uasi/20110523/1306079612
  au BufWritePost * call SetUTF8Xattr(expand("<afile>"))
  function! SetUTF8Xattr(file)
    let isutf8 = &fileencoding == "utf-8" || ( &fileencoding == "" && &encoding == "utf-8")
    if has("unix") && match(system("uname"),'Darwin') != -1 && isutf8
      call system("xattr -w com.apple.TextEncoding 'utf-8;134217984' '" . a:file . "'")
    endif
  endfunction

  " bracketed paste mode in OSX 10.7 LION
  " refs http://stackoverflow.com/questions/5585129/pasting-code-into-terminal-window-into-vim-on-mac-os-x
  if &term =~ "xterm.*"
    let &t_ti = &t_ti . "\e[?2004h"
    let &t_te = "\e[?2004l" . &t_te
    function XTermPasteBegin(ret)
      set pastetoggle=<Esc>[201~
      set paste
      return a:ret
    endfunction
    map <expr> <Esc>[200~ XTermPasteBegin("i")
    imap <expr> <Esc>[200~ XTermPasteBegin("")
  endif

endif
"}}}

" Rename {{{
" 編集中のファイル名を変更
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))
"}}}

" Textmanip {{{
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-l> <Plug>(textmanip-move-right)
xmap <C-h> <Plug>(textmanip-move-left)
" }}}

" quickhl.vim {{{
nmap <Space>m <Plug>(quickhl-toggle)
xmap <Space>m <Plug>(quickhl-toggle)
nmap <Space>M <Plug>(quickhl-reset)
xmap <Space>M <Plug>(quickhl-reset)
nmap <Space>j <Plug>(quickhl-match)
" }}}

" quickrun.vim {{{
let g:quickrun_config = {}
let g:quickrun_config['markdown'] = {
      \ 'outputter': 'browser'
      \ }
" }}}

" template.vim {{{
autocmd User plugin-template-loaded call s:template_keywords()
function! s:template_keywords()
  %s/@FILE@/\=expand('%:t:r')/g
  %s/@DATE@/\=strftime('%Y-%m-%d')/g
  %s/@YEAR@/\=strftime('%Y')/g
  %s/@AUTHOR@/\=expand('`whoami`')/g
  " And more...
endfunction
" }}}

" Autoclose {{{
let g:autoclose_on = 0
nmap <Leader>x <Plug>ToggleAutoCloseMappings
" }}}

" Powerline {{{
let g:Powerline_symbols = 'fancy'
" let g:Powerline_theme = 'default'
let g:Powerline_colorscheme = 'solarized'
" }}}

" Syntastic {{{
let g:syntastic_mode_map = { 'mode': 'active',
      \ 'active_filetypes': ['ruby', 'sh', 'perl', 'python', 'php', 'javascript', 'xml', 'html', 'css', 'eruby'],
      \ 'passive_filetypes': ['puppet'] }
" }}}

" Rooter {{{
" \cd でカレントディレクトリを移動（デフォルト）
" map <silent> <unique> <Leader>cd <Plug>RooterChangeToRootDirectory
autocmd BufEnter *.rb,*.html,*.haml,*.erb,*.rjs,*.css,*.js,*.java,*.conf,*.jsp,*.sql :Rooter
" cd の代わりに lcd を使う
let g:rooter_use_lcd = 1
" }}}

" obsolete {{{

" statusline {{{
"function! GetB()
"  let c = matchstr(getline('.'), '.', col('.') - 1)
"  let c = iconv(c, &enc, &fenc)
"  return String2Hex(c)
"endfunction
"" :help eval-examples
"" The function Nr2Hex() returns the Hex string of a number.
"func! Nr2Hex(nr)
"  let n = a:nr
"  let r = ""
"  while n
"    let r = '0123456789ABCDEF'[n % 16] . r
"    let n = n / 16
"  endwhile
"  return r
"endfunc
"" The function String2Hex() converts each character in a string to a two
"" character Hex string.
"func! String2Hex(str)
"  let out = ''
"  let ix = 0
"  while ix < strlen(a:str)
"    let out = out . Nr2Hex(char2nr(a:str[ix]))
"    let ix = ix + 1
"  endwhile
"  return out
"endfunc
"set statusline=%<[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%y\ %F%=[%{GetB()}]\ %l,%c%V%8P
"let &statusline = '%=%m%y%{"[".(&fenc!=""?&fenc:&enc).",".&ff."]"}%{"[".neocomplcache#keyword_complete#caching_percent("")."%]"} %3l,%3c %3p%%'
"}}}

" statusline {{{
"set statusline=%{expand('%:p:t')}\ %<\(%{SnipMid(expand('%:p:h'),80-len(expand('%:p:t')),'...')}\)%=\ %m%r%y%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}[%3l,%3c]%{fugitive#statusline()}
"
"function! SnipMid(str, len, mask)
"  if a:len >= len(a:str)
"    return a:str
"  elseif a:len <= len(a:mask)
"    return a:mask
"  endif
"
"  let len_head = (a:len - len(a:mask)) / 2
"  let len_tail = a:len - len(a:mask) - len_head
"
"  return (len_head > 0 ? a:str[: len_head - 1] : '') . a:mask . (len_tail > 0 ? a:str[-len_tail :] : '')
"endfunction

" Screen Buffer 切り替えで screen にファイル名を表示
"if &term =~ "screen"
"  au BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | silent! exe '!echo -n "kvim:%\\"' |
"endif

" }}}

" completion {{{
"set completeopt=menu,preview,menuone
"set complete=.,w,b,u,t,i
"
"set omnifunc=syntaxcomplete#Complete
"imap <C-o> <C-x><C-o>
"imap <C-l> <C-x><C-l>
"
"" 辞書ファイルからの単語補間
"set complete+=k

" obsolete
"au FileType python set omnifunc=pythoncomplete#Complete
"au FileType javascript set omnifunc=javascriptcomplete#CompleteJS
"au FileType html set omnifunc=htmlcomplete#CompleteTags
"au FileType xhtml set omnifunc=htmlcomplete#CompleteTags
"au FileType css set omnifunc=csscomplete#CompleteCSS
"au FileType xml set omnifunc=xmlcomplete#CompleteTags
"au FileType php set omnifunc=phpcomplete#CompletePHP
"au FileType c set omnifunc=ccomplete#Complete
"
"" javascript は . で Omni補完発動
"au FileType javascript :inoremap . .<C-X><C-O>
"" html 系のファイルは </ で Omni補完を発動させる
"au FileType html,xhtml,xml,rhtml,jsp,php :inoremap / /<C-X><C-O>
"
"" 注意: この内容は:filetype onよりも後に記述すること。
"au FileType *
"\   if &l:omnifunc == ''
"\ |   setlocal omnifunc=syntaxcomplete#Complete
"\ | endif

" }}}

" fuzzyfinder.vim {{{
"nnoremap <unique> <silent> <C-e> :FufFileWithCurrentBufferDir!<CR>
"nnoremap <unique> <silent> <C-f> :FufBuffer!<CR>
"nnoremap <unique> <silent> <C-b> :FufMruFile!<CR>
"au FileType fuf nmap <C-c> <ESC>
"let g:fuf_patternSeparator = ' '
"let g:fuf_modesDisable = ['mrucmd']
"let g:fuf_file_exclude = '\v\~$|\.(o|exe|bak|swp|gif|jpg|png|classes)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])'
"let g:fuf_mrufile_exclude = '\v\~$|\.bak$|\.swp|\.howm$|\.(gif|jpg|png)$'
"let g:fuf_mrufile_maxItem = 1000
"let g:fuf_enumeratingLimit = 20
"let g:fuf_keyPreview = '<C-]>'
" }}}

" }}}

" vim: set ft=vim fdm=marker commentstring="%s
