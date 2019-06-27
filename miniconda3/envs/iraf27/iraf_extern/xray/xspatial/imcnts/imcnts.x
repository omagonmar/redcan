#$Header: /home/pros/xray/xspatial/imcnts/RCS/imcnts.x,v 11.0 1997/11/06 16:32:48 prosb Exp $
#$Log: imcnts.x,v $
#Revision 11.0  1997/11/06 16:32:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:11  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/07  17:38:28  janet
#jd - fixed null bk input when qpoe, added dynamic allocation of all buffers.
#
#Revision 8.0  94/06/27  15:14:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:42  prosb
#General Release 2.3
#
#Revision 6.3  93/12/03  01:05:03  dennis
#Added poisserr, to select Poisson or Gaussian error estimation from data.
#
#Revision 6.2  93/12/03  00:15:18  dennis
#Keep QPOE header around to put into table file.
#
#Revision 6.1  93/07/16  21:41:52  dennis
#Corrected error of taking background or background error file names that 
#begin with numbers, as constant values.
#
#Revision 6.0  93/05/24  16:20:14  prosb
#General Release 2.2
#
#Revision 5.4  93/05/01  01:06:55  dennis
#Corrected possible closing of bemp and beim that hadn't been opened, 
#due to uninitialized bemp.
#
#Revision 5.3  93/04/27  00:18:42  dennis
#Regions system rewrite.
#
#Revision 5.2  92/11/30  17:54:44  mo
#MC	11/30/92	Fixed the "." bkgd file case ( again! )
#
#Revision 5.1  92/11/30  11:53:53  mo
#MC	11/30/92	Fixed bug that didn't allow a constant BKGDERR 
#			specification.  
#
#Revision 5.0  92/10/29  21:33:59  prosb
#General Release 2.1
#
#Revision 4.8  92/10/02  10:32:13  mo
#MC	10/1/92			Return the 'rootname' for bimage to 
#				original form.  There is very special
#				IMCNTS code to handle the 'null' bimage
#				filename option when wanting the same
#				bimage as simage
#
#Revision 4.7  92/09/23  15:50:24  mo
#MC	9/23/92		Add the SIMAGE to the rootname call for bimage
#			so that the "" filename specifier will work
#
#Revision 4.6  92/09/11  14:59:34  mo
#MC	9/11/92		Worked around IMACCESS bug that didn't
#			recognise QPOE files with filters ( but
#			not sections. )  This was a problem for
#			our background file and background error file.
#
#Revision 4.5  92/09/08  21:20:29  dennis
#Allow notes values and strings for smax, not sindices, regions.
#Correct initialization of Memd[berrors].  Improve a few comments.
#
#Revision 4.4  92/09/04  17:04:45  mo
#MC	9/4/92		Fix the bug that interpreted background filenames
#			starting with '.' or digits to be values
#
#Revision 4.3  92/08/11  14:20:21  dennis
#Moved the call to rootname() for the background file to after the check 
#for a constant background.  (Required by recent change in rootname() to 
#reject file name starting with a digit.)
#
#Revision 4.2  92/08/07  18:00:49  dennis
#New dependency on <regparse.h>:
#	Correct buffer size for sregion, bregion;
#	Replace literal 70 with SZ_NOTELINE;
#Correct size of nstr allocation;
#Change nullstr from static to dynamically allocated array.
#
#Revision 4.1  92/07/07  23:54:41  dennis
#Added new parameter (minimum region number) in calls to imcntsubs.x 
#routines cnt_rawdisp(), cnt_profile(), cnt_finaldisp(), and cnt_filltable(),
#to get the correct region numbers and parameters (radii and angles) 
#when the minimum region number in a mask is not 1.
#
#Revision 4.0  92/04/27  14:41:11  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/14  17:57:31  dennis
#Fix bug in Rev 3.3 change:  If no sregnotes, assign 0 to nflag
#
#Revision 3.3  92/04/10  18:15:02  dennis
#Accept .pl file without ASCII region descriptor
#
#Revision 3.0  91/08/02  01:27:25  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:12:40  pros
#General Release 1.0
#
# Module:       IMCNTS
# Project:      PROS -- ROSAT RSDC
# Purpose:      count photons in regions with normalized bkgd subtraction
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM -- initial version <when>    
#               {1} MC -- Update comments -- 	2/91
#               {n} <who> -- <does what> -- <when>
#
#	IMCNTS - count photons in regions with normalized bkgd subtraction
#

