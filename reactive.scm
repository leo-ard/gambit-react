;;;============================================================================

;;; File: "reactive.scm"

;;; Copyright (c) 2020-2021 by Léonard Oest O'Leary, All Rights Reserved.

;;;============================================================================


(##namespace ("reactive#"))

(##include "~~lib/gambit#.scm")

(##include "reactive#.scm")


(define-type reactive-value
  extender: define-type-of-reactive-value
  value
  dependent-blocks)

(define-type-of-reactive-value reactive-var
  constructor: construct-reactive-var
  equal?)

(define-type-of-reactive-value reactive-block
  constructor: construct-reactive-block
  thunk
  dependencies)

(define reactive-var-counter (construct-reactive-var 0 '() equal?))


(define (make-reactive-var value #!optional (equal? equal?))
  (reactive-set! reactive-var-counter (+ 1 (reactive-ref reactive-var-counter)))
  (construct-reactive-var value '() equal?))

(define (reactive-value-update! var value)
  (reactive-value-value-set! var value)
  (for-each (lambda (block) (reactive-block-update! block))
            (reactive-value-dependent-blocks var)))

(define (reactive-var-update! var value)
  (if (not (reactive-var? var))
      (if (reactive-block? var)
          (error "Cannot manualy set a reactive block, use a reactive variable instead")
          (error "Cannot set a non-reactive element")))
  (if (not ((reactive-var-equal? var) value (reactive-value-value var)))
      (reactive-value-update! var value)))


(define (reactive-block-update! block)
  (reactive-value-update! block ((reactive-block-thunk block))))

(define (reactive-ref var)
  (cond
   ((reactive-var? var) (reactive-var-value var))
   ((reactive-block? var) (reactive-block-value var))
   (else (reactive-value-value var))))

(define (reactive-block-value var)
  (let ((value (reactive-value-value var)))
    (if (eq? value #!void)
        (begin
          (reactive-block-update! var)
          (reactive-value-value var))
        value)))

(define (reactive-block-remove block)
  ;; remove the block from the dependent-blocks of the dependencies
  (for-each (lambda (var)
              (reactive-value-dependent-blocks-set!
               var
               (##remq block (reactive-value-dependent-blocks var))))
            (reactive-block-dependencies block))

  (reactive-set! reactive-block-counter (- (reactive-ref reactive-block-counter) 1)))

(define (reactive-block dependencies thunk)

  (define block (construct-reactive-block #!void '() thunk dependencies))

  (for-each (lambda (var)
              (reactive-value-dependent-blocks-set!
               var
               (cons block (reactive-value-dependent-blocks var))))
            dependencies)

  (reactive-set! reactive-block-counter (+ (reactive-ref reactive-block-counter) 1))

  block)

(define reactive? reactive-value?)
(define reactive-set! reactive-var-update!)
(define reactive-var-value reactive-value-value)
(define reactive-var make-reactive-var)

(define reactive-block-counter (reactive-var 0))

