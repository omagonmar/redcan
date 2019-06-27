#
# ASIN -- Compute the asin of a vector (generic).

procedure asinx (a, b, npix)

complex	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = asin (double (a[i]))
	}
end
