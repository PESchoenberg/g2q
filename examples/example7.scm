#! /usr/local/bin/guile -s
!#


; ==============================================================================
;
; example7.scm
;
; - This program is almost the same as example5.scm, but includes a system 
; call that invokes qre. This is a program that allows for execution in real or
; simulated remote quantum computers, or on local simulators, In this regard, 
; g2q and qre act as a JIT compiler/runtime.
;
; Compilation:
;
; - cd to your /examples folder.
;
; - Enter the following:
;
;   guile example7.scm
;
; Notes:
; - This program will only compile a .qasm file but not run it if you don't have
; qre installed on your system.
; - You should make sure that your PATH system variable points to the folder
; where you installed qre.
; - qre is available at https://github.com/PESchoenberg/qre
;
; ==============================================================================
;
; Copyright (C) 2018 - 2019  Pablo Edronkin (pablo.edronkin at yahoo.com)
;
;   This program is free software: you can redistribute it and/or modify
;   it under the terms of the GNU Lesser General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU Lesser General Public License for more details.
;
;   You should have received a copy of the GNU Lesser General Public License
;   along with this program.  If not, see <https://www.gnu.org/licenses/>.
;
; ==============================================================================


; Required modules.
(use-modules (g2q g2q0)
	     (g2q g2q2)
	     (grsp grsp0))

; Vars and initial stuff. 
(define fnameo "example7.qasm")
(define fnamei "data/json/example7_1.json")
;(define path "/home/pablo/Programs/C++/qre/qre")
(define qver 2.0)
(define q "q")
(define c "c")
(define qn 4)
(define cn 2)
(define mc 0)

; This configures the output to be sent a file instead of the console. If you
; take out or disable these lines, and those closing the output port (see at  
; the bottom) instead of getting a qasm file you will see the compiled lines
; on the console.
(define porto1 (current-output-port))
(define porto2 (open-output-file fnameo))
(set-current-output-port porto2)

; Creating header and required vectors.
(qhead fnameo qver)
(qregdef q qn c cn)

(g1y "h" q 0 3)
(cx q 0 q 1)
(g1 "h" q 2) ; (1) replace with z gate for a normal qpe+
(g1 "h" q 0)
(cx q 3 q 2)
(g1 "h" q 3)

(qmeas q 0 c 0)
(qmeas q 3 c 1)

; Sets the output port again to the console. Don't forget to check if the 
; compilation is error free or you have some bugs to kill.
(set-current-output-port porto1)
(close porto2)
(qendc)

; This is a system call to invoke qre. Replace [your-path-to-qre-folder] with
; the correct path or change your system PATH variable accordingly.
(newline)
(display "We make a system call to qre from within example7.scm ...")
(newline)
(newline)
(system "./qre example7.qasm post y qlib_simulator 1 example7_1")

; Now get the data from the QPU.
(define a (read-file-as-string fnamei))
(newlines 1)
(display "And now we get the results from qre back into example7.scm as a string: ")
(newlines 1)
(newlines 1)
(display a)
(newlines 1)
(display "You can parse the results from this string and use them in any way you want.")
(newlines 1)

(define b (qfclvr a))
(newlines 1)
(display (car b))
(newlines 1)
(display (cadr b))
(newlines 1)

(define c (qfres b "max"))
(newlines 1)
(display "Max value obtained: ")
(display (car c))
(display " ")
(display (cadr c))
(newlines 1)

(define c (qfres b "min"))
(newlines 1)
(display "Min value obtained: ")
(display (car c))
(display " ")
(display (cadr c))
(newlines 1)


