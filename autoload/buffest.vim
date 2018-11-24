" Variables {{{

let g:buffest_supported_registers = map(range(char2nr('a'),char2nr('z')),'nr2char(v:val)') + ['"', '*', '+']

let g:buffest_unsupported_register_error = 'buffest: E1: register not supported'

let g:buffest_supported_listfields = ['filename', 'module', 'lnum', 'pattern', 'col', 'vcol', 'nr', 'text', 'type', 'valid']

let g:buffest_default_list = [{'filename': '', 'module': '', 'lnum': '', 'pattern': '', 'col': 0, 'vcol': 0, 'nr': -1, 'text': '', 'type': '', 'valid': 1}]

let s:tmpdir = '/'.$TMP.'/buffest/'
if $TMP ==# ''
  let s:tmpdir = '/tmp/buffest/'
endif

" }}}

" Initialization {{{

function! buffest#init_tmpdir() abort
  call mkdir(s:tmpdir, 'p')
endfunction

function! buffest#init_au() abort
  augroup buffestfiletype
    autocmd!
    exec 'autocmd BufNewFile,BufRead '.s:tmpdir.'@* set filetype=buffestreg'
    exec 'autocmd BufNewFile,BufRead '.s:tmpdir.',q set filetype=buffestqflist'
    exec 'autocmd BufNewFile,BufRead '.s:tmpdir.',l set filetype=buffestloclist'
  augroup END
endfunction

function! buffest#init() abort
  call buffest#init_tmpdir()
  call buffest#init_au()
endfunction

" }}}

" General utilities {{{

function! buffest#tmpname(name) abort
  return s:tmpdir.a:name
endfunction

function! buffest#regexesc(string) abort
  return escape(a:string, '\\^$*+?.()|[]{}')
endfunction

function! buffest#dict2sortedstring(dict, fields) abort
  let l:string = '{'
  for l:field in a:fields
    let l:string .= "'".l:field."': ".string(a:dict[l:field]).', '
  endfor
  let l:string .= '}'
  let l:string = substitute(l:string, ', }$', '}', '')
  return l:string
endfunction

function! buffest#uniq_unsorted(list) abort
  return filter(copy(a:list), 'index(a:list, v:val, v:key + 1) == -1')
endfunction

function! buffest#intersection(src, ref) abort
  return filter(a:src, 'index(a:ref, v:val) >= 0')
endfunction

" }}}

" Registers {{{

" Register utilities {{{

function! buffest#validreg(regname) abort
  return index(g:buffest_supported_registers, a:regname) >= 0
endfunction

function! buffest#get_regname(filename) abort
  let l:pattern = '^'.buffest#regexesc(s:tmpdir).'@\zs.\?$'
  let l:match = matchstrpos(a:filename, l:pattern)
  if l:match[1] < 0
    return v:null
  endif
  let l:regname = tolower(l:match[0] ==# '' ? '"' : l:match[0])
  if !buffest#validreg(l:regname)
    return v:null
  endif
  return l:regname
endfunction

function! buffest#regcomplete(...) abort
  return g:buffest_supported_registers
endfunction

function! buffest#regdo(cmd, regname) abort
  let l:regname = tolower(a:regname)
  if !buffest#validreg(l:regname)
    throw g:buffest_unsupported_register_error
  endif
  exec a:cmd . ' ' . buffest#tmpname('@'.l:regname)
endfunction

" }}}

" Reading/writing registers {{{

function! buffest#readreg() abort
  let l:filename = expand('%:p')
  let l:regname = buffest#get_regname(l:filename)
  if l:regname == v:null
    return
  endif
  call writefile(getreg(l:regname, 1, 1), l:filename)
  edit!
endfunction

function! buffest#writereg() abort
  let l:filename = expand('%:p')
  let l:regname = buffest#get_regname(l:filename)
  if l:regname == v:null
    return
  endif
  call setreg(l:regname, readfile(l:filename), visualmode())
endfunction

" }}}

" }}}

" Lists {{{

" List utilities {{{

function! buffest#listfieldcomplete(...) abort
  return g:buffest_supported_listfields
endfunction

function! buffest#filterlistfields(list) abort
  let l:list = buffest#uniq_unsorted(a:list)
  return buffest#intersection(l:list, g:buffest_supported_listfields)
endfunction

function! buffest#has_listfields() abort
  return exists('b:buffest_listfields') && len(b:buffest_listfields)
endfunction

function! buffest#has_listfield(field) abort
  return !buffest#has_listfields() || index(b:buffest_listfields, a:field) >= 0
endfunction

" }}}

" Reading lists {{{

function! buffest#sanitize_listitem(item) abort
  let l:item = a:item
  " bufnr is not useful to edit for a human, it is converted to filename
  if has_key(l:item, 'bufnr')
    let l:item['filename'] = bufname(l:item['bufnr'])
    unlet l:item['bufnr']
  endif
  " do not promote invalid items to valid
  if !buffest#has_listfield('valid') && !l:item['valid']
    return v:null
  endif
  return l:item
endfunction

function! buffest#parse_listitem(item) abort
  let l:item = buffest#sanitize_listitem(a:item)
  if type(l:item) == v:t_none
    " item has been sanitized, return nothing
    let l:line = v:null
  elseif !buffest#has_listfields()
    " return an unfiltered string representation of the line
    let l:line = string(l:item)
  else
    " return a filtered string representation of the line
    let l:line = buffest#dict2sortedstring(l:item, b:buffest_listfields)
  endif
  return l:line
endfunction

function! buffest#readlist(list) abort
  if !len(a:list)
    let l:list = g:buffest_default_list
  else
    let l:list = a:list
  endif

  let l:filelist = []
  for l:item in l:list
    let l:line = buffest#parse_listitem(l:item)
    if l:line != v:null
      let l:filelist += [l:line]
    endif
  endfor
  call writefile(l:filelist, expand('%:p'))

  edit!
endfunction

" }}}

" Writing lists {{{

function! buffest#writelistfile() abort
  let l:contents = []
  for line in readfile(expand('%'))
    execute 'let l:contents += ['.line.']'
  endfor
  return l:contents
endfunction

" }}}

" Quickfix list {{{

function! buffest#readqflist() abort
  return buffest#readlist(getqflist())
endfunction

function! buffest#writeqflist() abort
  call setqflist(buffest#writelistfile())
endfunction

function! buffest#qflistdo(cmd, ...) abort
  exec a:cmd . ' ' . buffest#tmpname(',q')
  let b:buffest_listfields = buffest#filterlistfields(a:000)
  " force resetting the filetype to read the new buffest_listfields
  set filetype=buffestqflist
  edit!
endfunction

" }}}

" Location list {{{

function! buffest#readloclist() abort
  return buffest#readlist(getloclist('.'))
endfunction

function! buffest#writeloclist() abort
  call setloclist(winnr() + 1, buffest#writelistfile())
endfunction

function! buffest#loclistdo(cmd, ...) abort
  exec a:cmd . ' ' . buffest#tmpname(',l')
  let b:buffest_listfields = buffest#filterlistfields(a:000)
  " force resetting the filetype to read the new buffest_listfields
  set filetype=buffestloclist
  edit!
endfunction

" }}}

" }}}

call buffest#init()

" vim:set et sw=2 ts=2 fdm=marker:
