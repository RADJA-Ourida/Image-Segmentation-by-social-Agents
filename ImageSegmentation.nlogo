patches-own [ G1  sup inf nbrNotSilks]
turtles-own [ lastFixedSilk]


;;; nettoyeage de l'image
to preprocessing
  ask patches with [pcolor > 10][
    set pcolor 0
  ]
end

;;;Création des Fourmis
to setupAnts
  reset-ticks
  set-default-shape turtles "bug"
  create-turtles Nbagent-Ants
   [set size 10
    set color red
    setxy random-xcor random-ycor
  ]
  set Nbagent-Ants 0
end

;;;Fonctionnement Des Fourmis
to goAnts
  let PNb-visited 0
  let Nb-visited 0
  let Total ( ( max-pxcor - min-pxcor + 1 ) * (max-pycor - min-pycor + 1 ) )
  ask patches [
    set sup max [pcolor] of neighbors
    set  inf min [pcolor] of neighbors
    set G1  sup - inf

  ]
  while [PerV >  PNb-visited ] [
    ask turtles [
      if G1 > Grad [ set pcolor white   ; Marquer le patch
      ]
      set G1 0  ; ne pas visiter le patch visité sauf si nécessaire
      move-to patch-here  ;se deplacer au centre du patch actuel
      let  p max-one-of neighbors  [G1]  ;; choisir le voisin ayant le gradient le plus élevé
      face p
      move-to p
      set Nb-visited (  Nb-visited + 1 )
      set PNb-visited (Nb-visited / Total ) * 100
   ]
 ]
  ask patches with [pcolor < 9.9][
      set pcolor 0
  ]

end

;;; La tache d'optimisation des paramétres de l'algorithme des fourmis
to optimize-params-Ants
  let List-Nbagent-Ants [ 5 10 15 20 ]
  let List-Grad [  1.0 1.2  1.4  1.6  1.8  2.0 2.2 2.4  ]

  foreach List-Nbagent-Ants [
    i ->
    foreach List-Grad [
      j ->

        set Nbagent-Ants i
        set Grad j
        clear-all
        import-pcolors "IRM1.png"

        preprocessing
        setupAnts
        goAnts

        let p word "Ant" Nbagent-Ants
        set p word p  "_"
        set p word p Grad
        let picture-name word p ".png"
        export-interface picture-name
      ]
    ]

end



;;;;;;;;;;;;;;;;;;;;;;;;;;;; SPIDERS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;Création des arraignées
to setupSpiders-auto
  let ListcouleurTortue [ 13 17 23 27 35 45 55 75 85 92 107 125 131 9 3]
  let i Nbagent-Spiders
  while [ i > 0 ] [
    crt 1 [
    set color ( item  i  ListcouleurTortue )
    set size 10
    set shape "spider"
    setxy random-xcor random-ycor
  ]
    set i ( i - 1 )
    set Nbagent-Spiders 0
  ]

  ask turtles [
    let colorpatch pcolor
    let listV neighbors with [abs ( colorpatch - pcolor ) < Thres ]
    if ( not  any? listV ) [   ;vérifie si aucun voisins dans la liste listV
      let p min-one-of neighbors  [pcolor]
      face p
      move-to p ; se déplacer vers p en fixant la soie
    ]
  ]

end


;;; La possibilité de déposer les arraignées manuellement
to setupSpiders-manual
  let ListcouleurTortue [ 13 17 23 27 35 45 55 75 85 92 107 125 131 9 3]
  if (mouse-down?)[
    if (Nbagent-Spiders > 0)[
      crt 1  [
        set color ( item ( Nbagent-Spiders mod length ListcouleurTortue ) ListcouleurTortue )
        set size 10
        set shape "spider"
        setxy mouse-xcor mouse-ycor
      ]
      set Nbagent-Spiders (Nbagent-spiders - 1)
   ]
 ]
  ask patches [
  set nbrNotSilks 1
  ]
  ask turtles [
  set lastFixedSilk patch-here
  ]
end


;;;Le fonctionnement des arraignées
to goSpiders
  ask patches [
  set nbrNotSilks 1
  ]
  ask turtles [
  set lastFixedSilk patch-here
  ]
  while [NbIt > 0 ] [
    ask turtles [
      let colorpatch pcolor
      let listV neighbors with [abs ( colorpatch - pcolor ) < Thres ]
      ifelse ( any? listV ) [   ;vérifie si il y a au moins un voisins dans la liste listV
           let  p max-one-of   listV [ nbrNotSilks ] ; on favorise les voisins de la liste listV qui  ne sont pas fixé ou ayant le moins de soies fixées
           set lastFixedSilk patch-here
           set nbrNotSilks  (nbrNotSilks - 1 ) ; décrementer le nombre de soies fixées du patch actuel
           face p
           pen-down
           move-to p ; se déplacer vers p en fixant la soie
          set nbrNotSilks  (nbrNotSilks - 1 ) ; décrementer le nombre de soies fixées du patch sur lequel on s'est déplacé
     ]

      [
          face lastFixedSilk      ; Le retour en arrière
          pen-up
          move-to lastFixedSilk ; le déplacement vers le dernier pixel fixé
      ]
    ]
    set NbIt (NbIt - 1 )

  ]

