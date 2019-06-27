#
# NINT -- Compute the nint of a vector (generic).

procedure nintl (a, b, npix)

long	a[ARB]
int	b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = nint (real (a[i]))
	}
end