include <ctype.h>
include <imhdr.h>
include <pmset.h>
include	<error.h>

include <ext.h>
include <qpoe.h>

include <regparse.h>

include "imcnts.h"
define  IS_SIGN        ($1=='+'||$1=='-')
define  TYPE_INIT      999

procedure t_imcnts()


pointer	srg_parsing		# pointer to source region parsing control 
				#  structure
pointer bimage			# bkgd image name
pointer broot			# bkgd image name
pointer simage			# source image name
pointer sregion 		# source region descr
pointer sexposure		# source exposure file
pointer serror			# source error file
pointer bregion 		# bkgd region descr
pointer bexposure		# bkgd exposure file
pointer berror			# bkgd error file
pointer table			# table file name
pointer xtable			# temp table file name

bool	bjunk			# unneeded return from parser request routine

pointer	nullstr			# null string
int	sz_nullstr		# length of nullstr

int	smin, smax		# min and max indices for source regions
int	sindices		# total indices for source regions
int	stype			# data type of source
int	bmin, bmax		# min and max indices for bkgd regions
int	bindices		# total indices for bkgd regions
int	btype			# data type of bkgd
int	type			# type of counting we do - see above
#int	nchar			# number of characters converted by ctod
int	ip			# ctod pointer
int	dotable			# flag that a table file is required
bool	isdval			# bkgd or bkgd error param may be a constant
bool	isberrf			# there's a background error file, not constant
bool	matchbkgd		# match bkgd regions to source regions
int	doberr			# add bkgd to error calculation?
int	dotimenorm              # TRUE for live time normalization

bool	clobber			# clobber old table file
int     display                 # display level

real	sthresh			# exposure threshold for including source 
				#					pixels
real	bthresh			# exposure threshold for including bkgd pixels
real	sdpp			# source deg/pix
real	bdpp			# bkgd deg/pix

double	bkgdvalue		# constant bkgd/sq pixel
double	bkgderr			# error on constant bkgd
double	normfactor		# time + user normalization factor

pointer	sim 			# source image pointer
bool	isheader		# whether source image has a standard header
pointer	shead			# source header
int	poisserr		# YES/NO:  Poisson/Gaussian error estimation
pointer	spm			# exposure-filtered region mask for source
pointer	smp			# MIO descriptor to read source image thru mask
pointer	stitle			# header of exposure-filtered region mask for 
				#  source
pointer	scounts			# counts in source
pointer	sarea			# area in source
pointer	serrors			# errors on source from external file
pointer	seim 			# source error image pointer
# pointer	sepm		# exposure-filtered region mask for source 
				#  error data (image)
pointer	semp			# MIO descriptor to read source error data 
				#  (image) thru mask
# pointer	setitle		# header of exposure-filtered region mask for 
				#  source error data (image)


pointer	bim			# bkgd image pointer
pointer	bhead			# bkgd header
pointer	bpm			# exposure-filtered region mask for bkgd
pointer	bmp			# MIO descriptor to read bkgd image thru mask
pointer	btitle			# header of exposure-filtered region mask for 
				#  bkgd
pointer	bcounts			# counts in bkgd
pointer	barea			# area in bkgd
pointer	berrors			# errors on bkgd from external file
pointer	beim 			# bkgd error image pointer
# pointer	bepm		# exposure-filtered region mask for bkgd 
				#  error data (image)
pointer	bemp			# MIO descriptor to read bkgd error data 
				#  (image) thru mask
# pointer	betitle		# header of exposure-filtered region mask for 
				#  bkgd error data (image)

pointer	bscounts		# counts in bkgd-subtracted source
pointer	bsarea			# area in bkgd-subtracted source
pointer	bserrors		# error on bscountss
pointer	bncounts		# counts in normalized bkgd
pointer	bnerrors		# error on normalized bkgd
pointer	brightness		# cts/pixel
pointer	profile			# profile
pointer	errness			# err/pixel
pointer	djunk			# pointer to temp double array
pointer	sp			# stack pointer

# table pointers
pointer	tp			# table pointer
pointer	cp[MAX_CP]		# array of column pointers

