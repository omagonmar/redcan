#$Header: /home/pros/xray/xtiming/timlib/RCS/tim_cntrate.x,v 11.0 1997/11/06 16:45:11 prosb Exp $
#$Log: tim_cntrate.x,v $
#Revision 11.0  1997/11/06 16:45:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:06  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:40  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:14  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  12:48:16  janet
#jd - updated error calcs, added call to one_sigma lib.
#
#Revision 6.0  93/05/24  16:59:27  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:05:55  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:37:02  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:02:30  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:42  pros
#General Release 1.0
#
# --------------------------------------------------------------------------
#
# Module:	TIM_CNTRATE
# Project:	PROS -- ROSAT RSDC
# Purpose:	Compute the count rate for 1 bin of data
# External:	tim_cntrate()
# Local:	tim_netcnts(), tim_adjexp()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Adam Sczcypek initial version Jan 1987
#		{1} Janet DePonte updated version Apr 1989
#		{n} <who> -- <does what> -- <when>
#
# --------------------------------------------------------------------------

include  <mach.h>
include	 "timing.h"

# --------------------------------------------------------------------------
#
# Function:	tim_cntrate
# Purpose:	Compute the count rate for 1 bin of data
#
# --------------------------------------------------------------------------
procedure  tim_cntrate (source, bkgrd, exposure, bin, errtype, srcarea, bkarea, 
			bknorm, ctrt, ctrt_err, netcts, neterr)


real	 source			# i: binned source photon data
real	 bkgrd			# i: binned bkgrd photon data
real	 exposure		# i: seconds of good time in each bins
int	 bin			# i: current timing bin 
int      errtype		# i: error type; pois or gaus
double   srcarea		# i: source area
double   bkarea			# i: bkgrd area
real     bknorm			# i: bkgd normalization factor
real	 ctrt			# o: computed cnt rate for 1 bin 
real	 ctrt_err		# o: cnt rate error
real     netcts			# o: net cts
real	 neterr 		# o: net cts error

begin

	call tim_netcts (source, bkgrd, srcarea, bkarea, 
			 bknorm, exposure, errtype, netcts, neterr)

        call tim_adjexp (exposure, bin, netcts, neterr, 
			 ctrt, ctrt_err)

end

# --------------------------------------------------------------------------
#
# Function:	tim_netcnts
# Purpose:	Compute the net counts & statistical error for 1 bin of data
#
# --------------------------------------------------------------------------
procedure  tim_netcts ( source, bkgrd, srcarea, bkarea, bknorm, exposure,
			errtype, netcts, neterr)

real	 source			# i: src photons in current bin
real	 bkgrd			# i: bkgrd photons in current bin
double   srcarea		# i: source area
double   bkarea			# i: bkgrd area
real     bknorm			# i: bkgd normalization factor
real     exposure               # i: exposure of the bin in seconds
int      errtype		# l: poisson or gaus errors; from qpoe hdr 
real	 netcts			# o: net source data
real	 neterr			# o: statistical error

real     berr, serr             # l: error on src and bk counts
real	 stob			# l: (source area)/(bkgrd area)

begin

#   First divide source area by bkgd area.  The default bknorm is 1.
	if ( bkarea > EPSILONR ) {
	    stob =  srcarea/bkarea * bknorm
	} else {
	    stob = 0.0
	}

#	call printf ("errtype = %d\n")
#	   call pargi (errtype)
#       call flush (STDOUT)

#   Compute the Net source counts and Statistical error
        if ( exposure > EPSILONR ) {
	   netcts = source - stob*bkgrd

           call one_sigma(source,1,errtype,serr)
           call one_sigma(bkgrd,1,errtype,berr)
           neterr = sqrt(serr**2 + (stob**2)*berr**2) 
	} else {
	   netcts = 0.0
	   neterr = 0.0
	}
  
        # - old error calc - 
        # neterr = sqrt(source + stob*stob*bkgrd)
	# - old error calc - 

end

# --------------------------------------------------------------------------
#
# Function:	tim_adjexp
# Purpose:	compute cntrate & it's error 
#
# --------------------------------------------------------------------------
procedure  tim_adjexp ( exposure, bin, netcts, neterr, ctrt, ctrt_err)

real	 exposure		# i: seconds of good time in current bin
int	 bin			# i: current bin
real	 netcts			# i: net counts
real	 neterr			# i: net count error
real	 ctrt			# o: computed count rate
real	 ctrt_err		# o: count rate error

begin


#     Compute the count rate and count rate error
	
	if ( exposure > EPSILONR ) {
	   ctrt = netcts / exposure
	   ctrt_err = neterr / exposure
	} else  {
	   ctrt = 0.0
	   ctrt_err = 0.0
	   if ( netcts > EPSILONR )  {
	      call printf("Bin %d has %f counts but no exposure! \n")
		call pargi (bin)
		call pargr (ctrt)
	   }
	}
end

