#$Header: /home/pros/xray/xspatial/makevig/RCS/vign.h,v 11.0 1997/11/06 16:31:46 prosb Exp $
#$Log: vign.h,v $
#Revision 11.0  1997/11/06 16:31:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:50:00  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:11:06  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:39  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:01  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:37:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:52:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:13:22  pros
#General Release 1.0
#
define  DEGTOAS         (3600.0*($1))           # degrees to seconds of arc


# Definition of vignetting structure containing all the necessary parameters
#	to compute the vignetting correction for ROSAT or Einstein
# The vignetting correction is calculated differently for the two satellites:
#	For Einstein there is both a quadratic correction formula and a linear
# correction formula ( as a function of off-axis angle ) depending on the
# off-axis distance.
define	LEN_VIGN	33		# Length of structure
define	COEFF0		Memd[P2D($1)] # High order quadratic coefficient
define	COEFF1		Memd[P2D($1+2)]	# Quadratic coefficient for x term
define	COEFF2		Memd[P2D($1+4)] # Quadratic coeff for constant term
define	COEFF3		Memd[P2D($1+6)]	# Linear coeff for x term
define	COEFF4		Memd[P2D($1+8)] # Linear coeff for constant term
define	COEFF5		Memd[P2D($1+10)]# Threshold at which to change from
define	MAXVIGN		Memd[P2D($1+12)]# value at edge
define	A1		Memd[P2D($1+14)]
define	A2		Memd[P2D($1+16)]
define	THIRDA1		Memd[P2D($1+18)]
define	QQ		Memd[P2D($1+20)]
define	QQ3		Memd[P2D($1+22)]
define	RR		Memd[P2D($1+24)]
define	EVNORM		Memd[P2D($1+26)]
define	FOV		Memd[P2D($1+28)]
define	ORDER		Memi[$1+30]	# polynomial order
define	SAT		Memi[$1+31]	# Satellite Code
define 	INST		Memi[$1+32]	# Instrument Code



