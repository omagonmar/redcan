#
# ATAN -- Compute the atan of a vector (generic).

procedure atanx (a, b, npix)

complex	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = atan (double (a[i]))
	}
end
