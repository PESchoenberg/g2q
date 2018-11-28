; ==============================================================================
;
; g2q1.scm
;
; Additional configuratin and machines-specific functions.
;
; Sources:
;
; - https://qiskit.org/documentation/install.html 
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


; Config for IBM Quantum Experience and Qiskit. This still needs development in
; but might be needed to test QASM prorams on IBM Q processors.


; TODO - define config functions to access simulators or actual quantum
; processors, like those provided by IBM.
;
(define-module (g2q g2q1)
  #:export (ibm-apitoken
	    ibm-config))


; TODO: token for using IBM Q series machines; equivalent to functions found on
; Qiskit IDE.
;
(define (ibm-apitoken)
  (let ((token "Your token here."))
  (display token)))


; TODO : configuration for using IBM Q series machines; equivalent to functions
; found on Qiskit IDE.
;
(define (ibm-config)
  (let ((conf(list "url" "Your URL here")))
  (display conf)))

