augroup buffestreg
  autocmd!
  autocmd BufWritePost <buffer> call buffest#write_reg()
  autocmd BufEnter <buffer> call buffest#read_reg()
augroup END

setlocal bufhidden=delete
setlocal nobuflisted

" vim:set et sw=2 ts=2 fdm=marker:
