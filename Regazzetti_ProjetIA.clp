; Regazzetti Lea
; Numero Etudiant : 2195697
; L3 MIASHS IDS
; Projet Intelligence Artificielle

; Partie 1

; Exo 1,2 : initialisation de la base de faits
(deffacts labyrinthe
	; dans ma base de faits, les chemins sont a double-sens, ainsi vous trouverez le fait laby entre un noeud nx et un noeud ny mais aussi son symetrique
	(laby n1 n2)
	(laby n2 n7)
	;Partie 4 : ajouts de cles de passage
	;(laby n2 n3)
	;(laby n3 n2)
	(laby n3 n4)
	(laby n3 n5)
	(laby n3 n6)
	(laby n4 n3)
	(laby n4 n5)
	(laby n4 n7)
	(laby n5 n3)
	(laby n5 n4)
	(laby n6 n3)
	(laby n7 n2)
	(laby n7 n4)
	(noeud_courant n1) ;emplacement initial de l'aventurier avec le fait noeud_courant, il partira du noeud n1 par exemple
	;Partie 2 Exo 7
	(tresor n4 20) ;les tresors avec emplacement et montant
	(tresor n6 10)
	(monstre n7 10) ;les monstres avec emplacement et force
	(monstre n5 2)
	(force 5) ;score de force de l'aventurier initilisé à 5 par exemple
	(pieces 0) ;pour calculer le nombre de pieces récoltées par l'agent explorateur
	; Partie 4
	; Ajouts de competences
	(laby n2 n8)
	(laby n8 n2)
	(agilite n8 15)
	;(laby n4 n9)
	;(laby n9 n4)
	(laby n5 n9)
	(laby n9 n5)
	(ruse n9 10)
	; Ajouts de pieges
	(laby n7 n10)
	(laby n10 n7)
	(laby n4 n10)
	(laby n10 n4)
	(laby n6 n11)
	(laby n11 n6)
	(panthere n11 10)
	(renard n10 3)
	(agile 0)
	(rus 0)
	; Ajouts de cles de passage
	(cle n12 n2 n3)
	(cle n13 n4 n9)
	(laby n2 n12)
	(laby n12 n2)
	(laby n6 n12)
	(laby n12 n6)
	(laby n12 n11)
	(laby n11 n12)
	(laby n1 n13)
	(laby n13 n1)
	(laby n13 n8)
	(laby n8 n13)
	; Ajout d'une memoire
	(memoire n1)
)

; Exo 3 : regle demandant a l'utilisateur de choisir un endroit vers lequel aller
;(defrule demander
;	(declare (salience 5))
;	(noeud_courant ?nc)
;=>
;	(printout t "Vers quel endroit voulez-vous aller ? ")
;	(assert (noeud (explode$(lowcase (readline t)))))
;)

; Exo 4 : regle verifiant que le chemin existe
(defrule existe
	(declare (salience 2))
	?x <- (noeud_courant ?nc)
	?y <- (noeud ?n)
	(laby ?nc ?n)
=>
	(retract ?x)
	(retract ?y)
	(assert (noeud_courant ?n))
	(printout t "Le nouveau lieu est " ?n crlf)
)

; Exo 5 : regle si le lieu est inaccessible
(defrule inaccessible
	?x <- (noeud_courant ?nc)
	?y <- (noeud ?n)
=>
	(retract ?x)
	(retract ?y)
	(printout t "Le lieu est inaccessible" crlf)
	(assert (noeud_courant ?nc))
)

; Exo 6 : regle si l'utilisateur ne rentre aucune reponse
(defrule no_rep
	?x <- (noeud_courant ?nc)
	?y <- (noeud)
=>
	(retract ?x)
	(retract ?y)	
	(printout t "Je n'ai pas compris" crlf)
	(assert (noeud_courant ?nc))
	
)

