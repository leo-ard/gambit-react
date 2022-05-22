;;;============================================================================

;;; File: "reative-html.scm"

;;; Copyright (c) 2020-2021 by Marc Feeley and Léonard Oest O'Leary, 
;;;               All Rights Reserved.

;;;============================================================================

;; Preamble

(##namespace ("reactive-html#"))

(##include "~~lib/gambit#.scm")

(##include "~~lib/_six/six-expand#.scm")
(##include "~~lib/_six/js#.scm")

(##include "reactive#.scm")
(##include "reactive-html#.scm")

(##namespace ("" scheme))

(declare
 (standard-bindings)
 (extended-bindings)
 (block)
 (not safe))

(define event-queue (open-vector))

(define (listen-events)
  ((read event-queue))
  (listen-events))

;; Needed for the generation of the html tags

(define (on-keyword? key)
  (let ((key-str (keyword->string key)))
    (and (> (string-length key-str) 3)
         (string=? (substring key-str 0 3) "on:")
         (substring key-str 3 (string-length key-str)))))

(define (link-keyword? key)
  (let ((key-str (keyword->string key)))
    (and (> (string-length key-str) 5)
         (string=? (substring key-str 0 5) "link:")
         (substring key-str 5 (string-length key-str)))))

(define (parse-args args table)

  (define (set-attr attr val)
    (cond
     ((table-ref table attr #f)
      =>
      (lambda (old-val)
        (if (eq? attr body:)
            (table-set! table body: (cons val (table-ref table body:)))
            (error "Cannot set the attribute twice : " attr old-val))))
     ((keyword? val) (error "Attribute value is not a value (but a keyword)"))
     (else (table-set! table attr val))))

  (cond
   ((not (pair? args)) table)
   ((keyword? (car args))
    (begin
      (if (pair? (cdr args))
          (set-attr (car args) (cadr args))
          (error "Expecting value after attribute" (car args)))
      (parse-args (cddr args) table)))
   (else
    (if (not (table-ref table body: #f))
        (table-set! table body: '()))
    (table-set! table body: (append (table-ref table body:) (list (car args)) ))
    (parse-args (cdr args) table))))


(define (obj->str obj) (with-output-to-string (lambda () (write obj))))
(define (jsdump obj) \console.log(`(obj->str obj)))

(define (mutationCallback e mut)
  \(`e).forEach(`(lambda (mutationRecord . foo)
                   \(`mutationRecord).removedNodes.forEach(`remove-reactive-block-on-dom))))

(define mutationConfigs \(new Object()))
\(`mutationConfigs).childList=true


(define mutationObject \(new MutationObserver(`mutationCallback)))


(define (register-observer-on-parent elem)
  #;\console.log("registering parent ", `elem)
  \(`mutationObject).observe(`elem, `mutationConfigs))

(define (register-reactive-block-on-dom domelem block)
  (let ((reactive-block-lst \((`domelem).reactiveblock)))
    #;\console.log("registering node", `domelem)
    (if \(`reactive-block-lst)===undefined
        \(`domelem).reactiveblock=`(scheme (list block))
        \(`domelem).reactiveblock=`(scheme (cons block reactive-block-lst)))))

(define (remove-reactive-block-on-dom domelem . foo) ;; foo is for javascript compatibilty
  (let ((reactive-block-lst \(`domelem).reactiveblock))
    #;\console.log("deleting", `domelem, "had", `(length reactive-block-lst), "blocks")
    (for-each
     (lambda (block)
       (reactive-block-remove block))
     reactive-block-lst)
    \(`domelem).reactiveblock=undefined))

;; Utility functions

(define (createElement name)
  \document.createElement(`name))

(define (toDomElement elem)
  (cond
   ((or (string? elem) (number? elem))
    \document.createTextNode(`elem))
   (else elem)))


(define (createElement name)
  \document.createElement(`name))

(define (createApp . elems)

  (define args (parse-args elems (make-table)))
  (define default-html
    (<p> "No elements in createApp"))

  \console.log(`args)
  (if (table-ref args debug: #f)
      (table-set! args body:
                  (cons
                   (<div>
                    style: "position:fixed; top:0; right:0; background-color: #ffff005e; color: #000000a6;"
                    (<p>
                     "Reactive block: " reactive-block-counter (<br>)
                     "Reactive variables: " reactive-var-counter
                    )
                    )

                   (table-ref args body: default-html))))


  \document.getElementById("app").appendChild(`(<div> body: (table-ref args body: default-html))))






