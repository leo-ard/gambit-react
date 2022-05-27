;;;============================================================================

;;; File: "reactive#.scm"

;;; Copyright (c) 2020-2021 by Léonard Oest O'Leary, All Rights Reserved.

;;;============================================================================

#|
(define-syntax |{...}|
  (lambda (src)
    (define (reactive-ref? src)
      (let ((x (##source-strip src)))
        (and (pair? x) ;; detect the form {symbol}
             (pair? (cdr x))
             (null? (cddr x))
             (eq? (##source-strip (car x)) '|{...}|)
             (let ((sym (##source-strip (cadr x))))
               (and (symbol? sym)
                    sym))))) ;; and return symbol
    (define (expand-reactive-ref sym)
      `(reactive-value-value ,sym))
    (define (expand-reactive-code)
      (define dependencies (make-table))
      (define (walk src)
        (let ((x (##source-strip src)))
          (cond ((not (pair? x)))
                ((reactive-ref? src)
                 =>
                 (lambda (sym)
                   (table-set! dependencies sym #t)))
                (else
                 (let loop ((lst x))
                   (if (pair? lst)
                       (begin
                         (walk (car lst))
                         (loop (cdr lst)))))))))
      (walk src) ;; Populate dependencies table
      (let ((deps (map car (table->list dependencies)))) ;; Get dependencies keys
        `(make-reactive-block
          (##list ,@deps)
          (##lambda () ,@(cdr (##source-strip src))))))  ;; Get the sexp without leading |{...}|
    (cond ((reactive-ref? src)  => expand-reactive-ref)  ;; (expand-reactive-ref src) where src is a symbol
          (else                    (expand-reactive-code)))))



(define-syntax set!
  (lambda (stx)
    (syntax-case stx ()
      ((_ (|{...}| old) new)
       #'(reactive-var-update! old new))
      ((_ old new)
       #'(##set! old new)))))
|#

(define-syntax reactive
  (lambda (src)
    (define (reactive-ref? src)
      (let ((x (##source-strip src)))
        (and (pair? x) ;; detect the form {symbol}
             (pair? (cdr x))
             (null? (cddr x))
             (eq? (##source-strip (car x)) 'reactive-ref)
             (let ((sym (##source-strip (cadr x))))
               (and (symbol? sym)
                    sym))))) ;; and return symbol

    (define (reactive-block? src)
      (let ((x (##source-strip src)))
        (and (pair? x) ;; detect the form {symbol}
             (pair? (cdr x))
             (eq? (##source-strip (car x)) 'reactive-block)
             ))) ;; and return symbol

    (define dependencies (make-table))


    (define (walk src)
      (let ((x (##source-strip src)))
        (cond ((not (pair? x)))
              ((reactive-block? src))
              ((reactive-ref? src)
               =>
               (lambda (sym)
                 (table-set! dependencies sym #t)))
              (else
               (let loop ((lst x))
                 (if (pair? lst)
                     (begin
                       (walk (car lst))
                       (loop (cdr lst)))))))))
    (walk src) ;; Populate dependencies table
    (let ((deps (map car (table->list dependencies)))) ;; Get dependencies keys
      `(reactive-block
        (##list ,@deps)
        (##lambda () ,@(cdr (##source-strip src)))))))

(##namespace
 ("reactive#"

  ;; debug only
  reactive-block-counter
  reactive-var-counter

  reactive?
  reactive-var
  reactive-ref
  reactive-block
  reactive-set!
  reactive-block-update!
  reactive-block-remove

  reactive-var-value-update!
  reactive-var?

  reactive-var-value
  reactive-var-value-set!
  reactive-var-value-set

  reactive-var-equal?
  reactive-var-equal?-set!
  reactive-var-equal?-set

  reactive-var-dependent-block
  reactive-var-dependent-block-set!
  reactive-var-dependent-block-set

  reactive-block?
  reactive-block-thunk
  reactive-block-activate
  reactive-block-bindings
  reactive-block-add-binding

  reactive-block-thunk-set!
  reactive-block-activate-set!
  reactive-block-bindings-set!))

