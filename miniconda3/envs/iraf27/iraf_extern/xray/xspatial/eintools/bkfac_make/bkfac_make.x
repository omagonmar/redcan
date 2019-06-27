#
#--------------------------------------------------------------------------
# Module:       bkfac_make.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_bkfac_make
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 10/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <qpc.h>
include <ext.h>

#--------------------------------------------------------------------------
# Procedure:    t_bkfac_make()
#
# Purpose:      Main procedure call for the task bkfac_make
#
# Input parameters:
#               qpoefile        input qpoe file 
#		bkfacfile	name of output BKFAC table
#               pi_band         PI band to make counts for
#               br_edge_filt    filter to use to remove bright edge
#               gti_ext         name of GTI extension ['' for default]
#		obi_name	name of OBI column in GTI extension
#		use_obi		Should we average aspects in OBIs?
#		max_off_diff	maximum differences for aspect groups
#		dist_to_edge	pixels to edge of field
#               display         display level
#               clobber         overwrite output file?
#
# Description:  This procedure reads in the appropriate parameters and
#               calls the routine "bkfac_make" which creates a background
#		factors table from the BLT and GTI information in the
#		passed qpoe file.
#--------------------------------------------------------------------------
procedure t_bkfac_make()
pointer p_qpoe_expr	# pointer to input qpoe expression 
			#   (e.g., "i2060.qp[time=1000000:2000000]")
pointer p_bkfac_name	# pointer to output BKFAC name
pointer p_pi_band       # pointer to PI band
pointer p_br_edge_filt  # pointer to bright edge filter
pointer p_gti_ext	# pointer to name of GTI extension in QPOE
pointer	p_obi_name	# pointer to OBI column name in GTI
bool	use_obi		# should we average aspects within OBIs?
double  max_off_diff	# max. offset difference
double	dist_to_edge	# distance to edge of field
bool    clobber         # flag: should we allow clobbering of output?
int     display         # display level (0-5)

### LOCAL VARS ###

pointer p_bkfac_name_temp # pointer to temporary name for output file
int	n_bkfac		# number of rows in output bkfac
pointer p_qpoe_evlist   # pointer to event list portion of qpoe expression
pointer p_qpoe_name     # pointer to qpoe filename
pointer p_pi_range	# pointer to PI range
pointer sp        	# stack pointer

### EXTERNAL FUNCTION DECLARATIONS ###

bool    clgetb()  # returns boolean CL parameter [sys/clio]
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
        call salloc( p_bkfac_name_temp, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_evlist, SZ_EXPR, TY_CHAR)
	call salloc( p_pi_band, SZ_EXPR, TY_CHAR)
	call salloc( p_pi_range, SZ_EXPR, TY_CHAR)
	call salloc( p_br_edge_filt, SZ_EXPR, TY_CHAR)
	call salloc( p_gti_ext, SZ_EXPR, TY_CHAR)
	call salloc( p_obi_name, SZ_EXPR, TY_CHAR)
	
        #----------------------------------------------
        # read in parameters
        #----------------------------------------------
        call clgstr("qpoefile",Memc[p_qpoe_expr],SZ_PATHNAME)
        call clgstr("bkfacfile",Memc[p_bkfac_name],SZ_PATHNAME)
        call clgstr("pi_band",Memc[p_pi_band],SZ_EXPR)
        call clgstr("br_edge_filt",Memc[p_br_edge_filt],SZ_EXPR)
        call clgstr("gti_ext",Memc[p_gti_ext],SZ_EXPR)
        call clgstr("obi_name",Memc[p_obi_name],SZ_EXPR)
	use_obi=clgetb("use_obi")
	max_off_diff=clgetd("max_off_diff")
	dist_to_edge=clgetd("dist_to_edge")
	display=clgeti("display")
	clobber=clgetb("clobber")

        #----------------------------------------------
        # massage the input parameter filenames:
        #    remove white space around filenames
	#    add roots to names
        #----------------------------------------------
        call strip_whitespace(Memc[p_qpoe_expr])
        call strip_whitespace(Memc[p_bkfac_name])
        call strip_whitespace(Memc[p_obi_name])
        call strip_whitespace(Memc[p_gti_ext])
	call rootname(Memc[p_qpoe_expr],Memc[p_qpoe_expr],
		      EXT_QPOE,SZ_PATHNAME) 
	call rootname(Memc[p_qpoe_expr],Memc[p_bkfac_name],
		      EXT_BKFAC,SZ_PATHNAME) 

        #----------------------------------------------
        # convert pi band into range: "soft" to "2:4", etc.
        #----------------------------------------------
	call band2range(Memc[p_pi_band],p_pi_range)

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
	    call printf("to create bkgd factor table %s.\n")
	     call pargstr(Memc[p_bkfac_name])
	    call printf("Pi range=[%s], gti_ext=%s, bright edge filter=[%s].\n")
	     call pargstr(Memc[p_pi_range])
	     call pargstr(Memc[p_gti_ext])
	     call pargstr(Memc[p_br_edge_filt])
	    if (!use_obi)
	    {
		call printf("Not using OBI information from GTI extension.\n")
	    }
	}

        #----------------------------------------------
        # check if output file already exists
        #----------------------------------------------
	call clobbername(Memc[p_bkfac_name],Memc[p_bkfac_name_temp],
			 clobber,SZ_PATHNAME)

        #----------------------------------------------
        # make bkfac table!
        #----------------------------------------------
	call bkfac_make(Memc[p_qpoe_name],Memc[p_qpoe_evlist],
 		      Memc[p_bkfac_name_temp],Memc[p_bkfac_name],
		      Memc[p_pi_range],Memc[p_br_edge_filt],
		      Memc[p_gti_ext],Memc[p_obi_name],use_obi,
		      max_off_diff,dist_to_edge,n_bkfac,display )

        #----------------------------------------------
        # rename temp file to output file
        #----------------------------------------------
	call finalname(Memc[p_bkfac_name_temp],Memc[p_bkfac_name])

	if (display>0)
	{
	   call printf("\nCreated bkfac table %s with %d row(s).\n")
	     call pargstr(Memc[p_bkfac_name])
	     call pargi(n_bkfac)
	}

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end
