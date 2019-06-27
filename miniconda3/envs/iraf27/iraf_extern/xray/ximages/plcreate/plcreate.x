#$Header: /home/pros/xray/ximages/plcreate/RCS/plcreate.x,v 11.0 1997/11/06 16:28:33 prosb Exp $
#$Log: plcreate.x,v $
#Revision 11.0  1997/11/06 16:28:33  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:28  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:26:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:07:24  prosb
#General Release 2.2
#
#Revision 5.2  93/05/19  03:53:35  dennis
#Put the dimensions of the mask, not of the image section at the time of
#creating it, in the mask header.
#
#Revision 5.1  93/04/27  00:12:53  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:26:58  prosb
#General Release 2.1
#
#Revision 4.1  92/08/07  17:54:26  dennis
#Correct buffer sizes for plname, region, tempname, imname
# (including new dependency on <regparse.h>);
#Replace check for "NONE" with call to ck_none().
#
#Revision 4.0  92/04/27  14:30:04  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:27  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:05  pros
#General Release 1.0
#
#
# PLCREATE -- create a PLIO mask file, inputting either a reference image
#		or 2 dimensions to specify the size of the mask
#

include	<plio.h>
include <plset.h>
include <pmset.h>

include <ext.h>
include <plhead.h>
include	<regparse.h>

# define max dimensions of the mask we create
define MAX_DIMS	2

procedure t_plcreate()

char	plname[SZ_PATHNAME]		# name of output PLIO file
char	imname[SZ_PATHNAME]		# name of input reference image file
char	region[SZ_REGINPUTLINE]		# region descriptor
char	tempname[SZ_PATHNAME]		# temp mask name
char	s[SZ_PLHEAD]			# plio header string
char	dmode[SZ_LINE]			# mode of plio display (zoom, etc.)
char	dummy[2]			# dummy for rg_ftype
bool	clobber				# clobber old mask

int	doimage				# flag we have a reference image
int	disp				# display mask
int	ncols				# columns to display
int	nrows				# rows to display

int	pmnaxes				# number of axes (ref. image)
long	pmaxlenl[PL_MAXDIM]		# ref. image axis lengths
int	pmdepth				# mask depth, in bits
int	pmaxlen[2]			# ref. image axis lengths

int	axislen[MAX_DIMS+1]		# axis lengths + 1 as a buffer
int	ndims				# number of dims specified by user

int	nchar				# return from ctoi
int	ip				# ctoi index
int	x1, y1, x2, y2			# rg_pldisp parameters
pointer	im				# reference image pointer
pointer	parsing				# pointer to parsing control structure
bool	bjunk				# unneeded rtn f/ parser request setup

bool    ck_none()               # check for "NONE" or abbrev, u.c. or l.c.
int	clgeti()			# get int param
int	imaccess()			# image file existence
int	ctoi()				# char to int
int	stridx()			# string index
bool	clgetb()			# get boolean
bool	streq()				# string compare
int	rg_ftype()			# rg file type: plio or region
pointer	rg_open_parser()		# prepare parser for requests
bool	rg_openmask_req()		# set up request for opened
					#  region mask from parser
bool	rg_expdesc_req()		# set up request for expanded
					#  region descriptor from parser
pointer	immap()				# open an image

begin
	# get the parameters
	call clgstr ("region", region, SZ_REGINPUTLINE)
	call clgstr ("image", imname, SZ_PATHNAME)
	call clgstr ("mask", plname, SZ_PATHNAME)
	disp = clgeti ("display")
	if( disp >1 ){
	    call clgstr("disp_mode", dmode, SZ_LINE)
	    ncols = clgeti("ncols")
	    nrows = clgeti("nrows")
	    call get_plims(dmode, x1, x2, y1, y2)
	}
	clobber = clgetb ("clobber")

	# make sure the user did not input a plio file
	if( rg_ftype(region, dummy, 0) ==2 )
	    call error(1, "can't make a pl mask using only a pl mask as input")

	# determine if we have a reference image or dimensions
	if( (imaccess(imname, 0) == YES) || (stridx("[", imname) >0) ){
	    doimage = YES
	    # allow mask name to default to image
	    call rootname(imname, plname, EXT_PL, SZ_PATHNAME)
	}
	else{
	    # pick out the dimensions from the string
	    ndims = 1
	    ip = 1
	    while( TRUE ){
		nchar = ctoi(imname, ip, axislen[ndims])
		if( nchar ==0 ) break
		if( ndims > MAX_DIMS )
		    call error(1, "too many pl dimensions specified")
		ndims = ndims + 1
	    }
	    doimage = NO
	}
	# get actual number of dims
	ndims = ndims - 1
	
	# gotta have dimensions
	if( ndims == 0 )
	    call error(1, "requires file name or 2 dimensions")
	# help the user if she only put in one dim
	else if( ndims == 1 )
	    axislen[2] = axislen[1]

	# must have a valid plname
	if( streq(plname, "") )
	    call error(1, "requires a mask file name")

	# must have a valid plname
	if( ck_none(plname) )
	    call error(1, "requires a mask file name")

	# add the extension, if necessary
	call addextname(plname, EXT_PL, SZ_PATHNAME)

	# check for already-existing file
	call clobbername(plname, tempname, clobber, SZ_PATHNAME)

	# set up parser request for opened mask and expanded descriptor
	parsing = rg_open_parser()
	bjunk = rg_openmask_req(parsing)
	bjunk = rg_expdesc_req(parsing)

	# create the mask
	if( doimage == YES ){
	    # open the reference image
	    im = immap(imname, READ_ONLY, 0)
	    # create the PMIO file
	    call rg_imcreate(parsing, region, im)
	    # get the dimensions of the mask
	    call pl_gsize(MASKPTR(parsing), pmnaxes, pmaxlenl, pmdepth)
	    pmaxlen[1] = pmaxlenl[1]
	    pmaxlen[2] = pmaxlenl[2]
	    # create the mask header
	    call enc_plhead(plname, "region", imname, pmaxlen[1], pmaxlen[2], 
			0.0D0, EXPDESCPTR(parsing), s, SZ_PLHEAD)
	    # save mask in a file
	    call pm_savef(MASKPTR(parsing), tempname, s, 0)
	    # close the reference image
	    call imunmap(im)
	    # display as necessary
	    if( disp >0 )
	        call disp_plhead(s)
	    if( disp >1 )
		call rg_pldisp(MASKPTR(parsing), ncols, nrows, x1, x2, y1, y2)
	}
	else{
	    # create the PLIO file
	    call rg_plcreate(parsing, region, axislen)
	    # create the mask header
	    call enc_plhead(plname, "region", "",
			axislen[1], axislen[2],
			0.0D0, EXPDESCPTR(parsing), s, SZ_PLHEAD)
	    # save mask in a file
	    call pl_savef(MASKPTR(parsing), tempname, s, 0)
	    # display as necessary
	    if( disp >0 )
	        call disp_plhead(s)
	    if( disp >1 )
		call rg_pldisp(MASKPTR(parsing), ncols, nrows, x1, x2, y1, y2)
	}

	# close the mask file and the parser
	call rg_close_parser(parsing)

	# rename mask file, if necessary
	if( disp >= 1){
 	    call printf("Creating pl mask output file: %s\n")
                call pargstr(plname)
	}
	call finalname(tempname, plname)
end
