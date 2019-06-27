# $Header: /home/pros/xray/xspatial/eintools/_band2range/RCS/band2range.x,v 11.0 1997/11/06 16:31:01 prosb Exp $
# $Log: band2range.x,v $
# Revision 11.0  1997/11/06 16:31:01  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:50  prosb
# General Release 2.4
#
#Revision 1.1  1994/08/04  13:49:24  dvs
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       band2range.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_band2range.x
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <qpc.h>

#--------------------------------------------------------------------------
# Procedure:    t_band2range()
#
# Purpose:      Main procedure call for the task band2range
#
# Input parameters:
#		band		PI band to convert
#
# Output parameters:
#		range		PI range corresponding to band.
#
# Description:  This task will convert any PI band into a range.
#		A PI band is expected to be a string which is either
#               one of "soft", "hard", "broad", or "all" [or any
#               abbreviation of these, such as "s", "b", etc.] OR
#               a range of values (such as "2:6" or "3:7,9:10").
#
#               This routine will convert this band into a range.
#               For instance, "soft" will be converted into "2:4".
#
#               The definitions of soft, hard, broad, etc. are specific
#               to the Einstein instrument. 
#
# Note:		This task is simply a wrapper for the routine "band2range"
#--------------------------------------------------------------------------
procedure t_band2range()
pointer p_band		# PI band

### LOCAL VARS ###

pointer sp        	# stack pointer
pointer p_pi_range	# output PI range

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # allocate space on stack & set aside memory
        #   for strings
        #----------------------------------------------
        call smark(sp)
        call salloc( p_band, SZ_EXPR, TY_CHAR)
	
        #----------------------------------------------
        # read in parameters
        #----------------------------------------------
        call clgstr("band",Memc[p_band],SZ_EXPR)

        #----------------------------------------------
        # massage the input parameter filenames:
        #    remove white space around filenames
	#    add roots to names
        #----------------------------------------------
        call strip_whitespace(Memc[p_band])

        #----------------------------------------------
        # convert pi band into range
        #----------------------------------------------
	call band2range(Memc[p_band],p_pi_range)

	call clpstr("range",Memc[p_pi_range])

        #----------------------------------------------
        # free stack
        #----------------------------------------------
	call mfree(p_pi_range,TY_CHAR)
        call sfree (sp)
end
