# include <math.h>
# include <float.h>
# include <stdio.h>
# include <string.h>
# include <xtables.h>	/* For the IRAF_INDEF macros */
# include "pedsky.h"
# define  CGOLD	0.3819660	/* Num. Rec. golden section search ratio */
# define  ZEPS	1.0e-10		/* Num. Rec. zero min. fractional accuracy */
# define  SHFT(a,b,c,d)	(a)=(b);(b)=(c);(c)=(d);
# define  SIGN(a,b)	((b) >= 0.0 ? fabs(a) : -fabs(a))
# define  INDEF		(float)IRAF_INDEFR
/*   FINDSKY_ITER  --  Find best sky value for a NICMOS image.
/* Arguments:

###  Proprietary source code removed  ###
