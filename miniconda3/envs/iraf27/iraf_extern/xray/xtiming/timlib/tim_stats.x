#$Header: /home/pros/xray/xtiming/timlib/RCS/tim_stats.x,v 11.0 1997/11/06 16:45:12 prosb Exp $
#$Log: tim_stats.x,v $
#Revision 11.0  1997/11/06 16:45:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:09  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:18  prosb
#General Release 2.3
#
#Revision 6.1  93/06/11  17:35:28  mo
#no change
#
#Revision 6.0  93/05/24  16:59:32  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:05:59  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:37:10  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/23  17:54:13  janet
#added total counts to header.
#
#Revision 3.0  91/08/02  02:02:32  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:48  pros
#General Release 1.0
#
# ----------------------------------------------------------------------------
#
# Module:	TIM_MINMAX
# Project:	PROS -- ROSAT RSDC
# Purpose:	determine min & max column values to be saved in hdr
# External:	tim_initmm(), tim_minmax(), tim_updhdr()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version Apr 1989	
#		{n} <who> -- <does what> -- <when>
#
# ----------------------------------------------------------------------------

include "timing.h"
include <mach.h>

# ----------------------------------------------------------------------------
#
# Function:	tim_initmm
# Purpose:	initiialize min & max values in the structure
# Notes:	column names are: 
#			ctrt, ctrt_err, exp, src, bkgd, net neterr
#
# ----------------------------------------------------------------------------
procedure tim_initmm (minmax) 

pointer minmax				# i: min/max struct ptr

begin

	CRMIN(minmax)  =  MAX_REAL
	CRMAX(minmax)  = -MAX_REAL
	CRMU(minmax)   =  0.0

	CREMIN(minmax) =  MAX_REAL
	CREMAX(minmax) = -MAX_REAL 
	CREMU(minmax)  =  0.0

	EXPMIN(minmax) =  MAX_REAL
	EXPMAX(minmax) = -MAX_REAL
	EXPMU(minmax)  =  0.0

	SMIN(minmax)   =  MAX_REAL
	SMAX(minmax)   = -MAX_REAL
	SMU(minmax)    =  0.0

	BMIN(minmax)   =  MAX_REAL
	BMAX(minmax)   = -MAX_REAL
	BMU(minmax)   =  0.0

	NMIN(minmax)   =  MAX_REAL
	NMAX(minmax)   = -MAX_REAL
	NMU(minmax)    =  0.0

	NEMIN(minmax)  =  MAX_REAL
	NEMAX(minmax)  = -MAX_REAL
	NEMU(minmax)   =  0.0

	NTOT(minmax)   =  0.0

end

# ----------------------------------------------------------------------------
#
# Function:	tim_minmax
# Purpose:	determine column min & max values
# Notes:	column names are: 
#			ctrt, ctrt_err, exp, cnts, bkgd, net, neterr
#
# ----------------------------------------------------------------------------
procedure tim_minmax (minmax, cnt_rate, cnt_rate_err, exp, source, bkgd,
		      net_cts, net_err) 

pointer minmax				# i: min/max struct ptr
real	cnt_rate			# i: cnt rate for 1 bin
real	cnt_rate_err 			# i: statistical error for 1 bin 
real	exp				# i: exposure for 1 bin
real	source				# i: src photons in 1 bin
real	bkgd				# i: bkgd photons in 1 bin
real	net_cts				# i: net counts per bin
real    net_err				# i: net counts err

