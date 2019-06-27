#
# LNOT -- Vector logical not.  C[i], type INT, is set to 1 if A[i] is zero,
# else C[i] is set to zero.

procedure lnotl (a, b, npix)

long	a[ARB]
int	b[ARB]
int	npix
int	i

begin
	do i = 1, npix
		if ( a[i] ==0 )
		    b[i] = 1
		else
		    b[i] = 0
end
