#$Header: /home/pros/xray/ximages/imcalc/RCS/imcalc.com,v 11.0 1997/11/06 16:27:25 prosb Exp $
#$Log: imcalc.com,v $
#Revision 11.0  1997/11/06 16:27:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:43:55  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:23:50  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:39  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:27:46  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:44  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:16  pros
#General Release 1.0
#
# The image calculator common.

pointer	c_registers			# register array
int	c_nextreg			# next register

pointer	c_images			# image descriptors
int	c_nextimage			# next image

int	c_metacode[LEN_INSTRUCTION,MAX_INSTRUCTIONS]
int	c_nextinst			# next instruction
int	c_ip				# instruction pointer

int	c_ndim				# ndim of largest input image
int	c_len[IM_MAXDIM]		# lens of largest input image
int 	c_pixtype			# "highest" pixtype of input images

char	c_imname[SZ_FNAME]		# name of image
char	c_imtemp[SZ_FNAME]		# temp name of image if name already exists
int	c_imageno			# number of images being processed
int	c_ateof				# EOF reached on output image
int     c_lineno			# line number of output image

pointer	c_sbuf				# string buffer
pointer c_nextch			# next char in string buffer

int	c_error				# parser error status
int	c_debug				# debug flag
bool	c_delete			# delete old output image

int	c_callno			# call frame number
int	c_arg[MAX_ARGS, MAX_CALLS]	# call frames (argument lists)
int	c_nargs[MAX_CALLS]		# number of args per frame

int	c_tokens			# number of tokens parsed in this expression

int	c_imhandle			# handle of image to use in NEW_COPY
int	c_section			# flag if lhs image is a section

common	/imccom/ c_registers, c_nextreg,
	c_images, c_nextimage,
	c_metacode, c_nextinst, c_ip,
	c_ndim, c_len, c_pixtype,
	c_imageno, c_ateof, c_lineno,
	c_imname, c_imtemp,
	c_sbuf, c_nextch,
	c_error, c_debug, c_delete,
	c_callno, c_arg, c_nargs, c_tokens,
	c_imhandle, c_section


