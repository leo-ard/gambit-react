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

(create-app
 (<div>
   (<p> "this is a test")))


\console.log("heyyyyyy")

(listen-events)
