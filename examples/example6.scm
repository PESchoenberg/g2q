#! /usr/local/bin/guile -s
!#


; ==============================================================================
;
; example6.scm
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
;   guile example6.scm
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
	     (g2q g2q2))

; Vars and initial stuff. 
(define fname "example6.qasm")
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

; Sets the output pot againt to the console. Don't forget to check if the 
; compilation is error free or you have some bugs to kill.
(set-current-output-port port1)
(close port2)
(qendc)

; This is a system call for qre. Replace [your-path-to-qre-folder] with
; the correct path or change your system PATH variable accordingly.
(system "[your-path-to-qre-folder]/qre example6.qasm post y qlib_simulator 1 example6_1")


