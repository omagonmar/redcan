#
# SIN -- Compute the sin of a vector (generic).

procedure sinl (a, b, npix)

long	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = sin (double (a[i]))
	}
end
