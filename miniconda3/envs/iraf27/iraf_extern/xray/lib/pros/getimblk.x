#$Header: /home/pros/xray/lib/pros/RCS/getimblk.x,v 11.0 1997/11/06 16:20:30 prosb Exp $
#$Log: getimblk.x,v $
#Revision 11.0  1997/11/06 16:20:30  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:42  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:38  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:44:49  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:49  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:48:48  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:00:45  wendy
#General
#
#Revision 2.0  91/03/07  00:07:00  pros
#General Release 1.0
#
include <error.h>
include <imhdr.h>

# ---------------------------------------------------------------------
# get_imblk - compute the blocking factor from the image hdr
# ---------------------------------------------------------------------

real procedure get_imblk(im, dim)

pointer im			# i: image handle
int     dim			# i: image dimension retrieving factor for

int     ximlen			# l: axis length of dimension in image
int     xaxlen			# l: reference axis length of dimension
pointer buf			# l: string buffer
pointer sp			# l: memory stack pointer	
real    blk_factor		# l: image block factor

int     imaccf()
int     imgeti()

begin

	call smark(sp)
	call salloc (buf, SZ_LINE, TY_CHAR)

#   Retrieve the current length of the image in the given dimension
	ximlen = IM_LEN(im,dim)

#   Retrieve the original length of the image in the given dimension
#   ( if it doesn't exist assume the value above )

	call sprintf (Memc[buf], SZ_LINE, "axlen%d")
	  call pargi(dim)

	if ( imaccf (im, Memc[buf]) == NO) {
	      xaxlen = ximlen
	} else {
	      xaxlen = imgeti (im, Memc[buf])
	}

#   Determine the block factor of the current image
	blk_factor = xaxlen / ximlen

	call sfree (sp)

	return ( blk_factor )
end
