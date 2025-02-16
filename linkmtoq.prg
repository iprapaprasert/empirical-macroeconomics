subroutine linkmtoq(String %series, String %convert)
	'''
	' High to low frequency conversion (m -> q)
	' usually %convert should be:
	' - "a" (average of the nonmissing observation)
	' - "ns" (sum, propagating missing)
	'''
	copy(c={%convert}) m\{%series} q\
endsub