end

;;; L'optimisation des paramétres utilisées par l'algorithme des araignées
to optimize-params-spiders

  let List-NbIt [ 20000 30000 500000 ]
  let List-Nbagent-Spiders [ 5 10 14 ]
  let List-Thres [ 0.12  0.13 0.14  0.15  ]

  foreach List-NbIt [
    i ->
    foreach List-Nbagent-Spiders [
      j ->
      foreach List-Thres [
        k ->
        set NbIt i
        set Nbagent-Spiders j
        set Thres k

        ;; Appeler les fonctions
        clear-all
        import-pcolors "IRM1.png"
        preprocessing
        setupSpiders-auto
        gospiders

        ;; Exporter les images résultantes
        let p word "Spider" NbIt
        set p word p  "_"
        set p word p Nbagent-Spiders
        set p word p "_"
        set p word p Thres
        let picture-name word p ".png"
        export-interface picture-name
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
565
10
1055
501
-1
-1
2.0
1
10
1
1
1
0
1
1
1
-120
120
-120
120
0
0
1
ticks
30.0

BUTTON
205
55
312
88
preprocessing
preprocessing
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
100
10
238
55
filename
filename
"IRM1.png"
0

SLIDER
330
285
502
318
Nbagent-Spiders
Nbagent-Spiders
0
15
0.0
1
1
NIL
HORIZONTAL

BUTTON
0
305
132
338
setupSpiders-auto
setupSpiders-auto
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
170
305
252
338
goSpiders
goSpiders
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
330
330
502
363
NbIt
NbIt
0
50000
0.0
1
1
NIL
HORIZONTAL

SLIDER
330
375
502
408
Thres
Thres
0
3
0.14
0.01
1
NIL
HORIZONTAL

BUTTON
100
55
197
88
importimage
import-pcolors filename
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
0
55
92
88
initialisation
clear-all\nset Nbagent-Ants 20\nset PerV 100\nset Grad 1.6\n\nset Nbagent-Spiders 14\nset Thres 0.14\nset NbIt 40000\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
0
270
147
303
setupSpiders-manual
setupSpiders-manual\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
5
160
92
193
setupAnts
setupAnts
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
335
125
507
158
PerV
PerV
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
335
165
507
198
Grad
Grad
0
5
1.6
0.3
1
NIL
HORIZONTAL

BUTTON
100
160
167
193
goAnts
goAnts
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
335
210
507
243
Nbagent-Ants
Nbagent-Ants
0
50
20.0
1
1
NIL
HORIZONTAL

BUTTON
135
350
297
383
optimize-params-spiders
optimize-params-spiders
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
180
160
327
193
NIL
optimize-params-ants
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

Il s'agit d'un modèle de sélection artificiel qui montre le résultat de deux algorithmes de segmentation d’image provenant de la biologie les fourmis et les araignées sociales .

## HOW TO IT WORKS

Le premier algorithme concerne l’algorithme des fourmis qui a pour but de détecter les countours dans l’image dans lequel nous avons choisi d'utiliser le biais de phéromones (en marquant les pixels) pour effectuer la tâche de segmentation d'image. Cette segmentation utilise un certain nombre de fourmis qui sont injectées au hasard dans l'environnement. 

Le deuxième algorithme est celui des araignées qui a pour but de  détecter les régions dans l’image, dans lequel nous avons introduit la notion d’intensité , les araignées ont notamment la capacité de se déplacer dans l’environnement , de reculer et également de tisser une toile sur l'image en fixant des soies entre les pixels.

## HOW TO USE IT

D’abord cliquez sur le bouton Initialisation afin de réinitialiser l’environnement , puis sur le bouton importimage pour importer l’image à segmenter, ensuite cliquez sur le bouton preprocessing dans le but de procéder au nettoyage de l’image. Une fois tous ça est fait, avant de cliquer sur n’importe quel bouton, vous choisissez d’abord une des méthodes soit la méthode des fourmis ou celle des araignées:

Si votre choix porte sur la technique des Fourmis, vous procédez comme suit:
    -vous cliquez sur le bouton setupAnts pour configurer les fourmis 
    -ensuite , sur le bouton goAnts pour accomplir la tâche de segmentation à base des fourmis ,et le phéromone déposé est présenté sous forme d’une couleur blanche qui à permet de contourner l'image.
Le curseur NbAgent-Ants définit le nombre de fourmis qui travaille sur la segmentation
Le curseur PerV Contrôle le pourcentage de pixels visités
Le curseur Grad permet de définir un seuil du gradient morphologique à dépasser afin de marquer le pixel.
Le bouton Optimize-params-Ants permet d'optimiser les paramétres utilisés dans cet algorithme 

Si vous souhaitez modifier le nombre de fourmis,le seuil du gradient et le pourcentage de pixel à visiter, vous déplacez respectivement le curseur Nbagent-Ants, Grad et PerV avant d'appuyer sur setupAnts.

Si votre choix porte sur la technique des Araignées, vous procédez comme suit:
   Dans ce cas vous avez deux choix soit vous déposez les araignées de manière automatique soit de façon manuelle.
    -Si vous choisissez de les déposer automatiquement, donc vous cliquez sur le bouton setupSpiders pour la configuration des araignées ensuite sur le bouton goSpiders pour réaliser la tache de segmentation à base des araignées.
    -Si vous choisissez de les deposer manuellement vous sélectionnez le bouton Manual pour avoir la possibilité de déposer, une fois les araignées sont déposées vous cliquez sur le bouton goSpiders.
Le curseur NbAgent-Spiders définit le nombre d’araignées qui travaille sur la segmentation
Le curseur NbIt définit le nombre d’itérations que prend une segmentation d'image. 
Le curseur Thres permet de définir un seuil d’intensité à ne pas dépasser afin de fixer les soies entre pixels.
Si vous souhaitez modifier le nombre d’araignées, le nombres d’itérations et le seuil d’intensité , vous déplacez respectivement  le curseur Nbagent-Spiders, NbIt et Thres avant d'appuyer sur setupSpiders.
Le bouton Optimize-params-spiders permet d'optimiser les paramétres utilisés dans cet algorithme 

## THINGS TO NOTICE
Les fourmis changent l'état d'un pixel de libre à visité dés qu'elle s'introduient dans un pixel donné ,et marquent les pixels qui dépassent le seuil du gradient morphologique fixé.
Les araignées donnent la priorité aux pixels voisins non déja soyeux ou les moins soyeux pour fixer une soie.


## EXTENDING THE MODEL
Dans le cas de l'algorithme des araignées, en déposant automatiquement on peut avoir des résulats ou des régions ne sont pas définit pour la raison qu'aucun agent ne s'est déposé dessus.


## CREDITS AND REFERENCES

-SEGMENTATION MULTI-AGENTS EN IMAGERIE BIOLOGIQUE ET MÉDICALE : APPLICATION AUXIRM 3D https://tel.archives-ouvertes.fr/tel-00652445/document
-On the use of social agents for image segmentationhttps://hal.archives-ouvertes.fr/hal-00414490/document
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bird
true
0
Polygon -7500403 true true 151 170 136 170 123 229 143 244 156 244 179 229 166 170
Polygon -16777216 true false 152 154 137 154 125 213 140 229 159 229 179 214 167 154
Polygon -7500403 true true 151 140 136 140 126 202 139 214 159 214 176 200 166 140
Polygon -16777216 true false 151 125 134 124 128 188 140 198 161 197 174 188 166 125
Polygon -7500403 true true 152 86 227 72 286 97 272 101 294 117 276 118 287 131 270 131 278 141 264 138 267 145 228 150 153 147
Polygon -7500403 true true 160 74 159 61 149 54 130 53 139 62 133 81 127 113 129 149 134 177 150 206 168 179 172 147 169 111
Circle -16777216 true false 144 55 7
Polygon -16777216 true false 129 53 135 58 139 54
Polygon -7500403 true true 148 86 73 72 14 97 28 101 6 117 24 118 13 131 30 131 22 141 36 138 33 145 72 150 147 147

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

spider
true
0
Polygon -7500403 true true 134 255 104 240 96 210 98 196 114 171 134 150 119 135 119 120 134 105 164 105 179 120 179 135 164 150 185 173 199 195 203 210 194 240 164 255
Line -7500403 true 167 109 170 90
Line -7500403 true 170 91 156 88
Line -7500403 true 130 91 144 88
Line -7500403 true 133 109 130 90
Polygon -7500403 true true 167 117 207 102 216 71 227 27 227 72 212 117 167 132
Polygon -7500403 true true 164 210 158 194 195 195 225 210 195 285 240 210 210 180 164 180
Polygon -7500403 true true 136 210 142 194 105 195 75 210 105 285 60 210 90 180 136 180
Polygon -7500403 true true 133 117 93 102 84 71 73 27 73 72 88 117 133 132
Polygon -7500403 true true 163 140 214 129 234 114 255 74 242 126 216 143 164 152
Polygon -7500403 true true 161 183 203 167 239 180 268 239 249 171 202 153 163 162
Polygon -7500403 true true 137 140 86 129 66 114 45 74 58 126 84 143 136 152
Polygon -7500403 true true 139 183 97 167 61 180 32 239 51 171 98 153 137 162

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
setup
ask predators [ show-turtle ]
repeat 15 [ ask bugs [ move-bug ] ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-spiders</setup>
    <go>gospiders</go>
    <exitCondition>NbIt = 0</exitCondition>
    <enumeratedValueSet variable="filename">
      <value value="&quot;IRM1.png&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbIt">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nbagent">
      <value value="5"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Thres">
      <value value="0.19"/>
      <value value="0.2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Percentage-Visited">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="filename">
      <value value="&quot;IRM1.png&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grad">
      <value value="1.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nbagent">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbIt">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Thres">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nbagent-Ants">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setupAnts</setup>
    <go>goAnts</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Percentage-Visited">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="filename">
      <value value="&quot;IRM1.png&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Grad">
      <value value="1.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nbagent">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbIt">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Thres">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nbagent-Ants">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
