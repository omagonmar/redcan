#
# COS -- Compute the cos of a vector (generic).

procedure cosd (a, b, npix)

double	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = cos (a[i])
	}
end
