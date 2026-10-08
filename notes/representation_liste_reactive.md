# Représentation des listes réactives
Dans cet article, j'essaie de trouvé la forme canonique des listes réactive.
J'explore plusieurs représentation possible et j'essaie d'implémenté les
fonctions de base des listes, que je préfixe avec un `r`. Par exemple, sur les
listes, on a les fonctions `list`, `append!`, `cons`, `car`, `cdr` etc...
J'essaie donc de trouver `rlist`, `rappend!`, `rcons`, `rcar`, `rcdr`


## Représentation "style lazy"
### Type
`RLIST := (val . (rvar RLIST)) | '()`
### Exemples:
```
(rlist 1 2 3) => (1 . (rvar (2 . rvar (3 . (rvar '())))))
(rlist) => '()

(rcons 1 2) => (1 . (rvar 2))

(rcar (rlist 1 2)) => 1
(rcdr (rlist 1 2)) => (2 . (rvar '()))
```

### Avantages:
**composable**
```
(rappend! (rlist 1 2) (rlist 3 4))
=>
(rappend! (1 . (rvar (2 . (rvar '()))))
          (3 . (rvar (4 . (rvar '())))))
=>
(reactive-update! (rcddr (rlist 1 2))
                  (rlist 3 4))


On a juste a prendre la fin de la (rlist 1 2) et de faire un reactive-update avec la deuxieme liste.
```


### Desavantages
**cas  de base étrage**
```
Comme le cas de base est une liste vide, il ne contient aucune variable réactive. On ne peux pas facilement muté cette liste vide pour créer des updates par la suite. Par exemple, si on fait quelquechode comme :

(define x (rlist))

(append! x (rlist 2 3)) ; problème ici

Il n'y a aucun moyen de savoir que `x` a changé avec un (reactive ...). Cela cause problème si on veut faire une map réactif...
```

## Représentation "style variable réactive"
### Type
`RLIST := (rvar (val . RLIST)) | (rvar '())`

## Exemples:
```
(rlist 1 2 3) => (rvar (1 . (rvar (2 . (rvar (3 . (rvar '())))))))
(rlist) => (rvar '())

(rcons 1 2) => (rvar (1 . 2))

(rcar (rlist 1 2 3)) => 1
(rcdr (rlist 1 2 3)) => (rvar (2 . (rvar (3 . (rvar '())))))

```

### Avantages
**cas de base meilleur**
```
Si on crée la liste vide, on peut facilement modifier son contenu "sans problème"

(define x (rlist))

(reactive (pp "liste modifiée") (reactive-ref x))

(append! x (rlist 1 2 3))

```

### Desavantage

**plus difficilement composable**
```
Si on essaie de faire un append, on arrive a un problème :

(append! (rlist 1 2) (rlist 3 4))
=>
(append! (rvar (1 . (rvar (2 . (rvar '())))))
         (rvar (3 . (rvar (4 . (rvar '())))))
)
=>
...?

On a ici une duplication de variable réactive. Pour faire le "append", il faudrait remplacé le (rvar '()) de la première liste avec la deuxième liste. Il faudrait donc avoir une opération de "bind" entre deux variables réactives pour que la valeur de (rvar '()) soit toujours égale à (rvar (3 . ...)), ce qui n'est pas impossible mais complique l'opération et peut causé des "side effects" si mal fait.
```

**Un peut plus contre intuitif**
```
Si un programmeur veut mettre a jour la liste, il ne peut pas faire quelquechode comme :

(define x (rlist))
(reactive-update! x (rlist 1 2 3))

On va se retrouvé avec x = (rvar (rvar (1 . (var . ...))))
```


## Autre questioments ?
Q: Est-ce que les valeurs dans a liste devrait par défault etre réactif ?
Par exemple, est-ce qu'on devrait avoir le type :
`rlist = ((rvar val) . (rvar rlist)) | '()` (pour le style lazy)

un argument pour est la simplicité du `rcons`, et la capacité de faire des arbres facilement. On a donc que :

```
(rcons 1 2) => ((rvar 1) . (rvar 2))

(define reactive-tree (rcons (rcons 1 2) (rcons 3 4)))
=> (((rvar 1) . (rvar 2)) . ((rvar 3) . (rvar 4)))

Toute modification a l'arbre est réactive !
```

