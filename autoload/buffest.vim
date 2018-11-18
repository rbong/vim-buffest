let g:buffest_supported_registers = map(range(char2nr('a'),char2nr('z')),'nr2char(v:val)') + ['"', '*', '+']

let g:buffest_unsupported_register_error = 'buffest: E1: register not supported'

let g:buffest_supported_list_fields = ['filename', 'module', 'lnum', 'pattern', 'col', 'vcol', 'nr', 'text', 'type', 'valid']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  working around vim's register modes and write modes  "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! buffest#RegFileIntoBuffer(file, modeAtWriting) abort
    exec "edit! ".a:file
    set nofixeol noeol
    if a:modeAtWriting ==# 'V'
        normal Go
    endif
endf
fun! buffest#RegModeFromList(list) abort
    if empty(a:list) || !empty(a:list[-1])
        return 'v'
    endif
    return 'V'
endf
fun! buffest#Get_reg2list(regname) abort
    let processed = getreg(a:regname, 1, 1) + (getregtype(a:regname) ==# "V" ? [''] : [] )
    return processed
endf
fun! buffest#Set_list2reg(regname, list) abort
    let mode = buffest#RegModeFromList(a:list)
    if mode ==# 'V'
        " we have of course to strip that indicating newline again
        let internalRepr = a:list[0:-2]
    else
        let internalRepr = a:list
    endif
    " echom 'the mode is: '.mode
    call setreg(a:regname, internalRepr, mode)
    return getreg(a:regname)
endf
fun! buffest#Readfile(file) abort
    return readfile(a:file, 'b')
endf
fun! buffest#Writefile(content, file) abort
    call writefile(a:content, a:file, 'b')
    return buffest#RegModeFromList(a:content)
endf

""""""""""""""""""""""""""""""""""""""""""""
"  end of working around vim corner cases  "
""""""""""""""""""""""""""""""""""""""""""""

" Gets called when a buffer name globbed '@*' is encountered.
" Path gets matched against tmpfile generation method, so should work without
" exta maintenance. glob pattern (in autocomd) could be centralized still.
function! buffest#adapt_buffer() abort
    let filename = expand('%:p')
    let matchingReg = ''
    for reg in g:buffest_supported_registers
        if buffest#tmpname('@'.reg) ==# filename
            let matchingReg = reg
        endif
    endfor
    if !empty(matchingReg)
        let l:regname = tolower(matchingReg)
        if index(g:buffest_supported_registers, l:regname) < 0
          throw g:buffest_unsupported_register_error
        endif
        call buffest#regdo(matchingReg, 'edit')
    endif
endf

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
  echom '!!' . l:regname

let writecontent = buffest#Get_reg2list(l:regname)
echom '!!writecontent '. string(writecontent)
let file = expand('%:p')
let modeAtWriting = buffest#Writefile(writecontent, file)
call buffest#RegFileIntoBuffer(file, modeAtWriting)
endfunction


function! buffest#writereg()
  if !exists('b:buffest_regname')
    return
  endif
  let l:regname = tolower(b:buffest_regname)
  call buffest#Set_list2reg(l:regname, buffest#Readfile(expand('%:p')))
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
  set filetype=buffestreg
  let b:buffest_regname = l:regname
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

function! buffest#writelistfile()
  let contents = []
  for line in readfile(expand('%'))
    execute 'let contents += ['.buffest#unescseparator(line).']'
  endfor
  return contents
endfunction

function! buffest#writeqflist()
  call setqflist(buffest#writelistfile())
endfunction

function! buffest#writeloclist()
  call setloclist('.', buffest#writelistfile())
endfunction

function! buffest#listfieldcomplete(...)
  return g:buffest_supported_list_fields
endfunction

function! buffest#filterlistfields(list)
  return filter(uniq([] + a:list), 'index(g:buffest_supported_list_fields, v:val) >= 0')
endfunction

function! buffest#qflistdo(cmd, ...)
  exec a:cmd . ' ' . buffest#tmpname(',q')
  " must create a new array for uniq to work
  let b:buffest_list_fields = buffest#filterlistfields(a:000)
  set filetype=buffestqflist
  edit!
endfunction

function! buffest#loclistdo(cmd, ...)
  exec a:cmd . ' ' . buffest#tmpname(',l')
  " must create a new array for uniq to work
  let b:buffest_list_fields = buffest#filterlistfields(a:000)
  set filetype=buffestloclist
  edit!
endfunction
