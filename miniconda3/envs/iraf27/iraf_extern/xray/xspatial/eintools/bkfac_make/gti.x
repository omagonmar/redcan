# $Header: /home/pros/xray/xspatial/eintools/bkfac_make/RCS/gti.x,v 11.0 1997/11/06 16:30:49 prosb Exp $
# $Log: gti.x,v $
# Revision 11.0  1997/11/06 16:30:49  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:33  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/23  08:54:12  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       gti.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     bf_read_gti
# Internal:     
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include "../source/array.h"
include "../../../lib/qpcreate/qpcreate.h"

#--------------------------------------------------------------------------
# Procedure:    bf_read_gti
#
# Purpose:      To read in GTI and OBI information from a GTI extension
#
# Input variables:
#               qp              input qpoe file
#               gti_ext         qpoe extension which contains GTI info
#               obi_name        name of OBI column within GTI
#		display		display level
#
# Output variables:
#               p_sgti          pointer to starting good times [array of dbls]
#               p_egti          pointer to ending good times [array of dbls]
#		p_gti2obi	array: how gti's map to obi's
#		n_gti		number of GTI records.
#
# Description:  This routine fills in the SGTI and EGTI arrays with the
#		starting and ending times of the GTIs in the passed in
#		extension.
#
#		If there is an OBI column within the GTI extension 
#		(which has the column name obi_name), then read in the
#		mapping between the GTI records and OBI values.  For
#		instance, the first 5 GTI records might be OBI 1, the
#		next 10 records might be OBI 2, etc.
#
#		If there is no OBI information in the GTI extension, simply
#		make each GTI record a separate OBI.  Thus the returning
#		GTI2OBI record will be the identity function.
#
# Note:		We use the routine get_gtsi to read in the GTI extension.
#		The routine "get_gtsi" actually reads in a generic
#		extension, nut just a TSI extension.  We can then parse
#		the descriptor passed back in p_gtilist to find the
#		obi column.
#
#		If the PROS library gets better tools to read extensions,
#		this should be rewritten.  For instance, we are 
#		assuming that the first two records of the GTI are the
#		starting and ending times -- we aren't checking this
#		first.
#--------------------------------------------------------------------------

procedure bf_read_gti(qp,gti_ext,obi_name, p_sgti,p_egti,p_gti2obi,
			n_gti,display)
pointer qp                # i: input qpoe file name
char    gti_ext[ARB]      # i: GTI extension to read from
char    obi_name[ARB]     # i: OBI column within GTI
pointer p_sgti,p_egti	  # o: starting & ending good times
pointer p_gti2obi	  # o: index array between gti & obis
int     n_gti		  # o: number of gti's
int	display		  # i: display level

### LOCAL VARS ###

pointer	dummyvar	# [unused] unused pointer in get_gtsi call
int     i_gti		# which GTI record are we looking at?
int	gticnt		# number of columns in GTI record
int	gtisize		# length of GTI record (in SZ_SHORT units)
pointer	p_gtidata	# data holding GTI record
pointer p_gtistr	# [unused] descriptor string
pointer	p_gtilist	# list of column descriptors [see qpcreate.h]
int	i_gtilist	# which column descriptor we're looking at
pointer	c_gtilist	# pointer to current column descriptor
short   obi		# obi of current gti
bool	obi_found	# is there an OBI record within GTI?
int	obi_loc		# offset of OBI within GTI record.  
int     obi_offset	# offset (in SZ_SHORTs) of OBI in p_gtidata
int     s_offset	# offset (in SZ_SHORTs) of starting GTI time 
int     e_offset	# offset (in SZ_SHORTs) of ending GTI time 

### EXTERNAL FUNCTION DECLARATIONS ###

int	strcmp()	# strcmp(s1,s2): <0 if s1<s2,
			#                 0 if s1==s2,
			#                >0 if s1>s2.   [sys/fmtio]
### BEGINNING OF PROCEDURE ###

begin
        #-------------------------------------------------
	# Read in GTI data and descriptors
        #-------------------------------------------------
	call get_gtsi(qp, gti_ext, p_gtistr, p_gtilist, gticnt, 
		gtisize, p_gtidata, dummyvar, n_gti)

	if (n_gti==0)
	{
	   call errstr(1,
		"No GTI records found in QPOE with extension name",gti_ext)
	}

        #-------------------------------------------------
	# find OBI location by searching p_gtilist until
	# we find a name which matches obi_name.  If we
	# don't find one, obi_found will be false.
        #-------------------------------------------------
	obi_found=false
	obi_loc=0
	do i_gtilist=1,gticnt
	{
	    c_gtilist=MACRO_STRUCT(p_gtilist, i_gtilist)
	
	    if (strcmp(obi_name,NAME_STR(c_gtilist))==0)
	    {
		obi_loc=BYTE_OFFSET(c_gtilist)
		obi_found=true
	    }
	}

	
	if (display>4)
	{
	    if (obi_found)
	    {
	 	call printf("\nFound OBI information in GTI record.\n")
	    }
	    else
	    {
		call printf("\nNo OBI information found in GTI record--\n")
		call printf("setting each GTI to be an OBI.\n")
	    }
	}

        #-------------------------------------------------
	# Set aside memory for EGTI, SGTI, GTI2OBI
	# NOTE: GTI records need to have one extra record 
	#       set aside for a bug in output_timfilt.
        #-------------------------------------------------
        call malloc(p_sgti,n_gti+1,TY_DOUBLE)  # set aside extra for bug
        call malloc(p_egti,n_gti+1,TY_DOUBLE)  # set aside extra for bug
        call malloc(p_gti2obi,n_gti,TY_INT)

        #-------------------------------------------------
	# Loop through GTI records.
        #-------------------------------------------------
  	obi=0
        do i_gti=1,n_gti
        {
            #-------------------------------------------------
	    # Calculate starting & ending offsets: assume
	    # they are first & second records.
            #-------------------------------------------------
            s_offset=(i_gti-1)*gtisize
            e_offset=s_offset+SZ_DOUBLE

            #-------------------------------------------------
	    # Load SGTI and EGTI data
            #-------------------------------------------------
            call amovi(Mems[P2S(p_gtidata)+s_offset],
                                ARRELE_D(p_sgti,i_gti),SZ_DOUBLE)
            call amovi(Mems[P2S(p_gtidata)+e_offset],
                                ARRELE_D(p_egti,i_gti),SZ_DOUBLE)

            #-------------------------------------------------
	    # Set "obi" to be obi value of current GTI
            #-------------------------------------------------
	    if (obi_found)
	    {
	   	obi_offset=s_offset+obi_loc
                call amovi(Mems[P2S(p_gtidata)+obi_offset],
                                obi,SZ_SHORT)
	    }
	    else
	    {
		obi=obi+1
	    }

            #-------------------------------------------------
	    # Fill in gti2obi
            #-------------------------------------------------
            ARRELE_I[p_gti2obi,i_gti]=obi
        }

        #-------------------------------------------------
	# Free memory!
        #-------------------------------------------------
	call mfree(p_gtistr,TY_CHAR)
	call mfree(p_gtilist,TY_STRUCT)
	call mfree(p_gtidata,TY_STRUCT)
end
