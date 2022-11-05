;; =============================================================================
;;
;; g2q0.scm
;;
;; Guile to QASM compiler.
;;
;; =============================================================================
;;
;; Copyright (C) 2018 - 2022 Pablo Edronkin (pablo.edronkin at yahoo.com)
;;
;;   This program is free software: you can redistribute it and/or modify
;;   it under the terms of the GNU Lesser General Public License as published by
;;   the Free Software Foundation, either version 3 of the License, or
;;   (at your option) any later version.
;;
;;   This program is distributed in the hope that it will be useful, but
;;   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;   or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
;;   License for more details.
;;
;;   You should have received a copy of the GNU Lesser General Public License
;;   along with this program. If not, see <https://www.gnu.org/licenses/>.
;;
;; =============================================================================


;;;; General notes:
;;
;; - Read sources for limitations on function parameters.
;; - Read at least the general notes of all scm files in this library before
;;   use.
;;
;; Compilation:
;;
;; - (use-modules (g2q g2q0)(g2q g2q1)(g2q g2q2)(g2q g2q3)(g2q g2q4))
;;
;; Sources:
;;
;; - [1] Gidney, C. (2019). Breaking Down the Quantum Swap. [online]
;;   Algassert.com. Available at: https://algassert.com/post/1717
;;   [Accessed 28 Sep. 2019].


(define-module (g2q g2q0)
  #:use-module (g2q g2q1)
  #:use-module (grsp grsp0)
  #:export (qhead
	    qstr
	    qcomm
	    qelib1
	    qbgns
	    qbgnc
	    qbgna
	    qbg
	    qbgd
	    qmeas
	    qcx
	    qregdef
	    qin
	    g1
	    g2
	    u1
	    u2
	    u3
	    qcond1
	    qcond2
	    qvalid-conditional
	    swap
	    qcomg))


;;;; qhead - Defines a program name.
;;
;; Parameters:
;;
;; - p_s1: string, program name.
;; - p_n1: numeric, Open QASM version number.
;;
(define (qhead p_s1 p_n1)
  (qstr (strings-append (list (g2q-txt 6) p_s1 ";") 0))
  (qstr (strings-append (list (g2q-txt 6)
			      "Compiled with "
			      (g2q-version)
			      ";")
			0))
  (qstr (strings-append (list "OPENQASM " (grsp-n2s p_n1) ";") 0))
  (qstr "include \"qelib1.inc\";"))
  

;;;; qstr - Displays or writes a literal statement.
;;
;; Parameters:
;;
;; - p_s1: string containing the statement.
;;
(define (qstr p_s1)
  (display (strings-append (list p_s1 "\n") 0))) 


;;;; qcomm - Writes a comment.
;;
;; Parameters:
;;
;; - p_s1: comment string.
;;
(define (qcomm p_s1)
  (qstr (strings-append (list (g2q-txt 6) p_s1 ";") 0)))


;;;; qelib1 - Includes initial QASM library.
;;
(define (qelib1)
  (display "include \"qelib1.inc\";\n"))


;;;; qbgns - Adds a trailing space to a string.
;;
;; Parameters:
;;
;; - p_s1: string.
;;
(define (qbgns p_s1)
  (string-append p_s1 " "))


;;;; qbgns - Adds a trailing colon to a number after converting it into
;; a string.
;;
;; Parameters:
;;
;; - p_n1: numeric.
;;
(define (qbgnc p_n1)
  (string-append (grsp-n2s p_n1) ","))


;;;; qbgna - Constructs an array item.
;;
;; Parameters:
;;
;; - p_r1: array name.
;; - p_y1: item number.
;;
(define (qbgna p_r1 p_y1)
  (strings-append (list p_r1 "[" (grsp-n2s p_y1) "]") 0))


;;;; qbg - Basic gate structure.
;;
;; Parameters:
;;
;; - p_g1: string, gate name.
;; - p_r1: quantum or conventional register name (q or c).
;; - p_y1: qubit ordinal number.
;;
(define (qbg p_g1 p_r1 p_y1)
  (string-append (qbgns p_g1) (qbgna p_r1 p_y1)))


