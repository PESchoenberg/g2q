# g2q - Guile to QASM compiler.

[![DOI](https://zenodo.org/badge/159570670.svg)](https://zenodo.org/badge/latestdoi/159570670)


## Overview:

A very simple Guile-to-OpenQASM 2.0 compiler based on a GNU Guile addon library
that lets you write programs for QASM-based quantum computers using Scheme.


## Dependencies:

* GNU Guile - ver 2.0.11 or newer ( https://www.gnu.org/software/guile/ )

* grsp - https://github.com/PESchoenberg/grsp.git


## Optional:

* qre - https://github.com/PESchoenberg/qre if you want to run example6.scm


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

* You just need to remove /usr/share/guile/site/2.2/g2q or /usr/local/share/guile/site/2.2/g2q and its subfolders.

* There are no other dependencies.


## Usage:

* Should be used as any other GNU Guile library; programs written with g2q
should be written and compiled as any regular Guile program.

* See the examples contained in the /examples folder. These are self-explaining
and filled with comments. You will find there both .scm and .qasm files.

* As a general guide, in order to compile a g2q-based program - say example1.scm:

  * cd into the folder containing the program.

  * enter

    guile example1.scm

    to run it just as any regular GNU Guile program.

* If your code is correct, this will generate a full QASM file named
example1.qasm on the same folder. You can then try that code on a quantum
computer simulator or even a real one that is compatible with Open QASM 2.0.

* File example6.scm requires that you have qre installed on your system (see 
below); this particular example not only compiles code into QASM2 but actually 
runs it using qre.


## Credits and Sources:

* GNU Guile - https://www.gnu.org/software/guile/ (LGPL-3.0 or later)

* qre quantum remote execution - https://github.com/PESchoenberg/qre (LGPL-3.0 or later)

* URL of this project - https://github.com/PESchoenberg/g2q


## Related reading material:

* Extending the Lambda Calculus to Express Randomized and Quantumized Algorithms - Mayman. 1996 - https://arxiv.org/abs/quant-ph/9612052

* A Lambda Calculus for Quantum Computation - Van Tonder. 2003 - http://www.het.brown.edu/people/andre/qlambda/

* Quantum Lambda Calculus  - Selinger, Valiron - https://www.mscs.dal.ca/~selinger/papers/qlambdabook.pdf

* A Lambda Calculus for Quantum Computation with Classical Control - Selinger, Valiron. 2005 - https://www.mathstat.dal.ca/~selinger/papers/papers/qlambda-mscs.pdf 


## License:

* LGPL-3.0-or-later.


