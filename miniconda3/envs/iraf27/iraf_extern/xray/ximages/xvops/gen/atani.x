#
# ATAN -- Compute the atan of a vector (generic).

procedure atani (a, b, npix)

int	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = atan (real (a[i]))
	}
end
