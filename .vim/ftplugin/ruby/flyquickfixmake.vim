setlocal makeprg=rvm\ 1.9.3\ do\ ruby\ -cdw\ %
setlocal errorformat=%f:%l:%m
"setlocal shellpipe=2>&1\ >

compiler ruby

if !exists("g:ruby_flyquickfixmake")
"  let g:ruby_flyquickfixmake = 1
"  au BufWritePost *.rb silent make %
endif
