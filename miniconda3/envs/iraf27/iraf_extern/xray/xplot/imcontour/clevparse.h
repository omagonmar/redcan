#$Header: /home/pros/xray/xplot/imcontour/RCS/clevparse.h,v 11.0 1997/11/06 16:38:02 prosb Exp $
#$Log: clevparse.h,v $
#Revision 11.0  1997/11/06 16:38:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:52  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:15  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:45  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:34:53  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:13  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:23:55  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:05:45  wendy
#Initial revision
#
#Revision 2.0  91/03/06  23:20:36  pros
#General Release 1.0
#
#
# CLEVPARSE.H -- definitions for contour level set parsing
#

define  MAX_NESTS       32			# max nesting of includes
define	YYMAXDEPTH	150			# parser stack length

# Parser stack structure.  The operand value is stored in a VAL field if the
# operand is a constant, else in the associated register.

define	LEN_OPERAND	4			# size of operand structure
define	YYOPLEN		LEN_OPERAND		# for the parser

define  LBUF	        Memi[($1)]           	# line buffer pointer
define	VALC		Memc[Memi[($1)]]	# string val (in string buffer)
define	VALI		Memi[($1)]		# int value
define	VALR		Memr[($1)]		# real value

# define string buffer size for names
define	SZ_SBUF		1024
