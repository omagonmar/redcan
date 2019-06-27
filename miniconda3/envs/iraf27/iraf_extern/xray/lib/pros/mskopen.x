#$Header: /home/pros/xray/lib/pros/RCS/mskopen.x,v 11.0 1997/11/06 16:20:41 prosb Exp $
#$Log: mskopen.x,v $
#Revision 11.0  1997/11/06 16:20:41  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:44  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:06  prosb
#General Release 2.3
#
#Revision 6.1  93/06/16  17:07:10  prosb
#jso - commented out pm_newcopy because on the DECStation (DSUX) it
#     cannot be opened at the same time as pl_newcopy.
#
#Revision 6.0  93/05/24  15:45:17  prosb
#General Release 2.2
#
#Revision 5.4  93/05/19  03:49:47  dennis
#Put the dimensions of the mask, not of the image section at the time of 
#creating it, in the mask header.
#
#Revision 5.3  93/05/19  00:05:09  dennis
#Removed the recently added change (Rev. 5.2) to its proper place, in 
#rg_pmcreate() and rg_imcreate().
#
#Revision 5.2  93/05/12  00:03:04  dennis
#In msk_open(), prevented PMIO routines from taking coordinates of an 
#already-created region mask (in image-relative coordinates) as 
#section-relative.
#
#Revision 5.1  93/04/26  23:55:28  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:17:09  prosb
#General Release 2.1
#
#Revision 4.1  92/09/02  02:45:02  dennis
#Replaced erroneous call to rg_isfile() with call to rg_ftype();
#removed erroneous call to dec_plhead(), and references to its results.
#Removed extra freeing of memory pointed to by "regions".
#Corrected several buffer sizes, to SZ_PATHNAME or SZ_2PATHNAMESPLUS.
#Changed name timages[] to more accurate tmasks[].
#
#Revision 4.0  92/04/27  13:49:20  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:00:54  wendy
#General
#
#Revision 2.1  91/07/03  14:47:41  mo
#MC	7/3/91		Fixed bad types for the escale and rscale
#			parameters.  This was causing IRAFX to
#			ignore MASK specifiers for regions.
#
#Revision 2.0  91/03/07  00:07:16  pros
#General Release 1.0
#
# Module:       MSKOPEN.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      < opt, brief description of whole family, if many routines>
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>    
#               {1} MC  -- Update include files  -- 2/21/91
#               {n} <who> -- <does what> -- <when>

include <plio.h>
include <pmset.h>

include <plhead.h>
include	<regparse.h>	# Defines SZ_2PATHNAMESPLUS, parsing control structure
include <error.h>

# max value in an exposure mask
define MAXEXPOSURE	32767.0

define TY_IMWCS	1
define TY_QPWCS	2

pointer procedure msk_imopen(parsing, regname, expname, thresh, im, title)

pointer	parsing			# i: pointer to parsing control structure
char	regname[ARB]		# i: region descriptor
char	expname[ARB]		# i: exposure mask file spec
real	thresh			# i: exposure threshold
pointer	im			# i: image handle, or 0 for pl
pointer	title			# o: reg + exp .pl file header

pointer	msk_open()		# l: open a mask

begin
	return(msk_open(parsing, regname, expname, thresh, im, title,TY_IMWCS))
end

pointer procedure msk_qpopen(parsing, regname, expname, thresh, qp, title)

pointer	parsing			# i: pointer to parsing control structure
char	regname[ARB]		# i: region descriptor
char	expname[ARB]		# i: exposure mask file spec
real	thresh			# i: exposure threshold
pointer	qp			# i: qpoe handle
pointer	title			# o: reg + exp .pl file header

pointer	msk_open()		# l: open a mask

begin
	return(msk_open(parsing, regname, expname, thresh, qp, title,TY_QPWCS))
end

#
# MSK_OPEN -- open a region mask and/or an exposure mask,
# and combine the two into a final mask, given an exposure threshold;
# this routine performs pl calls if im == 0, else pm calls
#
pointer procedure msk_open(parsing_ext, regname, expname, thresh, im, title, 
									itype)