;; qbgd - Display basic gate structure.
;;
;; Parameters:
;;
;; - p_g1: string, gate name.
;; - p_r1: quantum or conventional register name (q or c).
;; - p_y1: qubit ordinal number.
;;
(define (qbgd p_g1 p_r1 p_y1)
  (display (string-append (qbg p_g1 p_r1 p_y1) (g2q-txt 2))))


;;;; qmeas - Measurement gate.
;;
;; Parameters:
;;
;; - p_r1: quantum register name 1.
;; - p_x1: numeric, register ordinal of p_r1.
;; - p_r2: quantum register name 2.
;; - p_x2: numeric, register ordinal of p_r2.
;;
(define (qmeas p_r1 p_x1 p_r2 p_x2)
  (display (strings-append (list "measure "
				 (qbgna p_r1 p_x1)
				 " -> "
				 (qbgna p_r2 p_x2)
				 (g2q-txt 2))
			   0)))


;;;; qcx - Gate cx.
;;
;; Parameters:
;;
;; - p_g1: item name.
;; - p_r1: quantum register name 1. 
;; - p_y1: control qubit (dot).
;; - p_r2: quantum register name 2. 
;; - p_y2: target qubit (plus) 
;;
(define (qcx p_g1 p_r1 p_y1 p_r2 p_y2)
  (display (strings-append (list p_g1
				 " "
				 (qbgna p_r1 p_y1)
				 ","
				 (qbgna p_r2 p_y2)
				 (g2q-txt 2))
			   0)))

 
;;;; qregdef - Register definitions.
;;
;; Parameters:
;;
;; - p_r1: quantum register name 1.
;; - p_y1: number of items in p_r1.
;; - p_r2: quantum register name 2.
;; - p_y2: number of items in p_r2.
;;
(define (qregdef p_r1 p_y1 p_r2 p_y2)
  (qbgd "qreg" p_r1 p_y1)
  (qbgd "creg" p_r2 p_y2))


;;;; qin - Increment the value of a variable p_v by p_s.
;;
;; Parameters:
;;
;; - p_n1: variable to increment.
;; - p_n2: increment step.
;;
(define (qin p_n1 p_n2)
  (set! p_n1 (+ p_n1 p_n2)))


;;;; g1 - Fundamental gate using one qbit.
;;
;; Parameters:
;;
;; - p_g1: string, gate name.
;; - p_r1: quantum register name 1.
;; - p_y1: qubit 1.
;;
(define (g1 p_g1 p_r1 p_y1)
  (qbgd p_g1 p_r1 p_y1))  


;;;; g2 - Fundamental quantum gates.
;;
;; Parameters:
;;
;; - p_g1: string, gate name.
;; - p_r1: quantum register name 1.
;; - p_y1: control qubit 1.
;; - p_r2: quantum register name 2.
;; - p_y2: target qubit number 2. Set to zero in the case of gates with no
;;   target q quibt.
;;
(define (g2 p_g1 p_r1 p_y1 p_r2 p_y2)
  (cond ((equal? "cx" p_g1)
	 (qcx p_g1 p_r1 p_y1 p_r2 p_y2))
	((equal? "cy-fast" p_g1)
	 (qcx "cy" p_r1 p_y1 p_r2 p_y2))
	((equal? "cz-fast" p_g1)
	 (qcx "cz" p_r1 p_y1 p_r2 p_y2))
	((equal? "ch-fast" p_g1)
	 (qcx "ch" p_r1 p_y1 p_r2 p_y2))
	(else (qcx p_g1 p_r1 p_y1 p_r2 p_y2))))


;;;; u1 - Gate u1.
;;
;; Parameters:
;;
;; - p_y1: first rotation.
;; - p_r1: quantum register name 1.
;; - p_y2: qubit number.
;;
(define (u1 p_y1 p_r1 p_y2)
  (display (strings-append (list "u1("
				 (grsp-n2s p_y1)
				 (g2q-txt 4)
				 (qbgna p_r1 p_y2)
				 (g2q-txt 2))
			   0)))


