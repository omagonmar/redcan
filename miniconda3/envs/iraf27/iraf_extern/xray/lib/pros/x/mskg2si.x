#$Header: /home/pros/xray/lib/pros/RCS/mskg2s.gx,v 11.0 1997/11/06 16:20:41 prosb Exp $
#$Log: mskg2s.gx,v $
#Revision 11.0  1997/11/06 16:20:41  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:00  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:45:14  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:07  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:49:17  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:00:53  wendy
#General
#
#Revision 2.0  91/03/07  00:07:14  pros
#General Release 1.0
#
#
# MSK_G2S -- fill a 2-D buffer using MIO calls
# the mask is used as a filter but is otherwise ignored
#

include <mach.h>
include <pmset.h>
include <error.h>

procedure msk_g2si(mp, buf, xdim, ydim, ncols, nrows)

pointer	mp		# i: mask handle
int	buf[ARB]	# o: array to hold data
int	xdim, ydim	# i: dim of array
int	nrows, ncols	# i: size of buffer

int	val		# l: value at this pixel
int	i		# l: loop counter
int	status		# l: status flag for mio call
int	mval		# l: value of integer mask from mio call
int	npix		# l: size of returned pp array
int 	yoffset		# l: offset into buffer for this line
int	xoffset		# l: offset into buffer within this line
int	offset		# l: combo of xoffset, yoffset into buf
int	xblock, yblock	# l: blocking factors
long	v[PM_MAXDIM]	# l: vector from mio call
pointer	pp		# l: pixel pointer for mio call

int mio_glsegi()	# l: mio get seg call

begin
	status = OK
	xblock = xdim/ncols
	yblock = ydim/nrows
	while( status != EOF ){
	    # get next line segment
	    status = mio_glsegi(mp, pp, mval, v, npix)
	    if( status != EOF ){
		# determine the line number in which this pixel lies
		yoffset = (v[2]-1)/yblock
		# skip last rows if nrows does not divide ydim evenly
		if( yoffset < nrows ){
		    # deposit each pixel in this line segment
		    do i=0, (npix-1){
			if( Memi[pp+i] ==0 )
			    next
			else
			    val = Memi[pp+i]
			# determine the offset into this line
		        xoffset = (v[1]+i-1)/xblock
			# skip last cols if ncols does not divide xdim evenly
		        if( xoffset < ncols ){
		            offset = yoffset * ncols + xoffset + 1
		            buf[offset] = buf[offset] + val
			}
		    }
		}
	    }
	}
end
