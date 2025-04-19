(defmodule proponer-receta (export ?ALL) (import MAIN ?ALL))

(defrule iniciar-propuesta
   =>
   (assert (modulo proponer-receta))
)


;;seleccionamos una receta al azar de todas las candidatas disponibles que cumplan con las restricciones puestas por el usuario
(defrule seleccionar-receta
   (modulo proponer-receta)
   =>
   (bind ?candidatas (create$))
   ;; recolectamos todas las candidatas
   (do-for-all-facts ((?r receta-candidata)) TRUE
      (bind ?candidatas (create$ ?candidatas ?r:nombre)))

   ;elegimos una al azar
   (bind ?total (length$ ?candidatas))
   (bind ?indice (random 1 ?total))
   (bind ?seleccionada (nth$ ?indice ?candidatas))

   (assert (receta-seleccionada (nombre ?seleccionada)))
)


;;mostramos la receta seleccionada con justificación
(defrule mostrar-receta-seleccionada
   (modulo proponer-receta)
   (receta-seleccionada (nombre ?n))
   (receta (nombre ?n) (tipo_plato $?tipo) (ingredientes $?ings))
   =>
   (printout t crlf "Te recomendamos la receta: *** " ?n " ***" crlf)
   (printout t "Tipo de plato: " ?tipo crlf)
   (printout t "Ingredientes: " (implode$ ?ings) crlf)
   (printout t "Propiedades especiales:" crlf)
   (do-for-all-facts ((?p propiedad_receta)) 
      (and (eq ?p:receta ?n)
           (neq ?p:tipo ingrediente_principal))
      (printout t " - " ?p:tipo crlf))
   (printout t crlf)
)

;preguntamos si quiere más información sobre la receta
(defrule preguntar-si-desea-info
   (modulo proponer-receta)
   (receta-seleccionada (nombre ?n))
   =>
   (printout t "¿Quieres más información sobre esta receta? (si / no): ")
   (bind ?respuesta (lowcase (readline)))
   (if (eq ?respuesta "si") then
      (assert (desea-info (valor si)))
   else
      (assert (desea-info (valor no))))
)

;si quiere más información, se la mostramos
(defrule mostrar-informacion-detallada
   (modulo proponer-receta)
   (receta-seleccionada (nombre ?n))
   ?d <- (desea-info (valor si))
   ?r <- (receta 
           (nombre ?n)
           (introducido_por ?autor)
           (numero_personas ?npers)
           (ingredientes $?ings)
           (dificultad ?dific)
           (duracion ?dur)
           (enlace ?link)
           (tipo_plato $?tipos)
           (coste ?coste)
           (tipo_copcion ?coc)
           (tipo_cocina $?cocina)
           (temporada ?temp)
           (Calorias ?cal)
           (Proteinas ?prot)
           (Grasa ?gras)
           (Carbohidratos ?carb)
           (Fibra ?fibra)
           (Colesterol ?colest))
   =>
   (printout t crlf "*** Información detallada de la receta: ***" crlf)
   (printout t "Autor: " ?autor crlf)
   (printout t "Para " ?npers " personas" crlf)
   (printout t "Dificultad: " ?dific ", Duración: " ?dur crlf)
   (printout t "Tipo(s) de plato: " (implode$ ?tipos) crlf)
   (printout t "Ingredientes: " (implode$ ?ings) crlf)
   (printout t "Tipo de cocción: " ?coc ", Tipo cocina: " (implode$ ?cocina) crlf)
   (printout t "Temporada: " ?temp ", Coste: " ?coste crlf)
   (printout t "Valores nutricionales - Cal: " ?cal ", Prot: " ?prot ", Grasa: " ?gras ", Carb: " ?carb ", Fibra: " ?fibra ", Colesterol: " ?colest crlf)
   (printout t "Enlace: " ?link crlf crlf)
   (retract ?d)
)

;preguntamos al usuario si le ha gustado la receta que le hemos recomendado
(defrule preguntar-confirmacion
   (modulo proponer-receta)
   (receta-seleccionada (nombre ?n))
   (not (desea-info (valor ?))) ; espera a que se haya respondido esa pregunta
   =>
   (printout t "¿Te gusta esta receta? (si / no): ")
   (bind ?respuesta (lowcase (readline)))
   (if (eq ?respuesta "si") then
      (assert (confirmacion_receta (valor si)))
   else
      (assert (confirmacion_receta (valor no))))
)

;si le ha gustado la receta, justificamos mejor la respouesta y terminamos
;justifico cada propiedad que es y por que se ha elegido esa receta (segun propiedad especial y tipo de plato)
(defrule justificar-receta-final
   ?m <- (modulo proponer-receta)
   ?c <- (confirmacion_receta (valor si))
   ?f <- (receta-seleccionada (nombre ?n))
   (receta (nombre ?n) (tipo_plato $?tipo) (ingredientes $?ings))
   =>
   (printout t crlf "Perfecto." crlf)
   (printout t "Esta receta ha sido seleccionada porque cumple con tus preferencias alimentarias y el tipo de plato que buscabas:" crlf)
   (printout t "El tipo de plato de esta receta concuerda con el elegido: " (implode$ ?tipo) crlf)
   (printout t "Los ingredientes son los siguientes: " (implode$ ?ings) crlf)
   (printout t "Las propiedades especiales que tiene (concuerdan con las elegidas):" crlf)
   (do-for-all-facts ((?p propiedad_receta)) 
      (and (eq ?p:receta ?n)
           (neq ?p:tipo ingrediente_principal))
      (printout t " - " ?p:tipo crlf))
   (printout t crlf)
   (printout t "Si es vegana no tiene carne, pescado, lacteos ni nada de origen animal. Si es vegetariana no tiene ni pescado ni carne. Si es sin gluten no tiene nada derivado del trigo. Si es sin lactosa no lleva nada de derivados lacteos. Si es picante lo lleva en el nombre. Si es de dieta tiene menos de 350 calorías." crlf)
   (printout t "Gracias por usar el recomendador de recetas. ¡Buen provecho!" crlf)
   (retract ?c)
   (retract ?f)
   (retract ?m)
)


;; si no le ha gustado, proponemos otra que no sea la anterior
(defrule nueva-propuesta
   (modulo proponer-receta)
   ?r <- (receta-seleccionada (nombre ?nombreAntigua))
   ?c <- (confirmacion_receta (valor no))
   ?rc <- (receta-candidata (nombre ?nombreAntigua))
   ?otra <- (receta-candidata (nombre ?n&~?nombreAntigua))
   =>
   (retract ?r)
   (retract ?c)
   (retract ?rc) ; eliminamos la receta rechazada de la lista de candidatas
   (assert (receta-seleccionada (nombre ?n)))
)

;regla para cuando solo quede/haya una receta candidata
(defrule sin-mas-recetas
   ?m <- (modulo proponer-receta)
   ?r <- (receta-seleccionada (nombre ?n))
   ?c <- (confirmacion_receta (valor no))
   ?rc <- (receta-candidata (nombre ?n))
   (not (receta-candidata (nombre ?otra&~?n))) ; no hay otras
   =>
   (printout t crlf "Lo sentimos, no tenemos más recetas compatibles para recomendarte." crlf)
   (printout t "Puedes ejecutar el sistema de nuevo con otras preferencias. ¡Lo siento!" crlf)
   (retract ?r)
   (retract ?rc)
   (retract ?c)
   (retract ?m)
)






