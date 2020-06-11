#! /usr/local/bin/guile -s
!#


;; =============================================================================
;;
;; example8.scm
;;
;; This program shows how to use g2q as a just-in-time compiler generating
;; several QASM2 programs dynamically and running them on a QPU.
;;
;; Compilation:
;; - cd to your /examples folder.
;;
;; - Enter the following:
;;
;;   guile example8.scm
;;
;; Notes:
;; - This program will only compile a .qasm file but not run it if you don't have
;; qre installed on your system.
;; - You should make sure that your PATH system variable points to the folder
;; where you installed qre.
;; - qre is available at https://github.com/PESchoenberg/qre
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
	     (g2q g2q2)
	     (grsp grsp0))


;; Vars and initial stuff. 
(define fnameo "example8.qasm")
(define fnamei "data/json/example8_1.json")
(define qver 2.0)
(define q "q")
(define c "c")
(define qn 5)
(define cn 5)
(define mc 0)
(define qx 0)
(define res 0)


;; This function comprises an entire compilation and execution cycle.
;;
;; Arguments:
;; - p_qver: qver.
;; - p_q: q.
;; - p_c: c.
;; - p_qn qn.
;; - p_cn: cn.
;; - p_mc: mc.
;; - p_i: iteration number.
;;
;; Output:
;; - A result that consists in the maximum probability obtaied from the 
;;   execution of the compiled quantum circuit.
;;
(define (compile-and-run p_qver p_q p_c p_qn p_cn p_mc p_i)
  (let ((porto1 (current-output-port))
	(porto2 (open-output-file fnameo))
	(a "")
	(b "")
	(res 0)
	(qqn (- p_qn 1))
	(ccn (- p_cn 1)))

    ;; This configures the output to be sent a file instead of the console.
    (set-current-output-port porto2)

    ;; Creating header and required vectors.
    (qhead fnameo p_qver)
    (qregdef p_q p_qn p_c p_cn)    

    ;; Create circuit. Note that it will be different, depending on the iteration
    ;; number. Note that using an iteration system such as ths one is not the 
    ;; same as increasing the number of shots in qre.cfg. Changing the number of
    ;; shots to say, shots = n means that a given QASM2 code will be iterated n 
    ;; times by the QPU, be it real or simulated, while changing the number of
    ;; qcalls may or may not produce a result similar to a variation of shots.
    ;;
    ;; - If qcalls = shots = n and there is no variaion in the qcircuit between
    ;;   qcalls, then the result will be similar as in the case of pretforming 
    ;;   the experiment in n shots.
    ;;
    ;; - If qcalls != shots or qcalls = shots but qcircuit changes on each qcall 
    ;;   results will be different. in fact, in any of these cases the program 
    ;;   written compiled and executed using g2q and qre will behave as a set of 
    ;;   experiments of cuantums circuits rather than a singe one.
    ;;
    ;; The intersting part of this is that you can introduce more flexibility in
    ;; quantum programs using traditional programming features.
    
    ;; Qcircuit.
    (g1y "h" q 0 qqn)
    (if (= p_i 1)(g1y "x" p_q 0 qqn))
    (if (= p_i 2)(g1y "y" p_q 0 qqn))
    (if (= p_i 3)(g1y "z" p_q 0 qqn))    
    (qmeasy  p_q p_c 0 ccn)
    
    ;; Set the output port again to the console.
    (set-current-output-port porto1)
    (close porto2)

    ;; This is a system call to invoke qre. Replace [your-path-to-qre-folder] with
    ;; the correct path or change your system PATH variable accordingly. You need
    ;; to have g2q and qre included on your system path variable or modify the
    ;; call below to make it work properly. It will also work if you run 
    ;; this program from within the main folder of qre.
    (system "./qre example8.qasm post y qx_simulator 1 example8_1")
    
    ;; Now get the data from the QPU.
    (set! a (read-file-as-string fnamei))
    (set! b (qfclvr a))
    (set! res (car (cdr (qfres b "max"))))
    
    res))
    

;; This is the main loop of the program. It will be repeated p_qx times.
;;
;; Arguments:
;; - p_qver: qver.
;; - p_q: q.
;; - p_c: c.
;; - p_qn qn.
;; - p_cn: cn.
;; - p_mc: mc.
;; - p_qx: qx
;;
;; Output:
(define (main-loop p_qver p_q p_c p_qn p_cn p_mc p_qx)
  (let ((res 0))    
    (let loop ((i p_qx))
      (if (= i 0)
	  res
	  (begin (set! res (+ res (compile-and-run p_qver p_q p_c p_qn p_cn p_mc i)))
		 (loop (- i 1)))))))


;; And this is the main program. It gives as a result the decimal absolute and
;; non-probabilistic summation of the max values obtained on the execution of 
;; each quantum circuit created on each qcall.
(qcomm "Number of QPU call (qcalls): ")
(set! qx (read))
(set! res (main-loop qver q c qn cn mc qx))
(newlines 2)
(display "Result = ")
(display res)
(newlines 1)


