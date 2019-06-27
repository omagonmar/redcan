#
# EXP -- Compute the exp of a vector (generic).

procedure exps (a, b, npix)

short	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = exp (real (a[i]))
	}
end
