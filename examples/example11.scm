#! /usr/local/bin/guile -s
!#


; ==============================================================================
;
; example11.scm
;
; - Experiment to produce majoranas.

;
; Compilation (if you have g2q and qre in your system path):
;
; - cd to your /examples folder.
;
; - Enter the following:
;
;   guile example11.scm
;   
; Notice that you will need to have g2q and qre (see README.md for details)
; installed on your system  and your system path variable set to point to both
; in order for this program to work properly. Alternatively, you can:
;
; - copy example11.scm to the main folder of your qre installation.
; 
; - Enter the following:
;
;   guile example11.scm 
;
; Sources:
; - https://medium.com/@decodoku/an-experiment-i-did-and-why-you-should-care-9cbabe544cc7
; - https://arxiv.org/pdf/1609.07774.pdf
; - https://youtu.be/_xFOPmdjwCI
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


; Required modules.
(use-modules (g2q g2q0)
	     (g2q g2q1)
	     (g2q g2q2)
	     (g2q g2q3)
	     (grsp grsp0))


; Vars and initial stuff. These are editable.
(define fname "example11") ; File name
(define qpu "qlib_simulator")
(define clean "y") ; Clean the json files created in ddir after use.
(define qver 2.0) ; OpenQASM version
(define qn 5) ; Length of the quantum register.
(define cn 5) ; Length of the conventional register
(define v "y") ; Verbosity.

; Vars and initial stuff. Do not edit these.
(define ddir (car (g2q-qre-config))) ; Obtain this value from configuration list.
(define fnameo (strings-append (list fname ".qasm") 0))
(define q "q")
(define c "c")
(define mc 0)
(define qx 1)
(define res 0)


; qf - Notice that qf is a function that contains the actual code to be compiled
; into QASM2. The function itself is passed as an argument (higher order
; function) to function main-loop. Also take in account that the arguments 
; to functions such as this one must match the arguments passed to the functions 
; to which this one is passed as an argument.
;
; Arguments:
; - p_i: counter for qcalls.
; - p_q: value of q variable.
; - p_c: c.
; - p_qnl: p_qn lowest.
; - p_qnh: p_qn highest.
; - p_cnl: p_cn lowest.
; - p_cnh: p_cn highest.
;
(define (qf p_i p_q p_c p_qnl p_qnh p_cnl p_cnh)
  (g1 "sdg" q 0)
  (g1y "id" q 1 4)
  (g1 "h" q 0)
  (g1 "sdg" q 3)
  (g1 "h" q 3)
  (cx q 0 q 2)
  (cx q 3 q 2)
  (g1 "h" q 0)
  (g1 "s" q 0)
  (g1 "h" q 3)
  (g1 "s" q 3)
  (g1 "h" q 1)  
  (g1 "h" q 2)
  (cx q 1 q 2)
  (g1 "h" q 1)  
  (g1 "h" q 2)
  (g1 "h" q 4)
  (cx q 4 q 2)
  (g1 "h" q 3)
  (g1 "h" q 4)
  (cx q 3 q 2)
  (g1 "h" q 3)    
  (qmeasy p_q p_c p_cnl p_cnh)
  (qdeclare "qx-simulator" "error_model depolarizing_channel,0.001")
  (qdeclare "qlib-simulator" "// Hello qlib-simulator"))


; rf - results function. In this case, extract the max value.
;
; Arguments:
; - p_b: b. List fo results to process.
;
(define (rf p_b)
  (let ((res 0))
    (set! res (car (cdr (qfres p_b "max"))))
    res))


; qpresent - This is a presentation for the program and what it intends to
; do.
;
; Arrguments:
; - p_ti: title.
; - p_te: text.
; - p_en: if you want an <ENT> message to appear.
;  - "y" for yes.
;  - "n" for no.
;
(define (qpresent p_ti p_te p_en)
  (let ((n 0))
    (ptit "=" 60 2 p_ti)
    (ptit " " 60 0 p_te)
    (display " ")
    (newline)
    (if (eq? p_en "y")(begin
			(qcomm "Press <ENT> to continue.")
			(set! n (read))))))


; And this is the main program. It gives as a result the decimal absolute and
; non-probabilistic summation of the max values obtained on the execution of 
; each quantum circuit created on each qcall.
(qpresent "Producing majoranas" "Based on a work by Dr. James Wootton." "n")
(display "Department of Physics, University of Basel, 2017.\n")
(set! qpu (g2q-select-qpu))
(cond ((equal? qpu "none")(display "\nBye!\n"))
      (else  
       (begin
	 (newline)
	 (display "Running. Wait...")
	 (newline)
	 (set! res (qmain-loop clean fname fnameo qver ddir qpu qf q c qn cn mc qx v rf))
	 (newlines 2)
	 (display "Result = ")
	 (display res)
	 (newlines 1))))


