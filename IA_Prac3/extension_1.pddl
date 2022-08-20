(define (problem roverprob01) (:domain Rover)
(:objects
	alm	          - almacen
	ase_A ase_B	  - asentamiento
	a b c d e	  - personal
	v w x y z	  - suministro
	R	  	  - rover
	aa bb cc dd ee	  - id
	)
(:init
	(petition_suministro	ase_A		aa)
	(petition_suministro	ase_A		bb)
	(petition_suministro	ase_A		cc)
	(petition_suministro	ase_A		dd)
	(petition_suministro	ase_A		ee)
	
	(petition_personal	ase_B		aa)
	(petition_personal	ase_B		bb)
	(petition_personal	ase_B		cc)
	(petition_personal	ase_B		dd)
	(petition_personal	ase_B		ee)

	(at			a		ase_A)
	(at			b		ase_A)
	(at			c		ase_A)
	(at			d		ase_A)
	(at			e		ase_A)
	
	(at			v		alm)
	(at			w		alm)
	(at			x		alm)
	(at			y		alm)
	(at			z		alm)

	(at			R		ase_B)

	(= (number_personal	R) 		0)
	(= (number_suministro 	R) 		0)

	(path 			ase_A 		ase_B)
	(path 			ase_A 		alm)
	)
(:goal
	(and
		(delivered a)
		(delivered b)
		(delivered c)
		(delivered d)
		(delivered e)

		(delivered v)
		(delivered w)	
		(delivered x)
		(delivered y)
		(delivered z)
	)
)
)