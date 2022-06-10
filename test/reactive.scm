
(import (_test))
(import (reactive))

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
