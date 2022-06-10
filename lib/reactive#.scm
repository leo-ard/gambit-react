;;;============================================================================

;;; File: "reactive#.scm"

;;; Copyright (c) 2020-2021 by Léonard Oest O'Leary and Marc Feeley, All Rights Reserved.

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
|#




(define-macro (reactive . args)
  (let ((block-name (gensym))
        (value      (gensym)))
    `(let* ((,block-name (reactive-block (lambda () ,@args) '()))
            (,value      ($$retrieve-value ,block-name)))
       (reactive-node-value-set! ,block-name ,value)
       ,block-name)))

(define-macro (reactive-ref reactive-var)
  `($$reactive-ref ($$reactive-scope) ,reactive-var))

(##namespace
 ("reactive#"
  
  reactive-var
  reactive-block
  $$reactive-update-dependencies
  $$reactive-scope
  $$add-dependencie
  $$reactive-ref
  $$retrieve-value

  reactive-node-value
  reactive-node-value-set!
  reactive-node-value-set

  reactive-node-dependencies
  reactive-node-dependencies-set!
  reactive-node-dependencies-set

  reactive-update!

  reactive-scope-create

  ))

