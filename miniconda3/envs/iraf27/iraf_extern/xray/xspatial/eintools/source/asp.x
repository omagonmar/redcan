# $Header: /home/pros/xray/xspatial/eintools/source/RCS/asp.x,v 11.0 1997/11/06 16:31:30 prosb Exp $
# $Log: asp.x,v $
# Revision 11.0  1997/11/06 16:31:30  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:36  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  14:13:12  dvs
#Fixed documentation.
#
#Revision 1.1  94/03/15  09:12:26  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       asp.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     qp2asp, filter2asp, avgasp
# Local:        blt2asp,add_times
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
#  ASP.X is a file of routines used by EINTOOLS to create and manipulate
#  the BLT aspect data structure in ASP.H.  The data consists of a
#  series of aspect information (stored in the old BLT format as ROLL,
#  ASPR, ASPX, and ASPY) and a separate array of start and stop times.
#
#--------------------------------------------------------------------------

include "array.h"
include "asp.h"

include <qpoe.h>
include <qpc.h>


#--------------------------------------------------------------------------
# Procedure:    qp2asp
#
# Purpose:      To create the aspect data structure for a qpoe file
#
# Input variables:
#               qp		input qpoe file
#		qpoe_evlist	input qpoe event list
#               display         text display level (0=none, 5=full)
#
# Output variables:
#               p_asp		pointer to output aspect data (see ASP.H)
#		n_asp           number of elements in aspect structure
#		p_times		pointer to ouput times data (see ASP.H)
#		n_times		number of elements in times structure
#		p_times2asp     integer index which shows how the times
#				data maps to the aspect data.
#		p_aspqual	pointer to array of aspect quality
#
# Description:  This routine will fill in the aspect and times data
#		structures with the information found in the BLT
#		record of the input QPOE file.  It will only include
#		those aspect values which lie within the passed in
#		time filter (in qpoe_evlist).
#
#		The array TIMES2ASP is an integer array showing how
#		the TIMES data maps to the ASP data.  For instance,
#		we might have the following aspect data:
#
#		   ASP 1st row:   ROLL=0.8 ASPX=1.0 ASPY=2.0 ASPR=0.01
#		   ASP 2nd row:   ROLL=0.8 ASPX=2.0 ASPY=0.0 ASPR=0.02
#
#		 TIMES 1st row:   START=9080594.02  STOP=9080600.02
#		 TIMES 2nd row:   START=9080605.88  STOP=9080799.98
#		 TIMES 3rd row:   START=9081888.25  STOP=9084002.87
#
#		 TIMES2ASP[1]=1
#		 TIMES2ASP[2]=1
#		 TIMES2ASP[3]=2
#
#		Thus the first aspect would be valid for the times in
#		the TIMES structure's first and second rows, while the
#		second aspect would be valid for the time in the third
#		row.   Note that the size of the TIMES2ASP array is
#		the same as the number of elements in the TIMES
#		structure (n_times).
#
#		The aspect quality array is a series of integers
#		indicating whether the quality of the aspect.
#		(This is read directly from the BLT records.)
#		The quality values mean:
#		     1 = good aspect
#		     2 = bad time, but still good aspect
#		     3 = bad aspect (aspect values should be 0.0)
#
# Note:		There is no good reason why the aspect quality couldn't
#		go into the aspect structure.  The reason it didn't was
#		that the binning routines assume the aspect
#		data structure would be all the same type (double).
#--------------------------------------------------------------------------
procedure qp2asp(qp,qpoe_evlist,p_asp,n_asp,p_times,n_times,
				p_times2asp,p_aspqual,display)
pointer qp		 # i: input QPOE file
char	qpoe_evlist[ARB] # i: input qpoe event list (from qp_parse)
pointer p_asp		 # o: pointer to output aspect data 
int	n_asp		 # o: number of elements in aspect structure
pointer p_times		 # o: pointer to ouput times data 
int	n_times		 # o: number of elements in times structure
pointer p_times2asp	 # o: index between times and asp structures
pointer	p_aspqual    	 # o: pointer to aspect quality
int 	display		 # i: text display level (0=none, 5=full)

