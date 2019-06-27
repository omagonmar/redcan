#
# EXP -- Compute the exp of a vector (generic).

procedure expl (a, b, npix)

long	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = exp (double (a[i]))
	}
end
