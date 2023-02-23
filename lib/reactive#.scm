;;;============================================================================

;;; File: "reactive#.scm"

;;; Copyright (c) 2020-2021 by Léonard Oest O'Leary and Marc Feeley, All Rights Reserved.

;;;============================================================================


(define-macro (reactive #!key (initialize #t) . args)
  (let ((block-name (gensym))
        (value      (gensym)))
    `(let* ((,block-name (reactive-block (lambda () ,@args)))
            (,value      ,(if initialize `($$retrieve-value ,block-name) `#!void)))
       (reactive-node-value-set! ,block-name ,value)
       ,block-name)))

(define-macro (reactive-ref reactive-var)
  `($$reactive-ref ($$reactive-scope) ,reactive-var))

(define-macro (no-reactive-ref reactive-var)
  `($$reactive-ref #f ,reactive-var))

(define-macro (no-reactive . args)
  `(parameterize (($$reactive-scope #f))
    ,@args))

(##namespace
 ("reactive#"
  
  reactive-var
  reactive-block
  $$reactive-update-dependencies
  $$reactive-scope
  $$add-dependencie
  $$reactive-ref
  $$retrieve-value
  $$reactive-debug-count

  reactive?
  reactive-block?

  reactive-node-value
  reactive-node-value-set!
  reactive-node-value-set

  reactive-node-dependencies
  reactive-node-dependencies-set!
  reactive-node-dependencies-set

  reactive-node-deleted
  reactive-node-deleted-set!
  reactive-node-deleted-set

  reactive-update!
  reactive-delete!

  reactive-scope-create

  rlist
  reactive-list
  rcdr-update!
  rcar-update!
  rcar
  rcdr
  rcons
  rlist-end
  $$rlist-end
  rappend!
  rtail

  ))

