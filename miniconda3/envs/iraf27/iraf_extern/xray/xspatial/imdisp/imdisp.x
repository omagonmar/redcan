#$Header: /home/pros/xray/xspatial/imdisp/RCS/imdisp.x,v 11.0 1997/11/06 16:30:28 prosb Exp $
#$Log: imdisp.x,v $
#Revision 11.0  1997/11/06 16:30:28  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:26  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:52  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:30:03  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:15:39  mo
#MC	12/22/93	Fix YES/TRUE NO/FALSE type mismatch
#
#Revision 6.0  93/05/24  16:12:22  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  03:57:42  dennis
#Expanded regname buffer to SZ_LINE chars.
#
#Revision 5.1  93/04/27  00:19:18  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:29:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:36:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:27:32  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:12:50  pros
#General Release 1.0
#
# Module:       IMDISP - read data from an image into an array and display it
# Project:      PROS -- ROSAT RSDC
# Purpose:      read data from an image into an array and display it
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>    
#               {1} MC  -- Updated the include files -- 2/91
#               {n} <who> -- <does what> -- <when>
#

include <imhdr.h>
include <pmset.h>

include <ext.h>

procedure t_imdisp()

char	imname[SZ_FNAME]	# image name
char	regname[SZ_LINE]	# region specifier 
char	expname[SZ_FNAME]	# exposure mask
char	table[SZ_FNAME]		# table file
char	temp[SZ_FNAME]		# temp file name for table
int	xdim, ydim		# dimensionality of image
int	nrows, ncols		# rows and cols to display on scr
int	type			# type of data
real	thresh			# exposure threshold
real	scale			# data scale factor
real	bias			# data bias
bool	header			# display header?
bool	dotable			# create a table?
bool	clobber			# clobber old table?
bool	flip			# flip display?

pointer	buf			# buffer pointer
pointer	im			# image handle
pointer	pm			# pixel list handle (exposure-filtered region 
				#					mask)
pointer	mp			# mask handle
pointer	tp			# table pointer
pointer	cp			# column pointers
pointer	title			# (exposure-filtered region) mask title
pointer	imhead			# header pointer
pointer	sp			# stack pointer

int	is_imhead()		# check for qpoe image header
int	clgeti()		# get int param
real	clgetr()		# get real param
bool	strne()			# string compare
bool	streq()			# string compare
bool	clgetb()		# get boolean parameter
pointer	immap()			# open an image
pointer	msk_imopen()		# open a region and/or exposure mask
pointer	mio_openo()		# open a pixel mask for MIO

begin
	# mark the stack
	call smark(sp)

	# init some variables
	title = 0

	# get image name, region descriptor, and output mask name
	call clgstr("image", imname, SZ_FNAME)
	call clgstr("region", regname, SZ_LINE)
	call clgstr("exposure", expname, SZ_FNAME)
	# see if we are applying exposure
	call rootname(imname, expname, EXT_EXPOSURE, SZ_FNAME)
	if( strne(expname, "NONE") ){
	    thresh = clgetr("expthresh")
	    if( thresh < 0.0 )
		call error(1, "exposure threshold must be >=0")
	}
	else
	    thresh = -1.0
	# get scale and bias factors
	scale = clgetr("scale")
	bias = clgetr("bias")
	# get the number of rows and cols the user wants displayed
	ncols = clgeti("ncols")
	nrows = clgeti("nrows")
	# see if we flip the display and table
	flip = clgetb("flip") 

	# see if the user wants to display the header
	header = clgetb("disp_header")
	# get the table name
	call clgstr("table", table, SZ_FNAME)
	# see if we are making a table file
	call rootname(imname, table, EXT_IMDISP, SZ_FNAME)
	if( streq("NONE", table) )
		dotable = FALSE
	else{
		dotable = TRUE
		clobber = clgetb ("clobber")
		call clobbername(table, temp, clobber, SZ_FNAME)
	}

	# open the image
	im = immap(imname, READ_ONLY, 0)
	# open the region and/or exposure
	pm = msk_imopen(NULL, regname, expname, thresh, im, title)
	# open the final mask for mio I/O
	mp = mio_openo(pm, im)

	# get dimensionality and make sure we have a 2D buffer
	if( IM_NDIM(im) <= 2 ){
	    xdim = IM_LEN(im, 1)
	    ydim = IM_LEN(im, 2)
	    type = IM_PIXTYPE(im)
	}
	else
	    call error(1, "image dimensions must be <= 2")	

	# make sure that the columns and rows are >= xdim, ydim
	if( ncols > xdim )
	    ncols = xdim
	if( nrows > ydim )
	    nrows = ydim

	# display the image name and the regions
	call msk_disp("", imname, Memc[title])

	# display the header, if possible (and necessary)
	if( header ){
	    # look for an X-ray header
	    if( is_imhead(im) == YES ){
		call get_imhead(im, imhead)
		call disp_imhead(imhead)
		call mfree(imhead, TY_STRUCT)
	    }
	    else
		call printf("\nNo X-ray header available\n\n")
	}

	# display the block factor, etc. we will use
	call printf("\nblocking factors (x,y):\t%d %d\n")
	call pargi(xdim/ncols)
	call pargi(ydim/nrows)
	call printf("scale factor:\t %.2f\n")
	call pargr(scale)
	call printf("bias factor:\t %.2f\n")
	call pargr(bias)
