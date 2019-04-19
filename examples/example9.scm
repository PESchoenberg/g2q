#! /usr/local/bin/guile -s
!#


; ==============================================================================
;
; example9.scm
;
; - This program shows how to use functions from module g2q3 to easily create
; QASM2 programs with multiple QPU calls and measurements.
;
; Compilation (if you have g2q and qre in your system path):
;
; - cd to your /examples folder.
;
; - Enter the following:
;
;   guile example9.scm
;   
; Notice that you will need to have g2q and qre (see README.md for details)
; installed on your system  and your system path variable set to point to both
; in order for this program to work properly. Alternatively, you can:
;
; - copy example9.scm to the main folder of your qre installation.
; 
; - Enter the following:
;
;   guile example9.scm 
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
	     (g2q g2q3)
	     (grsp grsp0))


; Vars and initial stuff. These are editable.
(define fname "example9") ; File name
(define qpu "qlib_simulator") ; qpu to use. Change it according to what qre accepts.
(define clean "y") ; Clean the json files created in ddir after use.
(define qver 2.0) ; OpenQASM version
(define qn 5) ; Length of the quantum register.
(define cn 5) ; Length of the conventional register


; Vars and initial stuff. Do not edit these.
(define ddir "data/json/")
(define fnameo (strings-append (list fname ".qasm") 0))
(define q "q")
(define c "c")
(define mc 0)
(define qx 0)
(define res 0)


; qf - Notice that qf is a function that contains the actual code to be compiled
; into QASM2. The function itself is passed as an argument (higher order
; function) to function main-loop. Also take in account that the arguments 
; to functions such as this one must match the arguments passed to the functions 
; to which this one is passed as an argument.
;
; Arguments:
; p_i: counter for qcalls.
; p_q: value of q variable.
; p_c: c.
; p_qn qn.
; p_qc qc.
;
(define (qf p_i p_q p_c p_qn p_cn)
    (g1y "h" p_q 0 5)
    (if (= p_i 1)(g1y "x" p_q 0 5))
    (if (= p_i 2)(g1y "y" p_q 0 5))
    (if (= p_i 3)(g1y "z" p_q 0 5))    
    (qmeasy  p_q p_c p_qn p_cn))


; And this is the main program. It gives as a result the decimal absolute and
; non-probabilistic summation of the max values obtained on the execution of 
; each quantum circuit created on each qcall.
(qcomm "Number of QPU call (qcalls): ")
(set! qx (read))
(display "Wait...")
(newlines 1)
(set! res (main-loop clean fname fnameo qver ddir qpu qf q c qn cn mc qx))
(newlines 2)
(display "Result = ")
(display res)
(newlines 1)


