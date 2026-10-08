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

(define $$body-tag 'body)

(define (parse-args args 
                    #!optional (table (let ((table (make-table))) 
                                        (table-set! table $$body-tag '()) 
                                        table)))

  (define (set-attr attr val)
    (cond
      ((table-ref table attr #f)
       =>
       (lambda (old-val)
         (error "Cannot set the attribute twice : " attr old-val)))
      ((keyword? val) (error "Attribute value is a keyword"))
      (else (table-set! table attr val))))

  (cond
    ((not (pair? args)) table)
    ((keyword? (car args))
     (if (pair? (cdr args))
       (set-attr (car args) (cadr args))
       (error "Expecting value after attribute" (car args)))
     (parse-args (cddr args) table))
    ((list? (car args))
     (table-set! table $$body-tag (append (table-ref table $$body-tag) (car args)))
     (parse-args (cdr args) table))
    (else
      (table-set! table $$body-tag (append (table-ref table $$body-tag) (list (car args)) ))
      (parse-args (cdr args) table))))

(define-type reactive-socket
  status
  send
  receive)

(define (reactive-socket url)

  (let ((ws \new WebSocket(`url))
        (status  (reactive-var 'connecting)) ;; three status : connecting, open and closed
        (send    (reactive-var 0 (lambda (x y) #f)))
        (receive (reactive-var 0 (lambda (x y) #f))))
    (define (onopen e)
      (reactive
        ;initialize: #f
        (let ((object (object->u8vector (reactive-ref send))))
          \(`ws).send(`object)))
      (reactive-update! status 'open))

    ;; translate the data to a scheme object
    \(`ws).onmessage=function(m){m.data.arrayBuffer().then(`(lambda (buf) \console.log("receiving...") (reactive-update! receive (u8vector->object \new Uint8Array(`buf)))));} 

    \(`ws).onopen=`onopen
    \(`ws).onclose=`(lambda (e) (reactive-update! status 'closed))
    (make-reactive-socket status send receive)))


;; could be replaced by list directly
;;(define-type reactive-list lst)
;;
;;(define (rlist #!optional (lst '()))
;;  (if (list? lst)
;;    (make-reactive-list lst)
;;    (error "Cannot create a reactive list")))
;;
;;(define (rcar rlist)
;;  (car (reactive-list-lst rlist)))
;;
;;(define (rcdr rlist)
;;  (make-reactive-list (reactive-ref (cdr (reactive-list-lst rlist)))))
;;
;;(define (rcons elem rlist)
;;  (make-reactive-list ))




(define (create-app #!key (debug #f) (root "#app") . dom-elems)
  ;(define args (parse-args raw-args))

  (define root-node \document.querySelector(`root))

  (define default-html (<p> "No node in create-app, add some to get started !"))

  ;; Register garbage collection on root node

  (define (remove-reactive-node-on-dom domelem . foo) ;; foo is for javascript compatibilty
    (let ((reactive-nodes \(`domelem).reactiveNodes))
    (if reactive-nodes
      (begin

        (if debug
          \console.log("deleting", `domelem, "had", `(length reactive-nodes), "blocks"))

        \Array.from((`domelem).childNodes.values).forEach(`remove-reactive-node-on-dom) ;; remove from child

        (for-each
          (lambda (block)
            (reactive-delete! block))
          reactive-nodes)

        \(`domelem).reactiveblock=undefined))))


(define mutationConfig
  (let ((mutationConf \(new Object())))
  \(`mutationConf).childList=true
\(`mutationConf).subtree=true
mutationConf))

(define (mutationCallback e mut)
  \(`e).forEach(`(lambda (mutationRecord . foo)
                   \(`mutationRecord).removedNodes.forEach(`remove-reactive-node-on-dom))))

(define mutationObject \(new MutationObserver(`mutationCallback)))

\(`mutationObject).observe(`root-node , `mutationConfig)

(if debug 
  \(`root-node).appendChild(`(<div>
                               style: "position:fixed; top:0; right:0; background-color: #ffff005e; color: #000000a6;"
                               (<p>
                                 ;"not yet available"
                                 "Reactive nodes: " $$reactive-debug-count 
                                 ;"Reactive variables: " reactive-var-counter
                                 ))))

(for-each
  (lambda (dom-elem . foo)
    \(`root-node).appendChild(`dom-elem))
dom-elems)
)



;(define (obj->str obj) (with-output-to-string (lambda () (write obj))))
;(define (jsdump obj) \console.log(`(obj->str obj)))






#;(define (register-observer-on-parent elem)
#;\console.log("registering parent ", `elem)
\(`mutationObject).observe(`elem, `mutationConfigs))

(define (register-reactive-node-on-dom domelem node)

  (let ((reactive-nodes \((`domelem).reactiveNodes)))
    \console.log("registering node", `domelem)
    (if \(`reactive-nodes)===undefined
        \(`domelem).reactiveNodes=`(scheme (list node))
        \(`domelem).reactiveNodes=`(scheme (cons node reactive-nodes)))))


;; Utility functions

(define (createElement name)
  \document.createElement(`name))

(define (toDomElement elem)
  (cond
   ((or (string? elem) (number? elem))
    \document.createTextNode(`elem))
   ((list? elem)
    (<div> elem))
   (else elem)))


(define (createElement name)
  \document.createElement(`name))

#;(define (createApp . elems)

  (define args (parse-args elems (make-table)))
  (define default-html
    (<p> "No elements in createApp"))

  (if (table-ref args debug: #f)
      (table-set! args body:
                  (cons
                   (<div>
                    style: "position:fixed; top:0; right:0; background-color: #ffff005e; color: #000000a6;"
                    (<p>
                     "Reactive block: " reactive-block-counter (<br>)
                     "Reactive variables: " reactive-var-counter))

                   (table-ref args body: default-html))))


  \document.getElementById("app").appendChild(`(<div> body: (table-ref args body: default-html))))


(define (gen-tag name)

  (define (func . raw-args)
    (define args (parse-args raw-args))
    (define tag (createElement name))

    (for-each
      (lambda (kv)
        (define key (car kv))
        (define value (cdr kv))

        (cond 
          ((equal? key $$body-tag)
           (for-each
             (lambda (elem)
              (cond
                ((reactive? elem)
                  (let ((old (toDomElement (reactive-ref elem))))
                    \(`tag).appendChild(`old)
                    (register-reactive-node-on-dom
                      tag
                      (reactive
                        ;initialize: #f
                        (let ((new (toDomElement (reactive-ref elem)))) 
                          \(`tag).replaceChild(`new ,`old)
                          (set! old new)
                          )))))
                (else
                  \(`tag).appendChild(`(toDomElement elem)))))
             value))
  
          
          ((on-keyword? key)
           =>
           (lambda (event)
             \(`tag).addEventListener(`event,
                                       `(lambda (e)
                                          (write
                                            (lambda () (value e))
                                            event-queue)))))
  
          ((link-keyword? key)
           =>
           (lambda (prop)
             (register-reactive-node-on-dom
               tag
               (reactive
                 \(`tag)[`prop]=`(reactive-ref value)))))
  
          ((reactive? value)
           (register-reactive-node-on-dom
             tag
             (reactive
               \(`tag).setAttribute(`(keyword->string key), `(reactive-ref value)))))
          
          (else
            \(`tag).setAttribute(`(keyword->string key), `value))))
  
  
      (table->list args))
    tag)

  func)




