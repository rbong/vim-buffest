augroup buffestqflist
  autocmd!
  autocmd BufWritePost <buffer> call buffest#writeqflist()
  autocmd BufEnter <buffer> call buffest#readqflist()
augroup END

setlocal bufhidden=delete
setlocal nobuflisted

" vim:set et sw=2 ts=2 fdm=marker:
