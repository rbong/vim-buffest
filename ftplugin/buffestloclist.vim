augroup buffestloclist
  autocmd!
  autocmd BufWritePost <buffer> call buffest#writeloclist()
  autocmd BufEnter <buffer> call buffest#readloclist()
augroup END

setlocal bufhidden=delete
setlocal nobuflisted

" vim:set et sw=2 ts=2 fdm=marker:
