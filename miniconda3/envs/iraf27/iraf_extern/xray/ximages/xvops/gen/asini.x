#
# ASIN -- Compute the asin of a vector (generic).

procedure asini (a, b, npix)

int	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = asin (real (a[i]))
	}
end
