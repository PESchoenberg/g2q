g2q - A very simple Guile-to-QASM compiler.

Description:
- Lets you write programs for QASM-based quantum computers using GNU Guile.


License:
- LGPL-3.0-or-later.


Installation:
- Unpack into a folder of your choice and cd into it.

- Follow the GNU Guile instructions for installing libraries. On an Ubuntu
system, you would copy everything using a command like this:

- sudo cp qstdlib.scm /usr/share/guile/site/2.0/rsp

Note that you may need to create folders /site /2.0 and /rsp. also, if you use
a more recent version of GNU Guile, you may want to create it instead of /2.0,
for example, /2.2


Use:
- See the examples contained in the /examples folder and the introductory guide
found also in that folder.


Compiling:
- Assuming a given program, say test1.scm, you would write in your shell

- guile test1.scm

- This will generate a test1.qasm file.


