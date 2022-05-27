;;;============================================================================

;;; File: "reactive-html#.scm"

;;; Copyright (c) 2020-2021 by Léonard Oest O'Leary, All Rights Reserved.

;;;============================================================================

(define-macro (define-html-tag tag)

  (let* ((proc-name tag)
         (tag-string (symbol->string tag))
         (tag-name (substring tag-string 1 (- (string-length tag-string) 1))))
    `(define (,proc-name . args)

       ;; variable that makes sure that the parent isnt registered twice
       ;; the observer checks if children nodes are removed. If its the case
       ;; we remove the reactive blocks attached to that node
       (define should-register-observer #f)

       (let ((table (parse-args args (make-table)))
             (elem (createElement ,tag-name)))
         ;;validate table
         (for-each
          (lambda (kv)
            (let ((key (car kv))
                  (value (cdr kv)))
              (cond
               ((equal? key body:)
                (for-each
                 (lambda (value)
                   (if (reactive? value)
                       (let ((old (toDomElement (reactive-ref value)))
                             (ccc 0))
                         (set! should-register-observer #t)
                         \(`elem).appendChild(`old)

                         ;; If we have a reactive-block, register it with this node
                         (if (reactive-block? value)
                             (register-reactive-block-on-dom elem value))

                         (register-reactive-block-on-dom
                          elem
                          ;; creates the reactive block and register it right away
                          (reactive
                           (let ((new (toDomElement (reactive-ref value))))
                             #;\console.log("updated", `ccc, `new)
                             \(`elem).replaceChild(`new, `old)
                             (set! old new)
                             (set! ccc (+ ccc 1))))))
                       \(`elem).appendChild(`(toDomElement value))))
                 value))

               ((on-keyword? key)
                =>
                (lambda (event)
                  \(`elem).addEventListener(`event,
                                            `(lambda (e)
                                               (write
                                                (lambda () (value e))
                                                event-queue)))))
               ((link-keyword? key)
                =>
                (lambda (prop)
                  (reactive \(`elem)[`prop]=`(reactive-ref value))))
               ((reactive? value)

                ;; registers the block so that it is deleted when the element is deleted
                (if (reactive-block? value)
                    (register-reactive-block-on-dom elem value))

                ;; creates a bloc that update the attribute when the value is changed
                (let ((reactive-elem
                       (reactive
                        \(`elem).setAttribute(`(keyword->string key), `(reactive-ref value)))))
                  ;; call the block
                  (reactive-block-update! reactive-elem)
                  ;; register it
                  (register-reactive-block-on-dom elem reactive-elem)))
               (else
                \(`elem).setAttribute(`(keyword->string key), `value)))))

          (table->list table))

         (if should-register-observer
             (register-observer-on-parent elem))

         elem))))

(define-macro (define-and-register-tag . tags)
   `(begin
      ,@(map
         (lambda (tag)
             `(define-html-tag ,tag))
         tags)
      (##namespace ("reactive-html#" ,@tags))))

(##namespace ("reactive-html#"
              createElement
              createApp
              on-keyword?
              link-keyword?
              toDomElement
              parse-args
              remove-reactive-block-on-dom
              register-reactive-block-on-dom
              register-observer-on-parent
              event-queue
              listen-events))

;; source https://developer.mozilla.org/en-US/docs/Web/HTML/Element
(define-and-register-tag

  <div>
  <a>
  <h1>
  <h2>
  <h3>
  <p>
  <br>
  <button>
  <input>
  <label>


  ;; main root
  <html>

  ;; document metadata
  <base>
  <head>
  <link>
  <meta>
  <style>
  <title>

  ;; sectionning root
  <body>

  ;; content sectionning
  <address>
  <article>
  <aside>
  <footer>
  <header>
  <h1>
  <h2>
  <h3>
  <h4>
  <h5>
  <h6>
  <main>
  <nav>
  <section>

  ;; text content
  <blockquote>
  <dd>
  <div>
  <dl>
  <dt>
  <figcaption>
  <figure>
  <hr>
  <li>
  <ol>
  <p>
  <pre>
  <ul>

  ;; inlide text semantics
  <a>
  <abbr>
  <b>
  <bdi>
  <bdo>
  <br>
  <cite>
  <code>
  <data>
  <dfn>
  <em>
  <i>
  <kbd>
  <mark>
  <q>
  <rb>
  <rp>
  <rt>
  <rtc>
  <ruby>
  <s>
  <samp>
  <small>
  <span>
  <strong>
  <sub>
  <sup>
  <time>
  <u>
  <var>
  <wbr>

  ;; image and multimedia
  <area>
  <audio>
  <img>
  <map>
  <track>
  <video>

  ;; embedded content
  <embed>
  <iframe>
  <object>
  <param>
  <picture>
  <portal>
  <source>

  ;; svg and mathml
  <svg>
  <math>

  ;; scripting
  <canvas>
  <noscript>
  <script>

  ;; demarcating edits
  <del>
  <ins>

  ;; table content
  <caption>
  <col>
  <colgroup>
  <table>
  <tbody>
  <td>
  <tfoot>
  <th>
  <thead>
  <tr>

  ;; Forms
  <button>
  <datalist>
  <fieldset>
  <form>
  <input>
  <label>
  <legend>
  <meter>
  <optgroup>
  <option>
  <output>
  <progress>
  <select>
  <textarea>

  ;; interactive elements
  <details>
  <dialog>
  <menu>
  <summary>

  ;; web component
  <slot>
  <template>)
