;;;============================================================================

;;; File: "main.scm"

;;; Copyright (c) 2020-2022 by Marc Feeley and Léonard Oest O'Leary,
;;;    All Rights Reserved.

;;;============================================================================

;; Preamble

(##namespace ("extra#"))                  ;; File namespace
(##namespace ("" scheme))                 ;; Don't shadow definitions

(##include "~~lib/gambit/prim/prim#.scm") ;; map fx+ to ##fx+, etc
(##include "~~lib/_gambit#.scm")          ;; for macro-check-procedure,
;;                                        ;; macro-absent-obj, etc

(##include "~~lib/_six/six-expand#.scm")
(##include "~~lib/_six/js#.scm")

(##include "../../lib/reactive#.scm")
(##include "../../lib/reactive-html#.scm")

(##declare (extended-bindings) (standard-bindings) (block))

;; ne fonctionne pas :(  
(define-type message
  owner
  content)

(define (link reactive-var) (lambda (e) (reactive-update! reactive-var \(`e).srcElement.value)))

(define (<reactive-input> label placeholder onclick)
  (let* ((content (reactive-var ""))
         (callback (lambda (e) (onclick (reactive-ref content))))
         (enter-callback (lambda (e) (if \(`e).key==="Enter" (onclick (reactive-ref content))))))

    (<div>
      (<label> for: "input" label)
      (<input> 
        id: "input"
        placeholder: placeholder
        on:input: (link content))
        on:keyup: enter-callback
      (<button>
        on:click: callback
        "send !"))))

(create-app
  debug: #t
  (let* ((socket (reactive-socket "ws://localhost:7777"))
         (socket-status (reactive-socket-status socket))
         (socket-send (reactive-socket-send socket))
         (socket-receive (reactive-socket-receive socket))
         (all-messages (reactive-var '()))
         (name (reactive-var #f)))

    (reactive (reactive-update! all-messages (append ($$reactive-ref #f all-messages) (list (reactive-ref socket-receive)))))

    (<div>
      (reactive
        (cond
          ((not (reactive-ref name))
           (<reactive-input> "Enter a name :" "" (lambda (name-string) (reactive-update! name name-string))))
          ((eq? (reactive-ref socket-status) 'connecting)
           (<p> "connecting to socket..."))
          ((eq? (reactive-ref socket-status) 'closed)
           (<p> "The connection to the socket was closed, please refresh the page or launch the server"))
          (else
            (<div> 
              (reactive
                (map 
                  (lambda (message) 
                    (if (not (number? message))
                      (<p> 
                        (<b> (car message)) 
                        " : "
                        (cadr message))
                      (<div>)))
                  (reactive-ref all-messages)))   
              (<reactive-input> "" "Type a message to send" (lambda (message) (reactive-update! socket-send (list (reactive-ref name) message)))))))))))

(listen-events)
