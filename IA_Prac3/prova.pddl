(define (domain Rover)
(:requirements :adl)
(:types
	asentamiento almacen suministro personal rover id)

(:predicates
 (petition_personal		?y - asentamiento  ?id - id)
 (petition_suministro		?y - asentamiento  ?id - id)
 (at 	     ?o - (either rover suministro personal) 	?y - (either asentamiento almacen))
 (delivered   ?p - (either suministro personal))
 (contains    ?r - rover		?m - (either suministro personal))
 (path 	     ?x - (either asentamiento almacen)		?y - (either asentamiento almacen))
)
(:functions
 (number_personal	 ?r - rover)
 (number_suministro 	 ?r - rover)
 (fuel	      	 	 ?r - rover)
 (total_fuel_used)
 (total_petition_score)
 (cost_petition_suministro 	?y - asentamiento ?id - id)
 (cost_petition_personal 		?y - asentamiento ?id - id)
)




(:action move_drop_personal
 :parameters(?origin - (either asentamiento almacen) ?destiny - asentamiento ?r - rover ?p - personal ?id - id)
 :precondition (and 
              (at ?r ?origin) 
              (not (at ?r ?destiny))
              (> (fuel ?r) 0)
              (or (path ?origin ?destiny) (path ?destiny ?origin))
              (contains ?r ?p)
              (petition_personal ?destiny ?id)
              )
 :effect (and 
            (not (at ?r ?origin))
            (at ?r ?destiny)
            (delivered ?p)
            (increase (total_fuel_used) 1)
            (decrease (fuel ?r) 1)
            (not (contains ?r ?p))
	     (not (petition_personal ?destiny ?id))
            (increase (total_petition_score)
                (cost_petition_personal ?destiny ?id))
	      )
)

(:action move_drop_suministro
 :parameters(?origin - (either asentamiento almacen) ?destiny - asentamiento ?r - rover ?s - suministro ?id - id)
 :precondition (and 
                (contains ?r ?s)
                (at ?r ?origin)
                (not (at ?r ?destiny))
                (or (path ?origin ?destiny) (path ?destiny ?origin))
                (petition_suministro ?destiny ?id)
                )
 :effect (and 
            (not (at ?r ?origin))
            (at ?r ?destiny)
            (delivered ?s)
            (increase (total_fuel_used) 1)
            (decrease (fuel ?r) 1)
            (not (contains ?r ?s))
	        (not (petition_suministro ?destiny ?id))
            (increase (total_petition_score) 
                (cost_petition_suministro ?destiny ?id))
 ))





(:action add_personal
 :parameters (?p - personal ?r - rover ?y - asentamiento)
 :precondition (and 
    (not (delivered ?p))
    (at ?r ?y) 
    (at ?p ?y) 
    (not(contains ?r ?p))
    (= (number_suministro ?r) 0)
    (< (number_personal ?r) 2))
 :effect (and (contains ?r ?p) (not(at ?p ?y))(increase (number_personal ?r) 1))
)

(:action add_suministro
 :parameters (?s - suministro ?r - rover ?y - almacen) 
 :precondition (and 
    (not (delivered ?s))
    (at ?r ?y) 
    (at ?s ?y) 
    (not(contains ?r ?s))
    (not (delivered ?s))
    (= (number_suministro ?r) 0)
    (= (number_personal ?r) 0))
 :effect (and (contains ?r ?s) (not(at ?s ?y))(increase (number_suministro ?r) 1))
)


(:action move_to_lugar
 :parameters(?origin - (either asentamiento almacen) ?destiny - (either asentamiento almacen) ?r - rover)
 :precondition (and 
 	(at ?r ?origin) 
	(not (at ?r ?destiny))
	(> (fuel ?r) 0)
	(or (path ?origin ?destiny) (path ?destiny ?origin)))
 :effect (and 
 	(not (at ?r ?origin))
	(at ?r ?destiny)
	(increase (total_fuel_used) 1)
	(decrease (fuel ?r) 1))
)

(:action drop_personal
 :parameters (?r - rover ?p - personal ?y - asentamiento ?id - id)
 :precondition (and
		(not (delivered ?p))
		(at ?r ?y)
		(contains ?r ?p)
		(petition_personal ?y ?id)
	       )
 :effect (and (delivered ?p)
	      (not (contains ?r ?p))
	      (not (petition_personal ?y ?id))
	      (decrease (number_personal ?r) 1)
	      (increase (total_petition_score) (cost_petition_personal ?y ?id)))
 )
(:action drop_suministro
 :parameters (?r - rover ?s - suministro ?y - asentamiento ?id - id)
 :precondition (and
		(not (delivered ?s))
		(at ?r ?y)
		(contains ?r ?s)
		(petition_suministro ?y ?id)
	       )
 :effect (and (delivered ?s)
	      (not (contains ?r ?s))
	      (not (petition_suministro ?y ?id))
	      (decrease (number_suministro ?r) 1)
	      (increase (total_petition_score) (cost_petition_suministro ?y ?id)))
)
)
