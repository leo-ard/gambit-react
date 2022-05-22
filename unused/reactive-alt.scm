;; File: "reactive.scm"

(##namespace ("reactive#"))

(##include "~~lib/gambit#.scm")

(##include "reactive#.scm")


(define-type reactive-var
  constructor: construct-reactive-var
  value
  equal?
  dependent-blocks)


(define-type reactive-block
  constructor: construct-reactive-block
  thunk
  activate
  dependencies)


(define (reactive-block->reactive-var block)
  (let* ((value ((reactive-block-activate block)))
         (block-var (make-reactive-var value (lambda (a b) #f) '() ))
         (old-activate (reactive-block-activate block)))
    (reactive-block-activate-set! block
                                  (lambda ()
                                    (let ((value (activate)))
                                      (set! {block-var} value)
                                      value)))
    block-var))

(define (make-reactive-var value #!optional (equal? equal?))
  (construct-reactive-var value equal? '()))

(define %reactive-var-value reactive-var-value)
(define (reactive-var-value var)
  (let ((value (%reactive-var-value var)))
    (if (and (reactive-block? var) (eq? value 'n..o..t..i..n..g))
        ((reactive-block-activate var))
        value)))

(define (reactive-var-value-update! var val)
  (if (not ((reactive-var-equal? var) (%reactive-var-value var) val))
      (begin
        (reactive-var-value-set! var val)
        (for-each (lambda (block) ((reactive-block-activate block)))
                  (reactive-var-dependent-blocks var)))))


(define (reactive-block-remove block)
  ;; remove the block from the dependent-blocks of the dependencies
  (for-each (lambda (var)
              (reactive-var-dependent-blocks-set!
               var
               (##remq block (reactive-var-dependent-blocks var))))
            (reactive-block-dependencies block)))

(define (reactive-block-add-binding block bind)
  (reactive-block-bindings-set! block (cons bind (reactive-block-bindings block))))

(define (make-reactive-block dependencies thunk)

  (define block (construct-reactive-block thunk thunk dependencies))

  (for-each (lambda (var)
              (reactive-var-dependent-blocks-set!
               var
               (cons block (reactive-var-dependent-blocks var))))
            dependencies)

  block)

