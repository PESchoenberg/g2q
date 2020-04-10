#! /usr/local/bin/guile -s
!#

; ==============================================================================
;
; example3.scm
;
; Implementation of Grover's algorithm for two qubits [1]. 
; 
;
; Sources:
;
; - [1]: Quantum Algorithm Implementations for Beginners. Coles, Eidenbenz et al.
;   2018, https://arxiv.org/abs/1804.03719
;   - [1.1]: Donwloaded as https://arxiv.org/pdf/1804.03719.pdf
;     - [1.1.1]: from [1.1], pag 26, fig 18.
;
;
; Compilation:
;
; - cd to your /examples folder.
;
; - Enter the following:
;
;   guile example3.scm
;
; ==============================================================================
;
; Copyright (C) 2018 - 2020  Pablo Edronkin (pablo.edronkin at yahoo.com)
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


; Modules. These two will be almost always required.
(use-modules (g2q g2q0)
	     (g2q g2q2))


; Vars and initial stuff.
(define fname "example3.qasm")
(define qver 2.0)
(define q "q")
(define c "c")
(define qn 5)
(define cn 5)
(define a 1)
(define b 0)

; This configures the output to be sent a file instead of the console. If you
; take out or disable these lines, and those closing the output port (see at  
; the bottom) instead of getting a qasm file you will see the compiled lines
; on the console.
(define port1 (current-output-port))
(define port2 (open-output-file fname))
(set-current-output-port port2)

; Creating header and required vectors.
(qhead fname qver)
(qregdef q qn c cn)

; Main stuff, i.e quantum gates.
(g1y "h" q b a)
(g1y "s" q b a)
(g1cxg1 "h" q a b)
(g1y "s" q b a)
(g1y "h" q b a)
(g1y "x" q b a)
(g1cxg1 "h" q a b)
(g1y "x" q b a)
(g1y "h" q b a)

; And finally, we measure.
(qcomm "Measuring")
(qmeas q b c b)
(qmeas q a c a)

; Sets the output port again to the console. Don't forget to check if the 
; compilation is error free or you have some bugs to kill.
(set-current-output-port port1)
(close port2)
(qendc)


