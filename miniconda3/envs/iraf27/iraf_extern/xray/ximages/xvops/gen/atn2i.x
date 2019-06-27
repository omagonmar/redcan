#
# ATN2 -- Compute the atan2 of 2 vectors containing x in first and y in
# second (generic).

procedure atn2i (a, b, c, npix)

int	a[ARB], b[ARB] c[ARB]
int	npix, i

begin
	do i = 1, npix {
			c[i] = atan2 (real (b[i]), real (a[i]))
	}
end
