#$Header: /home/pros/xray/lib/regions/RCS/rgsymmetry.x,v 11.0 1997/11/06 16:19:24 prosb Exp $
#$Log: rgsymmetry.x,v $
#Revision 11.0  1997/11/06 16:19:24  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:51  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:14  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:37  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:30  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:45  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:50  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:37  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:30  pros
#General Release 1.0
#

#  rgsymmetry.x
#
#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_enter_sym()
#  rg_exit_sym()


include <pmset.h>
include "rgset.h"


########################################################################
#
# rg_enter_sym(), rg_exit_sym()
#
# Pixel assignment of edges for symmetric shapes (circle, annuli, ellipse)
#
# Pixels which center is inside the edge are included.  (The same applies
#   to PIXINCL (see rgset.h) used by non-radially-symmetric shapes).
# When a pixel center is exactly on the edge, the pixel assignment rule is:
#   > the outer edge of a symmetric shape does not include such pixels
#   > the inner edge of a symmetric shape (annulus) includes such pixels
# In this way, an annulus with radius from 0 to 1, centered exactly on
#   a pixel, includes the pixel on which it is centerd, but none of its
#   neighbors.
#
# These rules ensure that when defining concentric shapes, no pixels are
#   ommitted between concentric regions and no pixels are claimed by two
#   regions.  When applied to small symmetric shapes, the shape is less
#   likely to be skewed, as would happen with non-radially-symmetric rules.
# These rules differ from the rules for box-like shapes, which are more
#   likely to be positioned adjacent to one another.  Radially-ymmetric
#   shapes placed side by side whose real edges touch at a pixel center
#   will leave that pixel unclaimed.
#
# Call rg_enter_sym() for crossing an edge while entering a radially-
#   symmetric region's outer edge, or leaving one's inner edge
#
# Call rg_exit_sym() for crossing an edge while leaving a radially-
#   symmetric region's outer edge, or entering one's inner edge
#
# Input: real coordinate (x or y)
# Output: pixel coordinate appropriate for that real coordinate
#
########################################################################

int procedure rg_exit_sym ( val )

real	val	# i: real coordinate
int	ival	# o: corresponding integer value

begin
	ival = val
	if (real(ival) == val)
	    return (ival)
	else
	    return (ival + 1)
end


int procedure rg_enter_sym ( val )

real	val	# i: real coordinate
int	ival	# o: corresponding integer value

begin
	ival = val
	return (ival + 1)
end
