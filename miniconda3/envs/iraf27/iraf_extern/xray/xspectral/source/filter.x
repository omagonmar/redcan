#$Header: /home/pros/xray/xspectral/source/RCS/filter.x,v 11.0 1997/11/06 16:42:04 prosb Exp $
#$Log: filter.x,v $
#Revision 11.0  1997/11/06 16:42:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:05  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:51  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:04  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:19  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:44  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:07  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:02:47  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#   filter.x   ---   fold photon spectrum through filter(s)




#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  fold through filter (dummy routine for now)

procedure filter_fold( original_spectrum,  filtered_spectrum, bins )

int	bins,  i
double	original_spectrum[ARB],  filtered_spectrum[ARB]

begin
	for( i=1; i<=bins; i=i+1 )
		filtered_spectrum[i] = original_spectrum[i]
end
