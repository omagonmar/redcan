#
# ATAN -- Compute the atan of a vector (generic).

procedure atand (a, b, npix)

double	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = atan (a[i])
	}
end
