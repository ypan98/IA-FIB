(define (problem maximize_score_extension_3) (:domain Rover)
(:objects
	alm	          - almacen
	ase_A ase_B	  - asentamiento
	a b c d	  	  - personal
	x y z w		  - suministro
	R	  	      - rover
	aa bb cc dd	  - id
	priorA priorB priorC  - id
	)
(:init
	(petition_suministro	ase_A		aa)
	(petition_suministro	ase_A		bb)
	(petition_suministro	ase_A		cc)
	(petition_suministro	ase_A		dd)
	(= (cost_petition_suministro	ase_A		aa) 1)
	(= (cost_petition_suministro	ase_A		bb) 1)
	(= (cost_petition_suministro	ase_A		cc) 1)
	(= (cost_petition_suministro	ase_A		dd) 1)


	(petition_suministro	ase_B		aa)
	(petition_suministro	ase_B		bb)
	(petition_suministro	ase_B		cc)
	(petition_suministro	ase_B		dd)
	(= (cost_petition_suministro	ase_B		aa) 3)
	(= (cost_petition_suministro	ase_B		bb) 3)
	(= (cost_petition_suministro	ase_B		cc) 3)
	(= (cost_petition_suministro	ase_B		dd) 3)



	(at			x		alm)
	(at			y		alm)
	(at			z		alm)


	(at			R		alm)

	(= (number_personal			R) 		0)
	(= (number_suministro 		R)		0)
	(= (fuel		R)			30)
	(= (total_fuel_used)		0)
	(= (total_petition_score) 	0)

	(path 			alm			ase_A)
	(path 			ase_A 		ase_B)
	(path 			ase_B 		alm)

	)

(:goal
	(and
		(delivered x)
		(delivered y)
		(delivered z)
	)
)

(:metric maximize (total_petition_score))
)
