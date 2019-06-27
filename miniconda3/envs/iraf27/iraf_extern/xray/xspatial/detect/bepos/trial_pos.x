# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/trial_pos.x,v 11.0 1997/11/06 16:32:10 prosb Exp $
# $Log: trial_pos.x,v $
# Revision 11.0  1997/11/06 16:32:10  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:51:09  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:13:13  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:33:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:18:34  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:32:10  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  11:12:18  janet
#Initial revision
#
#
# Module:       trial_pos.x
# Project:      PROS -- ROSAT RSDC
# Purpose: 	move the next trial position in the direction 
#               currently being tested
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include "bepos.h"

# -------------------------------------------------------------------------

procedure trial_pos (direction, pixel_increment, trial_xy)

int	direction 		# i: pos or neg x or y dir
real	pixel_increment 	# i: pixel zoom

real	trial_xy[ARB]		# o: trial position


begin

#   positiive x direction
      if ( direction == pos_x ) {
         trial_xy[x] = trial_xy[x] + pixel_increment

#   negative x direction
      } else if ( direction == neg_x ) {
         trial_xy[x] = trial_xy[x] - pixel_increment

#   positive y direction
      } else if ( direction == pos_y ) {
         trial_xy[y] = trial_xy[y] + pixel_increment

#   negative y direction
      } else if ( direction == neg_y ) {
         trial_xy[y] = trial_xy[y] - pixel_increment

      }

end
