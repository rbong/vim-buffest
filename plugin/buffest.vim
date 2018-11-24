" Commands {{{

command! -complete=customlist,buffest#regcomplete -nargs=1
      \ Regsplit call buffest#regdo('split', <f-args>)
command! -complete=customlist,buffest#regcomplete -nargs=1
      \ Regvsplit call buffest#regdo('vsplit', <f-args>)
command! -complete=customlist,buffest#regcomplete -nargs=1
      \ Regtabedit call buffest#regdo('tabedit', <f-args>)
command! -complete=customlist,buffest#regcomplete -nargs=1
      \ Regedit call buffest#regdo('edit', <f-args>)

command! -complete=customlist,buffest#listfieldcomplete -nargs=*
      \ Qflistsplit call buffest#qflistdo('split', <f-args>)
command! -complete=customlist,buffest#listfieldcomplete -nargs=*
      \ Qflistvsplit call buffest#qflistdo('vsplit', <f-args>)
command! -complete=customlist,buffest#listfieldcomplete -nargs=*
      \ Qflisttabedit call buffest#qflistdo('tabedit', <f-args>)
command! -complete=customlist,buffest#listfieldcomplete -nargs=*
      \ Qflistedit call buffest#qflistdo('edit', <f-args>)

command! -complete=customlist,buffest#listfieldcomplete -nargs=*
      \ Loclistsplit call buffest#loclistdo('aboveleft split', <f-args>)
command! -complete=customlist,buffest#listfieldcomplete -nargs=*
      \ Loclistvsplit call buffest#loclistdo('aboveleft vsplit', <f-args>)
command! -complete=customlist,buffest#listfieldcomplete -nargs=*
      \ Loclisttabedit call buffest#loclistdo('tabedit', <f-args>)
command! -complete=customlist,buffest#listfieldcomplete -nargs=*
      \ Loclistedit call buffest#loclistdo('edit', <f-args>)

" }}}

" Bindings {{{

if !hasmapto('<Plug>Regsplit') && mapcheck('c@', 'n') ==# ''
  map <unique> c@ <Plug>Regsplit
  " Only map this if the defaul mapping is used
  nnoremap <unique> c@@ :Regsplit "<cr>
endif

nnoremap <Plug>Regsplit :execute 'Regsplit '.nr2char(getchar())<cr>

if hasmapto('<Plug>Regvsplit')
  nnoremap <Plug>Regvsplit :execute 'Regvsplit '.nr2char(getchar())<cr>
endif

if hasmapto('<Plug>Regtabedit')
  nnoremap <Plug>Regtabedit :execute 'Regtabedit '.nr2char(getchar())<cr>
endif

if hasmapto('<Plug>Regedit')
  nnoremap <Plug>Regedit  :execute 'Regedit '.nr2char(getchar())<cr>
endif

if !hasmapto('<Plug>Qflistsplit') && mapcheck('c,q', 'n') ==# ''
  map <unique> c,q <Plug>Qflistsplit
endif

nnoremap <Plug>Qflistsplit :Qflistsplit<cr>

if hasmapto('<Plug>Qflistvsplit')
  nnoremap <Plug>Qflistvsplit :Qflistvsplit<cr>
endif

if hasmapto('<Plug>Qflisttabedit')
  nnoremap <Plug>Qflisttabedit :Qflisttabedit<cr>
endif

if hasmapto('<Plug>Qflistedit')
  nnoremap <Plug>Qflistedit :Qflistedit<cr>
endif

if !hasmapto('<Plug>Loclistsplit') && mapcheck('c,l', 'n') ==# ''
  map <unique> c,l <Plug>Loclistsplit
endif

nnoremap <Plug>Loclistsplit :Loclistsplit<cr>

if hasmapto('<Plug>Loclistvsplit')
  nnoremap <Plug>Loclistvsplit :Loclistvsplit<cr>
endif

if hasmapto('<Plug>Loclisttabedit')
  nnoremap <Plug>Loclisttabedit :Loclisttabedit<cr>
endif

if hasmapto('<Plug>Loclistedit')
  nnoremap <Plug>Loclistedit :Loclistedit<cr>
endif

" }}}

" vim:set et sw=2 ts=2 fdm=marker:
