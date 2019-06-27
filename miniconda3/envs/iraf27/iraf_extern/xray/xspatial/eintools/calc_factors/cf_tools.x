# $Header: /home/pros/xray/xspatial/eintools/calc_factors/RCS/cf_tools.x,v 11.0 1997/11/06 16:31:26 prosb Exp $
# $Log: cf_tools.x,v $
# Revision 11.0  1997/11/06 16:31:26  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:28  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  13:57:32  dvs
#Fixed documentation.
#
#Revision 1.1  94/03/31  10:57:26  prosb
#Initial revision
#
#
#
#--------------------------------------------------------------------------
# Module:       cf_tools.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     calc_factors
# Internal:     mk_fact, cf_check_pi, cf_check_time, cf_check_cts
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <qpoe.h>
include "../source/et_err.h"
include "../tables/bkfac.h"
include "../source/array.h"
include "../source/band.h"

#--------------------------------------------------------------------------
# Procedure:    calc_factors()
#
# Purpose:      Calculate BE/DS factors for background factors table
#
# Input variables:
#               qpoe_name       input qpoe file name
#               qpoe_evlist     associated event list (e.g. "[time=10:50]")
#               bkf_name        input background factors table
#               pi_range        PI range to make counts for
#		be_name		name of bright Earth map
#		ds_name		name of deep survey map
#		br_edge_reg	region for be/ds to remove bright edge
#               br_edge_filt    filter for qpoe to use to remove bright edge
#		src_cts		number of counts from sources in qpoe
#               min_grp_time    min. group time for using group counts
#               display         display level
#
# Description:  This is the main routine for the task calc_factors.  
#		This routine should be run after a background factors
#		table has been created (with bkfac_make).  This routine
#		will fill in the BE_FACT and DS_FACT columns with the
#		appropriate bright Earth and deep survey factors.
#
#		The final BKFAC table will contain all the information
#		needed for the be_ds_rotate task to create the
#		background map for the QPOE.  The factors are the
#		weights to apply on the bright Earth and deep survey
#		maps.
#
#		This routine performs a variety of checks on the
#		input files:
#
#		* Check that the nominal RA & DEC match between
#		  the QPOE file and BKFAC table.  [ERROR if no match]
#
#		* This routine checks that the PI-BAND	headers in 
#		  the BE and DS maps and the BKFAC table match each 
#		  other and the passed in pi_range.  
#
#		* This routine checks that the sum of the times in
#		  the BKFAC table is close to the QPOE exposure
#		  time times its dead-time correction.
#
#		* It also checks that the total counts (PI_CTS column
#		  in the BKFAC table) matches the counts in the QPOE
#		  file (with the appropriate filters).
#
#		If any of the last three checks don't match, the user is
#		given a warning.  We use the total livetime and counts
#		from the BKFAC to do the calculations, even if they
#		differ from the QPOE livetime & counts.
#
#		Finally, this task also writes the following header
#		keywords to the BKFAC table:
#
#		BECTS, DSCTS: total counts found in BE and DS images
#		DSTIME: livetime of DS map (read from DS header)
#
#		These values can be used in other routines to ensure
#		that this BKFAC table is used with the same BE and
#		DS maps, since the factors depends on those maps.
#                       
# Note:		It would be nice if we didn't have to ask for both
#		the br_edge_reg and br_edge_filt, since they are
#		screening out the same thing.  Unfortunately, we
#		have no easy way to translate between regions and
#		filters.
#--------------------------------------------------------------------------
procedure calc_factors(qpoe_name,qpoe_evlist,bkf_name,pi_range,
		      be_name,ds_name,br_edge_reg,br_edge_filt,
		      src_cts,min_grp_time,display )
char    qpoe_name[ARB]    # i: input qpoe file name
char    qpoe_evlist[ARB]  # i: associated event list (e.g. "[time=10:50]")
char    bkf_name[ARB]     # i: output BKFAC name
char    pi_range[ARB]     # i: PI range to make counts for
char    be_name[ARB]	  # i: bright Earth map 
char    ds_name[ARB]	  # i: deep survey map
char    br_edge_reg[ARB]  # i: region for be/ds to remove bright edge
char    br_edge_filt[ARB] # i: filter to use to remove bright edge
double	src_cts		  # i: number of counts from sources in qpoe
double  min_grp_time	  # i: min. group time for using group counts
int     display		  # i: display level

### LOCAL VARS ###

double	area		# [unused] num. of pixels in region
int	n_bkfac		# number of rows in BKFAC
pointer p_bkf_info	# pointer to BKFAC info (see gt_info.x)
pointer p_bkfac_data	# pointer to data read from BKFAC
pointer	c_bkfac_data	# pointer to current bkfac row
int	i_bkfac		# which row we're reading
pointer col_ptr[N_COL_BKFAC] # column pointers for BKFAC
double	be_cts		# number of counts in bright Earth image
double  ds_cts		# number of counts in deep survey image
double	dstime		# livetime for DS (read from DS)
pointer ip_be		# BE image pointer
pointer ip_ds		# DS image pointer
double	tot_cts		# total counts in BKFAC
double  tot_livetime	# total livetime in BKAC
pointer qp              # QPOE file pointer
pointer qphead          # QPOE header
pointer tp		# pointer to BKFAC table

### EXTERNAL FUNCTION DECLARATIONS ###

double	cf_check_cts() # returns total counts in BKFAC [local]
double	cf_check_time() # returns total livetime in BKFAC [local]
double	get_dstime()  # returns livetime of DS map [../source/bkmap.x]
int     gt_open()     # returns number of rows in table [../tables/gt_file.x]
pointer immap()	      # returns pointer to image [sys/imio]
double  im_cts()      # returns no. coutns in image [lib/pros/im_cts.x]
pointer	qp_open()     # returns pointer to QPOE [sys/qpio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# open BKFAC table
        #----------------------------------------------
        call bkf_setup(false,OTHER_BAND,p_bkf_info)
        n_bkfac=gt_open(bkf_name,READ_WRITE,tp,col_ptr,p_bkf_info)

        #----------------------------------------------
	# open qpoe file and read in header
        #----------------------------------------------
        qp=qp_open(qpoe_name,READ_ONLY,0)
        call get_qphead(qp,qphead)

        #----------------------------------------------
	# open BE and DS images
        #----------------------------------------------
	ip_be=immap(be_name,READ_ONLY, 0)
	ip_ds=immap(ds_name,READ_ONLY, 0)

        #----------------------------------------------
	# calculate BE and DS image counts
        #----------------------------------------------
	be_cts=im_cts(ip_be,br_edge_reg,area)
	ds_cts=im_cts(ip_ds,br_edge_reg,area)

        #----------------------------------------------
	# get dstime
        #----------------------------------------------
	dstime=get_dstime(ip_ds)
	
	if (display>4)
	{
	    call printf("be_cts=%.5f, ds_cts=%.5f, dstime=%.5f.\n")
	     call pargd(be_cts)
	     call pargd(ds_cts)
	     call pargd(dstime)
	    call flush(STDOUT)
	}

        #----------------------------------------------
	# read BKFAC info into memory
        #----------------------------------------------
	call malloc(p_bkfac_data,SZ_BKFAC*n_bkfac,TY_STRUCT)
	call gt_get_rows(tp,p_bkf_info,col_ptr,1,n_bkfac,false,
				p_bkfac_data)


        #----------------------------------------------
	# Check nominal RA&DEC, PI values, livetimes,
	# and image counts.  Returns tot_livetime and
	# tot_cts.
        #----------------------------------------------
	call check_nom(qphead,tp,display)
	call cf_check_pi(pi_range,tp,ip_be,ip_ds,display)
	tot_livetime=cf_check_time(p_bkfac_data,n_bkfac,
				qp,qphead,qpoe_evlist,display)
	tot_cts=cf_check_cts(p_bkfac_data,n_bkfac,
	         qp,qphead,qpoe_evlist,pi_range,br_edge_filt,display)


        #----------------------------------------------
	# calculate factors for each row!
        #----------------------------------------------
	do i_bkfac=1,n_bkfac
	{
	    c_bkfac_data=BKFAC(p_bkfac_data,i_bkfac)
	    call mk_fact(qphead,tot_livetime,tot_cts,dstime,ds_cts,be_cts,
				src_cts,min_grp_time,c_bkfac_data,display)
	    call gt_put_row(c_bkfac_data,tp,p_bkf_info,col_ptr,i_bkfac)

	}

        #----------------------------------------------
	# write out ds/be counts & ds time
        #----------------------------------------------
	call tbhadd(tp,BK_BECTS,be_cts)
	call tbhadd(tp,BK_DSCTS,ds_cts)
	call tbhadd(tp,BK_DSTIME,dstime)

        #----------------------------------------------
	# free up data
        #----------------------------------------------
	call mfree(p_bkfac_data,TY_STRUCT)
        call tbtclo(tp)
        call gt_free_info(p_bkf_info)
	call imunmap(ip_be)
	call imunmap(ip_ds)
        call mfree(qphead,TY_STRUCT)
        call qp_close(qp)
