setlocal dictionary=~/.vim/dict/html.dict
setlocal dictionary+=~/.vim/dict/css.dict
setlocal iskeyword+=-,:

setlocal path+=templates,static
setlocal includeexpr=substitute(v:fname,'^\\/','','')

