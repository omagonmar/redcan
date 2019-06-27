#
# SIN -- Compute the sin of a vector (generic).

procedure sind (a, b, npix)

double	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = sin (a[i])
	}
end
