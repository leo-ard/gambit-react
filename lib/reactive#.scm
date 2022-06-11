;;;============================================================================

;;; File: "reactive#.scm"

;;; Copyright (c) 2020-2021 by Léonard Oest O'Leary and Marc Feeley, All Rights Reserved.

;;;============================================================================


(define-macro (reactive . args)
  (let ((block-name (gensym))
        (value      (gensym)))
    `(let* ((,block-name (reactive-block (lambda () ,@args) '()))
            (,value      ($$retrieve-value ,block-name)))
       (reactive-node-value-set! ,block-name ,value)
       ,block-name)))

(define-macro (reactive-ref reactive-var)
  `($$reactive-ref ($$reactive-scope) ,reactive-var))

(##namespace
 ("reactive#"
  
  reactive-var
  reactive-block
  $$reactive-update-dependencies
  $$reactive-scope
  $$add-dependencie
  $$reactive-ref
  $$retrieve-value

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

  ))

