;;MODULO PARA PEDIR INFORMACION AL USUARIO
;(defmodule PEDIR
;  (import MAIN ?ALL)
;  (export ?ALL))

(defrule iniciar-peticion
   =>
   (assert (modulo PEDIR))
)

(defrule preguntar-tipo-plato
   (modulo PEDIR)
   (not (preferencia tipo_plato ?))
   =>
   (printout t "Hola! Un placer poder ser tu recomendador de platos según tus necesidades. ¿Qué tipo de plato buscas? (entrante, primer_plato, plato_principal, postre, desayuno_merienda, acompanamiento): ")
   (bind ?tipo (readline))
   (assert (preferencia tipo_plato ?tipo))
)

(defrule preguntar-propiedades-especiales
   (modulo PEDIR)
   (not (preferencia propiedad ?))
   (not (hecho propiedad-preguntada)) ; solo preguntamos si no se ha preguntado aún
   =>
   (assert (hecho propiedad-preguntada))
   (printout t "¿Buscas alguna propiedad especial? (es_vegana, es_vegetariana, es_sin_gluten, es_picante, es_sin_lactosa, es_de_dieta) o escribe 'ninguna': ")
   (bind ?prop (readline))
   (if (neq ?prop "ninguna") then
      (assert (preferencia propiedad ?prop)))
)


(defrule fin-pedir-informacion
   ?f <- (modulo PEDIR)
   (preferencia tipo_plato ?)
   (hecho propiedad-preguntada)
   =>
   (retract ?f)
   (assert (modulo deducir-propiedades))
)


