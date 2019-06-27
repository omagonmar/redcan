# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/calc_conf.x,v 11.0 1997/11/06 16:31:53 prosb Exp $
# $Log: calc_conf.x,v $
# Revision 11.0  1997/11/06 16:31:53  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:34  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:57  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:13:51  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:16  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  09:05:15  janet
#Initial revision
#
#
#***********************************************************************
#
# author : jd                date: 27-feb-1987 08:55
#                            converted to SPP 7/92
#
#***********************************************************************

include "bepos.h"
  
# ------------------------------------------------------------------------- 
#
# calculate the quadrant fraction which goes into the final pos confidence
#
# ------------------------------------------------------------------------- 

procedure calc_conf (direction, e_bepos_xy, conf_dif, pixel_incr, 
                     prev_conf_dif, trial_xy, quadconf)

int	direction 		# i: code indicating pox or neg x or y

real	e_bepos_xy[ARB]		# i: best pos in element units
real	conf_dif 		# i: confidence difference
real	pixel_incr 		# i: pixel increment
real	prev_conf_dif 		# i: previous confidence difference
real	trial_xy[ARB]		# i: trial position in elements

real	quadconf 		# o: confidence in separate quadrants

real	delta 			# intermediate product

begin

#   positive x direction
      if ( direction == pos_x ) {
         delta = - pixel_incr *
                   (1.0 - prev_conf_dif / (prev_conf_dif - conf_dif) )
         quadconf = abs (trial_xy[x] + delta - e_bepos_xy[x])

#   negative x direction
      } else if ( direction == neg_x ) {
         delta = pixel_incr *
                 (1.0 - prev_conf_dif / (prev_conf_dif - conf_dif) )
         quadconf = abs (trial_xy[x] + delta - e_bepos_xy[x])

#   positive y direction
      } else if ( direction == pos_y ) {
         delta = - pixel_incr *
                   (1.0 - prev_conf_dif / (prev_conf_dif - conf_dif) )
         quadconf = abs (trial_xy[y] + delta - e_bepos_xy[y])

#   negative y direction
      } else if ( direction == neg_y ) {
         delta = pixel_incr *
                 (1.0 - prev_conf_dif / (prev_conf_dif - conf_dif) )
         quadconf = abs (trial_xy[y] + delta - e_bepos_xy[y])

      }

end