bool	clgetb()		# get boolean parameter
bool    streq()                 # checks if 2 strings match
bool	ck_none()		# check for "NONE" or abbrev, u.c. or l.c.
bool	ck_dval()		# convert ascii to double
bool	rg_oneregnotes_req()	# request single-region notes from parser
int     clgeti()		# get integer parameter
int	btoi()			# convert boolean to int
int	is_imhead()		# YES if we have an X-ray header
int	imaccess()
pointer	immap()			# open an image
pointer	rg_open_parser()	# open parser
pointer	msk_imopen()		# open a region and/or exposure mask
pointer	mio_openo()		# open a pixel mask for MIO
real	clgetr()		# get a real param
double	clgetd()		# get double parameter routine

begin
	# mark the stack
	call smark(sp)
        call salloc (broot,     SZ_PATHNAME,     TY_CHAR)
        call salloc (bimage,    SZ_PATHNAME,	 TY_CHAR)
	call salloc (simage,    SZ_PATHNAME,	 TY_CHAR)			
	call salloc (sregion,   SZ_REGINPUTLINE, TY_CHAR)	
	call salloc (sexposure, SZ_PATHNAME,	 TY_CHAR)
	call salloc (serror,    SZ_PATHNAME,	 TY_CHAR)			
	call salloc (bregion,   SZ_REGINPUTLINE, TY_CHAR)	
	call salloc (bexposure, SZ_PATHNAME,	 TY_CHAR)			
	call salloc (berror,    SZ_PATHNAME,	 TY_CHAR)			
	call salloc (table,     SZ_PATHNAME,	 TY_CHAR)			
	call salloc (xtable,    SZ_PATHNAME,	 TY_CHAR)			
	
	# initialize pointers to source and bkgd exposure-filtered region 
	#  mask headers (to be allocated by msk_open())
	stitle = NULL
	btitle = NULL

	# make a null string for later use
	sz_nullstr = max(SZ_PATHNAME, SZ_REGINPUTLINE)
	call salloc(nullstr, sz_nullstr, TY_CHAR)
	call strcpy("", Memc[nullstr], sz_nullstr)

	# initalize bkgd type
        type = TYPE_INIT 

# ==========================================================================
#	Get parameters from the user
# ==========================================================================
	display = clgeti("display")

	# --------------------------------------------------------------
	# get user's specs of source image, region, exposure, error data
	# --------------------------------------------------------------
	call clgstr("source", Memc[simage], SZ_PATHNAME)
	call clgstr("region", Memc[sregion], SZ_REGINPUTLINE)
	# get exposure stuff for source
	call clgstr("exposure", Memc[sexposure], SZ_PATHNAME)
	call rootname(Memc[simage], Memc[sexposure], EXT_EXPOSURE, SZ_PATHNAME)
	if (!ck_none(Memc[sexposure])) {
	    sthresh = clgetr("expthresh")
	    if( sthresh < 0.0 )
		call error(1, "exposure threshold must be >=0")
	}
	else
	    sthresh = -1.0
	# get external error file
	call clgstr("err", Memc[serror], SZ_PATHNAME)
	call rootname(Memc[simage], Memc[serror], EXT_ERROR, SZ_PATHNAME)

	# -------------------------------------------------------------
	# get user's specs of bkgd image, region, exposure, error data, 
	#  and figure out how to use the background
	# -------------------------------------------------------------
	call clgstr("bkgd", Memc[bimage], SZ_PATHNAME)
	# try to convert ascii to double
	# if so, we have a constant bkgd and we know the source/bkgd type
	call rootname("", Memc[bimage], "", SZ_PATHNAME)
	call imgcluster (Memc[bimage], Memc[broot], SZ_PATHNAME)	
	ip = 1
	isdval = ck_dval(Memc[bimage],ip,bkgdvalue)

	if ( display >= 5 )  {
           call printf ("broot= %s, bimage= %s \n")
	     call pargstr (Memc[broot])
	     call pargstr (Memc[bimage])
	}

