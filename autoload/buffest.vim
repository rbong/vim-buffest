let g:buffest_supported_registers = map(range(char2nr('a'),char2nr('z')),'nr2char(v:val)') + ['"', '*', '+']

let g:buffest_unsupported_register_error = 'buffest: E1: register not supported'

let g:buffest_supported_listfields = ['filename', 'module', 'lnum', 'pattern', 'col', 'vcol', 'nr', 'text', 'type', 'valid']

let s:tmpdir = '/'.$TMP.'/buffest/'
if $TMP == ''
  let s:tmpdir = '/tmp/buffest/'
endif

function! buffest#init_tmpdir()
  call mkdir(s:tmpdir, 'p')
endfunction

function! buffest#init_au()
  augroup buffestfiletype
    autocmd!
    exec 'autocmd BufNewFile,BufRead '.s:tmpdir.'@* set filetype=buffestreg'
    exec 'autocmd BufNewFile,BufRead '.s:tmpdir.',q set filetype=buffestqflist'
    exec 'autocmd BufNewFile,BufRead '.s:tmpdir.',l set filetype=buffestloclist'
  augroup END
endfunction

function! buffest#init()
  call buffest#init_tmpdir()
  call buffest#init_au()
endfunction

function! buffest#tmpname(name)
  return s:tmpdir.a:name
endfunction

function! buffest#regexesc(string)
  return escape(a:string, '\\^$*+?.()|[]{}')
endfunction

function! buffest#validreg(regname)
  return index(g:buffest_supported_registers, a:regname) >= 0
endfunction

function! buffest#get_regname(filename)
  let l:pattern = buffest#regexesc(s:tmpdir).'@\zs.\?$'
  let l:match = matchstrpos(a:filename, l:pattern)
  if l:match[1] < 0
    return v:null
  endif
  let l:regname = tolower(l:match[0] == '' ? '"' : l:match[0])
  if !buffest#validreg(l:regname)
    return v:null
  endif
  return l:regname
endfunction

function! buffest#readreg()
  let l:filename = expand('%:p')
  let l:regname = buffest#get_regname(l:filename)
  if l:regname == v:null
    return
  endif
  call writefile(getreg(l:regname, 1, 1), l:filename)
  edit!
endfunction

function! buffest#writereg()
  let l:filename = expand('%:p')
  let l:regname = buffest#get_regname(l:filename)
  if l:regname == v:null
    return
  endif
  call setreg(l:regname, readfile(l:filename), visualmode())
endfunction

function! buffest#regcomplete(...)
  return g:buffest_supported_registers
endfunction

function! buffest#regdo(regname, cmd)
  let l:regname = tolower(a:regname)
  if !buffest#validreg(l:regname)
    throw g:buffest_unsupported_register_error
  endif
  exec a:cmd . ' ' . buffest#tmpname('@'.l:regname)
  edit!
endfunction

function! buffest#sanitize_listitem(item)
  let l:item = a:item
  " bufnr is not useful to edit for a human, it is converted to filename
  if exists("l:item['bufnr']")
    let l:item['filename'] = bufname(l:item['bufnr'])
    unlet l:item['bufnr']
  endif
  " do not promote invalid items to valid
  if exists('b:buffest_listfields') && index(b:buffest_listfields, 'valid') < 0 && !l:item['valid']
    return v:null
  endif
  return l:item
endfunction

function! buffest#listitem2string(item)
  let l:item = buffest#sanitize_listitem(a:item)
  if type(l:item) == v:t_none
    " item has been sanitized, return nothing
    let l:line = v:null
  elseif !exists('b:buffest_listfields') || !len(b:buffest_listfields)
    " add a straight up string representation of the line
    let l:line = string(l:item)
  else
    " add a representation of the line with sorted fields
    let l:line = '{'
    for l:field in b:buffest_listfields
      let l:line .= "'".l:field."': ".string(l:item[l:field]).', '
    endfor
    let l:line .= '}'
    let l:line = substitute(l:line, ', }$', '}', '')
  endif
  return l:line
endfunction

function! buffest#readlist(list)
  if !len(a:list)
    let l:list = [{'filename': '', 'module': '', 'lnum': '', 'pattern': '', 'col': 0, 'vcol': 0, 'nr': -1, 'text': '', 'type': '', 'valid': 1}]
  else
    let l:list = a:list
  endif

  let l:filelist = []
  for l:item in l:list
    let l:line = buffest#listitem2string(l:item)
    if l:line != v:null
      let l:filelist += [l:line]
    endif
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
    execute 'let contents += ['.line.']'
  endfor
  return contents
endfunction

function buffest#writeqflist()
  call setqflist(buffest#writelistfile())
endfunction

function buffest#writeloclist()
  call setloclist(winnr() + 1, buffest#writelistfile())
endfunction

function buffest#listfieldcomplete(...)
  return g:buffest_supported_listfields
endfunction

function buffest#filterlistfields(list)
  return filter(uniq([] + a:list), 'index(g:buffest_supported_listfields, v:val) >= 0')
endfunction

function buffest#qflistdo(cmd, ...)
  exec a:cmd . ' ' . buffest#tmpname(',q')
  " must create a new array for uniq to work
  let b:buffest_listfields = buffest#filterlistfields(a:000)
  " force resetting the filetype to read the new buffest_listfields
  set filetype=buffestqflist
  edit!
endfunction

function buffest#loclistdo(cmd, ...)
  exec a:cmd . ' ' . buffest#tmpname(',l')
  " must create a new array for uniq to work
  let b:buffest_listfields = buffest#filterlistfields(a:000)
  " force resetting the filetype to read the new buffest_listfields
  set filetype=buffestloclist
  edit!
endfunction

call buffest#init()