### LOCAL VARS ###

int	n_blt	     # number of BLT records
int	p_blt	     # pointer to BLT info
pointer p_qpfilter   # pointer to temporary string filter 

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Make the string filter from GTI & EVLIST info
	#  (see strfilter.x in PROS library)
        #----------------------------------------------
	call mk_gtifilter(qpoe_evlist,qp,p_qpfilter,display)


        #----------------------------------------------
        # Read BLT info
        #----------------------------------------------
        call get_qpbal(qp,p_blt,n_blt)

        #----------------------------------------------
	# Make asp & times structures from filter & blt records
        #----------------------------------------------
	call filter2asp(qp,Memc[p_qpfilter],p_blt,n_blt,
			p_asp,n_asp,p_times,n_times,
			p_times2asp,p_aspqual,display)

        #----------------------------------------------
        # Free memory
        #----------------------------------------------
	call mfree(p_blt,TY_STRUCT)
        call mfree(p_qpfilter,TY_CHAR)
end

#--------------------------------------------------------------------------
# Procedure:    filter2asp
#
# Purpose:      To create the aspect data structure from a qpoe and
#		a filter
#
# Input variables:
#               qpoe            input qpoe file
#		filter		input string filter
#		p_blt		pointer to BLT record
#		n_blt		number of BLT records
#               display         text display level (0=none, 5=full)
#
# Output variables:
#               p_asp           pointer to output aspect data (see ASP.H)
#               n_asp           number of elements in aspect structure
#               p_times         pointer to ouput times data (see ASP.H)
#               n_times         number of elements in times structure
#               p_times2asp     integer index which shows how the times
#                               data maps to the aspect data.
#		p_aspqual	pointer to array of aspect quality
#
# Description:  This procedure will fill in the ASP and TIMES data
#		structures, as well as the TIMES2ASP index and the
#		ASPQUAL array.  The expected arguments are the QPOE
#		file, the string filter to use to filter out times,
#		and the BLT records from the QPOE file.  See the
#		description of qp2asp for the description of the
#		output parameters.
#
#		The passed-in filter should not have brackets.
#		(See strfilter.x in the PROS library.)
#
#		The QPOE file is not really used here -- the routine
#		filter2gt needs some QPOE file in order to convert
#		the string filter into good time lists.
#
# Algorithm:	* Set aside space for arrays, structures, and strings
#		* Find beginning and ending times of filter
#		* For each BLT record, check that some part of it
#		  falls within the filter.  If so, do the following:
#		  * Make aspect filter which is the intersection of
#		    the BLT record and the passed in filter.
#		  * Convert aspect filter into a list of good times
#		  * If there are good times, do the following:
#		    * Fill in the aspect and aspqual structures
#		    * Fill in the times and times2asp structures
#
# Note:		The constant TIMES_MEM_BUF is the size we initially allocate
#		to the TIMES structure.  If we need more memory, we
#		allocate an additional TIMES_MEM_BUF records.
#--------------------------------------------------------------------------
define TIMES_MEM_BUF 40

procedure filter2asp(qp,filter,p_blt,n_blt,p_asp,n_asp,p_times,n_times,
			p_times2asp,p_aspqual,display)
pointer qp		# i: input QPOE file
char	filter[ARB]     # i: input string filter
int	p_blt		# i: pointer to BLT info
int	n_blt		# i: number of BLT records
pointer p_asp		# o: pointer to output aspect data 
int	n_asp		# o: number of elements in aspect structure
pointer p_times		# o: pointer to ouput times data 
int	n_times		# o: number of elements in times structure
pointer p_times2asp	# o: index between times and asp structures
pointer	p_aspqual    	# o: pointer to aspect quality
int 	display		# i: text display level (0=none, 5=full)

