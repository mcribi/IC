;;MODULO PARA OBTENER LAS RECETAS COMPATIBLES SEGUN LAS RESTRICCIONES DEL USUARIO
;importamos todo lo del main y definimos el modulo actual. Con el export all hace que lo definido en este modulo este disponible para los demas modulos
;asi puede ser usado tambien desde fuera
(defmodule obtener-compatibles (export ?ALL) (import MAIN ?ALL))


;;;;;;;;;;;;;;;;;;;;EXPLICACON MODULO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OBTENER-COMPATIBLES: este modulo se encarga de filtrar las recetas segun la informacion dada por el usuario
;marca como candidatas las recetas que coincida el tipo y propiedades del usuario
;elimina las recetas que no cumplen las restricciones del usuario
;si no se especifico ninguna restriccion, se aceptan todas 
;nos aseguramos que el sistema responde con lo que introduce el usuario
; ademas, es capaz de razonar con conocimiento incompleto, lo que le interese a cada usuario porque si no da restriccion se eligen todas como candidatas
; deduce que una receta es compatible con lo que desea el usuario (y retracta cuando con la nueva información deje de serlo->en modulo de proponer-receta)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;regla para aniadir el modulo actual para que se puedan disparar las siguiente reglas de este modulo
(defrule iniciar-compatibilidad
   =>
   (assert (modulo obtener-compatibles))
)

;recetas que coinciden con el tipo de plato indicado
(defrule receta-compatible-con-preferencia
   (modulo obtener-compatibles)
   (receta (nombre ?n) (tipo_plato $?t))
   (preferencia-plato (tipo ?p))
   (test (member$ (sym-cat ?p) ?t))
   =>
   (assert (receta-candidata (nombre ?n)))
)

;si el usuario ha indicado una propiedad, descartamos recetas que no la tengan
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


;;mensaje si no se indicó ninguna propiedad (se cogeran todas en este caso)
(defrule sin-propiedades-especiales
   (modulo obtener-compatibles)
   (not (preferencia-propiedad (tipo ?)))
   =>
   (printout t "No se especificó ninguna propiedad especial. Se aceptan todas las recetas del tipo indicado." crlf)
)

;mensaje si no hay recetas candidatas
(defrule sin-recetas-candidatas
   (modulo obtener-compatibles)
   (not (receta-candidata (nombre ?n)))
   =>
   (printout t "No se encontraron recetas que cumplan con tus preferencias." crlf)
)

;en este caso ya lo hace el main
;; fin de módulo
;(defrule fin-obtener-compatibles
;   ?f <- (modulo obtener-compatibles)
;   =>
;   (retract ?f)
;   (assert (modulo proponer-receta))
;)
