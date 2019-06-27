#$Header: /home/pros/xray/xspatial/immd/RCS/mdnewcopy.x,v 11.2 2000/01/04 22:28:52 prosb Exp $
#$Log: mdnewcopy.x,v $
#Revision 11.2  2000/01/04 22:28:52  prosb
# copy from pros_2.5 (or pros_2.5_p1)
#
#Revision 9.0  1995/11/16  18:52:35  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:22  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:03  prosb
#General Release 2.2
#
#Revision 5.1  93/04/07  13:37:00  orszak
#jso - changes to add lorentzian model.
#
#Revision 5.0  92/10/29  21:34:37  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:31  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:06  pros
#General Release 1.0
#
#
# Module:	MDNEWCOPY.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	add new task history to output image file
# External:	smo_map, smerr_map, mod_hist, md_getascii, md_newcopy
# Local:	
# Description:	Package the history string and call put_imhist
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	27 March 1989	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include <imhdr.h>
include "mdset.h"

#
# Function:	smo_map
# Purpose:	Open file for writing smoothed image and prepare header history
# Parameters:	See argument declarations
# Returns:	pointer to image opened for writing
# Uses:		put_imhist()
# Uses:		md_getascii(), md_newcopy() below
# Method:	Open image file with imtname, copying header info from iminame.
#		Add one history line using put_imhist().
# Notes:	blocking is noted if it was used
#
pointer procedure smo_map ( iminame, imtname, imoname, block, mdfunc )

char    iminame[ARB]	# i: name of input image
char	imtname[ARB]	# i: name of temp file (later moved to imoname)
char    imoname[ARB]	# i: name of output image
int     block		# i: blocking factor for compression
pointer	mdfunc		# i: model parameter structure

pointer outim		# o: open handle to output image (dest) 
pointer	hist
pointer model
pointer	sp
pointer	md_newcopy()

begin
	# save stack pointer and allocate two string buffers
	call smark(sp)
	call salloc(hist, SZ_LINE, TY_CHAR)
	call salloc(model, SZ_LINE, TY_CHAR)
	# fill model string buffer with summary of smoothing model
	call md_getascii (mdfunc, Memc[model], SZ_LINE)
	# package history line
	if( block > 1 )
	{
	    call sprintf(Memc[hist], SZ_LINE, "%s (block=%d, %s) -> %s")
	     call pargstr(iminame)
	     call pargi(block)
	     call pargstr(Memc[model])
	     call pargstr(imoname)
	}
	else
	{
	    call sprintf(Memc[hist], SZ_LINE, "%s (%s) -> %s")
	     call pargstr(iminame)
	     call pargstr(Memc[model])
	     call pargstr(imoname)
	}
	# open and add history line to header of output image file
	outim = md_newcopy (iminame, imtname)
	call put_imhistory (outim, "imsmooth", Memc[hist], "")
	call sfree(sp)
	return( outim )
end

#
# Function:	smerr_map
# Purpose:	Open file for writing smooth errors and prepare header history
# Parameters:	See argument declarations
# Returns:	pointer to image opened for writing
# Uses:		put_imhist()
# Uses:		md_getascii(), md_newcopy() below
# Method:	Open image file with imtname, copying header info from iminame.
#		Add one history line using put_imhist().
# Notes:	blocking is noted if it was used
# Notes:	iminame is either error file name or data file name
#
pointer procedure smerr_map ( iminame, imtname, imoname, efile, block, mdfunc )

char    iminame[ARB]	# i: name of input image (error if given, else data)
char	imtname[ARB]	# i: name of temp file (later moved to imoname)
char    imoname[ARB]	# i: name of output image
int	efile		# i: flag that error read from an error file
int     block		# i: blocking factor for compression
pointer	mdfunc		# i: model parameter structure

pointer outim		# o: open handle to output image (dest) 
pointer	hist
pointer model
pointer	sp
pointer	md_newcopy()

begin
	# save stack pointer and allocate two string buffers
	call smark(sp)
	call salloc(hist, SZ_LINE, TY_CHAR)
	call salloc(model, SZ_LINE, TY_CHAR)
	# fill model string buffer with summary of smoothing model
	call md_getascii (mdfunc, Memc[model], SZ_LINE)
	# package history line
	if( block > 1 )
	{
	    if( efile == YES )
		call sprintf(Memc[hist], SZ_LINE, "%s (block=%d, %s) -> %s")
	    else
		call sprintf(Memc[hist], SZ_LINE,
			     "%s (block=%d, sqrt, %s) -> %s")
	     call pargstr(iminame)
	     call pargi(block)
	     call pargstr(Memc[model])
	     call pargstr(imoname)
	}
	else
	{
	    if( efile == YES )
		call sprintf(Memc[hist], SZ_LINE, "%s (%s) -> %s")
	    else
		call sprintf(Memc[hist], SZ_LINE, "%s (sqrt, %s) -> %s")
	     call pargstr(iminame)
	     call pargstr(Memc[model])
	     call pargstr(imoname)
	}
	# open and add history line to header of output image file
	outim = md_newcopy (iminame, imtname)
	call put_imhistory (outim, "imsmooth errors", Memc[hist], "")
	call sfree(sp)
	return( outim )
end

#
# Function:	mod_hist
# Purpose:	Add history entry for modeled image
# Parameters:	See argument declarations
# Returns:	
# Uses:		put_imhist, md_getascii() below
# Pre-state:	output image open with imnewcopy()
# Post-state:	one history line is added to header of outim
# Method:	
#
procedure mod_hist ( outim, iminame, imoname, infile, mdfunc )

