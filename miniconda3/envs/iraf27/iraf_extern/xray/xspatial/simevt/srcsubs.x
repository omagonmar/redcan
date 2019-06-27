# JCC(5/5/98) - change YES/int to TRUE/bool for linux.
#
# Module:	srcsubs.x
# Project:      PROS -- ROSAT RSDC
# Purpose:	Procedures used in defining source parameters
# Description:	includes subroutines get_srccts, get_oaa, get_sigma,
#		define_src
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} KRM -- initial version -- 8/94
#
# -----------------------------------------------------------------------

include "simevt.h"
include <mach.h>

# -----------------------------------------------------------------------
#  
# get_srccts
#
# Input : 	srcinfo - pointer to source info data structure
#	  	qpinfo - pointer to qpoe info data strucuture
#
# Return value : srccts - integer number of source counts
#
# Description : Compute the number of counts to generate for a particular
# source from the source intensity and, if a "rate" is specified, from the
# determine the appropriate livetime from the user specified value and
# the reference qpoe file.  If resolved livetime is 0, exit with an error!
#
###

procedure  get_srccts(srcinfo, qpinfo, display)

pointer srcinfo
pointer qpinfo
int display

real srccts	# computed source counts

real clgetr()
int nint()
bool streq()

begin

    if ( streq(ITYPE(srcinfo), "counts" ) ) {
	srccts = INTENS(srcinfo)
    }
    else if ( streq(ITYPE(srcinfo), "rate" ) ) {

       	# If this is the first "rate" source, need to figure out what
        # the livetime of our simulated observation will be.  The livetime
	# starts off as 0 (set by qpfill routine).  Check the task parameter
	# first, then the reference qpoe file.

	if ( SIM_QPLVT(qpinfo) <= EPSILONR ) {
	    # need to determine livetime, start with user specified	
	    # value

	    SIM_QPLVT(qpinfo) = clgetr("livetime")

       	    if ( SIM_QPLVT(qpinfo) <= EPSILONR ) {
		# user wants to use value in reference qpoe file

            	SIM_QPLVT(qpinfo) = SIM_REFLVT(qpinfo)
	
	    	if ( SIM_QPLVT(qpinfo) <= EPSILONR ) {
		    # we have zero in both places, error !

	    	    call error(1, "zero LIVETIME found!")
		}
	    }

	    if ( display > 0 ) {
	   	call printf("Using LIVETIME of %.2f seconds to determine source counts\n\n")	
		  call pargr(SIM_QPLVT(qpinfo))
	    }
   	}

	srccts = INTENS(srcinfo) * SIM_QPLVT(qpinfo)

    }

    else {
	call eprintf("Unknown itype %s encountered for source number %d \n")
	call pargstr(ITYPE(srcinfo))
	call pargi(SRCNO(srcinfo))
	call error(1, "")
    }

    # convert srccts to the nearest integer

    SRCCTS(srcinfo) = nint(srccts)

end


# -----------------------------------------------------------------------
#
# get_oaa
#
# Input	:	srcinfo structure
#		qpinfo structure
#
# Ouput : 	offang - offaxis angle in arcminutes
#
###

procedure get_oaa(srcinfo, qpinfo, offang)

pointer srcinfo
pointer qpinfo

real offang

int xdiff
int ydiff

begin

    xdiff = SRCX(srcinfo) - SIM_QPCENX(qpinfo)
    ydiff = SRCY(srcinfo) - SIM_QPCENY(qpinfo)

    offang = sqrt( real(xdiff**2 + ydiff**2) )

    # convert to arcminutes

    offang = (offang * SIM_QPAPPX(qpinfo)) / 60.0

end

# -----------------------------------------------------------------------
#
# get_sigma
#
# Input		offang	- offaxis angle in arcminutes
#		prftopen - bool flag to indicate that prf table is open
#		qpinfo	- qp info structure
# 		display	- display value
#		ptp	- pointer to prf lookup table
#		pcolptr	- pointer to table columns
#
# Output	sigma	- sigma value in pixels
#
# Description : Use the prf lookup table to convert offang to a 
# sigma value
#
# Algorithm is defined in the prf table header and is the same that
# is used in the calcef.x subroutine of the detect.bepos task.
#
###

procedure get_sigma(offang, prftopen, qpinfo, display, ptp, pcolptr, sigma)

real offang
bool prftopen
pointer qpinfo
int display
pointer ptp
pointer pcolptr

real sigma

