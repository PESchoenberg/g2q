# g2q - Guile to QASM compiler.

[![DOI](https://zenodo.org/badge/159570670.svg)](https://zenodo.org/badge/latestdoi/159570670)


## Overview:

A very simple Guile-to-OpenQASM 2.0 compiler based on a GNU Guile addon library
that lets you write programs for QASM-based quantum computers using Scheme.


## Dependencies:

* GNU Guile - v2.2.3 or later ( https://www.gnu.org/software/guile/ )

* grsp - v1.0.7 or later ( https://github.com/PESchoenberg/grsp.git )


## Optional:

* qre - https://github.com/PESchoenberg/qre if you want to run some of the
examples on a couple of quantum simulators on your computer.


## Installation:

* Once you have all dependencies installed on your system, get g2q, unpack 
it into a folder of your choice and cd into it.

* g2q installs as a GNU Guile library. See GNU Guile's manual instructions for
details concerning your OS and distribution, but as an example, on Ubuntu you
would issue (depending on where you installed Guile):

      sudo mkdir /usr/share/guile/site/2.2/g2q

      or

      sudo mkdir /usr/local/share/guile/site/2.2/g2q

      and then 

      sudo cp *.scm -rv /usr/share/guile/site/2.2/g2q

      or

      sudo cp *.scm -rv /usr/local/share/guile/site/2.2/g2q

and that will do the trick.


## Uninstall:

* You just need to remove

/usr/share/guile/site/2.2/g2q

or

/usr/local/share/guile/site/2.2/g2q

and its subfolders.

* There are no other dependencies.


## Usage:

* Should be used as any other GNU Guile library; programs written with g2q
should be written and compiled as any regular Guile program.

* See the examples contained in the /examples folder. These are self-explaining
and filled with comments. You will find there both .scm and .qasm files. Some
programs can run as they are, and some will require program qre.

* As a general guide, in order to compile a g2q-based program - say example1.scm:

  * cd into the folder containing the program.

  * enter

    guile example1.scm

    to run it just as any regular GNU Guile program.

* If your code is correct, this will generate a full QASM file named
example1.qasm on the same folder. You can then try that code on a quantum
computer simulator or even a real one that is compatible with Open QASM 2.0.

* File example6.scm and other with a higher prder number (example7, example8,
etc.) require that you have qre installed on your system (see below); this
particular example as well as many of the others described above not only
compile code into QASM2 but actually runs it using qre.


## Credits and Sources:

* GNU contributors (2019). GNU's programming and extension language — GNU
Guile. [online] Gnu.org. Available at: https://www.gnu.org/software/guile/
[Accessed 2 Sep. 2019].

* Edronkin, P. (2019). qre - local and remote runtime for QASM2 programs.
[online] qre. Available at: https://peschoenberg.github.io/qre/
[Accessed 26 Aug. 2019].

* Edronkin, P. (2019). grsp - Useful Scheme functions. [online] grsp.
Available at: https://peschoenberg.github.io/grsp/ [Accessed 26 Aug. 2019].

* URL of this project - https://github.com/PESchoenberg/g2q .

Please let me know if I forgot to add any credits or sources.


## Related reading material:

* P. Maymin (1996). Extending the Lambda Calculus to Express Randomized and
Quantumized Algorithms [online]. Available at:
https://arxiv.org/abs/quant-ph/9612052 [Accessed 02 Sep. 2019]

* van Tonder, A. (2003). A lambda calculus for quantum computation. [online]
Het.brown.edu. Available at:
http://www.het.brown.edu/people/andre/qlambda/ [Accessed 2 Sep. 2019].

* Selinger, P. and Valiron, B. (2012). Quantum Lambda Calculus. [ebook]
Available at: https://www.mscs.dal.ca/~selinger/papers/qlambdabook.pdf
[Accessed 2 Sep. 2019].

* Selinger, P. and Valiron, B. (2005). A lambda calculus for quantum
computation with classical control. [ebook] Available at:
https://www.mathstat.dal.ca/~selinger/papers/papers/qlambda-mscs.pdf
[Accessed 2 Sep. 2019].


## License:

* LGPL-3.0-or-later.


