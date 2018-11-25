augroup buffestloclist
  autocmd!
  autocmd BufWritePost <buffer> call buffest#write_loclist()
  autocmd BufEnter <buffer> call buffest#read_loclist()
augroup END

setlocal bufhidden=delete
setlocal nobuflisted

" vim:set et sw=2 ts=2 fdm=marker:
