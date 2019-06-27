#$Log: strfilter.x,v $
#Revision 11.0  1997/11/06 16:21:10  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:19  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:15  prosb
#General Release 2.3.1
#
#Revision 1.1  94/02/07  16:22:01  prosb
#Initial revision
#
#$Header: /home/pros/xray/lib/pros/RCS/strfilter.x,v 11.0 1997/11/06 16:21:10 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       strfilter.x
# Project:      PROS -- LIBRARY
# External:     rm_brack,add_brack,add_filter,mk_gtifilter,add_gtifilter,
#		filter2gt
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
# STRFILTER.X
#
# These routines are used for creating and manipulating string time
# filters, such as those used in qpio_open and returned by qp_parse.
#
#--------------------------------------------------------------------------

include <ercode.h>

#--------------------------------------------------------------------------
# Procedure:    rm_brack
#
# Purpose:      To remove brackets from a filter string
#
# Input variables:
#               in_filter       input filter
#
# Output variables:
#               p_out_filter    pointer to output filter
#
# Description:  This routine removes the beginning '[' and ending ']'
#               of filter string.  Most routines in this library expect
#               the brackets around the string to be removed in order
#               to better manipulate them.
#
#		An error is given if the input filter does not have
#		brackets, unless the input filter is empty (in which
#		case the output filter will also be empty).
#
# 		Memory is set aside for the output string.
#--------------------------------------------------------------------------

procedure rm_brack(in_filter,p_out_filter)
char	in_filter[ARB]	# i: input filter (with brackets)
pointer	p_out_filter	# o: pointer to output filter (without brackets)

### LOCAL VARS ###

int	filt_len	# string length of in_filter

### EXTERNAL FUNCTION DECLARATIONS ###

int	strlen()	# returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for output filter
        #----------------------------------------------
        filt_len = strlen(in_filter)
        call malloc( p_out_filter, filt_len+1, TY_CHAR)

        #----------------------------------------------
        # If filter is non-empty, remove brackets.
        #----------------------------------------------
        if( filt_len > 0 ){
            #----------------------------------------------
            # Check that brackets exist around filter.
            #----------------------------------------------
	    if (in_filter[1]!='[' || in_filter[filt_len]!=']')
	    {
		call errstr(PROS_WRONG_FORMAT,
		  "RM_BRACK: String not surrounded by brackets",in_filter)
	    }

            #----------------------------------------------
            # Copy string without brackets.
            #----------------------------------------------
            call strcpy(in_filter[2],Memc[p_out_filter], filt_len)
            Memc[p_out_filter+filt_len-2]=NULL
        }
        else
	{
            #----------------------------------------------
            # Set output filter to be empty.
            #----------------------------------------------
            Memc[p_out_filter]=NULL
	}
end

#--------------------------------------------------------------------------
# Procedure:    add_brack
#
# Purpose:      To add brackets to a filter string
#
# Input variables:
#               in_filter       input filter
#
# Output variables:
#               p_out_filter    pointer to output filter
#
# Description:  This routine surrounds the input string with the 
#		characters '[' and ']'.  Routines such as qpio_open
#		expect the filter to have brackets around them.
#
# 	        Memory is set aside for the output string.
#
# Note:         We can NOT use the FMTIO routines (such as sprintf)
#		to achieve this task because they only allow strings
#		up to a certain size (such as 1024 characters).  This
#		routine has no such restrictions.
#--------------------------------------------------------------------------

procedure add_brack(in_filter,p_out_filter)
char	in_filter[ARB]
pointer	p_out_filter

### LOCAL VARS ###

int     filt_len        # string length of in_filter

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen()        # returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for output filter
        #----------------------------------------------
        filt_len = strlen(in_filter)+2
        call malloc( p_out_filter, filt_len, TY_CHAR)

        #----------------------------------------------
        # Create output filter
        #----------------------------------------------
	call strcpy("[",Memc[p_out_filter],filt_len)
        call strcat(in_filter,Memc[p_out_filter],filt_len)
	call strcat("]",Memc[p_out_filter],filt_len)
end

#--------------------------------------------------------------------------
# Procedure:    add_filter
#
# Purpose:      To concatinate two filters
#
# Input variables:
#               filter1         input filter # 1
#               filter2         input filter # 2
#
# Output variables:
#               p_sum_filter    pointer to output filter
#
# Description:  This routine concatinates filter1 and filter2 to
#		produce the summed filter.  Both input filters
#		are expected to NOT have brackets around them.
#		(See rm_brack.)
#
#               Memory is set aside for the output string.
#
# Note:         We can NOT use the FMTIO routines (such as sprintf)
#               to achieve this task because they only allow strings
#               up to a certain size (such as 1024 characters).  This
#               routine has no such restrictions.
#--------------------------------------------------------------------------
procedure add_filter(filter1,filter2,p_sum_filter)
char	filter1[ARB]	# i: input filter 1
char	filter2[ARB]    # i: input filter 2
pointer	p_sum_filter    # o: pointer to output filter (filter1+filter2)

### LOCAL VARS ###

int     filt_len        # string length of in_filter

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen()        # returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for output filter
        #----------------------------------------------
	filt_len = strlen(filter1)+strlen(filter2)+1
	call malloc(p_sum_filter,filt_len,TY_CHAR)

        #----------------------------------------------
        # Create output filter
        #----------------------------------------------
	call strcpy(filter1,Memc[p_sum_filter],filt_len)
        call strcat(",",Memc[p_sum_filter],filt_len)
        call strcat(filter2,Memc[p_sum_filter],filt_len)
end

#--------------------------------------------------------------------------
# Procedure:    mk_gtifilter
#
# Purpose:      To create a filter which represents a QPOE's GTI,
#		taking into account the event list.
#
# Input variables:
#               qpoe_evlist     The QPOE's event list (see qp_parse)
#		qp		The input QPOE file
#               display		display level (0-5)
#
# Output variables:
#		p_gtifilter     The output filter of GTIs.
#
# Description:  This routine finds the current good time intervals
#		(via get_gtifilt) and concatinates this filter with
#		the current event list.  The final, returned filter
#		will not have brackets.
#
#		(The qpoe_evlist is assumed to still have its
#		brackets.)
#
#               Memory is set aside for the output string.
#--------------------------------------------------------------------------
procedure mk_gtifilter(qpoe_evlist,qp,p_gtifilter,display)
char	qpoe_evlist[ARB] # i: The QPOE's event list
pointer	qp		 # i: The input QPOE file
pointer	p_gtifilter	 # o: output filter of GTIs, with event list
int	display		 # i: display level (0-5)

### LOCAL VARS ###

pointer	p_sgti		# temporary array of starting good times
pointer	p_egti		# temporary array of ending good times
int	n_filt          # number of good time elements
pointer	p_tmpfilter     # pointer to temporary filter string of good times
pointer p_evlstfilter   # pointer to temporary event list filter

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Remove brackets from the event list
        #----------------------------------------------
	call rm_brack(qpoe_evlist,p_evlstfilter)

        #----------------------------------------------
        # Retrieve list of GTIs
        #----------------------------------------------
	call get_gtifilt(qp,p_tmpfilter,n_filt,p_sgti,p_egti)
	call mfree(p_sgti,TY_DOUBLE)
	call mfree(p_egti,TY_DOUBLE)

        #-------------------------------------------------------
	# concatenate event list with gti filter into one filter
        #-------------------------------------------------------
	call add_filter(Memc[p_tmpfilter],Memc[p_evlstfilter],
			p_gtifilter)

	if (display>4)
	{
           #--------------------------------------------------------------
  	   # NOTE: if string is over 1024 chars, this print will not work!
           #--------------------------------------------------------------
	   call printf("GTI filter: %s.\n")
	    call pargstr(Memc[p_gtifilter])
	}

        #----------------------------------------------
        # Free memory
        #----------------------------------------------
	call mfree(p_tmpfilter,TY_CHAR)
	call mfree(p_evlstfilter,TY_CHAR)
end

