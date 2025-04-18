
(defmodule MAIN
  (export ?ALL))

(defrule MAIN::hacer-loads
  (modulo MAIN)
  =>
  (load "PEDIR.clp")
)


(reset)

(run)



