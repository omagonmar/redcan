# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/chkres.x,v 11.0 1997/11/06 16:32:02 prosb Exp $
# $Log: chkres.x,v $
# Revision 11.0  1997/11/06 16:32:02  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:47  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:32  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:19  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:37:22  mo
#MC	7/2/93		Remove redundant == TRUE (RS6000 port)
#
#Revision 6.0  93/05/24  16:14:17  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:38  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  10:49:56  janet
#Initial revision
#
#
# Module:       chkres.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      check status of key vars to determine if we
#		have usable results
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include "bepos.h"

# ---------------------------------------------------------------------------
procedure chkres (cnts_in_bin, out_of_bnds, e_bepos_xy, e_rough_xy, 
	          refine_limit, error_code, reason_for_failure, good_position)

int	cnts_in_bin 		# i: # of phototns in bin circle

bool	out_of_bnds 		# i: indicates if outside of array bnds

real	e_bepos_xy[ARB] 	# i: best pos in element coords
real	e_rough_xy[ARB] 	# i: rough pos in element coords
real	refine_limit 		# i: refine limit

int	error_code 		# i/o: error indicator
int	reason_for_failure[ARB] # i/o: debug failure array

bool	good_position 		# l: indicates if the position passes


begin

      good_position = TRUE

#   check if there is an error condition present and set code appropriately
#   - else we have a good position to continue with.
      if ( out_of_bnds ) {
         reason_for_failure[oob] = reason_for_failure[oob] + 1
         good_position = FALSE
         error_code = oob

      } else if ( cnts_in_bin == 0 ) {
         reason_for_failure[nc] = reason_for_failure[nc] + 1
         good_position = FALSE
         error_code = nc

      } else if ( ((e_bepos_xy[x] - e_rough_xy[x]) > refine_limit) ||
                  ((e_bepos_xy[y] - e_rough_xy[y]) > refine_limit)) {
         reason_for_failure[rl] = reason_for_failure[rl] + 1
         good_position = FALSE
         error_code = rl

      }

end
