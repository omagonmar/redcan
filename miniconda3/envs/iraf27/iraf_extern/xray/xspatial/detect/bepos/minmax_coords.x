# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/minmax_coords.x,v 11.0 1997/11/06 16:32:06 prosb Exp $
# $Log: minmax_coords.x,v $
# Revision 11.0  1997/11/06 16:32:06  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:57  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:37  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:37  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:56  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  11:09:08  janet
#Initial revision
#
#
# Module:       .x
# Project:      PROS -- ROSAT RSDC
# Purpose: 	calculate the min and max, x and y array elements of bin size
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include "bepos.h" 

define   min 1
define   max 2

# ---------------------------------------------------------------------------
procedure minmax_coords(bin_size,windo_dim, trial_xy, bin_coords, out_of_bnds)

int	bin_size[ARB]  		# i: size of a bin in elements
int	windo_dim 		# i: dimension of array

real	trial_xy[ARB]		# i: trial position

int	bin_coords[2,ARB]	# o: calc coords in elements
bool    out_of_bnds 		# o: flag indicates out of array bnds

begin

      out_of_bnds = FALSE

#   determine src_windo min and max coordinates of bin around position
      bin_coords[x,min] = trial_xy[x] - bin_size[x]

      bin_coords[x,max] = trial_xy[x] + bin_size[x]

      bin_coords[y,min] = trial_xy[y] - bin_size[y]

      bin_coords[y,max] = trial_xy[y] + bin_size[y]

#   flag if coordinates are outside of bin boundaries
      if ((bin_coords[x,min] <= 0)        ||
          (bin_coords[x,max] > windo_dim) ||
          (bin_coords[y,min] <= 0)        ||
          (bin_coords[y,max] > windo_dim))  { 

         out_of_bnds = TRUE
      }

end
