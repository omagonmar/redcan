#
# COS -- Compute the cos of a vector (generic).

procedure cosl (a, b, npix)

long	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = cos (double (a[i]))
	}
end
