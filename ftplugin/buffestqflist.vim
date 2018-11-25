augroup buffestqflist
  autocmd!
  autocmd BufWritePost <buffer> call buffest#write_qflist()
  autocmd BufEnter <buffer> call buffest#read_qflist()
augroup END

setlocal bufhidden=delete
setlocal nobuflisted

" vim:set et sw=2 ts=2 fdm=marker:
