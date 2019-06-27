# $Header: /home/pros/xray/xspatial/eintools/bkfac_make/RCS/bf_tools.x,v 11.0 1997/11/06 16:30:44 prosb Exp $
# $Log: bf_tools.x,v $
# Revision 11.0  1997/11/06 16:30:44  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:28  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  13:55:16  dvs
#Added code to convert default parameter (gti_ext) into appropriate
#value (gti or allgti).
#
#Revision 1.1  94/03/23  08:53:51  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       bf_tools.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     bkfac_make
# Internal:     qp2obiasp, mk_gti_ext,mk_obilist, bf_copy_times, bf_mk_cts,
#		mk_grptimes, mk_bkfac_data, bkfac_header, bkfac_hist
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <qpc.h>
include <qpoe.h>
include <math.h>
include "../tables/bkfac.h"
include "../source/array.h"
include "../source/asp.h"
include "../source/et_err.h"
include "../source/band.h"

#--------------------------------------------------------------------------
# Procedure:    bkfac_make()
#
# Purpose:      Make background factors table from qpoe file
#
# Input variables:
#               qpoe_name       input qpoe file name
#               qpoe_evlist     associated event list (e.g. "[time=10:50]")
#               bkf_name        output background factors table
#               final_bkf_name  name of final BKFAC table [for history]
#               n_bkfac         number of rows in output bkfac table
#               pi_range        PI range to make counts for
#               br_edge_filt    filter to use to remove bright edge
#               gti_ext         name of GTI extension
#               obi_name        name of OBI column in GTI extension
#               use_obi         Should we average aspects in OBIs?
#               max_off_diff    maximum differences for aspect groups
#               dist_to_edge    pixels to edge of field
#               display         display level
#
# Description:  This is the main routine for the task bkfac_make.  Its
#               purpose is to group together the aspect information
#               in the BLT records of the QPOE file [intersecting the
#               times with the current GTI and the passed in event
#               list], then write the groups out to the table in
#               WCS format.
#
#		It is similar to the task cat_make, except that the
#		grouping algorithm is quite different.  First, (assuming
#		use_obi is true), it will find the average aspect 
#		within each OBI (a.k.a. HUT).  [The point is to cut
#		down on small records of wildly varied aspect.]
#
#		Second, it uses a grouping algorithm (see grp.x)
#		which differs from cat_make's binning algorithm.  
#
#		Lastly, it will calculate the number of image counts
#		which fall within each group of aspects. 
#
#		The final table will contain columns for the aspect
#		(now in WCS format), the pi_cts, and two undefined
#		columns which will be filled in during calc_factors.
#
#		If use_obi is false, then we will consider each
#		aspect record within the BLT record as an "OBI" and
#		won't need to find an average.
#			
#		Here is a summary of the different types of aspect
#		records and time records (see asp.h):
#
#		p_obi:  contains aspect information for each obi.
#			(or, if use_obi is false, for each BLT record)
#
#		p_times:  times array for each obi aspect record,
#			  showing duration
#
#		p_times2obi:  index array mapping times array to
#			      obi records.
#
#		EXAMPLE:  If there are two obi aspect records,
#		there may still be five times records.  This can
#		happen if the user inserts a time filter breaking
#		up an obi (or even a blt record).  The index array
#		might be something like  1,2,3->1  4,5->2.
#		(i.e. times2obi[1]=1, times2obi[2]=1,
#		      times2obi[3]=1, times2obi[4]=2, and
#		      times2obi[5]=2.)	
#
#		p_grp:	contains aspect information for each grouped
#			obi.
#
#		p_grp_dur:  number of seconds each grp record 
#			    corresponds to (array of doubles)
#
#		p_obi2grp:  index array mapping obi aspect records
#			    to grouped records.
#
#	
#		EXAMPLE:  If there were eight obi aspect records,
#		let's say they are grouped into three obi records.
#		This index array might be something like this:
#		   1,4,5->1  2,7,8->2  3->3
#		The grp_dur array should have the same number
#		of elements as there are groups.  The duration
#		of group one in the above example would be the
#		sums of the durations of obi aspect records
#		1, 4, and 5 [obtained by finding which times
#		arrays match with those obi aspect records].
#		
#
#		The user can enter "" as the gti extension; this
#		will then resolve to the correct extension for the
#		qpoe file.  (Revision 0 QPOE will use "GTI", while
#		rev 1 QPOE will use "ALLGTI".)
#
# Algorithm:    * Open QPOE file and read in the header
#		* Resolve GTI_EXT, if default
#               * Open output bkfac table
#               * Create list of aspect records (potentially 
#		    having to average aspects in obis).  These
#		    will be called obi aspects.
#               * Group obi aspects
#		* Calculate image counts within each obi aspect group
#               * Fill output table with group aspect, converted to WCS,
#		  and image counts (called pi_cts).
#               * Write out header and history to BKFAC.
#               * Release memory
#
#--------------------------------------------------------------------------

procedure bkfac_make(qpoe_name,qpoe_evlist,bkf_name,final_bkf_name,pi_range,
		      br_edge_filt,gti_ext,obi_name,use_obi,
		      max_off_diff,dist_to_edge,n_bkfac,display )
char    qpoe_name[ARB]    # i: input qpoe file name
char    qpoe_evlist[ARB]  # i: associated event list (e.g. "[time=10:50]")
char	bkf_name[ARB]	  # i: output BKFAC name
char	final_bkf_name[ARB] # i: name for actual final BKFAC [for history]
char    pi_range[ARB]     # i: PI range to make counts for
char    br_edge_filt[ARB] # i: filter to use to remove bright edge
char	gti_ext[SZ_EXPR]  # i: GTI extension to read from
char	obi_name[ARB]	  # i: OBI column within GTI
bool	use_obi		  # i: should we average aspect in OBI?
double	max_off_diff	  # i: maximum offset diff
double	dist_to_edge	  # i: distance to edge of field
int	n_bkfac		  # o: number of BKFAC records
int	display		  # i: display level

### LOCAL VARS ###

