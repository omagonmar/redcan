#$Header: /home/pros/xray/lib/coords/RCS/precess.com,v 11.0 1997/11/06 16:24:23 prosb Exp $
#$Log: precess.com,v $
#Revision 11.0  1997/11/06 16:24:23  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:38  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:35  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:03:06  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:30  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:13:07  prosb
#General Release 2.0:  April 1992
#
#Revision 2.0  91/03/07  00:32:40  pros
#General Release 1.0
#
#
# precess.com
#
# Common block for precession routines
#


double	imatrix[3, 3]
double	omatrix[3, 3]
double 	c_iepoch
double	c_oepoch
int	c_icsystem
int	c_ocsystem

common	/c_precess/	imatrix, omatrix,
			c_iepoch, c_oepoch, c_icsystem, c_ocsystem
