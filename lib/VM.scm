;;;============================================================================

;;; File: "VM.scm"

;;; Copyright (c) 2020-2021 by Marc Feeley, All Rights Reserved.

;;;============================================================================
;; (##include "~~lib/_gambit#.scm")

;; ##include -> copy/paste
(##include "~~lib/_six/js.scm")
(##include "~~lib/_six/six-expand.scm")
(define _six/six-expand#... #f)
(##include "reactive.scm")
(##include "reactive-html.scm")

(##namespace ("VM#"))
(##include "~~lib/gambit/prim/prim#.scm") ;; map fx+ to ##fx+, etc
(##include "~~lib/_gambit#.scm")          ;; for macro-check-procedure,
                                          ;; macro-absent-obj, etc
(##include "~~lib/_six/six-expand#.scm")
(##include "~~lib/_six/js#.scm")


(declare (extended-bindings) (standard-bindings) (block))
(declare (not inline))

(##inline-host-declaration #<<end-of-host-code

// Defer Scheme code execution until scheme_program_start is called.
scheme_program_start = @all_modules_registered@;
@all_modules_registered@ = function () { };

glo=@glo@;
procedure2host=@procedure2host@;

end-of-host-code
)

;;;----------------------------------------------------------------------------
