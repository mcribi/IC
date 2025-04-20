;Práctica 1
;María Cribillés Pérez	

;;;;; SISTEMA BASADO EN EL CONOCIMIENTO PARA RECOMENDAR LA CANTIDAD A TOMAR DE UN ALIMENTO  ;;;;;
                  ;;;;; PARA MANTENER UNA DIETA CARDIOSALUDABLE ;;;;;;;;;
			
;;; Fuente de conocimiento: https://fundaciondelcorazon.com/nutricion/piramide-de-alimentacion.html				

;;;; Descripción: Este sistema pregunta por un alimento y recomienda una cantidad saludable según
;;;; la pirámide alimentaria, mostrando además alimentos parecidos en nivel y propiedades.


;;;ENTRADAS;;;
;;;; (alimento ?a) representará ?a es el alimento sobre el que se pide información
; por ejemplo cuando esté (alimento pan) representará que el usuario desea información sobre el pan

;;; HECHOS DE CONOCIMIENTO
;;;; (es_un_tipo_de ?x ?y) representará ?x es un tipo de ?y
; por ejemplo "los macarrones son un tipo de pasta" se representará (es_un_tipo_de macarrones pasta)
; se introducen de forma explícita algunos, otros se deducen

;;;; (nivel_piramide_alimentaria ?a ?n) representará ?a es un tipo de alimento del nivel ?n de la pirámide alimentaria
; todos se introducen de forma explícita

;;;; (propiedad ?p ?a ?v) representará el valor de la propiedad ?p para ?a es ?v 
; por ejemplo, "la pasta en un alimento rico en hidratos de carbono" se representará (propiedad rico_en_hidratos pasta si)
; se introducen algunos, otros se deducen

