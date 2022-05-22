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

(##include "reactive#.scm")
(##include "reactive-html#.scm")

(##declare (extended-bindings) (standard-bindings) (block))

(define-type Fait
  start
  rel
  end
  start-id
  rel-id
  end-id)

;; app.scm


(define (random-integer v)
  \Math.floor(Math.random()*`v))

(define (random-boolean)
  (eqv? (random-integer 2) 0))

(define (link reactive-var) (lambda (e) (reactive-set! reactive-var \(`e).srcElement.value)))
(define faits (reactive-var #f))
(define faits-loaded (reactive-var #f))
(define (faits-contains id)
  (fold (lambda (fait lst) (or (equal? id \(`fait)['@id']) lst)) #f (vector->list (reactive-ref faits))))

(define (faits-add! vector-to-add)
  \console.log(`vector-to-add)
  (let ((unique (fold (lambda (fact lst)
                        \console.log(`fact)
                        \console.log(`lst)
                        (if (faits-contains \(`fact)['@id']) lst (cons fact lst)))
                      '()
                      (vector->list vector-to-add))))
    (reactive-set! faits (vector-append (reactive-ref faits) (list->vector unique))))
    )

(define page (reactive-var "menu"))
(define all-pages '("menu" "games" "database"))


(define (display-loading-table)
  (<table> class: "table"
           (<thead> (<tr> (<th> "start")
                          (<th> "Relation")
                          (<th> "End")))
           (<tbody> (<tr> (<th> "Loading...")
                          (<th> "Loading...")
                          (<th> "Loading...")))))

(define (display-table facts)
  (<table> class: "table"
           (<thead> (<tr> (<th> "start")
                          (<th> "Relation")
                          (<th> "End")))
   (<tbody>
    body: (map (lambda (e) (<tr> (<th> \`e['start']['label'])
                                 (<th> \`e['rel']['label'])
                                 (<th> \`e['end']['label'])))
               (vector->list \`facts)))))

(define (<menu-button> name menu)
  (<button> type: "button"
            class: "btn btn-primary"
            on:click: (lambda (e) (reactive-set! page menu))
            name))

(define (display-menu)
   (<div>
    (<h1> "Welcome to the ConceptNet Client")
    (<p>
     (<a> "ConceptNet" href: "https://conceptnet.io/")
     " is a database made up of facts about concepts. You can see example of facts below."
     "You can checkout the games under the games tab or make requests to the database under the database tab. "
     "The table below is stored on runtime and is used as default for the games. You can add new concepts by searching them with the database tab")

    (reactive (if (reactive-ref faits-loaded)
                  (display-table (reactive-ref faits))
                  (display-loading-table)))))

(define (display-jeu)
  (define jeu-en-cours (reactive-var 'oui-non))
  (define jeux (make-table))
  (define (setup-button sym)
    (lambda (e) (reactive-set! jeu-en-cours sym)))

  (table-set! jeux 'oui-non jeu-oui-non)
  (table-set! jeux 'consigne jeu-consigne)
  (table-set! jeux 'qui-suis-je jeu-qui-suis-je)

  (<div>
   (<h1> "Choose a game !")
   (<div>
    (<div>
     class: "row"
     (reactive
      (<ul>
       class: "col-md-auto list-group"
       body: (map (lambda (sym)
                    (<li> (string-append "Jeu " (symbol->string sym))
                          class: (string-append "list-group-item " (if (eq? (reactive-ref jeu-en-cours) sym)
                                                                   "active"
                                                                   ""))
                              on:click: (setup-button sym))

                    )
                  '(oui-non consigne qui-suis-je))))

     (reactive
      (<div>

       class: "col mx-auto container"
       (if (reactive-ref faits-loaded)
           ((table-ref jeux (reactive-ref jeu-en-cours)))
           (<p> "Les faits n'ont pas fini de loader..."))
       )
      )))

     )



    )

(define (unique-concepts facts)
  (let ((table (make-table)))
    (for-each (lambda (fact)
                (table-set! table \(`fact)['start']['@id'] #t)
                (table-set! table \(`fact)['end']['@id'] #t))
              (vector->list facts))
    (table->list table)
    ))


(define (unique-relations facts)
  (let ((table (make-table)))
    (for-each (lambda (fact)
                (table-set! table \(`fact)['rel']['@id'] #t))
              (vector->list facts))
    (table->list table)))

(define (<nav-bar>)
  (<div>
   (reactive
    (<div>
     class: "navbar navbar-fix-top"
     style: "background-color: #20a4f3"
     (<div>
      class: "pull-left mr-auto d-flex align-items-center"

      body: (cons
             (<span>
              style: "color: #292929; font-family:Calibri, sans-serif;"
              class: "h1 my-0 mx-2"
              (<img>
               style: "height:60px;"
               src: "./logo-simple.png"
               class: "mx-2")
              "ConceptNet Client"

              )
             (map
             (lambda (name)
               (<button>
                class: (string-append "btn mx-2 my-auto " (if (equal? (reactive-ref page) name) "btn-light" "text-dark"))
                on:click: (lambda (e) (reactive-set! page name))
                name))
             all-pages

             ))
      )
     (<div>
      class: "pull-right"
      style: "margin-left: auto"
      (<span>
       ""))
     (<div>
      class: "pull-right"
      (if (reactive-ref faits-loaded)
          (<div>
           class: "mx-4"
           (<span>
            (vector-length (reactive-ref faits))
            " facts in memory" )
           (<br>)
           (<span>
            (length (unique-concepts (reactive-ref faits)))
            " unique concepts"
            )
           (<br>)
           (<span>
            (length (unique-relations (reactive-ref faits)))
            " unique relations"
            )
           )

          (<span>
           class: "mx-4"
           "Facts are still loading...")))))))

(define (fait->Fait fait)
  (make-Fait \(`fait)['start']['label']
             \(`fait)['rel']['label']
             \(`fait)['end']['label']
             \(`fait)['start']['@id']
             \(`fait)['rel']['@id']
             \(`fait)['end']['@id']))

(define (get-random-fait faits)
  \console.log(`faits)
  (let ((index (random-integer (vector-length faits))))
    \console.log(`index)
    (fait->vector (vector-ref faits index))))

(define (get-random-fait* faits)
  (let ((index (random-integer (vector-length faits))))
    (vector-ref faits index)))

(define (get-random-concept faits)
  (let ((fait (get-random-fait* faits))
        (start-or-end? (random-boolean)))
    (if start-or-end?
        (cons \(`fait)['start']['@id'] \(`fait)['start']['label'])
        (cons \(`fait)['end']['@id']   \(`fait)['start']['label']))))


(define (fait->vector fait)
  (vector
   \(`fait)['start']['label']
   \(`fait)['rel']['label']
   \(`fait)['end']['label']))

(define (get-swaped-random-fait faits)
  (let* ((swap-index (random-integer 3))
         (fait1 (get-random-fait faits))
         (fait2 (get-random-fait faits)))
    (if (equal? (vector-ref fait1 swap-index) (vector-ref fait2 swap-index))
        (get-swaped-random-fait faits)
        (vector-set fait1 swap-index (vector-ref fait2 swap-index)))))

(define (<fait> fait)
  (<p> (<span>
        style: "font-style: italic"
        (vector-ref fait 0))
       " "
       (<span>
        style: "font-weight: bold"
        (vector-ref fait 1))
       " "
       (<span>
        style: "font-style: italic"
        (vector-ref fait 2))))

(define (setup-timer timeout-action time)
  \setTimeout((`timeout-action), `time))



(define (jeu-oui-non)
  (define timer (reactive-var 20))
  (define state (reactive-var 'start))
  (define timer-ref #f)
  ;(define statement (get-random-statement faits))
  (define valid #f)
  (define statement #f)
  (define (timeout-action)
    (let ((newTime (- (reactive-ref timer) 1)))
      (reactive-set! timer newTime)
      (if (eq? (reactive-ref state) 'waiting)
          (if (> newTime 0)
              (set! timer-ref (setup-timer timeout-action 1000))
              (reactive-set! state 'no-time)))))

  (define (input-response res)
    (lambda (e)
      (if (eq? res valid)
          (reactive-set! state 'win)
          (reactive-set! state 'lose))))

  (define (start _)
    (if timer-ref
        \clearTimeout(`timer-ref))
    (reactive-set! timer 60)
    (set! valid (random-boolean))
    (set! statement (if valid (get-random-fait (reactive-ref faits)) (get-swaped-random-fait (reactive-ref faits))))
    (set! timer-ref (setup-timer timeout-action 1000))
    (reactive-set! state 'waiting))

  (<div>
   (reactive
    (cond
     ((eq? (reactive-ref state) 'start)
      (<div>
       (<p> "In this game, a random statement will showup on the screen. Depending on the truthness of the statement, press the according button. For exemple: \"Gambit Synonym Slow\" is a false statement.")
       (<button>
        class: "btn btn-primary"
        on:click: start
        "Start Game")))

     ((eq? (reactive-ref state) 'waiting)
      (<div>
       (<p> (string-append (number->string (reactive-ref timer)) " seconds left" ))
       (<fait> statement)
       (<button> class: "btn btn-primary"
                 on:click: (input-response #t)
                 "True")
       (<button> class: "btn btn-primary mx-2"
                 on:click: (input-response #f)
                 "False")))
     ((eq? (reactive-ref state) 'no-time)
      (<div>
       (<p> "Time is out ! You lost")))
     ((eq? (reactive-ref state) 'lose)
      (<p> "This is not the right answer, you lost !"
           (<br>)
           (<button> "Try again ?"
                     class: "btn btn-primary"
                     on:click: start)))
     ((eq? (reactive-ref state) 'win)
      (<p> "Fantastic ! This is the right answer"
           (<br>)
           (<button> "Play again ?"
                     class: "btn btn-primary m-2"
                     on:click: start)))
     (else (<p> (string-append "state " (symbol->string state) " invalid")))))))

(define (list-><table> name lst h-lst show-points)
  \console.log(`h-lst)
    (<table>
     ;(<thead> name)
     (reactive
      (let ((points 0))
        (<tbody>
         body: (map (lambda (x) (if (member x h-lst)
                                    (begin
                                      (set! points (+ 1 points))
                                      (<tr> (<th> style: "font-weigth:bold;" (string-append x " (1 point !)")))
                                      )
                                    (<tr> (<th> x)))) (reactive-ref lst))
         (if show-points
             (<p> "Et vous avez " points " points")
             (<div>)))))))


(define (<timer> timer)
  (<div> (reactive (<p> "Il vous reste " (reactive-ref timer) " secondes !"))))

(define (<linked-input> reactive-var placeholder action)
  (<div>
   class: "input-group mb-3"
   (<input> type: "input"
            class: "form-control"
            on:input: (link reactive-var)
            on:keyup: (lambda (event)
                        \console.log(`event)
                        (if (equal? \(`event)['key'] "Enter")
                            (action event)
                                          ))
            link:value: reactive-var
            placeholder: "placeholder")
   (<div>
    class: "input-group-append"
    (<button>
     class: "btn btn-primary"
     on:click: action
     "submit"))))

(define (reactive-<fait> fait random-hidden)
  (<div>
   (reactive
    (let ((vec-fait (fait->vector (reactive-ref fait))))
      (<fait> (vector-set vec-fait random-hidden "?"))))))

(define (jeu-consigne)
  (define state (reactive-var 'start))
  (define timer (reactive-var 0))
  (define consigne #f)
  (define random-hidden 0)
  (define word-input (reactive-var ""))
  (define word-list (reactive-var '()))
  (define solution #f)
  (define (add-word-list! word)
    (if (not (member word (reactive-ref word-list)))
        (reactive-set! word-list (cons word (reactive-ref word-list)))

        )
    )

  (define (timeout-action)
    (let ((newTime (- (reactive-ref timer) 1)))
      (reactive-set! timer newTime)
      (if (eq? (reactive-ref state) 'waiting)
          (if (> newTime 0)
              (setup-timer timeout-action 1000)
              (begin
                (reactive-set! state 'score)
                )
              ))))

  (define (submit e)
    (add-word-list! (reactive-ref word-input))
    (reactive-set! word-input ""))

  (define (start _)
    (reactive-set! word-input "")
    (reactive-set! word-list '())
    (reactive-set! timer 60)
    (set! consigne (get-random-fait* (reactive-ref faits)))
    (set! random-hidden 2)
    (setup-timer timeout-action 1000)
    (let ((g \(new Object())))
      \(`g)['start']=(`consigne)['start']['@id']
      \(`g)['rel']=(`consigne)['rel']['@id']
      \foreign(query_concept(`g).then(`(lambda (e) (faits-add! \(`e)['edges']) (set! solution e))))
      )
    \console.log("set setate")
    (reactive-set! state 'waiting)
    \console.log("heyy"))

  (define (display-words)
     (reactive (<p> (list-><table> "words" word-list '() #f))))

  (<div>
   (reactive
    (cond
     ((eq? (reactive-ref state) 'score)
      (<div>
       (<fait> (vector-set (fait->vector consigne) random-hidden "???"))
       (<h3> "Times out ! Your answers :")
       (list-><table> "word" word-list (map (lambda (x) \(`x)['end']['label']) (vector->list \(`solution)['edges'])) #t)
       (<h3> "Good answers :")
       (<div>
        body: (map (lambda (e) (<span> \(`e)['end']['label'] ", ")) (vector->list \(`solution)['edges'])))
       )


      )
     ((eq? (reactive-ref state) 'start)
      (<div>
       (<p> "A random statement will appear on screen, but one component will be missing. It will be replaced by a `???`. "
            "Try to guess what can go there ! You gain one point for each good answers you get. Multiple answers are possible.")
       (<button> on:click: start
                 class: "btn btn-primary"
                 "Start !")))
     ((eq? (reactive-ref state) 'waiting)
      (<div> (<timer> timer)
             "Try to guess all the words !"
             (<fait> (vector-set (fait->vector consigne) random-hidden "???"))
             (<linked-input> word-input "Enter words here" submit)

             (display-words)))
     (else (<div> "error"))))))

(define (list-take lst k acc)
  (if (and (pair? lst) (> k 0))
      (list-take (cdr lst) (- k 1) (cons (car lst) acc) )
      acc))

(define (vector-map foo vec)
  (list->vector (map foo (vector->list vec))))

(define (string-contains-aux parent content parent-index content-index)
  \console.log(`parent)
  \console.log(`content)
  \console.log(`parent-index)
  \console.log(`content-index)
  (if (< (string-length parent) parent-index)
      (eqv? (string-length content) content-index)
      (if (eq? (string-ref parent parent-index)
               (string-ref content content-index))
          (if (eqv? (string-length content) content-index)
              #t
              (string-contains-aux parent content (+ 1 parent-index) (+ 1 content-index))
              )
          (string-contains-aux parent content (+ 1 parent-index) 0)
          )
      )
  )


;; Taken here : https://programming-idioms.org/idiom/10/shuffle-a-list/2021/scheme
(define list-shuffle
  (lambda (x)
    (if (< (length x) 2)
        list
        (let ((item (list-ref list (random-integer (length x)))))
          (cons item (shuffle (remove item x)))))))



(define (string-contains parent content)
  (string-contains-aux (string-upcase parent)
                       (string-upcase content)
                       0
                       0))

(define (display-bad bad)
  (<div>
   (reactive
    (if (reactive-ref bad)
        (<p> "mauvaise réponse !")
        (<div>)))))


(define (jeu-qui-suis-je)
  (define state (reactive-var 'start))
  (define timer (reactive-var 0))
  (define solution #f)
  (define hints #f)
  (define nb-show (reactive-var 0))
  (define maxtime #f)
  (define word-input (reactive-var ""))
  (define bad (reactive-var #f))
  (define (timeout-action)
    (let ((newTime (- (reactive-ref timer) 1)))
      (reactive-set! timer newTime)
      (reactive-set! nb-show (+ 1 (quotient (- maxtime newTime) 20)))

      (if (eq? (reactive-ref state) 'waiting)
          (if (> newTime 0)
              (setup-timer timeout-action 1000)
              (begin
                (reactive-set! state 'timeout))))))

  (define (hide-hint hint)
    (map (lambda (fait)
           (vector-set fait 0 "???")
           ;(vector-map (lambda (x) (if (string-contains x (cdr solution)) "???" x)) fait)
           )
         hint)
    )
  (define (fait->hint-vector fait)
    (if (equal? \(`fait)['start']['@id'] (car solution))
        (vector-set (fait->vector fait) 0 "???")
        (vector-set (fait->vector fait) 2 "???")))

  (define (start _)
    (set! solution (get-random-concept (reactive-ref faits)))
    (reactive-set! state 'loading)
    (let ((g \(new Object())))
      \(`g)['node']=(`(car solution))
      \(`g)['limit']=1000
      \query_concept(`g).then(remove_names).then(`(lambda (e) (set! hints (map fait->hint-vector (list-take (vector->list e) 5 '())))))
      )
    (set! maxtime (+ (* (length hints) 20) 20))
    (reactive-set! timer maxtime)
    (reactive-set! nb-show 1)
    (setup-timer timeout-action 1000)
    (reactive-set! state 'waiting)
    \console.log(`solution))

  (define (submit e)
    (if (equal? (string-upcase (reactive-ref word-input)) (string-upcase (cdr solution)))
        (reactive-set! state 'win)
        (begin
          (reactive-set! bad #t)
          (setup-timer (lambda () (reactive-set! bad #f)) 500)))
    )

  (define (get-hints)
    (<div>
     (reactive
      (<div>
       body: (map <fait> (list-take hints (reactive-ref nb-show) '())))
      )
     ))
  (define (calculate-score)
    (- 8 (quotient (- maxtime (reactive-ref timer)) 20)) )

  (<div>
   (reactive
    (cond
     ((eq? (reactive-ref state) 'loading)
      (<p> "loading"))
     ((eq? (reactive-ref state) 'start)
      (<div>
       (<p> "Each 20s, a new statement will apear. Try to guess which word can go there !")
       (<button> on:click: start
                 class: "btn btn-primary"
                 "Start !")
       )
      )
     ((eq? (reactive-ref state) 'win)
      (<div> (<p> "You won " (calculate-score) " points ! Good job !")
             (<button> class: "btn btn-primary"
                       "Replay ?"
                       on:click: start))
      )
     ((eq? (reactive-ref state) 'timeout)
      \console.log(`solution)
      (<div>
       (<p> "Malheureusement la réponse était : " (cdr solution))
       (<button> class: "btn btn-primary"
                 "Replay ?"
                 on:click: start)
       ))
     ((eq? (reactive-ref state) 'waiting)
      \console.log(`hints)
      (<div>
       (get-hints)
       (<timer> timer)
       (display-bad bad)
       (<linked-input> word-input "Entrez votre guess !" submit)

       )
      ))))





  )

(define unique-id 0)
(define (get-unique-id)
  (set! unique-id (+ unique-id 1))
  (string-append "id-" (number->string unique-id)))

(define (<reactive-input> label reactive-var placeholder)
  (let ((id (get-unique-id)))
    (<div>
     class: "input-group mb-3"
     (<div>
      class: "input-group-prepend"
      (<span>
       class: "input-group-text"
       label))
     (<input>
      class: "form-control"
      on:input: (link reactive-var)
      placeholder: placeholder))))

(define (<reactive-button> reactive-var name)
  (<div>
   (reactive
    (if (reactive-ref reactive-var)
        (<li>
         class: "page-item"
         on:click: (reactive-ref reactive-var)
         name)
        (<div>)))))

(define (display-database)

  (define node-input (reactive-var ""))
  (define relation-input (reactive-var ""))


  (define nbreq (reactive-var ""))
  (define show-all (reactive-var #f))
  (define database-result (reactive-var #f))
  (define next-page (reactive-var #f))
  (define prev-page (reactive-var #f))
  (define first-page (reactive-var #f))

  (define (search-database e)
    (define (f e)
      (let* ((before-filter \(`e)['edges'])
             (after-filter  \(`before-filter).filter(filter_names)))
        (faits-add! after-filter)
        (if \(`e)['view']!==undefined
            (begin
              (if \(`e)['view']['nextPage']!==undefined
                  (reactive-set! next-page (lambda (_)
                                             (reactive-set! database-result 'loading)
                                             \foreign((`e).nextPage().then(`f))
                                             ))
                  (reactive-set! next-page #f))
              (if \(`e)['view']['previousPage']!==undefined
                  (reactive-set! prev-page (lambda (_)
                                             (reactive-set! database-result 'loading)
                                             \foreign((`e).previousPage().then(`f))
                                             ))
                  (reactive-set! prev-page #f))
              (if \(`e)['view']['firstPage']!==undefined
                  (reactive-set! first-page (lambda (_)
                                              (reactive-set! database-result 'loading)
                                              \foreign((`e).firstPage().then(`f))
                                              ))
                  (reactive-set! first-page #f)))
            (begin
              (reactive-set! first-page #f)
              (reactive-set! prev-page #f)
              (reactive-set! next-page #f)))
        (reactive-set! nbreq
                       (string-append
                        (number->string (vector-length after-filter))
                        " (fr/en) "
                        (number->string (vector-length before-filter))
                        " (tout) "))
        (reactive-set! database-result before-filter)))

    (reactive-set! database-result 'loading)
    (let ((query \Object()))
      (if (not (equal? (reactive-ref node-input) ""))
          \(`query)['node']=`(reactive-ref node-input))

      (if (not (equal? (reactive-ref relation-input) ""))
          \(`query)['rel']=`(reactive-ref relation-input))
      \(`query)['limit']=100

      \foreign(query_concept(`query).then(`f).catch(`(lambda (e) \console.log(`e) (reactive-set! database-result 'error))))))
  (define (<pagination>)
    (<nav>

     (reactive
      (<ul>
       class: "pagination my-4"
       body: (append
              (fold (lambda (name lst)
                    (if (car name)
                        (cons (<li> class: "page-item"
                                    on:click: (car name)
                                    (<span>
                                     class: "page-link"
                                     (cdr name)
                                     )
                                    )
                              lst)
                        lst))
                   '()
                   (list
                    (cons (reactive-ref next-page) "Next Page")
                    (cons (reactive-ref first-page) "First Page")
                    (cons (reactive-ref prev-page) "Previous Page")))
              (list
               (<li>
                class: "my-auto mx-2 input-group-text"
                (<input>
                 class: "mx-2"
                 type: "checkbox"
                 id: "see-all"
                 on:input: (lambda (e) (reactive-set! show-all \(`e).srcElement.checked))
                 (if (reactive-ref show-all)
                     checked:
                     "")
                 ""
                 )
                (<label> for: "see-all" "Voir toutes les langues"))))))))

  (<div> (<h1> "Database searcher")
         (<reactive-input> "Relation: " relation-input "e.g. /r/RelatedTo ")
         (<reactive-input> "Node: " node-input "e.g. /c/en/gambit")
         (<button>
          class: "btn btn-primary btn-block w-100"
          on:click: search-database
          "Search !")

         (reactive
          (cond
           ((eq? 'loading (reactive-ref database-result))
            "Loading result...")
           ((eq? 'error (reactive-ref database-result))
            "There was an error, maybe conceptNet is down ?")
           ((reactive-ref database-result)
            (<div>
             (<pagination>)
             (<p> (string-append "Nombre de résultats :" (reactive-ref nbreq)))
             (if (reactive-ref show-all)
                 (display-table (reactive-ref database-result))
                 (display-table \(`(reactive-ref database-result)).filter(filter_names)))))
           (else "")))))

(createApp
 debug: #f
 (<nav-bar>)
 (reactive
  (<div>
   class: "w-75 mx-auto my-4"
   (cond
    ((equal? (reactive-ref page) "menu") (display-menu))
    ((equal? (reactive-ref page) "games") (display-jeu))
    ((equal? (reactive-ref page) "database") (display-database))
    (else (<div> "error"))))))

\foreign(get_100_faits().then(`(lambda (e) (reactive-set! faits e) (reactive-set! faits-loaded #t))))

(listen-events)
