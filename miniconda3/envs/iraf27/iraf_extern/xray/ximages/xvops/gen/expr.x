#
# EXP -- Compute the exp of a vector (generic).

procedure expr (a, b, npix)

real	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = exp (a[i])
	}
end
