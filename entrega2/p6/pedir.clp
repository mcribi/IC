;Practica 3
;María Cribillés Pérez

;;MODULO PARA PEDIR INFORMACION AL USUARIO
;importamos todo lo del main y definimos el modulo actual. Con el export all hace que lo definido en este modulo este disponible para los demas modulos
;asi puede ser usado tambien desde fuera
(defmodule PEDIR (export ?ALL) (import MAIN ?ALL))

;;;;;;;;;;;;;;;;;;;;EXPLICACON MODULO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PEDIR: este modulo se encarga de recopilar informacion que le pide al usuario, verifica la entrada y si no interpreta que no quiere restriccion e inserta las preferencias del usuario como hechos
;creo que para empezar lo mejor es preguntarle lo esencial al usuario: tipo de plato y propiedad especial
;esto hara que sea SENCILLA Y COMODA LA ENTRADA para el usuario responder lo que quiere
; de hecho, ADMITE SIEMPRE RESPUESTAS PARCIALES ya que si no quiere tener ninguna restriccion o 
; quiere que sea cualquier plato puede no responder nada y este modulo lo interpretara que no tiene ninguna
; restriccion o que le da igual el tipo de plato (puede no escribir o escribir cualquier cosa que no sea una opcion)
; esto hace que la ENTRADA SEA NATURAL, NO TEDIOSA NI DE FORMA MECANICA
; ya que primero solo preguntamos esas dos cosas (y puede si quiere ni escribirlas para que sea mas libre) y se recomendara una receta acorde a eso
; sera despues de recomendarla cuando se le preguntara si le ha gustado y caracteristicas mas especificas a cambiar
; es la forma mas natural y que hariamos las persona, no preguntar todo de golpe, si no ir de los principal a lo especifico
; asi conseguimos que solo se realicen las preguntas oportunas en cada momento y de acuerdo a cada caso
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;regla para iniciar el modulo y meter un hecho que sea el modulo
;en las demas reglas del modulo tenemos en el antecedente el hecho de este modulo
;por lo que solo se dispararan si se ha ejecutado antes esta regla
(defrule iniciar-peticion
   =>
   (assert (modulo PEDIR)))

;preguntamos acerca del tipo de plato que quiere consumir el usuario
;admite RESPUESTA PARCIAL: si escribe una opcion o cualquier cosa (incluso si no escribe nada) que no sea una opcion, el recomendador
;pensara que no quiere ninguna restriccion de tipo de plato y le recomendara cualquier tipo indiferentemente
(defrule preguntar-tipo-plato
   (modulo PEDIR)
   ?f <- (info-faltante (campo tipo-plato))
   (not (preferencia-plato (tipo ?)))
   =>
   (printout t "¿Qué tipo de plato buscas? (entrante, primer_plato, plato_principal, postre, desayuno_merienda, acompanamiento): ")
   (bind ?input (readline))
   (bind ?tipo (sym-cat ?input)) 
   (if (member$ ?tipo (create$ entrante primer_plato plato_principal postre desayuno_merienda acompanamiento)) then
      (assert (preferencia-plato (tipo ?tipo)))
   else
      (printout t "Opción no válida. Se considerarán todos los tipos de plato." crlf)
      (foreach ?t (create$ entrante primer_plato plato_principal postre desayuno_merienda acompanamiento)
         (assert (preferencia-plato (tipo ?t)))))
   (retract ?f)
)


;para preguntar si tiene alguna propiedad especial
;al igual que el anterior ADMITE RESPUESTAS PARCIALES ya que si no escribe o escribe una opcion no valida se considerará que no necesita ninguna 
;propiedad en concreto y recomendara opcion sin tener en cuenta las propiedades
(defrule preguntar-propiedades-especiales
   (modulo PEDIR)
   ?f <- (info-faltante (campo propiedad))
   (not (preferencia-propiedad (tipo ?)))
   (not (hecho propiedad-preguntada))
   =>
   (assert (hecho propiedad-preguntada))
   (printout t "¿Buscas alguna propiedad especial? (es_vegana, es_vegetariana, es_sin_gluten, es_picante, es_sin_lactosa, es_de_dieta) o escribe 'ninguna': ")
   (bind ?input (readline))
   (bind ?prop (sym-cat ?input))
   (if (member$ ?prop (create$ es_vegana es_vegetariana es_sin_gluten es_picante es_sin_lactosa es_de_dieta)) then
      (assert (preferencia-propiedad (tipo ?prop)))
   else
      (printout t "No se aplicará ninguna restricción por propiedad especial." crlf))
   (retract ?f)
)

;regla final del modulo donde imprime las preferencias guardadas para
;que el usuario pueda comprobar la informacion guardada
(defrule fin-pedir-informacion
   ?f <- (modulo PEDIR)
   (not (info-faltante (campo tipo-plato)))
   (not (info-faltante (campo propiedad)))
   =>
   (printout t crlf "Resumen de tus preferencias:" crlf)

   ;;mostramos los tipos de plato elegidos
   (printout t "  Tipo(s) de plato: ")
   (do-for-all-facts ((?p preferencia-plato)) TRUE
      (printout t ?p:tipo " "))
   (printout t crlf)

   ;;mostramos la propiedad especial (si la hay)
   (bind ?propiedad "ninguna")
   (do-for-fact ((?pp preferencia-propiedad)) TRUE
      (bind ?propiedad ?pp:tipo))
   (printout t "  Propiedad especial: " ?propiedad crlf crlf)

   (retract ?f)
   (assert (modulo deducir-propiedades))
)





