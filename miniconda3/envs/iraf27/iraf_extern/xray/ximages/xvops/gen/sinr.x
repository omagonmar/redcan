#
# SIN -- Compute the sin of a vector (generic).

procedure sinr (a, b, npix)

real	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = sin (a[i])
	}
end
