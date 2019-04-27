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


; Config for IBM Quantum Experience and Qiskit. This still needs development in
; but might be needed to test QASM prorams on IBM Q processors.


(define-module (g2q g2q1)
  #:export (g2q-version
	    g2q-ibm-config
	    g2q-qre-config))


; g2q-version - returns the current version of the compiler.
;
(define (g2q-version)
  (let ((res "g2q - v1.2.0"))
    res))


; TODO : configuration for using IBM Q series machines; equivalent to functions
; found on Qiskit IDE. (Deprecated)
;
; Elements:
; 1 - Base uri for online access.
; 2 - token.
; 3 - subdir to post https execution requests.
;
(define (g2q-ibm-config)
  (let ((conf (list "https://quantumexperience.ng.bluemix.net/api" "your-token-goes-here" "/codes/execute")))
    conf
    ))


; Configuration for using qre
;
; Elements:
; 1 - json subdir.
; 2 - sqlite3 subdir.
; 3 - default qpu.
;
(define (g2q-qre-config)
  (let ((conf (list "data/json/" "data/sqlite3/" "qlib_simulator" "ibmqx_simulator" "qx_simulator")))
    conf
    ))