#       looking for none as input bkgd
	if( ck_none(Memc[bimage]) ){
	    if ( display >= 5 ) 
               call printf ("in ck_none\n")
	    call strcpy(Memc[nullstr], Memc[bimage], SZ_PATHNAME)
	    call strcpy(Memc[nullstr], Memc[bregion], SZ_REGINPUTLINE)
	    type = CONSTANT_BKGD
	    bkgdvalue = 0.0
	}
	else if (streq (Memc[bimage],"") ) {
	    call strcpy(Memc[simage], Memc[bimage], SZ_PATHNAME)
	    if ( display >= 5 )  {
              call printf ("blank bk, set to -> bimage= %s \n")
	        call pargstr (Memc[bimage])
	    }
	    # if not, get the bkgd region
	    call clgstr("bkgdregion", Memc[bregion], SZ_REGINPUTLINE)
	    # determine the relationship between source and bkgd
	    call cnt_bstype (Memc[simage], Memc[sregion], Memc[bimage],
                             Memc[bregion], bkgdvalue, type)
	}
	else if( imaccess(Memc[broot],READ_ONLY)== YES ){ 
	    if ( display >= 5 )  
               call printf ("in imaccess - READ_ONLY\n")
	    #  Need to expand the "." option, if used
  	    call rootname(Memc[simage], Memc[bimage], "", SZ_PATHNAME)
	    if ( display >= 5 )  {
              call printf ("after rootname -> bimage= %s \n")
	        call pargstr (Memc[bimage])
	    }
	    # if not, get the bkgd region
	    call clgstr("bkgdregion", Memc[bregion], SZ_REGINPUTLINE)
	    # determine the relationship between source and bkgd
	    call cnt_bstype (Memc[simage], Memc[sregion], Memc[bimage],
                             Memc[bregion], bkgdvalue, type)
	}
	else if( isdval ){
	    if ( display >= 5 ) 
               call printf ("in isdval\n")
	    call strcpy(Memc[nullstr], Memc[bimage], SZ_PATHNAME)
	    call strcpy(Memc[nullstr], Memc[bregion], SZ_REGINPUTLINE)
	    type = CONSTANT_BKGD
	}
	else {
	    call errstr(1,"Not an accessible bkgd file or value",Memc[bimage])
	}

        if ( display >= 5 ) {
	   call printf ("type = %d\n")
	     call pargi (type)
        }
        call flush (STDOUT)

	if( type != CONSTANT_BKGD ){
	    # get whether to match background regions to source regions
	    matchbkgd = clgetb("matchbkgd")

	    # get exposure stuff for bkgd
	    call clgstr("bkgdexposure", Memc[bexposure], SZ_PATHNAME)
	    call rootname(Memc[bimage], Memc[bexposure], EXT_EXPOSURE, 
                          SZ_PATHNAME)
	    if (!ck_none(Memc[bexposure])) {
		bthresh = clgetr("bkgdthresh")
		if( bthresh < 0.0 )
		    call error(1, "exposure threshold must be >=0")
	    }
	    else
		bthresh = -1.0
	}
	# for no bkgd, skip bkgd error as well
	if( (type == CONSTANT_BKGD) && (bkgdvalue ==0.0) ){
	    doberr = NO
	}
	else{
	    # see if user wants bkgd added to error calculation
	    doberr = btoi(clgetb("addbkgderr"))
	}
	if( doberr == YES ){
	    # get the bkgd error string
	    call clgstr("bkgderr", Memc[berror], SZ_PATHNAME)
	    call rootname("", Memc[berror], "", SZ_PATHNAME)
	    # for possible constant bkgd, convert to constant value
	    ip = 1
	    isdval = ck_dval(Memc[berror],ip,bkgderr)
	    call imgcluster (Memc[berror], Memc[broot], SZ_PATHNAME)
	    isberrf = false		# initializing
	    if( ck_none(Memc[berror]) ){
	        bkgderr = 0.0D0
	    }
	    else if( (imaccess(Memc[broot],READ_ONLY)==YES) ){ 
		isberrf = true
		if( type == CONSTANT_BKGD )
		    call errstr(1,
		     "bkgd error must be const. for const. bkgd", Memc[berror])
	    }
	    else if( !isdval ){
		    call errstr(1,
			    "BKGDERR not an accessible file or valid value",
			     Memc[berror])
	    }
	}
	# don't add bkgd to error
	else{
	    call strcpy("NONE", Memc[berror], SZ_PATHNAME)
	    bkgderr = 0.0D0
	}

	# -------------------------------	
	# get flag for time normalization
	# -------------------------------
	dotimenorm = btoi(clgetb ("timenorm"))

	# ----------------------------
	# get the normalization factor
	# ----------------------------
	normfactor = clgetd("normfactor")

	# -----------------------
	# get the table file name
	# -----------------------
	call clgstr("table", Memc[table], SZ_PATHNAME)
	call rootname(Memc[simage], Memc[table], EXT_CNTS, SZ_PATHNAME)
	if (ck_none(Memc[table])) {
	    dotable = NO
	} else {
	    # get flag for clobbering old table file
	    clobber = clgetb ("clobber")
	    dotable = YES
	}
	call clobbername(Memc[table], Memc[xtable], clobber, SZ_PATHNAME)

