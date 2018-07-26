" Commands {{{

command! -complete=customlist,buffest#regcomplete -nargs=1
      \ Regsplit call buffest#regdo(<f-args>, 'split')
command! -complete=customlist,buffest#regcomplete -nargs=1
      \ Regvsplit call buffest#regdo(<f-args>, 'vsplit')
command! -complete=customlist,buffest#regcomplete -nargs=1
      \ Regtabedit call buffest#regdo(<f-args>, 'tabedit')

command! -nargs=0 Qflistsplit call buffest#qflistdo('split')
command! -nargs=0 Qflistvsplit call buffest#qflistdo('vsplit')
command! -nargs=0 Qflisttabedit call buffest#qflistdo('tabedit')

command! -nargs=0 Loclistsplit call buffest#loclistdo('split')
command! -nargs=0 Loclistvsplit call buffest#loclistdo('vsplit')
command! -nargs=0 Loclisttabedit call buffest#loclistdo('tabedit')

" }}}

" Bindings {{{

if !hasmapto('<Plug>Regsplit')
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

if !hasmapto('<Plug>Qflistsplit')
  map <unique> c,q <Plug>Qflistsplit
endif

nnoremap <Plug>Qflistsplit :Qflistsplit<cr>

if hasmapto('<Plug>Qflistvsplit')
  nnoremap <Plug>Qflistvsplit :Qflistvsplit<cr>
endif

if hasmapto('<Plug>Qflisttabedit')
  nnoremap <Plug>Qflisttabedit :Qflisttabedit<cr>
endif

if !hasmapto('<Plug>Loclistsplit')
  map <unique> c,l <Plug>Loclistsplit
endif

nnoremap <Plug>Loclistsplit :Loclistsplit<cr>

if hasmapto('<Plug>Loclistvsplit')
  nnoremap <Plug>Loclistvsplit :Loclistvsplit<cr>
endif

if hasmapto('<Plug>Loclisttabedit')
  nnoremap <Plug>Loclisttabedit :Loclisttabedit<cr>
endif

" }}}

" vim: set fdm=marker
