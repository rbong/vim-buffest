let g:buffest_supported_registers = map(range(char2nr('a'),char2nr('z')),'nr2char(v:val)') + ['"', '*', '+']

let g:buffest_unsupported_register_error = 'buffest: E1: register not supported'

let g:buffest_supported_list_fields = ['filename', 'module', 'lnum', 'pattern', 'col', 'vcol', 'nr', 'text', 'type', 'valid']

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
  call setreg(l:regname, readfile(expand('%')), visualmode())
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
  if !len(a:list)
    let l:list = [{'filename': '', 'module': '', 'lnum': '', 'pattern': '', 'col': 0, 'vcol': 0, 'nr': -1, 'text': '', 'type': '', 'valid': 1}]
  else
    let l:list = a:list
  endif

  " build the list to write to the file
  let l:filelist = []
  for l:item in l:list
    " clean up the item
    if exists("l:item['bufnr']")
      let l:item['filename'] = bufname(l:item['bufnr'])
      unlet l:item['bufnr']
    endif

    " calculate the line
    if !exists('b:buffest_list_fields') || !len(b:buffest_list_fields)
      " add a straight up string representation of the line
      let l:line = string(l:item)
    else
      " add a representation of the line with sorted fields
      let l:line = '{'
      for l:field in b:buffest_list_fields
        let l:line .= "'".l:field."': ".string(l:item[l:field]).", "
      endfor
      let l:line .= '}'
      let l:line = substitute(l:line, ", }$", "}", "")
    endif

    let l:filelist += [l:line]
  endfor

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

function buffest#listfieldcomplete(...)
  return g:buffest_supported_list_fields
endfunction

function buffest#filterlistfields(list)
  return filter(uniq([] + a:list), 'index(g:buffest_supported_list_fields, v:val) >= 0')
endfunction

function buffest#qflistdo(cmd, ...)
  exec a:cmd . ' ' . buffest#tmpname(',q')
  " must create a new array for uniq to work
  let b:buffest_list_fields = buffest#filterlistfields(a:000)
  set filetype=buffestqflist
  edit!
endfunction

function buffest#loclistdo(cmd, ...)
  exec a:cmd . ' ' . buffest#tmpname(',l')
  " must create a new array for uniq to work
  let b:buffest_list_fields = buffest#filterlistfields(a:000)
  set filetype=buffestloclist
  edit!
endfunction
