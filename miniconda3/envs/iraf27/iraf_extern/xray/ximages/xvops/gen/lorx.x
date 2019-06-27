#
# LOR -- Vector logical or.  C[i], type INT, is set to 1 if A[i] or
# B[i] are non-zero, else C[i] is set to zero.

procedure lorx (a, b, c, npix)

complex	a[ARB], b[ARB]
int	c[ARB]
int	npix
int	i

begin
	do i = 1, npix
		if ( ((real(a[i]) !=0) && (aimag(a[i]) !=0)) ||
		     ((real(b[i]) !=0) && (aimag(b[i]) !=0)) )
		    c[i] = 1
		else
		    c[i] = 0
end
