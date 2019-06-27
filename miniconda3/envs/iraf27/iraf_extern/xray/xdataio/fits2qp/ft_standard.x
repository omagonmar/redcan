#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_standard.x,v 11.0 1997/11/06 16:34:48 prosb Exp $
#$Log: ft_standard.x,v $
#Revision 11.0  1997/11/06 16:34:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:40  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:39:23  dvs
#Modified code to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.0  94/06/27  15:21:28  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:58  prosb
#General Release 2.3
#
#Revision 6.1  93/12/14  18:20:35  mo
#MC	12/13/93		Make IRAF/QPOE buf fix work-around (qpx_addf)
#
#Revision 6.0  93/05/24  16:25:49  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:41  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:57  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:46  jmoran
#Initial revision
#
#
# Module:	ft_standard.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <qpset.h>
include <evmacro.h>
include "fits2qp.h"
include "cards.h"

#
#  FT_STANDARD -- write some standard parameters to the qpoe file
#
procedure ft_standard(qp)

pointer	qp				# i: qpoe handle
int	cval				# l: creation time
int	mval				# l: modification time
int	lval				# l: when limits were calculated
long	clktime()			# l: get clock time
int	qp_accessf()			# l: qpoe param existence
include "fits2qp.com"

begin

	# Set the datafile page size.
	call qp_seti (qp, QPOE_PAGESIZE, pagesize)
	# Set the bucket length in units of number of events.
	call qp_seti (qp, QPOE_BUCKETLEN, bucketlen)
	# Set the debug level
	call qp_seti (qp, QPOE_DEBUGLEVEL, debug)
	# set the default block factor for IMIO
	if( qp_accessf(qp, "defblock") == NO )
	    call qpx_addf (qp, "defblock", "i", 1, "default QPOE block factor",
			  0)
	call qp_puti (qp, "defblock", blockfactor)

	# add creation time
	cval = clktime(0)
	mval = cval
	lval = 0
	if( qp_accessf(qp, "cretime") == NO )
	    call qpx_addf(qp, "cretime", "i", 1, "QPOE file creation time", 0)
	call qp_puti(qp, "cretime", cval)
	if( qp_accessf(qp, "modtime") == NO )
	    call qpx_addf(qp, "modtime", "i", 1,
		"QPOE data modification time", 0)
	call qp_puti(qp, "modtime", mval)
	if( qp_accessf(qp, "limtime") == NO )
	    call qpx_addf(qp, "limtime", "i", 1,
		"time QPOE file limits were calculated", 0)
	call qp_puti(qp, "limtime", lval)
end

