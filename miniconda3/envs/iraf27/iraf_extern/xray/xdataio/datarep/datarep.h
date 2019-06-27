#$Header: /home/pros/xray/xdataio/datarep/RCS/datarep.h,v 11.0 1997/11/06 16:33:55 prosb Exp $
#$Log: datarep.h,v $
#Revision 11.0  1997/11/06 16:33:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:32  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:31  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:40  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:10  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:14  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:35:48  pros
#General Release 1.0
#
# datarep.h
#



# The datarep instruction list
#
define	LEN_INST	1

define	I_FUNC	Memi[$1]
define	I_REPT	Memi[$1]
define	I_TEXT	Memi[$1]


# Symbol table
#
define	LEN_SYMBOL	4

define	S_FUNC	Memi[$1 + 0]
define	S_TEXT	Memi[$1 + 1]
define	S_TOKEN	Memi[$1 + 2]
define	S_REPT	Memi[$1 + 3]





# Linked list file stack
#
define	LEN_STACK	2

define	ST_NEXT	 Memi[$1 + 0]
define	ST_VALUE Memi[$1 + 1]


define MAXTOKEN		32