; Exo 8 : regle pour un lieu comportant un tresor
(defrule lieu_tresor
	(declare (salience 10))
	?x <- (noeud_courant ?nc)
	?z <- (tresor ?nc ?t)
	?a <- (pieces ?p)
=>
	(retract ?x)
	(retract ?a)
	(retract ?z) ; on supprime le tresor
	(printout t "Tresor pris" crlf)
	(assert (pieces = (+ ?p ?t)))
	(assert (noeud_courant ?nc))
)

; Exo 9 : regle pour un lieu comportant un monstre plus faible
(defrule monstre_faible
	(declare (salience 10))
	?x <- (noeud_courant ?nc)
	?b <- (monstre ?nc ?m)
	(force ?f)
	(test(< ?m ?f))
=>
	(retract ?b)
	(printout t "Monstre plus faible supprime" crlf)
	(assert (noeud_courant ?nc))
)

; Exo 10 : regle pour un lieu comportant un monstre plus fort
(defrule monstre_fort
	(declare (salience 10))
	?x <- (noeud_courant ?nc)
	(monstre ?nc ?m)
	?a <- (pieces ?p)
	(force ?f)
	(test(> ?m ?f))
=>
	(retract ?x)
	(retract ?a) ; perd le tresor accumule
	(printout t "Perdu. Vous avez rencontre un monstre plus fort que vous." crlf)
)

; Exo 11 : fin de la partie 
(defrule fin
	(declare (salience 5))
	?x <- (noeud_courant ?nc)
	(noeud fin)
	(pieces ?p)
=>
	(retract ?x)
	(printout t "Partie finie. Votre tresor vaut " ?p crlf)
)

; Exo 12 : regle pour que l'aventurier se deplace seul
(defrule choix_direction
	(noeud_courant ?nc)
	(laby ?n ?m)
	; Partie 4 : ajout de memoire
	?a <- (memoire ?me)
	(test 
		(and 
			(eq ?nc ?n) ; il faut que le chemin existe
		 	(neq ?m ?me) ;mais pas que le noeud suivant soit celui qu'on a quitte precedemment
		 )
	)
=>
	(retract ?a)	
	(assert (noeud ?m))
	(assert (memoire ?nc))
)

; Avec la commande (set-strategy random) le jeu se termine toujours lorsque l'on rencontre un monstre plus fort

; Exo 14 : regle de fin conditionnelle. Par exemple la partie est gagnee et finie quand le magot de l'agent explorateur depasse 10 pieces
(defrule fin_condi
	(declare (salience 5))
	?x <- (noeud_courant ?nc)
	(pieces ?p)
	(test (> ?p 10))
=>
	(retract ?x)
	(printout t "Vous avez gagné " ?p " c'est plus que 10. Vous avez gagné!" crlf)
)

; Partie 4
; Les 6 regles suivantes concernent les ajouts de competences 
; Les 3 regles suivantes concernent le gain d'agilite de l'agent explorateur
;tout d'abord une regle pour ajouter un nombre aleatoire a la base de faits
(defrule alea_agilite
	(declare (salience 10))
	(noeud_courant ?nc)
	(agilite ?nc ?a)
=>
	(assert (alea (random 1 10)))
)
;regle pour le cas ou le nombre aleatoire est superieur a 5 pour l'agilite
(defrule ajout_agilite
	(declare (salience 10)) ;la meme priorite que les monstres
	?x <- (noeud_courant ?nc)
	?w <- (agilite ?nc ?a)
	?z <- (alea ?y)
	?q <- (agile ?ag)
	(test(> ?y 5))
=>
	(retract ?x)
	(retract ?q)
	(assert (agile =(+ ?ag ?a)))
	(retract ?z)
	(assert (noeud_courant ?nc))
	(printout t "Bravo, vous avez gagné " ?a " points d'agilite ! " crlf)
	(retract ?w)
)
;regle pour le cas ou le nombre aleatoire est inferieur a 5 pour l'agilite
(defrule pas_agilite
	(declare (salience 10))
	(noeud_courant ?nc)
	(agilite ?nc ?a)
	?z <- (alea ?y)
	(test(<= ?y 5))
=>
	(retract ?z)
	(printout t "Dommage vous n'avez pas eu le score d'agilite, retentez une prochaine fois..."  crlf)
)

