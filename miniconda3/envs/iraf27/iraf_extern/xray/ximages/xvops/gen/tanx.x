#
# TAN -- Compute the tan of a vector (generic).  If the tan
# is undefined (x = pi/2 or x = -pi/2) a user supplied function is called
# to compute the value.

include "math.h"

procedure tanx (a, b, npix, errfcn)

complex	a[ARB], b[ARB]
int	npix, i
extern	errfcn()
complex	errfcn()
errchk	errfcn

begin
	do i = 1, npix {
		{
			b[i] = sin (a[i]) / cos (a[i])
		}
	}
end