pointer p_aspqual	# aspect quality array for BLT records
pointer tp		# pointer to BKFAC table
pointer col_ptr[N_COL_BKFAC] # column pointers for BKFAC
pointer	p_bkf_info	# pointer to BKFAC info (see gt_info.x)
pointer p_bkf_data	# pointer to data read from BKFAC
pointer p_cts		# pointer to PI_CTS data
int	n_grp		# number of grouped obi aspect records
pointer p_grp		# pointer to grouped obi aspect records
pointer p_grp_dur	# duration of each group record [array of dbls]
int	n_obi		# number of obi aspect records
pointer p_obi		# pointer to obi aspect records
int	i_obi		# current obi aspect record [for displaying]
pointer p_obi2grp	# index array mapping obi records to grouped
			# obi records
pointer qp              # QPOE file pointer
pointer qphead          # QPOE header
int	n_times		# number of TIMES records for obi aspect 
pointer	p_times		# pointer to TIMES records
pointer	p_times2obi	# index array between TIMES and obi aspect
int	i_times		# index into TIMES array

### EXTERNAL FUNCTION DECLARATIONS ###

pointer qp_open()  # returns pointer to QPOE [sys/qpoe]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # open qpoe and get header
        #----------------------------------------------
	qp=qp_open(qpoe_name,READ_ONLY,0)
	call get_qphead(qp,qphead)

        #----------------------------------------------
        # Find actual gti extension (if default)
        #----------------------------------------------
	call mk_gti_ext(gti_ext,qphead)

        #----------------------------------------------
        # Set up BKFAC data and create new table
        #----------------------------------------------
	call bkf_setup(false,OTHER_BAND,p_bkf_info)
	call gt_new(bkf_name,tp,col_ptr,p_bkf_info)

	if (display>1)
	{
	    call printf("\nCreating aspect information...\n")
	    call flush(STDOUT)
	}

        #-------------------------------------------------
        # If we are averaging aspects within obi, run
	# "qp2obiasp".  Otherwise, run "qp2asp" which
	# will simply create aspect records from each BLT
	# record.  (We'll call them "obi" records anyways,
	# for consistency.)
        #-------------------------------------------------
	if (use_obi)
	{
	    call qp2obiasp(qp,qpoe_evlist,gti_ext,obi_name,
			p_obi,n_obi,p_times,n_times,p_times2obi,display)
	}
	else
	{
	    call qp2asp(qp,qpoe_evlist,p_obi,n_obi,p_times,n_times,
				p_times2obi,p_aspqual,display)
            #----------------------------------------------
            # We don't need aspect quality here -- free.
            #----------------------------------------------
	    call mfree(p_aspqual,TY_INT)
	}


        #----------------------------------------------
        # Display OBI and TIMES records for debugging
        #----------------------------------------------
 	if (display>4)
	{
	    call printf("\n\nOBIs:\n")
	    do i_obi=1,n_obi
	    {
	   	call printf("  %d: ASPX=%g, ASPY=%g, ASPR=%g, NOMR=%g\n")
	    	 call pargi(i_obi)
	    	 call pargd(ASP_ASPX(ASP(p_obi,i_obi)))
	    	 call pargd(ASP_ASPY(ASP(p_obi,i_obi)))
	    	 call pargd(ASP_ASPR(ASP(p_obi,i_obi)))
	    	 call pargd(ASP_ROLL(ASP(p_obi,i_obi)))
	    }
	    call printf("\n\nTIMES:\n")

	    do i_times=1,n_times
	    {
	    	call printf("    start=%g, stop=%g, obi=%d\n")
	     	 call pargd(TM_START(TM(p_times,i_times)))
	     	 call pargd(TM_STOP(TM(p_times,i_times)))
	     	 call pargi(ARRELE_I(p_times2obi,i_times))
	    }
	}


        #----------------------------------------------
        # Group together obi records
        #----------------------------------------------
 	call group_asp(p_obi,n_obi,max_off_diff,
		dist_to_edge, p_grp, n_grp, p_obi2grp, display)

	if (display>1)
	{
	   call printf("\nCalculating qpoe counts...\n")
	   call flush(STDOUT)
	}

        #----------------------------------------------
        # Generate image counts for each group.
	# (Also generates group dureations.)
        #----------------------------------------------
 	call bf_mk_cts(qp,qpoe_evlist,n_grp,p_obi2grp,n_times,p_times,
		p_times2obi,pi_range,br_edge_filt,p_cts,
		p_grp_dur,display)


        #----------------------------------------------
        # fill table data
        #----------------------------------------------
	call mk_bkfac_data(qp,qphead,n_grp,p_grp,Memi[p_cts],Memd[p_grp_dur],
				n_bkfac,p_bkf_data,display)


        #----------------------------------------------
        # write out bkfac data
        #----------------------------------------------
 	call gt_put_rows(p_bkf_data,tp,p_bkf_info,col_ptr,1,n_bkfac)


        #----------------------------------------------
        # write header and history to BKFAC
        #----------------------------------------------
 	call bkfac_header(qp,qphead,tp,pi_range)
	call bkfac_hist(qpoe_name,final_bkf_name,tp)

        #----------------------------------------------
        # close BKFAC
        #----------------------------------------------
	call tbtclo(tp)

        #----------------------------------------------
        # clear BKFAC info 
        #----------------------------------------------
	call gt_free_info(p_bkf_info)

        #----------------------------------------------
        # free up all other pointers
        #----------------------------------------------
	call mfree(p_bkf_data,TY_STRUCT)
	call mfree(p_cts,TY_INT)
	call mfree(p_grp_dur,TY_DOUBLE)
	call mfree(p_obi2grp,TY_INT)
	call mfree(p_grp,TY_DOUBLE)
	call mfree(p_times2obi,TY_INT)
	call mfree(p_times,TY_DOUBLE)
	call mfree(p_obi,TY_DOUBLE)
	call mfree(p_bkf_info,TY_STRUCT)
	call mfree(qphead,TY_STRUCT)
	call qp_close(qp)
end