; Les 3 regles suivantes concernent le gain de ruse de l'agent explorateur
;tout d'abord une regle pour ajouter un nombre aleatoire a la base de faits
(defrule alea_ruse 
	(declare (salience 10))
	(noeud_courant ?nc)
	(ruse ?nc ?r)
=>
	(assert (alea (random 1 10)))
)
;regle pour le cas ou le nombre aleatoire est superieur a 5 pour la ruse
(defrule ajout_ruse
	(declare (salience 10)) ;la meme priorite que les monstres
	?x <- (noeud_courant ?nc)
	?w <- (ruse ?nc ?r)
	?z <- (alea ?y)
	?q <- (rus ?ru)
	(test(> ?y 5))
	
=>
	(retract ?x)
	(retract ?q)
	(assert (rus =(+ ?ru ?r)))
	(retract ?z)
	(assert (noeud_courant ?nc))
	(printout t "Bravo, vous avez gagné " ?r " points de ruse ! " crlf)
	(retract ?w)
)
;regle pour le cas ou le nombre aleatoire est inferieur a 5 pour la ruse
(defrule pas_ruse
	(declare (salience 10))
	(noeud_courant ?nc)
	(ruse ?nc ?r)
	?z <- (alea ?y)
	(test(<= ?y 5))
=>
	(retract ?z)
	(printout t "Dommage vous n'avez pas eu le score de ruse, retentez une prochaine fois..."  crlf)
)

; Les 4 regles suivantes concernent les ajouts de pieges
; regle pour un lieu comportant un renard plus faible
(defrule renard_faible
	(declare (salience 10))
	?x <- (noeud_courant ?nc)
	?b <- (renard ?nc ?re)
	(rus ?r)
	(test(< ?re ?r))
=>
	(retract ?b)
	(printout t "Renard plus faible supprime" crlf)
	(assert (noeud_courant ?nc))
)

; regle pour un lieu comportant un renard plus fort
(defrule renard_fort
	(declare (salience 10))
	?x <- (noeud_courant ?nc)
	(renard ?nc ?re)
	?y <- (rus ?r)
	(test(> ?re ?r))
=>
	(retract ?x)
	(retract ?y) ; perd le score de ruse accumule et fin de partie
	(printout t "Vous avez rencontre un renard plus fort que vous, vous avez perdu." crlf)
)

; regle pour un lieu comportant une panthere plus faible
(defrule panthere_faible
	(declare (salience 10))
	?x <- (noeud_courant ?nc)
	?b <- (panthere ?nc ?p)
	(agile ?a)
	(test(< ?p ?a))
=>
	(retract ?b)
	(printout t "Panthrere plus faible supprimee" crlf)
	(assert (noeud_courant ?nc))
)

; regle pour un lieu comportant une panthere plus forte
(defrule panthere_forte
	(declare (salience 10))
	?x <- (noeud_courant ?nc)
	(panthere ?nc ?p)
	?y <- (agile ?a)
	(test(> ?p ?a))
=>
	(retract ?x)
	(retract ?y) ; perd le score d'agilite accumule et fin de partie
	(printout t "Vous avez rencontre une panthere plus forte que vous, vous avez perdu." crlf)
)

; La regle suivante concerne l'ajout de cles de passage
;regle pour un lieu comportant une cle de passage
(defrule cle
	(declare (salience 10))
	?x <- (noeud_courant ?nc)
	?y <- (cle ?c ?a ?b)
	(test (eq ?nc ?c))
=>
	(retract ?x)
	(retract ?y)
	(printout t "Cle prise, passage ouvert entre " ?a " et " ?b crlf)
	(assert (laby ?a ?b))
	(assert (laby ?b ?a))
	(assert (noeud_courant ?nc))
)