;;;; u2 - Gate u2.
;;
;; Parameters:
;;
;; - p_y1: numeric, angle 1, first rotation.
;; - p_y2: numeric, angle 2, second rotation.
;; - p_r1: quantum register name 1.
;; - p_y3: qubit number.
;;
(define (u2 p_y1 p_y2 p_r1 p_y3)
  (display (strings-append (list "u2("
				 (qbgnc p_y1)
				 (grsp-n2s p_y2)
				 (g2q-txt 4)
				 (qbgna p_r1 p_y3)
				 (g2q-txt 2))
			   0)))
  

;;;; u3 - Gate u3.
;;
;; Parameters:
;;
;; - p_y1: numeric, angle 1, first rotation.
;; - p_y2: numeric, angle 2, second rotation.
;; - p_y3: numeric, angle 3, third rotation.
;; - p_r1: quantum register name 1.
;; - p_y4: qubit number.
;;
(define (u3 p_y1 p_y2 p_y3 p_r1 p_y4)
  (display (strings-append (list "u3("
				 (qbgnc p_y1)
				 (qbgnc p_y2)
				 (grsp-n2s p_y3)
				 (g2q-txt 4)
				 (qbgna p_r1 p_y4)
				 (g2q-txt 2))
			   0)))
  

;;;; qcond1 - Quantum conditional 1.
;;
;; Parameters:
;;
;; - p_c1: condition.
;; - p_y1: classical bit vector.
;; - p_y2: number to compare p_y1 to.
;;
(define (qcond1 p_c1 p_y1 p_y2)
  (let ((res1 " "))
    
    (cond ((equal? (qvalid-conditional p_c1) #t)
	   (set! res1 (strings-append (list (g2q-txt 5)
					    p_y1
					    p_c1
					    (grsp-n2s p_y2)
					    (g2q-txt 4))
				      0))))
    
    (display res1)))


;;;; qcond2 - Quantum conditional 2.
;;
;; Parameters:
;;
;; - p_c1: condition.
;; - p_y1: classical bits.
;; - p_y2: number to compare p_y1[pY3] to.
;; - p_y3: classical bit vector item.
;;
(define (qcond2 p_c1 p_y1 p_y3 p_y2)
  (let ((res1 " "))
    
    (cond ((equal? (qvalid-conditional p_c1) #t)
	   (set! res1 (strings-append (list (g2q-txt 5)
					    p_y1
					    "["
					    (grsp-n2s p_y3)
					    "]"
					    p_c1
					    (grsp-n2s p_y2)
					    (g2q-txt 4))
				      0))))
    
    (display res1)))


;;;; qvalid-string - Validate a string.
;;
;; Parameters:
;;
;; - p_s1: string to validate.
;; 
;; Output:
;;
;; - #t if the string is validated, #f otherwise.
;;
(define (qvalid-conditional p_s1)
  (let ((res1 #f))
    
    (cond ((equal? p_s1 "==")
	   (set! res1 #t))
	  ((equal? p_s1 "!=")
	   (set! res1 #t)))
    
    res1))


;;;; swap - Gate swap expressed atomically.
;;
;; Parameters:
;;
;; - p_r1: quantum register name 1. 
;; - p_y1: qubit 1.
;; - p_y2: qubit 2. 
;;
;; Sources:
;;
;; - [1].
;;                                                                     
(define (swap p_r1 p_y1 p_y2)
  (qcomg "swap" 0)
  (qcx "cx" p_r1 p_y1 p_r1 p_y2)
  (qcx "cx" p_r1 p_y2 p_r1 p_y1)
  (qcx "cx" p_r1 p_y1 p_r1 p_y2)
  (qcomg "swap" 1))


;;;; qcomg - Comments for complex gates. Useful to identify various code
;; sections when complex gates are compiled into QASM2 code.
;;
;; Parameters:
;;
;; - p_g1: string, gate name.
;; - p_p1: numeric value indicating the kind of auto gate comment.
;;   - 0: begin block.
;;   - 1: end block.
;;
(define (qcomg p_g1 p_p1)
  (let ((res1 ""))
    
    (cond ((eq? p_p1 0)
	   (set! res1 (strings-append (list (g2q-txt 6) "Begin " p_g1 ";") 0)))
	  ((eq? p_p1 1)
	   (set! res1 (strings-append (list (g2q-txt 6) "End " p_g1 ";") 0))))
    
    (grsp-dl res1)))

