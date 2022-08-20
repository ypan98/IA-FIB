;;;---------------------------------------------------------------------------------------------------------------------------------
;;;----------                                   MODULOS                                                                                                
;;;---------------------------------------------------------------------------------------------------------------------------------

(defmodule MAIN (export ?ALL))

(defmodule datosPaciente
	(import MAIN ?ALL)
	(export ?ALL)
)
(defmodule iniPlanificacion
  (import MAIN ?ALL)
  (import datosPaciente ?ALL)
  (export ?ALL)
)
(defmodule generarPlanificacion
  (import MAIN ?ALL)
  (import datosPaciente ?ALL)
  (import iniPlanificacion ?ALL)
  (export ?ALL)
)
(defmodule mostrarPlanificacion
  (import MAIN ?ALL)
  (import datosPaciente ?ALL)
  (import iniPlanificacion ?ALL)
  (import generarPlanificacion ?ALL)
  (export ?ALL)
)

;;;---------------------------------------------------------------------------------------------------------------------------------
;;;----------                                   HECHOS INICIALES                                                                                              
;;;---------------------------------------------------------------------------------------------------------------------------------

(deffacts datosPaciente::preguntas
	(preguntarNombre)
	(preguntarEdad)
  (preguntarSexo)
	(preguntarCondicion)
	(preguntarAntecedentes)
        ;(calcularFCMax)
)


;;;---------------------------------------------------------------------------------------------------------------------------------
;;;----------                                   FUNCIONES                                                                                                 
;;;---------------------------------------------------------------------------------------------------------------------------------

(deffunction MAIN::input (?text)
  (format t ?text)
  (bind ?value (read))
  ?value
)
(deffunction MAIN::inputString (?text)
  (bind ?answer (input ?text))
  ?answer
)
(deffunction MAIN::inputInteger (?text)
  (bind ?answer (input ?text))
  (while (not (integerp ?answer)) do
    (bind ?answer (input ?text))
  )
  ?answer
)
(deffunction MAIN::inputChoice(?text $?values)
   (bind ?answer (input ?text))
   (while (not (member ?answer ?values)) do
        (bind ?answer (input ?text)))
   ?answer
)
(deffunction MAIN::inputMultiChoice(?text ?leave $?values)
  (bind ?choices (create$))
  (bind ?result (inputChoice ?text (insert$ $?values 1 ?leave)))
  (while (not(eq ?result ?leave) ) do
    (if (not (member ?result $?choices)) then (bind ?choices (insert$ $?choices 1 ?result)))
    (bind ?result (inputChoice ?text (insert$ $?values 1 ?leave)))
  )
  $?choices
)


(deffunction MAIN::beneficiosUtilizados (?sesiones)
    (bind ?beneficiosUtilizados (create$)) 
    (loop-for-count (?i 1 (length ?sesiones)) do
                  (bind ?sesion (nth$ ?i ?sesiones))
                  (bind ?esfuerzoSesion (send ?sesion get-esfuerzo))
                  (bind ?beneficios (send ?esfuerzoSesion get-beneficios))
                  (foreach ?beneficio ?beneficios
                    (if (not (member ?beneficio ?beneficiosUtilizados))
                     then (bind ?beneficiosUtilizados (insert$ ?beneficiosUtilizados 1 ?beneficio)))))
    ;(printout t ?beneficiosUtilizados)
    (return ?beneficiosUtilizados)
)

(deffunction MAIN::intersect (?A ?B)
    (bind $?result (create$))
    (foreach ?a ?A
      (foreach ?b ?B
         (if (and (eq ?a ?b) (not (member ?a $?result)))
            then (bind $?result (insert$ $?result 1 ?a)))
      )
    )
  $?result
)

(deffunction MAIN::difference (?A ?B)
    (bind $?result (create$ ?A))
    (bind $?C (intersect ?A ?B))
    (foreach ?c $?C
         (bind $?result (delete-member$ $?result ?c)))
   $?result
)

(deffunction MAIN::show ($?sesiones)
    (loop-for-count (?i 1 (length ?sesiones)) do
      (bind ?sesion (nth$ ?i $?sesiones))
      (bind ?calentamiento (send ?sesion get-calentamiento))
      (bind ?esfuerzo (send ?sesion get-esfuerzo))
      (bind ?recuperacion (send ?sesion get-recuperacion))
      (format t (str-cat "%n" "Sesion " ?i ":%n"))
      (format t (str-cat "Calentamiento: " (send ?calentamiento get-nombreActividad) " de " (send ?calentamiento get-duracion) " minutos " "%n"))
      (format t (str-cat "Actividad: " (send ?esfuerzo get-nombreActividad) " de " (send ?esfuerzo get-duracion) " minutos " "%n"))
      (format t (str-cat "Recuperacion: " (send ?recuperacion get-nombreActividad) " de " (send ?recuperacion get-duracion) " minutos " "%n"))
    )

)

;;;---------------------------------------------------------------------------------------------------------------------------------
;;;----------                                   REGLAS                                                                                              
;;;---------------------------------------------------------------------------------------------------------------------------------

;(defrule datosPaciente::calcularFCMax
;    (not (preguntarSexo))
;    (not (preguntarEdad))
;    ?pregunta <- (calcularFCMax)
;    ?paciente <- (object (is-a Paciente)(sexo ?sexo)(edad ?edad))
;    =>
;    (if (eq ?sexo M) then (modify-instance  ?paciente (FCMax (integer (- 214 (* 0.79 ?edad))))))
;    (if (eq ?sexo F) then (modify-instance  ?paciente (FCMax (integer (- 209 (* 0.72 ?edad))))))
;    (retract ?pregunta)
;)

(defrule MAIN::initialRule "Regla inicial"
    (declare (salience 10))
    =>
    (format t "%n----------------------------------------------------------------------------------------------------------------
----------                           SISTEMA DE RECOMENDACION DE ACTIVIDADES                                                                                              
----------------------------------------------------------------------------------------------------------------%n%n")
    (focus datosPaciente)
)


(defrule datosPaciente::nombre "Establece el nombre del paciente"
    ?pregunta <- (preguntarNombre)
    =>
    (bind ?nombre (inputString "Introducir nombre del paciente:%n"))
    (make-instance (gensym) of Paciente (nombrePaciente ?nombre))
    (retract ?pregunta)
)

(defrule datosPaciente::edad "Establece la edad del paciente"
    ?paciente <- (object (is-a Paciente))
    ?pregunta <- (preguntarEdad)
    =>
    (bind ?edad (inputInteger "Introducir la edad del paciente:%n"))
    (modify-instance ?paciente (edad ?edad))
    (retract ?pregunta)
)

(defrule datosPaciente::antecedentes "Establece antecedentes del paciente"
    ?paciente <- (object (is-a Paciente))
    ?pregunta <- (preguntarAntecedentes)
    =>
    (bind ?antecedente (inputMultiChoice "Introducir antecedentes del paciente:%n
  Caida/Displemia/Diabetes/Nefropatia/Hipertension/Neuropatia/Obesidad
  /EnfermedadPulmonal/Osteoporosis/Artritis/Fibrosis%n 
  Para acabar escribe: salir%n" salir Caida Displemia Diabetes Nefropatia Hipertension Neuropatia Obesidad EnfermedadPulmonal Osteoporosis Artritis Fibrosis))
    (modify-instance ?paciente (antecedentes ?antecedente))
    (retract ?pregunta)
)

(defrule datosPaciente::condicion "Establece la condicion del paciente"
    ?paciente <- (object (is-a Paciente))
    ?pregunta <- (preguntarCondicion)
    =>
    (bind ?condicion (inputChoice "Introducir condicion del paciente:%nmuyDescondicionado/desentrenado/algoEntrenado/entrenado%n" muyDescondicionado desentrenado algoEntrenado entrenado))
    (modify-instance ?paciente (condicion ?condicion))
    (retract ?pregunta)
)

(defrule datosPaciente::sexo "Establece sexo del paciente"
    ?paciente <- (object (is-a Paciente))
    ?pregunta <- (preguntarSexo)
    =>
    (bind ?sexo (inputChoice "Introducir sexo del paciente:%nM/F%n" M F))  
    (modify-instance ?paciente (sexo ?sexo))
    (retract ?pregunta)
)

(defrule datosPaciente::datosCompletos "Se han introducido todos los datos"
    (not (preguntarNombre))
    (not (preguntarEdad))
    (not (preguntarSexo))
    (not (preguntarCondicion))
    (not (preguntarAntecedentes))
    ;(not (calcularFCMax))
    =>
    (format t "Datos del paciente completos%n")     
    (focus iniPlanificacion)
)

(defrule iniPlanificacion::iniciarCondiciones "Inicializar Planificacion"
        (object (is-a Paciente) (condicion ?condicion)(antecedentes $?antecedentes)(edad ?edad))
        =>
        (bind ?minDuracion 15)
        (bind ?maxDuracion 60)
        (switch ?condicion
                (case muyDescondicionado then (bind ?zonasFCMax (create$ ZonaDeActividadModerada))(bind ?nDias 3))
                (case desentrenado then (bind ?zonasFCMax (create$ ZonaDeActividadModerada ZonaControlDePeso))(bind ?nDias 4))
                (case algoEntrenado then (bind ?zonasFCMax (create$ ZonaDeActividadModerada ZonaControlDePeso ZonaAerobica))(bind ?nDias 5))
                (case entrenado then (bind ?zonasFCMax (create$ ZonaDeActividadModerada ZonaControlDePeso ZonaAerobica ZonaUmbralAnaerobico))(bind ?nDias 7))
        )
        (bind ?beneficios (create$))
        (if (member Diabetes ?antecedentes) then
                (bind ?zonasFCMax (delete-member$ ?zonasFCMax ZonaUmbralAnaerobico ZonaDeActividadModerada))
                (if (not(member Resistencia $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Resistencia)))
                (if (not(member$ Fuerza $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Fuerza)))
        )
        (if (or (member Caida ?antecedentes) (>= ?edad 55)) then
                (if (not(member Flexibilidad $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Flexibilidad)))
                (if (not(member Coordinacion $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Coordinacion)))
                (if (not(member Agilidad $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Agilidad)))

        )
        (if (member Displemia ?antecedentes) then
                (bind ?minDuracion 40)
                (bind ?maxDuracion 60)
                (bind ?zonasFCMax (delete-member$ ?zonasFCMax ZonaAerobica ZonaUmbralAnaerobico))
        )
        (if (member Hipertension ?antecedentes) then
                (bind ?zonasFCMax (delete-member$ ?zonasFCMax ZonaAerobica ZonaUmbralAnaerobico)) 
        )
        (if (member Obesidad $?antecedentes) then
                (bind ?zonasFCMax (delete-member$ ?zonasFCMax ZonaAerobica ZonaUmbralAnaerobico))
                (if (not(member Resistencia $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Resistencia)))
                (if (not(member ControlPeso $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 ControlPeso)))
        )
        (if (member EnfermedadPulmonal $?antecedentes) then
                (bind ?zonasFCMax (delete-member$ ?zonasFCMax ZonaUmbralAnaerobico))
                (if (not(member Resistencia $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Resistencia)))
                (if (not(member Fuerza $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Fuerza)))
                (if (not(member Agilidad $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Agilidad)))
        )
        (if (member Osteoporosis $?antecedentes) then
                (bind ?minDuracion 50)
                (bind ?maxDuracion 60)
                (if (not(member Resistencia $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Resistencia)))
                (if (not(member Fuerza $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Fuerza)))
                (if (not(member Coordinacion $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Coordinacion)))
        )
        (if (member Artritis $?antecedentes) then
                (if (not(member Resistencia $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Resistencia)))
                (if (member Fuerza $?beneficios) then (delete-member$ ?beneficios Fuerza))
                (if (not(member Agilidad $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Agilidad)))
        )
        (if (member Fibrosis $?antecedentes) then
                (if (not(member Resistencia $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Resistencia)))
                (if (not(member Flexibilidad $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Flexibilidad)))
                (if (not(member Fuerza $?beneficios)) then (bind ?beneficios (insert$ ?beneficios 1 Fuerza)))
        )        

        ;que por lo menos haga actividades para prevenir cancer, y control de peso
        (if (eq (length$ ?beneficios) 0) then 
          (bind ?beneficios (insert$ ?beneficios 1 Resistencia))
          (bind ?beneficios (insert$ ?beneficios 1 ControlPeso))
        )
        (make-instance (gensym) of Planificacion (beneficios ?beneficios) (maxDuracion ?maxDuracion) (minDuracion ?minDuracion) (nDias ?nDias) (sesiones (create$)) (zonasFCMax ?zonasFCMax))
        (format t "Inicializacion de la planificacion completa%n")
        (format t "Generando solucion...%n")
        (focus generarPlanificacion)
)

(defrule generarPlanificacion::asignarSesionesConBeneficioDiferenteYMaximoSinRepetir
    (declare (salience 75))
	  ?paciente <- (object (is-a Paciente) (antecedentes $?antecedentesPaciente))
    ?planificacion <- (object (is-a Planificacion)(sesiones $?sesiones) (beneficios $?beneficiosPlan) (zonasFCMax $? ?zonaFCMaxPlan $?)(minDuracion ?minDuracion) (maxDuracion ?maxDuracion))
    ?faseEsfuerzo <- (object (is-a FaseEsfuerzo)
                           (partesCuerpo $?partesCuerpoEsfuerzo)
                           (antecedentesNoAptos $?antecedentesNoAptos&:(eq (length (intersect $?antecedentesNoAptos $?antecedentesPaciente)) 0))
                           (beneficios $?beneficiosSesion&:(>(length (intersect $?beneficiosSesion (difference $?beneficiosPlan (beneficiosUtilizados $?sesiones)))) 0))
                           (zonaFCMax ?zonaFCMaxPlan)
                           (duracion ?duracion&:(>= ?duracion ?minDuracion)&:(<= ?duracion ?maxDuracion)))
    (not (exists (object (is-a FaseEsfuerzo)
               (antecedentesNoAptos $?antecedentesNoAptos&:(eq (length (intersect $?antecedentesNoAptos $?antecedentesPaciente)) 0))
               (zonaFCMax ?zonaFCMaxPlan)
               (duracion ?duracion&:(>= ?duracion ?minDuracion)&:(<= ?duracion ?maxDuracion))
               (beneficios $?beneficios&:(> (length (intersect $?beneficios (difference $?beneficiosPlan (beneficiosUtilizados $?sesiones)))) (length (intersect $?beneficiosSesion (difference $?beneficiosPlan (beneficiosUtilizados $?sesiones)))))))))
  
    ?faseCalentamiento <- (object (is-a FaseCalentamiento)(partesCuerpo $?partesCuerpoCalentamiento)(nombreActividad ?nombreCalentamiento))
    (not (exists (object (is-a FaseCalentamiento)
                       (partesCuerpo $?partesCuerpo&:(> (length (intersect $?partesCuerpo $?partesCuerpoEsfuerzo)) (length (intersect $?partesCuerpoCalentamiento $?partesCuerpoEsfuerzo)))))))
  
    ?faseRecuperacion <- (object (is-a FaseRecuperacion)(partesCuerpo $?partesCuerpoRecuperacion)(nombreActividad ?nombreRecuperacion))
    (not (exists (object (is-a FaseCalentamiento)
                       (partesCuerpo $?partesCuerpo&:(> (length (intersect $?partesCuerpo $?partesCuerpoEsfuerzo)) (length (intersect $?partesCuerpoRecuperacion $?partesCuerpoEsfuerzo)))))))
    
    (not (exists (object (is-a Sesion) (esfuerzo ?x&:(eq ?x ?faseEsfuerzo)))))

    =>

    ;(format t "asignar sesion(1):%n")
    ;(format t (str-cat (send ?faseEsfuerzo get-nombreActividad) %n))

	  (bind ?sesion (make-instance (gensym) of Sesion (calentamiento ?faseCalentamiento)(esfuerzo ?faseEsfuerzo)(recuperacion ?faseRecuperacion)))
	  (bind ?sesiones (insert$ ?sesiones 1 ?sesion)) 
	  (modify-instance ?planificacion (sesiones ?sesiones))

)

(defrule generarPlanificacion::asignarSesionesConBeneficioMaximoSinRepetir
    (declare (salience 50))
	  ?paciente <- (object (is-a Paciente) (antecedentes $?antecedentesPaciente))
    ?planificacion <- (object (is-a Planificacion)(sesiones $?sesiones) (beneficios $?beneficiosPlan) (zonasFCMax $? ?zonaFCMaxPlan $?)(minDuracion ?minDuracion) (maxDuracion ?maxDuracion))
    ?faseEsfuerzo <- (object (is-a FaseEsfuerzo)
                           (partesCuerpo $?partesCuerpoEsfuerzo)
                           (antecedentesNoAptos $?antecedentesNoAptos&:(eq (length (intersect $?antecedentesNoAptos $?antecedentesPaciente)) 0))
                           (beneficios $?beneficiosSesion)
                           (zonaFCMax ?zonaFCMaxPlan)
                           (duracion ?duracion&:(>= ?duracion ?minDuracion)&:(<= ?duracion ?maxDuracion)))
    (not (exists (object (is-a FaseEsfuerzo)
               (antecedentesNoAptos $?antecedentesNoAptos&:(eq (length (intersect $?antecedentesNoAptos $?antecedentesPaciente)) 0))
               (zonaFCMax ?zonaFCMaxPlan)
               (duracion ?duracion&:(>= ?duracion ?minDuracion)&:(<= ?duracion ?maxDuracion))
               (beneficios $?beneficios&:(> (length (intersect $?beneficios $?beneficiosPlan)) (length (intersect $?beneficiosSesion $?beneficiosPlan )))))))             
  
    ?faseCalentamiento <- (object (is-a FaseCalentamiento)(partesCuerpo $?partesCuerpoCalentamiento))
    (not (exists (object (is-a FaseCalentamiento)
                       (partesCuerpo $?partesCuerpo&:(> (length (intersect $?partesCuerpo $?partesCuerpoEsfuerzo)) (length (intersect $?partesCuerpoCalentamiento $?partesCuerpoEsfuerzo)))))))
  
    ?faseRecuperacion <- (object (is-a FaseRecuperacion)(partesCuerpo $?partesCuerpoRecuperacion))
    (not (exists (object (is-a FaseCalentamiento)
                       (partesCuerpo $?partesCuerpo&:(> (length (intersect $?partesCuerpo $?partesCuerpoEsfuerzo)) (length (intersect $?partesCuerpoRecuperacion $?partesCuerpoEsfuerzo)))))))
  
    (not (exists  (object (is-a Sesion) (esfuerzo ?x&:(eq ?x ?faseEsfuerzo)))))


    =>

    ;(format t "asignar sesion(2):%n")
    ;(format t (str-cat (send ?faseEsfuerzo get-nombreActividad) %n))

	  (bind ?sesion (make-instance (gensym) of Sesion (calentamiento ?faseCalentamiento)(esfuerzo ?faseEsfuerzo)(recuperacion ?faseRecuperacion)))
	  (bind ?sesiones (insert$ ?sesiones 1 ?sesion)) 
	  (modify-instance ?planificacion (sesiones ?sesiones))

)

(defrule generarPlanificacion::asignarSesionesConBeneficioMaximoRepitiendo
    (declare (salience 25))
	  ?paciente <- (object (is-a Paciente) (antecedentes $?antecedentesPaciente))
	  ?planificacion <- (object (is-a Planificacion)(sesiones $?sesiones) (beneficios $?beneficiosPlan) (zonasFCMax $? ?zonaFCMaxPlan $?)(minDuracion ?minDuracion) (maxDuracion ?maxDuracion))
    ?faseEsfuerzo <- (object (is-a FaseEsfuerzo)
                           (partesCuerpo $?partesCuerpoEsfuerzo)
                           (antecedentesNoAptos $?antecedentesNoAptos&:(eq (length (intersect $?antecedentesNoAptos $?antecedentesPaciente)) 0))
                           (beneficios $?beneficiosSesion)
                           (zonaFCMax ?zonaFCMaxPlan)
                           (duracion ?duracion&:(>= ?duracion ?minDuracion)&:(<= ?duracion ?maxDuracion)))
    (not (exists (object (is-a FaseEsfuerzo)
               (antecedentesNoAptos $?antecedentesNoAptos&:(eq (length (intersect $?antecedentesNoAptos $?antecedentesPaciente)) 0))
               (zonaFCMax ?zonaFCMaxPlan)
               (duracion ?duracion&:(>= ?duracion ?minDuracion)&:(<= ?duracion ?maxDuracion))
               (beneficios $?beneficios&:(> (length (intersect $?beneficios $?beneficiosPlan)) (length (intersect $?beneficiosSesion $?beneficiosPlan )))))))             
    
    ?faseCalentamiento <- (object (is-a FaseCalentamiento)(partesCuerpo $?partesCuerpoCalentamiento))
    (not (exists (object (is-a FaseCalentamiento)
                       (partesCuerpo $?partesCuerpo&:(> (length (intersect $?partesCuerpo $?partesCuerpoEsfuerzo)) (length (intersect $?partesCuerpoCalentamiento $?partesCuerpoEsfuerzo)))))))
  
    ?faseRecuperacion <- (object (is-a FaseRecuperacion)(partesCuerpo $?partesCuerpoRecuperacion))
    (not (exists (object (is-a FaseCalentamiento)
                       (partesCuerpo $?partesCuerpo&:(> (length (intersect $?partesCuerpo $?partesCuerpoEsfuerzo)) (length (intersect $?partesCuerpoRecuperacion $?partesCuerpoEsfuerzo)))))))
    

    =>
    (bind ?sesion (make-instance (gensym) of Sesion (calentamiento ?faseCalentamiento)(esfuerzo ?faseEsfuerzo)(recuperacion ?faseRecuperacion)))
	  (bind ?sesiones (insert$ ?sesiones 1 ?sesion)) 
	  (modify-instance ?planificacion (sesiones ?sesiones))
)


(defrule generarPlanificacion::acabarPlanificacion "Acaba la planificacion"
        (declare (salience 100))
        (object (is-a Planificacion) (nDias ?nDias) (sesiones $?sesiones&:(>= (length$ ?sesiones) ?nDias)))  
        =>
        (focus mostrarPlanificacion)
)

(defrule mostrarPlanificacion::mostrar "Mostrar la planificacion al paciente"
        (object (is-a Planificacion)(sesiones $?sesiones))
        =>
        (show $?sesiones)
        (format t "%n")
        (halt)
)
