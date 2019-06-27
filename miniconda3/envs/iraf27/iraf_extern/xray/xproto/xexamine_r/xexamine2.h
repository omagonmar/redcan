# $Header: /home/pros/xray/xproto/xexamine_r/RCS/xexamine2.h,v 1.2 1998/04/24 16:14:32 prosb Exp $
# $Log: xexamine2.h,v $
# Revision 1.2  1998/04/24 16:14:32  prosb
# Patch Release 2.5.p1
#
# Revision 1.1  1998/02/25 19:55:45  prosb
# Initial revision
#
#
# JCC(1/8/98) - Add XE_DLEN2 for AXLEN2 in QPOE
#               originated from ../xexamine/xexamine.h
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

#JCC define 	XE_SIZE 	14

define 	XE_SIZE 	15

# original input params
define  XE_IM           Memi[$1+0] 
define  XE_AS           Memr[$1+1]
define  XE_BL		Memi[$1+2]
define  XE_LEN          Memi[$1+3]

# detector params : XE_DLEN is AXLEN1 in QPOE
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

#JCC - new XE_DLEN2  for AXLEN2 in QPOE
define  XE_DLEN2        Memi[$1+14]

# --------------------------------

define 	BEG  	0
define 	DONE 	1

define  SZ_FILTER  1025
