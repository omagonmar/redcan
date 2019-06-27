#
# NINT -- Compute the nint of a vector (generic).

procedure nintd (a, b, npix)

double	a[ARB]
int	b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = nint (real (a[i]))
	}
end
