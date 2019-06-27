# $Header: /home/pros/xray/xspatial/detect/ms/RCS/ms.h,v 11.0 1997/11/06 16:32:38 prosb Exp $
# $Log: ms.h,v $
# Revision 11.0  1997/11/06 16:32:38  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:52:00  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:14:26  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:23  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:19:53  prosb
#General Release 2.2
#
#Revision 1.1  93/05/13  12:07:52  janet
#Initial revision
#

define  LEN_NODE	18

define  MS_NXT		Memi[$1]
define  MS_MTCH		Memi[$1+2]
define  MS_ID		Memi[$1+4]
define  MS_CELLX	Memi[$1+6]
define  MS_CELLY	Memi[$1+8]
define  MS_POSX		Memr[$1+10]
define  MS_POSY		Memr[$1+12]
define  MS_ERR		Memr[$1+14]
define  MS_SNR		Memr[$1+16]

define  NUM_MS_OUT	10
