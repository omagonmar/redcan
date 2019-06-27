# $Header: /home/pros/xray/xspatial/eintools/src_cnts/RCS/src_cnts.x,v 11.0 1997/11/06 16:31:25 prosb Exp $
# $Log: src_cnts.x,v $
# Revision 11.0  1997/11/06 16:31:25  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:24  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  14:44:36  dvs
#Fixed documentation, removed exp_max parameter.
#
#Revision 1.1  94/03/15  09:10:28  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       src_cnts.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_src_cnts
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <qpc.h>
include <ext.h>

#--------------------------------------------------------------------------
# Procedure:    t_src_cnts()
#
# Purpose:      Main procedure call for the task src_cnts
#
# Input parameters:
#               qpoefile        input qpoe file 
#               srcfile         input source file
#               expfile         input exposure file
#               pi_band		PI band
#		br_edge_filt	filter to use to remove bright edge
#		src_rad		source radius
#		bkgd_ann_in	inner radius of bkgd annulus
#		bkgd_ann_out	outer radius of bkgd annulus
#		soft_cmsc	circle mirror scat. corr. for soft band
#		soft_cprc	circle point resp. corr. for soft band
#		hard_cmsc	circle mirror scat. corr. for hard band
#		hard_cprc	circle point resp. corr. for hard band
#               display         display level
#
# Output parameters:
#		src_cts		output source counts
#
# Description:  This procedure reads in the appropriate parameters and
#               calls the routine "src_cnts" which finds the number
#		of image counts due to the sources listed in the
#		source file.
#
#		What's the difference between a PI band and a PI range?
#		A band could be any of "soft", "hard", "broad", "all", 
#		or some range of values.  A PI range can only be a range
#		of values, such as "2:4" or "1:8,10:12".
#--------------------------------------------------------------------------
procedure t_src_cnts()
pointer p_qpoe_expr     # pointer to input qpoe expression 
                        #   (e.g., "i2060.qp[time=1000000:2000000]")
pointer p_src_name	# pointer to input source filename
pointer p_exp_name      # pointer to input exposure filename
pointer p_pi_band	# pointer to PI band
pointer p_br_edge_filt  # pointer to bright edge filter
double	counts		# output counts
double	src_rad		# source radius
double	bkgd_ann_in	# inner radius of bkgd annulus
double	bkgd_ann_out    # outer radius of bkgd annulus
double	s_cmsc		# circle mirror scat. corr. for soft band
double	s_cprc		# circle point resp. corr. for soft band
double	h_cmsc		# circle mirror scat. corr. for hard band
double	h_cprc		# circle point resp. corr. for hard band
int     display         # display level (0-5)

### LOCAL VARS ###

pointer sp        	# stack pointer
pointer p_qpoe_evlist   # pointer to event list portion of qpoe expression
pointer p_qpoe_name     # pointer to qpoe filename
pointer	p_pi_range	# pointer to PI range

### BEGINNING OF PROCEDURE ###

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
        call salloc( p_src_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_exp_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_evlist, SZ_EXPR, TY_CHAR)
	call salloc( p_pi_band, SZ_EXPR, TY_CHAR)
	call salloc( p_br_edge_filt, SZ_EXPR, TY_CHAR)
	call salloc( p_pi_range, SZ_EXPR, TY_CHAR)
	
        #----------------------------------------------
        # read in parameters
        #----------------------------------------------
        call clgstr("qpoefile",Memc[p_qpoe_expr],SZ_PATHNAME)
        call clgstr("srcfile",Memc[p_src_name],SZ_PATHNAME)
        call clgstr("expfile",Memc[p_exp_name],SZ_PATHNAME)
        call clgstr("pi_band",Memc[p_pi_band],SZ_EXPR)
        call clgstr("br_edge_filt",Memc[p_br_edge_filt],SZ_EXPR)
	src_rad=clgetd("src_rad")
	bkgd_ann_in=clgetd("bkgd_ann_in")
	bkgd_ann_out=clgetd("bkgd_ann_out")
	s_cmsc=clgetd("soft_cmsc")
	s_cprc=clgetd("soft_cprc")
	h_cmsc=clgetd("hard_cmsc")
	h_cprc=clgetd("hard_cprc")
	display=clgeti("display")

        #----------------------------------------------
        # massage the input parameter filenames:
        #    remove white space around filenames
	#    add roots to names
        #----------------------------------------------
        call strip_whitespace(Memc[p_qpoe_expr])
        call strip_whitespace(Memc[p_src_name])
        call strip_whitespace(Memc[p_exp_name])
        call strip_whitespace(Memc[p_pi_band])
        call strip_whitespace(Memc[p_br_edge_filt])
	call rootname(Memc[p_qpoe_expr],Memc[p_qpoe_expr],
		      EXT_QPOE,SZ_PATHNAME) 
	call rootname(Memc[p_qpoe_expr],Memc[p_exp_name],
		      EXT_EXPOSURE,SZ_PATHNAME) 

        #----------------------------------------------
        # seperate qpoe expression into name & evlist
        #----------------------------------------------
	call qp_parse(Memc[p_qpoe_expr], Memc[p_qpoe_name], SZ_PATHNAME,
		      Memc[p_qpoe_evlist], SZ_EXPR)

	#---------------------------------------------------
        # convert pi band into range: "soft" to "2:4", etc.
        #---------------------------------------------------
	call band2range(Memc[p_pi_band],p_pi_range)

	if (display>3)
	{
	    call printf("Using qpoe file %s with event list \"%s\"\n")
	     call pargstr(Memc[p_qpoe_name])
	     call pargstr(Memc[p_qpoe_evlist])
	    call printf("with source table %s and exposure file %s\n")
	     call pargstr(Memc[p_src_name])
	     call pargstr(Memc[p_exp_name])
	    call printf("to find source counts.\n")
	}

        #----------------------------------------------
        # calculate source counts
        #----------------------------------------------
	call src_cnts(Memc[p_qpoe_name],Memc[p_qpoe_evlist],
 		      Memc[p_src_name], Memc[p_exp_name],
		      Memc[p_pi_range],Memc[p_br_edge_filt],
		      src_rad, bkgd_ann_in, bkgd_ann_out,
		      s_cmsc, s_cprc, h_cmsc, h_cprc,
		      counts,display )

        #----------------------------------------------
        # put output param
        #----------------------------------------------
	call clputd("src_cts",counts)
	
	if (display>0)
	{
	   call printf("\nFound source counts of image to be %.2f.\n")
	     call pargd(counts)
	}

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end
