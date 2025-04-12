;;;; SISTEMA BASADO EN EL CONOCIMIENTO PARA CLASIFICAR ALIMENTOS

;;; A partir de los grupos definidos en la pirámide alimentaria y de la relación es_un_tipo_de se clasifican los alimentos jerarquicamente por grupos.
;;;;;;;; (es_un_tipo_de ?x ?y) representará que ?x es un tipo de ?y
;;; Se deduce el concepto es_grupo_alimentos para cada uno de los grupos de la jerarquía, se representa (es_grupo_alimentos ?x)
;;; Se deduce el concepto de alimento para los grupos de alimentos que no contengan subgrupos, se representa (alimento ?x)
;;; Se crean conceptos agrupando los que compartan ser un tipo de la misma clase y la primera palabra del nombre, siempre que esa palabra no sea el nombre de la superclase común
;;;;;;;;;asi de aceitunas_verdes y aceitunas_rojas se deduce que existe el grupo aceitunas.
;;; Se descubren relaciones es_un_tipo_de por ser especificaciones del nombre de un grupo, así salmon_ahumado será deducido como un tipo de salmon
;;; Se introducen conceptos que no son alimentos básicos pero si ingredientes habituales en recetas (salsas, bebudas, agua, ...)
;;; Se introduce el concepto de ser un condimento, para recoger alimentos o ingredientes que nunca son ingrediente principal de una receta

; Apuntes clase: 
; deffunction: para definir funciones
; queremos hacer reglas lo mas simple posible
; podemos utilizar condicionales y bucles pero no queremos abusar para no complicar la lectura de las reglas
; la programacion (if, while...) siempre despues del =>, NUNCA antes
; eq comprueba si son iguales dos cadenas de caracteres
; bind le asigna rv ""
; str-index te devuelve la posicion donde se encuentra la segunda cadena dentro de la cadera tercera (str). Devuelve la primera vez que aparece
; str-cat concatena cadenas
; en clips no "existen" los tipos, es decir, todos son simbolos. No se diferencia entre numeros, strings...
; CONSEJO: buscar reglas MUY SIMPLES

; 1) Si un alimento aparece en el nombre, seguramente sea un ingrediente principal
; 2) Los condimentos no son ingredientes principales
; 3) Si un ingrediente es carne o pescado y no hay ingredientes principales seguramente sea un ingrediente principal


;;; FUNCIONES UTILES
; rpl: reemplazo y fnd: found
(deffunction str-replace (?str ?rpl ?fnd)
   (if (eq ?fnd "") then (return ?str))
   (bind ?rv "") ;rv suele ser lo que devuelve una funcion
   (bind ?i (str-index ?fnd ?str))
   (while ?i
      (bind ?rv (str-cat ?rv (sub-string 1 (- ?i 1) ?str) ?rpl))
      (bind ?str (sub-string (+ ?i (str-length ?fnd)) (str-length ?str) ?str))
      (bind ?i (str-index ?fnd ?str)))
   (bind ?rv (str-cat ?rv ?str)))
; Ejemplo de uso: Juan 1 n -> Jua1
; Juann 1 n -> Jua11
   
; LA FUNCION ESTA MAL: LA HE MODIFICADO   
(deffunction   pregunta  (?pregunta  $?valores-permitidos) ; el $ significa que es una lista
(format t "¿%s? (%s) " ?pregunta (implode$ ?valores-permitidos)) (bind ?respuesta (read)) ; implode$ lista como cada de caracteres lo que hay en una lista
(while (not (member$ ?respuesta ?valores-permitidos)) do
         (format t "¿%s? (%s) " ?pregunta (implode$ ?valores-permitidos))
         (bind ?respuesta (read))
       )
?respuesta
)
; Ejemplo de uso: (pregunta "como te llamas" Juan luis Antonio) -> devuelve la respuesta a la pregunta siempre que coincida con un elemento de la lista
   
;;;; Concocimiento general

(deffacts piramide_alimentaria
(nivel_piramide_alimentaria verdura 1)
(nivel_piramide_alimentaria hortalizas 1)
(nivel_piramide_alimentaria fruta 2)
(nivel_piramide_alimentaria cereales_integrales 3)
(nivel_piramide_alimentaria lacteos 4)
(nivel_piramide_alimentaria aceite_de_oliva 5)
(nivel_piramide_alimentaria frutos 5)
(nivel_piramide_alimentaria frutos_secos 6)
(nivel_piramide_alimentaria especies 6)
(nivel_piramide_alimentaria hierbas_aromaticas 6)
(nivel_piramide_alimentaria legumbres 7)
(nivel_piramide_alimentaria carne_blanca 8)
(nivel_piramide_alimentaria pescado 8)
(nivel_piramide_alimentaria huevos 8)
(nivel_piramide_alimentaria carne_roja 9)
(nivel_piramide_alimentaria embutidos 9)
(nivel_piramide_alimentaria fiambres 9)
(nivel_piramide_alimentaria dulces 9)
)   