end

#--------------------------------------------------------------------------
# Procedure:    mk_fact
#
# Purpose:      Calculate BE and DS factors and add to BKFAC structure
#
# Input variables:
#		qphead		QPOE header
#               i_obi           which OBI we are creating
#		tot_livetime	total livetime in BKFAC
#		tot_cts		total image counts in BKFAC
#		dstime		deep survey live time
#		ds_cts		deep survey image counts
#		be_cts		bright Earth image counts
#		src_cts		counts due to sources in QPOE
#               min_grp_time    min. group time for using group counts
#		p_bkfac		BKFAC row to fill in
#		display		display level
#
# Description:  This routine calculates the bright Earth and deep survey
#		weights for a particular row of the BKFAC table.  
#
#		DS-FACTOR formula:
#
#		dsfac = lt/dstime 
#
#
# 		BE-FACTOR formula:
#
#  		befac = (1/be_cts)(gp_cts-(gp_lt/lt)*scts-ds*ds_counts)
#
#  		where gp_cts is the actual group counts when gp_lt>min_grp_time
#            	    or is the weighted group counts
#                                   ((gp_lt/lt)*im_cts) when gp_lt<=min_grp_time
#
#		Thus if the livetime of the row does not meet the minimum 
#		threshold, we consider the group "PI_CTS" to be potentially
#		suspect, and use an average group counts instead.
#--------------------------------------------------------------------------

procedure mk_fact(qphead,tot_livetime,tot_cts,dstime,ds_cts,be_cts,
				src_cts,min_grp_time,p_bkfac,display)
pointer qphead		# i: QPOE header
double  tot_livetime	# i: total livetime in BKFAC
double	tot_cts		# i: total image counts in BKFAC
double	dstime		# i: deep survey live time
double	ds_cts		# i: deep survey image counts
double	be_cts		# i: bright Earth image counts
double	src_cts		# i: counts due to sources in QPOE
double  min_grp_time	# i: min. group time for using group counts
pointer	p_bkfac		# io: BKFAC row
int     display		# i: display level

double	gp_cts		# number of counts in current row

begin
	if (BK_LIVETIME(p_bkfac)>min_grp_time)
	{
	    gp_cts=BK_PI_CTS(p_bkfac)
	}
	else
	{
	    gp_cts=(BK_LIVETIME(p_bkfac)/tot_livetime)*tot_cts
	}
	
	BK_DSFAC(p_bkfac)=BK_LIVETIME(p_bkfac)/dstime

	BK_BEFAC(p_bkfac)=(gp_cts-
		   (BK_LIVETIME(p_bkfac)/tot_livetime)*src_cts-
		    BK_DSFAC(p_bkfac)*ds_cts)/be_cts

end


#--------------------------------------------------------------------------
# Procedure:    cf_check_pi
#
# Purpose:      Check that the PI band matches between input files
#
# Input variables:
#               pi_range	user-specified PI range
#		tp		BKFAC table
#		ip_be		bright Earth image pointer
#		ip_ds		deep survey image pointer
#		display		display level
#
# Description:  This routine checks that the PI ranges match between
#		the BKFAC table, the bright Earth, the deep survey, and
#		the user-specified PI range.
#
#		If they don't match, this routine issues a warning.
#
# Note:		The "PIBAND" read from the table and image pointer will
#		always be in range format, i.e. "2:4" or "8:9,11:12"
#
#		It is possible to get an error when there is no problem.
#		For instance, the pi ranges "2:3,3:4" will be considered
#		different from "2:4".
#--------------------------------------------------------------------------

procedure cf_check_pi(pi_range,tp,ip_be,ip_ds,display)
char	pi_range[ARB]	# i: user-specified PI range
pointer	tp		# i: table pointer
pointer ip_be		# i: BE image pointer
pointer ip_ds		# i: DS image pointer
int	display		# i: display level

### LOCAL VARS ###

