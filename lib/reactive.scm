;;;============================================================================

;;; File: "reactive.scm"

;;; Copyright (c) 2020-2022 by Léonard Oest O'Leary and Marc Feeley, All Rights Reserved.

;;;============================================================================


(##namespace ("reactive#"))

(##include "~~lib/gambit#.scm")

;; for debug purpuses
;(##include "~~lib/_six/six-expand#.scm")
;(##include "~~lib/_six/js#.scm")

(##include "reactive#.scm")

(define-type reactive-node
  value
  equal?
  thunk
  dependencies
  deleted)

(define debug #t)

(define $$reactive-debug-count (make-reactive-node 0 equal? #f (make-table) #f))

;; A reactive variable is just a node with a value, and without an update function
(define (reactive-var value #!optional (equal? equal?))
  (if debug
    (reactive-update! $$reactive-debug-count (+ 1 (reactive-node-value $$reactive-debug-count))))

  (make-reactive-node value equal? #f (make-table) #f))

(define (reactive-block thunk #!optional (dependencies (make-table)) (equal? equal?))
  (if debug
    (reactive-update! $$reactive-debug-count (+ 1 (reactive-node-value $$reactive-debug-count))))

  (make-reactive-node #f equal? thunk dependencies #f))

(define (reactive-update! node #!optional (new-value ($$retrieve-value node)))
  (let* ((old-value (reactive-node-value node))
         (eq-func   (reactive-node-equal? node)))
    (if (not (eq-func new-value old-value))
      (begin
        (reactive-node-value-set! node new-value)
        ($$reactive-update-dependencies node)))))

(define ($$reactive-update-dependencies node)
  (let ((dependencies (reactive-node-dependencies node)))
    (reactive-node-dependencies-set! node (make-table))
    (for-each 
      (lambda (kv)
        (define reactive-node (car kv))

        (if (not (reactive-node-deleted reactive-node))
            (reactive-update! reactive-node)))
      (table->list dependencies))))

(define ($$retrieve-value node)
  (let ((thunk (reactive-node-thunk node)))
    (if (not thunk)
      (error "Trying to update a non-reactive element"))
    (parameterize (($$reactive-scope node))
      (thunk))))

(define ($$add-dependencie reactive-elem dependencie)
  (let ((deps (reactive-node-dependencies reactive-elem)))
    (table-set! deps dependencie #t)))

(define ($$reactive-ref scope node)
  (if scope
      ($$add-dependencie node scope))

  (reactive-node-value node))

(define (reactive-delete! node)
  (if debug
    (reactive-update! $$reactive-debug-count (- (reactive-node-value $$reactive-debug-count) 1)))
  (reactive-node-deleted-set! node #t))

(define reactive? reactive-node?)
(define (reactive-var? node) (and (reactive? node) (not (reactive-node-thunk node)))) 
(define (reactive-block? node) (and (reactive? node) (reactive-node-thunk node)))


;; global scope
(define $$reactive-scope (make-parameter #f))


;; ======= REACTIVE CONSTRUCTIONS ========


;; constuctions with type:
;; rlist = (cons (reactive-var val) (reactive-var rlist)) | '()

#;(begin

  (define (list->reactive-list lst)
    (if (pair? lst)
      (let* ((elem (car lst))
             (rest (cdr lst)))
        (rcons elem (list->reactive-list rest)))
      '()))
  
  (define (reactive-list? lst)
    (if (pair? lst)
      (and (reactive? (cdr lst)) (reactive? (car lst)) (reactive-list? (rcdr lst)))
      #t))
  
  (define (rset-cdr! lst val)
    (if (not (reactive? (cdr lst)))
      (error "cdr of list is not reactive" lst))
    (reactive-update! (cdr lst) val))
  
  (define (rset-car! lst val)
    (if (not (reactive? (car lst)))
      (error "car of list is not reactive" lst))
    (reactive-update! (car lst) val))
  
  (define (rcdr lst)
    (if (not (reactive? (cdr lst)))
      (error "cdr of list is not reactive" lst))
    (reactive-ref (cdr lst)))
  
  (define (rcar lst)
    (if (not (reactive? (car lst)))
      (error "car of list is not reactive" lst))
    (reactive-ref (car lst)))
  
  (define (rcons elem lst)
    (cons (reactive-var elem) (reactive-var lst)))

  ;(define (rtail lst) 
  ;  )
  ;
  ;(define (rappend! lst1 lst2)
  ;  )
  
  (define (rlist . args)
    (list->reactive-list args))
  
  (define (rpair? lst)
    (and (pair? lst)
         (reactive? (car lst))
         (reactive? (cdr lst))))
  
  ;; return the reactive variable at that place
  (define ($$rlist-end lst)
    (if (rpair? lst)
      (if (eq? (rcdr lst) '()) 
        ($$rlist-end (cdr lst))
        (cdr lst))

      (error "Cannot find end of non reactive-list")))
  
  (define (rlist-end lst)
    (define end (reactive-var '()))
    (define end-pointer (reactive-var ($$rlist-end lst)))
  
    (reactive
      (let ((end-of-lst ($$rlist-end (reactive-ref (no-reactive-ref end-pointer)))))
        #;(reactive-ref end-of-lst)
        (reactive-update! end-pointer end-of-lst)
        ;(reactive-update! end-of-lst (reactive-ref end))
        #;(reactive-node-value-set! end '())))
  
    (reactive 
      (reactive-update! (no-reactive-ref end-pointer) (reactive-ref end)))
  
    (reactive
      (reactive-update! end (no-reactive-ref (reactive-ref end-pointer))))
    
    end)
  )


;; constuction with type 
;; rlist = (reactive-var (cons (reactive-var val) rlist)) | (reactive-var '())
(begin

  (define (list->reactive-list lst)
    (if (pair? lst)
      (let* ((elem (car lst))
             (rest (cdr lst)))
        (rcons elem (list->reactive-list rest)))
      (reactive-var '())))

  (define (rcons elem lst)
    (reactive-var (cons elem lst)))

  (define (rlist . args)
    (list->reactive-list args))

  (define (rcar lst)
    (car (reactive-ref lst)))

  (define (rcdr lst)
    (cdr (reactive-ref lst)))

  (define (rcar-update! lst val)
    (reactive-update! lst (cons val (rcdr lst))))

  (define (rcdr-update! lst val)
    (reactive-update! lst (cons (rcar lst) val)))
  


  (define (rtail lst)
    (let ((lst-elem (reactive-ref lst)))
      (if (eq? lst-elem '())
        lst
        (rtail (cdr lst-elem)))))

  (define (rappend! lst1 lst2)
    (let ((lst1-tail (rtail lst1)))
      (reactive
        (reactive-update! lst1-tail (reactive-ref lst2)))))

  )





