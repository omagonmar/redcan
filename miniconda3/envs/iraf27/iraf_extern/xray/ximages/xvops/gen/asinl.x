#
# ASIN -- Compute the asin of a vector (generic).

procedure asinl (a, b, npix)

long	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = asin (double (a[i]))
	}
end
