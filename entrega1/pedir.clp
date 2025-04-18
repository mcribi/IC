;;MODULO PARA PEDIR INFORMACION AL USUARIO
(defmodule PEDIR (export ?ALL) (import MAIN ?ALL))

(defrule iniciar-peticion
   =>
   (assert (modulo PEDIR)))

(defrule preguntar-tipo-plato
   (modulo PEDIR)
   ?f <- (info-faltante (campo tipo-plato))
   (not (preferencia-plato (tipo ?)))
   =>
   (printout t "¿Qué tipo de plato buscas? (entrante, primer_plato, plato_principal, postre, desayuno_merienda, acompanamiento): ")
   (bind ?tipo (readline))
   (assert (preferencia-plato (tipo ?tipo)))
   (retract ?f)
)

(defrule preguntar-propiedades-especiales
   (modulo PEDIR)
   ?f <- (info-faltante (campo propiedad))
   (not (preferencia-propiedad (tipo ?)))
   (not (hecho propiedad-preguntada))
   =>
   (assert (hecho propiedad-preguntada))
   (printout t "¿Buscas alguna propiedad especial? (es_vegana, es_vegetariana, es_sin_gluten, es_picante, es_sin_lactosa, es_de_dieta) o escribe 'ninguna': ")
   (bind ?prop (readline))
   (if (neq ?prop "ninguna") then
      (assert (preferencia-propiedad (tipo ?prop))))
   (retract ?f)
)

(defrule fin-pedir-informacion
   ?f <- (modulo PEDIR)
   (preferencia tipo_plato ?)
   (hecho propiedad-preguntada)
   =>
   (retract ?f)
   (assert (modulo deducir-propiedades))
)