### LOCAL VARS ###

int	asp_filter_len  # length of aspect filter
pointer p_asp_filter    # pointer to aspect filter string
pointer	c_blt		# current pointer to BLT record
int	i_blt		# index into BLT records
double	filter_begin    # begin time of filter
double	filter_end	# end time of filter
pointer	p_sgt		# pointer to starting good times array
pointer p_egt		# pointer to ending good times array
int	n_gt		# number of good time records
int	m_times 	# current maximum size of TIMES structure
pointer	sp		# stack pointer

### EXTERNAL FUNCTION DECLARATIONS ###

int	strlen()	# returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for filter & structures
        #----------------------------------------------
	call smark(sp)
	asp_filter_len=strlen(filter)+SZ_EXPR
        call salloc(p_asp_filter, asp_filter_len, TY_CHAR)
	call malloc(p_asp,n_blt*SZ_ASP,TY_DOUBLE)
	call malloc(p_aspqual,n_blt,TY_INT)
	call malloc(p_times,TIMES_MEM_BUF*SZ_TIME,TY_DOUBLE)
	call malloc(p_times2asp,TIMES_MEM_BUF,TY_INT)

        #----------------------------------------------
        # Initialize m_times, n_times, and n_asp
        #----------------------------------------------
        m_times=TIMES_MEM_BUF
        n_times=0
	n_asp=0

        #----------------------------------------------
	# find bounds of times on the filter
        #----------------------------------------------
	call filter2gt(qp,filter,p_sgt,p_egt,n_gt)
	filter_begin=ARRELE_D(p_sgt,1)
	filter_end=ARRELE_D(p_egt,n_gt)
	call mfree(p_sgt,TY_DOUBLE)
	call mfree(p_egt,TY_DOUBLE)

	if (display>4)
	{
	    call printf("Filter bounds: %f,%f.\n")
	     call pargd(filter_begin)
	     call pargd(filter_end)
	}

        #----------------------------------------------
	# loop on BLT records
        #----------------------------------------------
	do i_blt=1,n_blt
        {
            c_blt=BLT(p_blt,i_blt)	

            #----------------------------------------------
	    # is BLT record within filter?
            #----------------------------------------------
	    if ((BLT_STOP(c_blt) > filter_begin) &&
	        (BLT_START(c_blt) < filter_end))
	    {
        	#----------------------------------------------
		# make aspect filter
        	#----------------------------------------------
		call sprintf(Memc[p_asp_filter],asp_filter_len,"time=%g:%g,")
	 	 call pargd(BLT_START(c_blt))
	 	 call pargd(BLT_STOP(c_blt))
		call strcat(filter,Memc[p_asp_filter],asp_filter_len)
		
        	#----------------------------------------------
		# convert aspect filter to good times
        	#----------------------------------------------
		call filter2gt(qp,Memc[p_asp_filter],p_sgt,p_egt,n_gt)
		
        	#----------------------------------------------
		# Are there good times?
        	#----------------------------------------------
		if (n_gt>0)
		{
        	    #----------------------------------------------
		    # Create new aspect record
        	    #----------------------------------------------
	 	    n_asp=n_asp+1
	            call blt2asp(c_blt,ASP(p_asp,n_asp),
					ARRELE_I(p_aspqual,n_asp))

        	    #----------------------------------------------
		    # Fill in TIMES structure and TIMES2ASP array
        	    #----------------------------------------------
		    call add_times(p_sgt,p_egt,n_gt,m_times,n_times,p_times,
				p_times2asp,n_asp,display)
		}

        	#----------------------------------------------
		# Free memory
        	#----------------------------------------------
		call mfree(p_sgt,TY_DOUBLE)
		call mfree(p_egt,TY_DOUBLE)
	    }
	}

        #----------------------------------------------
	# free memory
        #----------------------------------------------
	call realloc(p_asp,n_asp*SZ_ASP,TY_DOUBLE)
	call realloc(p_aspqual,n_asp,TY_INT)
	call sfree(sp)
