;;MODULO PARA DEDUCIR PROPIEDADES A PARTIR DEL CONOCIMIENTO
;importamos todo lo del main y definimos el modulo actual. Con el export all hace que lo definido en este modulo este disponible para los demas modulos
;asi puede ser usado tambien desde fuera
;;;;;;ES IGUAL QUE LA PRACTICA 2 (sin la interacion final del usuario->aqui se hace en el modulo correspondiente)
(defmodule deducir-propiedades (export ?ALL) (import MAIN ?ALL))

;regla para aniadir el modulo actual para que se puedan disparar las siguiente reglas de este modulo
(defrule iniciar-deduccion
  (declare (salience 1001))
   =>
   (assert (modulo deducir-propiedades))
)

;;Tenemos en un fichero de texto recetas.txt en el mismo directorio de recetas.clp y hemos copiado 
;;parte (lo he corregido yo que tenia algunos fallos y no cargaba bien) el contenido del archivo compartido
;;ademas, he aniadido yo dos recetas 
;cargamos las recetas (lo primero, de ahi el salience tan positivo)

(defrule carga_recetas
(declare (salience 1000))
(modulo deducir-propiedades)
=>
(load-facts "recetas.txt")
)

(defrule componiendo_es_un_tipo_de
(modulo deducir-propiedades)
(es_un_tipo_de ?x ?y)
(es_un_tipo_de ?y ?z)
=>
(assert (es_un_tipo_de ?x ?z))
)

(defrule deducir_grupo_por_piramide
(modulo deducir-propiedades)
(nivel_piramide_alimentaria ?g ?) ; hay una ? sola porque sabemos que por sintaxis es asi pero no la vamos a utilizar ni almacenar en esta regla
=>
(assert (es_grupo_alimentos ?g))
)

(defrule superclase_grupos_son_grupos
(modulo deducir-propiedades)
(es_grupo_alimentos ?g)
(es_un_tipo_de ?g ?x)
(test (neq ?x condimento)) ; no igual 
=>
(assert (es_grupo_alimentos ?x))
)

(defrule es_alimento
(modulo deducir-propiedades)
(es_un_tipo_de ?a ?g)
(es_grupo_alimentos ?g)
=>
(assert (es_alimento ?a))
)

(defrule deducir_es_un_tipo_de
(modulo deducir-propiedades)
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
(modulo deducir-propiedades)
?f <- (es_alimento ?a)
(es_un_tipo_de ?x ?a)
=>
(assert (es_grupo_alimentos ?a))
(retract ?f)
)

(defrule retractar_grupo_como_alimento
(declare (salience -2))
(modulo deducir-propiedades)
?f <- (es_alimento ?g)
(es_grupo_alimentos ?g)
=>
(retract ?f)
)

(defrule retractar_grupos_sin_subgrupos
(declare (salience -1)) ; para que me asegure que ya no hay mas por deducir y por tanto realmente no tiene subgrupo
(modulo deducir-propiedades)
?f <- (es_grupo_alimentos ?g)
(not (es_un_tipo_de ? ?g)) ; ? tiene que haber algo pero no me importa y no lo guardo
=>
(retract ?f)
)

;casi siempre cuando hay un not tiene que estar ligado a un salience negativo

