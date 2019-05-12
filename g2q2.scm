; ==============================================================================
;
; q2q2.scm
;
; Structures made of fundamental gates.
;
; Sources: 
;
; - https://arxiv.org/abs/1707.03429 , arXiv:1707.03429v2 [quant-ph] , Open Quantum Assembly Language, Andrew W. Cross, Lev S. Bishop, John A. Smolin, Jay M. Gambetta.
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


(define-module (g2q g2q2)
  #:use-module (g2q g2q0)
  #:use-module (g2q g2q1)
  #:use-module (grsp grsp0)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:export (qconst
	    g1y
	    g1x
	    g1xy
	    qmeasy
	    cx
	    cz
	    cy
	    ch
	    ccx
	    rx
	    ry
	    rz
	    crz
	    cu1
	    cu3
	    g1cxg1
	    qendc
	    qregex
	    qreq
	    qcnot1
	    qxor1
	    qfclvr
	    qfres))


; qconst - various required constants.
;
; Arguments:
; - p_n1: constant name, string.
;
(define (qconst p_n1)
  (let ((res 0))
    (cond ((equal? p_n1 "Pi")(set! res 3.14159))
	  ((equal? p_n1 "gr")(set! res 1.00))
	  (else (set! res 0)))
    res))


; g1y - repeats placement of gate p_n1 and group p_l1 by repeating the use of qgate1
; from qbit p_y1 to qbit p_y2 on y axis (vertically).
;
; Arguments:
; - p_n1: gate name.
; - p_l1: gate group identifier.
; - p_y1: initial qubit.
; - p_y2: last qubit.
;
(define (g1y p_n1 p_l1 p_y1 p_y2)
  (let loop ((i p_y1))
    (if (= i p_y2)
	(g1 p_n1 p_l1 i)
	(begin (g1 p_n1 p_l1 i)
	       (loop (+ i 1))))))


; g1x - repeats placement of gate p_n1 and group p_l1 by repeating the use of
; qgate1 from qbit p_y1 to qbit p_y2 on x axis (horizontally).
;
; Arguments:
; - p_n1: gate name.
; - p_l1: gate group identifier.
; - p_y1: number of iterations.
; - p_m1: number of iterations.
;
(define (g1x p_n1 p_l1 p_y1 p_m1)
  (let loop ((i 1))
    (if (= i p_m1)
	(g1 p_n1 p_l1 p_y1)
	(begin (g1 p_n1 p_l1 p_y1)
	       (loop (+ i 1))))))


; g1xy - repeats placement of gate p_n1 and group p_l1 by repeating the use of
; qgate1 from qubit p_y1 to qubit p_y2 on y axis (vertically).
;
; Arguments:
; - p_n1: gate name.
; - p_l1: gate group identifier.
; - p_y1: initial qubit.
; - p_y2: last qubit.
; - p_x1: number if iterations that g1y will be repeated along x.
;
(define (g1xy p_n1 p_l1 p_y1 p_y2 p_x1)
  (let loop ((j 1))
    (if (= j p_x1)
	(g1y p_n1 p_l1 p_y1 p_y2)
	(begin (g1y p_n1 p_l1 p_y1 p_y2)
	       (loop (+ j 1))))))


; qmeasy - Performs measurements on group p_l1 to group p_l2 from p_y1 to p_y2.
;
; Arguments:
; - p_l1: quantum reginster group identifier.
; - p_l2: conventional register group identifier.
; - p_y1: initial qubit.
; - p_y2: last qubit.
;
(define (qmeasy p_l1 p_l2 p_y1 p_y2)
  (let loop ((i p_y1))
    (if (= i p_y2)
	(qmeas p_l1 p_y2 p_l2 p_y2)
	(begin (qmeas p_l1 i p_l2 i)
	       (loop (+ i 1))))))


; cx - gate cx.
;
; Arguments:
; - p_l1: gate group name 1.
; - p_y1: qubit 1 (dot).
; - p_l2: gate group name 2.
; - p_y2: qubit 2 (plus).
;
(define (cx p_l1 p_y1 p_l2 p_y2)
  (g2 "cx" p_l1 p_y1 p_l2 p_y2))


