let g:buffest_supported_registers = map(range(char2nr('a'),char2nr('z')),'nr2char(v:val)') + ['"', '*', '+']

let g:buffest_unsupported_register_error = 'buffest: E1: register not supported'

function! buffest#tmpname(name)
  let l:tmp = '/'.$TMP.'/buffest/'
  if $TMP == ""
    let l:tmp = '/tmp/buffest/'
  endif
  call mkdir(l:tmp, 'p')
  return l:tmp.a:name
endfunction

function! buffest#readreg()
  if !exists('b:buffest_regname')
    return
  endif
  let l:regname = tolower(b:buffest_regname)
  call writefile(getreg(l:regname, 1, 1), expand('%:p'))
  edit!
endfunction

function! buffest#writereg()
  if !exists('b:buffest_regname')
    return
  endif
  let l:regname = tolower(b:buffest_regname)
  call setreg(l:regname, readfile(expand('%')))
endfunction

function! buffest#regcomplete(...)
  return g:buffest_supported_registers
endfunction

function! buffest#regdo(regname, cmd)
  let l:regname = tolower(a:regname)
  if index(g:buffest_supported_registers, l:regname) < 0
    throw g:buffest_unsupported_register_error
  endif
  exec a:cmd . ' ' . buffest#tmpname('@'.l:regname)
  let b:buffest_regname = l:regname
  set filetype=buffestreg
  edit!
endfunction

function! buffest#escseparator(string)
  return substitute(a:string, ':', '\\:', 'g')
endfunction

function! buffest#unescseparator(string)
  return substitute(a:string, '\\:', ':', 'g')
endfunction

function! buffest#readlist(list)
  let l:filelist = []
  if !len(a:list)
    let l:filelist = ["{'filename': '', 'module': '', 'lnum': '', 'pattern': '', 'col': 0, 'vcol': 0, 'nr': -1, 'text': '', 'type': '', valid: 1}"]
  else
    for l:item in a:list
      let l:item['filename'] = bufname(l:item['bufnr'])
      unlet l:item['bufnr']
      let l:filelist += [string(l:item)]
    endfor
  endif
  call writefile(l:filelist, expand('%:p'))
  edit!
endfunction

function! buffest#readqflist()
  return buffest#readlist(getqflist())
endfunction

function! buffest#readloclist()
  return buffest#readlist(getloclist('.'))
endfunction

function buffest#writelistfile()
  let contents = []
  for line in readfile(expand('%'))
    execute 'let contents += ['.buffest#unescseparator(line).']'
  endfor
  return contents
endfunction

function buffest#writeqflist()
  call setqflist(buffest#writelistfile())
endfunction

function buffest#writeloclist()
  call setloclist('.', buffest#writelistfile())
endfunction

function buffest#qflistdo(cmd)
  exec a:cmd . ' ' . buffest#tmpname('[]q')
  set filetype=buffestqflist
  edit!
endfunction

function buffest#loclistdo(cmd)
  exec a:cmd . ' ' . buffest#tmpname('[]l')
  set filetype=buffestloclist
  edit!
endfunction
