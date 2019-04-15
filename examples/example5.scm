#! /usr/local/bin/guile -s
!#


; ==============================================================================
;
; example5.scm
;
; - This is an example circuit based on a double quantum phase estimator that
; measures + and - at the same time on qubits 0 and 3. In this case, changing 
; the z gate at (1) by an h gate, we obtain either 10 or 00 as results.
;
; Compilation:
;
; - cd to your /examples folder.
;
; - Enter the following:
;
;   guile example5.scm
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
	     (g2q g2q2))


; Vars and initial stuff. 
(define fname "example5.qasm")
(define qver 2.0)
(define q "q")
(define c "c")
(define qn 4)
(define cn 2)


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
(set-current-output-port port1)
(close port2)
(qendc)

