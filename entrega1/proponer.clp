(defmodule proponer-receta (export ?ALL) (import MAIN ?ALL))

(defrule iniciar-propuesta
   =>
   (assert (modulo proponer-receta))
)


;;seleccionamos una receta al azar de todas las candidatas disponibles que cumplan con las restricciones puestas por el usuario
(defrule seleccionar-receta
   (modulo proponer-receta)
   (not (receta-seleccionada (nombre ?)))
   =>
   (bind ?candidatas (create$))
   ;recolectamos todas las candidatas
   (do-for-all-facts ((?r receta-candidata)) TRUE
      (bind ?candidatas (create$ ?candidatas ?r:nombre)))

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
   (assert (info-mostrada))
)

;preguntamos al usuario si le ha gustado la receta que le hemos recomendado
(defrule preguntar-confirmacion
   (modulo proponer-receta)
   (receta-seleccionada (nombre ?n))
   ?d <- (desea-info (valor no))  ; si no quiso más info
   =>
   (retract ?d)
   (assert (info-mostrada)) ; también continúa
)

(defrule pedir-confirmacion-receta
   (modulo proponer-receta)
   (receta-seleccionada (nombre ?n))
   ?i <- (info-mostrada)
   =>
   (retract ?i)
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

;si no le ha gustado le preguntamos el por que (ingredientes, dificultad, duracion)
(defrule preguntar-rechazo
   (modulo proponer-receta)
   ?c <- (confirmacion_receta (valor no))
   =>
   (retract ?c)
   (printout t "¿Qué aspecto no te convence de la receta? (ingredientes, dificultad, duracion): ")
   (bind ?entrada (readline))
   (bind ?motivo (sym-cat (lowcase ?entrada))) ; convertir a símbolo
   (if (member$ ?motivo (create$ ingredientes dificultad duracion)) then
      (assert (motivo-rechazo (tipo ?motivo)))
   else
      (printout t "Opción no válida. Intenta de nuevo." crlf)
      (assert (confirmacion_receta (valor no)))) ; volverá a preguntar
)


;si el motivo es dificultad, preguntar el nivel
(defrule detalle-rechazo-dificultad
   ?m <- (motivo-rechazo (tipo dificultad))
   =>
   (retract ?m)
   (printout t "¿Qué dificultad quieres evitar? (alta, media, baja, muy_baja): ")
   (bind ?entrada (readline))
   (bind ?dif (sym-cat (lowcase ?entrada)))
   (if (member$ ?dif (create$ alta media baja muy_baja)) then
      (assert (detalle-rechazo (tipo dificultad) (valor ?dif)))
   else
      (printout t "Dificultad no válida. Intenta de nuevo." crlf)
      (assert (motivo-rechazo (tipo dificultad)))) ; vuelve a preguntar
)


;si el motivo es duración, preguntar máximo en minutos
(defrule detalle-rechazo-duracion
   ?m <- (motivo-rechazo (tipo duracion))
   =>
   (retract ?m)
   (printout t "¿Cuál es el tiempo máximo de preparación en minutos (solo número, ejemplo: 45)?: ")
   (bind ?entrada (readline))
   (if (and (integerp (eval ?entrada)) (> (eval ?entrada) 0)) then
      (assert (detalle-rechazo (tipo duracion) (valor (eval ?entrada))))
   else
      (printout t "Duración no válida. Intenta de nuevo." crlf)
      (assert (motivo-rechazo (tipo duracion))))
)

;si el motivo es ingredientes, preguntar cuál
(defrule detalle-rechazo-ingrediente
   ?m <- (motivo-rechazo (tipo ingredientes))
   =>
   (retract ?m)
   (printout t "¿Qué ingrediente deseas evitar?: ")
   (bind ?ing (lowcase (readline)))
   (assert (detalle-rechazo (tipo ingredientes) (valor ?ing)))
)


; Filtrar por dificultad
(defrule filtrar-dificultad
   ?f <- (detalle-rechazo (tipo dificultad) (valor ?d))
   ?r <- (receta-candidata (nombre ?n))
   (receta (nombre ?n) (dificultad ?dif&?d))
   =>
   (retract ?r)
)


; Filtrar por duración (cuando excede el tiempo máximo en minutos indicado por el usuario)
(defrule filtrar-duracion
   ?f <- (detalle-rechazo (tipo duracion) (valor ?max))
   ?r <- (receta-candidata (nombre ?n))
   (receta (nombre ?n) (duracion ?dur))
   =>
   (bind ?solo-num (sub-string 1 (- (str-length ?dur) 1) ?dur))
   (if (integerp (eval ?solo-num)) then
      (bind ?num (eval ?solo-num))
      (if (> ?num ?max) then
         (retract ?r)))
)

; Filtrar por ingrediente
(defrule filtrar-ingrediente
   ?f <- (detalle-rechazo (tipo ingredientes) (valor ?ing))
   ?r <- (receta-candidata (nombre ?n))
   (receta (nombre ?n) (ingredientes $?lista))
   =>
   (if (member$ ?ing ?lista) then
      (retract ?r))
)

;regla para marcar que ya se ha filtrado todas las recetas candidatas
(defrule marcar-filtrado-completo
   (modulo proponer-receta)
   (detalle-rechazo (tipo dificultad) (valor ?d))
   (not 
      (and 
         (receta-candidata (nombre ?n))
         (receta (nombre ?n) (dificultad ?d))
      )
   )
   ?f <- (detalle-rechazo (tipo dificultad) (valor ?d))
   =>
   (printout t "Buscamos recetas para evitar" crlf) ;ACABAR
   (retract ?f)
   (assert (filtrado-completado))
)

;regla que repropone otra receta despues del filtrado
(defrule continuar-tras-filtrado
   (modulo proponer-receta)
   ?f <- (filtrado-completado)
   ?r <- (receta-seleccionada (nombre ?n))
   =>
   (retract ?f)
   (retract ?r) ; limpiamos la receta anterior
   ; La regla seleccionar-receta se disparará automáticamente
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
   (declare (salience 10)) ;si esta lista para disparse que se dispare la primera para no causar errores inesperados
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

;regla para cuando no haya despues del filtrado
(defrule sin-mas-recetas-despues-filtrado
   (declare (salience 10)) ;si esta lista para disparse que se dispare la primera para no causar errores inesperados
   ?m <- (modulo proponer-receta)
   ?r <- (receta-seleccionada (nombre ?n))
   ?f <- (filtrado-completado)
   (not (receta-candidata (nombre ?otra&~?n)))
   =>
   (printout t crlf "No tenemos más recetas compatibles tras aplicar tus preferencias." crlf)
   (retract ?f)
   (retract ?r)
   (retract ?m)
)