pointer p_pi_band	# temporary PI range read from BKFAC table

### EXTERNAL FUNCTION DECLARATIONS ###

bool	streq()		# TRUE if strings are equal [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# Set aside memory for PI band
        #----------------------------------------------
	call malloc(p_pi_band,SZ_LINE,TY_CHAR)

        #----------------------------------------------
	# Read PIBAND from BKFAC table
        #----------------------------------------------
	call tbhgtt(tp,BK_PIBAND,Memc[p_pi_band],SZ_LINE)
        call strip_whitespace(Memc[p_pi_band])

        #----------------------------------------------
	# compare pi-range to that found in BKFAC table
        #----------------------------------------------
	if (!streq(pi_range,Memc[p_pi_band]) && display>0)
	{
	    call printf("\nWARNING: BKFAC table PI band differs:\n")
	    call printf("Found (%s), expected (%s).\n")
	     call pargstr(Memc[p_pi_band])
	     call pargstr(pi_range)
	    call flush(STDOUT)
	}
	call mfree(p_pi_band,TY_CHAR)	

        #----------------------------------------------
	# compare pi-range to that found in BE & DS images
        #----------------------------------------------
	call beds_check_pi(ip_be,ip_ds,pi_range,display)
end


#--------------------------------------------------------------------------
# Procedure:    cf_check_time
#
# Purpose:      Check that the livetime matches between QPOE & BKFAC table
#
# Input variables:
#               p_bkfac_data	data from BKFAC table
#		n_bkfac		number of rows
#		qp		QPOE
#		qphead		QPOE header
#		qpoe_evlist	user-input event list
#               display         display level
#
# Return value:
#		Returns the total livetime found in BKFAC table.
#
# Description:  This routine sums the livetime values in the BKFAC table
#		and compares them to the livetime (exposure times dead
#		time correction) in the QPOE file.  This checks that
#		the user has entered the same QPOE file and the same
#		event list [QPOE filter].  It also checks the algorithm
#		of BKFAC_MAKE.
#
#		We only display a warning if the difference in time is
#		greater than one second.
#
#		For screened data, each BLT record is missing 0.32 seconds,
#		and thus the BKFAC could easily be off by several seconds
#		from the QPOE file.  
#
#		There are also other inconsistencies between BLT records
#		and GTI records, leaving gaps of 41 seconds or more. 
#		Again, these will be recognized here and told to the
#		user.
#
# Note:		We can't just use the LIVETIME in the QPOE header; it
#		will not reflect the user's filter on the QPOE, and isn't
#		updated with time filtering.
#--------------------------------------------------------------------------
double procedure cf_check_time(p_bkfac_data,n_bkfac,
				qp,qphead,qpoe_evlist,display)
pointer p_bkfac_data	# i: BKFAC data	
int	n_bkfac		# i: number of BKFAC records
pointer	qp		# i: QPOE file
pointer	qphead		# i: QPOE header
char    qpoe_evlist[ARB] # i: QPOE event list
int     display		# i: display level

### LOCAL VARS ###

int	i_bkfac		# which BKFAC we are looking at
pointer	c_bkfac		# pointer to current BKFAC record
double	bkf_time	# total time in BKFAC table
double	exp_time	# QPOE's exposure time
pointer blist		# [unused] list of beginning GTI times
pointer	elist		# [unused] list of ending GTI times
int	nlist		# [unused] number of GTI times
double	qp_time		# QPOE's livetime

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# Get total time in BKFAC table
        #----------------------------------------------
	bkf_time=0.0D0
	do i_bkfac=1,n_bkfac
	{
	    c_bkfac=BKFAC(p_bkfac_data,i_bkfac)
	    bkf_time=bkf_time+BK_LIVETIME(c_bkfac)
	}

        #----------------------------------------------
	# GET QP_TIME
        #----------------------------------------------
	call get_qpexp(qp, qpoe_evlist, display, blist, elist, nlist, exp_time)
	call mfree(blist,TY_DOUBLE)
	call mfree(elist,TY_DOUBLE)

	qp_time=exp_time*QP_DEADTC(qphead)	 

        #----------------------------------------------
	# COMPARE THE TWO
        #----------------------------------------------
        if (abs(qp_time-bkf_time)>1.0 && display>0)
        {
	   call printf("\nWARNING: Total livetime in the background factors table (%.5f)\n") 
	    call pargd(bkf_time)
	   call printf("does not match the livetime in the qpoe file (%.5f).\n")
	    call pargd(qp_time)
	   call flush(STDOUT)
	   
	}
	else if (display>4)
	{
	    call printf("Image time=%.5f, bkfac total livetime=%.5f.\n")
	     call pargd(qp_time)
	     call pargd(bkf_time)
	   call flush(STDOUT)
	}

        #----------------------------------------------
	# Return total BKFAC livetime
        #----------------------------------------------
	return bkf_time
