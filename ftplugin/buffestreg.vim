augroup buffestreg
  autocmd!
  autocmd BufWritePost <buffer> call buffest#writereg()
  autocmd BufEnter <buffer> call buffest#readreg()
  autocmd BufNewFile,BufRead @* call buffest#adapt_buffer()
augroup END

setlocal bufhidden=delete
setlocal nobuflisted

" vim:set et sw=2 ts=2 fdm=marker:
