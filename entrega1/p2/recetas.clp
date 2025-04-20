;Practica 2
;María Cribillés Pérez

;;;; AÑADIR LA INFORMACION DE AL MENOS 2 RECETAS NUEVAS al archivo compartido recetas.txt (https://docs.google.com/document/d/15zLHIeCEUplwsxUxQU66LsyKPY9n9p5v1bmi8M85YlU/edit?usp=sharing)
;;;;;recoger los datos de https://www.recetasgratis.net  en el siguiente formato
;plantilla que debe de seguir cada receta aniadida en el recetas.txt
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
;;;; Para los datos calculados se puede utilizar: https://www.labdeiters.com/nutricalculadora/ o https://fitia.app/buscar/alimentos-y-recetas/

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;FORMATO DE LOS HECHOS:
;(lo he cambiado un poco con respecto a lo que nos ha dado de referencia para que sea mas completo)
;y pueda almacenar mas informacion:
;
; Hechos que representan información sobre recetas:
;
;       (receta 
;           (nombre ?r)
;           (introducido_por ?alumno)
;           (numero_personas ?n)
;           (ingredientes ?i1 ?i2 ...)
;           (dificultad ?nivel)
;           (duracion ?duracion)
;           (enlace ?url)
;           (tipo_plato ?t1 ?t2 ...)
;           (coste ?coste)
;           (tipo_coccion ?tipo)
;           (tipo_cocina ?c1 ?c2 ...)
;           (temporada ?estacion)
;           (Calorias ?cal)
;           (Proteinas ?g)
;           (Grasa ?g)
;           (Carbohidratos ?g)
;           (Fibra ?g)
;           (Colesterol ?mg))
;
; Hechos que representan propiedades deducidas de la receta:
;
;       (propiedad_receta ingrediente_principal ?r ?a)
;       (propiedad_receta es_vegetariana ?r)
;       (propiedad_receta es_vegana ?r)
;       (propiedad_receta es_sin_gluten ?r)
;       (propiedad_receta es_picante ?r)
;       (propiedad_receta es_sin_lactosa ?r)
;       (propiedad_receta es_de_dieta ?r)
;       (propiedad_receta entrante ?r)
;       (propiedad_receta primer_plato ?r)
;       (propiedad_receta plato_principal ?r)
;       (propiedad_receta postre ?r)
;       (propiedad_receta acompanamiento ?r)
;       (propiedad_receta desayuno_merienda ?r)
;
; Hechos auxiliares utilizados en la interacción:
;
;       (receta-pedida ?r)                 ; nombre de la receta introducida por el usuario
;       (Tarea receta-no-encontrada)      ; tarea para comprobar existencia de receta
;
; Hechos de conocimiento nutricional:
;
;       (nivel_piramide_alimentaria ?alimento ?nivel)
;       (es_un_tipo_de ?alimento ?grupo)
;       (es_grupo_alimentos ?grupo)
;       (es_alimento ?alimento)
;       (propiedad ?propiedad ?alimento si) ; por ejemplo: (propiedad rico_en_fibras brocoli si)
;
; Hechos relacionados con el cálculo nutricional:
;
;       (cantidad_recomendada nivel ?n ?porcion ?frecuencia)
;       (compuesto_fundamentalmente_por ?alimento ?ingrediente_base)
;

;Parte 1:
; 1) Si un alimento aparece en el nombre, seguramente sea un ingrediente principal
; 2) Los condimentos no son ingredientes principales
; 3) Si un ingrediente es carne o pescado y no hay ingredientes principales seguramente sea un ingrediente principal

;Aqui vamos a definir las plantillas necesarias
(deftemplate propiedad_receta
   (slot tipo)         ;tipo de propiedad especial que tenga la receta
   (slot receta)       ;nombre de la receta
   (slot ingrediente)  ;ingredientes principales
)

(deftemplate receta-seleccionada
   (slot nombre)
)

