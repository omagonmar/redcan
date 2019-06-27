#$Header: /home/pros/xray/ximages/imcreate/RCS/imcreate.x,v 11.0 1997/11/06 16:28:04 prosb Exp $
#$Log: imcreate.x,v $
#Revision 11.0  1997/11/06 16:28:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:17  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:58  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:52  prosb
#General Release 2.3
#
#Revision 6.1  93/10/20  16:52:36  mo
#MC	10/20/93	Add routine to replace comma delimiters with spaces
#
#Revision 6.0  93/05/24  16:06:50  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:26  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:16:50  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:13  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:49:59  pros
#General Release 1.0
#
#
#	IMCREATE - CREATE AN N-DIMENSIONAL IMAGE FILE
#

include <fset.h>
include <finfo.h>
include <error.h>
include	<imhdr.h>
include <mach.h>

define	NTYPES		6

#
# IMCREATE -- Make a new two dimensional image of a specified size
# and datatype.  The image pixels are all set to zero.
#
procedure t_imcreate()

char	ich				# input data type
char	och				# output data type
short	ty_code[NTYPES]			# buffer for type codes
int	i				# loop counter
int	cc				# number of char returned by ctod
int	otype				# data type of output
int 	ndims				# number of dimensions
int	dims[IM_MAXDIM]			# lengths of all dims
int	fin				# file channel
int	hsize				# header size
int	totsize				# total length of all dims
int	fsize				# size of file
int	itype				# data type of input
int	ip				# pointer to ctod
int	status				# status of image I/O
int	linelen				# length of input line to read
int	nchar				# nchars actually read from input
int	junk				# status of finfo call
int	kpix				# flag if constant value pixel is true
bool	clobber				# clobber old image file
long	ostruct[LEN_FINFO]		# info structure
long	iv[IM_MAXDIM]			# image vector
double	pixval				# constant pixel value
pointer	imname				# image name
pointer imtemp				# temp image name
pointer	pixstr				# pix value of file
pointer	title				# title
pointer lenstr				# string with dimension lengths
pointer	im				# image pointer
pointer buf				# output buf pointer
pointer	hist				# history
pointer	sp				# stack pointer

char	clgetc()			# get parm char
bool	clgetb()			# get parm bool
bool	streq()				# string compare
int	ctod()				# convert char to double
int	clgeti()			# get parm int
int	stridx()			# string compare
int	open(), read()			# file I/O
int	finfo()				# get file into
int	access()			# file access routine
int	ctoi()				# convert ascii to int
int	sizeof()			# size of a type
pointer	immap()				# open an image
int	impnls(), impnli(), impnll(), impnlr(), impnld(), impnlx()

string	types "silrdx"			# Supported pixfile datatypes
data	ty_code /TY_SHORT, TY_INT, TY_LONG, TY_REAL,
	TY_DOUBLE, TY_COMPLEX/