#--------------------------------------------------------------------------
# Procedure:    mk_gti_ext
#
# Purpose:      To find default GTI extension, if needed
#
# Input variables:
#               gti_ext         qpoe extension to modify
#		qphead		QPOE header
#
# Description:  If the user passed in an empty string as the GTI
#		extension, this routine will fill it in with the
#		default extension, depending on the type of QPOE
#		file.  The old QPOE files (revision=0) has "GTI"
#		as its extension; the new QPOE files (revision>0)
#		have either "ALLGTI" and "STDGTI" as possible 
#		GTI extensions; the default is "ALLGTI".
#--------------------------------------------------------------------------

procedure mk_gti_ext(gti_ext,qphead)
char	gti_ext[SZ_EXPR]  # io: GTI extension to modify
pointer qphead		  # i: QPOE header information

int     strlen() # returns length of string [sys/fmtio]

begin
        #----------------------------------------------
        # Do we need to make default string?
        #----------------------------------------------
	if (strlen(gti_ext)==0)
	{
            #----------------------------------------------
            # Revision=0: "GTI"
	    # Revision>0: "ALLGTI"
            #----------------------------------------------
	    if (QP_REVISION(qphead)==0)
	    {
		call strcpy("GTI",gti_ext,SZ_EXPR)
	    }
	    else
	    {
		call strcpy("ALLGTI",gti_ext,SZ_EXPR)
	    }
	}
end

#--------------------------------------------------------------------------
# Procedure:    qp2obiasp
#
# Purpose:      To create the obi aspect data structure for a qpoe file
#
# Input variables:
#               qp              input qpoe file
#               qpoe_evlist     input qpoe event list
#		gti_ext		qpoe extension which contains GTI info
#		obi_name	name of OBI column within GTI
#               display         text display level (0=none, 5=full)
#
# Output variables:
#               p_obi           pointer to output aspect data (see ASP.H)
#               n_obi           number of elements in aspect structure
#               p_times         pointer to ouput times data (see ASP.H)
#               n_times         number of elements in times structure
#               p_times2obi     integer index which shows how the times
#                               data maps to the obi aspect data.
#
# Description:  This routine will fill in the aspect and times data
#               structures using the average aspect records (from the
#		BLT records) within each OBI.  This routine only includes
#		aspect values lying within the current time filter
#		(in qpoe_evlist).
#		
#		The GTI extension chosen will be the one used to
#		determine the start and stopping times of each OBI.
#		The IPC unscreened data contains a column with this
#		data.  For instance, a sample record might be:
#
#		 GTI start      GTI stop       OBI
#		5237270.1      5237801.5        3
#
#		The OBI values should be non-decreasing as the GTI
#		records increase, though this isn't necessary.  It
#		is assumed that GTI records which are in the same
#		hut/obi will have the same OBI number.
#
#		If the obi_name column is not found in the GTI
#		extension (such as for screened data), then each
#		GTI record will be considered as a separate OBI.
#
#		We can thus form an array of starting and stopping
#		OBI times (p_sobi, p_eobi).
#
#		For each OBI time, we must find the average aspect
#		from within the BLT records, but also taking into
#		account the current deffilt and the passed in
#		qpoe_evlist.  See avgasp() for more details on
#		how the average is calculated.
#
#		(Note: the nominal roll must be constant throughout
#		an obi.)
#
#		We must also generate an array index times2obi.
#		
# Example:	For example, we may have 3 BLT records, with 8
#		time values associated with them:
#
#		TIMES 1: start=1000, end=2900  --> BLT 1
#		TIMES 2: start=3000, end=4000  --> BLT 1
#		TIMES 3: start=4250, end=4500  --> BLT 1
#		TIMES 4: start=5000, end=5500  --> BLT 2
#		TIMES 5: start=5700, end=6200  --> BLT 2
#		TIMES 6: start=6500, end=7000  --> BLT 3
#		TIMES 7: start=8000, end=8200  --> BLT 3
#		TIMES 8: start=8300, end=8900  --> BLT 3
#
#		There may be two OBIs: 
#
#		OBI 1:  start=800, end=5400
#		OBI 2:  start=5400, end=9000
#
#		First the BLT records are averaged between
#		times 800 and 5400 (BLT's 1 and 2).  [Note: The
#		averaging is weighted by time.]  This will be
#		the first obi aspect record.  The second will
#		come from times 5400 to 9000 (BLT's 2 and 3).
#		Note that the OBI can end or begin in the middle 
#		of a TIMES interval.
#
#		There will thus be NINE records in p_times
#		(since the 4th TIMES record above must be split
#		into two records), with the obi aspect records
#		being mapped into as follows:
#		   1,2,3,4->1  5,6,7,8,9->2
#
# Algorithm:    * Make string filter "evfilter" from QPOE & evlist
#		  (this will be deffilt & used-defined filter together)
#		* Read OBI values from GTI extension in QPOE
#		* Make list of obi start and end times
#		* Set aside space for all arrays
#		* Read BLT records from QPOE file
#		* Loop over each obi:
#		  * Create a new filter intersecting "evfilter" with
#		    the start and stop obi time.
#		  * Use "filter2asp" to create list of aspect records
#		    and times arrays from BLT records with this filter.
#		  * Find average aspect value, store as obi aspect
#		  * Create obi aspect times records and update times2obi
#		  * Free memory for this loop
#		* Free memory
#
# Note:		The OBI start and stop times are actually stored
#		as start and stop GTI records.  I.e., the starting
#		time of the OBI is the starting time of the start GTI
#		record, and the end of the OBI is the ending time of
#		the end GTI record.  Why aren't they just stored
#		as times?  Because there may be breaks within the 
#		GTI's.
#--------------------------------------------------------------------------

procedure qp2obiasp(qp,qpoe_evlist,gti_ext,obi_name,
		p_obi,n_obi,p_times,n_times,p_times2obi,display)

pointer	qp 		  # i: input qpoe file name
char    qpoe_evlist[ARB]  # i: associated event list (e.g. "[time=10:50]")
char    gti_ext[ARB]      # i: GTI extension to read from
char    obi_name[ARB]     # i: OBI column within GTI
pointer p_obi		  # o: pointer to obi aspect records
int	n_obi		  # o: number of obi aspect records
pointer p_times		  # o: pointer to obi aspect TIMES record
int	n_times		  # o: number of such records
pointer	p_times2obi	  # o: integer array mapping times to obi
int	display		  # i: display level