# ==========================================================================
#	Open image file and (region and exposure) mask, then open MIO 
#	 descriptor to read the image through the mask, for source and for 
#	 bkgd; also get "expanded" region descriptors for display to user, and 
#	 single-source-region notes, for display and inclusion in table file
# ==========================================================================

	if (type == NO_SOURCE)
	    call error(EA_FATAL, "no source file specified")
	if (type == SAME_SAME)
	    call error(EA_FATAL, 
			"{source, bkgd} AND {source reg, bkgd reg} the same")
	if( (type != SAME_OTHER) && (type != OTHER_SAME) && 
	    (type != OTHER_OTHER) && (type != CONSTANT_BKGD) )
	    call error(EA_FATAL, "unknown source/bkgd type")	

	# ------
	# Source
	# ------
	# open the source image
	sim = immap(Memc[simage], READ_ONLY, 0)

	# open region descriptor parser for source regions, and set up 
	#  request for single-region notes
	# (This is an unusual use of the parser.  msk_open() (called by 
	#  msk_imopen()) receives a region descriptor, exposure mask spec, 
	#  and exposure threshold; it sets up a parser request to get a 
	#  region mask and expanded descriptor; it then filters the resulting 
	#  region mask through a boolean mask made from the exposure mask, 
	#  according to the exposure threshold; it also incorporates the 
	#  expanded region descriptor into the header (title) for this 
	#  filtered region mask; it doesn't, except as requested through 
	#  the parsing structure, return anything directly from the parsing 
	#  of the region descriptor.  This, then, is a request to pass back 
	#  the region-by-region notes from the parsing of the region 
	#  descriptor.)
	srg_parsing = rg_open_parser()
	bjunk = rg_oneregnotes_req(srg_parsing)

	# open a mask made by filtering the source region mask through a 
	#  boolean mask whose set pixels had exposure >= sthresh
	spm = msk_imopen (srg_parsing, Memc[sregion], Memc[sexposure], 
                          sthresh, sim, stitle)

	# open the source MIO descriptor, governing reading the source image 
	#  through the source mask
	smp = mio_openo(spm, sim)

	# ----------
	# Background
	# ----------
	if (type != CONSTANT_BKGD) {
	    # open the bkgd image
	    bim = immap(Memc[bimage], READ_ONLY, 0)

	    # open a mask made by filtering the bkgd region mask through a 
	    #  boolean mask whose set pixels had exposure >= bthresh
	    bpm = msk_imopen (NULL, Memc[bregion], Memc[bexposure], bthresh,  
                              bim, btitle)

	    # open the bkgd MIO descriptor, governing reading the bkgd image 
	    #  through the bkgd mask
	    bmp = mio_openo(bpm, bim)
	}

# ==========================================================================
#	Get deg/pix (for area normalization of bkgd)
# ==========================================================================

	# first, assume we don't use deg/pixel in the bkgd normalization
	sdpp = -1.0
	bdpp = -1.0
	# if there is a source header, try to get the degrees/pixel from it; 
	# keep the header around to put into output table file
	isheader = (is_imhead(sim) == YES)
	if( isheader ){
	    call get_imhead(sim, shead)
	    sdpp = abs(QP_CDELT1(shead))
	    poisserr = QP_POISSERR(shead)
	} else
	    poisserr = YES
	# if there is a bkgd header, try to get the degrees/pixel from it
	if( type != CONSTANT_BKGD ){
	    if( is_imhead(bim) == YES ){
		call get_imhead(bim, bhead)
		bdpp = abs(QP_CDELT1(bhead))
		call mfree(bhead, TY_STRUCT)
	    }
	}
	# make sure we have deg/pix for both files
	# or else don't make that correction in bkgd normalization
	if( (sdpp <0.0 ) || (bdpp <0.0) ){
	    sdpp = 1.0
	    bdpp = 1.0
	}

