# vim-buffest

Easily edit vim registers/macros and lists as buffers.

![demo video](/media/demo.gif?raw=true)

## Examples

**Opening registers**

All of the named registers, as well as the `"`, `*`, and `+` registers, are supported.
Some different ways to edit register `a` (case insensitive):

```
c@a
:Regsplit a
:Regvsplit a
:Regtabedit a
:Regedit a
:Regpedit a
```

Repace `a` with `<register>` to edit that register.
Additionally, `c@@` opens the `"` register.

**Opening the quickfix list**

```
c\q
:Qflistsplit
:Qflistvsplit
:Qflisttabedit
:Qflistedit
```

**Opening the location list**

```
c\l
:Loclistsplit
:Loclistvsplit
:Loclisttabedit
:Loclistedit
```

**Opening lists with specific fields shown**

```
:Qflistsplit filename lnum
:Loclistsplit filename lnum
```

**Reloading and writing**

Write a buffer to the target:

```
:w
```

To change the type of the register, write it in the desired visual mode.

```
" Change to single-line mode
v:<C-U>wq<CR>
" Change to multi-line mode
V:<C-U>wq<CR>
" Change to block mode
<C-V>:<C-U>wq<CR>
```

Reload the contents of the buffer:

```
:e
```

Force reload the contents of the buffer:

```
:e!
```

**Remapping**

This will change the default mappings:

```
nnoremap <leader>br <Plug>BuffestRegsplit
nnoremap <leader>bq <Plug>BuffestQflistsplit
nnoremap <leader>bl <Plug>BuffestLoclistsplit
```

Other commands can be mapped in the same way.

## Contributing

Before contributing please read [CONTRIBUTING.md](/CONTRIBUTING.md).
