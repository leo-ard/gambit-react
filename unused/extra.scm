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


(createApp
 (<div>
  (<h1> "Welcome from Gambit !")))

(##thread-sleep! +inf.0)