### LOCAL VARS ###

pointer	p_asp		# list of aspect records for current obi
int	n_asp		# number of such records
pointer	p_aspqual	# array of aspect qualities for these records
pointer p_asptimes	# aspect times records for these records [see asp.h]
int	n_asptimes	# number of above times records
pointer	p_asptimes2asp	# index array mapping aspect TIMES structure to
			# the aspect records.	
pointer p_blt		# BLT records for full QPOE
int	n_blt		# number of BLT records
pointer p_evfilter	# string filter for qpoe file for full sequence
int	evlist_len	# length of above filter
pointer p_filter	# string filter for QP for particular OBI
pointer	p_sgti,p_egti	# start & end times for gti's in GTI extension
			#    [array of doubles]		
int	n_gti		# number of GTI records in extension
pointer p_gti2obi	# index array mapping GTI's to OBIs
pointer p_sobi,p_eobi	# start & end GTI records for each OBI [array of ints]
			# (i.e., "sobi" refers to the GTI record which stores
			#  the time of the start of the OBI, and "eobi" refers
			#  to the GTI record with the end of the OBI)
int	i_obi		# which OBI we are looking at
int	start_obi	# current OBI's start: points to GTI record
int	end_obi		# current OBI's end: points to GTI record

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen() # returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #-------------------------------------------------
        # Make string filter "evfilter" from QPOE & evlist
        #-------------------------------------------------
	call mk_gtifilter(qpoe_evlist,qp,p_evfilter,display)
	evlist_len=strlen(Memc[p_evfilter])

        #----------------------------------------------
	# Read OBI values from GTI extension in QPOE
        #----------------------------------------------
        call bf_read_gti(qp,gti_ext, obi_name,p_sgti,p_egti,
		  	   p_gti2obi,n_gti,display)

        #----------------------------------------------
	# Make list of obi start and end times
	# (assumes gti2obi is an increasing function)
        #----------------------------------------------
	call mk_obilist(n_gti,p_gti2obi,p_sobi,p_eobi,n_obi)
	call mfree(p_gti2obi,TY_INT)

        #----------------------------------------------
	# Set aside space for all arrays
        #----------------------------------------------
	call malloc(p_obi,n_obi*SZ_ASP,TY_DOUBLE)
	call malloc(p_times,0,TY_DOUBLE) 
	call malloc(p_times2obi,0,TY_INT)

        #----------------------------------------------
	# get blt records
        #----------------------------------------------
        call get_qpbal(qp,p_blt,n_blt)

        #----------------------------------------------
	# loop on obis
        #----------------------------------------------
	n_times=0
	do i_obi=1,n_obi
	{
	    if (display>4)
	    {
		call printf("\nOBI #%d: ")
	    	 call pargi(i_obi)
	    }


            #--------------------------------------------------
	    # Create a new filter intersecting "evfilter" with
	    # the start and stop obi time.
            #-------------------------------------------------
	    start_obi=ARRELE_I(p_sobi,i_obi)
	    end_obi=ARRELE_I(p_eobi,i_obi)
	    call add_gtifilter(ARRELE_D[p_sgti,start_obi],
			ARRELE_D[p_egti,start_obi],
			end_obi-start_obi+1,Memc[p_evfilter],
			p_filter,display)

            #------------------------------------------------------
            # Make asp & times structures from filter & blt records
            #------------------------------------------------------
            call filter2asp(qp,Memc[p_filter],p_blt,n_blt,
                        p_asp,n_asp,p_asptimes,n_asptimes,
			p_asptimes2asp,p_aspqual,display)

            #-------------------------------------------------
	    # Calculate average aspect
            #-------------------------------------------------
	    call avgasp(p_asp,n_asp,p_asptimes,n_asptimes,Memi[p_aspqual],
				Memi[p_asptimes2asp],ASP(p_obi,i_obi))


            #-------------------------------------------------
	    # Fill in times2obi and obi's times records
            #-------------------------------------------------
	    call bf_copy_times(i_obi,n_asptimes,p_asptimes,
				n_times,p_times,p_times2obi)

            #-------------------------------------------------
	    # free memory
            #-------------------------------------------------
	    call mfree(p_filter,TY_CHAR)
	    call mfree(p_asp,TY_DOUBLE)
	    call mfree(p_aspqual,TY_INT)
	    call mfree(p_asptimes,TY_DOUBLE)
	    call mfree(p_asptimes2asp,TY_INT)
	}

        #----------------------------------------------
	# free MORE memory!
        #----------------------------------------------
        call mfree(p_blt,TY_STRUCT) 
	call mfree(p_sobi,TY_INT)
	call mfree(p_eobi,TY_INT)
end


#--------------------------------------------------------------------------
# Procedure:    mk_obilist
#
# Purpose:      Create obi start and stop list
#
# Input variables:
#		n_gti		number of GTI records
#		p_gti2obi	how each GTI record maps to OBIs
#
# Output variables:
#		p_sobi		GTI record corresponding to OBI start
#		p_eobi		GTI record corresponding to OBI end
#		n_obi		number of OBIs
#
# Description:  This routine basically creates an inverse map
#		for the gti2obi.  For instance, if gti2obi is
#		as follows:
#
#		    gti2obi[1] = 1
#		    gti2obi[2] = 1
#		    gti2obi[3] = 1
#		    gti2obi[4] = 3
#		    gti2obi[5] = 3
#		    gti2obi[6] = 4
#		    gti2obi[7] = 5
#		    gti2obi[8] = 5
#		    gti2obi[9] = 5
#		    gti2obi[10] = 5
#		    gti2obi[11] = 6
#		    gti2obi[12] = 6
#		
#		Then the output start and stop obi's will be as
#		follows:
#
#		    sobi[1]=1   eobi[1]=3
#		    sobi[2]=4   eobi[2]=5
#		    sobi[3]=6   eobi[3]=6
#		    sobi[4]=7   eobi[4]=10
#		    sobi[5]=11  eobi[5]=12
#
#		Hence the first obi runs from GTIs 1 to 3, the
#		second obi runs from GTIs 4 to 5, etc.  Note that
#		the OBI numbers are renumbered; even though the
#		last GTI record has obi number "6", it is really
#		the fifth obi.
#
#		This routine assumes that gti2obi is never
#		decreasing.  Thus the algorithm is simply to
#		loop through the GTIs and create a new OBI at the
#		end or when the obi number changes.
#--------------------------------------------------------------------------

