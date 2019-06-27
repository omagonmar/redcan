#
# SIN -- Compute the sin of a vector (generic).

procedure sins (a, b, npix)

short	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = sin (real (a[i]))
	}
end