real energy		# for now, this is always 0.0 (the ROSAT HRI)
int eqkey		# equation key for prf
real aa,bb,cc,dd,ee	# prf coefficients

begin

    energy = 0.0
   
    # If prf table is not open, call init_prftab to open and 
    # intialize pointers to the columns.

    if ( ! prftopen ) {
	call init_prftab(ptp, pcolptr)
	prftopen = TRUE
	if ( display > 2 ) {
	    call printf("Opened PRF lookup table \n\n")
  	}
    }

    # lookup prf coefficients

    call prf_lookup(ptp, pcolptr, SIM_INST(qpinfo), SIM_TEL(qpinfo), energy,
	            display, eqkey, aa, bb, cc, dd, ee)

    switch (eqkey) {

      case 1 :

	sigma = (sqrt (aa**2 + bb**2 + (cc + dd * offang**ee)**2))/ SIM_QPAPPX(qpinfo)
	
      default:
	call error(1, "Cannot recognize eq_code Not Equal to 1")
    }

end

# -----------------------------------------------------------------------
#
# define_src
#
# Input :	srcinfo - pointer to stucture containing source info
#		qpinfo  - pointer to structure containing field info
#		prftopen - boolean to indicate an open prf table
#		ptp 	- pointer to prf lookup table
#		pcolptr	- array of column pointers
#		display	- display value
# 
# Output : fill the following fields in the srcinfo structure
#
#		SRCTYPE - code for type of PRF to use when generating 
#			  source
#		SRCPAR - relevant parameter, either "oaa" or "sigma"
#
# Description : This routine is used to set the code for the appropriate
# PRF routine to use for the input source, and to determine the parameter
# value (either offaxis angle or sigma).  The following input source
# prf specifications are allowed :
#
# 1) roshri	: ROSAT HRI PRF, offaxis angle specified
# 2) gauss_oaa  : GAUSSIAN PRF, offaxis angle specified
# 3) gauss_sig  : GAUSSIAN PRF, sigma value specified
#
# For prf types 1 and 2, if INDEF is used for the oaa value it is 
# calculated by the routine get_oaa by using the source center 
# coordinates as a detector positions.
#
# For prf type 2, the routine get_sigma is used to convert the specified
# offaxis angle value to a sigma value.
#
##

procedure define_src(srcinfo, qpinfo, prftopen, ptp, pcolptr, display)

pointer srcinfo
pointer qpinfo
bool prftopen
pointer ptp
pointer pcolptr[ARB]
int display

real offang		# offaxis angle in arcminutes
real sigma		# sigma in pixels

bool streq

begin

    if ( streq(PTYPE(srcinfo), "roshri") ) {
  	SRCTYPE(srcinfo) = HRI_PRF

	# need to determine offaxis angle

	if ( IS_INDEFR(PRFPAR(srcinfo)) ) {
	    call get_oaa(srcinfo, qpinfo, offang)
	    SRCPAR(srcinfo) = offang
	}
	else {
	    SRCPAR(srcinfo) = PRFPAR(srcinfo)
	}
    }

    else if ( streq(PTYPE(srcinfo), "gauss_oaa") ) {
	SRCTYPE(srcinfo) = GAUSS_PRF
	
	# need to determine offaxis angle and convert to sigma

	if ( IS_INDEFR(PRFPAR(srcinfo)) ) {
	    call get_oaa(srcinfo, qpinfo, offang)
	}
	else {
	    offang = PRFPAR(srcinfo)
	}

	call get_sigma(offang, prftopen, qpinfo, display, ptp, pcolptr, sigma)
   	if ( sigma <= EPSILONR ) {
	    call eprintf("0 sigma specified for source number %d \n")
	      call pargi(SRCNO(srcinfo))
	    call error(1, "")
        }
	else {
	    SRCPAR(srcinfo) = sigma
	}
    }

    else if ( streq( PTYPE(srcinfo), "gauss_sig") ) {
	SRCTYPE(srcinfo) = GAUSS_PRF

	# get specified sigma value

	if ( IS_INDEFR(PRFPAR(srcinfo)) ) {
	    call eprintf("Source number %d ")
	      call pargi(SRCNO(srcinfo))
	    call error(1, "Undefined value of sigma specified!")
	}
	else {

	    SRCPAR(srcinfo) = PRFPAR(srcinfo)
	}

	# if 
    }
    else {
	call error(1, "Unknown PTYPE (prf_type) encountered!")
    }

end
