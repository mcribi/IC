(defmodule obtener-compatibles (export ?ALL) (import MAIN ?ALL))

(defrule iniciar-compatibilidad
   =>
   (assert (modulo obtener-compatibles))
)

;; Recetas que coinciden con el tipo de plato indicado
(defrule receta-compatible-con-preferencia
   (modulo obtener-compatibles)
   (receta (nombre ?n) (tipo_plato $?t))
   (preferencia-plato (tipo ?p))
   (test (member$ (sym-cat ?p) ?t))
   =>
   (assert (receta-candidata (nombre ?n)))
)

;; Si el usuario ha indicado una propiedad, descartamos recetas que no la tengan
(defrule receta-incompatible-con-propiedad
   (modulo obtener-compatibles)
   ?f <- (receta-candidata (nombre ?n))
   (preferencia-propiedad (tipo ?p))
   (test (not (any-factp ((?pr propiedad_receta))
            (and (eq ?pr:receta ?n)
                 (eq ?pr:tipo (sym-cat ?p))))))
   =>
   (retract ?f)
)


;; Mensaje si no se indicó ninguna propiedad
(defrule sin-propiedades-especiales
   (modulo obtener-compatibles)
   (not (preferencia-propiedad (tipo ?)))
   =>
   (printout t "No se especificó ninguna propiedad especial. Se aceptan todas las recetas del tipo indicado." crlf)
)

;; Mensaje si no hay recetas candidatas
(defrule sin-recetas-candidatas
   (modulo obtener-compatibles)
   (not (receta-candidata (nombre ?n)))
   =>
   (printout t "No se encontraron recetas que cumplan con tus preferencias." crlf)
)


;; fin de módulo
;(defrule fin-obtener-compatibles
;   ?f <- (modulo obtener-compatibles)
;   =>
;   (retract ?f)
;   (assert (modulo proponer-receta))
;)