procedure mk_obilist(n_gti,p_gti2obi,p_sobi,p_eobi,n_obi)
int	n_gti	  # i: number of GTI records
pointer p_gti2obi # i: index mapping GTIs to OBIs
pointer p_sobi    # o: OBI start [as map into GTI]
pointer p_eobi    # o: OBI end [as map into GTI]
int	n_obi	  # o: number of OBI records

### LOCAL VARS ###

int	i_gti	    # which GTI record we are looking at
int	sgti	    # GTI which current OBI starts with
bool	is_obi_done # Have we reached the end of this OBI?

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# Set aside memory for sobi & eobi records.
	# (We set aside too much, but that's okay.)
        #----------------------------------------------
	call malloc(p_sobi,n_gti,TY_INT)
	call malloc(p_eobi,n_gti,TY_INT)

        #----------------------------------------------
	# Loop over GTI records
        #----------------------------------------------
	n_obi=0
	sgti=1
	do i_gti=1,n_gti
	{
            #----------------------------------------------
	    # The current OBI is finished if we are at the
	    # last GTI or if the following GTI record has
	    # a different OBI number.
            #----------------------------------------------
	    if (i_gti==n_gti)
	    {
	      	is_obi_done=true
	    }
	    else
	    {
		is_obi_done=(ARRELE_I(p_gti2obi,i_gti)!=ARRELE_I(p_gti2obi,i_gti+1))
	    }

	    if (is_obi_done)
	    {
		n_obi=n_obi+1
		ARRELE_I(p_sobi,n_obi)=sgti
		ARRELE_I(p_eobi,n_obi)=i_gti
		sgti=i_gti+1
	    }
	}
	
end

#--------------------------------------------------------------------------
# Procedure:    bf_copy_times
#
# Purpose:      Copy times from aspect TIMES record into OBI aspect TIMES
#
# Input variables:
#		i_obi 		which OBI we are creating
#		n_asptimes	number of aspect times records
#		p_asptimes	pointer to aspect times records
#		n_times		number of times records created so far
#				(value gets updated by end of routine)
#		p_times		pointer to times records
#		p_times2obi	integer index mapping times to obi records
#
# Description:  This routine is passed a list of aspect starting and
#		stopping times (stored as a TIMES structure -- see asp.h).
#		These are all times in the current obi (whose index is
#		passed in).  We must update the obi TIMES structure
#		(passed in just as p_times) with these new values.
#
#		The times2obi array is also updated, pointing all the
#		new times values to the passed index.
#--------------------------------------------------------------------------


procedure bf_copy_times(i_obi,n_asptimes,p_asptimes,
			n_times,p_times,p_times2obi)
int	i_obi		# i: which OBI the new times correspond to
int	n_asptimes	# i: number of aspect times records to add
pointer p_asptimes	# i: pointer to aspect times records
int	n_times		# io: number of OBI times records
pointer p_times		# io: pointer to OBI times
pointer p_times2obi	# io: integer index mapping times to OBI records

### LOCAL VARS ###

int	i_asptimes	# which aspect times record we are copying from
int	i_times		# which obi times record we are copying to

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set i_times and bump up n_times
        #----------------------------------------------
	i_times=n_times
	n_times=n_times+n_asptimes

        #----------------------------------------------
        # Set aside more memory in TIMES and TIMES2OBI
        #----------------------------------------------
	call realloc(p_times,n_times*SZ_TIME,TY_DOUBLE)  
	call realloc(p_times2obi,n_times,TY_INT)  

        #----------------------------------------------
        # Loop through aspect times & fill in arrays
        #----------------------------------------------
	do i_asptimes=1,n_asptimes
	{
	    i_times=i_times+1
	    TM_STOP(TM(p_times,i_times))=TM_STOP(TM(p_asptimes,i_asptimes))
	    TM_START(TM(p_times,i_times))=TM_START(TM(p_asptimes,i_asptimes))
	    ARRELE_I(p_times2obi,i_times)=i_obi
	}
end

#--------------------------------------------------------------------------
# Procedure:    bf_mk_cts
#
# Purpose:      Find image counts and duration for each obi group
#
# Input variables:
#               qp              input qpoe file
#               qpoe_evlist     input qpoe event list
#		n_grp		number of obi groups
#		p_obi2grp	index array mapping obi aspect records
#				to obi groups
#		n_times		number of obi aspect TIMES records
#		p_times		pointer to aspect TIMES records
#		p_times2obi	index array mapping TIMES to OBI records
#               pi_range        PI range to make counts for
#               br_edge_filt    filter to use to remove bright edge
#		display		display level
#
# Output variables:
#               p_cts           image counts, one for each group
#		p_grp_dur	duration of each group
#
# Description:  This routine loops through each group and determines
#		the number of counts are in the QPOE file which fell
#		during that group.  It also calculates the duration of
#		each group.
#
#		The QPOE is filtered using the user-defined event list,
#		and the standard eintools filters (br_edge_filt and
#		pi_range).
#
#		We can find the time intervals corresponding to an
#		obi group by using times2obi and obi2grp indices and
#		using only those time intervals matching our group.
#
#		For example, there may be 10 times records mapping to
#		the obi records as follows:
#
#		   times2obi[1]=1
#		   times2obi[2]=2
#		   times2obi[3]=2
#		   times2obi[4]=2
#		   times2obi[5]=3
#		   times2obi[6]=4
#		   times2obi[7]=4
#		   times2obi[8]=4
#		   times2obi[9]=5
#		   times2obi[10]=6
#
#		If the 6 obi aspect records were mapped into three
#		groups as follows:  1,4,5->1  2,6->2  3->3, then
#		the times records for each group would be as follows:
#
#		   group 1:  times 1, 6, 7, 8, 9
#		   group 2:  times 2, 3, 4, 10
#		   group 3:  times 5
#
# Algorithm:    * Create TIMES2GRP array from TIMES2OBI and OBI2GRP
#		* Set aside memory
#		* Create qpfilter from br_edge_filt & pi_range & qpoe_evlist
#		* loop over each group:
#		  * create list of group start and stop times
#		    (which also updates group duration)
#		  * Create grpfilter from above list
#		  * Create sumfilter, adding grpfilter to qpfilter
#		  * Add brackets to sumfilter
#		  * Call qp_cts to find number of counts (using filter)
#		  * Free memory
#               * Free memory
#--------------------------------------------------------------------------

