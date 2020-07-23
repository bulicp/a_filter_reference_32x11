## Little help

Top module: a_filter_approx

a_filter_approx.v
	fos_exact_v4.v //Fos sekcija 
		rad4_reference3 // Egzaktni rad4 množač sa 6 parcijalna produkta
	fos_exact_v3.v
		rad4_reference2 // Egzaktni rad4 množač sa 6 parcijalna produkta
	fos_exact_v2.v
		rad4_reference1 // Egzaktni rad4 množač sa 6 parcijalna produkta
	fos_exact_v2.v
		rad4_reference1 // Egzaktni rad4 množač sa 6 parcijalna produkta
	fos_exact_v1.v
		rad4_reference // Egzaktni rad4 množač sa 6 parcijalna produkta
	fos_exact_v1.v
		rad4_reference // Egzaktni rad4 množač sa 6 parcijalna produkta
	
rad4_reference, rad4_reference1, rad4_reference2 i rad4_reference3 su isti množači. Zaradi simulacije sam morao promjeniti imena. 

### Filter types: 
- Type 1: rad4_odd_trunc.v 
  - Zeros: -1 and Pole: -0.2031(-208)
- Type 2: rad4_exact.v 
  - Zeros: -1 and Pole: -0.9971(-1021)
- Type 3: rad4_odd_trunc.v 
  - Zeros: 0.2998 (307) Pole: -0.9082 (-930)
- Type 4: rad4_odd.v
  - Zeros: 0 Pole: -0.9863 (-1010)
  - 