;;Tenemos en un fichero de texto recetas.txt en el mismo directorio de recetas.clp y hemos copiado 
;;parte (lo he corregido yo que tenia algunos fallos y no cargaba bien) el contenido del archivo compartido
;;ademas, he aniadido yo dos recetas 
;cargamos las recetas (lo primero, de ahi el salience tan positivo)
(defrule carga_recetas
(declare (salience 1000))
=>
(load-facts "recetas.txt")
)

;guardamos las recetas modificadas y todos los hechos deducidos (se hace lo ultimo, de ahi el salience tan negativo)
(defrule guarda_recetas
(declare (salience -1000))
=>
(save-facts "recetas_saved.txt")
)

;;;;;;;;;;Cargo conocimiento anterior y mio
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


;;;;;;;;;;;MI CONOCIMIENTO: 
;; aniado conocimiento para que pueda funcionar mejor (mas tipos y alimentos sobretodo)
;;agrupados por grupos directamente
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

  ;lacteos
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

  ;verduras
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;EJERCICIO: Añadir reglas para  deducir tal y como tu lo harias (usando razonamiento basado en conocimiento):
;;;  1) cual o cuales son los ingredientes relevantes de una receta
;;;  2) modificar las recetas completando cual seria el/los tipo_plato asociados a una receta, 
;;;;;;;; especialmente para el caso de que no incluya ninguno
;;;  3) si una receta es: vegana, vegetariana, de dieta, picante, sin gluten o sin lactosa
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;PARTE 1-DEDUCIR INGREDIENTES PRINCIPALES DE UNA RECETA

;dada una receta y sus ingredientes vamos a sacar los ingredientes principales, es decir, los mas importantes
;voy a deducir como yo lo haria o como yo lo pensaria 
;no siempre va a ser perfecto, pero prefiero generalizar y que sean reglas simples a sobreajustar y que 
;se vuelvan reglas muy complejas o muchas reglas

; Mis ideas: 
; Si un alimento aparece en el nombre de la receta, seguramente sea un ingrediente principal
(defrule ingrediente-en-nombre
  (receta (nombre ?nombre) (ingredientes $? ?ing $?))
  (test (str-index (lowcase (str-cat ?ing)) (lowcase ?nombre))) ; el ingrediente está en el nombre (case insensitive)
  =>
  ;(printout t "El ingrediente principal de " ?nombre " es " ?ing crlf) ;estos prints los tenia para depurar
  (assert (propiedad_receta (tipo ingrediente_principal) (receta ?nombre) (ingrediente ?ing)))
)

;que este en el nombre parcialmente
;una palabra del nombre de la receta esta en una parte del igrediente. Por ejemplo, si la receta es tortilla de patatas quiero que el ingrediente patatas_fritas se considere principal
;para evitar duplicados con la regla anterior vamos a comprobar que no este ya de antes
(defrule coincidencia-parcial-nombre
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
  (receta (nombre ?nombre) (ingredientes $?lista))
  (test (<= (length$ ?lista) 3)) ;si son 3 o menos
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
  ?f <- (propiedad_receta (receta ?nombre) (ingrediente ?ing)) ; comprobamos que es un ingrediente
  (es_un_tipo_de ?ing condimento) ; si es un condimento, lo eliminamos
  =>
  ;(printout t "El ingrediente " ?ing " en la receta " ?nombre " es un condimento, no se considera ingrediente principal." crlf)
  (retract ?f) ; eliminamos el hecho
)