(defrule agrupando_por_nombre
(modulo deducir-propiedades)
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


; Si un alimento aparece en el nombre, seguramente sea un ingrediente principal
(defrule ingrediente-en-nombre
  (modulo deducir-propiedades)
  (receta (nombre ?nombre) (ingredientes $? ?ing $?))
  (test (str-index (lowcase (str-cat ?ing)) (lowcase ?nombre))) ; el ingrediente está en el nombre (case insensitive)
  =>
  ;(printout t "El ingrediente principal de " ?nombre " es " ?ing crlf)
  (assert (propiedad_receta (tipo ingrediente_principal) (receta ?nombre) (ingrediente ?ing)))
)

;que este en el nombre parcialmente
;una palabra del nombre de la receta esta en una parte del igrediente. Por ejemplo, si la receta es tortilla de patatas quiero que el ingrediente patatas_fritas se considere principal
;para evitar duplicados con la regla anterior vamos a comprobar que no este ya de antes
(defrule coincidencia-parcial-nombre
  (modulo deducir-propiedades)
  (receta (nombre ?nombre) (ingredientes $? ?ing $?))
  (not (propiedad_receta (receta ?nombre) (ingrediente ?ing))) ; evitamos duplicados
  (test (str-index (lowcase (sub-string 1 15 ?ing)) (lowcase ?nombre))) ; comprobamos coincidencia parcial
  (not (es_un_tipo_de ?ing condimento)) ; evitamos condimentos como ingredientes principales
  =>
  ;(printout t "Ingrediente principal de " ?nombre " es " ?ing " por nombre parcial encontrado" crlf)
  (assert (propiedad_receta (tipo ingrediente_principal) (receta ?nombre) (ingrediente ?ing))) 
)

;si hay 3 ingredientes o menos son todos principales
;es posible que se cuele algun condimento o algo no esencial, pero despues se retractara
(defrule pocos-ingredientes-principales
  (modulo deducir-propiedades)
  (receta (nombre ?nombre) (ingredientes $?lista))
  (test (<= (length$ ?lista) 3))
  =>
  (foreach ?ing ?lista
    ;(printout t "El ingrediente " ?ing " en la receta " ?nombre " es ingrediente principal por tener menos de 3 ingredientes." crlf)
    (assert (propiedad_receta (tipo ingrediente_principal) (receta ?nombre) (ingrediente ?ing)))
  )
)


; 2) Los condimentos no son ingredientes principales
;vamos a ver de cada receta los ingredientes y si hay condimentos los quitamos
;no considero que sal, perejil o pimienta sean ingredientes principales, porque eso suele estar en casi todas las recetas
(defrule evitar-condimentos-como-principales
  (modulo deducir-propiedades)
  ?f <- (propiedad_receta (receta ?nombre) (ingrediente ?ing)) ; comprobamos que es un ingrediente
  (es_un_tipo_de ?ing condimento) ; si es un condimento, lo eliminamos
  =>
  ;(printout t "El ingrediente " ?ing " en la receta " ?nombre " es un condimento, no se considera ingrediente principal." crlf)
  (retract ?f) ; eliminamos el hecho
)

; 3) Si un ingrediente es carne o pescado y no hay ingredientes principales seguramente sea un ingrediente principal
;;para carne:
(defrule carne-es-principal-si-no-hay-otros
  (modulo deducir-propiedades)
  (receta (nombre ?nombre) (ingredientes $?ings))
  (not (propiedad_receta (receta ?nombre) (ingrediente ?ing))) ; no debe haber ingredientes principales aún
  ?f <- (es_un_tipo_de ?ing carne) ; si encontramos carne
  (test (member$ ?ing ?ings)) ; y está en los ingredientes
  =>
  ;(printout t "El ingrediente " ?ing " en la receta " ?nombre " es carne y no hay otros ingredientes principales." crlf)
  (assert (propiedad_receta (tipo ingrediente_principal) (receta ?nombre) (ingrediente ?ing))) ; aniadimos carne como ingrediente principal
)

;; para pescado: 
(defrule pescado-es-principal-si-no-hay-otros
  (modulo deducir-propiedades)
  (receta (nombre ?nombre) (ingredientes $?ings))
  (not (propiedad_receta (receta ?nombre) (ingrediente ?ing))) ; no debe haber ingredientes principales aún
  ?f <- (es_un_tipo_de ?ing pescado) ; si encontramos pescado
  (test (member$ ?ing ?ings)) ; y está en los ingredientes
  =>
  ;(printout t "El ingrediente " ?ing " en la receta " ?nombre " es pescado y no hay otros ingredientes principales." crlf)
  (assert (propiedad_receta (tipo ingrediente_principal) (receta ?nombre) (ingrediente ?ing))) ; añadimos pescado como ingrediente principal
)

;;;PARTE 2
;;;modificar las recetas completando cual seria el/los tipo_plato asociados a una receta, 
;;;;;;;; especialmente para el caso de que no incluya ninguno
;usamos modify para modificar el template de la receta y asi completar los tipos de platos
;de hecho, algunos ya tienen su tipo de plato pero se le añadirá alguno mas si se ve conveniente
;por ejemplo, yo no veo mucha diferencia entre postre y desayuno_merienda, entonces, muchas recetas que sean
;del tipo postre, pueden aniadirse tambien al tipo desayuno_merienda

;he pensado en clasificar ingredientes caracteristicos
;si tiene carne o pescado es un plato principal
(defrule deducir-plato-principal
  (modulo deducir-propiedades)
  ?r <- (receta (nombre ?nombre) (tipo_plato $?tipo&:(not (member$ plato_principal ?tipo))) (ingredientes $?ings))
  (or 
    (test (member$ carne ?ings)) ; si tiene carne
    (test (member$ pescado ?ings)) ; o si tiene pescado
  )
  =>
  (modify ?r (tipo_plato (create$ ?tipo plato_principal)))
  (assert (propiedad_receta (tipo plato_principal) (receta ?nombre))) ; asignamos el tipo plato_principal
)



