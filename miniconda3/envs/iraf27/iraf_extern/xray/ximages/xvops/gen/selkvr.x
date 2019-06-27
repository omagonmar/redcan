#
# SELKV -- Vector select element.  The output vector is formed by taking
# successive pixels from either of the two input vectors, based on the value
# of the integer (boolean) selection vectors.  Used to implement vector
# conditional expressions.

#
#	this set of routines takes a constant as selection 1
#	and a vector as selection 2
#
procedure selkvr (a, b, c, sel, npix)

real	a, b[ARB], c[ARB]
int	sel[ARB]			# IF sel[i] THEN a[i] ELSE b[i]
int	npix
int	i

begin
	do i = 1, npix
	    if (sel[i] != 0)
		c[i] = a
	    else
		c[i] = b[i]
end
