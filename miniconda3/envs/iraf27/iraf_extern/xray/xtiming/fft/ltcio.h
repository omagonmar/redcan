#$Header: /home/pros/xray/xtiming/fft/RCS/ltcio.h,v 11.0 1997/11/06 16:44:39 prosb Exp $
#$Log: ltcio.h,v $
#Revision 11.0  1997/11/06 16:44:39  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:31  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:26  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:28  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:49:05  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:33:04  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:35  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:44:21  pros
#General Release 1.0
#

DEFINE	SZ_LTCIO	15
DEFINE	SRC_AREA	Memd[P2D($1)]
DEFINE	BK_AREA		Memd[P2D($1+2)]
DEFINE	TOTEXP		Memr[$1+4]
DEFINE	SQP		Memi[$1+5]
DEFINE	BQP		Memi[$1+6]
DEFINE	SQPIO		Memi[$1+7]
DEFINE	BQPIO		Memi[$1+8]
DEFINE	SOFFSET		Memi[$1+9]
DEFINE	BOFFSET		Memi[$1+10]
DEFINE	TP		Memi[$1+11]
DEFINE	TYPE		Memi[$1+12]
DEFINE	DOBKGD		Memi[$1+13]
DEFINE	COLUMN		Memi[$1+14]

DEFINE	SRC	1
DEFINE	SOURCE	SRC
DEFINE	BK	2
DEFINE	BACKGROUND	BK
DEFINE	NET	3
DEFINE	EXPOSURE	4
DEFINE	CTRT	5

