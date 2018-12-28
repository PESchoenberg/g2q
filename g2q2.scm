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


(define-module (g2q g2q2)
  #:use-module (g2q g2q0)
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
	    pline
	    g1cxg1))


; qconst - various constants.
;
; Arguments:
; - p_n1: constant name, string.
;
(define (qconst p_n1)
  (let ((res 0))
  (cond ((eq? p_n1 "Pi")(set! res 3.14159))
	((eq? p_n1 "gr")(set! res 1.00))
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


; pline - displays character p_n p_m times in one line.
;
; Arguments:
; - p_n: character to display.
; - p_m: line length.
;
(define (pline p_n p_m)
  (let ((str ""))
  (let loop ((i 0))
    (if (= i p_m)
	(begin (newline)(newline)(display str)(newline)(newline))
	(begin (set! str (string-append str p_n))
	       (loop (+ i 1)))))))


; Puts a set of gates in configuration g1 cx g1.
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


