#$Header: /home/pros/xray/xtiming/timlib/RCS/ltc_fillhdr.x,v 11.0 1997/11/06 16:45:04 prosb Exp $
#$Log: ltc_fillhdr.x,v $
#Revision 11.0  1997/11/06 16:45:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:53  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:16  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:51  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:59:03  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:08:13  janet
#jd - made binlen a double in all timing procedures.
#
#Revision 5.0  92/10/29  23:05:38  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:35:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:02:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:21  pros
#General Release 1.0
#
# ----------------------------------------------------------------------------
#
# Module:	LTC_FILLHDR
# Project:	PROS -- ROSAT RSDC
# Purpose:	ltcurv table initialize and output routines
# External:	ltc_fillhdr()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version Apr 1989	
#		{n} <who> -- <does what> -- <when>
#
# ----------------------------------------------------------------------------

include <tbset.h>
include <qpoe.h>

# ----------------------------------------------------------------------------
#
# Function:	ltc_fillhdr
# Purpose:	write info to table header
# Notes:	saved header values are:
#			start_time, stop_time, src_area, bkgd_area, bin_length
#
# ----------------------------------------------------------------------------
procedure ltc_fillhdr(tp,start_time,stop_time,srcarea,bkarea,bin_length,numbins)

pointer	tp				# i: table pointer
double  start_time			# i: save start time in hdr
double  stop_time			# i: save stop time in hdr
double  srcarea				# i: save source area in hdr
double  bkarea				# i: save bkgd area in hdr
double  bin_length			# i: save the num of secs/bin in hdr
int     numbins				# i: save number of bins

begin

#   Some useful numbers associated with timing task
	call tbhadt (tp,"taskinfo","This Info reflects run of the Ltcurv task:")
	call tbhadd (tp, "beg_time", start_time)
	call tbhadd (tp, "end_time", stop_time)
	call tbhadd (tp, "srcarea", srcarea)
	call tbhadd (tp, "bkarea", bkarea)
	call tbhadd (tp, "binlen", bin_length)
	call tbhadi (tp, "numbins", numbins)

end