# ==========================================================================
#	Open the table file (if necessary), set up the columns, and give it 
#	 a standard header (if one is available)
# ==========================================================================

	if( dotable == YES ) {
	    call cnt_initable(Memc[xtable], tp, cp, type, bkgdvalue, doberr, 
						ANNPIEFLAGS(srg_parsing))
	    if( isheader ) {
		call put_tbhead(tp, shead)
		call mfree(shead, TY_STRUCT)
	    }
	}

# ==========================================================================
#	Open files providing source error data and background error data, 
#	 if necessary
# ==========================================================================

	# ------
	# Source
	# ------
	if (!ck_none(Memc[serror])) {
	    # open the image file that contains the source error data
	    seim = immap(Memc[serror], READ_ONLY, 0)
	    # open the source error MIO descriptor, governing reading the 
	    # source error data (image) through the source mask
	    semp = mio_openo(spm, seim)
	}
	else
	    semp = 0

	# ----------
	# Background
	# ----------
	if( doberr == YES ){
	    # see if we have an external file
	    if (isberrf) {
		# open the image file that contains the bkgd error data
		beim = immap(Memc[berror], READ_ONLY, 0)
		# open the bkgd error MIO descriptor, governing reading the 
		#  bkgd error data (image) through the bkgd mask
		bemp = mio_openo(bpm, beim)
	    }
	    # else see if it's constant bkgd
	    else 
		bemp = 0
	} else		# doberr == NO
	    bemp = 0

# ==========================================================================
#	Make sure source and background images are 1D or 2D
# ==========================================================================

	if( IM_NDIM(sim) > 2 )
	    call error(EA_FATAL, "source image dimensions must be <= 2")
	stype = IM_PIXTYPE(sim)

	if( type != CONSTANT_BKGD ){
	    if( IM_NDIM(bim) > 2 )
		call error(EA_FATAL, "bkgd image dimensions must be <= 2")
	    btype = IM_PIXTYPE(bim)
	}

# ==========================================================================
#	Display (region and exposure) mask headers for source and bkgd; 
#	 store the image file specs, the mask headers, and the error file 
#	 specs in the table header
# ==========================================================================

	# ------
	# Source
	# ------
	call msk_disp("SOURCE", Memc[simage], Memc[stitle])
	# put source into table
	if( dotable ==	YES ){
	    call put_tbh(tp, "source", Memc[simage], Memc[stitle])
	    # write in source error origination info
	    if( semp !=0 )
		call tbhadt(tp, "serr", Memc[serror])
	    else
		call tbhadt(tp, "serr", "source errors calc'ed from data")
	}

	# ----------
	# Background
	# ----------
	if( type != CONSTANT_BKGD ){
	    call msk_disp("BACKGROUND", Memc[bimage], Memc[btitle])
	    # put bkgd into table
	    if( dotable == YES ){
		call put_tbh(tp, "bkgd", Memc[bimage], Memc[btitle])
		# write in bkgd error origination info
		if( doberr == YES ){
		    if( bemp !=0 )
			call tbhadt(tp, "berr", Memc[berror])
		    else
			call tbhadt(tp, "berr","bkgd errors calc'ed from data")
		}
		else
		    call tbhadt(tp, "berr", "bkgd error not calculated")
	    }
	}
	else{
	    call printf("\nconstant bkgd:\t%.4f counts/sq. pixel\n")
	    	call pargd(bkgdvalue)
	    # add a header parameter for constant bkgd, if necessary
	    if( dotable == YES ){
	    	call tbhadr(tp, "bkgd", real(bkgdvalue))
		# write in source of bkgd error, if necessary
		if( doberr == YES )
		    call tbhadr(tp, "berr", real(bkgderr))
		else
		    call tbhadt(tp, "berr", "bkgd error not calculated")
	    }
	}

# ==========================================================================
#	If time normalization is required, get ratio of live times and
#	 factor it into constant normfactor
# ==========================================================================

	call cnt_norm(sim, bim, tp, normfactor, type, dotimenorm, dotable)

# ==========================================================================
#	Flush printout so far
# ==========================================================================

	call flush(STDOUT)

# ==========================================================================
# ==========================================================================

