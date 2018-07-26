# vim-buffest

Easily edit vim registers/macros and lists as buffers.

## Examples

**Opening registers**

All of the named registers, as well as the `"`, `*`, and `+` registers, are supported.
Some different ways to edit register `a` (case insensitive):

```
c@a
:Regsplit a
:Regvsplit a
:Regtabedit a
```

Repace `a` with `<buffer>` to edit that buffer.
Additionally, `c@@` opens the `"` register.

**Opening the quickfix list**

```
cq
:Qflistsplit
:Qflistvsplit
:Qflisttabedit
```

**Opening the location list**

```
cl
:Loclistsplit
:Loclistvsplit
:Loclisttabedit
```

**Reloading and writing**

Write a buffer to the target:

```
:w
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
nnoremap <leader>br <Plug>Regsplit
nnoremap <leader>bq <Plug>Qflistsplit
nnoremap <leader>bl <Plug>Loclistsplit
```

Other commands can be mapped in the same way.