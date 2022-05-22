(include "reactive.scm")

(define x (reactive-var 8))

;; HERE

(reactive-if (fx= (reactive-ref x) 10) (display "egal a 10\n") (display "pas egal a 10\n"))

(reactive-set! x 10)
(reactive-set! x 20)
(reactive-set! x 21)