;;he pensado que todo lo que tenga pan a secas sea acompañamiento
;esto obviamente puede fallar ya que hay platos que tienen pan que no son acompaniamento
;pero no quiero caer en el sobreajuste y yo creo que es lo mas logico cuando piensa una persona en acompaniamento
(defrule deducir-acompanamiento
  (modulo deducir-propiedades)
  ?r <- (receta (nombre ?nombre) (tipo_plato $?tipo&:(not (member$ acompanamiento ?tipo))) (ingredientes $?ings))
  (test (member$ pan ?ings))
  =>
  (modify ?r (tipo_plato (create$ ?tipo acompanamiento)))
  ;(printout t "Asignado tipo_plato acompanamiento a receta " ?nombre " porque contiene pan." crlf)
  (assert (propiedad_receta (tipo acompaniamento) (receta ?nombre)))
)


;;para los entrantes creo que son los que solo tienen verdura y pocos ingredientes
(defrule deducir-entrante
  (modulo deducir-propiedades)
  ?r <- (receta (nombre ?nombre) (tipo_plato $?tipo&:(not (member$ entrante ?tipo))) (ingredientes $?ings))
  (test (<= (length$ ?ings) 4))
  (test (subsetp ?ings (create$ lechuga tomate zanahoria cebolla espinacas calabacin berenjena)))
  =>
  (modify ?r (tipo_plato (create$ ?tipo entrante)))
  ;(printout t "Asignado tipo_plato entrante a receta " ?nombre " porque contiene solo vegetales y pocos ingredientes." crlf)
  (assert (propiedad_receta (tipo entrante) (receta ?nombre)))
)

;;para el primer plato suele llevar algo de legumbres, arroz o pasta
(defrule deducir-primer-plato
  (modulo deducir-propiedades)
  ?r <- (receta (nombre ?nombre) (tipo_plato $?tipo&:(not (member$ primer_plato ?tipo))) (ingredientes $?ings))
  (test (or (member$ arroz ?ings) (member$ lentejas ?ings) (member$ pasta ?ings)))
  =>
  (modify ?r (tipo_plato (create$ ?tipo primer_plato)))
  ;(printout t "Asignado tipo_plato primer_plato a receta " ?nombre crlf)
  (assert (propiedad_receta (tipo primer_plato) (receta ?nombre)))
)

;;para la categoria de postre pongo que si tiene un ingrediente dulce
;al igual que antes, esto es bastante probable que clasifique una receta que se le echa azucar como postre
;porque hay recetas que tienen azucar y no son postres. Sin embargo, es lo mas logico y creo que lo mas general
;para los postres
(defrule deducir-postre-por-dulces
  (modulo deducir-propiedades)
  ?r <- (receta (nombre ?nombre) (ingredientes $?ings) (tipo_plato $?tipo&:(not (member$ postre ?tipo))))
  (es_un_tipo_de ?i dulces)
  (test (member$ ?i ?ings))
  =>
  (modify ?r (tipo_plato (create$ ?tipo postre)))
  ;(printout t "Asignado tipo_plato postre a receta " ?nombre " porque contiene el ingrediente dulce: " ?i crlf)
  (assert (propiedad_receta (tipo postre) (receta ?nombre)))
)

;;para la categoria de desayuno_merienda voy a incluir todas las recetas que tienen fruta
;; las unicas frutas que voy a obviar son el limon y la naranja que si se utilizan mas en la cocina tradicional
(defrule deducir-desayuno-merienda-por-fruta
  (modulo deducir-propiedades)
  ?r <- (receta (nombre ?nombre) (ingredientes $?ings) (tipo_plato $?tipo&:(not (member$ desayuno_merienda ?tipo))))
  (es_un_tipo_de ?i fruta)
  (test (member$ ?i ?ings))
  (test (neq ?i limon)) ; excluimos limon
  (test (neq ?i naranja)) ; excluimos naranja
  =>
  (modify ?r (tipo_plato (create$ ?tipo desayuno_merienda)))
  ;(printout t "Asignado tipo_plato desayuno_merienda a receta " ?nombre " porque contiene fruta: " ?i crlf)
  (assert (propiedad_receta (tipo desayuno_merienda) (receta ?nombre)))
)

;;; PARTE 3
;;; si una receta es: vegana, vegetariana, de dieta, picante, sin gluten o sin lactosa
;;una receta vegana no tiene lacteos, ni huevos, ni carne, ni pescado
;nos centramos en los alimentos que no pueden tener ciertas propiedades
;miramos si los tienen. Si los tienen se clasifica como que no cumple esa propiedad y despues se hace el not

;;una receta vegana no tiene lacteos, ni huevos, ni carne, ni pescado
(defrule receta-no-vegana
   (declare (salience -4)) 
   (modulo deducir-propiedades)
   (receta (nombre ?n) (ingredientes $? ?i $?))
   (or (es_un_tipo_de ?i carne)
      (es_un_tipo_de ?i pescado)
      (es_un_tipo_de ?i embutidos)
      (es_un_tipo_de ?i fiambres)
      (es_un_tipo_de ?i lacteos)
      (es_un_tipo_de ?i huevos))                
  =>
  (assert (propiedad_receta (tipo no_es_vegana) (receta ?n)))
  ;(printout t ?n " no es vegana " crlf)
)