pointer	parsing_ext		# i: pointer to external parsing control 
				#     structure, or NULL
char	regname[ARB]		# i: region descriptor
char	expname[ARB]		# i: exposure mask file spec
real	thresh			# i: exposure threshold
pointer	im			# i: image handle, or 0 for pl
pointer	title			# o: reg + exp .pl file header
int	itype			# i: type of WCS

pointer	parsing_local			# l: local variable for pointer to 
					#     parsing control structure
bool	new_openmask_req		# l: true if no higher level routine 
					#     has already requested an opened
					#     region mask
bool	new_expdesc_req			# l: true if no higher level routine 
					#     has already requested expanded 
					#     region descriptor
int	naxes				# l: number of axes of region mask
long	axislenl[PL_MAXDIM]		# l: region mask axis lengths
int	depth				# l: region mask depth, in bits
int	axislen[2]			# l: region mask axis lengths
char	etitle[SZ_PLHEAD]		# l: exposure mask title
char	tmasks[SZ_2PATHNAMESPLUS]	# l: temp mask name string buffer
int	ithresh				# l: int threshold for exposure
int	isplio				# l: is descr. a plio file?
pointer	em				# l: exposure pixel mask handle
pointer	pm				# l: merges pixel mask handle

bool	streq()				# l: string compare
pointer	rg_open_parser()		#  : prepare parser for requests
bool	rg_openmask_req()		#  : set up request for opened 
					#     region mask from parser
bool	rg_expdesc_req()		#  : set up request for expanded 
					#     region descriptor from parser
int	rg_ftype()			# l: is descriptor a plio file?
pointer	pl_newcopy()			#  : get template for dup of a mask
# DSUX compiler won't allow pm_newcopy and pl_newcopy
# to be declared simultaneously
#pointer	pm_newcopy()		#  : get template for dup of a mask
pointer	rg_pmmask()			# l: merge masks with a threshold
pointer	rg_plmask()			# l: merge masks with a threshold
# VMS compiler won't allow pm_open and pl_open to be declared simultaneously
#pointer	pm_open()			# l: open a pixel mask
pointer	pl_open()			# l: open a pixel mask

# exposure mask info from dec_plhead():
char	ename[SZ_PATHNAME]
char	etype[SZ_LINE]
char	efile[SZ_PATHNAME]
int	exdim, eydim
double	escale
pointer	eregions
pointer	enotes

char	rname[SZ_PATHNAME]	# (Assumes not already a combined mask)

begin
	# common code called by msk_..open()

# ==========================================================================
#	Get opened region mask & expanded region descriptor from parser
# ==========================================================================
	if (parsing_ext != NULL)
	    parsing_local = parsing_ext
	else
	    parsing_local = rg_open_parser()

	new_openmask_req = rg_openmask_req(parsing_local)
	new_expdesc_req = rg_expdesc_req(parsing_local)

	switch(itype){
	case TY_IMWCS:
		call rg_imcreate(parsing_local, regname, im)
	case TY_QPWCS:
		call rg_qpcreate(parsing_local, regname, im)
	}

	# get dimensions of the mask
	call pl_gsize(MASKPTR(parsing_local), naxes, axislenl, depth)
	axislen[1] = axislenl[1]
	axislen[2] = axislenl[2]

	# (if region descriptor was a file spec or root, get the file's full 
	#  name and type; if it's a .pl file, we'll include its name in 
	#  mask_name in the header of the exposure-filtered mask)
	isplio = rg_ftype(regname, rname, SZ_PATHNAME)