; cz - gate cz, controlled phase.
;
; Arguments:
; - p_l1: gate group indentifier 1
; - p_y1: qbit 1 (dot).
; - p_l1: gate group indentifier 1
; - p_y2: qbit 2 (plus).
;
(define (cz p_l1 p_y1 p_l2 p_y2)
  (g1 "h" p_l1 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "h" p_l2 p_y2))


; cy - gate cy, controlled y.
;
; Arguments:
; - p_l1: gate group indentifier 1
; - p_y1: qubit 1 (dot).
; - p_l1: gate group indentifier 1
; - p_y2: qubit 2 (plus).
;
(define (cy p_l1 p_y1 p_l2 p_y2)
  (g1 "sdg" p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "s" p_l2 p_y2))


; ch - gate ch, controlled h.
;
; Arguments:
; - p_l1: gate group indentifier 1.
; - p_y1: qubit 1 (dot).
; - p_l2: gate group indentifier 2.
; - p_y2: qubit 2 (plus).
;
(define (ch p_l1 p_y1 p_l2 p_y2)
  (g1 "h" p_l2 p_y2)
  (g1 "sdg" p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "h" p_l2 p_y2)
  (g1 "t" p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "t" p_l2 p_y2)
  (g1 "h" p_l2 p_y2)
  (g1 "s" p_l2 p_y2)
  (g1 "x" p_l2 p_y2)
  (g1 "s" p_l1 p_y1))


; ccx - gate ccx - Toffoli.
;
; Arguments:
; - p_l1: gate group indentifier 1.
; - p_y1 qubit 1.
; - p_l2: gate group indentifier 2.
; - p_y2: qubit 2.
; - p_l3: gate group indentifier 3.
; - p_y3: qubit 3.
;
(define (ccx p_l1 p_y1 p_l2 p_y2 p_l3 p_y3)
  (g1 "h" p_l3 p_y3)
  (cx p_l2 p_y2 p_l3 p_y3)
  (g1 "tdg" p_l3 p_y3)
  (cx p_l1 p_y1 p_l3 p_y3)
  (g1 "t" p_l3 p_y3)
  (cx p_l2 p_y2 p_l3 p_y3)
  (g1 "t" p_l3 p_y3)
  (cx p_l1 p_y1 p_l3 p_y3)
  (g1 "t" p_l2 p_y2)
  (g1 "t" p_l3 p_y3)
  (g1 "h" p_l3 p_y3)
  (cx p_l1 p_y1 p_l2 p_y2)
  (g1 "t" p_l1 p_y1)
  (g1 "tdg" p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2))


; rx - gate rx, rotation around X-axis.
;
; Arguments:
; - p_t: theta angle.
; - p_l1: gate group indentifier 1.
; - p_y1: qubit 1.
;
(define (rx p_t p_l1 p_y1)
  (let ((y2 (/ (qconst "Pi") 2)))
    (u3 p_t (* y2 -1) y2 p_l1 p_y1)))


; ry - gate ry, rotation around Y-axis.
;
; Arguments:
; - p_t: theta angle.
; - p_l1: gate group indentifier 1.
; - p_y1: qubit 1.
;
(define (ry p_t p_l1 p_y1)
  (u3 p_t 0 0 p_l1 p_y1))


; rz - gate rz, rotation around Z-axis.
;
; Arguments:
; - p_p: phi angle.
; - p_l1: gate group indentifier 1.
; - p_y1: qubit 1.
;
(define (rz p_p p_l1 p_y1)
  (u1 p_p p_l1 p_y1))


; crz - gate crz, controlled rz.
;
; Arguments:
; - p_la: lambda angle.
; - p_l1: gate group indentifier 1.
; - p_y1: qubit 1.
; - p_l2: gate group indentifier 2.
; - p_y2: qubit 2.
;
(define (crz p_la p_l1 p_y1 p_l2 p_y2)
  (let ((la (/ p_la 2)))
    (u1 la p_l2 p_y2)
    (cx p_l1 p_y1 p_l2 p_y2)
    (u1 (* -1.0 la) p_l2 p_y2)
    (cx p_l1 p_y1 p_l2 p_y2)))