;Nivel en la pirámide alimentaria para distintos grupos de alimentos
(deffacts piramide_alimentaria
(nivel_piramide_alimentaria verdura 1)
(nivel_piramide_alimentaria hortalizas 1)
(nivel_piramide_alimentaria fruta 2)
(nivel_piramide_alimentaria cereales 3)
(nivel_piramide_alimentaria lacteos 4)
(nivel_piramide_alimentaria aceite_de_oliva 5)
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

;Relaciones de jerarquis: subtipos
(deffacts subtipos
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
)

;Cantidades recomendadas segun el nivel que estemos de la piramide
(deffacts cantidad_recomendada
(cantidad_recomendada nivel 1 "en raciones de 120-150 gramos" "3-4 veces al dia")
(cantidad_recomendada nivel 2 "en raciones de 150-200 gramos" "2-3 veces al dia")
(cantidad_recomendada nivel 3 "en raciones de 50 gramos" "3 veces al dia")
(cantidad_recomendada nivel 4 "en raciones de 120-150 gramos" "1-2 veces al dia")
(cantidad_recomendada nivel 5 "" "4 cucharadas al dia")
(cantidad_recomendada nivel 6 "en raciones de 25-30 gramos" "1 vez al dia")
(cantidad_recomendada nivel 7 "" "3 veces a la semana")
(cantidad_recomendada nivel 8 "" "3-5 dias a la semana")
(cantidad_recomendada nivel 9 "" "de forma esporadica")
)

;Composicion de algunos alimentos
(deffacts hecho_de
(compuesto_fundamentalmente_por pan harina)
(compuesto_fundamentalmente_por pasta harina)
(compuesto_fundamentalmente_por pizza harina)
)

;;;;;Reglas de inferencia
;Transitividad 
(defrule componiendo_es_un_tipo_de
(es_un_tipo_de ?x ?y)
(es_un_tipo_de ?y ?z)
=>
(assert (es_un_tipo_de ?x ?z))
)

;Clasficacion por composicion
(defrule compuesto_fundamentalmente_por_entonces_es_un_tipo_de
(compuesto_fundamentalmente_por ?x ?y)
=>
(assert (es_un_tipo_de ?x ?y))
)

;Clasfica un alimento en su nivel 
(defrule indicar_nivel_grupo
(alimento ?a)
(nivel_piramide_alimentaria ?a ?n)
=>
(printout t crlf "Pertence al nivel " ?n " de la cadena alimentaria, compuesto por: ")
(assert (nivel ?n))
)

;muestra su nivel
(defrule indicar_nivel_por_tipo
(alimento ?a)
(es_un_tipo_de ?a ?x)
(nivel_piramide_alimentaria ?x ?n)
=>
(printout t crlf "Pertence al nivel " ?n " de la cadena alimentaria, compuesto por: ")
(assert (nivel ?n))
)

;muestra clasificacion por composicion
(defrule indicar_compuesto_fundamentalmente_por
(declare (salience 2))
(alimento ?a)
(compuesto_fundamentalmente_por ?a ?b)
=>
(printout t crlf "Esta compuesto fundamentalmente por " ?b ", asi que lo clasificaremos como este alimento" crlf)
)

;recomendaciones especificas de ciertos alimentos
(defrule recomendar_cereales_siempre_integrales
(alimento ?a)
(es_un_tipo_de ?a cereales)
=>
(printout t crlf crlf "Se recomienda que los cereales se tomen siempre integrales")
)

(defrule recomendar_cereales_siempre_integrales2
(alimento cereales)
=>
(printout t crlf crlf "Se recomienda que los cereales se tomen siempre integrales")
)

(defrule recomendar_lacteos_desnatados_o_semidenatados
(alimento ?a)
(es_un_tipo_de ?a lacteos)
=>
(printout t crlf crlf "Se recomienda que los lacteos se tomen desnatados o semidesnatados")
)

(defrule recomendar_lacteos_desnatados_o_semidenatados2
(alimento lacteos)
=>
(printout t crlf crlf "Se recomienda que los lacteos se tomen desnatados o semidesnatados")
)

;imprime todos los alimentos de un mismo nivel de la piramide
(defrule describir_nivel
(nivel ?n)
(nivel_piramide_alimentaria ?a ?n)
=>
(printout t "- " ?a "   ")
)

;recomendacion final
(defrule indicar_cantidad_recomendada
(declare (salience -1))
(nivel ?n)
(cantidad_recomendada nivel ?n ?t1 ?t2)
=>
(printout t crlf crlf "Para el conjunto de los alimentos de este nivel se recomienda consumirlos " ?t1 " " ?t2 crlf crlf)
)

;pregunta al usuario
(defrule preguntar_alimento
=>
(printout t crlf "Indica el alimento del que deseas saber la cantidad recomendada: " )
(assert (alimento (read)))
)

;;;;;;;; AMPLIANDO EL SISTEMA ;;;;;;;
;propiedades nutricionales por grupo
(deffacts rico_en_proteinas
(propiedad rico_en_proteinas carne si)
(propiedad rico_en_proteinas pescado si)
(propiedad rico_en_proteinas huevos si)
(propiedad rico_en_proteinas lacteos si)
)

(deffacts rico_en_hidratos_de_carbono
(propiedad rico_en_hidratos cereales si)
(propiedad rico_en_hidratos frutos_secos si)
(propiedad rico_en_hidratos legumbres si)
)

(deffacts rico_en_fibras
(propiedad rico_en_fibras fruta si)
(propiedad rico_en_fibras verdura si)
(propiedad rico_en fibras hortalizas si)
(propiedad rico_en_fibras hortalizas si)
)

(deffacts rico_en_grasas
(propiedad rico_en_grasas carne_roja si)
(propiedad rico_en_grasas embutidos si)
(propiedad rico_en_grasas aceite_de_oliva si)
(propiedad rico_en_grasas queso si)  
)

(deffacts rico_en_azucares
(propiedad rico_en_azucares dulces si)
(propiedad rico_en_azucares fruta si)
)

;herencia de propiedades por jerarquia
(defrule herencia_propiedades
(propiedad ?p ?a ?v)
(es_un_tipo_de ?x ?a)
=>
(assert (propiedad ?p ?x ?v))
)

;justificacion por propiedades
(defrule indicar_propiedad_por_tipo
(declare (salience -1))
(alimento ?a)
(es_un_tipo_de ?a ?x)
(nivel_piramide_alimentaria ?x ?)
(propiedad ?p ?x si)
=>
(printout t crlf "Este es un alimento " ?p " porque es un tipo de " ?x crlf)
)

;;;;;; EJERCICIO PARTE 1:  AÑADIR REGLAS PARA LISTAR LOS ALIMENTOS DE LOS QUE SE DISPONE DE INFORMACION ANTES DE PREGUNTAR
;;; Indicaciones: 1) deduce hechos (es_alimento ?x) representando que algo es un alimento a partir de la relacion "es_un_tipo_de"
;;;               2) Imprime por pantalla los es_alimento

;Primero creamos una propiedad llamada es_alimento donde si x es un tipo de y e y ya es un alimento, entonces x es tambien un alimento
(defrule deducir_alimentos
(es_un_tipo_de ?x ?)
=>
(assert (es_alimento ?x)))

;Incluimos tambien los alimentos que no son subtipo de nada pero siguen siendo alimentos
(defrule deducir_alimentos_no_subtipo
(nivel_piramide_alimentaria ?x ?)
(not(es_un_tipo_de ? ?x))
=>
(assert (es_alimento ?x))
)

; A continuacion vamos a imprimir por pantallas todos los hechos insertados de es_alimento realizado justo arriba
; le he subido la prioridad para que se ejecute lo primero, es decir, antes de preguntar