begin

	CRMIN(minmax)  = min (cnt_rate, CRMIN(minmax))
	CRMAX(minmax)  = max (cnt_rate, CRMAX(minmax))
	CRMU(minmax)   = CRMU(minmax) + cnt_rate

	CREMIN(minmax) = min (cnt_rate_err, CREMIN(minmax))
	CREMAX(minmax) = max (cnt_rate_err, CREMAX(minmax))
	CREMU(minmax)  = CREMU(minmax) + cnt_rate_err

	EXPMIN(minmax) = min (exp, EXPMIN(minmax))
	EXPMAX(minmax) = max (exp, EXPMAX(minmax))
	EXPMU(minmax)  = EXPMU(minmax) + exp

	SMIN(minmax)   = min (source, SMIN(minmax))
	SMAX(minmax)   = max (source, SMAX(minmax))
	SMU(minmax)    = SMU(minmax) + source

	BMIN(minmax)   = min (bkgd, BMIN(minmax))
	BMAX(minmax)   = max (bkgd, BMAX(minmax))
	BMU(minmax)    = BMU(minmax) + bkgd

	NMIN(minmax)   = min (net_cts, NMIN(minmax))
	NMAX(minmax)   = max (net_cts, NMAX(minmax))
	NMU(minmax)    = NMU(minmax) + net_cts

	NEMIN(minmax)   = min (net_err, NEMIN(minmax))
	NEMAX(minmax)   = max (net_err, NEMAX(minmax))
	NEMU(minmax)    = NEMU(minmax) + net_err

	NTOT(minmax)    = NTOT(minmax) + net_cts
end

# ----------------------------------------------------------------------------
#
# Function:	tim_compmu
# Purpose:	compute the averages of stats
#
# ----------------------------------------------------------------------------
procedure tim_compmu (minmax, num_bins)

pointer	minmax  			# i: min/max struct pointer
real    num_bins			# i: num of bins for mean computation

begin

#   Compute the averages 
	CRMU(minmax) = CRMU(minmax)/num_bins
	CREMU(minmax) = CREMU(minmax)/num_bins
	EXPMU(minmax) = EXPMU(minmax)/num_bins
	SMU(minmax) = SMU(minmax)/num_bins
	BMU(minmax) = BMU(minmax)/num_bins
	NMU(minmax) = NMU(minmax)/num_bins
	NEMU(minmax) = NEMU(minmax)/num_bins

end
# ----------------------------------------------------------------------------
#
# Function:	tim_updhdr
# Purpose:	write min/max info to table header
# Notes:	saved header values are:
#		ctrt min, ctrt max, err min, err max, exp min, exp max, 
#		cnts min, cnts max, bkgd min, bkgd max, net min, net max, 
#		neterr min, neterr max
#
# ----------------------------------------------------------------------------
procedure tim_updhdr (minmax, tp, bins)

pointer	minmax  			# i: min/max struct pointer
pointer tp				# i: table pointer
int     bins                            # i: number of bins

begin

#   Some useful numbers when plotting

	call tbhadr (tp, "ctrtmn",   CRMIN(minmax))
	call tbhadr (tp, "ctrtmx",   CRMAX(minmax))
	call tbhadr (tp, "ctrtmu",   CRMU(minmax))

	call tbhadr (tp, "errmn",    CREMIN(minmax))
	call tbhadr (tp, "errmx",    CREMAX(minmax))
	call tbhadr (tp, "errmu",    CREMU(minmax))

	call tbhadr (tp, "expmn",    EXPMIN(minmax))
	call tbhadr (tp, "expmx",    EXPMAX(minmax))
	call tbhadr (tp, "expmu",    EXPMU(minmax))

	call tbhadr (tp, "srcmn",    SMIN(minmax))
	call tbhadr (tp, "srcmx",    SMAX(minmax))
	call tbhadr (tp, "srcmu",    SMU(minmax))

	call tbhadr (tp, "bkgdmn",   BMIN(minmax))
	call tbhadr (tp, "bkgdmx",   BMAX(minmax))
	call tbhadr (tp, "bkgdmu",   BMU(minmax))

	call tbhadr (tp, "netmn",    NMIN(minmax))
	call tbhadr (tp, "netmx",    NMAX(minmax))
	call tbhadr (tp, "netmu",    NMU(minmax))

	call tbhadr (tp, "neterrmn", NEMIN(minmax))
	call tbhadr (tp, "neterrmx", NEMAX(minmax))
	call tbhadr (tp, "neterrmu", NEMU(minmax))

	call tbhadi (tp, "totcnts",  int(NTOT(minmax)))
end