end

#--------------------------------------------------------------------------
# Procedure:    blt2asp
#
# Purpose:      Low level routine to convert BLT record to ASP record
#
# Input variables:
#               p_blt           pointer to BLT record
#
# Output variables:
#               p_asp           pointer to output aspect data 
#               aspqual         aspect quality
#
# Description:  This procedure will copy the data from the BLT record
#		into the ASP record and fill in the aspqual parameter.
#--------------------------------------------------------------------------

procedure blt2asp(p_blt,p_asp,aspqual)
int	p_blt		# i: pointer to BLT info
pointer p_asp		# o: pointer to ASP info
int	aspqual		# o: aspect quality
begin
	ASP_ROLL(p_asp)=BLT_NOMROLL(p_blt)
	ASP_ASPX(p_asp)=BLT_ASPX(p_blt)
	ASP_ASPY(p_asp)=BLT_ASPY(p_blt)
	ASP_ASPR(p_asp)=BLT_ROLL(p_blt)
	aspqual=BLT_QUALITY(p_blt)
end

#--------------------------------------------------------------------------
# Procedure:    add_times
#
# Purpose:      Update the TIMES and TIMES2ASP records.  
#		(Called by filter2asp)
#
# Input variables:
#               p_sgt           pointer to starting good times array
#               p_egt           pointer to ending good times array
#		n_gt		number of good time intervals
#		i_asp		which aspect record will be associated
#				with these times.
#               display         text display level (0=none, 5=full)
#
# Output variables:
#		m_times		current maximum number of TIMES
#		n_times		current size of TIMES array
#		p_times		pointer to TIMES array
#		p_times2asp	index between TIMES and aspect
#
# Description:  This procedure will update the TIMES and TIMES2ASP
#		records with the information passed in the good time
#		arrays.  
#--------------------------------------------------------------------------

procedure add_times(p_sgt,p_egt,n_gt,m_times,n_times,p_times,
				p_times2asp,i_asp,display)
pointer	p_sgt		# i: pointer to starting good times array
pointer p_egt		# i: pointer to ending good times array
int	n_gt		# i: number of good time records
int	m_times 	# io: current maximum size of TIMES structure
int	n_times		# io: number of times in the structure
pointer	p_times		# io: pointer to TIMES structure
pointer p_times2asp	# io: index between times and asp structures
int	i_asp		# i: which aspect corresponds to these times
int 	display		# i: text display level (0=none, 5=full)

### LOCAL VARS ###

pointer	c_times		# current pointer to TIMES structure
int	i_gt		# index to good time array

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Check if we need to add more memory.
        #----------------------------------------------
	while (n_times+n_gt>m_times)
	{
	    m_times=m_times+TIMES_MEM_BUF
	    call realloc(p_times,m_times*SZ_TIME,TY_DOUBLE)
	    call realloc(p_times2asp,m_times,TY_INT)
	    if (display>4)
	    {
		call printf("Adding more memory....\n")
	    }
	}

        #----------------------------------------------
        # Loop on each good time interval
        #----------------------------------------------
	do i_gt=1,n_gt
	{
            #-----------------------------------------------
            # Update n_times, TIMES structure, and TIMES2ASP
            #-----------------------------------------------
	    n_times=n_times+1
	    c_times=TM(p_times,n_times)
	    TM_START(c_times)=ARRELE_D(p_sgt,i_gt)
	    TM_STOP(c_times)=ARRELE_D(p_egt,i_gt)
	    ARRELE_I(p_times2asp,n_times)=i_asp

	    if (display>4)
	    {
		call printf("Added time %d: %f,%f.\n")
		 call pargi(n_times)
		 call pargd(TM_START(c_times))
		 call pargd(TM_STOP(c_times))
	    }
	}
end


