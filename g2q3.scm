;; =============================================================================
;;
;; q2q3.scm
;;
;; Functions that require the use of qre or are qre-related.
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
;;   use. Consider these files as your main documentation for g2q.


(define-module (g2q g2q3)  
  #:use-module (g2q g2q0)
  #:use-module (g2q g2q1)
  #:use-module (g2q g2q2)  
  #:use-module (grsp grsp0)
  #:use-module (ice-9 textual-ports)
  #:export (qcompile-and-run
	    qmain-loop
	    qdeclare))


;;;; qcompile-and-run - This function comprises an entire Scheme to QASM
;; compilation and execution cycle.
;;
;; Parameters:
;;
;; - p_fname: fname.
;; - p_fnameo: fnameo.
;; - p_qver: qver.
;; - p_ddir: ddir.
;; - p_qpu: qpu.
;; - p_qf: quantum function.
;; - p_q: q.
;; - p_c: c.
;; - p_qn qn.
;; - p_cn: cn.
;; - p_mc: mc.
;; - p_i: iteration number.
;; - p_v: verbosity ("y" or "n")
;; - p_rf: results function.
;;
;; Output:
;;
;; - A result that consists of the maximum probability obtained from the 
;;   execution of the compiled quantum circuit.
;;
(define (qcompile-and-run p_fname p_fnameo p_qver p_ddir p_qpu p_qf p_q p_c p_qn p_cn p_mc p_i p_v p_rf)
  (let ((porto1 (current-output-port))
	(porto2 (open-output-file p_fnameo))
	(a "")
	(fget "")
	(fsave "")
	(fnamei "")
	(res1 0)
	(pqn (- p_qn 1))
	(pcn (- p_cn 1)))

    ;; Define the names of the files that we will use.
    (set! fget (strings-append (list p_fname "_" (grsp-n2s p_i)) 0))
    (set! fsave (strings-append (list p_fname "_all_results.json") 0))    
    (set! fnamei (strings-append (list p_ddir fget ".json") 0))     
    
    ;; This configures the output to be sent a file instead of the console.
    (set-current-output-port porto2)

    ;; Creating header and required vectors.
    (qhead p_fnameo p_qver)
    (qregdef p_q p_qn p_c p_cn)    
   
    ;; Qcircuit call. Note that this is a first-class function passed as an
    ;; argument. In this case, the function has itself several arguments that
    ;; could be passed as a a single list argument in the future.
    (p_qf p_i p_q p_c 0 pqn 0 pcn)
    
    ;; Set the output port again to the console.
    (set-current-output-port porto1)
    (close porto2)

    ;; This is a system call to invoke  qre. 
    (system (strings-append (list "./qre"
				  p_fnameo
				  "post"
				  p_v
				  p_qpu
				  "1"
				  fget)
			    1))
    
    ;; Now get the data from the QPU. Here we use again a first order function,
    ;; which is passed as an argument to p_rf.
    (set! a (read-file-as-string fnamei))
    (set! res1 (p_rf (qfclvr a)))
    (grsp-save-to-file a fsave "a")
    
    res1))
    

;;;; qmain-loop - This is the main loop of the program. It will be repeated p_qx
;; times. Note this function will remove the json files holding the results
;; returned by the QPU in order to keep clean the ddir folder.
;;
;; Parameters:
;;
;; - p_clean: "y" to clean data folder.
;; - p_fname: fname.
;; - p_fnameo: fnameo.
;; - p_qver: qver.
;; - p_ddir: ddir.
;; - p_qpu: qpu.
;; - p_qf: quantum function.
;; - p_q: q.
;; - p_c: c.
;; - p_qn qn.
;; - p_cn: cn.
;; - p_mc: mc.
;; - p_qx: qx
;; - p_v: verbosity ("y" or "n").
;; - p_rf: results function.
;;
(define (qmain-loop p_clean p_fname p_fnameo p_qver p_ddir p_qpu p_qf p_q p_c p_qn p_cn p_mc p_qx p_v p_rf)
  (let ((res1 0))
    
    (let loop ((i p_qx))
      (if (= i 0)
	  (begin (if (equal? p_clean "y")
		     (system (strings-append (list "rm "
						   p_ddir
						   p_fname
						   "_*")
					     0)))
		 res1)
	  (begin (set! res1 (+ res1 (qcompile-and-run p_fname
						      p_fnameo
						      p_qver
						      p_ddir
						      p_qpu
						      p_qf
						      p_q
						      p_c
						      p_qn
						      p_cn
						      p_mc
						      i
						      p_v
						      p_rf)))
		 (loop (- i 1)))))))


;;;; qre-declare - Pragmas for specific quantum processors. This function 
;; adds to a program to be compiled in QASM2 declarations for compilation 
;; that are specific for different quantum processors. These are applicable 
;; for the declared qpu, but not others. Pragmas are introduced as comments
;; using the standard double "/" character and thus do not modify the QASM2 
;; code itself. Currently you can use it for writing comments on your QASM2
;; code and for sending special instructions to the qx simulator if you use
;; it.
;; 
;; Parameters:
;;
;; - p_qpu: qpu for which the declaration is intended for.
;; - p_d: declaration in the form of a string.
;;
;; Output:
;;
;; - A commented-out string that will be placed in compiled QADM2 code.
;;
(define (qdeclare p_qpu p_d)
  (qcomm (strings-append (list "qdeclare " p_qpu " " p_d) 0)))


