;;;============================================================================

;;; File: "extra.scm"

;;; Copyright (c) 2020-2021 by Marc Feeley, All Rights Reserved.

;;;============================================================================

;; Preamble

(##namespace ("extra#"))                  ;; File namespace
(##namespace ("" scheme))                 ;; Don't shadow definitions

(##include "~~lib/gambit/prim/prim#.scm") ;; map fx+ to ##fx+, etc
(##include "~~lib/_gambit#.scm")          ;; for macro-check-procedure,
;;                                        ;; macro-absent-obj, etc

(##include "~~lib/_six/six-expand#.scm")
(##include "~~lib/_six/js#.scm")

(##include "reactive#.scm")
(##include "reactive-html#.scm")

(##declare (extended-bindings) (standard-bindings) (block))

;; app.scm


(define (demo5)
  (define counter (reactive-var 0))

  (<div>
   (<button>
    on:click: (lambda (e) (reactive-set! counter (+ 1 (reactive-ref counter))))
    "The count is at " counter)

   ;; reactive properties
   (<div> id: counter)
   (<div> id: (reactive (reactive-ref counter)))
   (<div>
    (<div> id: counter)
    (<div> id: (reactive (reactive-ref counter))))

  (reactive
   (<div> id: (reactive-ref counter))
   (<div>
    (<div> id: (reactive-ref counter)))
   (if (fx= 0 (modulo (reactive-ref counter) 2))
       (<p> id: (reactive-ref counter) "The count is even")
       (<p> id: (reactive-ref counter) "the count is odd")))))


(createApp
 debug: #t
 (<p> "Ce fichier contient les démos de svelte, mais implémenté dans gambit-react ! "
      (<br>)
      (<a> href: "https://svelte.dev/examples#reactive-assignments" "Lien vers les démos sveltes")
      (<br>)
      (<a> href: "./extra.scm"
           "Lien vers le ficher .scm qui a généré cette page"
           target: "_blank")
      (<h3>
       "Actuellement, il y a " reactive-block-counter " blocks et " reactive-var-counter " variables actives"))

 ;; demo 1
 (let* ((count (reactive-var 0))
        (onclick (lambda (e) (reactive-set! count (+ 1 (reactive-ref count))))))

   (<div>
    (<h2> "Reactive assignments")
    (<button> on:click: onclick
              (reactive
               (string-append "Clicked "
                              (number->string (reactive-ref count))
                              (if (fx= (reactive-ref count) 1) " time" " times"))))))

 ;; demo 2
 (let* ((count (reactive-var 1))
        (onclick (lambda (e) (reactive-set! count (+ 1 (reactive-ref count)))))
        (doubled (reactive (* 2 (reactive-ref count))))
        (quadrupled (reactive (* 2 (reactive-ref doubled)))))

   (<div>
    (<h2> "Reactive declarations")
    (<button> on:click: onclick
              "Count: " (reactive (reactive-ref count)))
    (<p>
     (reactive (string-append
                (number->string (reactive-ref count))
                " * 2 = "
                (number->string (reactive-ref doubled))))
     (<br>)
     (reactive (reactive-ref doubled))
     " * 2 = "
     (reactive (reactive-ref quadrupled)))))

 ;; demo 3
 (let* ((count (reactive-var 1))
        (onclick (lambda (e) (reactive-set! count (+ 1 (reactive-ref count))))))
   (reactive
    (if (>= (reactive-ref count) 10)
        (begin
          \alert("count is deangerously high")
          (reactive-set! count 9))
        ))
   (<div>
    (<h2> "Reactive statement")
    (<button> on:click: onclick
              "Clicked "
              (reactive (reactive-ref count))
              (reactive (if (fx= (reactive-ref count) 1) " time" " times")))))

 ;; demo 4
 (let* ((name (reactive-var "this is my name"))
        (onchange (lambda (e) (reactive-set! name \(`e).srcElement.value))))
   (<div>
    (<h2> "Binding ")
    (<label> "name :" for: "input")
    (<input>
     id: "input"
     on:input: onchange
     value: (reactive-ref name))
    (<p> "Your name is: " (reactive (reactive-ref name)))

    (<h2> "other tests")
    (reactive
     (if (equal? "leonard" (reactive-ref name))
         (<p> name " est egal a leonard")
         (<p> name " n'est pas egal a leonard")))))
 (demo5))

(listen-events)
