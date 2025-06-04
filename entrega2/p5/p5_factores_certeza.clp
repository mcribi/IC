;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Definiciones
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftemplate Evidencia (slot nombre) (slot valor))
(deftemplate FactorCerteza (slot nombre) (slot valor) (slot fc))
(deftemplate Certeza (slot nombre) (slot fc))
(deftemplate Explicacion (slot hecho) (slot texto))


(deffacts hipotesis_posibles
  (hipotesis problema_bateria)
  (hipotesis problema_starter)
  (hipotesis problema_bujias)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Funciones auxiliares
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffunction encadenado (?fc_antecedente ?fc_regla)
   (if (> ?fc_antecedente 0)
      then (bind ?rv (* ?fc_antecedente ?fc_regla))
      else (bind ?rv 0))
   ?rv)

(deffunction combinacion (?fc1 ?fc2)
   (if (and (> ?fc1 0) (> ?fc2 0))
      then (bind ?rv (- (+ ?fc1 ?fc2) (* ?fc1 ?fc2)))
   else (if (and (< ?fc1 0) (< ?fc2 0))
      then (bind ?rv (+ (+ ?fc1 ?fc2) (* ?fc1 ?fc2)))
   else (bind ?rv (/ (+ ?fc1 ?fc2) (- 1 (min (abs ?fc1) (abs ?fc2))))))
   )
   ?rv)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Conversión de evidencias a factores de certeza
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule convertir-evidencia-a-fc
   (Evidencia (nombre ?e) (valor ?v))
   =>
   (assert (FactorCerteza (nombre ?e) (valor ?v) (fc 1)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Reglas del diagnóstico (R1 a R6)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; R1: SI motor_llega_gasolina Y gira_motor → problema_bujias 0.7
(defrule R1
   (FactorCerteza (nombre motor_llega_gasolina) (valor si) (fc ?f1))
   (FactorCerteza (nombre gira_motor) (valor si) (fc ?f2))
   (test (and (> ?f1 0) (> ?f2 0)))
   =>
   (assert (FactorCerteza (nombre problema_bujias) (valor si) (fc (encadenado (* ?f1 ?f2) 0.7))))
   (assert (Explicacion (hecho problema_bujias) (texto "Porque el motor recibe gasolina y gira, puede haber un problema con las bujías.")))
)

; R2: NO gira_motor → problema_starter 0.8
(defrule R2
   (FactorCerteza (nombre gira_motor) (valor no) (fc ?f))
   =>
   (assert (FactorCerteza (nombre problema_starter) (valor si) (fc (encadenado ?f 0.8))))
   (assert (Explicacion (hecho problema_starter) (texto "Porque el motor no gira, puede haber un problema con el starter.")))
)

; R3: NO encienden_las_luces → problema_bateria 0.9
(defrule R3
   (FactorCerteza (nombre encienden_las_luces) (valor no) (fc ?f))
   =>
   (assert (FactorCerteza (nombre problema_bateria) (valor si) (fc (encadenado ?f 0.9))))
   (assert (Explicacion (hecho problema_bateria) (texto "Porque no encienden las luces, puede haber un problema con la batería.")))
)

; R4: hay_gasolina_en_deposito → motor_llega_gasolina 0.9
(defrule R4
   (FactorCerteza (nombre hay_gasolina_en_deposito) (valor si) (fc ?f))
   =>
   (assert (FactorCerteza (nombre motor_llega_gasolina) (valor si) (fc (encadenado ?f 0.9))))
   (assert (Explicacion (hecho motor_llega_gasolina) (texto "Porque hay gasolina en el depósito, se supone que llega al motor.")))
)

; R5: hace_intentos_arrancar → problema_starter -0.6
(defrule R5
   (FactorCerteza (nombre hace_intentos_arrancar) (valor si) (fc ?f))
   =>
   (assert (FactorCerteza (nombre problema_starter) (valor si) (fc (encadenado ?f -0.6))))
   (assert (Explicacion (hecho problema_starter) (texto "Porque hace intentos de arrancar, es menos probable que sea el starter.")))
)

; R6: hace_intentos_arrancar → problema_bateria 0.5
(defrule R6
   (FactorCerteza (nombre hace_intentos_arrancar) (valor si) (fc ?f))
   =>
   (assert (FactorCerteza (nombre problema_bateria) (valor si) (fc (encadenado ?f 0.5))))
   (assert (Explicacion (hecho problema_bateria) (texto "Porque hace intentos de arrancar, puede haber un problema con la batería.")))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Combinación de deducciones repetidas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule combinar-deducciones
   (declare (salience 1))
   ?f1 <- (FactorCerteza (nombre ?h) (valor ?v) (fc ?fc1))
   ?f2 <- (FactorCerteza (nombre ?h) (valor ?v) (fc ?fc2))
   (test (neq ?fc1 ?fc2))
   =>
   (retract ?f1 ?f2)
   (assert (FactorCerteza (nombre ?h) (valor ?v) (fc (combinacion ?fc1 ?fc2))))
)

(defrule combinar-signos-opuestos
   (declare (salience 2))
   (FactorCerteza (nombre ?h) (valor si) (fc ?fc1))
   (FactorCerteza (nombre ?h) (valor no) (fc ?fc2))
   =>
   (assert (Certeza (nombre ?h) (fc (- ?fc1 ?fc2))))
)

(defrule marcar-diagnostico-listo
   (not (exists (and 
      (FactorCerteza (nombre ?h) (valor ?v) (fc ?f1))
      (FactorCerteza (nombre ?h) (valor ?v) (fc ?f2&:(neq ?f1 ?f2)))
   )))
   =>
   (assert (diagnostico listo)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Diagnóstico final: mostrar la hipótesis más probable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule mostrar-hipotesis-principal
   (diagnostico listo)
   (not (hipotesis-mostrada))
   (hipotesis ?hipo)
   ?h <- (FactorCerteza (nombre ?hipo) (valor si) (fc ?f))
   (not (and (hipotesis ?otra) (FactorCerteza (nombre ?otra) (valor si) (fc ?f2&:(> ?f2 ?f)))))
   =>
   (assert (hipotesis-mostrada))
   (printout t crlf "La hipótesis más probable es: " ?hipo ", con certeza " ?f crlf)
)


(defrule mostrar-explicaciones
   (Explicacion (hecho ?h) (texto ?t))
   =>
   (printout t "Explicación sobre " ?h ": " ?t crlf)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Entrada de usuario: pedir evidencias
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule pedir-evidencias
   =>
   (foreach ?evidencia (create$ hace_intentos_arrancar hay_gasolina_en_deposito gira_motor encienden_las_luces)
      (printout t crlf "¿Se da la evidencia: " ?evidencia "? (si/no): ")
      (bind ?r (read))
      (assert (Evidencia (nombre ?evidencia) (valor ?r)))
   )
)


