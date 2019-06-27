#
# ATAN -- Compute the atan of a vector (generic).

procedure atanr (a, b, npix)

real	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = atan (a[i])
	}
end
