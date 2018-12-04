# Contributing

The idea behind this plugin is to make as light a layer on top of Vim as possible for editing common constructs in buffers.
The plugin should do little more than read from a list/register, write it to a file, and read back from the file.
It should rely on Vim to handle complexity whenever possible.
Please keep your changes in line with this philosophy.

## Pull Request Process

1. Post an issue with the changes you wish to make if it does not already exist.
2. Changes to the code should be simple, iterative, and consistent.
3. Run [vint](https://github.com/Kuniwak/vint) in the root directory and make any necessary changes.
4. Keep documentation easy to read, concise, and up-to-date.
   Update `README.md` with simple examples if necessary.
   Update `buffest.txt` with any new or missing related information that users need to know.
