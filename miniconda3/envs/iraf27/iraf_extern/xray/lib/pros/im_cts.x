# $Header: /home/pros/xray/lib/pros/RCS/im_cts.x,v 11.0 1997/11/06 16:20:33 prosb Exp $
# $Log: im_cts.x,v $
# Revision 11.0  1997/11/06 16:20:33  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:27:48  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:20  prosb
#General Release 2.3.1
#
#Revision 1.2  94/02/23  09:45:16  prosb
#Changed purpose of im_cts.x (just documentation change)
#
#Revision 1.1  94/02/23  09:32:04  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       im_cts.x
# Project:      PROS LIBRARY
# External:     im_cts, qp_cts
# Local:        im_pars_cts
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
#  IM_CTS.X contains counting routines for images (QPOE and IMH).
#--------------------------------------------------------------------------

include <imhdr.h>
include <regparse.h>

#--------------------------------------------------------------------------
# Procedure:    im_cts
#
# Purpose:      Returns the number of counts in an image
#
# Input variables:
#               ip		image pointer
#               region		region to filter image with [string]
#
# Output variables:
#               area   		number of pixels in region
#
# Return value:
#               Returns number of counts [double]
#
#
# Description:  This routine will apply the passed-in region on the
#		image and find the number of counts in the image.
#
#
#--------------------------------------------------------------------------

double procedure im_cts(ip,region,area)
pointer ip		# i: image pointer
char	region[ARB]     # i: region to filter image with
double	area		# o: area of region

### LOCAL VARS ###

double	tot_im_cts	# return counts in image
pointer parsing		# temp variable for "rg_open_parser"
bool    bjunk		# junk variable for "rg_openmask_req"

### EXTERNAL FUNCTION DECLARATIONS ###

double 	im_pars_cts()     # returns number of counts in image [local]
pointer rg_open_parser()  # returns pointer to "parsing control structure"
			  # [/pros/lib/regions]
bool 	rg_openmask_req() # returns TRUE if no higher routine has asked
			  # for a mask.  [/pros/lib/regions]

### BEGINNING OF PROCEDURE ###

begin

        #-----------------------------------------------------
        # Open necessary regions routines
        #-----------------------------------------------------
	parsing = rg_open_parser()
        bjunk = rg_openmask_req(parsing)
        call rg_imcreate(parsing, region, ip)

        #-----------------------------------------------------
        # Call local counting routine
        #-----------------------------------------------------
	tot_im_cts=im_pars_cts(ip,parsing,area)

        #-----------------------------------------------------
        # Close regions parser
        #-----------------------------------------------------
        call rg_close_parser(parsing)

        #-----------------------------------------------------
        # Return number of counts
        #-----------------------------------------------------
	return tot_im_cts
end


#--------------------------------------------------------------------------
# Procedure:    im_pars_cts
#
# Purpose:      Returns the number of counts in an image, given a
#               parsing control structure
#
# Input variables:
#               ip              image pointer
#               parsing		parsing control structure
#
# Output variables:
#               area            number of pixels in region
#
# Return value:
#               Returns number of counts [double]
#
#
# Description:  This routine will find the number of counts in the
#		image using the regions info in the parsing control
#		structure.
#
#--------------------------------------------------------------------------

double procedure im_pars_cts(ip,parsing,area)

pointer ip              # i: image pointer
pointer parsing		# i: parsing control structure
double  area            # o: area of region

### LOCAL VARS ###

double  cts             # return counts in image
int     stype		# image pixel type
pointer mp		# MIO descriptor

### EXTERNAL FUNCTION DECLARATIONS ###

pointer mio_openo()	# pointer to MIO descriptor [sys/pmio]

### BEGINNING OF PROCEDURE ###

begin
        #-----------------------------------------------------
        # open the source MIO descriptor, governing reading 
        # the source image through the region mask
        #-----------------------------------------------------
        mp = mio_openo(MASKPTR(parsing), ip)

        #-----------------------------------------------------
        # Initialize variables.
        #-----------------------------------------------------
        stype = IM_PIXTYPE(ip)
        cts=0.0D0
        area=0.0D0

        #-----------------------------------------------------
        # find source counts [routine updates cts & area]
        #-----------------------------------------------------
        call msk_cnts(mp, stype, cts, area, 1, 1)

        #-----------------------------------------------------
        # close the mask file
        #-----------------------------------------------------
        call mio_close(mp)

        #-----------------------------------------------------
        # Return number of counts
        #-----------------------------------------------------
        return cts
end

#--------------------------------------------------------------------------
# Procedure:    qp_cts
#
# Purpose:      Returns the number of counts in a qpoe file
#
# Input variables:
#               qp              QPOE pointer
#               filter		filter for QPOE [with brackets]
#
# Return value:
#               Returns number of counts [double]
#
#
# Description:  This routine will apply the passed-in filter on the
#               QPOE file and find the number of counts in the image.
#
# Note:		The constant LEN_EVBUF was chosen arbitrarily to be
#		512.  We just need some value which indicates to
#		qpio_getevents how much memory we set aside for the
#		events pointer.
#		
#--------------------------------------------------------------------------

define LEN_EVBUF  512

int procedure qp_cts(qp,filter)
pointer	qp		# i: QPOE file
char	filter[ARB]	# i: string filter [with brackets]

### LOCAL VARS ###

int	cts		# total counts found [return value]
int	n_ev		# number of events loaded in each pass
pointer	p_ev[LEN_EVBUF]	# temp pointer to events
int	mval		# unused: return mask value from qpio_getevents
pointer	qpio		# event i/o pointer

### EXTERNAL FUNCTION DECLARATIONS ###

int	qpio_getevents() # returns EOF if file is exhausted [sys/qpoe]
pointer qpio_open()      # returns i/o pointer [sys/qpoe]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # open QPOE i/o pointer.  (This applies the
	# filter to the QPOE.)
        #----------------------------------------------
        qpio = qpio_open(qp, filter, READ_ONLY)

        #----------------------------------------------
        # Continue applying qpio_getevents until no
	# more counts are found.  Update "cts".
        #----------------------------------------------
	cts=0
	while (qpio_getevents(qpio,p_ev,mval,LEN_EVBUF,n_ev)!=EOF)
	{
	    cts=cts+n_ev
	}

        #----------------------------------------------
        # close QPOE i/o pointer.
        #----------------------------------------------
	call qpio_close(qpio)

        #----------------------------------------------
        # Return number of counts.
        #----------------------------------------------
	return cts
end



