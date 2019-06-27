# $Header: /home/pros/xray/xspatial/eintools/be_ds_rotate/RCS/be_ds_rotate.x,v 11.0 1997/11/06 16:31:17 prosb Exp $
# $Log: be_ds_rotate.x,v $
# Revision 11.0  1997/11/06 16:31:17  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:00  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/31  10:41:32  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       be_ds_rotate.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_be_ds_rotate 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <qpc.h>
include <ext.h>
include "../source/et_err.h"
include "../source/band.h"
include "../tables/bkfac.h"

#--------------------------------------------------------------------------
# Procedure:    t_be_ds_rotate()
#
# Purpose:      Main procedure call for the task be_ds_rotate
#
# Input parameters:
#		qpoefile	QPOE file to make bkgd map for
#		bkfacfile	input BKFAC table
#		rbkmap		output bkgd map
#               pi_band         PI band to make counts for
#		original_data   flag: are we using original BE & DS data?
#               br_edge_reg     region to use on blocked images to 
#                               remove bright edge
#		xscale		final X-scaling
#		yscale		final Y-scaling
#		display		display level
#		clobber		overwrite output file?
#
#	If original_data is true, then we have these additional parameters:
#		
#		orig_be_hard	pathname of original BE hard image
#		orig_be_soft	pathname of original BE soft image
#		orig_ds_hard	pathname of original DS hard image
#		orig_ds_soft	pathname of original DS soft image
#
#	If original_data is false, then we have these additional parameters:
#		
#               defmaps         using default maps?
#               bemap           if not, which BEMAP?
#               dsmap           and which DSMAP?
#               def_[be/ds]_[hard/soft/broad] default pathnames for
#                               be/dsmaps, for these three bands
#
# Description:  This procedure reads in the appropriate parameters and
#		calls the routine "be_ds_rotate" which actually creates
#		the final rotated background map.
#
#		If "original_data" is true, then the user has requested
#		that we make the BE & DS maps in the same manner as
#		the original level one processing made them.  This means
#		that we read in the "BEHARD" or "BESOFT" bright Earth
#		columns from the BKFAC table, and that we use the
#		original bright Earth and deep survey maps (either hard
#		or soft) used in level one processing.
#
#		If "original_data" is false, the user has another option
#		to use default maps (if the band is one of hard, soft,
#		or broad).  If so, the bemap & dsmap parameters point
#		to the default map locations.  Otherwise, the user is
#		prompted for the locations of the BE & DS maps.
#
#		The final X and Y scale parameters refer to the scaling
#		of the final background map.  If they are each 1.0, then
#		the final background map should be of the same pixel
#		size as the input QPOE file.
#
# Note:         The parameters defmaps through the default be/ds 
#               pathnames are read in the routine beds_param.
#
#               Why do we use band2range, then range2band?  The first
#               routine (band2range) will convert the user declared
#               band into a range.  Thus "soft" becomes "2:4", etc.
#               The second routine, range2band, converts the range
#               into an index of possible bands.  (See band.h.)  Thus
#               the user can enter either "soft" or "2:4" and end up
#               with the SOFT_BAND band.
#
#		There are other hidden parameters which affect the rotation
#		and scaling algorithms; they are loaded later in
#		bk_geo_setup. 
#--------------------------------------------------------------------------

procedure t_be_ds_rotate()
pointer p_qpoe_expr	    # pointer to input qpoe expression 
			    #   (e.g., "i2060.qp[time=1000000:2000000]")
pointer p_bkfac_name	    # pointer to background factors table name
pointer p_rbkmap_name	    # pointer to output rotated background map
pointer p_pi_band	    # pointer to PI range
pointer p_rbkmap_name_temp  # pointer to temporary name for output file
pointer p_br_edge_reg	    # pointer to bright edge region
double	xscale		    # final X-scale of bkgd map
double	yscale		    # final Y-scale of bkgd map
bool	use_original_data   # flag: are we using original BE&DS maps?
pointer p_be_name	    # pointer to input BE map
pointer p_ds_name	    # pointer to input DS map
bool	clobber		    # flag: should we allow clobbering of output?
int	display		    # display level (0-5)

### LOCAL VARS ###

int	band	  	# band index (see ..source/band.h).
pointer p_qpoe_evlist   # pointer to event list portion of qpoe expression
pointer p_qpoe_name     # pointer to qpoe filename
pointer p_pi_range	# PI range (i.e. "2:4", etc.)
pointer sp	  	# stack pointer

### EXTERNAL FUNCTION DECLARATIONS ###

