#$Header: /home/pros/xray/lib/regions/RCS/rgwcs.com,v 11.0 1997/11/06 16:19:25 prosb Exp $
#$Log: rgwcs.com,v $
#Revision 11.0  1997/11/06 16:19:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:52  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:17  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:39  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:33  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:47  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:54  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:38  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:31  pros
#General Release 1.0
#
# rgwcs.com
#
# The regions wcs transform common block
#

# the doubles must be aligned on correct boundaries
double	rg_imequix
double	rg_imepoch
pointer	rg_imwcs		# the images world coordinate system
pointer rg_ctwcs
pointer rg_ctpix
int	rg_imsystem
pointer	rg_imh


common /crg_wcs/ 	rg_imequix, rg_imepoch,
			rg_imwcs, rg_ctwcs, rg_ctpix, 
			rg_imsystem, rg_imh
