#$Header: /home/pros/xray/ximages/imcalc/RCS/xload.x,v 11.0 1997/11/06 16:27:55 prosb Exp $
#$Log: xload.x,v $
#Revision 11.0  1997/11/06 16:27:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:05  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:39  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:35  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:29  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:09  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:29:12  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:00  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:46  pros
#General Release 1.0
#
include	<imhdr.h>
include	"imcalc.h"

# XLOAD -- Load the next line from the input image into the output register.
# Keep the last line read around when the end of the input section is reached.

procedure xload (in, out)

pointer	in			# imcalc image descriptor
pointer	out			# output register

int	status
pointer	im, lbuf
pointer immap()
int	imgnls(), imgnli(), imgnll(), imgnlr(), imgnld(), imgnlx()
include "imcalc.com"

begin

10	im = I_IM(in)

	    switch (IM_PIXTYPE(im)) {
	    case TY_SHORT:
		status = imgnls (im, lbuf, I_V(in))
	    case TY_USHORT, TY_LONG:
		status = imgnll (im, lbuf, I_V(in))
	    case TY_INT:
		status = imgnli (im, lbuf, I_V(in))
	    case TY_REAL:
		status = imgnlr (im, lbuf, I_V(in))
	    case TY_DOUBLE:
		status = imgnld (im, lbuf, I_V(in))
	    case TY_COMPLEX:
		status = imgnlx (im, lbuf, I_V(in))
	    default:
		call imc_error("xload: unknown image pixel datatype")
		return
	    }

	    if (status == EOF) {
		# one less image to process
		if( I_ATEOF(in) == NO )
		    c_imageno = c_imageno - 1
		# this image is done for ...
		I_ATEOF(in) = YES
		#  ... but start looping through again
		call imunmap(im)
		I_IM(in) = immap(I_NAME(in), READ_ONLY, 0)
		call amovkl(long(1), I_V(in), IM_MAXDIM)
		goto 10
	    }
	    else{
		I_LBUF(in) = lbuf
	    }

	R_LBUF(out) = lbuf

end
