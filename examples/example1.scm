#! /usr/local/bin/guile -s
!#


; example1.scm
; A sample of different gates and functions of g2q.


; Modules
(use-modules (g2q g2q0))
(use-modules (g2q g2q2))


; Vars and initial stuff.
(define fname "example1.qasm")
(define qver 2.0)
(define q "q")
(define c "c")


; QASM program
(define port1 (current-output-port))
(define port2 (open-output-file fname))
(set-current-output-port port2)
(qhead fname qver)
(qregdef q 3 c 2)
(qregdef q 3 c 2)
(qcomm "Resetting")
(g1y "reset" q 0 4)
(g1 "h" q 0)
(g1y "barrier" q 0 2)
(qmeas q 0 c 0)
(qmeas q 1 c 1)
(qcond "==" q 0 1)(g1 "x" q 0)
(qcond "==" q 0 2)(g1 "x" q 2)
(qcond "==" q 0 3)(g1 "x" q 1)
(qmeas q 0 c 0)
(qmeas q 1 c 1)
(qmeas q 2 c 2)
(set-current-output-port port1)
(close port2)
(pline "-" 20)
