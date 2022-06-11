;;;============================================================================

;;; File: "reactive.scm"

;;; Copyright (c) 2020-2022 by Léonard Oest O'Leary and Marc Feeley, All Rights Reserved.

;;;============================================================================


(##namespace ("reactive#"))

(##include "~~lib/gambit#.scm")

(##include "reactive#.scm")

(define-type reactive-node
  value
  equal?
  thunk
  dependencies
  deleted)

;; A reactive variable is just a node with a value, and without an update function
(define (reactive-var value #!optional (equal? equal?))
  (make-reactive-node value equal? #f '() #f))

(define (reactive-block thunk #!optional (dependencies '()) (equal? equal?))
  (make-reactive-node #f equal? thunk dependencies #f))

(define ($$reactive-update-dependencies node)
  (let ((dependencies (reactive-node-dependencies node)))
    (reactive-node-dependencies-set! node '())
    (for-each 
      (lambda (reactive-node)
        (if (not (reactive-node-deleted reactive-node))
            (reactive-update! reactive-node)))
      dependencies)))

(define ($$retrieve-value node)
  (let ((thunk (reactive-node-thunk node)))
    (if (not thunk)
      (error "Trying to update a non-reactive element"))
    (parameterize (($$reactive-scope node))
      (thunk))))

(define ($$add-dependencie reactive-elem dependencie)
  (let ((deps (reactive-node-dependencies reactive-elem)))
    (reactive-node-dependencies-set! reactive-elem (cons dependencie deps))))

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
  (reactive-node-deleted-set! node #t))

(define reactive? reactive-node?)
(define (reactive-var? node) (and (reactive? node) (not (reactive-node-thunk node)))) 
(define (reactive-block? node) (and (reactive? node) (reactive-node-thunk node)))


;; global scope
(define $$reactive-scope (make-parameter #f))
