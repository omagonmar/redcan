#$Header: /home/pros/xray/xdataio/im2bin/RCS/im2bin.x,v 11.0 1997/11/06 16:35:59 prosb Exp $
#$Log: im2bin.x,v $
#Revision 11.0  1997/11/06 16:35:59  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:00:18  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:22:34  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:44:38  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:07:46  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:13:04  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:58:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:14:36  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:39:47  pros
#General Release 1.0
#
#
# Module:       IM2BIN
# Project:      PROS -- ROSAT RSDC
# Purpose:      To convert an image file (created by imcreate) back to a binary.
# External:     
# Local:        t_im2bin()
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} D.Meleedy  initial version 	2-7-1991
#               {n} <who> -- <does what> -- <when>
#

include <fset.h>
include <error.h>
include	<imhdr.h>
include <mach.h>

define	NTYPES		6

#
# IMTOBIN -- Make a binary file from a two dimensional image of a specified size
# and datatype.
#

procedure t_im2bin()

char	och				# output data type
char	istring[15]			# output data type in string form
short	ty_code[NTYPES]			# buffer for type codes
int	otype				# data type of output
int	fout				# file channel
int	itype				# data type of input
int	status				# status of image I/O
int	linelen				# length of input line to write
int	nchar				# nchars actually written to output
int     display                 # i: level of status message and debug
bool	odef				# use default for output file
bool	clobber				# clobber old output file
long	iv[IM_MAXDIM]			# image vector
pointer	imname				# image name
pointer binname				# binary file name
pointer	bintemp				# temp binary file name
pointer	im				# image pointer
pointer buf				# output buf pointer
pointer	sp				# stack pointer

bool	clgetb()			# get parm bool
int     clgeti()                # get int param from cl or param file
bool	streq()				# string compare
int	stridx()			# string compare
int	open(), write()			# file I/O
int	access()			# file access routine
int	sizeof()			# size of a type
pointer	immap()				# open an image
int	imgnls(), imgnli(), imgnll(), imgnlr(), imgnld(), imgnlx()

string	types "silrdx"			# Supported pixfile datatypes
data	ty_code /TY_SHORT, TY_INT, TY_LONG, TY_REAL,
	TY_DOUBLE, TY_COMPLEX/

begin
	# mark the stack
	call smark (sp)

	# allocate char space
        call salloc (imname, SZ_PATHNAME, TY_CHAR)
        call salloc (binname, SZ_PATHNAME, TY_CHAR)
        call salloc (bintemp, SZ_PATHNAME, TY_CHAR)

	# get the parameters
	call clgstr ("output_binary", Memc[binname], SZ_FNAME)
	call clgstr ("output_datatype",istring,10)
	odef = ( streq (istring,"") )
	och = istring[1]
	call clgstr("input_file", Memc[imname], SZ_FNAME)

	# see if input describes a file
	if( access(Memc[imname], 0, 0) == NO )
	    call error (1, "Specified input file does not exist.")

	# clobber old file?
	clobber = clgetb ("clobber")

	# display level?
	display = clgeti("display")

	# make sure we have an output file
	if( streq(Memc[binname], "") )
	    call error(1, "requires an output file name")

	# check for existence of output file
	call clobbername(Memc[binname], Memc[bintemp], clobber, SZ_PATHNAME)

	# open the input file
	im = immap (Memc[imname], READ_ONLY, 0)

	# get the file type and dimensions, etc.
	itype = IM_PIXTYPE(im)

	# figure out the output file type
	if (odef)
		otype = itype
	else
		otype  = ty_code[stridx(och,types)]

	#display the "imcreate" part of the history section of the image
	call disp_imhistory(im, "")
	call printf ("\n")
	call flush(STDOUT)

	# open the output file
	fout = open(Memc[bintemp], NEW_FILE, BINARY_FILE)

	# init the image vector
	call amovkl(long(1), iv, IM_MAXDIM)

	# set the SPP chars to write to each line
	linelen = sizeof(otype) * IM_LEN(im, 1)

	# Write out the lines.
	status = OK
	while( status != EOF )
	    {
		switch(itype){
		case TY_SHORT:
		    status = imgnls (im, buf, iv)
		    if( status == EOF ) break
		    nchar = write(fout, Mems[buf], linelen)
		case TY_INT:
		    status = imgnli (im, buf, iv)
		    if( status == EOF ) break
		    nchar = write(fout, Memi[buf], linelen)
		case TY_LONG:
		    status = imgnll (im, buf, iv)
		    if( status == EOF ) break
		    nchar = write(fout, Meml[buf], linelen)
		case TY_REAL:
		    status = imgnlr (im, buf, iv)
		    if( status == EOF ) break
		    nchar = write(fout, Memr[buf], linelen)
		case TY_DOUBLE:
		    status = imgnld (im, buf, iv)
		    if( status == EOF ) break
		    nchar = write(fout, Memd[buf], linelen)
		case TY_COMPLEX:
		    status = imgnlx (im, buf, iv)
		    if( status == EOF ) break
		    nchar = write(fout, Memx[buf], linelen)
		}		
		# look for unexpected EOF
		if( nchar == EOF )
		    call error(1, "unexpected EOF on input")
	    }

	# close up shop
	call imunmap (im)

	call close (fout)

	# write name of output file
	if ( display >= 1)
        {
		call printf ("writing binary file to : %s\n")
		call pargstr(Memc[binname])
		call flush(STDOUT)
	}

	# rename temp file, if necessary
	call finalname(Memc[bintemp], Memc[binname])

	# free up stack space
	call sfree(sp)
end
