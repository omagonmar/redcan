# JCC(5/5/98) - change NO/int to FALSE/bool for linux.
#
# Module:       simevt.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      Main routine for SIMEVT task.
# Description:  Generates simulated data as specified in a source table 
#               file.  Events are written out to an ascii file.  Header
#               information is extracted from a reference QPOE file and
#               an ascii header template is written.  These files can 
#               be used as input to the QPCREATE task.  
#               The SIMEVT task currently has the capability of generating
#               events from a Gaussian PRF or the ROSAT-HRI PRF as well
#               as random background over a specified field size.  The
#               system function "urand" is used to generate random numbers
#               between 0.0 and 1.0.
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} KRM -- intitial version -- 8/94
#
# -----------------------------------------------------------------------

include "simevt.h"
include <tbset.h>
include <mach.h>
include <fset.h>

# -----------------------------------------------------------------------

procedure t_simevt()

pointer refhead      	# pointer to xray header of reference qpoe file
pointer qpinfo       	# pointer to qpoe info data structure

pointer iptr         	# pointer to input source table
pointer icolptr[6] 	# pointers to the table columns
int numsrcs	     	# number of sources in the input table

int srcno	     	# loop  invariant
pointer srcinfo		# pointer to source info structure

int display		# display level for output

bool prftopen		# flag to indicate that prf table is open
pointer ptp		# pointer to prf lookup table
pointer pcolptr[10] 	# pointer to columns of prf lookup table

long clktime()		# returns clock time in seconds
real set_time		# value passed to clktime function

int ofd			# output file descriptor
pointer outlist		# name of ascii output list 

int ohd			# output header descriptor
pointer outhead		# name of ascii output header template

int jj			# loop invariant

int evtx, evty		# coordinates of source event

bool good_src		# flag to indicate that source position is within
			# the field boundaries

pointer sp

int clgeti()
int open()
bool streq()
double calc_hri_prf()

include "ran.com"	# contains value of seed for random number
			# generator
include "hri.com"	# contains value of hri prf normalization factor

begin

    display = clgeti("display")

    if ( display > 0 ) {
	call printf("Beginning run of SIMEVT ... \n\n")
    }

    # get the output file names

    call smark(sp)
    call salloc(outlist, SZ_PATHNAME, TY_CHAR)
    call clgstr("outlist", Memc[outlist], SZ_PATHNAME)

    call salloc(outhead, SZ_PATHNAME, TY_CHAR)
    call clgstr("outhead", Memc[outhead], SZ_PATHNAME)

    # open the ascii output list of events for writing

    ofd = open(Memc[outlist], NEW_FILE, TEXT_FILE)

    if ( ERR == ofd ) {
	call error(1, "Cannot open output event list file")
    }

    # open the ascii header template for writing

    ohd = open(Memc[outhead], NEW_FILE, TEXT_FILE)

    if ( ERR == ohd ) {
	call error(1, "Cannot open output event list file")
    }

    # get the header of the reference qpoe file
    # fill the qp info strucuture

    call qpfill(refhead, qpinfo)

    if ( display > 2 ) {
	call pr_qpinfo(qpinfo)
    }

    # open input src table and define columns and determine the
    # number of sources

    call init_stab(iptr, icolptr, numsrcs)

    # initialize boolean, prf table hasn't been opened yet

    prftopen = FALSE

    # set the seed for the random number generator

    set_time = 0.0
    seed = clktime(set_time)

    do srcno = 1, numsrcs {
	
	# get information for this source from the table file

	call get_src_info(iptr, icolptr, srcno, qpinfo, srcinfo, good_src)

	# good source tells us if the source position lies within the
	# field.  Print information to user if we are skipping this 
	# source, process otherwise.

	if ( ! good_src ) {
	    call printf("Source number %d at position (%d, %d) falls outside \n")
 	      call pargi(srcno)
 	      call pargi(SRCX(srcinfo))
	      call pargi(SRCY(srcinfo))
	    call printf("of allowed field limits, [%d : %d]. \n")
	      call pargi(SIM_QPLL(qpinfo))
	      call pargi(SIM_QPUL(qpinfo))
  	    call printf("Skipping this source ... \n\n")
	    call fseti (STDOUT, F_FLUSHNL, YES)
	}
	
	else {

	    # calculate the source counts

	    call get_srccts(srcinfo, qpinfo, display)

	    # treat the bkgd separately

	    if ( streq(PTYPE(srcinfo), "bkgd") ) {
	    	if ( INTENS(srcinfo) > EPSILONR ) {

	 	    if ( display > 2 ) {
		     	call pr_srcinfo(srcinfo)
		    }
		    if ( display > 0 ) {
			call printf("Generating random background events ... \n\n")
		    }

	 	    call get_bkg(qpinfo, SRCCTS(srcinfo), ofd)
	    	}
 	    }
	    else {	    # we have a real source

	   	# get the source type and related parameter value

 	    	call define_src(srcinfo, qpinfo, prftopen, ptp, pcolptr, display)

	    	if ( display > 2 ) {
                    call pr_srcinfo(srcinfo)
            	}

	   	# loop over the number of events
	    	# get_event calls the appropriate PRF routine

		# If we are using the HRI prf, we need to calculate
	 	# a normailization factor.  We do this for each
		# source (ie., each value of off axis angle).  The
		# value is stored in a common block

		if ( HRI_PRF == SRCTYPE(srcinfo) ) {
		    hri_norm = calc_hri_prf(double(SRCPAR(srcinfo)), MAX_RT)
		    if ( display > 2 ) {
		 	call printf("normalization factor for this source is : %.5f \n\n")	
			  call pargd(hri_norm)
		    }
		}
		
	    	do jj=1, SRCCTS(srcinfo) {

		    call get_event(srcinfo, qpinfo, evtx, evty)
	   	    call fprintf(ofd, "%d  %d \n")
		      call pargi(evtx)
		      call pargi(evty)
	    	}

	    }
	}
    }

    # write out ascii header template

    call mk_hdr(refhead, qpinfo, ohd)

    # close output files and free allocated memory

    call close(ofd)
    call close(ohd)

    call sfree(sp)
    call mfree(refhead, TY_STRUCT)

    call mfree(SIM_TPTR(qpinfo), TY_CHAR)
    call mfree(SIM_IPTR(qpinfo), TY_CHAR)
    call mfree(qpinfo, TY_STRUCT)

    call mfree(IPTR(srcinfo), TY_CHAR)
    call mfree(PPTR(srcinfo), TY_CHAR)
    call mfree(srcinfo, TY_STRUCT)

    call tbtclo(iptr)

    if ( prftopen ) {

    	call tbtclo(ptp)
    }
    
    if ( display > 0 ) {
	call printf("SIMEVT all done.\n")
    }
    
end
