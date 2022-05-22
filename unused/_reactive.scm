;; File: "_reactive.scm"
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
      `(reactive-var-value ,sym))
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
       #'(%reactive-var-value-set! old new))
      ((_ old new)
       #'(##set! old new)))))

(define-type reactive-var
  constructor: construct-reactive-var
  value
  equal?
  dependent-blocks)

(define (make-reactive-var value #!optional (equal? equal?))
  (construct-reactive-var value equal? '())) ;; Return a reactive-var

(define (%reactive-var-value-set! var val)
  (reactive-var-value-set! var val)
  (for-each (lambda (thunk) (thunk))
            (reactive-var-dependent-blocks var)))

(define (reactive-var-value-update! var val)
  ;; Don't update if equal using possibly custom equality operator
  (if (not ((reactive-var-equal? var) (reactive-var-value var) val))
      (%reactive-var-value-set! var val)))

(define (make-reactive-block dependencies thunk)
  (define (block #!optional operation)
    (cond ((not operation)
           ;; run the block
           (thunk)
           thunk)
          ((eq? operation 'remove)
           ;; remove the block from the dependent-blocks of the dependencies
           (for-each (lambda (var)
                       (reactive-var-dependent-blocks-set!
                        var
                        (##remq block (reactive-var-dependent-blocks var))))
                     dependencies)
           (void))
          ((eq? operation 'dependencies)
           dependencies)
          (else
           (error "unknown reactive block operation" operation))))
  (for-each (lambda (var)
              (reactive-var-dependent-blocks-set!
               var
               (cons block (reactive-var-dependent-blocks var))))
            dependencies)
  block)