# ==========================================================================
#	Get raw photon counts and errors, by region, for source and bkgd
# ==========================================================================

	# -----------------------------------------------------------------
	# Get areas and raw counts of photons, for source and bkgd regions
	# -----------------------------------------------------------------
	# scan source mask to find min and max region numbers, and set 
	#  span of effective region numbers
	call rg_pmvallims(spm, smin, smax)
	sindices = smax - smin + 1

	# allocate, initialize, and fill source photon count and area arrays
	call salloc(scounts, sindices, TY_DOUBLE)
	call aclrd(Memd[scounts], sindices)
	call salloc(sarea, sindices, TY_DOUBLE)
	call aclrd(Memd[sarea], sindices)
	call mskcnts(smp, stype, Memd[scounts], Memd[sarea], smin, smax)

	# check that at least one source region has non-zero area
	call cnt_zeroarea("source", Memd[sarea], sindices)

	if( type != CONSTANT_BKGD ){
	    # scan bkgd mask to find min and max region numbers, and set 
	    #  span of effective region numbers
	    call rg_pmvallims(bpm, bmin, bmax)
	    bindices = bmax - bmin + 1

	    # allocate, initialize, & fill bkgd photon count & area arrays
	    call salloc(bcounts, bindices, TY_DOUBLE)
	    call aclrd(Memd[bcounts], bindices)
	    call salloc(barea, bindices, TY_DOUBLE)
	    call aclrd(Memd[barea], bindices)
	    call mskcnts(bmp, btype, Memd[bcounts], Memd[barea], bmin, bmax)

	    # check that at least one bkgd region has non-zero area
	    call cnt_zeroarea("bkgd", Memd[barea], bindices)
	}
	else
	    bindices = 0

	# ----------------------------------------------------------------
	# Display the areas and raw counts of photons, for source and bkgd
	#  regions;  write the bkgd data into the table
	# ----------------------------------------------------------------
	call cnt_rawdisp("SOURCE DATA", Memd[scounts], Memd[sarea], 
			 smin, sindices)
	if( type != CONSTANT_BKGD ){
	    call cnt_rawdisp("BKGD DATA", Memd[bcounts], Memd[barea], 
			     bmin, bindices)
	    # write the raw bkgd counts and area into the table
	    if( dotable == YES )
		call cnt_wrbkgd(tp, Memd[bcounts], Memd[barea], bindices)
	}

	# ----------------------------------------------------
	# Get source and bkgd error data, if they are provided
	# ----------------------------------------------------
	if( semp !=0 || bemp != 0 )
	    call salloc(djunk, sindices, TY_DOUBLE)

	if( semp !=0 ){
	    # allocate, initialize, & fill source photon count error array
	    call salloc(serrors, sindices, TY_DOUBLE)
	    call aclrd(Memd[serrors], sindices)
	    call aclrd(Memd[djunk], sindices)
	    call mskcnts(semp, IM_PIXTYPE(seim), Memd[serrors], Memd[djunk],
			 smin, smax)
	}
	else
	    serrors = 0

	if( bemp !=0 ){
	    # allocate, initialize, & fill bkgd photon count error array
	    call salloc(berrors, bindices, TY_DOUBLE)
	    call aclrd(Memd[berrors], bindices)
	    call aclrd(Memd[djunk], sindices)
	    call mskcnts(bemp, IM_PIXTYPE(beim), Memd[berrors], Memd[djunk],
			bmin, bmax)
	}
	else
	    berrors = 0

# ==========================================================================
#	Subtract background counts from source counts
# ==========================================================================

	# -------------------------------------------------------------
	# Allocate & initialize arrays for areas, background-subtracted 
	#  counts, and background-subtracted errors, in source regions
	# -------------------------------------------------------------
	call salloc(bscounts, sindices, TY_DOUBLE)
	call aclrd(Memd[bscounts], sindices)
	call salloc(bsarea, sindices, TY_DOUBLE)
	call aclrd(Memd[bsarea], sindices)
	call salloc(bserrors, sindices, TY_DOUBLE)
	call aclrd(Memd[bserrors], sindices)

	# ----------------------------------------------
	# Normalize bkgd counts and subtract from source
	# ----------------------------------------------
	# allocate and initialize buffers to receive the results of 
	#  subtracting area-normalized bkgd counts from source counts, 
	#  and the correspondingly adjusted source error data
	call salloc(bncounts, sindices, TY_DOUBLE)
	call aclrd(Memd[bncounts], sindices)
	call salloc(bnerrors, sindices, TY_DOUBLE)
	call aclrd(Memd[bnerrors], sindices)

	# normalize the background and subtract from source, and calculate 
	#  adjusted source error data
	call cnt_bkgdsub(type, matchbkgd, 
	    Memd[scounts], Memd[sarea], sindices,
	    Memd[bcounts], Memd[barea], bindices,
	    Memd[bscounts], Memd[bsarea], Memd[bserrors],
	    Memd[bncounts], Memd[bnerrors],
	    serrors, berrors, poisserr, 
	    bkgdvalue, bkgderr, normfactor, doberr, sdpp, bdpp)

