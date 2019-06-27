#$Header: /home/pros/xray/xspatial/immodel/RCS/immodel.x,v 11.0 1997/11/06 16:30:20 prosb Exp $
#$Log: immodel.x,v $
#Revision 11.0  1997/11/06 16:30:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:09  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:26  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:40  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:15:06  mo
#MC	12/22/93	Give immodel it's own EXT name
#
#Revision 6.0  93/05/24  16:11:55  prosb
#General Release 2.2
#
#Revision 5.1  93/05/06  11:17:05  orszak
#jso - added a line feed.
#
#Revision 5.0  92/10/29  21:29:28  prosb
#General Release 2.1
#
#Revision 4.1  92/07/07  09:10:30  mo
#MC	7/2/92		Upgrade all filename lengths to SZ_PATHNAME
#
#Revision 4.0  92/04/27  17:30:36  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:02  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:01  pros
#General Release 1.0
#
#
# Module:	IMMODEL.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	create synthetic data
# External:	t_model
# Local:
# Description:  Create synthetic data by applying a model profile at given
#		source coordinates.  The data is real.  Model data can be
#		added to an existing file or start with an empty new file.
#		The model profile can be chosen from a menu of standard
#		functions, read from an IRAF file, or applied by a call to
#		a stub where the user may link in his own subroutine.
#		All models are normalized and then applied with a scaling
#		parameter.  The model can be applied multiply to make up an
#		image with multiple sources, using center coordinates and
#		scaling factor for each source.  An alternative approach
#		would be to model all sources as impulses and then smooth
#		them by the profile model (i.e. for extended sources).
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	1 December 1988	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include	<imhdr.h>
include <error.h>

include <ext.h>

# define max dimensions of the mask we create
define MAX_DIMS	2

#
# Function:		t_model
# Purpose:		add synthetic data to an image file (new or existing)
# Parameters:		See argument declarations
# Returns:	
# Uses:		
# Pre-condition:	optional existing image file
# Post-condition:	new image file with modeled data added
# Exceptions:
# Method:	< optional >
# Notes:	
#
procedure t_model()

real	modnorm			# l: normalization factor
real	modscale		# i: scale factor for all sources
pointer	xcen, ycen		# i: coordinates of source centers
pointer val			# i: magnitudes of sources
pointer modbuf			# l: data and smoothing buffers
pointer sp			# l: stack pointer
pointer	inim			# l: input image pointer
pointer	outim			# l: ouput image pointer
pointer modfunc			# l: structure for smoothing parameters
pointer	iminame			# i: buf for name of input image or dim
pointer	imoname			# i: buf for name of output image file
pointer	tempname		# l: temporary output image file name
pointer	namebuf			# i: buf for function and source file name
int	i			# l: loop counter
int	ip			# l: ctoi index
int	sources			# l: number of sources
int	bufsz			# l: size of data buffer
int	v[IM_MAXDIM]		# l: image read starting indeces
int	axlen[IM_MAXDIM]	# l: image dimensions
int	modcode			# l: code of smoothing function
int	infile			# l: flag that input file was given
int 	junk			# l: return from fnextn, fd for open check
int     display                 # i: level of status message and debug
bool	clobber			# i: clobber old output file
bool	donorm			# i: normalize model

real	md_norm()		# get normalization scale factor
int	pix_parse()		# get arrays of source params
int	md_parse()		# return smoothing function code
pointer	md_alloc()		# return smoothing function structure
pointer	md_newcopy()		# open an image with old header stuff
int	md_getparams()		# get function parameters from cl
int	ctoi()			# convert string to int
int	open()			# open a binary file
int	imaccess()		# test for existance of file name
int	fnextn()		# get file name extension
pointer	immap()			# open an image
bool	streq()			# string compare
bool	strne()			# string compare (not equal)
real	clgetr()		# get real param from cl or .par file
bool	clgetb()		# get boolean parameter
int     clgeti()                # get int param from cl or param file