# ==========================================================================
#	Filter region mask through "booleanized" exposure mask
# ==========================================================================
	# allocate space for a header for the exposure-filtered region mask
	call calloc(title, SZ_PLHEAD, TY_CHAR)

	if( streq(expname, "NONE") ){
	    # ----------------
	    # No exposure mask
	    # ----------------
	    # make a copy of the region mask (to be independent of the 
	    #  parsing control structure)
	    if (im == 0)  {
		pm = pl_newcopy (MASKPTR(parsing_local))
		call rg_plcopy (pm, MASKPTR(parsing_local))
	    } else {
# DSUX compiler won't allow pm_newcopy and pl_newcopy
# to be declared simultaneously
		pm = pl_newcopy (MASKPTR(parsing_local))
		call rg_pmcopy (pm, MASKPTR(parsing_local))
	    }

	    # create a plio header
	    call sprintf(tmasks, SZ_LINE, "%s")
	    if( isplio >1 )
		call pargstr(rname)
	    else
		call pargstr("in memory")
	    # encode the pl header
	    call enc_plhead(tmasks, "region", "", axislen[1], axislen[2],
	    	0.0D0, EXPDESCPTR(parsing_local), Memc[title], SZ_PLHEAD)
	    # add a note about the exposure
	    call enc_plnote("", "no exposure correction", TY_CHAR,
			Memc[title], SZ_PLHEAD)
	}
	else{
	    # -------------------------
	    # There is an exposure mask
	    # -------------------------
	    # get the scaled threshold
	    ithresh = (thresh*MAXEXPOSURE/100.0)
	    # read in the exposure mask
	    if( im ==0 ){
		em = pl_open(NULL)
		call pl_loadf(em, expname, etitle, SZ_PLHEAD)
		# merge the two masks into a final mask
		pm = rg_plmask(em, MASKPTR(parsing_local), ithresh)
		# close the exposure mask
		call pl_close(em)
	    }
	    else{
		em = pl_open(NULL)
#		em = pm_open(NULL)
		call pm_loadf(em, expname, etitle, SZ_PLHEAD)
		# merge the two masks into a final mask
		pm = rg_pmmask(em, MASKPTR(parsing_local), ithresh)
		# close the exposure mask
		call pm_close(em)
	    }

	    # Create the .pl header for this exposure-filtered region mask

	    # decode the exposure .pl header to get the exposure mask_name, 
	    #  its ref_file name (if any), and any .pl header notes
	    call dec_plhead(etitle, ename, SZ_PATHNAME, etype, SZ_LINE,
		efile, SZ_PATHNAME, exdim, eydim, escale, eregions, enotes)

	    # combine the region and exposure headers into one header

	    # tmasks gets mask_name for the exposure-filtered region mask
	    call sprintf(tmasks, SZ_2PATHNAMESPLUS, "%s & %s")
	    if( isplio >1 )
		call pargstr(rname)
	    else
		call pargstr("in memory")
	    call pargstr(ename)

	    # create the pl header
	    #  (notice that the exposure mask's ref_file, if any, becomes 
	    #   the exposure-filtered region mask's ref_file)
	    call enc_plhead(tmasks, "region & exposure", efile,
		axislen[1], axislen[2], 0.0D0,
		EXPDESCPTR(parsing_local), Memc[title], SZ_PLHEAD)
	    # add exposure notes, if necessary
	    if( enotes !=0 )
		call enc_plnote("", Memc[enotes], TY_CHAR,
			Memc[title], SZ_PLHEAD)
	    # add the exposure threshold
	    call enc_plnote("exposure threshold", thresh, TY_REAL,
			Memc[title], SZ_PLHEAD)
	    # and release the region summary space
	    call mfree(eregions, TY_CHAR)
	    call mfree(enotes, TY_CHAR)
	}

	# if no higher-level routine passed in a parsing request ...
	if (parsing_ext == NULL)
	    # ... close everything from the region descriptor parsing
	    call rg_close_parser(parsing_local)
	else {
	    # if no higher-level routine also wants it ...
	    if (new_openmask_req)
		# ... close region mask
		call rg_openmask_rel(parsing_local)
	    # if no higher-level routine also wants it ...
	    if (new_expdesc_req)
		# ... free expanded region descriptor buffer and pointer to it
		call rg_expdesc_rel(parsing_local)
	}

	# return final pointer
	return(pm)
end
