#
# LOR -- Vector logical or.  C[i], type INT, is set to 1 if A[i] or
# B[i] are non-zero, else C[i] is set to zero.

procedure lori (a, b, c, npix)

int	a[ARB], b[ARB]
int	c[ARB]
int	npix
int	i

begin
	do i = 1, npix
		if ( (a[i] !=0) || (b[i] !=0))
		    c[i] = 1
		else
		    c[i] = 0
end
