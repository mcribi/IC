;(defmodule DEDUCIR
;  (export ?ALL))

(deftemplate receta
(slot nombre)   ; necesario
(slot introducido_por) ; necesario
(slot numero_personas)  ; necesario
(multislot ingredientes)   ; necesario
(slot dificultad (allowed-symbols alta media baja muy_baja))  ; necesario
(slot duracion)  ; necesario
(slot enlace)  ; necesario
(multislot tipo_plato (allowed-symbols entrante primer_plato plato_principal postre desayuno_merienda acompanamiento)) ; necesario, introducido o deducido en este ejercicio
(slot coste)  ; opcional relevante
(slot tipo_copcion (allowed-symbols crudo cocido a_la_plancha frito al_horno al_vapor))   ; opcional
(multislot tipo_cocina)   ;opcional
(slot temporada)  ; opcional
;;;; Estos slot se calculan, se haria mediante un algoritmo que no vamos a implementar para este prototipo, lo usamos con la herramienta indicada y lo introducimos
(slot Calorias) ; calculado necesario
(slot Proteinas) ; calculado necesario
(slot Grasa) ; calculado necesario
(slot Carbohidratos) ; calculado necesario
(slot Fibra) ; calculado necesario
(slot Colesterol) ; calculado necesario
)

(deftemplate propiedad_receta
   (slot tipo)         ;tipo de propiedad especial que tenga la receta
   (slot receta)       ;nombre de la receta
   (slot ingrediente)  ;ingredientes principales
)

(deftemplate receta-seleccionada
   (slot nombre)
)


(defrule iniciar-deduccion
  (declare (salience 1001))
   =>
   (assert (modulo deducir-propiedades))
)

(defrule carga_recetas
(declare (salience 1000))
(modulo deducir-propiedades)
=>
(load-facts "recetas.txt")
)


;;;;;;;;;;Cargo conocimiento anterior y mismo
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
(es_un_tipo_de salmon_ahumado pescado) 
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


;;;;;;;;;;;MI CONOCIMIENTO: 
;; aniado conocimiento para que pueda funcionar mejor
(deffacts conocimiento_ampliado_ingredientes

  ;carnes
  (es_un_tipo_de pollo carne)
  (es_un_tipo_de pavo carne)
  (es_un_tipo_de conejo carne)
  (es_un_tipo_de cerdo carne)
  (es_un_tipo_de ternera carne)
  (es_un_tipo_de cordero carne)
  (es_un_tipo_de carne_picada carne)
  (es_un_tipo_de jamon carne)
  (es_un_tipo_de bacon carne)
  (es_un_tipo_de salchicha carne)
  (es_un_tipo_de pato carne)
  (es_un_tipo_de pollo carne)
  (es_un_tipo_de pavo carne)
  (es_un_tipo_de conejo carne)
  (es_un_tipo_de cerdo carne)
  (es_un_tipo_de ternera carne)
  (es_un_tipo_de cordero carne)
  (es_un_tipo_de carne_picada carne)
  (es_un_tipo_de jamon carne)
  (es_un_tipo_de bacon carne)
  (es_un_tipo_de salchicha carne)
  (es_un_tipo_de chistorra carne)
  (es_un_tipo_de bistec carne)
  (es_un_tipo_de morcilla carne)
  (es_un_tipo_de chorizo carne)
  (es_un_tipo_de panceta carne)
  (es_un_tipo_de bondiola carne)
  (es_un_tipo_de lomo carne)
  (es_un_tipo_de matambre carne)
  (es_un_tipo_de jamon_serrano carne)

  ;pescado y marisco
  (es_un_tipo_de salmon pescado)
  (es_un_tipo_de atun pescado)
  (es_un_tipo_de merluza pescado)
  (es_un_tipo_de bacalao pescado)
  (es_un_tipo_de boquerones pescado)
  (es_un_tipo_de sardinas pescado)
  (es_un_tipo_de langostinos marisco)
  (es_un_tipo_de langostino marisco)
  (es_un_tipo_de gambas marisco)
  (es_un_tipo_de mejillones marisco)
  (es_un_tipo_de almejas marisco)
  (es_un_tipo_de calamares marisco)
  (es_un_tipo_de pulpo marisco)
  (es_un_tipo_de marisco pescado)
  (es_un_tipo_de camarones pescado)

  ;lácteos
  (es_un_tipo_de leche lacteos)
  (es_un_tipo_de nata lacteos)
  (es_un_tipo_de queso lacteos)
  (es_un_tipo_de mantequilla lacteos)
  (es_un_tipo_de yogur lacteos)

  ;frutas
  (es_un_tipo_de platano fruta)
  (es_un_tipo_de manzana fruta)
  (es_un_tipo_de pera fruta)
  (es_un_tipo_de fresa fruta)
  (es_un_tipo_de kiwi fruta)
  (es_un_tipo_de melon fruta)
  (es_un_tipo_de sandia fruta)
  (es_un_tipo_de limon fruta)
  (es_un_tipo_de naranja fruta)
  (es_un_tipo_de uvas fruta)
  (es_un_tipo_de frutos_rojos fruta)
  (es_un_tipo_de arandanos fruta)
  (es_un_tipo_de mango fruta)

  ;verduras y hortalizas
  (es_un_tipo_de zanahoria verdura)
  (es_un_tipo_de cebolla verdura)
  (es_un_tipo_de ajo verdura)
  (es_un_tipo_de tomate verdura)
  (es_un_tipo_de calabacin verdura)
  (es_un_tipo_de berenjena verdura)
  (es_un_tipo_de lechuga verdura)
  (es_un_tipo_de espinacas verdura)
  (es_un_tipo_de acelgas verdura)
  (es_un_tipo_de brocoli verdura)
  (es_un_tipo_de coliflor verdura)
  (es_un_tipo_de pimiento_rojo pimiento)
  (es_un_tipo_de pimiento_verde pimiento)
  (es_un_tipo_de pimiento pimiento)
  (es_un_tipo_de pimiento verdura)

  ;cereales y harinas
  (es_un_tipo_de pan cereales)
  (es_un_tipo_de harina cereales)
  (es_un_tipo_de arroz cereales)
  (es_un_tipo_de pasta cereales)
  (es_un_tipo_de maiz cereales)
  (es_un_tipo_de avena cereales)
  (es_un_tipo_de quinoa cereales)
  (es_un_tipo_de couscous cereales)

  ;legumbres
  (es_un_tipo_de lentejas legumbres)
  (es_un_tipo_de garbanzos legumbres)
  (es_un_tipo_de judias_blancas legumbres)
  (es_un_tipo_de judias_verdes verdura)
  (es_un_tipo_de soja legumbres)

  ;frutos secos
  (es_un_tipo_de almendra frutos_secos)
  (es_un_tipo_de nueces frutos_secos)
  (es_un_tipo_de pistachos frutos_secos)
  (es_un_tipo_de cacahuetes frutos_secos)

  ;otros condimentos y especias
  (es_un_tipo_de pimienta especies)
  (es_un_tipo_de sal especies)
  (es_un_tipo_de curcuma especies)
  (es_un_tipo_de curry especies)
  (es_un_tipo_de pimenton especies)
  (es_un_tipo_de comino especies)
  (es_un_tipo_de ajo condimento)
  (es_un_tipo_de perejil hierbas_aromaticas)
  (es_un_tipo_de albahaca hierbas_aromaticas)
  (es_un_tipo_de laurel especies)
  (es_un_tipo_de azafran especies)
  (es_un_tipo_de salsa condimento)
  (es_un_tipo_de mayonesa condimento)
  (es_un_tipo_de ketchup condimento)

  ;dulces
  (es_un_tipo_de azucar dulces)
  (es_un_tipo_de miel dulces)
  (es_un_tipo_de chocolate dulces)
  (es_un_tipo_de mermelada dulces)
  (es_un_tipo_de sirope dulces)

  ;bebidas
  (es_un_tipo_de agua bebida)
  (es_un_tipo_de vino bebida)
  (es_un_tipo_de cerveza bebida)
  (es_un_tipo_de leche vegetal bebida)
  (es_un_tipo_de zumo bebida)

  ;definimos el grupo de gluten para poder clasificarlo despues para celiacos
  (es_un_tipo_de harina gluten)
  (es_un_tipo_de trigo gluten)
  (es_un_tipo_de pan gluten)
  (es_un_tipo_de pan_rallado gluten)
  (es_un_tipo_de espaguetis gluten)
  (es_un_tipo_de macarrones gluten)

)

