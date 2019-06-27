#$Header: /home/pros/xray/xtiming/fft/RCS/binpars.h,v 11.0 1997/11/06 16:44:25 prosb Exp $
#$Log: binpars.h,v $
#Revision 11.0  1997/11/06 16:44:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:39:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:00:50  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:56:44  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  11:42:56  mo
#MC	5/20/93		Update for DP bin sizes
#
#Revision 5.0  92/10/29  22:48:35  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:32:08  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:17  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:43:18  pros
#General Release 1.0
#

define	SZ_BINPARS	10
define	START		Memd[P2D($1)]
define	STOP		Memd[P2D($1+2)]
define	STARTBIN	Memd[P2D($1+4)]
define	STOPBIN		Memd[P2D($1+6)]
define	BINLENGTH	Memd[P2D($1+8)]
