; ==============================================================================
;
; g2q0.scm
;
; Guile to QASM compiler.
;
; Sources: 
;
; - https://www.gnu.org/software/guile/manual/html_node/Writing-new-Modules.html
; - https://quantumexperience.ng.bluemix.net/qx/community
; - https://qiskit.org/documentation/				    
; - https://quantumexperience.ng.bluemix.net/proxy/tutorial/full-user-guide/004-Quantum_Algorithms/061-Basic_Circuit_Identities_and_Larger_Circuits.html
; - https://quantumexperience.ng.bluemix.net/qx/tutorial?sectionId=full-user-guide&page=introduction
; - https://stackoverflow.com/questions/35191434/r5rs-scheme-input-output-how-to-write-append-text-to-an-output-file
; - https://stackoverflow.com/questions/43347366/how-to-write-to-a-file-in-append-mode-scheme-r5rs
;
; ==============================================================================
;
; Copyright (C) 2018  Pablo Edronkin (pablo.edronkin at yahoo.com)
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
(use-modules (g2q g2q1))


(define-module (g2q g2q0)
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
	    qcond))


; Define program name
;
; Arguments:
; - p_prog: program name.
; - p_v: Open QASM version number.
;
(define (qhead p_prog p_v)
  (qstr (string-append "// " p_prog))
  (qstr "//")
  (qstr (string-append "OPENQASM " (string-append (number->string p_v) ";")))
  (qstr "include \"qelib1.inc\";")
  (qstr "//"))
  

; Writes a literal statement.
;
; Arguments:
; - p_n: string containing the literal statement.
(define (qstr p_n)
  (display p_n)
  (newline))


; Write a comment.
;
; Arguments:
; - p_s: String to write as a comment.
;
(define (qcomm p_s)
  (qstr "// ")
  (qstr (string-append "// " p_s)))


; Include initial QASM library.
(define (qelib1)
  (display "include \"qelib1.inc\";")
  (newline))


; qbgns - adds a trailing space to a string.
;
; Arguments:
; - p_n: string.
;
(define (qbgns p_n)
  (string-append p_n " "))


; qbgns - adds a trailing colon to a number after converting it into a string.
;
; Arguments:
; - p_y: number.
;
(define (qbgnc p_y)
  (string-append (number->string p_y) ","))


; qbgna - constructs an array item.
;
; Arguments:
; - p_l: array.
; - p_y: item number.
;
(define (qbgna p_l p_y)
  (string-append p_l (string-append "[" (string-append (number->string p_y) "]"))))


; qbg - basic gate structure.
;
; Arguments:
; - p_n: gate name.
; - p_l: gate identifier (q or c).
; - p_y: number.
;
(define (qbg p_n p_l p_y)
  (string-append (qbgns p_n) (qbgna p_l p_y)))


; qbgd - basic gate structure displayed.
;
; Arguments:
; - p_n: gate name.
; - p_l: gate identifier (ex: q, c, etc.).
; - p_y: number.
;
(define (qbgd p_n p_l p_y)
  (display (string-append (qbg p_n p_l p_y) ";"))
  (newline))


; qmeas - measure gate
;
; Arguments:
; p_l1: gate group identifier.
; p_x1: register number of p_l1.
; p_l2: gate group identifier.
; p_x2: register number of p_l2.
;
(define (qmeas p_l1 p_x1 p_l2 p_x2)
  (display (string-append (string-append "measure " (string-append (qbgna p_l1 p_x1) (string-append " -> " (qbgna p_l2 p_x2)))) ";"))
  (newline))


; qcx - cx gate
;
; Arguments:
; p_n1: item name.
; p_l1: gate group identifier 1. 
; p_y1: y position (dot).
; p_l2: gate group identifier 2. 
; p_y2: y position (plus) 
;
(define (qcx p_n1 p_l1 p_y1 p_l2 p_y2)
  (display (string-append (string-append "cx " (string-append (qbgna p_l1 p_y1) (string-append "," (qbgna p_l2 p_y2)))) ";"))
  (newline))

 
; Register definitions
;
; Arguments:
; - p_l1: q register group name (usually q).
; - p_y1: number of q registers.
; - p_l2: c register group name (usually c).
; - p_y2: number of c registers.
;
(define (qregdef p_l1 p_y1 p_l2 p_y2)
  (qbgd "qreg" p_l1 p_y1)
  (qbgd "creg" p_l2 p_y2))


; qin - Increment a variable
;
; Arguments:
; - p_v: variable to increment
; - p_s: increment step.
;
(define (qin p_v p_t)
  (set! p_v (+ p_v p_t )))


; Fundamental gate using one qbit.
;
; Arguments:
; - p_n1: gate name.
; - p_l1: register name.
; - p_y1: qbit number.
;
(define (g1 p_n1 p_l1 p_y1)
  (qbgd p_n1 p_l1 p_y1))  


; Fundamental quantum gates
;
; Arguments:
; - p_n1: gate name.
; - p_r1: register name 1.
; - p_y1: origin q register number 1.
; - p_r2: register name 2.
; - p_y2: target q register number 2. Set to zero in the case of gates with no
; target q register.
;
(define (g2 p_n1 p_r1 p_y1 p_r2 p_y2)
  (cond ((equal? "cx" p_n1)(qcx p_n1 p_r1 p_y1 p_r2 p_y2))
	(else (qcx p_n1 p_r1 p_y1 p_r2 p_y2))))


; Gate u1
;
; Arguments:
; - p_y1: first rotation.
; - p_l1: gate group designator.
; - p_y2: qbit number.
;
(define (u1 p_y1 p_l1 p_y2)
  (display (string-append "u1(" (string-append (number->string p_y1) (string-append ") " (string-append (qbgna p_l1 p_y2) ";")))))
  (newline))


; Gate u2
;
; Arguments:
; - p_y1: first rotation.
; - p_y2: second rotation.
; - p_l1: gate group designator.
; - p_y3: qbit number.
;
(define (u2 p_y1 p_y2 p_l1 p_y3)
  (display (string-append "u2(" (string-append (qbgnc p_y1) (string-append (number->string p_y2) (string-append ") " (string-append (qbgna p_l1 p_y3) ";"))))))
  (newline))


; Gate u3
;
; Arguments:
; - p_y1: first rotation.
; - p_y2: second rotation.
; - p_y3: thirdd rotation.
; - p_l1: gate group designator.
; - p_y4: qbit number.
;
(define (u3 p_y1 p_y2 p_y3 p_l1 p_y4)
  (display (string-append "u3(" (string-append (qbgnc p_y1) (string-append (qbgnc p_y2) (string-append (number->string p_y3) (string-append ") " (string-append (qbgna p_l1 p_y4) ";")))))))
  (newline))


; Quantum conditional
;
; Arguments:
; - p_c1: condition.
; - p_y1: first parameter. Corresponds to classical bits.
; - p_y2: second parameter.
; - p_y3: third parameter. Corresponds to the number of classical bit.
; - p_a1: action.
;
(define (qcond p_c1 p_y1 p_y3 p_y2)
  (let ((qsen " "))
    (cond ((equal? p_c1 "==")(set! qsen (string-append "if(" (string-append p_y1 (string-append "[" (string-append (number->string p_y3) (string-append "]==" (string-append (number->string p_y2) (string-append ")" " "))))))))))
    (display qsen)))

