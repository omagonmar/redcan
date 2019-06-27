#$Header: /home/pros/xray/xspectral/source/RCS/intermed.h,v 11.0 1997/11/06 16:42:23 prosb Exp $
#$Log: intermed.h,v $
#Revision 11.0  1997/11/06 16:42:23  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:57  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:52  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:41  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:43  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:31  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:58:26  prosb
#General Release 1.1
#
#Revision 2.1  91/07/19  14:43:46  orszak
#jso - corrected spelling change
#
#Revision 2.0  91/03/06  23:03:56  pros
#General Release 1.0
#


# define the intermediate struct for use with int_get
#
define NINT_COLUMNS	7

define SZ_INTERMED	8

define ENERGY_PTR	Memi[$1 + 0]
define HENERGY_PTR	Memi[$1 + 1]
define LENERGY_PTR	Memi[$1 + 2]
define EMITTED_PTR	Memi[$1 + 3]
define INTRINS_PTR	Memi[$1 + 4]
define REDSHIFTED_PTR	Memi[$1 + 5]
define INCIDENT_PTR	Memi[$1 + 6]

define HEADER_PTR	Memi[$1 + 7]



# define the intermed header struct
#
define SZ_INTHEAD	SZ_LINE * 2

define	INT_BEST	Memc[$1 + 0]
define	INT_ABS		Memc[$1 + SZ_LINE]