#--------------------------------------------------------------------------
# Procedure:    add_gtifilter
#
# Purpose:      To add good time information to a filter.
#
# Input variables:
#               sgt		starting good times
#               egt		ending good times
#               n_gt            number of good time intervals
#               filter          input filter
#               display		display level (0-5)
#
# Output variables:
#               p_sum_filter    pointer to output filter
#
# Description:  This routine converts an array of good times into
#		a filter and concatinates it to an input filter to
#		produced a final filter.  All filters should have no
#		brackets.
#
#
#               Memory is set aside for the output string.
#
# Note: 	There is a bug in output_timfilt which will set
#		the unnecessarily place zero in the "n_gt+1"-st place
#		in the sgt and egt arrays.  This routine will make
#		up for this bug by preserving the "n-gt+1"-st values.
#		Note that there should always be one extra memory value
#		set aside for the sgt and egt records because of this
#		bug.
#--------------------------------------------------------------------------
procedure add_gtifilter(sgt,egt,n_gt,filter,p_sum_filter,display)
double	sgt[ARB]	# i: array of starting good times
double  egt[ARB]	# i: array of ending good times
int	n_gt		# i: number of good time intervals to add to filter
char	filter[ARB]	# i: filter to add to. 
pointer p_sum_filter    # o: output summed filter
int	display		# i: display level (0-5)

### LOCAL VARS ###

double  temp_sgt    # temporary starting GTI value (for bug workaround)
double  temp_egt    # temporary ending GTI value (for bug workaround)
pointer p_gtifilter # temporary pointer to GTI filter

begin
        #--------------------------------------------------
	# BUG in output_timfilt:  workaround by saving next
	# sgt & egt records!
        #--------------------------------------------------
	temp_sgt=sgt[n_gt+1]
	temp_egt=egt[n_gt+1]
	call output_timfilt(sgt,egt,n_gt,"%.7f",0,p_gtifilter,TRUE,TRUE)
	sgt[n_gt+1]=temp_sgt
	egt[n_gt+1]=temp_egt

	if (display>4)
	{
	   call printf("filter: %s\n")
	    call pargstr(Memc[p_gtifilter])
	}

        #----------------------------------------------
        # Concatinate input filter to GTI filter.
        #----------------------------------------------
	call add_filter(filter,Memc[p_gtifilter],p_sum_filter)

        #----------------------------------------------
        # Free memory
        #----------------------------------------------
	call mfree(p_gtifilter,TY_CHAR)
end

#--------------------------------------------------------------------------
# Procedure:    filter2gt
#
# Purpose:      To convert a string filter into a list of good times.
#
# Input variables:
#               qp              input QPOE (can be any QPOE file)
#               filter          input filter
#
# Output variables:
#               p_sgt		pointer to starting good times
#               p_egt		pointer to ending good times
#               n_gt            number of good time intervals
#
# Description:  This routine converts a string filter (without 
#		brackets) into a list of good times.
#
#		This routine will sort and group together times in
#		the array.  For instance, if the array has times:
#		         9010:9015,9001:9004,9008:9011
#		then the output times will be:
#		         sgt   9001, 9008
#		         egt   9004, 9015
#
#               Memory is set aside for good times arrays.
#
#		Even though a QPOE file is input, it is not actually
#		used in the translation, but is needed to open the
#		selection subsystem (QPEX).
#
#--------------------------------------------------------------------------
procedure filter2gt(qp,filter,p_sgt,p_egt,n_gt)
pointer	qp		# i: input QPOE file -- not really used
char	filter[ARB]	# i: filter to break up into good times
pointer	p_sgt		# o: array of starting good times
pointer p_egt		# o: array of ending good times
int	n_gt		# o: number of good time intervals

### LOCAL VARS ###

pointer	ex	     # pointer to selection expression
int	xlen	     # length of preallocated arrays

### EXTERNAL FUNCTION DECLARATIONS ###

pointer qpex_open()   # returns ptr to sellection expression [SYS/QPOE]
int	qpex_attrld() # returns number of good-value ranges [SYS/QPOE]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Open selection expression "ex"
        #----------------------------------------------
	ex = qpex_open(qp,filter)

        #-------------------------------------------------------
        # Set xlen to 0 (telling qpex_attrld that the passed in
	#  pointers have no memory allocated to them.)
        #-------------------------------------------------------
	xlen = 0

        #----------------------------------------------
        # Get list of good times from filter
        #----------------------------------------------
	n_gt= qpex_attrld (ex, "time", p_sgt, p_egt, xlen)

        #----------------------------------------------
        # Close selection expression "ex"
        #----------------------------------------------
	call qpex_close(ex)
end