; 3) Si un ingrediente es carne o pescado y no hay ingredientes principales seguramente sea un ingrediente principal
;;para carne:
(defrule carne-es-principal-si-no-hay-otros
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
  (receta (nombre ?nombre) (ingredientes $?ings))
  (not (propiedad_receta (receta ?nombre) (ingrediente ?ing))) ; no debe haber ingredientes principales aún
  ?f <- (es_un_tipo_de ?ing pescado) ; si encontramos pescado
  (test (member$ ?ing ?ings)) ; y está en los ingredientes
  =>
  ;(printout t "El ingrediente " ?ing " en la receta " ?nombre " es pescado y no hay otros ingredientes principales." crlf)
  (assert (propiedad_receta (tipo ingrediente_principal) (receta ?nombre) (ingrediente ?ing))) ; añadimos pescado como ingrediente principal
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;PARTE 2:MODIFICAR RECETAS COMPLETANDO EL TIPO DE PLATO 
;;;modificar las recetas completando cual seria el/los tipo_plato asociados a una receta, 
;;;;;;;; especialmente para el caso de que no incluya ninguno
;usamos modify para modificar el template de la receta y asi completar los tipos de platos
;de hecho, algunos ya tienen su tipo de plato pero se le añadirá alguno mas si se ve conveniente
;por ejemplo, yo no veo mucha diferencia entre postre y desayuno_merienda, entonces, muchas recetas que sean
;del tipo postre, pueden aniadirse tambien al tipo desayuno_merienda

;he pensado en clasificar ingredientes caracteristicos
;si tiene carne o pescado es un plato principal
(defrule deducir-plato-principal
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
  ?r <- (receta (nombre ?nombre) (tipo_plato $?tipo&:(not (member$ acompanamiento ?tipo))) (ingredientes $?ings))
  (test (member$ pan ?ings))
  =>
  (modify ?r (tipo_plato (create$ ?tipo acompanamiento)))
  ;(printout t "Asignado tipo_plato acompanamiento a receta " ?nombre " porque contiene pan." crlf)
  (assert (propiedad_receta (tipo acompaniamento) (receta ?nombre)))
)

;;para los entrantes creo que son los que solo tienen verdura y pocos ingredientes
(defrule deducir-entrante
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PARTE 3: DEDUCIR PROPIEDADES ESPECIALES DE LAS RECETAS
;;; si una receta es: vegana, vegetariana, de dieta, picante, sin gluten o sin lactosa
;nos centramos en los alimentos que no pueden tener ciertas propiedades
;miramos si los tienen. Si los tienen se clasifica como que no cumple esa propiedad y despues se hace el not

;;una receta vegana no tiene lacteos, ni huevos, ni carne, ni pescado
(defrule receta-no-vegana
   (declare (salience -4)) 
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
   (receta (nombre ?n))
   (not (propiedad_receta (tipo no_es_vegana) (receta ?n)))
   =>
   (assert (propiedad_receta (tipo es_vegana) (receta ?n)))
   ;(printout t ?n " es vegano " crlf)
)


;;una receta vegetariana es que no tiene pescado ni carne (embutidos, fiambres...) pero si puede tener lacteos o huevos
(defrule receta-no-vegetariana
   (declare (salience -6)) 
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
   (receta (nombre ?n))
   (not (propiedad_receta (tipo no_es_vegetariana) (receta ?n)))
   =>
   (assert (propiedad_receta (tipo es_vegetariana) (receta ?n)))
   ;(printout t ?n " es vegetariano " crlf)
)


;;sin gluten es que no tenga ni harina ni trigo ni sus derivados 
(defrule receta-gluten
   (declare (salience -10))
   (receta (nombre ?n) (ingredientes $? ?i $?))
   (es_un_tipo_de ?i cereales)
   =>
   ;(printout t ?n " no es para celiacos " crlf)
   (assert (propiedad_receta (tipo es_con_gluten) (receta ?n)))
)

;hacemos el not de la anterior
(defrule receta-no-gluten
   (declare (salience -11))
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_con_gluten) (receta ?n)))
   =>
   ;(printout t ?n " es para celiacos " crlf)
   (assert (propiedad_receta (tipo es_sin_gluten) (receta ?n)))
)


;;sin lactosa es que no tenga nada de lacteos
(defrule receta-lactosa
   (declare (salience -12))
   (receta (nombre ?n) (ingredientes $? ?i $?))
   (es_un_tipo_de ?i lacteos)
   =>
   ;(printout t ?n " no es intolerantes a la lactosa " crlf)
   (assert (propiedad_receta (tipo es_con_lactosa) (receta ?n)))
)

;hacemos el not de la anterior
(defrule receta-no-lactosa
   (declare (salience -13))
   (receta (nombre ?n))
   (not (propiedad_receta (tipo es_con_lactosa) (receta ?n)))
   =>
   ;(printout t ?n " es para intolerantes a la lactosa " crlf)
   (assert (propiedad_receta (tipo es_sin_lactosa) (receta ?n)))
)


;; si es picante en el nombre deberia de poner picante en el titulo de la receta
(defrule receta-picante
  (declare (salience -14))
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
  (receta (nombre ?n) (Calorias ?c&:(< ?c 350)))
  =>
  (assert (propiedad_receta (tipo es_de_dieta) (receta ?n)))
  ;(printout t "La receta " ?n " es de dieta (pocas calorias)." crlf)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;INTERACION CON EL USUARIO PARA QUE SEA SENCILLO DE COMPROBAR EL FUNCIONAMIENTO
;ahora voy a hacer una interaccion con el usuario para que sea mas comodo de entender mi programa:
;le voy a pedir al usuario una receta
;el programa va a decir los ingredientes principales y si tiene alguna propiedad (vegana, vegetariana, sin lactosa, para celiacos, picante o de dieta)

;regla para pedir el nombre de la receta al usuario
(defrule pedir-nombre-receta
   (declare (salience -16)) ;lo hacemos despues de que se haya deducido todo
   =>
   (printout t "Introduce el nombre de la receta: ")
   (bind ?nombre (readline))
   (assert (receta-pedida ?nombre))  ;almacenamos el nombre de la receta solicitada
   (assert (Tarea receta-no-encontrada)) ;asignamos una tarea para ver si la receta existe
)

;regla para ver si la receta existe
(defrule ver-existencia-receta
   (declare (salience -17))
   (receta (nombre ?nombre))
   (receta-pedida ?nombre)
   ?f <- (Tarea receta-no-encontrada)
   =>
   (printout t "Receta " ?nombre " encontrada." crlf)
   (retract ?f) ;eliminamos la tarea si la receta es encontrada
)

;regla para manejar cuando la receta no exista
(defrule receta-no-encontrada
   (declare (salience -18))
   (Tarea receta-no-encontrada)
   (receta-pedida ?nombre)
   =>
   (printout t "La receta " ?nombre " no se encuentra en el fichero recetas.txt." crlf)
)

;mostramos los ingredientes principales de la receta pedida
(deffunction mostrar-ingredientes-principales (?receta ?lista-ingredientes)
   (printout t "Ingredientes principales de la receta:" crlf)
   (foreach ?ing ?lista-ingredientes
      (if (any-factp ((?f propiedad_receta))
            (and (eq ?f:tipo ingrediente_principal)
                 (eq ?f:receta ?receta)
                 (eq ?f:ingrediente ?ing)))
         then
            (printout t " - " ?ing crlf))))

;mostramos las propiedades especiales de la receta
(deffunction mostrar-propiedades-extra (?receta)
   (bind ?prop-list (create$))
   (foreach ?tipo (create$ es_vegana es_vegetariana es_sin_gluten es_picante es_sin_lactosa es_de_dieta)
      (if (any-factp ((?f propiedad_receta))
            (and (eq ?f:tipo ?tipo)
                 (eq ?f:receta ?receta)))
         then
            (bind ?prop-list (insert$ ?prop-list 1 ?tipo))))
   (if (neq (length$ ?prop-list) 0)
      then
         (printout t "Propiedades especiales: " (implode$ ?prop-list ) crlf)
      else
         (printout t "Sin propiedades especiales." crlf)))


 (defrule mostrar-ingredientes-y-propiedades
   (declare (salience -19))
   (receta-pedida ?nombre)
   ?r <- (receta (nombre ?nombre) (ingredientes $?ings) (tipo_plato $?tipo))
   =>
   (printout t "Tipo de plato: " ?tipo crlf)
   (mostrar-propiedades-extra ?nombre) ;mostramos las propiedades adicionales
   (mostrar-ingredientes-principales ?nombre ?ings) ;mostramos los ingredientes relevantes
)
