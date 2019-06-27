#$Header: /home/pros/xray/xspectral/source/extra/RCS/z_to_distance.x,v 11.0 1997/11/06 16:41:43 prosb Exp $
#$Log: z_to_distance.x,v $
#Revision 11.0  1997/11/06 16:41:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:35:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:53:57  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:53:30  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:11  prosb
#General Release 2.1
#
#Revision 3.0  91/08/02  01:59:34  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:47:12  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:07:57  pros
#General Release 1.0
#
#   z_to_distance.x   ---   compute distance from redshift

include  <spectral.h>
include	 "flux.h"

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  Convert redshift to a distance (cm).

double  procedure  z_to_distance( redshift )

real	redshift,  clgetr()
double  distance,  hubble,  decell

begin
	hubble = clgetr( "Hubble_constant" )
	decell = clgetr( "decelleration_constant" )

	if(  decell == 0.0 )
		distance = C/hubble * (redshift + redshift*redshift/2.0)
	  else
		distance = C/(hubble*decell*decell) * (redshift*decell +
			   (decell-1.0)*(dsqrt(2.0*decell*redshift+1.0)-1.0))

	distance = distance * CM_PER_MPC
	return (distance)
end
