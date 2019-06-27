# $Header: /home/pros/xray/xspatial/eintools/source/RCS/pirange.x,v 11.0 1997/11/06 16:31:37 prosb Exp $
# $Log: pirange.x,v $
# Revision 11.0  1997/11/06 16:31:37  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:49  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:13:33  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       pirange.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     band2range,range2list
# Local:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
#  PIRANGE.X is for converting a PI band into a usable format.
#
#--------------------------------------------------------------------------

include <missions.h>
include "et_err.h"
include "array.h"
include "pirange.h"
	
#--------------------------------------------------------------------------
# Procedure:    band2range
#
# Purpose:      To convert an input pi band into a range of values
#
# Input variables:
#               pi_band		PI band 
#
# Output variables:
#               p_pi_range	pointer to output PI range
#
# Description:  A PI band is expected to be a string which is either
#		one of "soft", "hard", "broad", or "all" [or any
#		abbreviation of these, such as "s", "b", etc.] OR
#		a range of values (such as "2:6" or "3:7,9:10").
#
#		This routine will convert this band into a range.
#		For instance, "soft" will be converted into "2:4".
#
#		The definitions of soft, hard, broad, etc. are specific
#		to the Einstein instrument.  
#
#		Memory is set aside for p_pi_range.
#
# Note:		This routine does NOT check the format of the PI band.
#		If the PI band does not appear in the dictionary of
#		accepted strings, it will be copied into the PI range
#		and returned.  Thus if "sift" is entered as the PI band,
#		it will be returned as such.
#--------------------------------------------------------------------------


procedure band2range(pi_band,p_pi_range)
char 	pi_band[ARB]	# i: input PI band
pointer	p_pi_range	# o: pointer to PI range

### LOCAL VARS ###

string  band_names "|SOFT|HARD|BROAD|ALL|"  # band names to look for
int	range_size	# memory set aside for output PI range

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen()        # returns length of string [sys/fmtio]
int     strdic()	# returns where the input word appear in a
			# dictionary of words [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for strings
        #----------------------------------------------
	range_size=max(strlen(pi_band),SZ_LINE)
	call malloc(p_pi_range,range_size,TY_CHAR)

	
        #----------------------------------------------
        # Copy PI band into PI range and convert to
	# upper case
        #----------------------------------------------
        call strcpy(pi_band, Memc[p_pi_range], range_size)
        call strupr(Memc[p_pi_range])

        #----------------------------------------------
        # Search for a match in the "dictionary".  If a
	# match is found, set pi_range to be the new
	# range.  If not, we are finished.
        #----------------------------------------------
        switch ( strdic( Memc[p_pi_range], Memc[p_pi_range],
			range_size, band_names ) )  
	{
	case 1:	   # soft band
	   call strcpy(EIN_SOFT_RANGE,Memc[p_pi_range],range_size)
        case 2:	   # hard band
	   call strcpy(EIN_HARD_RANGE,Memc[p_pi_range],range_size)
        case 3:	   # broad band
	   call strcpy(EIN_BROAD_RANGE,Memc[p_pi_range],range_size)
        case 4:	   # all bands
	   call strcpy(EIN_ALL_RANGE,Memc[p_pi_range],range_size)
        default:   # none of those: do nothing.
	}
end

#--------------------------------------------------------------------------
# Procedure:    range2list
#
# Purpose:      To convert an PI range into a list of PI values
#
# Input variables:
#               pi_range	PI range
#
# Output variables:
#               n_pi		number of PI values
#		p_pi_list	pointer to list of PI values (ints)
#
# Description:  Given a PI range (such as "3:7" or "0:2,6:10"), this
#		routine will return an array of PI values, stored
#		as an array of integers.  For instance, if the
#		PI range is "2:6,5:7", it will return n_pi=6 and
#		the array will point to the values 2,3,4,5,6, and 7.
#
#		Memory is set aside in this routine for the PI list.
#
# Note:		This routine does NOT check the format of the PI range
#		before passing them to qpex_parsei.  If the range has
#		illegal characters, qpex_parsei will return an error.
#		
#		This also does not check if the PI values are valid
#		for the instrument.
#
#--------------------------------------------------------------------------


procedure range2list(range,n_pi,p_pi_list)
char 	range[ARB]	# i: PI range
int	n_pi		# o: number of PI values
pointer	p_pi_list	# o: pointer to array of PI values

### LOCAL VARS ###

int	n_int		# number of PI intervals
int	i_int		# index into PI intervals
pointer	p_start		# pointer to PI interval starts
pointer	p_end		# pointer to PI interval ends
int	pi_value	# particular PI value
int	i_pi		# which PI value we are setting in p_pi_list
int	size		# memory set aside for p_start & p_end

### EXTERNAL FUNCTION DECLARATIONS ###

int	qpex_parsei()   # returns number of parsed intervals [SYS/QPOE]

### BEGINNING OF PROCEDURE ###

begin
        #--------------------------------------------------
        # Parse RANGE into series of starting and ending
	# PI values.  Note that we must pass in "size" and
	# not "0" into the routine qpex_parsei, because 
	# the routine modifies this parameter.
        #--------------------------------------------------
	size=0   
	p_start=NULL
	p_end=NULL
	n_int=qpex_parsei(range,p_start,p_end,size)

        #--------------------------------------------------
        # Count the number of total PI values.
        #--------------------------------------------------
	n_pi=0
	do i_int=1,n_int
	{
	   n_pi=n_pi+ARRELE_I(p_end,i_int)-ARRELE_I(p_start,i_int)+1
	}

        #--------------------------------------------------
        # Set aside space for the PI list.
        #--------------------------------------------------
	call malloc(p_pi_list,n_pi,TY_INT)
	
        #--------------------------------------------------
        # Fill in PI list
        #--------------------------------------------------
	i_pi=0
	do i_int=1,n_int
	{
	   do pi_value=ARRELE_I(p_start,i_int),ARRELE_I(p_end,i_int)
	   {
	      	i_pi=i_pi+1
		ARRELE_I(p_pi_list,i_pi)=pi_value
	   }
	}	
		
        #--------------------------------------------------
        # Free up memory.
        #--------------------------------------------------
	call mfree (p_start,TY_INT)
	call mfree (p_end,TY_INT)
end

