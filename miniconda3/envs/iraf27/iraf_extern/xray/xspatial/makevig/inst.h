#$Header: /home/pros/xray/xspatial/makevig/RCS/inst.h,v 11.0 1997/11/06 16:31:43 prosb Exp $
#$Log: inst.h,v $
#Revision 11.0  1997/11/06 16:31:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:49:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:10:58  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:30:53  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:37:07  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:52:14  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:12:56  pros
#General Release 1.0
#
# Definition of instrument parameter structure containing all the necessary 
# parameters to define the instrument for ROSAT or Einstein.
# The vignetting correction is calculated differently for the two satellites:
define	LEN_INST	12		# Length of structure
define	XCENTER		Memd[P2D($1)]	# Satellite Code
define 	YCENTER		Memd[P2D($1+2)]	# Instrument Code
define	PIXSCALE	Memd[P2D($1+4)]	# plate scale factor in pixels/arcsec
define	XOPTICAL_CENTER Memi[($1+6)] # x average optical center
define	YOPTICAL_CENTER	Memi[($1+7)] # y average optical center
define	XCORNER		Memi[$1+8]	# low order corner ( horizontal axis)
define	YCORNER		Memi[$1+9]	# low order corner ( vertical axis)
define	XDIM		Memi[$1+10]	
define	YDIM		Memi[$1+11]


