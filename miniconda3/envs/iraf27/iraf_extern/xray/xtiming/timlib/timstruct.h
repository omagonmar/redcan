#$Header: /home/pros/xray/xtiming/timlib/RCS/timstruct.h,v 11.0 1997/11/06 16:45:14 prosb Exp $
#$Log: timstruct.h,v $
#Revision 11.0  1997/11/06 16:45:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:14  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:52  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:27  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:59:39  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:06:06  prosb
#General Release 2.1
#
#Revision 4.1  92/08/14  14:11:35  janet
#changed max bins from 100 to 1000.
#
#Revision 4.0  92/04/27  15:37:23  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/23  17:56:14  janet
#added bntot to struct.
#
#Revision 3.0  91/08/02  02:02:34  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:55  pros
#General Release 1.0
#
#        XTIMING.H
#
#        parameters used by the timing tasks

#  ---------------------------------------------------------------
define  BIN_MAX		        1000
#
define  LEN_BIN			1400

# Bin data structure
define  SRC			Memr[($1) + ($2)-1 ]
define  BK			Memr[($1)+200 + ($2)-1]
define  EXP			Memr[($1)+400 + ($2)-1]
define  CR			Memr[($1)+600 + ($2)-1]
define  CRERR			Memr[($1)+800 + ($2)-1]
define  NETCTS			Memr[($1)+1000 + ($2)-1]
define  NETERR			Memr[($1)+1200 + ($2)-1]

# Best Bin data structure
define  BST_SRC			Memr[($1) + ($2)-1 ]
define  BST_BK			Memr[($1)+200 + ($2)-1]
define  BST_EXP			Memr[($1)+400 + ($2)-1]
define  BST_CR			Memr[($1)+600 + ($2)-1]
define  BST_CRERR		Memr[($1)+800 + ($2)-1]
define  BST_NETCTS		Memr[($1)+1000 + ($2)-1]
define  BST_NETERR		Memr[($1)+1200 + ($2)-1]

define  NUM_MM			21

# Best structure with mins and max's
define  BCRMIN                   Memr[$1]
define  BCRMAX                   Memr[$1+2]
define  BCRMU                    Memr[$1+4]
define  BCREMIN                  Memr[$1+6]
define  BCREMAX                  Memr[$1+8]
define  BCREMU                   Memr[$1+10]
define  BEXPMIN                  Memr[$1+12]
define  BEXPMAX                  Memr[$1+14]
define  BEXPMU                   Memr[$1+16]
define  BSMIN                    Memr[$1+18]
define  BSMAX                    Memr[$1+20]
define  BSMU                     Memr[$1+22]
define  BBMIN                    Memr[$1+24]
define  BBMAX                    Memr[$1+26]
define  BBMU                     Memr[$1+28]
define  BNMIN                    Memr[$1+30]
define  BNMAX                    Memr[$1+32]
define  BNMU                     Memr[$1+34]
define  BNEMIN                   Memr[$1+36]
define  BNEMAX                   Memr[$1+38]
define  BNEMU                    Memr[$1+40]
define  BNTOT                    Memr[$1+42]
