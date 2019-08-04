; ==============================================================================
;
; g2q0.scm
;
; Guile to QASM compiler.
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
;   along with this program. If not, see <https://www.gnu.org/licenses/>.
;
; ==============================================================================


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


; qhead - Defines program name.
;
; Arguments:
; - p_prog: program name.
; - p_v: Open QASM version number.
;
(define (qhead p_prog p_v)
  (qstr (strings-append (list (g2q-txt 6) p_prog ";") 0))
  (qstr (strings-append (list (g2q-txt 6) "Compiled with " (g2q-version) ";") 0))
  (qstr (strings-append (list "OPENQASM " (grsp-n2s p_v) ";") 0))
  (qstr "include \"qelib1.inc\";"))
  

; qstr - Writes a literal statement.
;
; Arguments:
; - p_n: string containing the literal statement.
(define (qstr p_n)
  (display (strings-append (list p_n "\n") 0)))


; qcomm - Writes a comment.
;
; Arguments:
; - p_s: string to write as a comment.
;
(define (qcomm p_s)
  (qstr (strings-append (list (g2q-txt 6) p_s ";") 0)))


; qelib1 - Includes initial QASM library.
(define (qelib1)
  (display "include \"qelib1.inc\";\n"))


; qbgns - Adds a trailing space to a string.
;
; Arguments:
; - p_n: string.
;
(define (qbgns p_n)
  (string-append p_n " "))


; qbgns - Adds a trailing colon to a number after converting it into a string.
;
; Arguments:
; - p_y: number.
;
(define (qbgnc p_y)
  (string-append (grsp-n2s p_y) ","))


; qbgna - Constructs an array item.
;
; Arguments:
; - p_l: array name.
; - p_y: item number.
;
(define (qbgna p_l p_y)
  (strings-append (list p_l "[" (grsp-n2s p_y) "]") 0))


; qbg - Basic gate structure.
;
; Arguments:
; - p_n: gate name.
; - p_l: quantum or conventional register name (q or c).
; - p_y: qubit ordinal number.
;
(define (qbg p_n p_l p_y)
  (string-append (qbgns p_n) (qbgna p_l p_y)))


; qbgd - Display basic gate structure.
;
; Arguments:
; - p_n: gate name.
; - p_l: quantum or conventional register name (q or c).
; - p_y: qubit ordinal number.
;
(define (qbgd p_n p_l p_y)
  (display (string-append (qbg p_n p_l p_y) (g2q-txt 2))))


; qmeas - Measurement gate.
;
; Arguments:
; - p_l1: quantum register name 1.
; - p_x1: register ordinal of p_l1.
; - p_l2: quantum register name 2.
; - p_x2: register ordinal of p_l2.
;
(define (qmeas p_l1 p_x1 p_l2 p_x2)
  (display (strings-append (list "measure " (qbgna p_l1 p_x1) " -> " (qbgna p_l2 p_x2) (g2q-txt 2)) 0)))


; qcx - Gate cx.
;
; Arguments:
; - p_n1: item name.
; - p_l1: quantum register name 1. 
; - p_y1: control qubit (dot).
; - p_l2: quantum register name 2. 
; - p_y2: target qubit (plus) 
;
(define (qcx p_n1 p_l1 p_y1 p_l2 p_y2)
  (display (strings-append (list p_n1 " " (qbgna p_l1 p_y1) "," (qbgna p_l2 p_y2) (g2q-txt 2)) 0)))

 
; qregdef - Register definitions.
;
; Arguments:
; - p_l1: quantum register name 1.
; - p_y1: number of items in p_l1.
; - p_l2: quantum register name 2.
; - p_y2: number of items in p_l2.
;
(define (qregdef p_l1 p_y1 p_l2 p_y2)
  (qbgd "qreg" p_l1 p_y1)
  (qbgd "creg" p_l2 p_y2))


; qin - Increment a variable.
;
; Arguments:
; - p_v: variable to increment
; - p_s: increment step.
;
(define (qin p_v p_t)
  (set! p_v (+ p_v p_t )))


; g1 - Fundamental gate using one qbit.
;
; Arguments:
; - p_n1: gate name.
; - p_l1: quantum register name 1.
; - p_y1: qubit 1.
;
(define (g1 p_n1 p_l1 p_y1)
  (qbgd p_n1 p_l1 p_y1))  