(deffacts es_un_tipo_de_alimentos
(es_un_tipo_de carne_roja carne)
(es_un_tipo_de ternera carne_roja)
(es_un_tipo_de cerdo carne_roja)
(es_un_tipo_de cordero carne_roja)
(es_un_tipo_de carne_blanca carne)
(es_un_tipo_de pollo carne_blanca)
(es_un_tipo_de conejo carne_blanca)
(es_un_tipo_de leche lacteos)
(es_un_tipo_de queso lacteos)
(es_un_tipo_de yogur lacteos)
(es_un_tipo_de atun pescado) 
(es_un_tipo_de salmon pescado)    
(es_un_tipo_de boquerones pescado)
(es_un_tipo_de sardinas pescado)
(es_un_tipo_de salchichon embutidos)
(es_un_tipo_de chorizo embutidos)
(es_un_tipo_de judias_blancas legumbres)
(es_un_tipo_de garbanzos legumbres)
(es_un_tipo_de guisantes legumbres)
(es_un_tipo_de nueces frutos_secos)
(es_un_tipo_de almendra frutos_secos)
(es_un_tipo_de perejil hierbas_aromaticas)
(es_un_tipo_de pimienta especies)
(es_un_tipo_de pimenton especies)
(es_un_tipo_de cereales_integrales cereales)
(es_un_tipo_de trigo cereales)
(es_un_tipo_de harina cereales)
(es_un_tipo_de maiz cereales)
(es_un_tipo_de sandia fruta)
(es_un_tipo_de pinia fruta)
(es_un_tipo_de platano fruta)
(es_un_tipo_de pera fruta)
(es_un_tipo_de manzana fruta)
(es_un_tipo_de naranja fruta)
(es_un_tipo_de lechuga verdura)
(es_un_tipo_de coliflor verdura)
(es_un_tipo_de brocoli verdura)
(es_un_tipo_de ajo verdura)
(es_un_tipo_de pimiento verdura)
(es_un_tipo_de zanahoria verdura)
(es_un_tipo_de cebolla verdura)
(es_un_tipo_de tomate verdura)
(es_un_tipo_de pimiento_rojo pimiento)
(es_un_tipo_de pimiento_verde pimiento)
(es_un_tipo_de pastel dulces)
(es_un_tipo_de caramelos dulces)
(es_un_tipo_de azucar dulces)
(es_un_tipo_de aceite_de_oliva aceite)
(es_un_tipo_de mortadela fiambres)
(es_un_tipo_de jamon_de_york fiambres)
(es_un_tipo_de aceitunas_verdes frutos)
(es_un_tipo_de aceitunas_rojas frutos)
)

; condimento no van a ser alimentos pero pueden aparecer en las recetas
(deffacts es_un_tipo_de_condimento
(es_un_tipo_de especies condimento)
(es_un_tipo_de caldo condimento)
(es_un_tipo_de vino condimento)
(es_un_tipo_de aceite condimento)
(es_un_tipo_de ajo condimento)
(es_un_tipo_de salsa condimento)
(es_un_tipo_de bebida condimento)
)

(deffacts bebidas
(es_un_tipo_de cognac bebida)
(es_un_tipo_de vino bebida)
(es_un_tipo_de cerveza bebida)
(es_un_tipo_de agua bebida)
)

(deffacts especias
(es_un_tipo_de sal especies)
(es_un_tipo_de azafran especies)
(es_un_tipo_de laurel especies)
(es_un_tipo_de curry especies)
(es_un_tipo_de curcuma especies)
)


(defrule componiendo_es_un_tipo_de
(es_un_tipo_de ?x ?y)
(es_un_tipo_de ?y ?z)
=>
(assert (es_un_tipo_de ?x ?z))
)

(defrule deducir_grupo_por_piramide
(nivel_piramide_alimentaria ?g ?) ; hay una ? sola porque sabemos que por sintaxis es asi pero no la vamos a utilizar ni almacenar en esta regla
=>
(assert (es_grupo_alimentos ?g))
)

(defrule superclase_grupos_son_grupos
(es_grupo_alimentos ?g)
(es_un_tipo_de ?g ?x)
(test (neq ?x condimento)) ; no igual 
=>
(assert (es_grupo_alimentos ?x))
)