# ==========================================================================
#	Using background-subtracted count and error data, calculate 
#	 brightness ratio and err/pix, for each source region
# ==========================================================================

	# allocate and initialize these two buffers
	call salloc(brightness, sindices, TY_DOUBLE)
	call aclrd(Memd[brightness], sindices)
	call salloc(errness, sindices, TY_DOUBLE)
	call aclrd(Memd[errness], sindices)

	# calculate brightness ratio and err/pix
	call cnt_brightness(Memd[bscounts], Memd[bserrors], Memd[bsarea],
		Memd[brightness], Memd[errness], sindices)

# ==========================================================================
#	Calculate radial profile(s)
# ==========================================================================

	call salloc(profile, sindices, TY_DOUBLE)
	call aclrd(Memd[profile], sindices)
	call cnt_profile(Memd[bscounts], Memd[profile], smin, sindices,
			 ONEREGNOTESPTR(srg_parsing), ANNPIEFLAGS(srg_parsing))

# ==========================================================================
# ==========================================================================

# ==========================================================================
#	Display all the results, and write them to the table file
# ==========================================================================

	call cnt_finaldisp(Memd[bscounts], Memd[bsarea], Memd[bserrors],
			Memd[bncounts],  Memd[bnerrors],
			Memd[brightness], Memd[errness],
			Memd[profile], ONEREGNOTESPTR(srg_parsing),
			smin, sindices, ANNPIEFLAGS(srg_parsing), doberr)

	if( dotable == YES )
	    call cnt_filltable(Memd[scounts], Memd[bcounts],
		Memd[bscounts], Memd[bsarea], Memd[bserrors],
		Memd[bncounts], Memd[bnerrors], Memd[brightness], 
		Memd[errness], Memd[profile],
		ONEREGNOTESPTR(srg_parsing), smin, sindices, 
		ANNPIEFLAGS(srg_parsing), doberr, tp, cp)

# ==========================================================================
# ==========================================================================

# ==========================================================================
#	Clean up
# ==========================================================================

	# ----------------------------------------------------------
	# Close MIO descriptor, mask, and image, for source and bkgd
	# ----------------------------------------------------------
	# close source MIO descriptor
	call mio_close(smp)
	# close source mask
	call pm_close(spm)
	# close source image
	call imunmap(sim)

	if( type != CONSTANT_BKGD ){
	    # close bkgd MIO descriptor
	    call mio_close(bmp)
	    # close bkgd mask
	    call pm_close(bpm)
	    # close bkgd image
	    call imunmap(bim)
	}

	# --------------------------------------------------------------
	# Close MIO descriptor and image file, for source error data and 
	#  bkgd error data
	# --------------------------------------------------------------
	# close the source error files, if necessary
	if( semp !=0 ){
	    # close MIO descriptor for source error data
	    call mio_close(semp)
	    # close image file containing source error data
	    call imunmap(seim)
	}

	# close the bkgd error files, if necessary
	if( bemp !=0 ){
	    # close MIO descriptor for bkgd error data
	    call mio_close(bemp)
	    # close image file containing bkgd error data
	    call imunmap(beim)
	}

	# -----------------------------------
	# Close the parser for source regions
	# -----------------------------------
	call rg_close_parser(srg_parsing)

	# ------------------------------
	# Close table file, if necessary
	# ------------------------------
	if( dotable == YES ){
	    call tbtclo(tp)
	    if (display >= 1) {
		call printf("Creating table output file: %s\n")
		call pargstr(Memc[table])
	    }
	    call finalname(Memc[xtable], Memc[table])
	}

	# ----------------------
	# Release dynamic memory
	# ----------------------
	call mfree(stitle, TY_CHAR)
	call mfree(btitle, TY_CHAR)
	call sfree(sp)
end