;; Iniciamos la lista de alimentos, añadimos un hecho temporal para que se cumpla el antecedente de la siguiente regla
(defrule iniciar_lista_alimentos
(declare (salience 1))
=>
(printout t crlf "Alimentos con información disponibles: " crlf)
(assert (listar_alimentos)))

;;Regla para imprimir cada alimento. Cuando tengamos el antecedente es_alimento porque se ha disparado su regla correspondiente de deducir_alimentos y la regla anterior que nos da el hecho temporal lista_alimentos se dispara esta regla
;Cada vez que es imprimido, se retracta para que no haya duplicados
;En vez de retractar con numeros, almacenamos el identificador del hecho a la variable ?f
(defrule imprimir_alimento 
(es_alimento ?x)
(listar_alimentos)
=>
(printout t "- " ?x crlf))



;;;;;; EJERCICIO PARTE 2:  AÑADIR REGLAS PARA INDICAR AL FINAL OTROS ALIMENTOS DEL MISMO NIVEL  DE LA PIRÁMIDE Y CON LAS MISMAS PROPIEDADES
;;; Indicaciones: 1) deduce (alimento_parecido ?x)  para los alimentos pertenezcan del mismo nivel que el alimento sobre el que se pregunta
;;;               2) retracta los alimento_parecido que tengan una propiedad con valor distinto al preguntado, y los que no tengan una propiedad que si 
;;;                  tenga el preguntado, y los que tengan una propiedad que no tenga el preguntado
;;;               3) Imprime por pantalla los alimento_parecido que queden 

;aniadimos una regla para deducir los alimentos del mismo nivel de la piramide
;Necesitamos en el antecedente: el alimento preguntado, el nivel donde se encuentra, otros alimentos del mismo nivel y no incluir el propio elemento
(defrule deducir_alimentos_parecidos
(alimento ?a)  ; alimento por el que han hecho la consulta
(es_alimento ?x)  ;es un alimento
(nivel ?n)  ; nivel de la piramide donde esta el alimento
(nivel_piramide_alimentaria ?x ?n)  ; otros alimentos del mismo nivel
(test (neq ?x ?a))  ; quitar el propio elemento
=>
(assert (alimento_parecido ?x)))

;aniadimos tambien alimentos que son subtipos, no solo el alimento general
(defrule deducir_alimentos_parecidos_con_subtipo
(alimento ?a)  ; alimento por el que han hecho la consulta
(es_alimento ?x)  ;es un alimento
(nivel ?n)  ; nivel de la piramide donde esta el alimento
(nivel_piramide_alimentaria ?y ?n)  ; otros alimentos del mismo nivel
(test (neq ?x ?a))  ; quitar el propio elemento
(es_un_tipo_de ?x ?y)
=>
(assert (alimento_parecido ?x))
)

;retracta los alimento_parecido que tengan una propiedad con valor distinto al preguntado
(defrule retracta_alimentos_parecidos_diferente_propiedad
(alimento ?a)  ; alimento consultado
(alimento_parecido ?x)  ; alimento parecido
(propiedad ?p ?a ?v_a)  ; propiedad del alimento consultado
(propiedad ?p ?x ?v_x)  ; propiedad del alimento parecido
(test (neq ?v_a ?v_x))  ; si los valores son diferentes entonces lo retractamos
?f<-(alimento_parecido ?x) ; guardamos su identficador
=>
(retract ?f)) ;borramos el identificador
    
;retracta los alimento_parecido no tengan una propiedad como el alimento preguntado
(defrule retracta_alimentos_parecidos_sin_propiedad
(alimento ?a)  ; alimento consultado
(alimento_parecido ?x)  ; alimento parecido
(propiedad ?p ?a ?v)  ; propiedad del alimento consultado
(not (propiedad ?p ?x ?))  ; alimento parecido sin propiedad
?f<-(alimento_parecido ?x) ; guardamos su identficador
=>
(retract ?f)) ;borramos el identificador

; regla contraria a la anterior: x si tiene propiedad pero a no tiene propiedad: 
(defrule retractar_sin_otra_propiedad
(alimento ?a)  
(alimento_parecido ?x)  
(propiedad ?p ?x ?v)  ;x si tiene la propiedad p
(not (propiedad ?p ?a ?))  ;a no tiene la propiedad p
?f<-(alimento_parecido ?x) ; guardamos su identficador
=>
(retract ?f)) ;borramos el identificador

;imprimimos cabecera de alimentos parecidos
(defrule cabecera_alimentos_parecidos
(declare (salience -2))
(alimento ?a)
(nivel ?n)
=>
(printout t crlf "Los siguientes alimentos son parecidos a " ?a ": "crlf)
)

; imprimimos los alimentos parecidos al final de la consulta
(defrule imprimir_alimentos_parecidos
(declare (salience -3))  ; nos aseguramos que se produzca al final
(alimento ?a) 
(alimento_parecido ?x)  
=>
(printout t "- " ?x crlf))

