#
# ACOS -- Compute the acos of a vector (generic).

procedure acosl (a, b, npix)

long	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = acos (double (a[i]))
	}
end
