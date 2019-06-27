# $Header: /home/pros/xray/xspatial/eintools/calc_factors/RCS/calc_factors.x,v 11.0 1997/11/06 16:31:25 prosb Exp $
# $Log: calc_factors.x,v $
# Revision 11.0  1997/11/06 16:31:25  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:27  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/31  10:57:21  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       calc_factors.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_calc_factors
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <qpc.h>
include <ext.h>
include "../tables/bkfac.h"
include "../source/band.h"

#--------------------------------------------------------------------------
# Procedure:    t_calc_factors()
#
# Purpose:      Main procedure call for the task calc_factors
#
# Input parameters:
#               qpoefile        input qpoe file 
#               bkfacfile       name of input BKFAC table
#               pi_band         PI band to make counts for
#		src_cts		counts in image due to sources
#		defmaps		using default maps?
#		bemap		if not, which BEMAP?
#		dsmap		and which DSMAP?
#		def_[be/ds]_[hard/soft/broad] default pathnames for
#				be/dsmaps, for these three bands
#               br_edge_reg     region to use on blocked images to 
#				remove bright edge
#               br_edge_filt    filter to use on QPOE to remove bright edge
#		min_grp_time	min. group time for using group counts
#               display         display level
# 
#
# Description:  This procedure reads in the appropriate parameters and
#               calls the routine "calc_factors" to fill in the 
#		DS_FACT and BE_FACT columns of the BKFAC table.
#
# Note:		The parameters defmaps through the default be/ds 
#		pathnames are read in the routine beds_param.
#
#		Also note: br_edge_reg and br_edge_filt should be
#		describing the same region.  We can't check this!
#
#		Why do we use band2range, then range2band?  The first
#		routine (band2range) will convert the user declared
#		band into a range.  Thus "soft" becomes "2:4", etc.
#		The second routine, range2band, converts the range
#		into an index of possible bands.  (See band.h.)  Thus
#		the user can enter either "soft" or "2:4" and end up
#		with the SOFT_BAND band.
#--------------------------------------------------------------------------
procedure t_calc_factors()
pointer p_qpoe_expr	# pointer to input qpoe expression 
			#   (e.g., "i2060.qp[time=1000000:2000000]")
pointer p_bkfac_name	# pointer to input BKFAC name
pointer p_pi_band       # pointer to PI band
pointer	p_bemap		# BE map
pointer p_dsmap		# DS map
double	src_cts		# counts in QPOE due to sources
pointer p_br_edge_reg	# pointer to bright edge region (for be/ds images)
pointer p_br_edge_filt  # pointer to bright edge filter
double	min_grp_time	# minimum group time for using group counts
int     display         # display level (0-5)

### LOCAL VARS ###

pointer sp        	# stack pointer
pointer p_qpoe_evlist   # pointer to event list portion of qpoe expression
pointer p_qpoe_name     # pointer to qpoe filename
pointer p_pi_range      # pointer to PI range
int	band		# which band type?  (soft/hard/broad/other) [band.h]

### EXTERNAL FUNCTION DECLARATIONS ###

int     clgeti()  # returns integer CL parameter [sys/clio]
double	clgetd()  # returns double CL parameter [sys/clio]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # allocate space on stack & set aside memory
        #   for strings
        #----------------------------------------------
        call smark(sp)
        call salloc( p_qpoe_expr, SZ_PATHNAME, TY_CHAR)
        call salloc( p_bkfac_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_evlist, SZ_EXPR, TY_CHAR)
	call salloc( p_pi_band, SZ_EXPR, TY_CHAR)
	call salloc( p_pi_range, SZ_EXPR, TY_CHAR)
	call salloc( p_br_edge_reg, SZ_EXPR, TY_CHAR)
	call salloc( p_br_edge_filt, SZ_EXPR, TY_CHAR)
	call salloc( p_bemap, SZ_PATHNAME, TY_CHAR)
	call salloc( p_dsmap, SZ_PATHNAME, TY_CHAR)
	
        #----------------------------------------------
        # read in parameters
        #----------------------------------------------
        call clgstr("qpoefile",Memc[p_qpoe_expr],SZ_PATHNAME)
        call clgstr("bkfacfile",Memc[p_bkfac_name],SZ_PATHNAME)
        call clgstr("pi_band",Memc[p_pi_band],SZ_EXPR)
        call clgstr("br_edge_reg",Memc[p_br_edge_reg],SZ_EXPR)
	call clgstr("br_edge_filt",Memc[p_br_edge_filt],SZ_EXPR)
	src_cts=clgetd("src_cts")
	min_grp_time=clgetd("min_grp_time")
	display=clgeti("display")

        #---------------------------------------------------
        # convert pi band into range: "soft" to "2:4", etc.
        #---------------------------------------------------
        call strip_whitespace(Memc[p_pi_band])
	call band2range(Memc[p_pi_band],p_pi_range)

        #--------------------------------------------------
        # convert range into a band index (SOFT_BAND,
	#  HARD_BAND, BROAD_BAND, OTHER_BAND) [see band.h]
        #--------------------------------------------------
	call range2band(Memc[p_pi_range],band)

        #-------------------------------------------------------
	# read in bemap & dsmap from the appropriate parameter
        #-------------------------------------------------------
	call beds_param(band,Memc[p_bemap],Memc[p_dsmap])

        #----------------------------------------------
        # massage the input parameter filenames:
        #    remove white space around filenames
	#    add roots to names
        #----------------------------------------------
        call strip_whitespace(Memc[p_qpoe_expr])
        call strip_whitespace(Memc[p_bkfac_name])
        call strip_whitespace(Memc[p_bemap])
        call strip_whitespace(Memc[p_dsmap])
	call rootname(Memc[p_qpoe_expr],Memc[p_qpoe_expr],
		      EXT_QPOE,SZ_PATHNAME) 
	call rootname(Memc[p_qpoe_expr],Memc[p_bkfac_name],
		      EXT_BKFAC,SZ_PATHNAME) 

        #----------------------------------------------
        # seperate qpoe expression into name & evlist
        #----------------------------------------------
	call qp_parse(Memc[p_qpoe_expr], Memc[p_qpoe_name], SZ_PATHNAME,
		      Memc[p_qpoe_evlist], SZ_EXPR)

	if (display>3)
	{
	    call printf("Using qpoe file %s with event list \"%s\"\n")
	     call pargstr(Memc[p_qpoe_name])
	     call pargstr(Memc[p_qpoe_evlist])
	    call printf("to modify bkgd factor table %s.\n")
	     call pargstr(Memc[p_bkfac_name])
	    call printf("Using Bright Earth map %s\n")
	     call pargstr(Memc[p_bemap])
	    call printf("and deep survey map %s.\n")
	     call pargstr(Memc[p_dsmap])
	    call printf("Pi range=[%s], src_cts=%f, bright edge region=(%s).\n")
	     call pargstr(Memc[p_pi_range])
	     call pargd(src_cts)
	     call pargstr(Memc[p_br_edge_reg])
	    call flush(STDOUT)
	}

        #----------------------------------------------
        # calculate factors!
        #----------------------------------------------
	call calc_factors(Memc[p_qpoe_name],Memc[p_qpoe_evlist],
 		      Memc[p_bkfac_name],Memc[p_pi_range],
		      Memc[p_bemap],Memc[p_dsmap],Memc[p_br_edge_reg],
		      Memc[p_br_edge_filt],src_cts,min_grp_time,display )

	if (display>0)
	{
	   call printf("\nAdded background factors to table %s.\n")
	     call pargstr(Memc[p_bkfac_name])
	}

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end
