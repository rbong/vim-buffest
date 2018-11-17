augroup buffestreg
  autocmd!
  autocmd BufWritePost <buffer> call buffest#writereg()
  autocmd BufEnter <buffer> call buffest#readreg()
  autocmd BufNewFile,BufRead @* call buffest#adapt_buffer()
augroup END

setlocal bufhidden=delete
setlocal nobuflisted
