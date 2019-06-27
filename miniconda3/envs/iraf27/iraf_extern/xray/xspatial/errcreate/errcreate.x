# $Header: /home/pros/xray/xspatial/errcreate/RCS/errcreate.x,v 11.0 1997/11/06 16:30:30 prosb Exp $
# $Log: errcreate.x,v $
# Revision 11.0  1997/11/06 16:30:30  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:47:31  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  14:58:00  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/02  10:33:03  mo
#MC	5/2/94		Fix type declarations (and usage) for imaccess/streq
#			(Reported in MAC/AUX port)
#
#Revision 7.0  93/12/27  18:30:11  prosb
#General Release 2.3
#
#Revision 1.1  93/12/15  11:37:30  mo
#Initial revision
#
#
# Module:	< file name >
# Project:	PROS -- ROSAT RSDC
# Purpose:	< opt, brief description of whole family, if many routines>
# External:	< routines which can be called by applications>
# Local:	< routines which are NOT intended to be called by applications>
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} <author>  initial version <when>	
#		{n} <who> -- <does what> -- <when>
#

include	<fset.h>
include <ctype.h>
include	<imhdr.h>
include <ext.h>
include <qpoe.h>

define	ERR_FATAL	1
procedure t_errcreate()
bool	clobber
long	v1[IM_MAXDIM]			# image vector
long	v2[IM_MAXDIM]			# image vector
long	one_l				#
int	hsize,vsize			# x dimension
int	line
int	display
int	itype
pointer	sp	
pointer	imname				# image name
pointer	errname				# error image name
pointer errtemp				# temp image name
pointer buf				# print buffer
pointer	im				# input image pointer
pointer	imhead				# input image header structure 

pointer	err				# output err image pointer
pointer	hist				# history
pointer	l1,l2
int	clgeti(), imgeti(), fstati(), im_access()
bool	clgetb(),streq()
pointer	immap()				# open an image
pointer	impnlr()
pointer	imgnls(), imgnli(), imgnll(), imgnlr(), imgnld()

begin
        if (fstati (STDOUT, F_REDIR) != YES)
	    call fseti(STDOUT, F_FLUSHNL, YES)

	call smark(sp)
	# allocate char space
        call salloc (imname, SZ_PATHNAME, TY_CHAR)
        call salloc (errtemp, SZ_PATHNAME, TY_CHAR)
        call salloc (errname, SZ_PATHNAME, TY_CHAR)
	call salloc (hist, SZ_LINE, TY_CHAR)
	call salloc (buf, SZ_LINE, TY_CHAR)
	call salloc (imhead, SZ_QPHEAD, TY_CHAR)

	# get the parameters
	call clgstr ("input_image", Memc[imname], SZ_PATHNAME)
	# make sure we have an input file
	if( streq(Memc[imname], "") )
	    call error(ERR_FATAL, "requires an input file name")

	if( im_access(Memc[imname],READ_ONLY) == NO )
	    call errorstr(ERR_FATAL,"Input file does not exist",Memc[imname])

	# check for existence of output file
	call clgstr ("output_errimage", Memc[errname], SZ_PATHNAME)
	# clobber old file?
	clobber = clgetb ("clobber")
	display = clgeti ("display")

	call rootname(Memc[imname], Memc[errname], EXT_ERROR, SZ_PATHNAME)
	call clobbername(Memc[errname], Memc[errtemp], clobber, SZ_PATHNAME)

	# open the input file, if necessary
	# check on the file size
	im = immap(Memc[imname],READ_ONLY,0)
	call get_imhead(im,imhead)
	# open the output file
	err = immap (Memc[errtemp], NEW_COPY, im)

	hsize = IM_LEN(im,1)
	vsize = IM_LEN(im,2)

	one_l = 1
	call amovkl (one_l, v1, IM_MAXDIM)
	call amovkl (one_l, v2, IM_MAXDIM)
	itype =  imgeti(im,"i_pixtype")
	call imputi(err, "i_pixtype",TY_REAL)
	itype =  imgeti(err,"i_pixtype")
	line = 0
	if( display > 1 )
	{
	   if( QP_POISSERR(imhead) == YES )
		call printf("Calculating Poisson-style errors\n")
	   else
		call printf("Calculating Gaussian errors\n")
	}
	switch(itype)
	{
	    case TY_SHORT:
		while( imgnls( im, l1, v1) != EOF &&
			impnlr( err, l2, v2) != EOF)
		{
	            call achtsr(Mems[l1],Memr[l2],hsize)
	            call one_sigma(Memr[l2],hsize,QP_POISSERR(imhead),Memr[l2])
	            call amulr(Memr[l2], Memr[l2], Memr[l2], hsize)
		    line = line + 1
		}
	    case TY_INT:
		while( imgnli( im, l1, v1) != EOF &&
			impnlr( err, l2, v2) != EOF)
		{
	            call achtir(Mems[l1],Memr[l2],hsize)
	            call one_sigma(Memr[l2],hsize,QP_POISSERR(imhead),Memr[l2])
	            call amulr(Memr[l2], Memr[l2], Memr[l2], hsize)
	            call achtri(Mems[l1],Memr[l2],hsize)
		    line = line + 1
		}
	    case TY_LONG:
		while( imgnll( im, l1, v1) != EOF &&
			impnlr( err, l2, v2) != EOF)
		{
	            call achtlr(Mems[l1],Memr[l2],hsize)
	            call one_sigma(Memr[l2],hsize,QP_POISSERR(imhead),Memr[l2])
	            call amulr(Memr[l2], Memr[l2], Memr[l2], hsize)
		    line = line + 1
		}
	    case TY_REAL:
		while( imgnlr( im, l1, v1) != EOF &&
			impnlr( err, l2, v2) != EOF)
#	        call achtir(Mems[l1],Memr[l2],hsize)
		{
	            call one_sigma(Memr[l1],hsize,QP_POISSERR(imhead),Memr[l2])
	            call amulr(Memr[l2], Memr[l2], Memr[l2], hsize)
		    line = line + 1
		}
	    case TY_DOUBLE:
		while( imgnld( im, l1, v1) != EOF &&
			impnlr( err, l2, v2) != EOF)
		{
	            call achtdr(Mems[l1],Memr[l2],hsize)
	            call one_sigma(Memr[l2],hsize,QP_POISSERR(imhead),Memr[l2])
#	            call one_sigma(Memr[l2],hsize,Memr[l2])
	            call amulr(Memr[l2], Memr[l2], Memr[l2], hsize)
		    line = line + 1
		}
#	    case TY_COMPLEX:
#	        call amovx(Memx[(imgl2x(im,line)],Memx[impl2x(err,line),hsize)
	}

	# add the history line
	call sprintf(Memc[hist], SZ_LINE,
			"image %s -> errimage %s ")
	    call pargstr(Memc[imname])
	    call pargstr(Memc[errname])

	call put_imhistory(im, "errcreate", Memc[hist], "")
	if( display >= 1)
	    call printf("\n%s\n\n")
	        call pargstr(Memc[hist])

	# close up shop
	call imunmap (im)
	call imunmap (err)

	# rename temp file, if necessary
	if( display >= 1)
	   call printf("Writing output file %s\n")
		call pargstr(Memc[errname])
	call finalname(Memc[errtemp], Memc[errname])

	if( line != vsize )
	{
	    call sprintf(Memc[buf], SZ_LINE,"WARNING: input lines (%d) not equal to output lines (%d)")
	   	call pargi(vsize)
	   	call pargi(line)
	    call error(ERR_FATAL,Memc[buf])
	}
	# free up stack space
	call sfree(sp)
end
