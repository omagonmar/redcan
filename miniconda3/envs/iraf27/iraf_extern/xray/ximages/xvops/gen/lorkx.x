#
# LORK -- Vector logical or.  C[i], type INT, is set to 1 if A[i] or
# B are non-zero, else C[i] is set to zero.

procedure lorkx (a, b, c, npix)

complex	a[ARB], b
int	c[ARB]
int	npix
int	i

begin
	do i = 1, npix
		if ( ((real(a[i]) !=0) && (aimag(a[i]) !=0)) ||
		     ((real(b)    !=0) && (aimag(b)    !=0)) )
		    c[i] = 1
		else
		    c[i] = 0
end
