#$Header: /home/pros/xray/lib/scan/RCS/slopen.x,v 11.0 1997/11/06 16:23:50 prosb Exp $
#$Log: slopen.x,v $
#Revision 11.0  1997/11/06 16:23:50  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:20  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:52  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:18  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:42  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:12:38  mo
#MC   8/2/91          Updated dependencies
#
#Revision 3.0  91/08/02  01:08:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:18:42  pros
#General Release 1.0
#
#
#
# Module:	slopen.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Open and close a scan list handle
# Includes:	sl_open(), sl_close(), sl_reset()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	"slset.h"

#
# Function:	sl_open
# Purpose:	Allocate a scan list image handle for a client
# Parameters:	See argument declarations
# Returns:	handle for san list image
# Uses:		sc_open() in scopen.x
# Notes:	first SL_LEN elements of scan array are used as a header
#
pointer procedure sl_open ( width, height )

int	width		# i: width dimension of scan list image
int	height		# i: height dimension of scan list image

pointer	sl		# o: scan list image handle
pointer	sc_open()	# returns array of scan lists

begin
	sl = sc_open (height + SL_LEN)
	SL_WDTH(sl) = width
	SL_HGHT(sl) = height
	SL_SCAN(sl) = sl + SL_LEN
	return( sl )
end

#
# Function:	sl_close
# Purpose:	Close a scan list image handle and free its space for reuse
# Parameters:	See argument declarations
# Uses:		sc_repool() in scopen.x
# Method:	Free edge in scan (return to pool), then free the handle
# Notes:	
#
procedure sl_close ( sl )

pointer	sl		# i: scan list structure handle

begin
	call sc_repool (Memi[SL_SCAN(sl)], SL_HGHT(sl))
	call mfree (sl, TY_INT)
end

#
# Function:	sl_reset
# Purpose:	Free all malloc'd blocks of pool space held by sc calls
# Parameters:	See argument declarations
# Uses:		sc_freepool()
# Notes:	sl/sc library keeps link list space for reuse until this reset
#		call is made.
#
procedure sl_reset ()

begin
	call sc_freepool ()
end

