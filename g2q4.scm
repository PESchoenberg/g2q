;; =============================================================================
;;
;; q2q4.scm
;;
;; Useful algorithms and functions.
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
;;   This program is distributed in the hope that it will be useful,
;;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;   GNU Lesser General Public License for more details.
;;
;;   You should have received a copy of the GNU Lesser General Public License
;;   along with this program. If not, see <https://www.gnu.org/licenses/>.
;;
;; =============================================================================


;;;; General notes:
;; - Read sources for limitations on function parameters.
;;
;; Sources:
;; - [1] Roell, J., 2018. Demystifying Quantum Gates — One Qubit At A Time. [online]
;;   Medium. Available at: https://towardsdatascience.com/demystifying-quantum-gates-one-qubit-at-a-time-54404ed80640
;;   [Accessed 25 April 2020].


(define-module (g2q g2q4)
  #:use-module (g2q g2q0)
  #:use-module (g2q g2q1)
  #:use-module (g2q g2q2)
  #:use-module (g2q g2q3)  
  #:use-module (grsp grsp0)
  #:use-module (grsp grsp1)  
  #:export (qrand1))


;; qrand1 - 4 x 1 universal random quantum circuit .
;;
;; Parameters:
;; - p_l1: quantum register name.
;; - p_y1: qubit number.
;;
;; Sources:
;; - [1][g2q2.[6]] .
;;
(define (qrand1 p_l1 p_y1)
  (let ((y1 p_y1)
	(y2 (+ p_y1 1))
	(y3 (+ p_y1 2))
	(y4 (+ p_y1 3)))

    (qcomg "qrand1" 0)
    (g1y "h" p_l1 y1 y4)
    (cz p_l1 y2 p_l1 y3)
    (g1y "t" p_l1 y2 y3)
    (cz p_l1 y1 p_l1 y2)
    (cz p_l1 y3 p_l1 y4)
    (g1 "t" p_l1 y1)
    (g1 "y" p_l1 y2)
    (g1 "x" p_l1 y3)
    (g1 "t" p_l1 y4)
    (cz p_l1 y2 p_l1 y3)
    (g1 "x" p_l1 y2)
    (g1 "t" p_l1 y3)    	
    (cz p_l1 y1 p_l1 y2)
    (qcomg "qrand1" 1)))

