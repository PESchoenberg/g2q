#! /usr/local/bin/guile -s
!#


;; =============================================================================
;;
;; test1.scm
;;
;; A series of tests to evaluate which gates provided by g2q and qre are
;; compatible with a given qpu. In case that a gate is not compatible with the
;; selected quantum processor or simulator, a message will state so. Note that
;; in order for this to work, the gate must be one specified in the OpenQASM2
;; standard.
;;
;; Compilation (if you have g2q and qre in your system path):
;;
;; - cd to your /tests folder.
;;
;; - Enter the following:
;;
;;   guile test1.scm
;;   
;; Notice that you will need to have g2q and qre (see README.md for details)
;; installed on your system  and your system path variable set to point to both
;; in order for this program to work properly. Alternatively, you can:
;;
;; - copy test1.scm to the main folder of your qre installation.
;; 
;; - Enter the following:
;;
;;   guile test1.scm 
;;
;; Sources:
;; - Andrew W. Cross, Lev S. Bishop, John A. Smolin, Jay M. Gambetta "Open 
;;   Quantum Assembly Language", https://arxiv.org/abs/1707.03429
;; - https://en.wikipedia.org/wiki/OpenQASM
;; - https://github.com/Qiskit/openqasm
;;
;; =============================================================================
;;
;; Copyright (C) 2018 - 2020  Pablo Edronkin (pablo.edronkin at yahoo.com)
;;
;;   This program is free software: you can redistribute it and/or modify
;;   it under the terms of the GNU Lesser General Public License as published by
;;   the Free Software Foundation, either version 3 of the License, or
;;   (at your option) any later version.
;;
;;   This program is distributed in the hope that it will be useful,
;;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;   GNU Lesser General Public License for more details.
;;
;;   You should have received a copy of the GNU Lesser General Public License
;;   along with this program.  If not, see <https://www.gnu.org/licenses/>.
;;
;; =============================================================================


;; Required modules.
(use-modules (g2q g2q0)
	     (g2q g2q1)
	     (g2q g2q2)
	     (g2q g2q3)
	     (g2q g2q4)
	     (grsp grsp0))


;; Vars and initial stuff. These are editable.
(define fname "test1") ; File name
(define qpu "qlib_simulator")
(define clean "y") ; Clean the json files created in ddir after use.
(define qver 2.0) ; OpenQASM version
(define qn 5) ; Length of the quantum register.
(define cn 5) ; Length of the conventional register
(define v "y") ; Verbosity.

;; Vars and initial stuff. Do not edit these.
(define ddir (car (g2q-qre-config))) ; Obtain this value from configuration list for json.
;;(define ddir (car (cdr (g2q-qre-config)))) ; Obtain this value from configuration list for sqlite3.
(define fnameo (strings-append (list fname ".qasm") 0))
(define q "q")
(define c "c")
(define mc 0)
(define qx 1)
(define res 0)


;; qf - Notice that qf is a function that contains the actual code to be compiled
;; into QASM2.
;;
;; Arguments:
;; - p_i: counter for qcalls.
;; - p_q: value of q variable.
;; - p_c: c.
;; - p_qnl: p_qn lowest.
;; - p_qnh: p_qn highest.
;; - p_cnl: p_cn lowest.
;; - p_cnh: p_cn highest.
;;
(define (qf p_i p_q p_c p_qnl p_qnh p_cnl p_cnh)

  ;; Basic gates.
  (g1 "h" q 0)
  (g1 "x" q 1)
  (g1 "y" q 2)
  (g1 "z" q 0)
  (g1 "s" q 1)
  (g1 "t" q 2)  
  (g1 "sdg" q 0)
  (g1 "tdg" q 1)
  (g1 "reset" q 0)
  (swap q 1 2)
  (swap-fast q 0 1)  

  ;; Controlled gates.
  (cx q 2 q 0)
  (cy q 0 q 1)
  (cy-fast q 2 q 0)
  (cz q 0 q 1)
  (cz-fast q 2 q 0)
  (ch q 0 q 1)
  (ch-fast q 2 q 0)
  (cswap q 0 q 1 q 2)

  ;; Universal gates.  
  (u1 1.6 q 0)
  (u2 1.6 1.6 q 1)
  (u3 1.6 1.6 1.6 q 2)
  (cu1 1.6 q 2 q 0)
  (cu1-fast 1.6 q 2 q 1)
  (cu3 1.6 1.6 q 2 q 2)
  (cu3-fast 1.6 1.6 1.6 q 2 q 0)  

  ;; Toffoli.
  (ccx q 0 q 1 q 2)
  (ccx-fast q 0 q 1 q 2)  

  ;; Rotations and others.
  (rx 1.6 q 1)
  (rx-fast 1.6 q 1)
  (ry 1.6 q 2)
  (ry-fast 1.6 q 2)
  (rz 1.6 q 3)
  (rz-fast 1.6 q 0)
  (crz 1.6 q 1 q 2)
  (crz-fast 1.6 q 0 q 1)

  ;; Conditionals.
  (qcond1 "==" q 1)(g1 "y" q 2)
  (qcond2 "!=" q 2 1)(g1 "y" q 2)

  ;; QFT
  (qftyn q 0 q 2)
  (qftdgyn q 0 q 2)

  ;; ECC
  (ecc1 q 0)
  (ecc2 "x" q 0)
  (ecc3 q 0)

  ;; Complex superpositions.
  (hx q 0)
  (hy q 0)
  (hz q 0)
  (hs q 0)
  (hsdg q 0)
  (ht q 0)
  (htdg q 0)

  ;; Probabilistic.
  (qrand1 q 0)

  ;; g2q specific.
  (g1cxg1 "h" q 0 1)  

  ;; Barrier and measure.
  (g1y "barrier" q 0 p_qnh)
  (qmeasy p_q p_c p_cnl p_cnh)
  (qdeclare "qx-simulator" "error_model depolarizing_channel,0.001")
  (qdeclare "qlib-simulator" "// Hello qlib-simulator"))


;; rf - results function. In this case, extract the max value.
;;
;; Arguments:
;; - p_b: b. List of results to process.
;;
(define (rf p_b)
  (car (cdr (qfres p_b "max"))))


;; qpresent - This is a presentation for the program and what it intends to
;; do.
;;
;; Arguments:
;; - p_ti: title.
;; - p_te: text.
;; - p_en: if you want an <ENT> message to appear.
;;  - "y" for yes.
;;  - "n" for no.
;;
(define (qpresent p_ti p_te p_en)
  (let ((n 0))
    (ptit "=" 60 2 p_ti)
    (ptit " " 60 0 p_te)
    (if (eq? p_en "y")(begin
			(qcomm "Press <ENT> to continue.")
			(set! n (read))))))


;; Main program.
(qpresent "Test1.scm" "Testing compatibility of OpenQASM2 standard gates." "n")
(set! qpu (g2q-select-qpu))
(cond ((equal? qpu "none")(display "\nBye!\n"))
      (else  
       (begin
	 (newline)
	 (display "Running. Wait...")
	 (newline)
	 (set! res (qmain-loop clean fname fnameo qver ddir qpu qf q c qn cn mc qx v rf))
	 (newlines 2)
	 (display (strings-append (list "Result = " (grsp-n2s res) " , please read the output provided to check the status of each gate in relation to " qpu ".") 0))	 
	 (newlines 1))))

