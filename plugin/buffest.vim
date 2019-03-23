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

if !hasmapto('<Plug>BuffestRegsplit') && mapcheck('c@', 'n') ==# ''
  " Only map this if the defaul mapping is used
  if mapcheck('c@@', 'n') ==# ''
    nnoremap <silent> <unique> c@@ :silent Regsplit "<cr>
  endif
  nmap <silent> <unique> c@ <Plug>BuffestRegsplit
endif

nnoremap <Plug>BuffestRegsplit :silent execute 'Regsplit '.nr2char(getchar())<cr>

if hasmapto('<Plug>BuffestRegvsplit')
  nnoremap <Plug>BuffestRegvsplit :silent execute 'Regvsplit '.nr2char(getchar())<cr>
endif

if hasmapto('<Plug>BuffestRegtabedit')
  nnoremap <Plug>BuffestRegtabedit :silent execute 'Regtabedit '.nr2char(getchar())<cr>
endif

if hasmapto('<Plug>BuffestRegedit')
  nnoremap <Plug>BuffestRegedit  :silent execute 'Regedit '.nr2char(getchar())<cr>
endif

if hasmapto('<Plug>BuffestRegpedit')
  nnoremap <Plug>BuffestRegpedit  :silent execute 'Regpedit '.nr2char(getchar())<cr>
endif

if !hasmapto('<Plug>BuffestQflistsplit') && mapcheck('c\q', 'n') ==# ''
  nmap <silent> <unique> c\q <Plug>BuffestQflistsplit
endif

nnoremap <Plug>BuffestQflistsplit :silent Qflistsplit<cr>

if hasmapto('<Plug>BuffestQflistvsplit')
  nnoremap <Plug>BuffestQflistvsplit :silent Qflistvsplit<cr>
endif

if hasmapto('<Plug>BuffestQflisttabedit')
  nnoremap <Plug>BuffestQflisttabedit :silent Qflisttabedit<cr>
endif

if hasmapto('<Plug>BuffestQflistedit')
  nnoremap <Plug>BuffestQflistedit :silent Qflistedit<cr>
endif

if !hasmapto('<Plug>BuffestLoclistsplit') && mapcheck('c\l', 'n') ==# ''
  nmap <silent> <unique> c\l <Plug>BuffestLoclistsplit
endif

nnoremap <Plug>BuffestLoclistsplit :silent Loclistsplit<cr>

if hasmapto('<Plug>BuffestLoclistvsplit')
  nnoremap <Plug>BuffestLoclistvsplit :silent Loclistvsplit<cr>
endif

if hasmapto('<Plug>BuffestLoclisttabedit')
  nnoremap <Plug>BuffestLoclisttabedit :silent Loclisttabedit<cr>
endif

if hasmapto('<Plug>BuffestLoclistedit')
  nnoremap <Plug>BuffestLoclistedit :silent Loclistedit<cr>
endif

" }}}

" vim:set et sw=2 ts=2 fdm=marker:
