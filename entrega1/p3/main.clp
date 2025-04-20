;Practica 3
;María Cribillés Pérez

;Este archivo es el ejecutable donde carga todos los modulos y definimos las cosas en comun de todo el proyecto
;He diseniado un sistema basado en el conocimiento (Qué cocino hoy) para aconsejar a un usuario una receta de acuerdo a algunas restricciones
;El sistema cargará las recetas del fichero recetas.txt (igual que en la practica 2)
;Lo hemos hecho modular, es decir, tenemos 4 modulo mas el main
;En cada modulo nos centramos en una cosa diferente para que sea legible y editable facilmente. Es facil de entender y de aniadir o eliminar funcionalidades simplemente modificando reglas (eliminando/aniadendo)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MAIN.CLP 
;Cargamos todos los modulos:
; 1. pedir-informacion: pide la informacion necesaria al usuario y guarda esa informacion (admite respouestas parciales para que sea mas flexible para el usuario)
; 2. deducir-propiedades: es la practica 2 donde a partir de conocimiento se deducen propiedades de las recetas y alimentos
; 3. obtener-compatibles: con la informacion dada por el usuario, se van filtrando recetas hasta quedarnos con las candidatas concorde a esas restricciones
; 4. proponer-receta: al tener ya todas las candidatas, se escoge una aleatoria entre las candidatas, se pregunta al usuario si quiere mas informacion y si le gusta la receta. 
; si no le gusta la receta, se le preguntara por ciertas caracteristicas que quiere cambiar y se filtraran y retractaran las recetas que no cumplan esas caracteristicas
; se volvera a enseniar la receta seleccionada aleatoriamente entre las candidatas y volvera a preguntar si le gusta y si no la caracteristica que qiere filtrar. 
; asi en bucle hasta que no queden mas recetas a recomendar o hasta que el usuario le guste la receta
; 5. MAIN: define los template generales, controla el flujo entre los modulos, incializa el sistema saludando al usuario y activa el primer modulo 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;definimos el modulo main
(defmodule MAIN (export ?ALL))

;defino todos los templates que necesitamos 
;plantilla de receta (igual que practica 2)
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

;plantilla propiedad receta
(deftemplate propiedad_receta
   (slot tipo)         ;tipo de propiedad especial que tenga la receta
   (slot receta)       ;nombre de la receta
   (slot ingrediente)  ;ingredientes principales
)

;plantilla receta a enseñar (seleccionada entre todas las candidatas)
(deftemplate receta-seleccionada
   (slot nombre)
)

;plantilla para recetas compatibles con las restricciones dichas
(deftemplate receta-candidata
  (slot nombre)
)

;plantilla para la informacion que falta que no ha dado todavia el usuario
(deftemplate info-faltante 
  (slot campo))

;plantilla para el tipo de plato que ha elegido el usuario
(deftemplate preferencia-plato
   (slot tipo))

;plantilla para la propiedad que tiene de restriccion que ha dicho el usuario
(deftemplate preferencia-propiedad
   (slot tipo))

;plantilla con la receta recomendada
(deftemplate recomendacion
   (slot receta))

;plantilla de si o no para almacenar si el usuario le gusta o no la receta
(deftemplate confirmacion_receta
   (slot valor))

;plantilla de si o no para almacenar si el usuario quiere una informacion mas detallada de la receta
(deftemplate desea-info
  (slot valor))

;plantilla para almacenar la caracteristica que no le gusta al usuario a cambiar
(deftemplate motivo-rechazo
   (slot tipo)) ; ingredientes / dificultad / duracion

;plantilla mas detallada sobre el motivo de rechazo, de la caracteristica que quiere cambiar
(deftemplate detalle-rechazo
   (slot tipo) ; dificultad / duracion / ingrediente
   (slot valor); el valor concreto a evitar
)

;;conocimiento: 
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

;;Tenemos en un fichero de texto recetas.txt en el mismo directorio de recetas.clp y hemos copiado 
;;parte (lo he corregido yo que tenia algunos fallos y no cargaba bien) el contenido del archivo compartido
;;ademas, he aniadido yo dos recetas 
;cargamos las recetas (lo primero, de ahi el salience tan positivo)
(defrule cargar-modulos
    (declare (salience 1000))
    =>
    (load "pedir.clp")
    (load "deducir.clp")
    (load "compatibles.clp")
    (load "proponer.clp")
)

;regla para introducir al usuario el recomendador de recetas
;saluda y aniade un hecho de que falta informacion para que se dispare despues el pedir informacion al usuario
(defrule iniciar-sistema
   =>
   (printout t crlf "Hola. Soy un recomendador de platos según tus necesidades." crlf)
   (assert (estado activo))
   (assert (info-faltante (campo tipo-plato)))
   (assert (info-faltante (campo propiedad)))
)

;; CONTROL DE FLUJO ENTRE MÓDULOS
;ejecuccion del modulo pedir informacion al usuario
(defrule control-pedir-informacion
   (estado activo)
   (info-faltante (campo tipo-plato)) ;le falta informacion -> en este modulo la pide al usuario
   (info-faltante (campo propiedad))
   =>
   (focus PEDIR) ;hacemos focus para que se centre en ese modulo
)

;ejecuccion del modulo deducir propiedades
(defrule control-deduccion
   (estado activo)
   (not (info-faltante (campo tipo-plato))) ;ya no le falta informacion porque la ha pedido en el modulo anterior
   (not (info-faltante (campo propiedad)))
   =>
   (focus deducir-propiedades)
)

;ejecuccion del modulo obtener compatibles
(defrule control-compatibles
   (estado activo)
   (not (modulo deducir-propiedades)) ;ya se ha hecho el modulo anterior
   =>
   (focus obtener-compatibles)
)

;ejecuccion del modulo proponer receta
(defrule control-propuesta
   (estado activo)
   (receta-candidata (nombre $?))
   (not (receta-seleccionada (nombre ?))) ;aún no se ha seleccionado ninguna (para no proponer todas las disponibles)
   =>
   (focus proponer-receta)
)