procedure bf_mk_cts(qp,qpoe_evlist,n_grp,p_obi2grp,n_times,p_times,
		p_times2obi,pi_range,br_edge_filt,p_cts,p_grp_dur,display)
pointer qp                # i: input qpoe file name
char    qpoe_evlist[ARB]  # i: associated event list (e.g. "[time=10:50]")
int	n_grp		  # i: number of obi groups
pointer p_obi2grp	  # i: index map from OBIs to groups
int	n_times		  # i: number of TIMES intervals
pointer p_times		  # i: pointer to TIMES intervals
pointer p_times2obi	  # i: index map from TIMES to OBI
char    pi_range[ARB]     # i: PI range to make counts for
char    br_edge_filt[ARB] # i: filter to use to remove bright edge
pointer p_cts		  # o: pointer to PI_CTS data: im. cts per group
pointer	p_grp_dur	  # o: array of group durations [array of dbls]
int	display		  # i: display level

### LOCAL VARS ###
int	i_grp		# which group we are looking at
pointer p_sgrp	  	# array of group starting times [doubles]
pointer p_egrp		# array of group ending times [doubles]
int	n_grptimes	# number of elements in above arrays
pointer p_qpfilter	# string filter for whole qpoe
pointer p_grpfilter	# string filter of group times
pointer p_sumfilter	# sum of above two filters
pointer p_filter	# filter to use in qp_cts (sumfilter w/brackets)
pointer sp		# stack pointer
pointer p_times2grp	# array index between TIMES and obi groups

### EXTERNAL FUNCTION DECLARATIONS ###

int	qp_cts() 	# returns cts in qpoe [xray/lib/qpoe/im_cts.x]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# set stack pointer
        #----------------------------------------------
	call smark(sp)

        #----------------------------------------------
	# create TIMES2GRP array
        #----------------------------------------------
	call salloc(p_times2grp,n_times,TY_INT)
	call a2b2c(n_times,Memi[p_times2obi],Memi[p_obi2grp],
			Memi[p_times2grp])

        #--------------------------------------------------------------
	# Set aside memory for arrays.
	# NOTE: grp records need to have one extra record set aside,
 	#       due to a bug in put_gtifilt.
        #--------------------------------------------------------------
	call salloc(p_sgrp,n_times+1,TY_DOUBLE)
	call salloc(p_egrp,n_times+1,TY_DOUBLE)
	call malloc(p_cts,n_grp,TY_INT)
	call malloc(p_grp_dur,n_grp,TY_DOUBLE)

        #----------------------------------------------
	# Create main qp filter
        #----------------------------------------------
	call mk_qpfilter(qpoe_evlist,br_edge_filt,pi_range,p_qpfilter,display)

	if (display>2)
	{
	    call printf("\nFilter used for finding counts in QPOE file:\n")
	    call printf("  [%s]\n")
	     call pargstr(Memc[p_qpfilter])
	    call flush(STDOUT)
	}
	
        #----------------------------------------------
	# loop over groups
        #----------------------------------------------
	do i_grp=1,n_grp
	{

            #--------------------------------------------------
	    # Fill in sgrp, egrp arrays and update grp_dur
	    # array.
            #--------------------------------------------------
	    call mk_grptimes(n_times,p_times,Memi[p_times2grp],i_grp,
				n_grptimes,p_sgrp,p_egrp,
				ARRELE_D(p_grp_dur,i_grp))
	    
            #--------------------------------------------------
	    # Create grp filter
            #--------------------------------------------------
	    call put_gtifilt(p_sgrp,p_egrp,n_grptimes,p_grpfilter)

	    if (display>2)
	    {
	       	call printf("\nGrp #%d filter: %s")
		 call pargi(i_grp)
		 call pargstr(Memc[p_grpfilter])
		call flush(STDOUT)
	    }


            #--------------------------------------------------
	    # Create final filter by adding qpoe filter with
	    # grp filter and adding brackets
            #--------------------------------------------------
	    call add_filter(Memc[p_qpfilter],Memc[p_grpfilter],p_sumfilter)
	    call add_brack(Memc[p_sumfilter],p_filter)

            #--------------------------------------------------
	    # Find number of counts in qpoe
            #--------------------------------------------------
	    ARRELE_I(p_cts,i_grp)=qp_cts(qp,Memc[p_filter])
	    
	    if (display>2)
	    {
		call printf("   cts=%d, total livetime=%.5f.\n")
		 call pargi(ARRELE_I(p_cts,i_grp))
		 call pargd(ARRELE_D(p_grp_dur,i_grp))
		call flush(STDOUT)
	    }

            #--------------------------------------------------
	    # free memory!
            #--------------------------------------------------
	    call mfree(p_filter,TY_CHAR)
	    call mfree(p_sumfilter,TY_CHAR)
	    call mfree(p_grpfilter,TY_CHAR)
	}
	
        #----------------------------------------------
	# free more memory!
        #----------------------------------------------
 	call mfree(p_qpfilter,TY_CHAR)
	call sfree(sp)
end


