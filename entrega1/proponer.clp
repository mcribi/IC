(defmodule proponer-receta (export ?ALL) (import MAIN ?ALL))

(defrule iniciar-propuesta
   =>
   (assert (modulo proponer-receta))
)


;; Seleccionamos la primera receta candidata como la elegida
(defrule seleccionar-receta
   (modulo proponer-receta)
   ?c <- (receta-candidata (nombre ?n))
   =>
   (assert (receta-seleccionada (nombre ?n)))
   (retract ?c)
)

;; Mostramos la receta seleccionada con justificación
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

