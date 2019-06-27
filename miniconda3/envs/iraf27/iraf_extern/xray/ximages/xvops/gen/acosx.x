#
# ACOS -- Compute the acos of a vector (generic).

procedure acosx (a, b, npix)

complex	a[ARB], b[ARB]
int	npix, i

begin
	do i = 1, npix {
			b[i] = acos (double (a[i]))
	}
end
