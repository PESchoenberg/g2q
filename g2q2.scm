;; =============================================================================
;;
;; q2q2.scm
;;
;; Structures made of fundamental gates.
;;
;; Sources: 
;; - https://arxiv.org/abs/1707.03429 , arXiv:1707.03429v2 [quant-ph] , Open
;;   Quantum Assembly Language, Andrew W. Cross, Lev S. Bishop, John A. Smolin,
;;   Jay M. Gambetta.
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
;;   along with this program. If not, see <https://www.gnu.org/licenses/>.
;;
;; =============================================================================


(define-module (g2q g2q2)
  #:use-module (g2q g2q0)
  #:use-module (g2q g2q1)
  #:use-module (grsp grsp0)
  #:use-module (grsp grsp1)  
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:export (qconst
	    g1y
	    g1x
	    g1xy
	    qmeasy
	    cx
	    cz
	    cz-fast
	    cy
	    cy-fast
	    ch
	    ch-fast
	    ccx
	    ccx-fast
	    rx
	    rx-fast
	    ry
	    ry-fast
	    rz
	    rz-fast
	    crz
	    crz-fast
	    cu1
	    cu1-fast
	    cu3
	    cu3-fast
	    g1cxg1
	    qendc
	    qregex
	    qreq
	    qcnot1
	    qxor1
	    qfclvr
	    qfres
	    swap-fast
	    qftyn
	    qftdgyn
	    cswap
	    cx-ladder
	    swap-fast-ladder
	    swap-ladder
	    ghzy
	    g1yl
	    ecc1
	    ecc2
	    ecc3
	    hx
	    hy
	    hz
	    hs
	    hsdg
	    ht
	    htdg))


;; qconst - Sets the values of various required constants.
;;
;; Arguments:
;; - p_n1: constant name, string.
;;
;; Output:
;; - Returns the value of p_n1 if it exists. Zero otherwise.
;;
(define (qconst p_n1)
  (let ((res 0.0))

    (cond ((equal? p_n1 "Pi")
	   (set! res (gconst "A000796")))
	  ((equal? p_n1 "gr")
	   (set! res (gconst "gr"))) 
	  ((equal? p_n1 "e")	   
	   (set! res (gconst "A001113"))))
	   
    res))


;; g1y - Repeats placement of gate p_n1 and group p_l1 by repeating the use of
;; qgate1 from qubit p_y1 to qubit p_y2 on y axis (vertically on graphical
;; representation).
;;
;; Arguments:
;; - p_n1: gate name.
;; - p_l1: quantum register name (i.e. q).
;; - p_y1: ordinal of the initial qubit.
;; - p_y2: ordinal of the last qubit.
;;
(define (g1y p_n1 p_l1 p_y1 p_y2)
  (qcomg "g1y" 0)
  (let loop ((i p_y1))
    (if (= i p_y2)
	(g1 p_n1 p_l1 i)
	(begin (g1 p_n1 p_l1 i)
	       (loop (+ i 1)))))
  (qcomg "g1y" 1))


;; g1x - Repeats placement of gate p_n1 and register p_l1 by repeating the use
;; of qgate1 on regster element p_y1 p_x1 times on x axis.
;;
;; Arguments:
;; - p_n1: gate name.
;; - p_l1: quantum register name.
;; - p_y1: register element.
;; - p_x1: number of iterations on x.
;;
(define (g1x p_n1 p_l1 p_y1 p_x1)
  (qcomg "g1x" 0)
  (let loop ((i 1))
    (if (= i p_x1)
	(g1 p_n1 p_l1 p_y1)
	(begin (g1 p_n1 p_l1 p_y1)
	       (loop (+ i 1)))))
  (qcomg "g1x" 1))


;; g1xy - Repeats placement of gate p_n1 and group p_l1 by repeating the use of
;; qgate1 from qubit p_y1 to qubit p_y2 on y axis.
;;
;; Arguments:
;; - p_n1: gate name.
;; - p_l1: quantum register name.
;; - p_y1: ordinal of the initial qubit.
;; - p_y2: ordinal of the last qubit.
;; - p_x1: number if iterations that g1y will be repeated along x axis of
;;   sequence as a graph.
;;
(define (g1xy p_n1 p_l1 p_y1 p_y2 p_x1)
  (qcomg "g1xy" 0)
  (let loop ((j 1))
    (if (= j p_x1)
	(g1y p_n1 p_l1 p_y1 p_y2)
	(begin (g1y p_n1 p_l1 p_y1 p_y2)
	       (loop (+ j 1)))))
  (qcomg "g1xy" 1))


;; qmeasy - Performs measurements on group p_l1 to group p_l2 from p_y1 to p_y2.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_l2: conventional register name.
;; - p_y1: ordinal of the initial qubit.
;; - p_y2: ordinal of the last qubit.
;;
(define (qmeasy p_l1 p_l2 p_y1 p_y2)
  (qcomg "qmeasy" 0)
  (let loop ((i p_y1))
    (if (= i p_y2)
	(qmeas p_l1 p_y2 p_l2 p_y2)
	(begin (qmeas p_l1 i p_l2 i)
	       (loop (+ i 1)))))
  (qcomg "qmeasy" 1))


;; cx - Gate cx, performs a NOT operation on the target qubit if the control 
;; qubit is |1>. Leaves target qubit as it is otherwise.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1 (represented as a dot in a q diagram).
;; - p_l2: quantum register name 2.
;; - p_y2: target qubit 2 (represented as a plus).
;;
(define (cx p_l1 p_y1 p_l2 p_y2)
  (g2 "cx" p_l1 p_y1 p_l2 p_y2))


;; cz - Gate cz, controlled phase expressed atomically. Gates expressed in
;; this way are universally compatible but more error - prone than the same 
;; gates expressed in fast form.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1.
;; - p_l1: quantum register name 1.
;; - p_y2: target qubit 2.
;;
(define (cz p_l1 p_y1 p_l2 p_y2)
  (qcomg "cz" 0)
  (g1 "h" p_l1 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "h" p_l2 p_y2)
  (qcomg "cz" 1))


;; cz-fast - Gate cz, controlled y in fast form. Such a form is generally 
;; less error - prone that atomic variants, but they might not be 
;; compatible with all sorts and makes of qpu.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1.
;; - p_l1: quantum register name 1.
;; - p_y2: target qubit 2.
;;
(define (cz-fast p_l1 p_y1 p_l2 p_y2)
  (g2 "cz-fast" p_l1 p_y1 p_l2 p_y2))