begin
	# mark the stack
	call smark (sp)

	# allocate char space
        call salloc (imname, SZ_PATHNAME, TY_CHAR)
        call salloc (imtemp, SZ_PATHNAME, TY_CHAR)
        call salloc (pixstr, SZ_PATHNAME, TY_CHAR)
        call salloc (lenstr, SZ_LINE, TY_CHAR)
        call salloc (title, SZ_LINE, TY_CHAR)
	call salloc (hist, SZ_LINE, TY_CHAR)

	# get the parameters
	call clgstr ("output_image", Memc[imname], SZ_FNAME)
	# get string with dimensions in it
	call clgstr ("output_dims", Memc[lenstr], SZ_LINE)
	# pick out the dimensions from the string
	ndims = 1
	ip = 1
	# replace comma delimiter with space
	call ck_comma(Memc[lenstr],SZ_LINE)
	while( TRUE ){
	    nchar = ctoi(Memc[lenstr], ip, dims[ndims])
	    if( nchar ==0 ) break
	    if( ndims > IM_MAXDIM )
		call error(1, "too many image dimensions specified")
	    ndims = ndims + 1
	}
	ndims = ndims - 1
	och = clgetc ("output_datatype")
	otype  = ty_code[stridx(och,types)]
	call clgstr ("output_title", Memc[title], SZ_LINE)
	call clgstr("input_value", Memc[pixstr], SZ_FNAME)
	# see if input describes a file
	if( access(Memc[pixstr], 0, 0) == YES ){
	    ich = clgetc ("input_datatype")
	    itype  = ty_code[stridx(ich,types)]
	    hsize = clgeti ("input_headersize")
	    kpix = NO
	}
	else
	    kpix = YES
	# clobber old file?
	clobber = clgetb ("clobber")

	# get constant pixel value, if necessary
	if( kpix == YES ){
	    ip = 1
	    cc = ctod(Memc[pixstr], ip, pixval)
	    if( cc ==0 )
		call error(1, "pixval not a number or an accessible file")
	}

	# make sure we have an output file
	if( streq(Memc[imname], "") )
	    call error(1, "requires an output file name")

	# check for existence of output file
	call clobbername(Memc[imname], Memc[imtemp], clobber, SZ_PATHNAME)

	# open the output file
	im = immap (Memc[imtemp], NEW_IMAGE, 0)

	# set the file type and dimensions, etc.
	IM_PIXTYPE(im) = otype
	IM_NDIM(im) = ndims

	# fill in the dimension info
	# (calculate the expected size of the file along the way)
	totsize = sizeof(itype) * SZB_CHAR
	for(i=1; i<=ndims; i=i+1){
	    IM_LEN(im, i) = dims[i]
	    totsize = totsize * dims[i]
	}

	# add the title
	call strcpy (Memc[title], IM_TITLE(im), SZ_IMTITLE)

	# add the history line
	if( kpix == YES ){
	    call sprintf(Memc[hist], SZ_LINE,
			"constant %s -> %s (ty=%c, dims=%s)")
	    call pargstr(Memc[pixstr])
	    call pargstr(Memc[imname])
	    call pargc(och)
	    call pargstr(Memc[lenstr])
	}
	else{
	    call sprintf(Memc[hist], SZ_LINE,
			"file %s (ty=%c, head=%d) -> %s (ty=%c, dims=%s)")
	    call pargstr(Memc[pixstr])
	    call pargc(ich)
	    call pargi(hsize)
	    call pargstr(Memc[imname])
	    call pargc(och)
	    call pargstr(Memc[lenstr])
	}
	call put_imhistory(im, "imcreate", Memc[hist], "")
	call printf("\n%s\n\n")
	call pargstr(Memc[hist])

	# open the input file, if necessary
	if( kpix == NO ){
	    # check on the file size
	    junk = finfo(Memc[pixstr], ostruct)
	    fsize = FI_SIZE(ostruct) - hsize*SZB_CHAR
	    if( fsize != totsize ) {
		if( fsize < totsize )
		    call error(1, "input file is too small")
	 	else
		    call printf("Note: input file is longer than array\n")
	    }
	    # if ok, open the file
	    fin = open(Memc[pixstr], READ_ONLY, BINARY_FILE)
	    # and space past the header
	    if( hsize ==0 )
		hsize = BOF
	    else
		# first byte seems to be 1 in IRAF
		hsize = hsize + 1
	    call seek(fin, long(hsize))
	}

	# init the image vector
	call amovkl(long(1), iv, IM_MAXDIM)

	# set the SPP chars to read into each line
	linelen = sizeof(itype) * IM_LEN(im, 1)

	# Write out the lines.
	status = OK
	while( status != EOF ){
	    if( kpix == YES ){
		status = impnld (im, buf, iv)
		if( status == EOF ) break
		call amovkd (pixval, Memd[buf], IM_LEN(im,1))
	    }
	    else{
		switch(itype){
		case TY_SHORT:
		    status = impnls (im, buf, iv)
		    if( status == EOF ) break
		    nchar = read(fin, Mems[buf], linelen)
		case TY_INT:
		    status = impnli (im, buf, iv)
		    if( status == EOF ) break
		    nchar = read(fin, Memi[buf], linelen)
		case TY_LONG:
		    status = impnll (im, buf, iv)
		    if( status == EOF ) break
		    nchar = read(fin, Meml[buf], linelen)
		case TY_REAL:
		    status = impnlr (im, buf, iv)
		    if( status == EOF ) break
		    nchar = read(fin, Memr[buf], linelen)
		case TY_DOUBLE:
		    status = impnld (im, buf, iv)
		    if( status == EOF ) break
		    nchar = read(fin, Memd[buf], linelen)
		case TY_COMPLEX:
		    status = impnlx (im, buf, iv)
		    if( status == EOF ) break
		    nchar = read(fin, Memx[buf], linelen)
		}		
		# look for unexpected EOF
		if( nchar == EOF )
		    call error(1, "unexpected EOF on input")
	    }
	}

	# close up shop
	call imunmap (im)

	# rename temp file, if necessary
	call finalname(Memc[imtemp], Memc[imname])

	# free up stack space
	call sfree(sp)
end
