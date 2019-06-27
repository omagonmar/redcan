#
# ATAN -- Compute the atan of a vector (generic).

procedure atans (a, b, npix)

short	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = atan (real (a[i]))
	}
end