;; cy - Gate cy, controlled y expressed atomically.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1.
;; - p_l1: quantum register name 1.
;; - p_y2: target qubit 2.
;;
(define (cy p_l1 p_y1 p_l2 p_y2)
  (qcomg "cy" 0)
  (g1 "sdg" p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "s" p_l2 p_y2)
  (qcomg "cy" 1))


;; cy-fast - Gate cy, controlled y in fast form.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1.
;; - p_l1: quantum register name 1.
;; - p_y2: target qubit 2.
;;
(define (cy-fast p_l1 p_y1 p_l2 p_y2)
  (g2 "cy-fast" p_l1 p_y1 p_l2 p_y2))


;; ch - Gate ch, controlled h expressed atomically.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: target qubit 2.
;;
(define (ch p_l1 p_y1 p_l2 p_y2)
  (qcomg "ch" 0)
  (g1 "h" p_l2 p_y2)
  (g1 "sdg" p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (ht p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "t" p_l2 p_y2)
  (hs p_l2 p_y2)
  (g1 "x" p_l2 p_y2)
  (g1 "s" p_l1 p_y1)
  (qcomg "ch" 1))


;; ch-fast - Gate ch, controlled h in fast form.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: target qubit 2.
;;
(define (ch-fast p_l1 p_y1 p_l2 p_y2)
  (g2 "ch-fast" p_l1 p_y1 p_l2 p_y2))


;; ccx - Gate ccx, Toffoli gate expressed atomically.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1 (dot).
;; - p_l2: quantum register name 2.
;; - p_y2: control qubit 2 (dot).
;; - p_l3: quantum register name 3.
;; - p_y3: target qubit 3 (plus).
;;
;; Sources:
;; - Javadi, A. (2019). How can I implement an n-bit Toffoli gate?. [online] 
;;   Quantum Computing Stack Exchange. Available at: https://quantumcomputing.
;;   stackexchange.com/questions/2177/how-can-i-implement-an-n-bit-toffoli-gate 
;;   [Accessed 1 Oct. 2019].
;; - Bennet, C. (2019). Logical Reversibility of Computation*. [online] 
;;   Cs.princeton.edu. Available at: http://www.cs.princeton.edu/courses/archive
;;   /fall04/cos576/papers/bennett73.html [Accessed 1 Oct. 2019].
;; - Elementary gates for quantum computation. Adriano Barenco (Oxford U.), 
;;   Charles H. Bennett (IBM Watson Res. Ctr.), Richard Cleve (Calgary U.), 
;;   David P. DiVincenzo (IBM Watson Res. Ctr.), Norman Margolus (MIT, LNS), 
;;   Peter Shor (Bell Labs), Tycho Sleator (New York U.), John Smolin (UCLA), 
;;   Harald Weinfurter (Innsbruck U.). Mar 1995. 39 pp. Published in Phys.Rev. 
;;   A52 (1995) 3457. DOI: 10.1103/PhysRevA.52.3457
;; - En.wikipedia.org. (2019). Quantum logic gate. [online] Available at: 
;;   https://en.wikipedia.org/wiki/Quantum_logic_gate [Accessed 1 Oct. 2019].
;;
(define (ccx p_l1 p_y1 p_l2 p_y2 p_l3 p_y3)
  (qcomg "ccx" 0)
  (g1 "h" p_l3 p_y3)
  (cx p_l2 p_y2 p_l3 p_y3)
  (g1 "tdg" p_l3 p_y3)
  (cx p_l1 p_y1 p_l3 p_y3)
  (g1 "t" p_l3 p_y3)
  (cx p_l2 p_y2 p_l3 p_y3)
  (g1 "tdg" p_l3 p_y3)
  (cx p_l1 p_y1 p_l3 p_y3)
  (g1 "t" p_l2 p_y2)
  (g1 "t" p_l3 p_y3)
  (g1 "h" p_l3 p_y3)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "t" p_l1 p_y1)
  (g1 "tdg" p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (qcomg "ccx" 1))


;; ccx-fast - Toffoli gate in fast form.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: control qubit 1 (dot).
;; - p_l2: quantum register name 2.
;; - p_y2: control qubit 2 (dot).
;; - p_l3: quantum register name 3.
;; - p_y3: target qubit 3 (plus).
;;
(define (ccx-fast p_l1 p_y1 p_l2 p_y2 p_l3 p_y3)
  (display (strings-append (list "ccx " (qbgna p_l1 p_y1) "," (qbgna p_l1 p_y2) "," (qbgna p_l3 p_y3) (g2q-txt 2)) 0)))
  

;; rx - Gate rx, rotation around X-axis.
;;
;; Arguments:
;; - p_t: theta angle.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;;
(define (rx p_t p_l1 p_y1)
  (let ((y2 (/ (qconst "Pi") 2)))
    
    (u3 p_t (* y2 -1) y2 p_l1 p_y1)))


;; rx-fast - Gate rx, rotation around X-axis, in fast form.
;;
;; Arguments:
;; - p_t: theta angle; this is a dummy arument, left for consistency.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; 
(define (rx-fast p_t p_l1 p_y1)
  (display (strings-append (list "rx(" (grsp-n2s (/ (qconst "Pi") 2)) (g2q-txt 4)  p_l1 "[" (grsp-n2s p_y1) (g2q-txt 3)) 0)))


;; ry - Gate ry, rotation around Y-axis.
;;
;; Arguments:
;; - p_t: theta angle.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;;
(define (ry p_t p_l1 p_y1)
  (u3 p_t 0 0 p_l1 p_y1))


;; ry-fast - Gate ry, rotation around Y-axis, in fast form.
;;
;; Arguments:
;; - p_t: angle (dummy, left for consistency with other functions).
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; 
(define (ry-fast p_t p_l1 p_y1)
  (display (strings-append (list "ry(" (grsp-n2s (/ (qconst "Pi") 2)) (g2q-txt 4) p_l1 "[" (grsp-n2s p_y1) (g2q-txt 3)) 0)))


;; rz - Gate rz, rotation around Z-axis.
;;
;; Arguments:
;; - p_p: angle 1.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;;
(define (rz p_p p_l1 p_y1)
  (u1 p_p p_l1 p_y1))


;; rz-fast - Gate rz, rotation around Z-axis, in fast form.
;;
;; Arguments:
;; - p_t: angle; dummy argument left for consistency with other functions.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; 
(define (rz-fast p_t p_l1 p_y1)
  (display (strings-append (list "rz(" (grsp-n2s (/ (qconst "Pi") 2)) (g2q-txt 4) p_l1 "[" (grsp-n2s p_y1) (g2q-txt 3)) 0)))


;; crz - Gate crz, controlled rz expressed atomically.
;;
;; Arguments:
;; - p_la: angle 1.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2.
;;
(define (crz p_la p_l1 p_y1 p_l2 p_y2)
  (let ((la (/ p_la 2)))

    (qcomg "crz" 0)
    (u1 la p_l2 p_y2)
    (cx p_l1 p_y1 p_l2 p_y2)
    (u1 (* -1.0 la) p_l2 p_y2)
    (cx p_l1 p_y1 p_l2 p_y2)
    (qcomg "crz" 1)))


;; crz-fast - Gate crz, controlled rz expressed in fast form.
;;
;; Arguments:
;; - p_la: angle 1.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2.
;;
(define (crz-fast p_la p_l1 p_y1 p_l2 p_y2)
  (display (strings-append (list "crz(" (grsp-n2s (/ (qconst "Pi") 2)) (g2q-txt 4) p_l1 "[" (grsp-n2s p_y1) "]," p_l2 "[" (grsp-n2s p_y2) (g2q-txt 3)) 0)))


;; cu1 - Gate cu1, controlled phase rotation expressed atomically.
;;
;; Arguments:
;; - p_la: angle 1.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2.
;;
(define (cu1 p_la p_l1 p_y1 p_l2 p_y2)
  (let ((la (* p_la 0.5)))

    (qcomg "cu1" 0)
    (u1 la p_l1 p_y1)
    (cx p_l1 p_y1 p_l2 p_y2)
    (u1 (* -1.0 la) p_l2 p_y2)
    (cx p_l1 p_y1 p_l2 p_y2)
    (u1 la p_l1 p_y1)
    (qcomg "cu1" 1)))


;; cu1-fast - Gate cu1, controlled phase rotation gate expressed in fast form.
;;
;; Arguments:
;; - p_la: angle 1.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2.
;;
(define (cu1-fast p_la p_l1 p_y1 p_l2 p_y2)
  (display (strings-append (list "cu1(" (grsp-n2s p_la) (g2q-txt 4) p_l1 "[" (grsp-n2s p_y1) "]," p_l2 "[" (grsp-n2s p_y2) (g2q-txt 3)) 0)))


;; cu3 - Gate cu3, controlled U gate expressed atomically.
;;
;; Arguments:
;; - p_la: angle 1.
;; - p_pa: angle 2.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2.
;;
(define (cu3 p_la p_pa p_l1 p_y1 p_l2 p_y2)
  (qcomg "cu3" 0)
  (u1 (* (- p_la p_pa) 0.5) p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (u3 (* (* p_la 0.5) -1.0) 0 (* (* (+ p_pa p_la) 0.5) -1.0) p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (u3 (* p_la 0.5) p_pa 0 p_l2 p_y2)
  (qcomg "cu3" 1))


;; cu3-fast - Gate cu3, controlled U gate expressed in fast form.
;;
;; Arguments:
;; - p_la1: angle 1.
;; - p_la2: angle 2.
;; - p_la3: angle 3.
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2.
;;
(define (cu3-fast p_la1 p_la2 p_la3 p_l1 p_y1 p_l2 p_y2)
  (display (strings-append (list "cu3(" (grsp-n2s p_la1) "," (grsp-n2s p_la2) "," (grsp-n2s p_la3) (g2q-txt 4) p_l1 "[" (grsp-n2s p_y1) "]," p_l2 "[" (grsp-n2s p_y2) (g2q-txt 3)) 0)))


;; g1cxg1 - Puts a set of gates in configuration g1 cx g1.
;;
;; Arguments:
;; - p_n1: g1 gate name.
;; - p_l1: quantum register name (i.e. q).
;; - p_y1: qubit number 1 (control of cx).
;; - p_y2: qubit number 2 (target of cx).
;;
(define (g1cxg1 p_n1 p_l1 p_y1 p_y2)
  (qcomg "g1cxg1" 0)
  (g1 p_n1 p_l1 p_y2)
  (cx p_l1 p_y1 p_l1 p_y2)
  (g1 p_n1 p_l1 p_y2)
  (qcomg "g1cxg1" 1))


;; qendc - Prints a message stating that compilation has ended.
;;
(define (qendc)
  (ptit "=" 60 2 "Compilation completed!"))


;; qregex - Prepares a compiled qasm file as a string for passing to ibm q html
;; api.
;;
;; Arguments
;; - p_f: name of .qasm file.
;;
;; Output: 
;; - It returns p_f as a single string variable without any \r or \n characters.
;;
(define (qregex p_f)
  (let ((res p_f))
    
    (set! res (regexp-substitute/global #f "[\n]+" res 'pre "" 'post))
    (set! res (regexp-substitute/global #f "[\r]+" res 'pre "" 'post))
    (set! res (regexp-substitute/global #f "[\"]+" res 'pre "\\\"" 'post))
    
    res))


;; qreq - Constructs a qreg file.
;;
;; Arguments
;; - p_f1: name of .qasm file.
;; - p_f2: name of .qreg file.
;; - p_r: where results will be saved to:
;;  - "json" to save results to a json file.
;;  - "sqlite3" to save results to a sqlite3 database.
;; - p_d: device.
;; - p_s: shots.
;; - p_m: max credits.
;; - p_e: seed.
;;
;; Sources:
;; - Casey, K. (2017). Archived | Quantum computing in action: IBM's Q experience 
;;   and the quantum shell game. [online] IBM Developer. Available at: 
;;   https://developer.ibm.com/tutorials/os-quantum-computing-shell-game/ 
;;   [Accessed 30 Sep. 2019].
;;
(define (qreq p_f1 p_f2 p_r p_d p_s p_m p_e)
  (let ((port1 (current-output-port))
	(port2 (open-output-file p_f2))
	(conf #f)
	(i1 "")
	(i2 "")
	(i3 "")
	(i4 "")
	(token "")
	(i "")
	(res "")
	(dev p_d)
	(data ""))
    
    (set-port-encoding! port2 "UTF-8")
    
    ;; Get GX conf data
    (set! conf (g2q-ibm-config))
    (set! i1 (car conf))
    (set! token (cadr conf))
    (set! i2 (caddr conf))
    (set! i (string-append i1 i2)) 
    
    ;; Write to .comm file
    (set! data (read-file-as-string p_f1))
    (set! data (qregex data))
    (set-current-output-port port2)
    (qstr (strings-append (list "base-file=" p_f2) 0))
    (qstr " ")
    (qstr (strings-append (list "base-data=" data) 0))
    (qstr " ")
    (qstr (strings-append (list "base-token=" token) 0))
    (qstr " ")
    (qstr (strings-append (list "base-uri=" i1) 0))
    (qstr " ")
    (qstr (strings-append (list "base-results-storage=" p_r) 0))
    (qstr " ")
    (qstr (strings-append (list "base-device=" p_d) 0))
    (qstr " ")
    (qstr (strings-append (list "base-shots=" (number->string p_s)) 0))
    (qstr " ")
    (qstr (strings-append (list "base-seed=" (number->string p_e)) 0))
    (qstr " ")    
    (qstr (strings-append (list "base-max-credits=" (number->string p_m)) 0))
    (qstr " ")
    (qstr (strings-append (list "login-data=" "apiToken=" token) 0))
    (qstr " ")    
    (qstr (strings-append (list "login-uri=" i1 "/users/loginWithToken") 0))
    (qstr " ")
    (qstr (strings-append (list "login-id=" "wait-until-login") 0))
    (qstr " ")
    (qstr (strings-append (list "post-content-type=" (g2q-txt 8) (g2q-txt 7)) 0))
    (qstr " ")
    (qstr (strings-append (list "post-uri=" (string-append i1 i2)) 0))
    (qstr " ")
    (qstr (strings-append (list "get-content-type=" (g2q-txt 8) (g2q-txt 7)) 0))
    (qstr " ")
    (qstr (strings-append (list "get-uri=" (string-append i1 i3)) 0))
    (qstr " ")
    (qstr (strings-append (list "delete-content-type=" (g2q-txt 8) (g2q-txt 7)) 0))
    (qstr " ")
    (qstr (strings-append (list "delete-uri=" (string-append i1 i4)) 0))
    (qstr " ")
    (set-current-output-port port1)
    (close port2)))


;; qcnot1 - A cx based NOT gate expressed atomically.
;;
;; Arguments:
;; - p_l1: gate group name 1.
;; - p_y1: target qubit, normally p_y2 - 1.
;; - p_l2: gate group name 2.
;; - p_y2: control quibit, value to be inverted, 0 or 1.
;;
;; Output:
;; - Inverse of p_l2[p_y2], on p_l1[p_y1].
;;  - |0> -> |1>
;;  - |1> -> |0>
;;
(define (qcnot1 p_l2 p_y2 p_l1 p_y1)
  (qcomg "qcnot1" 0) 
  (g1 "x" p_l1 p_y1)
  (cx p_l2 p_y2 p_l1 p_y1)
  (qcomg "qcnot1" 1))


;; qxor1 - A qcnot1 based XOR gate expressed atomically.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: target qubit a, normally p_y2 - 1.
;; - p_l2: quantum register name 2.
;; - p_y2: control qubit a.
;; - p_l3: quantum register name 3.
;; - p_y3: target qubit b, normally p_y3 - 1.
;; - p_l4: quantum register name 4.
;; - p_y4: control qubit b.
;;
;; Output:
;; - On p_l1[p_y1].
;;   - |00> -> |0>
;;   - |11> -> |0>
;;   - |01> -> |1>
;;   - |10> -> |1>
;;
(define (qxor1 p_l1 p_y1 p_l2 p_y2 p_l3 p_y3 p_l4 p_y4)
  (qcomg "qxor1" 0)
  (qcnot1 p_l2 p_y2 p_l1 p_y1)
  (qcnot1 p_l4 p_y4 p_l3 p_y3)
  (qcnot1 p_l3 p_y3 p_l1 p_y1)
  (qcomg "qxor1" 1))


;; qfclvr - Find and construct label and value registers.
;;
;; Arguments:
;; - p_s: string with results from qre.
;;
;; Output:
;; - A list contaning two lists:
;; - The first list contains labels.
;; - Second list contains results.
;;
(define (qfclvr p_s)
  (let ((res (list ))
	(s1 p_s)
	(ls1 0)
	(slabels "")
	(svalues "")
	(lslabels (list ))
	(lsvalues (list )))

    ;; Construct strings from relevant data.
    (set! ls1 (string-length s1))
    (set! slabels (substring s1 (string-contains s1 "labels")))
    (set! svalues (substring slabels (string-contains slabels "values")))
    (set! slabels (substring slabels (string-contains slabels "[")))
    (set! svalues (substring svalues (string-contains svalues "[")))    
    (set! slabels (substring slabels (+ (string-contains slabels "[") 1)))
    (set! svalues (substring svalues (+ (string-contains svalues "[") 1)))
    (set! slabels (string-copy slabels 0 (string-contains slabels "]")))
    (set! svalues (string-copy svalues 0 (string-contains svalues "]")))   

    ;; Clean strings.
    (set! slabels (regexp-substitute/global #f "u" slabels 'pre "" 'post))
    (set! slabels (regexp-substitute/global #f "'" slabels 'pre "" 'post))
    (set! slabels (regexp-substitute/global #f "," slabels 'pre " " 'post))
    (set! svalues (regexp-substitute/global #f "," svalues 'pre " " 'post))
    (set! slabels (regexp-substitute/global #f "  " slabels 'pre " " 'post))
    (set! svalues (regexp-substitute/global #f "  " svalues 'pre " " 'post))

    ;; Construct lists from strings.
    (set! lslabels (string-split slabels #\space ))
    (set! lsvalues (string-split svalues #\space ))
    (set! res (list lslabels lsvalues))
        
    res))
	

;; qfres - Find max or min value among results. If more than one ocurrence
;; is found, it returns the last label corresponding to the last element that
;; matches.
;;
;; Arguments:
;; - p_l: list of results as obtained by applying qfclvr.
;; - p_r: choice between obtaining the max or min value.
;;   - "max" for maximum value.
;;   - "min" to get the minimum value.
;;
;; Output:
;; - A list of two elements:
;;   - First element contains the label of the result.
;;   - Second element contains the max value obtained.
;;
(define (qfres p_l p_r)
  (let ((res (list ))
	(sl (car p_l))
	(sv (car (cdr p_l)))
	(dvm 0)
	(dv (list ))
	(n 0)
	(slm (g2q-txt 9)))

    ;; Find value.
    (set! dv (map string->number sv))
    (if (equal? p_r "max")
	(set! dvm (apply max dv)))
    (if (equal? p_r "min")
	(set! dvm (apply min dv)))
    
    ;; Get the corresponding label.
    (set! n (- (length dv) 1))
    (while (>= n 0)
	   (if (= dvm (list-ref dv n))
	       (begin (set! slm (list-ref sl n))
		      (set! n 0)))
	   (set! n (- n 1)))
    (set! res (list slm dvm))
    
    res))
    

;; swap-fast - Swap gate expressed in fast form.
;;
;; Arguments:
;; - p_l1: quantum register name. 
;; - p_y1: qubit 1.
;; - p_y2: qubit 2. 
;;
(define (swap-fast p_l1 p_y1 p_y2)
  (display (strings-append (list "swap " (qbgna p_l1 p_y1) "," (qbgna p_l1 p_y2) (g2q-txt 2)) 0)))


;; qftyn - Quantum Fourier Transformation for n qubits in the range
;; [p_l1[p_y1] : p_l2[p_y2]]. Note that this function assumes that all qubits
;; in the quantum register are  interconnected. In some QPU architectures this
;; may not be possible. Expressed atomically.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1, min limit of the range.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2, max limit of the range.
;;
;; Sources:
;; - IBM Q Experience. (2019). IBM Q Experience. [online] Available at:
;;   https://quantum-computing.ibm.com/support/guides/quantum-algorithms-with-qiskit?
;;   page=5cbc5e2d74a4010049e1a2b0#qiskit-implementation [Accessed 7 Oct. 2019].
;; - En.wikipedia.org. (2019). Quantum Fourier transform. [online] Available at:
;;   https://en.wikipedia.org/wiki/Quantum_Fourier_transform [Accessed 7 Oct. 2019].
;;
(define (qftyn p_l1 p_y1 p_l2 p_y2)
  (let ((i p_y1)
	(j 0))
    
    (qcomg "qftyn" 0)    
    (while (<= i p_y2)
	   (g1 "h" p_l1 i)
	   (set! j (+ i 1))
	   (while (<= j p_y2)
		  (cu1 (/ (qconst "Pi") (expt 2 (- j i))) p_l1 j p_l2 i)
		  (set! j (+ j 1)))
	   (set! i (+ i 1)))
    (qcomg "qftyn" 1)))

	  
;; qftdgyn - Function qftyn dagger, expressed atomically.
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1, min limit of the range.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2, max limit of the range.
;;
;; Remarks:
;; - See the comments for qftyn.
;;
;; Sources:
;; - IBM Q Experience. (2019). IBM Q Experience. [online] Available at:
;;   https://quantum-computing.ibm.com/support/guides/quantum-algorithms-with-qiskit?
;;   page=5cc0b79786b50d00642353b9#qiskit-implementation-1 [Accessed 7 Oct. 2019].
;;
(define (qftdgyn p_l1 p_y1 p_l2 p_y2)
  (let ((i p_y1)
	(j 0)
	(k 0))
    
    (qcomg "qftdgyn" 0)
    (while (<= i p_y2)
	   (set! j (- (- p_y2 1) i))
	   
	   ;; PATCH: j does not behave well. Sometimes acquires -1 as value.
	   ;; this produces an error at least when using qx_simulator.
	   (cond ((< j 0)
		  (set! j 0)))
	   
	   (while (<= k j)
		  (cu1 (/ (qconst "Pi") (expt 2 (- j k))) p_l1 j p_l2 k)
		  (set! k (+ k 1)))
	   (g1 "h" p_l1 j)
	   (set! i (+ i 1)))
  (qcomg "qftdgyn" 1)))


;; cswap - Gate Fredkin in atomic form. Swaps p_y2 and p_y3 if p_y1 is |1> 
;; (controlled swap).
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;; - p_l2: quantum register name 2.
;; - p_y2: qubit 2.
;; - p_l3: quantum register name 3.
;; - p_y3: qubit 3.
;;
;; Sources:
;; - Nguyen, T. and Meter, R. (2019). A Resource-Efficient Design for a Reversible
;;   Floating Point Adder in Quantum Computing. [online] Semanticscholar.org.
;;   Available at: https://www.semanticscholar.org/paper/A-Resource-Efficient-Design-
;;   for-a-Reversible-Point-Nguyen-Meter/697e4fd8282e1b3cc151956bbb302b0b8e7df22b/
;;   figure/13 [Accessed 7 Oct. 2019].
;; - En.wikipedia.org. (2019). Quantum logic gate. [online] Available at:
;;   https://en.wikipedia.org/wiki/Quantum_logic_gate [Accessed 7 Oct. 2019].
;;
(define (cswap p_l1 p_y1 p_l2 p_y2 p_l3 p_y3)
  (qcomg "cswap" 0)
  (cx p_l3 p_y3 p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "h" p_l3 p_y3)
  (g1 "t" p_l1 p_y1)
  (g1 "tdg" p_l2 p_y2)
  (g1 "t" p_l3 p_y3)
  (cx p_l3 p_y3 p_l2 p_y2)
  (cx p_l1 p_y1 p_l3 p_y3)
  (g1 "t" p_l2 p_y2)
  (g1 "tdg" p_l3 p_y3)  
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "tdg" p_l2 p_y2)
  (cx p_l1 p_y1 p_l3 p_y3)
  (cx p_l3 p_y3 p_l2 p_y2)
  (g1 "t" p_l2 p_y2)
  (g1 "h" p_l3 p_y3)
  (cx p_l3 p_y3 p_l2 p_y2)  
  (qcomg "cswap" 1))


;; cx-ladder - Creates a ladder of succesive cx gates from p_l1[p_y1] to
;; p_l1[p_y2] according to :
;; - If p_y1 < p_y2: ladder goes from lower element number to greater
;;   element number on the registry.
;; - If p_y1 = p_y2: the fuunction behaves as a single cx gate.
;; - if p_y1 > p_y2: the ladder goes from higher to lower registry element.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit 1, control qubit of the cx gate where the ladder begins.
;; - p_y2: qubit 2, target qubit of the cx gate where the ladder ends.
;; - p_s: mode:
;;   - 1: descending ladder, control qubit on top (p_y1).
;;   - 2: ascending ladder, control qubit on top (p_y1).
;;   - 3: descending ladder, control qubit on bottom (p_y2).
;;   - 4: ascending ladder, control qubit on bottom (p_y2).
;;
(define (cx-ladder p_l1 p_y1 p_y2 p_s)
  (qcomg "cx-ladder" 0)
  (cond ((equal? p_y1 p_y2)(cx p_l1 p_y1 p_l1 p_y2))
        ;; Control qubit on top, descending.
	((equal? p_s 1)(begin (let loop ((i1 p_y1))
				 (if (equal? i1 (- p_y2 1))
				     (cx p_l1 i1 p_l1 p_y2)
				     (begin (cx p_l1 i1 p_l1 (+ i1 1))
					    (loop (+ i1 1)))))))
        ;; Control qubit on top, ascending.
	((equal? p_s 2)(begin (let loop ((i1 (- p_y1 1)))
				 (if (equal? i1 p_y2)
				     (cx p_l1 p_y2 p_l1 (+ i1 1))
				     (begin (cx p_l1 i1 p_l1 (+ i1 1))
					    (loop (- i1 1)))))))
        ;; Control qubit on bottom, descending.
	((equal? p_s 3)(begin (let loop ((i1 p_y1))
				 (if (equal? i1 (- p_y2 1))
				     (cx p_l1 p_y2 p_l1 i1)
				     (begin (cx p_l1 (+ i1 1) p_l1 i1)
					    (loop (+ i1 1)))))))	
        ;; Control qubit on bottom, ascending.
	((equal? p_s 4)(begin (let loop ((i1 p_y1))
				 (if (equal? i1 (+ p_y2 1))
				     (cx p_l1 i1 p_l1 p_y2)
				     (begin (cx p_l1 i1 p_l1 (- i1 1))
					    (loop (- i1 1))))))))
  (qcomg "cx-ladder" 1))


;; swap-fast-ladder - Creates a ladder of succesive swap-fast gates from
;; p_l1[p_y1] to  p_l1[p_y2] according to:
;; - If p_y1 < p_y2: ladder goes from lower element number to greater
;;   element number on the registry.
;; - If p_y1 = p_y2: the fuunction behaves as a single swap-fast gate.
;; - if p_y1 > p_y2: the ladder goes from higher to lower registry element.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit 1, lower registry number qubit where the ladder begins.
;; - p_y2: qubit 2, higher registry number qubit where the ladder ends.
;; - p_s: mode:
;;   - 1: descending ladder.
;;   - 2: ascending ladder.
;;
(define (swap-fast-ladder p_l1 p_y1 p_y2 p_s)
  (qcomg "swap-fast-ladder" 0)
  (cond ((equal? p_y1 p_y2)(swap-fast p_l1 p_y1 p_y2))
        ;; Descending.
	((equal? p_s 1)(begin (let loop ((i1 p_y1))
				 (if (equal? i1 (- p_y2 1))
				     (swap-fast p_l1 i1 p_y2)
				     (begin (swap-fast p_l1 i1 (+ i1 1))
					    (loop (+ i1 1)))))))
        ;; Ascending.
	((equal? p_s 2)(begin (let loop ((i1 (- p_y1 1)))
				 (if (equal? i1 p_y2)
				     (swap-fast p_l1 p_y2 (+ i1 1))
				     (begin (swap-fast p_l1 i1 (+ i1 1))
					    (loop (- i1 1))))))))
  (qcomg "swap-fast-ladder" 1))


;; swap-ladder - Creates a ladder of succesive swap gates from
;; p_l1[p_y1] to  p_l1[p_y2] according to :
;; - If p_y1 < p_y2: ladder goes from lower element number to greater
;;   element number on the registry.
;; - If p_y1 = p_y2: the fuunction behaves as a single swap gate.
;; - if p_y1 > p_y2: the ladder goes from higher to lower registry element.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit 1, lower registry number qubit where the ladder begins.
;; - p_y2: qubit 2, higher registry number qubit where the ladder ends.
;; - p_s1: mode:
;;  - 1: descending ladder.
;;  - 2: ascending ladder.
;;
(define (swap-ladder p_l1 p_y1 p_y2 p_s1)
  (qcomg "swap-ladder" 0)
  (cond ((equal? p_y1 p_y2)(swap p_l1 p_y1 p_y2))
        ;; Descending.
	((equal? p_s1 1)(begin (let loop ((i1 p_y1))
				 (if (equal? i1 (- p_y2 1))
				     (swap p_l1 i1 p_y2)
				     (begin (swap p_l1 i1 (+ i1 1))
					    (loop (+ i1 1)))))))
        ;; Ascending.
	((equal? p_s1 2)(begin (let loop ((i1 (- p_y1 1)))
				 (if (equal? i1 p_y2)
				     (swap p_l1 p_y2 (+ i1 1))
				     (begin (swap p_l1 i1 (+ i1 1))
					    (loop (- i1 1))))))))
  (qcomg "swap-ladder" 1))


;; ghzy - Prepares a GHX state for the interval of qubits defined by 
;; (- p_y2 p_y1) if the interval is equal or greater than three. Note that
;; this only prepares a GHZ state on y qubits. It does not make any 
;; measurement nor defines any measurement bases. You need to provide 
;; those steps separatedly. This function is a generalization to y qubits
;; from a basic three-qubit case.
;;
;; Arguments:
;; - p_n1: quantum gate 1 (i.e. "h").
;; - p_n2: quantum gate 2 (i.e. "x").
;; - p_l1: quantum register name (i.e. "q").
;; - p_y1: qubit 1, lower registry qubit of the GHZ array.
;; - p_y2: qubit 2, higher registry qubit of the GHZ array.
;; - p_s1: mode:
;;   - 1: descending order.
;;   - 2: ascending order.
;;
;; Remarks:
;; - If p_s1 = 1, qubit p_y2 contains the non - Hadamard gate.
;; - If p_s1 = 2, qubit p_y1 contains the non - Hadamard gate.
;; - This function places a barrier on all involved qubits after its relevant code.
;;
; Sources:
;; - IBM Q Experience. (2019). IBM Q Experience. [online] Available at:
;;   https://quantum-computing.ibm.com/support/guides/user-guide?
;;   page=5ddae9d75d640300671cc60f [Accessed 16 Dec. 2019].
;; - En.wikipedia.org. (2019). Greenberger–Horne–Zeilinger state. [online] Available at:
;;   https://en.wikipedia.org/wiki/Greenberger%E2%80%93Horne%E2%80%93Zeilinger_state
;;   [Accessed 16 Dec. 2019].
;; - Uchida, G., Bertlmann, R. and Hiesmayr, B. (2019). Entangled entanglement: A
;;   construction procedure. [online] Arxiv.org. Available at:
;;   https://arxiv.org/abs/1410.7145 [Accessed 21 Dec. 2019].
;; - Cruz, D., Fournier, R., Gremion, F., Jeannerot, A., Komagata, K., Tosic,
;;   T., Thiesbrummel, J., Chan, C., Macris, N., Dupertuis, M. and Javerzac‐Galy, C.
;;   (2019). Efficient Quantum Algorithms for GHZ and W States, and Implementation
;;   on the IBM Quantum Computer. [online] Wiley Online Library. Available at:
;;   https://onlinelibrary.wiley.com/doi/full/10.1002/qute.201900015 
;;   [Accessed 21 Dec. 2019].
;;
(define (ghzy p_n1 p_n2 p_l1 p_y1 p_y2 p_s1)
  (let ((d (- p_y2 p_y1))
	(y1 p_y1)
	(y2 p_y2)
	(s1 1))
    
    (qcomg "ghzy" 0)
    (cond ((equal? p_s1 1)(set! s1 p_s1))
	  ((equal? p_s1 2)(set! s1 p_s1))
	  (else (set! s1 1)))	   
    (cond ((> d 1)
	   (begin (cond ((equal? s1 1)
			 (begin (qcomg "ghzy ladder ascending" 0)
				(g1y p_n1 p_l1 p_y1 (- p_y2 1))
				(g1 p_n2 p_l1 p_y2)

				;; cx ascending ladder.
				(let loop ((i1 y2))
				  (if (equal? i1 (+ p_y1 1))
				      (cx p_l1 p_y1 p_l1 p_y2)					  
				      (begin (cx p_l1 (- i1 1) p_l1 p_y2)
					     (loop (- i1 1)))))))				    
			((equal? s1 2)
			 (begin (qcomg "ghzy ladder descending" 0)
				(g1 p_n2 p_l1 p_y1)
				(g1y p_n1 p_l1 (+ p_y1 1) p_y2)
				
				;; cx descending ladder
				(let loop ((i1 y1))
				  (if (equal? i1 (- p_y2 1))
				      (cx p_l1 p_y2 p_l1 p_y1)
				      (begin (cx p_l1 (+ i1 1) p_l1 p_y1)
					     (loop (+ i1 1)))))))))
			       
	   ;; Finish the structure.
	   (qcomg "ghzy ladder" 1)  
	   (g1y p_n1 p_l1 p_y1 p_y2)
	   (g1y "barrier" p_l1 p_y1 p_y2)))
    (qcomg "ghzy" 1)))


;; g1yl - Places gates on y axis according to list p_l. This allows you to set
;; a complete array of gates at once. While setting gates at a given execution
;; step can be achieved by means of other functions, g1y1 is yet another
;; option that might be more convenient at times, for example, when you want
;; to define an array of gates for a given time step procedureally depending
;; on certain factors such as the kind of reading that you might want to 
;; perform after a certain operation such as a GHZ state preparation.
;;
;; Arguments:
;; - p_l1: quantum register name (.e. "q").
;; - p_l2: list of strings defining the order on y axis of gates to be placed 
;;   (i.e. '("h" "h" "s") in the case of a three qubit system in which to place 
;;   h gates on the first and second, and an s gate on the third.
;; - p_y1: qubit 1, lower registry qubit
;;
;; Remarks:
;; - You might want to place a barrier on all qubits before or after calling
;;   this function. g1y1 does not place any barriers by itself, so if that is
;;   your choice, you would have to place your barrier(s) using the appropriate
;;   function calls.
;;
(define (g1yl p_l1 p_l2 p_y1)
  (let ((l (length p_l2))
	(v 0))

    (qcomg "g1y1" 0)
    (let loop ((i1 p_y1))
      (if (equal? i1 (- (+ l p_y1) 1))
	  (g1 (list-ref p_l2 v) p_l1 i1)
	  (begin (g1 (list-ref p_l2 v) p_l1 i1)
		 (set! v (+ v 1))
		 (loop (+ i1 1)))))
    (qcomg "g1y1" 1)))


;; ecc1 - Error correcting code. Encoder into bit flip code for qubits
;; [p_y1, p_y1+2].
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;;
;; Sources:
;; - IBM Quantum Experience. 2020. IBM Quantum Experience - Docs And Resources.
;;   [online] Available at:
;;   https://quantum-computing.ibm.com/docs/guide/err-corxn/quantum-repetition-code
;;   [Accessed 16 April 2020].
;;
;; Notes:
;; - Code adapted from sources.
;;
(define (ecc1 p_l1 p_y1)
  (let ((y1 p_y1)
	(y2 (+ p_y1 1))
	(y3 (+ p_y1 2)))
    (qcomg "ecc1" 0)
    (g1y "h" p_l1 y1 y3)    
    (g1 "t" p_l1 y2)
    (g1x "h" p_l1 y2 2)    
    (cx p_l1 y1 p_l1 y2)
    (g1 "h" p_l1 y1)
    (cx p_l1 y3 p_l1 y2)
    (g1y "h" p_l1 y2 y3) 
    (qcomg "ecc1" 1)))
  

;; ecc2 - Error correcting code. Reversible majority select by vote function for
;; decoding a selectable bit-flip gate passed as p_n1. Requres three qubits in
;; array p_l1 and interval [p_y1, p_y1+2].
;;
;; Arguments:
;; - p_n1: name of the gate to be tested.					;
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;;
;; Sources:
;; - IBM Quantum Experience. 2020. IBM Quantum Experience - Docs And Resources.
;;   [online] Available at:
;;   https://quantum-computing.ibm.com/docs/guide/err-corxn/quantum-repetition-code
;;   [Accessed 16 April 2020].
;;
;; Notes:
;; - Code adapted from sources.
;;
(define (ecc2 p_n1 p_l1 p_y1)
  (let ((y1 p_y1)
	(y2 (+ p_y1 1))
	(y3 (+ p_y1 2)))
    (qcomg "ecc2" 0)
    (g1y "h" p_l1 y1 y3)
    (g1 "h" p_l1 y2)
    (cx p_l1 y1 p_l1 y2)
    (g1 "h" p_l1 y1)
    (cx p_l1 y3 p_l1 y2)
    (g1 p_n1 p_l1 y1)
    (g1y "h" p_l1 y2 y3)
    (g1y p_n1 p_l1 y1 y3)
    (g1y p_n1 p_l1 y1 y3)    
    (g1 "h" p_l1 y1)
    (g1y p_n1 p_l1 y2 y3)
    (g1y "h" p_l1 y2 y3)
    (cx p_l1 y3 p_l1 y2)
    (cx p_l1 y1 p_l1 y2)    
    (g1 "h" p_l1 y3)
    (g1 "h" p_l1 y1)
    (cx p_l1 y3 p_l1 y2)
    (g1 "tdg" p_l1 y2)
    (cx p_l1 y1 p_l1 y2)    
    (g1 "t" p_l1 y2)
    (cx p_l1 y3 p_l1 y2)
    (g1 "tdg" p_l1 y2)
    (cx p_l1 y1 p_l1 y2)    
    (g1 "t" p_l1 y2)
    (g1 "h" p_l1 y2)
    (g1 "h" p_l1 y2) ; Check if this replaces (g1 "bloch" p_l1 y2) of the original buggy IBM's code.
    (qcomg "ecc2" 1)))


;; ecc3 - Error correcting code. Encoder into bit flip code with parity checks for 
;; for qubits p_y1, p_y1+1, p_y1+4 using qubits [p_y1, p_y1+4].
;;
;; Arguments:
;; - p_l1: quantum register name 1.
;; - p_y1: qubit 1.
;;
;; Sources:
;; - IBM Quantum Experience. 2020. IBM Quantum Experience - Docs And Resources.
;;   [online] Available at:
;;   https://quantum-computing.ibm.com/docs/guide/err-corxn/quantum-repetition-code
;;   [Accessed 16 April 2020].
;;
;; Notes:
;; - Code adapted from sources.
;;
(define (ecc3 p_l1 p_y1)
  (let ((y1 p_y1)
	(y2 (+ p_y1 1))
	(y3 (+ p_y1 2))
	(y4 (+ p_y1 3))
	(y5 (+ p_y1 4)))
    
    (qcomg "ecc3" 0)
    (g1y "h" p_l1 y1 y5)
    (g1 "t" p_l1 y3)    
    (g1x "h" p_l1 y3 2)
    (cx p_l1 y2 p_l1 y3)
    (cx p_l1 y1 p_l1 y3)
    (g1y "h" p_l1 y1 y2)
    (cx p_l1 y4 p_l1 y3)
    (g1y "h" p_l1 y3 y4)
    (cx p_l1 y4 p_l1 y3)
    (cx p_l1 y1 p_l1 y3)   
    (cx p_l1 y2 p_l1 y3)
    (g1 "h" p_l1 y3)
    (cx p_l1 y5 p_l1 y3)    
    (g1 "h" p_l1 y3)
    (g1 "h" p_l1 y5)
    (cx p_l1 y5 p_l1 y3)
    (cx p_l1 y2 p_l1 y3)    
    (cx p_l1 y4 p_l1 y3)	
    (qcomg "ecc3" 1)))


;; hx - Gate hx, places an h gate followed by an x on element p_y1 of register p_l1.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit number.
;;
(define (hx p_l1 p_y1)
  (qcomg "hx" 0)
  (g1 "h" p_l1 p_y1)
  (g1 "x" p_l1 p_y1)
  (qcomg "hx" 1))


;; hy - Gate hy, places an h gate followed by an y on element p_y1 of register p_l1.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit number.
;;
(define (hy p_l1 p_y1)
  (qcomg "hy" 0)
  (g1 "h" p_l1 p_y1)
  (g1 "y" p_l1 p_y1)
  (qcomg "hy" 1))


;; hz - Gate hz, places an h gate followed by an z on element p_y1 of register
;; p_l1.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit number.
;;
(define (hz p_l1 p_y1)
  (qcomg "hz" 0)
  (g1 "h" p_l1 p_y1)
  (g1 "z" p_l1 p_y1)
  (qcomg "hz" 1))


;; hs - Gate hs, places an h gate followed by an s on element p_y1 of register
;; p_l1.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit number.
;;
(define (hs p_l1 p_y1)
  (qcomg "hs" 0)
  (g1 "h" p_l1 p_y1)
  (g1 "s" p_l1 p_y1)
  (qcomg "hs" 1))


;; hsdg - Gate hsdg, places an h gate followed by an sdag on element p_y1 of
;; register p_l1.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit number.
;;
(define (hsdg p_l1 p_y1)
  (qcomg "hsdg" 0)
  (g1 "h" p_l1 p_y1)
  (g1 "sdg" p_l1 p_y1)
  (qcomg "hsdg" 1))


;; ht - Gate ht, places an h gate followed by a t on element p_y1 of register
;; p_l1.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit number.
;;
(define (ht p_l1 p_y1)
  (qcomg "ht" 0)
  (g1 "h" p_l1 p_y1)
  (g1 "t" p_l1 p_y1)
  (qcomg "ht" 1))


;; htdg - Gate htdg, places an h gate followed by a tdag on element p_y1 of
;; register p_l1.
;;
;; Arguments:
;; - p_l1: quantum register name.
;; - p_y1: qubit number.
;;
(define (htdg p_l1 p_y1)
  (qcomg "htdg" 0)
  (g1 "h" p_l1 p_y1)
  (g1 "tdg" p_l1 p_y1)
  (qcomg "htdg" 1))