;;agrupados por grupos directamente


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

;hacemos el not de la anterior y añadimos que en el nombre de la receta no ponga carne/pescado
(defrule receta-vegana
   (declare (salience -5))
   (modulo deducir-propiedades)
   (receta (nombre ?n))
   (not (propiedad_receta (tipo no_es_vegana) (receta ?n)))
   =>
   (assert (propiedad_receta (tipo es_vegana) (receta ?n)))
   ;(printout t ?n " es vegano " crlf)
)


;;una receta vegetariana es que no tiene pescado ni carne pero si puede tener lacteos o huevos
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

(defrule receta-vegetariana
   (declare (salience -7))
   (modulo deducir-propiedades)
   (receta (nombre ?n))
   (not (propiedad_receta (tipo no_es_vegetariana) (receta ?n)))
   =>
   (assert (propiedad_receta (tipo es_vegetariana) (receta ?n)))
   ;(printout t ?n " es vegetariano " crlf)
)



;;sin gluten es que no tenga ni harina ni trigo
(defrule receta-gluten
   (declare (salience -10))
   (modulo deducir-propiedades)
   (receta (nombre ?n) (ingredientes $? ?i $?))
   (es_un_tipo_de ?i cereales)
   =>
   ;(printout t ?n " no es para celiacos " crlf)
   (assert (propiedad_receta (tipo es_con_gluten) (receta ?n)))
)

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

(defrule receta-no-lactosa
   (declare (salience -13))
   (modulo deducir-propiedades)
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_con_lactosa) (receta ?n)))
   =>
   ;(printout t ?n " es para intolerantes a la lactosa " crlf)
   (assert (propiedad_receta (tipo es_sin_lactosa) (receta ?n)))
)


;; si es picante en el nombre deberia de poner picante o en un ingrediente
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


;;;FORMATO DE LOS HECHOS: 
;  
;       (propiedad_receta ingrediente_relevante ?r ?a)
;       (propiedad_receta es_vegetariana ?r) 
;       (propiedad_receta es_vegana ?r)
;       (propiedad_receta es_sin_gluten ?r)
;       (propiedad_receta es_picante ?r)
;       (propiedad_receta es_sin_lactosa ?r)
;       (propiedad_receta es_de_dieta ?r)

;; fin de módulo
(defrule fin-deducir-propiedades
   (declare (salience -5000)) 
   ?f <- (modulo deducir-propiedades)
   =>
   (retract ?f)
   (assert (modulo obtener-compatibles))
)