#--------------------------------------------------------------------------
# Procedure:    mk_grptimes
#
# Purpose:      Fill in sgrp & egrp arrays and find group duration
#
# Input variables:
#               n_times         number of obi aspect TIMES records
#		p_times		pointer to aspect TIMES records
#		times2grp	index array mapping times to groups
#		i_grp		which group we are finding data for
#
# Output variables:
#               n_grptimes	number of grp times records
#		p_sgrp		array of group starting times
#		p_egrp		array of group ending times
#               grp_dur         duration of this group
#
# Description:  This routine uses the TIMES records and the times2grp
#		index array to fill in the starting & ending arrays
#		for the selected group.  It also returns the duration
#		of the group.
#
#		Memory must be set aside for sgrp and egrp first.
#--------------------------------------------------------------------------

procedure mk_grptimes(n_times,p_times,times2grp,i_grp,
				n_grptimes,p_sgrp,p_egrp,grp_dur)
int     n_times           # i: number of TIMES intervals
pointer p_times           # i: pointer to TIMES intervals
int	times2grp[ARB]	  # i: TIMES2GRP array index
int	i_grp		  # i: which group?
int	n_grptimes	  # o: number of final group times
pointer	p_sgrp		  # o: starting group times
pointer p_egrp		  # o: ending group times
double	grp_dur		  # o: group duration

int	i_times

begin
 	n_grptimes=0
	grp_dur=0.0D0
	do i_times=1,n_times
	{
	    if (times2grp[i_times]==i_grp)
	    {
		n_grptimes=n_grptimes+1
		ARRELE_D(p_sgrp,n_grptimes)=TM_START(TM(p_times,i_times))
		ARRELE_D(p_egrp,n_grptimes)=TM_STOP(TM(p_times,i_times))
		grp_dur=grp_dur+ARRELE_D(p_egrp,n_grptimes)-
					ARRELE_D(p_sgrp,n_grptimes)
	    }
	}
end


#--------------------------------------------------------------------------
# Procedure:    mk_bkfac_data()
#
# Purpose:      To create the rows of the BKFAC table
#
# Input variables:
#               qp              QPOE file
#               qphead          QPOE header
#		n_grp		number of groups
#		p_grp		pointer to group aspect information
#		grp_cts		array of image counts (one per row)
#		grp_dur		array of group durations (one per row)
#               display         display level
#
# Output variables:
#               n_bkfac		number of BKFAC rows
#		p_bkf_data	pointer to BKFAC data
#
# Description:  This routine will convert the grouped aspect data into
#               WCS format and fill in the BKFAC data structure.  (Memory
#               is set aside for the BKFAC data.)
#
#               The WCS information for each row of the BKFAC is as follows:
#
#               RCRVL1,RCRVL2: where the reference point in the QPOE
#                             gets mapped to on the sky
#               RCROT2: (clockwise) rotation of image
#
#               These keywords, combined with the BKFAC header keywords
#               RCRPX1,RCRPX2,RCDLT1,RCDLT2 describe a transformation 
#               between the detector coordinates and the sky coordinates.
#               (See documentation for WCS for more info.)
#
#               Each BKFAC also has an associated duration, a.k.a. 
#               LIVETIME.  It represents how much time the satellite
#               was at the group.  We use the group duration times the
#		QPOE's dead time correction
#		
#		We also write out the number of counts found during
#		each group.
#
#		The BEFAC and DSFAC are set to be undefined -- see
#		the task calc_factors, which fills in these values.
#
# Note:		The number of BKFAC rows might be less than the number
#		of groups if the duration of a group is 0.0D0 or if
#		the number of counts in the row is 0.
#
#		(How could the duration be 0.0?  It could be that
#		 two sets of intervals were intersected resulting
#		 in a 0-length interval.  It happens!)
#
#		(And how could the cts be 0?  Well...if the duration
#		 of the group is really small...)
#--------------------------------------------------------------------------

procedure mk_bkfac_data(qp,qphead,n_grp,p_grp,grp_cts,grp_dur,n_bkfac,
			p_bkf_data,display)
pointer qp         # i: QPOE file
pointer qphead     # i: QPOE header
int	n_grp	   # i: number of groups
pointer	p_grp	   # i: pointer to group data
int	grp_cts[ARB] # i: counts in each group
double  grp_dur[ARB] # i: duration for each group
int	n_bkfac    # o: number of BKFAC rows
pointer	p_bkf_data # o: pointer to BKFAC data
int	display    # i: display level

### LOCAL VARS ###

pointer	c_bkf_data # pointer to current BKFAC record
int	i_grp	   # which group are we considering?
pointer	c_grp	   # pointer to current grp aspect data
pointer ct        # coordinate transformation descriptor
pointer mw        # MWCS descriptor (for QPOE)
double  r_qp[2]   # reference point for QPOE
double  w_qp[2]   # world reference point (unused)
double  arc_qp[2] # scale factors for X&Y (unused)
double  roll_qp   # QPOE roll (unused)
double  wldx      # temporary world reference point, X
double  wldy      # temporary world reference point, Y

### EXTERNAL FUNCTION DECLARATIONS ###