begin
	call smark(sp)

  # allocate string buffers
	call salloc(iminame, SZ_PATHNAME, TY_CHAR)
	call salloc(imoname, SZ_PATHNAME, TY_CHAR)
	call salloc(tempname, SZ_PATHNAME, TY_CHAR)
	call salloc(namebuf, SZ_PATHNAME, TY_CHAR)

  # get the input file and or the image dimensions

	call clgstr ("image", Memc[iminame], SZ_PATHNAME)
	# determine if we have a reference image or dimensions
	if( imaccess(Memc[iminame], 0) == YES )
	{
	    inim = immap(Memc[iminame], READ_ONLY, 0)
	    # get image's dimensions
	    axlen[1] = IM_LEN(inim,1)
	    axlen[2] = IM_LEN(inim,2)
	    infile = YES
	}
	else
	{
	    # pick out the dimensions from the string
	    ip = 1
	    if( ctoi(Memc[iminame], ip, axlen[1]) == 0 )
		call error(1, "requires input image name or 2 ints")
	    if( ctoi(Memc[iminame], ip, axlen[2]) == 0 )
		call error(1, "cannot read image height")
	    infile = NO
	}
	bufsz = axlen[1] * axlen[2]

	call clgstr ("outname", Memc[imoname], SZ_PATHNAME)
	call rootname(Memc[iminame],Memc[imoname], EXT_MDL, SZ_PATHNAME)
	if( streq(Memc[imoname], "") )
	    call error(1, "requires output image name")
	junk = fnextn (Memc[imoname], Memc[tempname], SZ_PATHNAME)
	if( strne(Memc[tempname], "imh") )
	{
	    call error(1, "output image must be of type '.imh'")
	}
	clobber = clgetb ("clobber")
	display = clgeti("display")
	call clobbername (Memc[imoname], Memc[tempname], clobber, SZ_PATHNAME)
	# check for write permission
	junk = open(Memc[tempname], NEW_FILE, BINARY_FILE)
	if( junk == 0 )
	{
	    call error(1, "Write access denied for output image")
	}
	call close (junk)
	call delete (Memc[tempname])

  # get the model parameters

	call clgstr ("function", Memc[namebuf], SZ_PATHNAME)
	modcode = md_parse (Memc[namebuf])
	if( modcode == 0 )
	    call error (1, "Unknown function type")
	modfunc = md_alloc (modcode)
	if( md_getparams(modfunc) != 1 )
	    call error (1, "Unacceptable function parameter")
	donorm = clgetb ("normalize")
	modscale = clgetr ("scale")

  # get source parameters

	call clgstr ("sources", Memc[namebuf], SZ_PATHNAME)
	sources = pix_parse (Memc[namebuf], xcen, ycen, val, 0)
	if( sources <= 0 )
	{
	    call printf( "No sources given\n" )
	    return
	}

  # determine model normalization

	if( donorm )
	{
	    call printf ("\n	computing model normalization\n")
	    call flush (STDOUT)
	    modnorm = md_norm (axlen[1], axlen[2], modfunc)
	    modscale = modnorm * modscale
	}

  # allocate model space an read in input if any

	# allocate data model buffer
	call salloc (modbuf, bufsz, TY_REAL)
	if( infile == YES )
	{
	    call printf ("	reading data file\n")
	    call flush (STDOUT)
	    # read in the image
	    call amovki (1, v, IM_MAXDIM)
	    # read in the data as complex pairs
	    call read_im_real (inim, Memr[modbuf], v, axlen, axlen[1], 1, 0)
	    call imunmap(inim)
	}
	else
	    call aclrr (Memr[modbuf], bufsz)

  # make the model data

	call printf("	adding model data\n")
	call flush(STDOUT)
	do i = 0, sources - 1
	{
	    call md_place (modfunc, Memr[xcen+i], Memr[ycen+i],
			   Memr[val+i] * modscale)
	    # put model in buffer as real values
	    call md_apply (Memr[modbuf], axlen[1], axlen[2], modfunc, 0, 0)
	    # indicate progress by dots after above message
	    call printf (".")
	    call flush (STDOUT)
	}
	# free the parameter space
	call mfree(xcen, TY_REAL)
	call mfree(ycen, TY_REAL)
	call mfree(val, TY_REAL)

  # write the model to file

	if( infile == YES )
	    outim = md_newcopy (Memc[iminame], Memc[tempname])
	else
	    outim = immap(Memc[tempname], NEW_IMAGE, 0)
	call mod_hist (outim, Memc[iminame], Memc[imoname], infile, modfunc)
	call mfree(modfunc, TY_STRUCT)
	call put_im_real (outim, Memr[modbuf], axlen, axlen, 0)
	call imunmap(outim)
	if ( display >= 1)
	{
	 # write out image (put cr after dots from previous message)
		call printf ("\n        writing image to: %s\n")
		call pargstr (Memc[imoname])
		call flush(STDOUT)
	}
	call finalname (Memc[tempname], Memc[imoname])
	call sfree(sp)
end
