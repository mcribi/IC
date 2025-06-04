;;; Definiciones necesarias:
(deftemplate vuelo (slot nombre) (slot vuela) (slot certeza))
(deftemplate explicacion (slot tipo) (slot nombre) (slot texto))
(deftemplate animal-consulta (slot nombre))


;Las aves y los mamíferos son animales
;Los gorriones, las palomas, las águilas y los pingüinos son aves
;La vaca, los perros y los caballos son mamíferos
;Los pingüinos no vuelan

(deffacts base-conocimiento
   (ave gorrion)
   (ave paloma)
   (ave aguila)
   (ave pinguino)
   (mamifero vaca)
   (mamifero perro)
   (mamifero caballo)
   (vuelo (nombre pinguino) (vuela no) (certeza seguro))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Reglas seguras: relación ave/mamífero → animal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Las aves son animales 
(defrule aves-son-animales
   (ave ?x)
   =>
   (assert (animal ?x))
   (assert (explicacion (tipo animal) (nombre ?x) (texto (str-cat "Sabemos que un " ?x " es un animal porque las aves son animales."))))
)
; añadimos un hecho que contiene la explicación de la deducción

; Los mamiferos son animales (A3)
(defrule mamiferos-son-animales
   (mamifero ?x)
   =>
   (assert (animal ?x))
   (assert (explicacion (tipo animal) (nombre ?x) (texto (str-cat "Sabemos que un " ?x " es un animal porque los mamíferos son animales."))))
)
; añadimos un hecho que contiene la explicación de la deducción

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Reglas por defecto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Casi todos las aves vuela --> puedo asumir por defecto que las aves vuelan
; Asumimos por defecto
(defrule ave-vuela-por-defecto
   (declare (salience -1))
   (ave ?x)
   (not (vuelo (nombre ?x)))
   =>
   (assert (vuelo (nombre ?x) (vuela si) (certeza por_defecto)))
   (assert (explicacion (tipo vuela) (nombre ?x) (texto (str-cat "Asumo que un " ?x " vuela porque casi todas las aves vuelan."))))
)

;asumimos pro defecto que los animales no vuelan
(defrule animal-no-vuela-por-defecto
   (declare (salience -2))
   (animal ?x)
   (not (vuelo (nombre ?x)))
   =>
   (assert (vuelo (nombre ?x) (vuela no) (certeza por_defecto)))
   (assert (explicacion (tipo vuela) (nombre ?x) (texto (str-cat "Asumo que " ?x " no vuela porque la mayoría de los animales no vuelan."))))
)

; Retractamos cuando hay algo en contra
;;; COMETARIO: esta regla también elimina los por defecto cuando ya esta seguro 
(defrule eliminar-vuelo-por-defecto
   (declare (salience 1))
   ?f <- (vuelo (nombre ?x) (vuela ?v) (certeza por_defecto))
   (vuelo (nombre ?x) (vuela ?s) (certeza seguro))
   =>
   (retract ?f)
   (assert (explicacion (tipo retracta_vuelo) (nombre ?x) (texto (str-cat "Retiro que " ?x " " ?v " vuela por defecto porque sabemos que " ?x " " ?s " vuela con seguridad."))))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Interacción con el usuario
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule preguntar-animal
   =>
   (printout t crlf "¿Sobre qué animal quieres saber si vuela?: " crlf)
   (bind ?nombre (read))
   (assert (animal-consulta (nombre ?nombre)))
)

(defrule preguntar-tipo-si-desconocido
   ?f <- (animal-consulta (nombre ?x))
   (not (or (ave ?x) (mamifero ?x) (animal ?x))) ; ← CORREGIDO
   =>
   (retract ?f)
   (printout t "No tengo información previa sobre " ?x "." crlf)
   (printout t "¿Es un ave, un mamífero o no lo sabes? (escribe ave / mamifero / no_lo_se): " crlf)
   (bind ?tipo (read))
   (if (eq ?tipo ave) then (assert (ave ?x)) else
    (if (eq ?tipo mamifero) then (assert (mamifero ?x)) else
     (assert (animal ?x))))
   (assert (animal-consulta (nombre ?x))) ; reafirma para continuar
)

(defrule mostrar-explicaciones
   (animal-listo ?x)
   (explicacion (nombre ?x) (texto ?t))
   =>
   (printout t "Explicación: " ?t crlf)
)

(defrule clasificar-animal-conocido
   ?a <- (animal-consulta (nombre ?x))
   (or (ave ?x) (mamifero ?x))
   =>
   (assert (animal ?x))
)

(defrule marcar-animal-listo
   (animal-consulta (nombre ?x))
   (animal ?x)
   (vuelo (nombre ?x) (vuela ?v) (certeza ?c))
   =>
   (assert (animal-listo ?x))
)

(defrule mostrar-respuesta
   ?r <- (animal-listo ?x)
   (vuelo (nombre ?x) (vuela ?v) (certeza ?c))
   =>
   (printout t crlf "El " ?x " " (if (eq ?v si) then "vuela" else "no vuela") " (" ?c ")" crlf)
   (retract ?r)
)




