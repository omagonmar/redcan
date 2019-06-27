#$Header: /home/pros/xray/xtiming/fold/RCS/fld_fillhdr.x,v 11.0 1997/11/06 16:44:54 prosb Exp $
#$Log: fld_fillhdr.x,v $
#Revision 11.0  1997/11/06 16:44:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:16  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:58:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:49:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:35:00  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:49  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:47:05  pros
#General Release 1.0
#
# ----------------------------------------------------------------------------
#
# Module:	FLD_FILLHDR
# Project:	PROS -- ROSAT RSDC
# Purpose:	fold table initialize and output routines
# External:	fld_fillhdr()
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
# Function:	fld_fillhdr
# Purpose:	write info to table header
# Notes:	saved header values are:
#			start_time, stop_time, src_area, bkgd_area, bin_length
#
# ----------------------------------------------------------------------------
procedure fld_fillhdr (tp, start_time, stop_time, srcarea, bkarea, 
		       bin_length, fold, numbins)

pointer	tp				# i: table pointer
double  start_time			# i: save start time in hdr
double  stop_time			# i: save stop time in hdr
double  srcarea				# i: save source area in hdr
double  bkarea				# i: save bkgd area in hdr
real    bin_length			# i: save the num of secs/bin in hdr
real    fold				# i: save fold period in hdr
int     numbins				# i: save number of bins

begin

#   Some useful numbers associated with timing task
	call tbhadt (tp, "taskinfo", "This Info reflects run of the Fold task:")
	call tbhadd (tp, "beg_time", start_time)
	call tbhadd (tp, "end_time", stop_time)
	call tbhadd (tp, "srcarea", srcarea)
	call tbhadd (tp, "bkarea", bkarea)
	call tbhadr (tp, "binlen", bin_length)
	call tbhadr (tp, "fold_per", fold)
	call tbhadi (tp, "numbins", numbins)

end
