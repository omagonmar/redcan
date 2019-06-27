#
# ASIN -- Compute the asin of a vector (generic).

procedure asind (a, b, npix)

double	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = asin (a[i])
	}
end
