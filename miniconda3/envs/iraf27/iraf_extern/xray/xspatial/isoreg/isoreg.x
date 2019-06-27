#$Header: /home/pros/xray/xspatial/isoreg/RCS/isoreg.x,v 11.0 1997/11/06 16:33:06 prosb Exp $
#$Log: isoreg.x,v $
#Revision 11.0  1997/11/06 16:33:06  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:47  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:42  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:26  prosb
#General Release 2.2
#
#Revision 5.3  93/05/21  08:48:11  janet
#jd - Added check and error when User inputs image with a section.
#
#Revision 5.2  93/05/20  18:12:30  dennis
#Changed "field" to "field; -field", and set PM_MAPXY(MASKPTR(parsing)) 
#back to YES after return from rg_imcreate(), in preparation for enabling 
#specifying section on the input image.
#
#Revision 5.1  93/04/27  00:21:31  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:34:57  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:43:20  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/02/14  09:49:49  janet
#changed output pl mask name in param file and code to out_mask.
#
#Revision 1.1  92/02/13  12:24:03  janet
#Initial revision
#
#
# Module:       ISOREG
# Project:      PROS -- ROSAT RSDC
# Purpose:
# External:
# Local:        all others
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD    initial version <when>

include	<regparse.h>
include	<plio.h>
include <plhead.h>
include <pmset.h>
include <imhdr.h>
include <error.h>
include <ext.h>

#------------------------------------------------------------------------
# ISOREG
#------------------------------------------------------------------------

procedure t_isoreg()

bool    clobber                         # clobber old filename

pointer ilims				# input limits
pointer in_image                        # input image filename
pointer iv                              # input image vector
pointer out_image                       # output image filename
pointer ov                              # output image vector
pointer tempname                        # temp image filename

int     display				# display level
int     i                               # loop counters
int     nlevs 				# number of contour levels
int     xlen, ylen			# image section x/y length

pointer clevels				# contour levels
pointer ibuf                            # input buffer pointer
pointer in                              # input image pointer
pointer obuf                            # input buffer pointer
pointer sp                              # memory stack pointer

int	naxes				# number of axes of region mask
long	axislenl[PL_MAXDIM]		# region mask axis lengths
int	depth				# region mask depth, in bits
int	axislen[2]			# region mask axis lengths
int     cl_index, cl_size       	# l: imparse pointer

pointer	parsing				# pointer to parsing control structure
bool	bjunk				# unneeded rtn f/ parser request setup
pointer title				# title of data
pointer imfilt
pointer imgroot
pointer isection

bool    ck_none()			# check for 'none' filename spec
bool    clgetb()                        # get parm bool function
bool    streq()                         # string equal compare function

int     clgeti()			# get an integer from the cl

pointer immap()                         # open image function
pointer imgnlr()			# image get next line
pointer	rg_open_parser()		# prepare parser for requests
bool	rg_openmask_req()		# set up request for opened
					#  region mask from parser
bool	rg_expdesc_req()		# set up request for expanded 

int     strlen()
					#  region descriptor from parser

begin

#   Allocate buffer space
        call smark(sp)
        call salloc (in_image, SZ_PATHNAME, TY_CHAR)
        call salloc (out_image, SZ_PATHNAME, TY_CHAR)
        call salloc (tempname, SZ_PATHNAME, TY_CHAR)
	call salloc (title, SZ_PLHEAD, TY_CHAR)
        call salloc (clevels, 100, TY_CHAR)
        call salloc (ilims, 100, TY_REAL)
        call salloc (iv, IM_MAXDIM, TY_LONG)
        call salloc (ov, PL_MAXDIM, TY_LONG)

        call salloc (imfilt, SZ_PATHNAME, TY_CHAR)
        call salloc (imgroot, SZ_PATHNAME, TY_CHAR)
        call salloc (isection, SZ_LINE, TY_CHAR)

#   Get Input Image name and check validity
        call clgstr ("in_image", Memc[in_image], SZ_PATHNAME)
        if ( (ck_none (Memc[in_image])) || (streq ("", Memc[in_image])) ) {
           call error(1, "requires image file as input")
        }

        call imparse (Memc[in_image], Memc[imgroot], SZ_PATHNAME,
            Memc[imfilt], SZ_LINE, Memc[isection], SZ_LINE,
            cl_index, cl_size)

        if ( strlen(Memc[isection]) > 0 ) {
           call printf ("        -- Image Sections NOT Accepted --\n")
           call flush(STDOUT)
           call error (1,"Use Imcopy on your section before running Isoreg")
        }

#   Open the Input image
        in  = immap (Memc[in_image], READ_ONLY, 0)

#   Get Output Image name and check validity
        call clgstr ("out_mask", Memc[out_image], SZ_PATHNAME)
        call rootname (Memc[in_image],Memc[out_image], EXT_ISO, SZ_PATHNAME)
        if ( (ck_none (Memc[out_image])) || ( streq("", Memc[out_image])) ) {
           call error(1, "Output filename missing")
        }
        clobber = clgetb ("clobber")
        call clobbername (Memc[out_image], Memc[tempname], clobber, SZ_PATHNAME)

        display = clgeti ("display")

#   Get Intensity level inputs
        call clgstr ("levels", Memc[clevels], SZ_PATHNAME)
	call get_intensity_regions(Memc[clevels], display, nlevs, Memr[ilims])


#   Set up request to parse the region descriptor ("field"), create output 
#   mask, and return the "expanded" descriptor
	parsing = rg_open_parser()
	bjunk = rg_openmask_req(parsing)
	bjunk = rg_expdesc_req(parsing)

#   Open output image and copy input image header
	call rg_imcreate(parsing, "field; -field", in)

#   Set output mask to receive section-relative coordinates
	PM_MAPXY(MASKPTR(parsing)) = YES

#   Initialize position vectors to line 1, col 1, band 1, ...
        call amovkl (long(1), Meml[iv], IM_MAXDIM)
        call amovkl (long(1), Meml[ov], PL_MAXDIM)
        xlen = IM_LEN(in,1)
        ylen = IM_LEN(in,2)

        call salloc (obuf, xlen, TY_INT)

#   Loop over each row in image 
        for (i=1; i<=ylen; i=i+1) {

#   Read the next line
           if (imgnlr (in, ibuf, Meml[iv]) != EOF) {

#   Process the line by replacing pixel data with region mask numbers
	      call assign_region (Memr[ibuf], i, xlen, nlevs, Memr[ilims], 
				  Memi[obuf], display)

#   write the line back out 
              Meml[ov+2-1] = i
	      call pmplpi (MASKPTR(parsing), Meml[ov], Memi[obuf], 0, xlen, 0)

           }
        }

#   encode the plheader with all the right stuff - mask_name, mask_type,
#   reference image, xdimension, ydimension, scale, region
	call pl_gsize(MASKPTR(parsing), naxes, axislenl, depth)
	axislen[1] = axislenl[1]
	axislen[2] = axislenl[2]
	call enc_plhead (Memc[out_image], "isoreg", Memc[in_image],
                         axislen[1], axislen[2], 1, EXPDESCPTR(parsing), 
                         Memc[title], SZ_PLHEAD)
        call pm_savef(MASKPTR(parsing),Memc[tempname],Memc[title],0)

#   Close the files and the parser
        call imunmap (in)
	call rg_close_parser(parsing)

#   Name the output file
        call finalname(Memc[tempname], Memc[out_image])
        if ( display > 0 ) {
           call printf ("Writing to Output file:  %s\n")
             call pargstr (Memc[out_image])
	}

        call sfree (sp)

end