;hacemos el not de la anterior para clasificar como vegana (no contiene esos alimentos)
(defrule receta-vegana
   (declare (salience -5))
   (modulo deducir-propiedades)
   (receta (nombre ?n))
   (not (propiedad_receta (tipo no_es_vegana) (receta ?n)))
   =>
   (assert (propiedad_receta (tipo es_vegana) (receta ?n)))
   ;(printout t ?n " es vegano " crlf)
)


;;una receta vegetariana es que no tiene pescado ni carne (embutidos, fiambres...) pero si puede tener lacteos o huevos
(defrule receta-no-vegetariana
   (declare (salience -6)) 
   (modulo deducir-propiedades)
   (receta (nombre ?n) (ingredientes $? ?i $?))
   (or (es_un_tipo_de ?i carne)
      (es_un_tipo_de ?i pescado)
      (es_un_tipo_de ?i embutidos)
      (es_un_tipo_de ?i fiambres))                           
  =>
  (assert (propiedad_receta (tipo no_es_vegetariana) (receta ?n)))
  ;(printout t ?n " no es vegetariano " crlf)
)

;hacemos el not de la anterior
(defrule receta-vegetariana
   (declare (salience -7))
   (modulo deducir-propiedades)
   (receta (nombre ?n))
   (not (propiedad_receta (tipo no_es_vegetariana) (receta ?n)))
   =>
   (assert (propiedad_receta (tipo es_vegetariana) (receta ?n)))
   ;(printout t ?n " es vegetariano " crlf)
)



;;sin gluten es que no tenga ni harina ni trigo ni sus derivados
(defrule receta-gluten
   (declare (salience -10))
   (modulo deducir-propiedades)
   (receta (nombre ?n) (ingredientes $? ?i $?))
   (es_un_tipo_de ?i cereales)
   =>
   ;(printout t ?n " no es para celiacos " crlf)
   (assert (propiedad_receta (tipo es_con_gluten) (receta ?n)))
)

;hacemos el not de la anterior
(defrule receta-no-gluten
   (declare (salience -11))
   (modulo deducir-propiedades)
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_con_gluten) (receta ?n)))
   =>
   ;(printout t ?n " es para celiacos " crlf)
   (assert (propiedad_receta (tipo es_sin_gluten) (receta ?n)))
)


;;sin lactosa es que no tenga nada de lacteos
(defrule receta-lactosa
   (declare (salience -12))
   (modulo deducir-propiedades)
   (receta (nombre ?n) (ingredientes $? ?i $?))
   (es_un_tipo_de ?i lacteos)
   =>
   ;(printout t ?n " no es intolerantes a la lactosa " crlf)
   (assert (propiedad_receta (tipo es_con_lactosa) (receta ?n)))
)

;hacemos el not de la anterior
(defrule receta-no-lactosa
   (declare (salience -13))
   (modulo deducir-propiedades)
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_con_lactosa) (receta ?n)))
   =>
   ;(printout t ?n " es para intolerantes a la lactosa " crlf)
   (assert (propiedad_receta (tipo es_sin_lactosa) (receta ?n)))
)


;; si es picante en el nombre deberia de poner picante en el titulo de la receta
(defrule receta-picante
  (declare (salience -14))
  (modulo deducir-propiedades)
  (receta (nombre ?n) (ingredientes $?ing))
  =>
  (foreach ?ingrediente ?ing
      (if (str-index "picante" ?ingrediente)
         then
         (assert (propiedad_receta (tipo es_picante) (receta ?n)))
         ;(printout t "La receta " ?n " es picante." crlf)
      )
   )
)


;;para ver si es de diesta voy a ver si tiene menos de 350 calorias
(defrule receta-de-dieta
  (declare (salience -15))
  (modulo deducir-propiedades)
  (receta (nombre ?n) (Calorias ?c&:(< ?c 350)))
  =>
  (assert (propiedad_receta (tipo es_de_dieta) (receta ?n)))
  ;(printout t "La receta " ?n " es de dieta (pocas calorias)." crlf)
)

;quitamos la interaccion con el usuario aqui porque la vamos a hacer en el modulo correspondiente dependiendo de si es salida o entrada de datos

;; fin de módulo 
;retractamos el modulo e insertamos el siguiente
(defrule fin-deducir-propiedades
   (declare (salience -5000)) 
   ?f <- (modulo deducir-propiedades)
   =>
   (retract ?f)
   (assert (modulo obtener-compatibles))
)

