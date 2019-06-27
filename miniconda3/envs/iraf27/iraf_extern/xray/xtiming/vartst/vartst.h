# $Header: /home/pros/xray/xtiming/vartst/RCS/vartst.h,v 11.0 1997/11/06 16:45:25 prosb Exp $
# $Log: vartst.h,v $
# Revision 11.0  1997/11/06 16:45:25  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:35:28  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:43:13  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:00:01  prosb
#General Release 2.2
#
#Revision 1.1  93/05/20  10:19:38  janet
#Initial revision
#
#        VARTST.H
#
#        parameters used by the vartst timing task

define   SOURCEFILENAME      "source_file"
define   VARFILENAME         "var_file"

define   STARTTIME           "start_time"
define   STOPTIME            "stop_time"

define   CLOBBER             "clobber"
define   DISPLAY             "display"

define   BANDWIDTH           "bandwidth"

define   LEN_EVBUF           1024

# Cramer VonMises probabilities for 90, 95, and 99 percent
define   C90_CVM	     0.347
define   C95_CVM	     0.461
define   C99_CVM	     0.743

# Ks-test probability constants (taken from MPE SASS code ks.for)
define   C90_KS	              1.22
define   C95_KS       	      1.36
define   C99_KS               1.63