pointer qp_loadwcs()    # pointer to MWCS descriptor [sys/qpoe]
pointer mw_sctran()     # pointer to CT descriptor [sys/mwcs]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Find MW, CT, and ref. points from QPOE file
        #----------------------------------------------
        mw=qp_loadwcs(qp)
        call bkwcs(mw,r_qp,w_qp,arc_qp,roll_qp)
        ct=mw_sctran(mw,"logical","world",3B)

        #----------------------------------------------
        # set aside memory for BKFAC	.
        #----------------------------------------------
	call malloc(p_bkf_data,n_grp*SZ_BKFAC,TY_STRUCT)

        #----------------------------------------------
        # loop through each group
        #----------------------------------------------
	n_bkfac=0
	do i_grp=1,n_grp
	{
           #----------------------------------------------
           # Only continue if livetime for row is > 0
           #----------------------------------------------
	    if (grp_cts[i_grp]>0 && grp_dur[i_grp]>0.0D0)
	    {
                #----------------------------------------------
                # Increment number of BKFAC rows
                #----------------------------------------------
		n_bkfac=n_bkfac+1

                #----------------------------------------------
                # Set current pointers in GRP & BKFAC arrays
                #----------------------------------------------
	    	c_bkf_data=BKFAC(p_bkf_data,n_bkfac)
		c_grp=ASP(p_grp,i_grp)


                #----------------------------------------------
                # Calculate RCRVL1 & RCRVL2
                #----------------------------------------------
		call get_wld_center(r_qp,ct,ASP_ROLL(c_grp),
			ASP_ASPX(c_grp),ASP_ASPY(c_grp),wldx,wldy,
			display)
		BK_RCRVL1(c_bkf_data)=wldx   
		BK_RCRVL2(c_bkf_data)=wldy   

                #----------------------------------------------
                # Calculate RCROT2
                #----------------------------------------------
		BK_RCROT2(c_bkf_data)=RADTODEG(ASP_ROLL(c_grp)+ASP_ASPR(c_grp))

                #----------------------------------------------
                # Fill in remaining columns
                #----------------------------------------------
		BK_PI_CTS(c_bkf_data)=grp_cts[i_grp]
		BK_BEFAC(c_bkf_data)=INDEFD
		BK_DSFAC(c_bkf_data)=INDEFD
		BK_LIVETIME(c_bkf_data)=grp_dur[i_grp]*QP_DEADTC(qphead)
	    }
	}

        #----------------------------------------------
        # Free memory
        #----------------------------------------------
        call mw_ctfree(ct)
        call mw_close(mw)
end



#--------------------------------------------------------------------------
# Procedure:    bkfac_head
#
# Purpose:      Fill in header keywords in CAT
#
# Input variables:
#               qp              input QPOE
#               qphead          QPOE header
#               tp              CAT pointer
#               pi_range	pi range used to calculate BKFAC table
#
# Description:  Fills in the following header keywords in the BKFAC:
#
#       BK_NOMRA, BK_NOMDEC:  nominal RA&DEC for QPOE.
#                             (this is used as an identifier)
#       RCTYP1,RCTYP2,RCRPX1,RCRPX2,RCDLT1,RCDLT2:  WCS info for BKFAC
#       BK_PI_BAND:  What pi band was used to make BKFAC?
#               
#               Also writes out comments to BKFAC.
#--------------------------------------------------------------------------
procedure bkfac_header(qp,qphead,tp,pi_range)
pointer qp       # i: QPOE file
pointer qphead   # i: QPOE header
pointer tp       # io: table pointer for CAT 
char	pi_range[ARB] # i: PI range

### LOCAL VARS ###
pointer mw        # MWCS descriptor (for QPOE)
double  r_qp[2]   # reference point for QPOE
double  w_qp[2]   # world reference point (unused)
double  arc_qp[2] # scale factors for X&Y (unused)
double  roll_qp   # QPOE roll (unused)

### EXTERNAL FUNCTION DECLARATIONS ###

pointer qp_loadwcs()  # pointer to MWCS descriptor [sys/qpoe]

### BEGINNING OF PROCEDURE ###

begin
        #---------------------------------------------------
        # write out nominal RA & DEC to identify this BKFAC.
        #---------------------------------------------------
	call tbhadr(tp,BK_NOMRA,QP_RAPT(qphead))
	call tbhadr(tp,BK_NOMDEC,QP_DECPT(qphead))

        #----------------------------------------------
        # load in some WCS info from QPOE
        #----------------------------------------------
         mw=qp_loadwcs(qp)
        call bkwcs(mw,r_qp,w_qp,arc_qp,roll_qp)
        call mw_close(mw)

        #----------------------------------------------
	# write out some WCS info to table.
        #----------------------------------------------
	call tbhadt(tp,"RCTYP1","RA--TAN")
	call tbhadt(tp,"RCTYP2","DEC-TAN")

	call tbhadd(tp,BK_RCRPX1,r_qp[1])
	call tbhadd(tp,BK_RCRPX2,r_qp[2])
	call tbhadd(tp,BK_RCDLT1,arc_qp[1])
	call tbhadd(tp,BK_RCDLT2,arc_qp[2])

        #----------------------------------------------
	# write out pi range
        #----------------------------------------------
	call tbhadt(tp,BK_PIBAND,pi_range)

        #----------------------------------------------
	# write comments about bkfac
        #----------------------------------------------
        call tbhadt(tp,"COMMENT1",
             "This background factors table is an intermediate file used")
        call tbhadt(tp,"COMMENT2",
             "in creating a rotated background image in the EINTOOLS")
        call tbhadt(tp,"COMMENT3",
             "package.  See the help page for BKFAC_MAKE for more")
	call tbhadt(tp,"COMMENT4","information.")
end

#--------------------------------------------------------------------------
# Procedure:    bkfact_hist
#
# Purpose:      Fill in history header keywords in BKFAC
#
# Input variables:
#               qpoe_name       file name of input QPOE
#               bkf_name        file name of output BKFAC
#               tp              BKFAC table pointer
#
# Description:  Writes history to BKFAC.
#--------------------------------------------------------------------------

procedure bkfac_hist(qpoe_name,bkf_name,tp)
char    qpoe_name[ARB]  # i: QPOE file name
char    bkf_name[ARB]	# i: BKFAC file name
pointer tp		# io: table pointer for BKFAC

### LOCAL VARS ###

pointer sp       # stack pointer
pointer p_hist   # pointer to history string
int     len      # length of history string

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen() # returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin   
        #----------------------------------------------
        # Set aside space for filter string
        #----------------------------------------------
        call smark(sp)
        len = strlen(bkf_name)+
              strlen(qpoe_name)+
              SZ_LINE
        call salloc(p_hist, len, TY_CHAR)

        #----------------------------------------------
        # Create main history string
        #----------------------------------------------
        call sprintf(Memc[p_hist], len, "BKFAC_MAKE: %s -> %s")
         call pargstr(qpoe_name)
         call pargstr(bkf_name)

        #----------------------------------------------
        # Write history string to file
        #----------------------------------------------
        call tbhadt(tp,"HISTORY",Memc[p_hist])

        #----------------------------------------------
        # Free up memory
        #----------------------------------------------
        call sfree(sp)
end
