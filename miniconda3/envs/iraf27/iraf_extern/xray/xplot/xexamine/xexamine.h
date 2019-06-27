# $Header: /home/pros/xray/xplot/xexamine/RCS/xexamine.h,v 11.0 1997/11/06 16:38:43 prosb Exp $
# $Log: xexamine.h,v $
# Revision 11.0  1997/11/06 16:38:43  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:05  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:24:54  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:50:06  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:42:50  prosb
#General Release 2.2
#
#Revision 5.2  93/05/13  11:33:53  janet
#*** empty log message ***
#
#Revision 5.1  92/12/01  14:46:58  janet
#*** empty log message ***
#
#Revision 1.2  92/10/01  09:42:07  janet
#added xe_wim and xe_wcsname for wcs coordinate transforms.
#
#Revision 1.1  92/09/30  14:31:32  janet
#Initial revision
#
#
# --------------------------------

define  XE_BUFF		6

# buffer names
define  XE_QPNAME	Memi[$1+0]
define  XE_ONAME	Memi[$1+1]
define  XE_UNAME	Memi[$1+2]
define  XE_WCSNAME	Memi[$1+3]
define  XE_FILT		Memi[$1+4]

# --------------------------------

define 	XE_SIZE 	14

# original input params
define  XE_IM           Memi[$1+0] 
define  XE_AS           Memr[$1+1]
define  XE_BL		Memi[$1+2]
define  XE_LEN          Memi[$1+3]

# detector params
define  XE_DAS		Memr[$1+4]
define  XE_DLEN         Memi[$1+5]

# examine params
define 	XE_ZOOM		Memi[$1+6]
define 	XE_FACTOR       Memi[$1+7]
define  XE_SAVZM        Memi[$1+8]
define  XE_GWDTH        Memi[$1+9]

# display 
define  XE_DISPLAY      Memi[$1+10]

# handle of wcs transformations
define  XE_WIM          Memi[$1+11] 

# detect  params
define  XE_CSIZE        Memi[$1+12]
define  XE_BKDEN        Memr[$1+13]

# --------------------------------

define 	BEG  	0
define 	DONE 	1

define  SZ_FILTER  1025