(defrule es_alimento
(es_un_tipo_de ?a ?g)
(es_grupo_alimentos ?g)
=>
(assert (es_alimento ?a))
)

(defrule deducir_es_un_tipo_de
(es_grupo_alimentos ?g)
(or (alimento ?a) (es_grupo_alimentos ?a))
(test (neq ?a ?g))
=>
(bind ?espacio_a (str-index "_" ?a))
(if ?espacio_a  then 
(bind ?primera_palabra_a (sub-string 1 (- ?espacio_a 1) ?a))
(if (eq ?primera_palabra_a ?g) then (assert (es_un_tipo_de ?a ?g)))
)
)
; g=aceitunas, a=aceitunas verdes => coge la primera palabra y lo demas lo corta, entonces aceitunas=aceitunas


; con esta regla no se permiten grupos y alimentos a la vez
(defrule de_alimento_a_grupo
?f <- (es_alimento ?a)
(es_un_tipo_de ?x ?a)
=>
(assert (es_grupo_alimentos ?a))
(retract ?f)
)

(defrule retractar_grupo_como_alimento
(declare (salience -2))
?f <- (es_alimento ?g)
(es_grupo_alimentos ?g)
=>
(retract ?f)
)

(defrule retractar_grupos_sin_subgrupos
(declare (salience -1)) ; para que me asegure que ya no hay mas por deducir y por tanto realmente no tiene subgrupo
?f <- (es_grupo_alimentos ?g)
(not (es_un_tipo_de ? ?g)) ; ? tiene que haber algo pero no me importa y no lo guardo
=>
(retract ?f)
)

;casi siempre cuando hay un not tiene que estar ligado a un salience negativo

(defrule agrupando_por_nombre
(es_un_tipo_de ?a1 ?g)
(es_un_tipo_de ?a2 ?g)
(test (neq ?a1 ?a2))
(not (es_un_tipo_de ?a1 ?a2))
(not (es_un_tipo_de ?a2 ?a1))
=>
(bind ?espacio_a1 (str-index "_" ?a1))
(if ?espacio_a1 then 
   (bind ?primera_palabra_a1 (sym-cat (sub-string 1 (- ?espacio_a1 1) ?a1))) 
   (bind ?espacio_a2 (str-index "_" ?a2))
   (if ?espacio_a2 then 
      (bind ?primera_palabra_a2 (sym-cat (sub-string 1 (- ?espacio_a2 1) ?a2)))
	  ;(printout t "Intentando agrupar " ?a1 " " ?a2 crlf) ; esto para ver como funciona, para debuggear
      ;(printout t "Primeras palabras respectivas " ?primera_palabra_a1 " " ?primera_palabra_a2 crlf)
      (if (eq (upcase ?primera_palabra_a1) (upcase ?primera_palabra_a2)) then 
         ;(printout t "Creando grupo " ?primera_palabra_a1 " con " ?a1 " y " ?a2 crlf) 
         (if (neq ?a1 ?primera_palabra_a1) then (assert (es_un_tipo_de ?a1 ?primera_palabra_a1)) (assert (es_un_tipo_de ?primera_palabra_a1 ?g))) 
         (if (neq ?a2 ?primera_palabra_a1) then (assert (es_un_tipo_de ?a2 ?primera_palabra_a1)) (assert (es_un_tipo_de ?primera_palabra_a1 ?g))) 
       )
	)   
)
)
; esto es para comprobar que funciona correctamente: (no se usan pero es para asegurarme que funciona)
;(defrule anunciar_listar_grupos_alimentos
;(declare (salience -997))
;=>
;(printout t crlf "Gurpos de alimentos de la base de conocimiento:" crlf)
;)

;(defrule listar_grupos_alimentos
;(declare (salience -998))
;(es_grupo_alimentos ?g)
;=>
;(printout t ?g crlf)
;)

;(defrule anunciar_listar_alimentos
;(declare (salience -999))
;=>
;(printout t crlf "Alimentos de la base de conocimiento:" crlf)
;)

;(defrule listar_alimentos
;(declare (salience -1000))
;(es_alimento ?a)
;=>
;(printout t ?a crlf)
;)

;(defrule anunciar_listar_condimentos
;(declare (salience -1001))
;=>
;(printout t crlf "Condimentos de la base de conocimiento:" crlf)
;)

;(defrule listar_condimentostos
;(declare (salience -1002))
;(es_un_tipo_de ?a condimento)
;=>
;(printout t ?a crlf)
;)
