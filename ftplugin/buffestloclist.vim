augroup buffestloclist
  autocmd!
  autocmd BufWritePost <buffer> call buffest#writeloclist()
  autocmd BufEnter <buffer> call buffest#readloclist()
augroup END

setlocal bufhidden=delete
setlocal nobuflisted