pointer outim		# i: open handle to output image (dest) 
char	iminame[ARB]	# i: name of input image
char	imoname[ARB]	# i: name of output image
int	infile		# i: flag whether input image given
pointer	mdfunc		# i: model parameter structure

pointer	hist
pointer model
pointer	sp

begin
	# save stack pointer and allocate two string buffers
	call smark(sp)
	call salloc(hist, SZ_LINE, TY_CHAR)
	call salloc(model, SZ_LINE, TY_CHAR)
	# fill model string buffer with summary of smoothing model
	call md_getascii (mdfunc, Memc[model], SZ_LINE)
	# package history line
	if( infile == YES )
	{
	    call sprintf(Memc[hist], SZ_LINE, "%s (%s) -> %s")
	     call pargstr(iminame)
	     call pargstr(Memc[model])
	     call pargstr(imoname)
	}
	else
	{
	    call sprintf(Memc[hist], SZ_LINE, "(%s) -> %s")
	     call pargstr(Memc[model])
	     call pargstr(imoname)
	}
	# open and add history line to header of output image file
	call put_imhistory (outim, "immodel", Memc[hist], "")
	call sfree(sp)
end

#
# Function:	md_getascii
# Purpose:	Prepare a string summarizing model
# Parameters:	See argument declarations
# Returns:	
# Uses:
# Pre-state:	string buffer is given
# Post-state:	test placed in string buffer (not appended)
# Method:	
#
procedure md_getascii ( mdfunc, buf, len )

pointer mdfunc		# i: structure for model parameters
char buf[ARB]		# i: char buffer to recieve summary
int len			# i: length of buf buffer

begin
	switch( MD_FUNCTION(mdfunc) ) {
	case MDBOXCAR:
	    call sprintf (buf, len, "boxcar %.3f %.3f")
	     call pargr (MD_WIDTH(mdfunc))
	     call pargr (MD_HEIGHT(mdfunc))
	case MDEXPO:
	    call sprintf (buf, len, "expo %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	case MDFILE:
	    call sprintf (buf, len, "file %s")
	     call pargstr (MD_FILENAME(mdfunc))
	case MDFUNC:
	    call sprintf (buf, len, "my own %.3f %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	     call pargr (MD_POWER(mdfunc))
	case MDGAUSS:
	    call sprintf (buf, len, "gauss %.3f")
	     call pargr (MD_SIGMA(mdfunc))
	case MDHIPASS:
	    call sprintf (buf, len, "hipass %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	case MDIMPULS:
	    call sprintf (buf, len, "impulse %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	case MDKFILE:
	    call sprintf (buf, len, "kfile %s")
	     call pargstr (MD_FILENAME(mdfunc))
	case MDKFUNC:
	    call sprintf (buf, len, "my own k %.3f %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	     call pargr (MD_POWER(mdfunc))
	case MDKING:
	    call sprintf (buf, len, "king %.3f %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	     call pargr (MD_POWER(mdfunc))
	case MDLOPASS:
	    call sprintf (buf, len, "lopass %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	case MDPOWER:
	    call sprintf (buf, len, "power %.3f %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	     call pargr (MD_POWER(mdfunc))
	case MDTOPHAT:
	    call sprintf (buf, len, "tophat %.3f")
	     call pargr (MD_RADIUS(mdfunc))
	case MDLORENT:
	    call sprintf (buf, len, "lorentz %.3f")
	     call pargr (MD_SIGMA(mdfunc))
	default:
	    call sprintf (buf, len, "Unknown function")
	}
end


#
# Function:	md_newcopy
# Purpose:	Open a new image with header and attributes from existing one
# Parameters:	See argument declarations
# Returns:	im handle from immap
# Uses:		immap(), error(), imaccf(), imputi()
# Post-state:	new image opened with old header copied over.
# Exceptions:	blocking cannot result in compression to less than 1 pixel
# Method:	Open the new image with immap(NEW_COPY).  Set axlen1 and
#		axlen2 if not yet set.  IM_NDIM and IM_LEN must be set later
#		by the application.
#
pointer procedure md_newcopy ( inname, outname )

char    inname[ARB]	# i: name of original image
char    outname[ARB]	# i: name of output image

pointer outim		# o: open handle to new image
pointer inim		# l: open handle to original image
pointer sp		# l: stack pointer
pointer axis		# l: string buffer for "axlen1"
int	i		# l: loop counter

int     imaccf()	# check access to header card
pointer immap()		# open image function

begin
	call smark(sp)
	inim = immap(inname, READ_ONLY, 0)
	# open the output image with NEW_COPY to copy header info
	iferr( outim = immap (outname, NEW_COPY, inim) )
	    call error(0, "can't open output image file")
	# Set origin axis lengths to dim of input image if doesn't yet exist
	call salloc (axis, 10, TY_CHAR)
	do i = 1, IM_NDIM(inim)
	{
	    call sprintf(Memc[axis], 10, "axlen%1d")
	     call pargi(i)
	    if( imaccf(outim, Memc[axis]) == NO )
	    {
		call imaddf (outim, Memc[axis], "i")
		call imputi (outim, Memc[axis], IM_LEN(inim,i)) 
	    }
	}
	call imunmap(inim)
	call sfree(sp)
	return( outim )
end
