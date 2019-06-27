#
# TAN -- Compute the tan of a vector (generic).  If the tan
# is undefined (x = pi/2 or x = -pi/2) a user supplied function is called
# to compute the value.

include "math.h"

procedure tand (a, b, npix, errfcn)

double	a[ARB], b[ARB]
int	npix, i
extern	errfcn()
double	errfcn()
errchk	errfcn

begin
	do i = 1, npix {
		if ((a[i] == M_PI_2) || (a[i] == - M_PI_2))
		    b[i] = errfcn (a[i])
		else
		{
			b[i] = sin (a[i]) / cos (a[i])
		}
	}
end
