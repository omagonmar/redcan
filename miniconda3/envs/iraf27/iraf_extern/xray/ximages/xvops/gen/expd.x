#
# EXP -- Compute the exp of a vector (generic).

procedure expd (a, b, npix)

double	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = exp (a[i])
	}
end
