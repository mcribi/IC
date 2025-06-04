(deffacts base-datos
   (prob-cond2 covid si zona alto vacuna si 0.01)
   (prob-cond2 covid si zona alto vacuna no 0.85)
   (prob-cond2 covid si zona medio vacuna si 0.005)
   (prob-cond2 covid si zona medio vacuna no 0.55)
   (prob-cond2 covid si zona bajo vacuna si 0.001)
   (prob-cond2 covid si zona bajo vacuna no 0.2)
   (prob zona alto 0.2)
   (prob zona medio 0.6)
   (prob zona bajo 0.2)
   (prob vacuna si 0.8)
   (prob vacuna no 0.2)
   (probcond fiebre alta covid si 0.7)
   (probcond fiebre alta covid no 0.03)
   (probcond tos si covid si 0.99)
   (probcond tos si covid no 0.01)
)



(defrule inicio
   =>
   (printout t "Sistema experto para calcular la probabilidad de tener COVID." crlf)
   (assert (fase datos))
)

(defrule mostrar-simples
   (fase datos)
   (prob ?v ?val ?p)
   =>
   (printout t "P(" ?v "=" ?val ") = " ?p crlf)
)

(defrule mostrar-condicionales-pos
   (fase datos)
   (probcond ?sintoma ?valor covid si ?p)
   =>
   (printout t "P(" ?sintoma "=" ?valor " | covid=si) = " ?p crlf)
)

(defrule mostrar-condicionales-neg
   (fase datos)
   (probcond ?sintoma ?valor covid no ?p)
   =>
   (printout t "P(" ?sintoma "=" ?valor " | covid=no) = " ?p crlf)
)

(defrule mostrar-cond2
   (fase datos)
   (prob-cond2 ?x si ?c1 ?v1 ?c2 ?v2 ?p)
   =>
   (printout t "P(" ?x " | " ?c1 "=" ?v1 " y " ?c2 "=" ?v2 ") = " ?p crlf)
)

(defrule pasar-a-causas
   ?f <- (fase datos)
   =>
   (retract ?f)
   (assert (fase causas))
)

(defrule preguntar-zona
   (fase causas)
   =>
   (printout t "¿Zona de riesgo? (1=alto 2=medio 3=bajo 4=desconocido): ")
   (bind ?res (read))
   (if (= ?res 1) then (assert (valor zona alto))
      else (if (= ?res 2) then (assert (valor zona medio))
         else (if (= ?res 3) then (assert (valor zona bajo))
            else (assert (valor zona desconocido)))))
)

(defrule preguntar-vacuna
   (fase causas)
   =>
   (printout t "¿Vacunado? (1=si 2=no 3=desconocido): ")
   (bind ?res (read))
   (if (= ?res 1) then (assert (valor vacuna si))
      else (if (= ?res 2) then (assert (valor vacuna no))
         else (assert (valor vacuna desconocido))))
)

(defrule pasar-a-sintomas
   ?f <- (fase causas)
   (valor zona ?)
   (valor vacuna ?)
   =>
   (retract ?f)
   (assert (fase sintomas))
)

(defrule preguntar-fiebre
   (fase sintomas)
   =>
   (printout t "¿Tiene fiebre? (1=alta 2=desconocido): ")
   (bind ?res (read))
   (if (= ?res 1) then (assert (valor fiebre alta))
       else (assert (valor fiebre desconocido)))
)

(defrule preguntar-tos
   (fase sintomas)
   =>
   (printout t "¿Tiene tos? (1=si 2=desconocido): ")
   (bind ?res (read))
   (if (= ?res 1) then (assert (valor tos si))
       else (assert (valor tos desconocido)))
)

(defrule pasar-a-inferencia
   ?f <- (fase sintomas)
   (valor fiebre ?)
   (valor tos ?)
   =>
   (retract ?f)
   (assert (fase inferencia))
)

(defrule calcular-prior
   (fase inferencia)
   (valor zona ?z)
   (valor vacuna ?v)
   (prob-cond2 covid si zona ?z vacuna ?v ?pc)
   (prob zona ?z ?pz)
   (prob vacuna ?v ?pv)
   =>
   (bind ?pconj (* ?pc ?pz ?pv))
   (assert (prob-conjunta covid ?pconj))
   (bind ?pconj_neg (* (- 1 ?pc) ?pz ?pv))
   (assert (prob-conjunta-neg covid ?pconj_neg))
)

(defrule ajustar-por-fiebre
   (fase inferencia)
   (valor fiebre ?f)
   ?f1 <- (prob-conjunta covid ?p)
   (probcond fiebre ?f covid si ?pf)
   (not (ajustado covid si fiebre))
   =>
   (retract ?f1)
   (assert (prob-conjunta covid (* ?p ?pf)))
   (assert (ajustado covid si fiebre))
)


(defrule ajustar-por-tos
   (fase inferencia)
   (valor tos ?t)
   ?f2 <- (prob-conjunta covid ?p)
   (probcond tos ?t covid si ?pt)
   (not (ajustado covid si tos))
   =>
   (retract ?f2)
   (assert (prob-conjunta covid (* ?p ?pt)))
   (assert (ajustado covid si tos))
)


(defrule ajustar-neg-por-fiebre
   (fase inferencia)
   (valor fiebre ?f)
   ?f1 <- (prob-conjunta-neg covid ?p)
   (probcond fiebre ?f covid no ?pf)
   (not (ajustado covid no fiebre))
   =>
   (retract ?f1)
   (assert (prob-conjunta-neg covid (* ?p ?pf)))
   (assert (ajustado covid no fiebre))
)


(defrule ajustar-neg-por-tos
   (fase inferencia)
   (valor tos ?t)
   ?f2 <- (prob-conjunta-neg covid ?p)
   (probcond tos ?t covid no ?pt)
   (not (ajustado covid no tos))
   =>
   (retract ?f2)
   (assert (prob-conjunta-neg covid (* ?p ?pt)))
   (assert (ajustado covid no tos))
)


(defrule calcular-final
   ?f <- (fase inferencia)
   (prob-conjunta covid ?pc)
   (prob-conjunta-neg covid ?pnc)
   =>
   (bind ?normal (+ ?pc ?pnc))
   (bind ?posterior (/ ?pc ?normal))
   (printout t crlf ">>> Probabilidad final de COVID = " ?posterior crlf)
   (assert (resultado covid ?posterior))
   (retract ?f)
)

