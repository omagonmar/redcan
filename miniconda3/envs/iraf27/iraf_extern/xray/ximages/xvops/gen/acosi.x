#
# ACOS -- Compute the acos of a vector (generic).

procedure acosi (a, b, npix)

int	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = acos (real (a[i]))
	}
end
