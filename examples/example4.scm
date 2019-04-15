#! /usr/local/bin/guile -s
!#

; ==============================================================================
;
; example4.scm
;
; A program that estimates decoherence time on an n-qubit quantum circuit after
; x time steps, being n and x configurable, adapted and developed from [1].
; 
;
; Sources:
;
; - [1]: Quantum Algorithm Implementations for Beginners. Coles, Eidenbenz et al.
;   2018, https://arxiv.org/abs/1804.03719
;   - [1.1]: Donwloaded as https://arxiv.org/pdf/1804.03719.pdf
;     - [1.1.1]: from [1.1], pag 32, fig 24.
;
;
; Compilation:
;
; - cd to your /examples folder.
;
; - Enter the following:
;
;   guile example4.scm
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


; Modules. These two will be almost always required.
(use-modules (g2q g2q0)
	     (g2q g2q2))


; Vars and initial stuff.
(define fname "example4.qasm")
(define qver 2.0)
(define q "q")
(define c "c")
(define g "h")
(define qn 0)
(define cn 0)
(define qx 0)
(define n 0)
(qcomm "Number of qubits: ") ; q
(set! qn (read))


; The number of conventional register will be the same as qubits.
(set! cn qn) 


; Number of times that function g1y wil be called.
(qcomm "Number of time steps: ")
(set! qx (read))


; Register count starts at zero, so we need n for looping in the interval 
; [0: (- qn 1)].
(set! n (- qn 1))


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


; Main stuff, rather short code but can expand into a lot of if q or n have 
; significant values.
(g1y g q 0 n)
(g1xy "id" q 0 n qx)


; And finally, we measure. Notice that we use qmeasy instead of qmeas this 
; provides us with as many measuring gates as n requires.
(qcomm "Measuring")
(qmeasy q c 0 n)


; Sets the output port again to the console. Don't forget to check if the 
; compilation is error free or you have some bugs to kill.
(set-current-output-port port1)
(close port2)
(qendc)

