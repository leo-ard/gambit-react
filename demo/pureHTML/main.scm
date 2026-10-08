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

(define x (reactive 42))

(create-app
  debug: #t
  (<div>
    "Welcome to GambitReact. If everything goes well, you should see 42 under this line: "
    (<p> x)))

\console.log("Page loaded!")

(listen-events)
