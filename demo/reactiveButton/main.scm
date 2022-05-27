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

(createApp
 debug: #t
 (let ((my-var (reactive-var 0)))
   (<div>
     (<button> 
       on:click: (lambda (e) (reactive-set! my-var (+ 1 (reactive-ref my-var))))
       "Number of clicks : " my-var))))

(listen-events)
