#$Header: /home/pros/xray/lib/pros/RCS/mskcnts.x,v 11.0 1997/11/06 16:20:39 prosb Exp $
#$Log: mskcnts.x,v $
#Revision 11.0  1997/11/06 16:20:39  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:57  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:45:08  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:02  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:49:09  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:00:52  wendy
#General
#
#Revision 2.0  91/03/07  00:07:11  pros
#General Release 1.0
#
#
# MSK_CNTS -- count up pixels in a 2-D buffer using MIO calls
# the mask value is used as an offset into the result buffer
#

include <error.h>
include <pmset.h>

procedure msk_cnts(mp, type, counts, area, min, max)

pointer	mp		# i: mask handle
int	type		# i: data type of image
double	counts[ARB]	# o: array to hold counts
double	area[ARB]	# o: array to hold areas
int	min		# i: min index value for mask
int	max		# i: max index value for mask

# short	sval		# l: value at this pixel
int	ival		# l: value at this pixel
long	lval		# l: value at this pixel
real	rval		# l: value at this pixel
double	dval		# l: value at this pixel
complex	xval		# l: value at this pixel

int	i		# l: loop counter
int	status		# l: status flag for mio call
int	mval		# l: value of integer mask from mio call
int	npix		# l: size of returned pp array
int	offset		# l: offset into array
long	v[PM_MAXDIM]	# l: vector from mio call
pointer	pp		# l: pixel pointer for mio call

int mio_glsegs()	# l: mio get seg call
int mio_glsegi()	# l: mio get seg call
int mio_glsegl()	# l: mio get seg call
int mio_glsegr()	# l: mio get seg call
int mio_glsegd()	# l: mio get seg call
int mio_glsegx()	# l: mio get seg call

begin
	status = OK
	while( status != EOF ){
	    # get next line segment
	    switch(type){
	    case TY_SHORT:
		status = mio_glsegs(mp, pp, mval, v, npix)
	    case TY_INT:
		status = mio_glsegi(mp, pp, mval, v, npix)
	    case TY_LONG:
		status = mio_glsegl(mp, pp, mval, v, npix)
	    case TY_REAL:
		status = mio_glsegr(mp, pp, mval, v, npix)
	    case TY_DOUBLE:
		status = mio_glsegd(mp, pp, mval, v, npix)
	    case TY_COMPLEX:
		status = mio_glsegx(mp, pp, mval, v, npix)
	    }		
	    if( status != EOF ){
		# make sure this mask value is in range
		if( (mval < min) || (mval > max) )
		    call error(EA_ERROR, "mask value out of range")
		# calc the offset into the arrays
		offset = mval - min + 1
		# add up the pixels values in this segment
		switch(type){
		case TY_SHORT:
#		    sval = 0
#		    do i=0, (npix-1)
#			sval = sval + Mems[pp+i]
#		    counts[offset] = counts[offset] + double(sval)
#		    area[offset] = area[offset] + npix
		    ival = 0
		    do i=0, (npix-1)
			ival = ival + Mems[pp+i]
		    counts[offset] = counts[offset] + double(ival)
		    area[offset] = area[offset] + npix
		case TY_INT:
		    ival = 0
		    do i=0, (npix-1)
			ival = ival + Memi[pp+i]
		    counts[offset] = counts[offset] + double(ival)
		    area[offset] = area[offset] + npix
		case TY_LONG:
		    lval = 0
		    do i=0, (npix-1)
			lval = lval + Meml[pp+i]
		    counts[offset] = counts[offset] + double(lval)
		    area[offset] = area[offset] + npix
		case TY_REAL:
		    rval = 0.0
		    do i=0, (npix-1)
			rval = rval + Memr[pp+i]
		    counts[offset] = counts[offset] + double(rval)
		    area[offset] = area[offset] + npix
		case TY_DOUBLE:
		    dval = 0.0D0
		    do i=0, (npix-1)
			dval = dval + Memd[pp+i]
		    counts[offset] = counts[offset] + dval
		    area[offset] = area[offset] + npix
		case TY_COMPLEX:
		    dval = 0.0D0
		    do i=0, (npix-1)
			xval = xval + Memx[pp+i]
		    counts[offset] = counts[offset] + double(xval)
		    area[offset] = area[offset] + npix
		}		
	    }
	}
end

