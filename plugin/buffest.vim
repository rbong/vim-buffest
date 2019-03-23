" Commands {{{

command! -complete=customlist,buffest#reg_complete -nargs=1
      \ Regsplit call buffest#reg_do('split', <f-args>)
command! -complete=customlist,buffest#reg_complete -nargs=1
      \ Regvsplit call buffest#reg_do('vsplit', <f-args>)
command! -complete=customlist,buffest#reg_complete -nargs=1
      \ Regtabedit call buffest#reg_do('tabedit', <f-args>)
command! -complete=customlist,buffest#reg_complete -nargs=1
      \ Regedit call buffest#reg_do('edit', <f-args>)
command! -complete=customlist,buffest#reg_complete -nargs=1
      \ Regpedit call buffest#reg_do('pedit', <f-args>)

command! -complete=customlist,buffest#listfield_complete -nargs=*
      \ Qflistsplit call buffest#qflist_do('split', <f-args>)
command! -complete=customlist,buffest#listfield_complete -nargs=*
      \ Qflistvsplit call buffest#qflist_do('vsplit', <f-args>)
command! -complete=customlist,buffest#listfield_complete -nargs=*
      \ Qflisttabedit call buffest#qflist_do('tabedit', <f-args>)
command! -complete=customlist,buffest#listfield_complete -nargs=*
      \ Qflistedit call buffest#qflist_do('edit', <f-args>)

command! -complete=customlist,buffest#listfield_complete -nargs=*
      \ Loclistsplit call buffest#loclist_do('aboveleft split', buffest#loclist_id(), <f-args>)
command! -complete=customlist,buffest#listfield_complete -nargs=*
      \ Loclistvsplit call buffest#loclist_do('aboveleft vsplit', buffest#loclist_id(), <f-args>)
command! -complete=customlist,buffest#listfield_complete -nargs=*
      \ Loclisttabedit call buffest#loclist_do('tabedit', '0', <f-args>)
command! -complete=customlist,buffest#listfield_complete -nargs=*
      \ Loclistedit call buffest#loclist_do('edit', '0', <f-args>)

" }}}

" Bindings {{{

if !hasmapto('<Plug>Regsplit') && mapcheck('c@', 'n') ==# ''
  " Only map this if the defaul mapping is used
  if mapcheck('c@@', 'n') ==# ''
    nnoremap <silent> <unique> c@@ :silent Regsplit "<cr>
  endif
  nmap <silent> <unique> c@ <Plug>Regsplit
endif

nnoremap <Plug>Regsplit :silent execute 'Regsplit '.nr2char(getchar())<cr>

if hasmapto('<Plug>Regvsplit')
  nnoremap <Plug>Regvsplit :silent execute 'Regvsplit '.nr2char(getchar())<cr>
endif

if hasmapto('<Plug>Regtabedit')
  nnoremap <Plug>Regtabedit :silent execute 'Regtabedit '.nr2char(getchar())<cr>
endif

if hasmapto('<Plug>Regedit')
  nnoremap <Plug>Regedit  :silent execute 'Regedit '.nr2char(getchar())<cr>
endif

if hasmapto('<Plug>Regpedit')
  nnoremap <Plug>Regpedit  :silent execute 'Regpedit '.nr2char(getchar())<cr>
endif

if !hasmapto('<Plug>Qflistsplit') && mapcheck('c\q', 'n') ==# ''
  nmap <silent> <unique> c\q <Plug>Qflistsplit
endif

nnoremap <Plug>Qflistsplit :silent Qflistsplit<cr>

if hasmapto('<Plug>Qflistvsplit')
  nnoremap <Plug>Qflistvsplit :silent Qflistvsplit<cr>
endif

if hasmapto('<Plug>Qflisttabedit')
  nnoremap <Plug>Qflisttabedit :silent Qflisttabedit<cr>
endif

if hasmapto('<Plug>Qflistedit')
  nnoremap <Plug>Qflistedit :silent Qflistedit<cr>
endif

if !hasmapto('<Plug>Loclistsplit') && mapcheck('c\l', 'n') ==# ''
  nmap <silent> <unique> c\l <Plug>Loclistsplit
endif

nnoremap <Plug>Loclistsplit :silent Loclistsplit<cr>

if hasmapto('<Plug>Loclistvsplit')
  nnoremap <Plug>Loclistvsplit :silent Loclistvsplit<cr>
endif

if hasmapto('<Plug>Loclisttabedit')
  nnoremap <Plug>Loclisttabedit :silent Loclisttabedit<cr>
endif

if hasmapto('<Plug>Loclistedit')
  nnoremap <Plug>Loclistedit :silent Loclistedit<cr>
endif

" }}}

" vim:set et sw=2 ts=2 fdm=marker:
