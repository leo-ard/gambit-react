;;;============================================================================

;;; File: "reactive-html#.scm"

;;; Copyright (c) 2020-2022 by Léonard Oest O'Leary and Marc Feeley, All Rights Reserved.

;;;============================================================================

(define-macro (define-html-tag tag)
  
  (let* ((proc-name tag)
         (tag-string (symbol->string tag))
         (tag-name (substring tag-string 1 (- (string-length tag-string) 1))))
    `(define ,proc-name (gen-tag ,tag-name))

  ))

(define-macro (define-and-register-tag . tags)
   `(begin
      ,@(map
         (lambda (tag)
             `(define-html-tag ,tag))
         tags)
      (##namespace ("reactive-html#" ,@tags))))

(##namespace ("reactive-html#"
              create-app
              createElement
              ;createApp
              on-keyword?
              link-keyword?
              toDomElement
              parse-args
              remove-reactive-node-on-dom
              register-reactive-node-on-dom
              event-queue
              listen-events
              gen-tag
              $$body-tag

              reactive-socket
              reactive-socket-send
              reactive-socket-receive
              reactive-socket-open

              ))

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