; g2 - Fundamental quantum gates.
;
; Arguments:
; - p_n1: gate name.
; - p_r1: quantum register name 1.
; - p_y1: cntrol qubit 1.
; - p_r2: quantum register name 2.
; - p_y2: target qubit number 2. Set to zero in the case of gates with no
;   target q quibt.
;
(define (g2 p_n1 p_r1 p_y1 p_r2 p_y2)
  (cond ((equal? "cx" p_n1)(qcx p_n1 p_r1 p_y1 p_r2 p_y2))
	((equal? "cy-fast" p_n1)(qcx "cy" p_r1 p_y1 p_r2 p_y2))
	((equal? "cz-fast" p_n1)(qcx "cz" p_r1 p_y1 p_r2 p_y2))
	((equal? "ch-fast" p_n1)(qcx "ch" p_r1 p_y1 p_r2 p_y2))
	(else (qcx p_n1 p_r1 p_y1 p_r2 p_y2))))


; u1 - Gate u1.
;
; Arguments:
; - p_y1: first rotation.
; - p_l1: quantum register name 1.
; - p_y2: qubit number.
;
(define (u1 p_y1 p_l1 p_y2)
  (display (strings-append (list "u1(" (grsp-n2s p_y1) (g2q-txt 4) (qbgna p_l1 p_y2) (g2q-txt 2)) 0)))


; u2 - Gate u2.
;
; Arguments:
; - p_y1: angle 1, first rotation.
; - p_y2: angle 2, second rotation.
; - p_l1: quantum register name 1.
; - p_y3: qubit number.
;
(define (u2 p_y1 p_y2 p_l1 p_y3)
  (display (strings-append (list "u2(" (qbgnc p_y1) (grsp-n2s p_y2) (g2q-txt 4) (qbgna p_l1 p_y3) (g2q-txt 2)) 0)))
  

; u3 - Gate u3.
;
; Arguments:
; - p_y1: angle 1, first rotation.
; - p_y2: angle 2, second rotation.
; - p_y3: angle 3, third rotation.
; - p_l1: quantum register name 1.
; - p_y4: qubit number.
;
(define (u3 p_y1 p_y2 p_y3 p_l1 p_y4)
  (display (strings-append (list "u3(" (qbgnc p_y1) (qbgnc p_y2) (grsp-n2s p_y3) (g2q-txt 4) (qbgna p_l1 p_y4) (g2q-txt 2)) 0)))
  

; qcond1 - Quantum conditional 1.
;
; Arguments:
; - p_c1: condition.
; - p_y1: classical bit vector.
; - p_y2: number to compare p_y1 to.
;
(define (qcond1 p_c1 p_y1 p_y2)
  (let ((qsen " "))
    (cond ((equal? (qvalid-conditional p_c1) #t)(set! qsen (strings-append (list (g2q-txt 5) p_y1 p_c1 (grsp-n2s p_y2) (g2q-txt 4)) 0))))    
    (display qsen)))


; qcond2 - Quantum conditional 2.
;
; Arguments:
; - p_c1: condition.
; - p_y1: classical bits.
; - p_y2: number to compare p_y1[pY3] to.
; - p_y3: classical bit vector item.
;
(define (qcond2 p_c1 p_y1 p_y3 p_y2)
  (let ((qsen " "))
    (cond ((equal? (qvalid-conditional p_c1) #t)(set! qsen (strings-append (list (g2q-txt 5) p_y1 "[" (grsp-n2s p_y3) "]" p_c1 (grsp-n2s p_y2) (g2q-txt 4)) 0))))    
    (display qsen)))


; qvalid-string - Validate a string.
;
; Arguments:
; - p_s1: string to validate.
; 
; Output:
; - #t if the string is validated, #f otherwise.
;
(define (qvalid-conditional p_s1)
  (let ((res #f))
    (cond ((equal? p_s1 "==")(set! res #t)))
    (cond ((equal? p_s1 "!=")(set! res #t)))
    res))


; swap - Gate swap expressed atomically.
;
; Arguments:
; - p_l1: quantum register name 1. 
; - p_y1: qubit 1.
; - p_y2: qubit 2. 
;
; Sources:
; - https://algassert.com/post/1717
;                                                                      
(define (swap p_l1 p_y1 p_y2)
  (qcomg "swap" 0)
  (qcx "cx" p_l1 p_y1 p_l1 p_y2)
  (qcx "cx" p_l1 p_y2 p_l1 p_y1)
  (qcx "cx" p_l1 p_y1 p_l1 p_y2)
  (qcomg "swap" 1))


; qxomg - Comments for complex gates. Useful to identify various code sections 
; when complex gates are compiled into QASM2 code.
;
; Arguments:
; - p_s: string (gate name).
; - p_v: value indicating the kind of gate comment.
;  - 0: begin block.
;  - 1: end block.
;
(define (qcomg p_s p_v)
  (let ((s ""))
    (cond ((eq? p_v 0)(set! s (strings-append (list (g2q-txt 6) "Begin " p_s ";") 0))))
    (cond ((eq? p_v 1)(set! s (strings-append (list (g2q-txt 6) "End " p_s ";") 0))))
    (display s)
    (newline)))



