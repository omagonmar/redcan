#
# COS -- Compute the cos of a vector (generic).

procedure cosi (a, b, npix)

int	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = cos (real (a[i]))
	}
end