end


#--------------------------------------------------------------------------
# Procedure:    cf_check_cts
#
# Purpose:      Check that the image counts between QPOE & BKFAC table
#
# Input variables:
#               p_bkfac_data    data from BKFAC table
#               n_bkfac         number of rows
#               qp              QPOE
#               qphead          QPOE header
#               qpoe_evlist     user-input event list
#               pi_range        range of PI values
#               br_edge_filt    bright edge filter 
#               display         display level
#
# Return value:
#               Returns the total image counts found in BKFAC table.
#
# Description:  This routine sums the image counts in the BKFAC table
#               and compares them to the counts in the QPOE file.  This 
#		checks that the user has entered the same QPOE file and the 
#               same event list [QPOE filter].  
#
#               We only display a warning if the difference in counts is
#               greater than one photon.
#
#		There will probably be differences in counts if there
#		was a difference in livetime, since photons may arrive
#		during the difference in time intervals.
#--------------------------------------------------------------------------
double procedure cf_check_cts(p_bkfac_data,n_bkfac,
	         qp,qphead,qpoe_evlist,pi_range,br_edge_filt,display)

pointer p_bkfac_data    # i: BKFAC data
int     n_bkfac         # i: number of BKFAC records
pointer qp              # i: QPOE file
pointer qphead          # i: QPOE header
char    qpoe_evlist[ARB] # i: QPOE event list
char    pi_range[ARB]           # i: PI range
char    br_edge_filt[ARB]       # i: bright edge filter
int     display         # i: display level

### LOCAL VARS ###

int     i_bkfac         # which BKFAC we are looking at
pointer c_bkfac         # pointer to current BKFAC record
double	bkf_cts		# total BKFAC image counts
pointer	p_qpfilter	# string filter for QPOE (including PI range, bright
			# edge filter, and QPOE event list)
pointer	p_filter	# QPOE filter plus brackets
double	qp_tot_cts	# total counts in QPOE 

### EXTERNAL FUNCTION DECLARATIONS ###

int	qp_cts()	# returns counts in QPOE.  [pros/lib/pros/im_cts.x]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	### Get total counts in BKFAC table
        #----------------------------------------------
	bkf_cts=0.0D0
	do i_bkfac=1,n_bkfac
	{
	    c_bkfac=BKFAC(p_bkfac_data,i_bkfac)
	    bkf_cts=bkf_cts+BK_PI_CTS(c_bkfac)
	}

        #----------------------------------------------
	# Make QPOE filter 
        #----------------------------------------------
	call mk_qpfilter(qpoe_evlist,br_edge_filt,pi_range,p_qpfilter,display)
	call add_brack(Memc[p_qpfilter],p_filter)

        #----------------------------------------------
	# Find QPOE counts
        #----------------------------------------------
	qp_tot_cts=qp_cts(qp,Memc[p_filter])

        #----------------------------------------------
	# Compare QPOE counts to BKFAC counts
        #----------------------------------------------
        if (abs(qp_tot_cts-bkf_cts)>1.0 && display>0)
        {
	   call printf("\nWARNING: Total counts in the background factors table (%.5f)\n")
	    call pargd(bkf_cts)
	   call printf("do not match the number of counts in the qpoe file (%.5f).\n")
	    call pargd(qp_tot_cts)
	   call flush(STDOUT)
	   
	}
	else

	if (display>4)
	{
	    call printf("Qpoe cts=%.5f, bkfac total cts=%.5f.\n")
	     call pargd(qp_tot_cts)
	     call pargd(bkf_cts)
	   call flush(STDOUT)
	}

        #----------------------------------------------
	# Free memory
        #----------------------------------------------
	call mfree(p_filter,TY_CHAR)
	call mfree(p_qpfilter,TY_CHAR)

        #----------------------------------------------
	# Return BKFAC counts!
        #----------------------------------------------
	return bkf_cts
end