#--------------------------------------------------------------------------
# Procedure:    avgasp
#
# Purpose:      Find average aspect value given ASP structure
#
# Input variables:
#               p_asp           pointer to output aspect data 
#               n_asp           number of elements in aspect structure
#               p_times         pointer to ouput times data 
#               n_times         number of elements in times structure
#		aspqual		array of aspect quality
#               times2asp       integer index which shows how the times
#                               data maps to the aspect data.
# Output variables:
#               p_avgasp	ASP structure of average aspect 
#
# Description:  This procedure will find the average value of each
#		of the elements in the input ASP structure.  This
#		is used to find the average aspect within an OBI.
#		
#		The nominal roll (ASP_ROLL) is expected to remain
#		constant throughout the list of times.  If not, a
#		warning is issued.  We only find the average of
#		aspects whose quality is 1 or 2.  Aspects with
#		quality 3 are ignored.
#
#		If there are no quality 1 or 2 aspects during the
#		given times, the average aspect is returned as 0.0.
#
#--------------------------------------------------------------------------

procedure avgasp(p_asp,n_asp,p_times,n_times,aspqual,times2asp,p_avgasp)

pointer p_asp		# i: pointer to aspect data 
int	n_asp		# i: number of elements in aspect structure
pointer p_times		# i: pointer to times data 
int	n_times		# i: number of elements in times structure
int	aspqual[ARB]   	# i: aspect quality array
int	times2asp[ARB]  # i: index between times and asp structures
pointer	p_avgasp	# o: average aspect

### LOCAL VARS ###

pointer	c_asp		# current pointer to ASP structure
double  asp_time	# net time for current TIMES record
double	duration	# total length of time	
int	i_times		# index into TIMES structure
pointer	c_times		# current pointer to TIMES structure

### EXTERNAL FUNCTION DECLARATIONS ###

bool	fp_equald()     # returns true if doubles are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Initialize duration and avg aspect structure
        #----------------------------------------------
	duration=0.0D0
	ASP_ROLL(p_avgasp)=ASP_ROLL(p_asp)
	ASP_ASPX(p_avgasp)=0.0D0
	ASP_ASPY(p_avgasp)=0.0D0
	ASP_ASPR(p_avgasp)=0.0D0

        #----------------------------------------------
        # Loop over times
        #----------------------------------------------
	do i_times=1,n_times
	{
	    c_times=TM(p_times,i_times)
	    asp_time=TM_STOP(c_times)-TM_START(c_times)

            #----------------------------------------------
            # Only include this TIMES record if it has
	    # time within it and the aspect quality is
	    # 1 or 2.
            #----------------------------------------------
	    if (asp_time>0.0D0 && 
		aspqual[times2asp[i_times]]<3) 
	    {
		duration=duration+asp_time
	    	c_asp=ASP(p_asp,times2asp[i_times])

        	#----------------------------------------------
		# Check if the nominal roll has changed.
        	#----------------------------------------------
		if (!fp_equald(ASP_ROLL(p_avgasp),ASP_ROLL(c_asp)))
		{
		   call printf("WARNING: nominal roll changes during OBI!\n")
		}

        	#----------------------------------------------
		# Increment average aspect values
        	#----------------------------------------------
		
		ASP_ASPX(p_avgasp)=ASP_ASPX(p_avgasp)+ASP_ASPX(c_asp)*asp_time
		ASP_ASPY(p_avgasp)=ASP_ASPY(p_avgasp)+ASP_ASPY(c_asp)*asp_time
		ASP_ASPR(p_avgasp)=ASP_ASPR(p_avgasp)+ASP_ASPR(c_asp)*asp_time
	    }
	}

        #----------------------------------------------
        # Find final average.
        #----------------------------------------------
	if (duration>0.0D0)
	{
	    ASP_ASPX(p_avgasp)=ASP_ASPX(p_avgasp)/duration
	    ASP_ASPY(p_avgasp)=ASP_ASPY(p_avgasp)/duration
	    ASP_ASPR(p_avgasp)=ASP_ASPR(p_avgasp)/duration
	}
end

