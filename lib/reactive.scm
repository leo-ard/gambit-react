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

(define (reactive-update! node #!optional (new-value ($$retrieve-value node)))
  (let* ((old-value (reactive-node-value node))
         (eq-func   (reactive-node-equal? node)))
    (if (not (eq-func new-value old-value))
      (begin
        (reactive-node-value-set! node new-value)
        ($$reactive-update-dependencies node)))))

(define (reactive-delete! node)
  (if debug
    (reactive-update! $$reactive-debug-count (- (reactive-node-value $$reactive-debug-count) 1)))
  (reactive-node-deleted-set! node #t))

(define reactive? reactive-node?)
(define (reactive-var? node) (and (reactive? node) (not (reactive-node-thunk node)))) 
(define (reactive-block? node) (and (reactive? node) (reactive-node-thunk node)))


;; global scope
(define $$reactive-scope (make-parameter #f))
