
(import (_test))
(import (reactive))

;; basic tests
(let ((var (reactive-var 42))
      (counter 0))
  (test-equal (reactive-ref var) 42)


  (reactive (set! counter (+ 1 counter))
            (reactive-ref var))

  (test-equal counter 1)
  
  (reactive-update! var 43)
  (test-equal counter 2)
  (test-equal (reactive-ref var) 43)
 
  (reactive-update! var 43)
  (test-equal counter 2))


;; dependent nodes
(let* ((var (reactive-var 42))
       (var+1 (reactive (+ 1 (reactive-ref var))))
       (var+1*2 (reactive (* 2 (reactive-ref var+1)))))
  
  (test-equal (reactive-ref var) 42)
  (test-equal (reactive-ref var+1) (+ 1 42))
  (test-equal (reactive-ref var+1*2) (* 2 43))

  (reactive-update! var 0)

  (test-equal (reactive-ref var) 0)
  (test-equal (reactive-ref var+1) 1)
  (test-equal (reactive-ref var+1*2) 2))

;; function scope

(define counter 0)

(define (reactive-function reactive-argument)
  (set! counter (+ 1 counter))
  (* 2 (reactive-ref reactive-argument)))

(define x (reactive 42))

(test-equal (reactive-function x) 84)
(test-equal counter 1)

(define y (reactive (reactive-function x)))  ;; register y reactive variable

(test-equal counter 2)
(test-equal (reactive-ref y) 84)

(reactive-update! x 43)

(test-equal counter 3)
(test-equal (reactive-ref x) 43)
(test-equal (reactive-ref y) 86)

;; delete 

(define x (reactive 42))

(define y (reactive (+ 1 (reactive-ref x))))

(define z (reactive (+ 1 (reactive-ref y))))

(reactive-delete! y)
(reactive-update! x 0)

(test-equal (reactive-node-deleted y) #t)
(test-equal (reactive-ref y) 43)
(test-equal (reactive-ref z) 44)

(test-equal (table-length (reactive-node-dependencies x)) 0)






