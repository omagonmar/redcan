#
# ACOS -- Compute the acos of a vector (generic).

procedure acosd (a, b, npix)

double	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = acos (a[i])
	}
end