; cu1 - gate cu1, controlled phase rotation.
;
; Arguments:
; - p_la: lambda angle.
; - p_l1: gate group indentifier 1.
; - p_y1: qubit 1.
; - p_l2: gate group indentifier 2.
; - p_y2: qubit 2.
;
(define (cu1 p_la p_l1 p_y1 p_l2 p_y2)
  (let ((la (* p_la 0.5)))
    (u1 la p_l1 p_y1)
    (cx p_l1 p_y1 p_l2 p_y2)
    (u1 (* -1.0 la) p_l2 p_y2)
    (cx p_l1 p_y1 p_l2 p_y2)
    (u1 la p_l1 p_y1)))


; cu3 - gate cu3, controlled U.
;
; Arguments:
; - p_la: lambda angle.
; - p_pa: 
; - p_l1: gate group indentifier 1.
; - p_y1: qubit 1.
; - p_l2: gate group indentifier 2.
; - p_y2: qubit 2.
;
(define (cu3 p_la p_pa p_l1 p_y1 p_l2 p_y2)
  (u1 (* (- p_la p_pa) 0.5) p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (u3 (* (* p_la 0.5) -1.0) 0 (* (* (+ p_pa p_la) 0.5) -1.0) p_l2 p_y2)
  (cx p_l1 p_y1 p_l2 p_y2)
  (u3 (* p_la 0.5) p_pa 0 p_l2 p_y2))


; g1cxg1 - Puts a set of gates in configuration g1 cx g1.
;
; Arguments:
; - p_n1: g1 gate name.
; - p_l1: qubit group (q).
; - p_y1: qubit number 1.
; - p_y2: qubit number 2.
;
(define (g1cxg1 p_n1 p_l1 p_y1 p_y2)
  (g1 p_n1 p_l1 p_y2)
  (cx p_l1 p_y1 p_l1 p_y2)
  (g1 p_n1 p_l1 p_y2))


; qendc - prints a message stating that compilation has ended.
;
(define (qendc)
  (ptit "=" 60 2 "Compilation completed!"))


; qregex - Prepares a compiled qasm file as a string for passing to ibm q html
; api.
;
; Arguments
; - p_f: name of .qasm file.
;
; Output: 
; - It returns p_f as a single string variable without any \r or \n characters.
;
(define (qregex p_f)
  (let ((res p_f))
    (set! res (regexp-substitute/global #f "[\n]+" res 'pre "" 'post))
    (set! res (regexp-substitute/global #f "[\r]+" res 'pre "" 'post))
    (set! res (regexp-substitute/global #f "[\"]+" res 'pre "\\\"" 'post))
    res))


; qreq - consturcts a qreg file.
;
; Arguments
; - p_f1: name of .qasm file.
; - p_f2: name of .qreg file.
; - p_r: where results will be saved to:
;   - "json" to save results to a json file.
;   - "sqlite3" to save results to a sqlite3 database.
; - p_d: device.
; - p_s: shots.
; - p_m: max credits.
; - p_e: seed.
;
; Sources:
; - https://developer.ibm.com/tutorials/os-quantum-computing-shell-game/
;
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
    
    ;Get GX conf data
    (set! conf (g2q-ibm-config))
    (set! i1 (car conf))
    (set! token (cadr conf))
    (set! i2 (caddr conf))
    (set! i (string-append i1 i2)) 
    
    ; Write to .comm file
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
    (qstr (strings-append (list "post-content-type=" "application/x-www-form-urlencoded;" "charset=utf-8") 0))
    (qstr " ")
    (qstr (strings-append (list "post-uri=" (string-append i1 i2)) 0))
    (qstr " ")
    (qstr (strings-append (list "get-content-type=" "application/x-www-form-urlencoded;" "charset=utf-8") 0))
    (qstr " ")
    (qstr (strings-append (list "get-uri=" (string-append i1 i3)) 0))
    (qstr " ")
    (qstr (strings-append (list "delete-content-type=" "application/x-www-form-urlencoded;" "charset=utf-8") 0))
    (qstr " ")
    (qstr (strings-append (list "delete-uri=" (string-append i1 i4)) 0))
    (qstr " ")
    (set-current-output-port port1)
    (close port2)))


; qcnot1 - a cx based NOT gate.
;
; Arguments:
; - p_l1: gate group name 1.
; - p_y1: target qubit (normally p_y2 - 1).
; - p_l2: gate group name 2.
; - p_y2: control quibit (value to be inverted, 0 or 1).
;
; Output:
; - Inverse of p_l2[p_y2], on p_l1[p_y1].
;  - |0> -> |1>
;  - |1> -> |0>
;
(define (qcnot1 p_l2 p_y2 p_l1 p_y1)
  (g1 "x" p_l1 p_y1)
  (cx p_l2 p_y2 p_l1 p_y1))


; qxor1 - a qcnot1 based XOR gate.
;
; Arguments:
; - p_l1: gate group name 1.
; - p_y1: target qubit a (normally p_y2 - 1).
; - p_l2: gate group name 2.
; - p_y2: control quibit a.
; - p_l3: gate group name 3.
; - p_y3: target qubit b (normally p_y3 - 1).
; - p_l4: gate group name 4.
; - p_y4: control quibit b.
;
; Output:
; - On p_l1[p_y1].
;  - |00> -> |0>
;  - |11> -> |0>
;  - |01> -> |1>
;  - |10> -> |1>
;
(define (qxor1 p_l1 p_y1 p_l2 p_y2 p_l3 p_y3 p_l4 p_y4)
  (qcnot1 p_l2 p_y2 p_l1 p_y1)
  (qcnot1 p_l4 p_y4 p_l3 p_y3)
  (qcnot1 p_l3 p_y3 p_l1 p_y1))


; qfclvr - Find and construct label and value registers.
;
; Arguments:
; - p_s: string with results from qre.
;
; Output:
; - A list contaning two lists:
; - The first list contains labels.
; - Second list contains results.
;
(define (qfclvr p_s)
  (let ((res (list ))
	(s1 p_s)
	(ls1 0)
	(slabels "")
	(svalues "")
	(lslabels (list ))
	(lsvalues (list )))

    ; Construct strings from relevant data.
    (set! ls1 (string-length s1))
    (set! slabels (substring s1 (string-contains s1 "labels")))
    (set! svalues (substring slabels (string-contains slabels "values")))
    (set! slabels (substring slabels (string-contains slabels "[")))
    (set! svalues (substring svalues (string-contains svalues "[")))    
    (set! slabels (substring slabels (+ (string-contains slabels "[") 1)))
    (set! svalues (substring svalues (+ (string-contains svalues "[") 1)))
    (set! slabels (string-copy slabels 0 (string-contains slabels "]")))
    (set! svalues (string-copy svalues 0 (string-contains svalues "]")))   

    ; Clean strings.
    (set! slabels (regexp-substitute/global #f "u" slabels 'pre "" 'post))
    (set! slabels (regexp-substitute/global #f "'" slabels 'pre "" 'post))
    (set! slabels (regexp-substitute/global #f "," slabels 'pre " " 'post))
    (set! svalues (regexp-substitute/global #f "," svalues 'pre " " 'post))
    (set! slabels (regexp-substitute/global #f "  " slabels 'pre " " 'post))
    (set! svalues (regexp-substitute/global #f "  " svalues 'pre " " 'post))

    ; Construct lists from strings.
    (set! lslabels (string-split slabels #\space ))
    (set! lsvalues (string-split svalues #\space ))
    (set! res (list lslabels lsvalues))
        
    res))
	

; qfres - find max or min value among results. If more than one ocurrence
; is found, it returns the last label corresponding to the last element that
; matches.
;
; Arguments:
; - p_l: List of results as obtained by applying qfclvr.
; - p_r: choice between obtaining the max or min value.
;  - "max" for maximum value.
;  - "min" to get the minimum value.
;
; Output:
; - A list of two elements:
;  - First element contains the label of the result.
;  - Second element contains the max value obtained.
;
(define (qfres p_l p_r)
  (let ((res (list ))
	(sl (car p_l))
	(sv (car (cdr p_l)))
	(dvm 0)
	(dv (list ))
	(n 0)
	(slm "na"))

    ; Find value.
    (set! dv (map string->number sv))
    (if (equal? p_r "max")(set! dvm (apply max dv)))
    (if (equal? p_r "min")(set! dvm (apply min dv)))
    
    ;Ge the corresponding label.
    (set! n (- (length dv) 1))
    (while (>= n 0)
	   (if (= dvm (list-ref dv n))(begin
					(set! slm (list-ref sl n))
					(set! n 0)))
	   (set! n (- n 1)))
    (set! res (list slm dvm))
    res))
    
    


