# $Header: /home/pros/xray/xtiming/vartst/RCS/vartst.x,v 11.0 1997/11/06 16:45:25 prosb Exp $
# $Log: vartst.x,v $
# Revision 11.0  1997/11/06 16:45:25  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:35:29  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:43:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:48  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:00:05  prosb
#General Release 2.2
#
#Revision 1.1  93/05/20  10:19:08  janet
#Initial revision
#
#
# -------------------------------------------------------------------------
# Module:	Vartst
# Project:	PROS -- ROSAT RSDC
# Purpose:	Task to determine aperiodic variability in a source.  We
#		perform the Ks-test and Cramer vonMises test on the data.
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JD - Mar 1993 - Initial Version
#
# -------------------------------------------------------------------------
include  <qpset.h>
include  <qpoe.h>
include  <ext.h>
include  "vartst.h"

procedure  t_vartst ()

bool     clobber		# clobber old file
bool 	 none

double   acctime		# accepted time
double   src_area		# source area
double   start_time		# start time for binning
double   stop_time		# stop time for binning

int      display		# display level (0-5)
int      nphots			# number of photons in qpoe
int      num_gintvs		# number of good time intvs
int	 soffset		# offset of named parameter
 
pointer  col_cp[10]             # output column pointer
pointer	 evlist			# name of input file
pointer	 gbegs			# gti begin times
pointer	 gends			# gti end times
pointer	 photon_file		# name of input file
pointer	 sp			# stack pointer
pointer  sqp			# src qpoe pointer
pointer  src_ptr		# src input pointer
pointer	 tempname 		# temp name of output file
pointer  tp			# table ptr 
pointer	 var_file		# name of output file

double   cvm			# Cramer-vonMises test result
real     d			# ks-test distribution
real     t90, t95, t99		# ks-test thresholds
real	 band			# cdf band width 
real     bthresh                # thresholg corresponding to cdf band

bool	 clgetb()				
int	 clgeti()
real	 clgetr()

begin
	call smark (sp)
	call salloc (photon_file,  SZ_PATHNAME, TY_CHAR)
	call salloc (evlist,  	   SZ_PATHNAME, TY_CHAR)
	call salloc (var_file,     SZ_PATHNAME, TY_CHAR)
	call salloc (tempname,     SZ_PATHNAME, TY_CHAR)

	display = clgeti(DISPLAY)
	clobber = clgetb(CLOBBER)
        band = clgetr(BANDWIDTH)

#  Get input filenames for source and background
	call tim_openqp(SOURCEFILENAME, EXT_STI, Memc[photon_file],
		        Memc[evlist], none, sqp, src_ptr)

#  Check input files for correct type ( must have TIME ) and 
#  get region areas
	call tim_cktime(sqp,"source",soffset)
	call tim_getarea(sqp,src_area)

#  Set up the output file
	call tim_outtable(VARFILENAME, EXT_VAR, photon_file, var_file,
			  tempname, clobber)
	call ks_inittab(Memc[tempname], clobber, sqp, Memc[photon_file],
                        col_cp, tp)

#  Get gintvs and compute accepted time
        call tim_gintvs (display, sqp, src_ptr, soffset, Memc[evlist], 
			 start_time, stop_time, gbegs, gends, num_gintvs,
                         acctime)

#  Determine the number of photons
        call get_nphots (src_ptr, display, soffset, nphots)

#  Tests starts here ...

        # Compute the probablility at 90, 95, and 99 percent
        call ks_thresh (nphots, band, t90, t95, t99, bthresh)

        # Determine if the source is variable using the ks-test
        call ksone (src_ptr, tp, col_cp, display, soffset, nphots,  
                    num_gintvs, Memd[gbegs], Memd[gends], acctime, 
                    bthresh, d, cvm)

        # Test if our source is variable, and report results
        call ks_prob (d, t90, t95, t99)

        # Test for CvM variability and report results
        call cvm_prob (cvm)

        # Write the ks-plot igi commands to a text file
        call wr_pltcmds (tp, Memc[var_file], clobber, nphots, start_time,
                         stop_time, acctime, d, t90, t95, t99, display)

        # Write the ks-plot band overlay to a text file
        call wr_ovrlycmds (Memc[var_file], acctime, display, clobber)

#   ... and ends here

# Update the output table header with more info
 	call var_fillhdr (tp, start_time, stop_time, acctime, src_area, 
                          cvm, d, t90, t95, t99, band, nphots)

# Close the input source file
	call tim_qpclose(sqp,src_ptr)
	
# Close the output file
	call tbtclo (tp)

# Finalize the names
	if ( display >= 1 ) {
	   call printf ("Creating Var file: %s\n")
	      call pargstr (Memc[var_file])
	}
	call finalname (Memc[tempname], Memc[var_file])

# Free the space
	call mfree (gbegs, TY_DOUBLE)
	call mfree (gends, TY_DOUBLE)
	call sfree (sp)
end
