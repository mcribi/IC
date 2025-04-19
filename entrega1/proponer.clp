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
   ;eliminamos todas las demas candidatas
   (do-for-all-facts ((?r receta-candidata)) TRUE
      (retract ?r))
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

;; Fin del módulo
(defrule fin-proponer-receta
   ?f <- (modulo proponer-receta)
   =>
   (retract ?f)
   (printout t "Gracias por usar el recomendador de recetas. ¡Buen provecho!" crlf)
)

