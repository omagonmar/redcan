#
# SIN -- Compute the sin of a vector (generic).

procedure sini (a, b, npix)

int	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = sin (real (a[i]))
	}
end
