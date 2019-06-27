#
# ASIN -- Compute the asin of a vector (generic).

procedure asinr (a, b, npix)

real	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = asin (a[i])
	}
end