#	if( flip )
#	    call printf("display is flipped\n")
#	else
#	    call printf("display is not flipped\n")

	# init the table file, if necessary, and write the header
	if( dotable ){
	    call salloc(cp, ncols, TY_INT)
	    call ini_distable(temp, tp, Memi[cp], ncols, type, xdim/ncols)
	    call put_tbh(tp, "", imname, Memc[title])
	    call hd_distable(tp, xdim/ncols, ydim/nrows, scale, bias, flip)
	}

	# accumulate and display the data
	switch(type){
	case TY_SHORT:
	    call salloc(buf, ncols * nrows, TY_SHORT)
	    call aclrs(Mems[buf], ncols * nrows)
	    call msk_g2ss(mp, Mems[buf], xdim, ydim, ncols, nrows)
	    call sca_disbuf(buf, nrows*ncols, type, scale, bias)
	    call dispbufs(Mems[buf], ncols, nrows, flip)
	case TY_INT:
	    call salloc(buf, ncols * nrows, TY_INT)
	    call aclri(Memi[buf], ncols * nrows)
	    call msk_g2si(mp, Memi[buf], xdim, ydim, ncols, nrows)
	    call sca_disbuf(buf, nrows*ncols, type, scale, bias)
	    call dispbufi(Memi[buf], ncols, nrows, flip)
	case TY_LONG:
	    call salloc(buf, ncols * nrows, TY_LONG)
	    call aclrl(Meml[buf], ncols * nrows)
	    call msk_g2sl(mp, Meml[buf], xdim, ydim, ncols, nrows)
	    call sca_disbuf(buf, nrows*ncols, type, scale, bias)
	    call dispbufl(Meml[buf], ncols, nrows, flip)
	case TY_REAL:
	    call salloc(buf, ncols * nrows, TY_REAL)
	    call aclrr(Memr[buf], ncols * nrows)
	    call msk_g2sr(mp, Memr[buf], xdim, ydim, ncols, nrows)
	    call sca_disbuf(buf, nrows*ncols, type, scale, bias)
	    call dispbufr(Memr[buf], ncols, nrows, flip)
	case TY_DOUBLE:
	    call salloc(buf, ncols * nrows, TY_DOUBLE)
	    call aclrd(Memd[buf], ncols * nrows)
	    call msk_g2sd(mp, Memd[buf], xdim, ydim, ncols, nrows)
	    call sca_disbuf(buf, nrows*ncols, type, scale, bias)
	    call dispbufd(Memd[buf], ncols, nrows, flip)
	case TY_COMPLEX:
	    call salloc(buf, ncols * nrows, TY_COMPLEX)
	    call aclrx(Memx[buf], ncols * nrows)
	    call msk_g2sx(mp, Memx[buf], xdim, ydim, ncols, nrows)
	    call sca_disbuf(buf, nrows*ncols, type, scale, bias)
	    call dispbufx(Memx[buf], ncols, nrows, flip)
	}
	# print final cr
	call printf("\n")

	# fill the table
	if( dotable ){
	    call fil_distable(tp, Memi[cp], buf, ncols, nrows, type,
			ydim/nrows, flip)
	    call tbtclo(tp)
	    call finalname(temp, table)
	}

	# close MIO file
	call mio_close(mp)
	# close pixel mask
	call pm_close(pm)
	# close image
	call imunmap(im)

	# free up stack space
	call sfree(sp)
	call mfree(title, TY_CHAR)
end

