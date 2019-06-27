#
# ACOS -- Compute the acos of a vector (generic).

procedure acoss (a, b, npix)

short	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = acos (real (a[i]))
	}
end