bool    clgetb()  # returns boolean CL parameter [sys/clio]
int	clgeti()  # returns integer CL parameter [sys/clio]
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
        call salloc( p_qpoe_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_qpoe_evlist, SZ_EXPR, TY_CHAR)
        call salloc( p_rbkmap_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_rbkmap_name_temp, SZ_PATHNAME, TY_CHAR)
	call salloc( p_pi_band, SZ_EXPR, TY_CHAR)
	call salloc( p_pi_range, SZ_EXPR, TY_CHAR)
        call salloc( p_be_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_ds_name, SZ_PATHNAME, TY_CHAR)
	call salloc( p_br_edge_reg, SZ_EXPR, TY_CHAR)
	
        #----------------------------------------------
        # read in some parameters
        #----------------------------------------------
        call clgstr("qpoefile",Memc[p_qpoe_expr],SZ_PATHNAME)
        call clgstr("bkfacfile",Memc[p_bkfac_name],SZ_PATHNAME)
        call clgstr("rbkmap",Memc[p_rbkmap_name],SZ_PATHNAME)
        call clgstr("pi_band",Memc[p_pi_band],SZ_EXPR)
	use_original_data=clgetb("original_data")
        call clgstr("br_edge_reg",Memc[p_br_edge_reg],SZ_EXPR)
	xscale=clgetd("xscale")
	yscale=clgetd("yscale")
	display=clgeti("display")
	clobber=clgetb("clobber")

        #----------------------------------------------
        # convert pi range into values, if soft/hard/broad
        #----------------------------------------------
        call strip_whitespace(Memc[p_pi_band])
        call band2range(Memc[p_pi_band],p_pi_range)

        #--------------------------------------------------
        # convert range into a band index (SOFT_BAND,
        #  HARD_BAND, BROAD_BAND, OTHER_BAND) [see band.h]
        #--------------------------------------------------
	call range2band(Memc[p_pi_range],band)

        #--------------------------------------------------
	# If we're using original data, load in pathnames
	# to original be & ds maps
        #--------------------------------------------------
	if (use_original_data)
	{
	    switch (band)
	    {
		case HARD_BAND:
	          call clgstr("orig_be_hard",Memc[p_be_name],SZ_PATHNAME)
                  call clgstr("orig_ds_hard",Memc[p_ds_name],SZ_PATHNAME)
   	        case SOFT_BAND:
                  call clgstr("orig_be_soft",Memc[p_be_name],SZ_PATHNAME)
                  call clgstr("orig_ds_soft",Memc[p_ds_name],SZ_PATHNAME)
		default:
		  call errstr(ET_UNKNOWN_BAND,
		    "PI range must be either soft or hard",Memc[p_pi_band])
	    }
	}
	else  # not using original data
	{
            #------------------------------------------------------
	    # read in bemap & dsmap from the appropriate parameter
            #------------------------------------------------------
	    call beds_param(band,Memc[p_be_name],Memc[p_ds_name])
	}

        #----------------------------------------------
        # massage the input parameter filenames:
        #    remove white space around filenames
        #    add roots to names
        #----------------------------------------------
        call strip_whitespace(Memc[p_rbkmap_name])
        call strip_whitespace(Memc[p_be_name])
        call strip_whitespace(Memc[p_ds_name])
        call strip_whitespace(Memc[p_bkfac_name])
        call strip_whitespace(Memc[p_qpoe_expr])
	call rootname(Memc[p_qpoe_expr],Memc[p_qpoe_expr],
		      EXT_QPOE,SZ_PATHNAME) 
	call rootname(Memc[p_qpoe_expr],Memc[p_bkfac_name],
		      EXT_BKFAC,SZ_PATHNAME) 
	call rootname(Memc[p_qpoe_expr],Memc[p_rbkmap_name],
		      EXT_BKGD,SZ_PATHNAME) 


        #----------------------------------------------
        # separate qpoe expression into name & evlist
        #----------------------------------------------
	call qp_parse(Memc[p_qpoe_expr], Memc[p_qpoe_name], SZ_PATHNAME,
		      Memc[p_qpoe_evlist], SZ_EXPR)


	if (display>3)
	{
	    call printf("Using bright Earth map %s\nand deep survey map %s\n")
	     call pargstr(Memc[p_be_name])
	     call pargstr(Memc[p_ds_name])
	    call printf("with the background factor table %s to create the output\n")
	     call pargstr(Memc[p_bkfac_name])
	    call printf("rotated background map %s for the qpoe file %s.\n")
	     call pargstr(Memc[p_rbkmap_name])
	     call pargstr(Memc[p_qpoe_name])
	    call printf("The background map will be scaled by (%.2f,%.2f).\n")
	     call pargd(xscale)
	     call pargd(yscale)
	    call flush(STDOUT)
	}

        #----------------------------------------------
        # check if output file already exists
        #----------------------------------------------
	call clobbername(Memc[p_rbkmap_name],Memc[p_rbkmap_name_temp],
			 clobber,SZ_PATHNAME)

        #----------------------------------------------
        # make background map!
        #----------------------------------------------
	call be_ds_rotate(Memc[p_qpoe_name],Memc[p_bkfac_name],
			  Memc[p_rbkmap_name_temp], Memc[p_rbkmap_name],
			  Memc[p_be_name],Memc[p_ds_name],xscale,yscale,
			  use_original_data,band,Memc[p_pi_range],
			  Memc[p_br_edge_reg],display )

        #----------------------------------------------
        # rename temp file to output file
        #----------------------------------------------
	call finalname(Memc[p_rbkmap_name_temp],Memc[p_rbkmap_name])

	if (display>0)
	{
	   call printf("\nCreated rotated background map %s.\n")
	     call pargstr(Memc[p_rbkmap_name])
	}

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end
