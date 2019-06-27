#
# COS -- Compute the cos of a vector (generic).

procedure coss (a, b, npix)

short	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = cos (real (a[i]))
	}
end
