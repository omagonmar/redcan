#
# EXP -- Compute the exp of a vector (generic).

procedure expi (a, b, npix)

int	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = exp (real (a[i]))
	}
end
