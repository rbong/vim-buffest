" Variables {{{

let g:buffest_supported_registers = map(range(char2nr('a'),char2nr('z')),'nr2char(v:val)') + ['"', '*', '+']

let g:buffest_unsupported_register_error = 'buffest: E1: register not supported'

let g:buffest_list_defaults = {'filename': '', 'module': '', 'lnum': '', 'pattern': '', 'col': 0, 'vcol': 0, 'nr': -1, 'text': '', 'type': '', 'valid': 1}

let g:buffest_supported_listfields = keys(g:buffest_list_defaults)

" prefix lists with a timestamp to prevent vim instances from sharing buffers
let g:buffest_list_prefix = localtime()

let s:tmpdir = '/' . $TMP . '/buffest/'
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
    exec 'autocmd BufNewFile,BufRead ' . s:tmpdir . '@* set filetype=buffestreg'
    exec 'autocmd BufNewFile,BufRead ' . s:tmpdir . '\,q set filetype=buffestqflist'
    exec 'autocmd BufNewFile,BufRead ' . s:tmpdir . '\,l#* set filetype=buffestloclist'
  augroup END
endfunction

function! buffest#init() abort
  call buffest#init_tmpdir()
  call buffest#init_au()
endfunction

" }}}

" General utilities {{{

function! buffest#tmpname(name) abort
  return fnameescape(s:tmpdir.a:name)
endfunction

function! buffest#escape_regex(string) abort
  return escape(a:string, '\\^$*+?.()|[]{}')
endfunction

function! buffest#dict2sortedstring(dict, fields) abort
  let l:keyvalues = []
  for l:field in a:fields
    let keyvalues += [string(l:field) . ': ' . string(a:dict[l:field])]
  endfor
  let l:string = '{' . join(keyvalues, ', ') . '}'
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

function! buffest#valid_regname(regname) abort
  return index(g:buffest_supported_registers, a:regname) >= 0
endfunction

function! buffest#get_regname(filename) abort
  let l:pattern = '^' . buffest#escape_regex(s:tmpdir) . '@\zs.\?$'
  let [l:match, l:matchstart, l:matchend] = matchstrpos(a:filename, l:pattern)
  if l:matchstart < 0
    return v:null
  endif
  let l:regname = tolower(l:match ==# '' ? '"' : l:match)
  if !buffest#valid_regname(l:regname)
    return v:null
  endif
  return l:regname
endfunction

function! buffest#reg_complete(...) abort
  return g:buffest_supported_registers
endfunction

function! buffest#reg_do(cmd, regname) abort
  let l:regname = tolower(a:regname)
  " escape character, cancel
  if l:regname ==# nr2char(27)
    return
  elseif !buffest#valid_regname(l:regname)
    throw g:buffest_unsupported_register_error
  endif
  exec a:cmd . ' ' . buffest#tmpname('@' . l:regname)
endfunction

" }}}

" Reading/writing registers {{{

function! buffest#read_reg() abort
  let l:filename = expand('%:p')
  let l:regname = buffest#get_regname(l:filename)
  if l:regname == v:null
    return
  endif
  set binary
  call writefile(getreg(l:regname, 1, 1), l:filename, 'b')
  edit!
endfunction

function! buffest#write_reg() abort
  let l:filename = expand('%:p')
  let l:regname = buffest#get_regname(l:filename)
  if l:regname == v:null
    return
  endif

  let l:mode = visualmode()
  if l:mode ==# ''
    let l:mode = getregtype(l:regname)
  endif

  call setreg(l:regname, readfile(l:filename, 'b'), l:mode)
endfunction

" }}}

" }}}

" Lists {{{

" List utilities {{{

function! buffest#loclist_id() abort
  return g:buffest_list_prefix . '-' . string(bufnr('%'))
endfunction

" }}}

" List fields {{{

function! buffest#listfield_complete(lead, ...) abort
  return filter(copy(g:buffest_supported_listfields), 'v:val =~# "^" . a:lead')
endfunction

function! buffest#filter_listfields(list) abort
  let l:list = buffest#uniq_unsorted(a:list)
  return buffest#intersection(l:list, g:buffest_supported_listfields)
endfunction

function! buffest#get_listfields() abort
  if exists('b:buffest_listfields')
    return b:buffest_listfields
  endif
  if &filetype ==# 'buffestqflist'
    return exists('s:qflist_fields') ? s:qflist_fields : v:null
  elseif &filetype ==# 'buffestloclist'
    return exists('s:loclist_fields') ? s:loclist_fields : v:null
  endif
endfunction

function! buffest#has_listfields() abort
  let l:listfields = buffest#get_listfields()
  return type(l:listfields) != v:none && len(l:listfields)
endfunction

function! buffest#has_listfield(field) abort
  return !buffest#has_listfields() || index(buffest#get_listfields(), a:field) >= 0
endfunction

function! buffest#save_listfields() abort
  if !exists('b:buffest_listfields') && buffest#has_listfields()
    let b:buffest_listfields = buffest#get_listfields()
  endif
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
    let l:line = buffest#dict2sortedstring(l:item, buffest#get_listfields())
  endif
  return l:line
endfunction

function! buffest#read_list(list) abort
  if !len(a:list)
    let l:list = [g:buffest_list_defaults]
  else
    let l:list = a:list
  endif

  call buffest#save_listfields()

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

function! buffest#get_writelist() abort
  let l:contents = []
  for line in readfile(expand('%'))
    let l:contents += [eval(line)]
  endfor
  return l:contents
endfunction

" }}}

" Quickfix list {{{

function! buffest#read_qflist() abort
  return buffest#read_list(getqflist())
endfunction

function! buffest#write_qflist() abort
  call setqflist(buffest#get_writelist())
endfunction

function! buffest#qflist_do(cmd, ...) abort
  let s:qflist_fields = buffest#filter_listfields(a:000)
  try
    exec a:cmd . ' ' . buffest#tmpname(',q')
  finally
    unlet s:qflist_fields
  endtry
endfunction

" }}}

" Location list {{{

function! buffest#read_loclist() abort
  return buffest#read_list(getloclist('.'))
endfunction

function! buffest#write_loclist() abort
  call setloclist(winnr() + 1, buffest#get_writelist())
endfunction

function! buffest#loclist_do(cmd, list_id, ...) abort
  let s:loclist_fields = buffest#filter_listfields(a:000)
  try
    exec a:cmd . ' ' . buffest#tmpname(',l#' . a:list_id)
  finally
    unlet s:loclist_fields
  endtry
endfunction

" }}}

" }}}

call buffest#init()

" vim:set et sw=2 ts=2 fdm=marker:
