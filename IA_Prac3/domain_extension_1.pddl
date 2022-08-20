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
)


	
(:action add_personal
 :parameters (?p - personal ?r - rover ?y - asentamiento)
 :precondition (and 
    (not (delivered ?p))
    (at ?r ?y) 
    (at ?p ?y) 
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
    (= (number_suministro ?r) 0)
    (= (number_personal ?r) 0))
 :effect (and (contains ?r ?s) (not(at ?s ?y))(increase (number_suministro ?r) 1))
)


(:action move_to_lugar
 :parameters(?origin - (either asentamiento almacen) ?destiny - (either asentamiento almacen) ?r - rover)
 :precondition (and (
	 at ?r ?origin) 
	 (not (at ?r ?destiny))
	(or (path ?origin ?destiny) (path ?destiny ?origin))
 )
 :effect (and (not (at ?r ?origin))(at ?r ?destiny))
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
	      )
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
	     )
)
)
