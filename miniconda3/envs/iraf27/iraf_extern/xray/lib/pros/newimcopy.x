#$Header: /home/pros/xray/lib/pros/RCS/newimcopy.x,v 11.0 1997/11/06 16:20:42 prosb Exp $
#$Log: newimcopy.x,v $
#Revision 11.0  1997/11/06 16:20:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:03  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:47  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:09  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:45:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:12  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:49:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:00:55  wendy
#General
#
#Revision 2.0  91/03/07  00:07:18  pros
#General Release 1.0
#
include <error.h>
include <imhdr.h>
#  --------------------------------------------------------------------------
#  new_imcopy  -- open the output image and copy the input header.  Set the
#		  axlen if it doesn't exist.
#  --------------------------------------------------------------------------

procedure new_imcopy (in, outname, out)

pointer in			# i: input image handle
char    outname[ARB]		# i: output image filename
pointer out			# o: output image handle

int     dim			# l: dimension counter
pointer axbuf			# l: axis header label
pointer sp			# l: memory stack pointer

int	imaccf()
pointer immap()

begin
  
	call smark (sp)
	call salloc (axbuf, SZ_LINE, TY_CHAR)

#   Open the output image and copy the header

	out = immap (outname, NEW_COPY, in)

#   Initialize axis length of output if doesn't exist to dim of input image
#   It will only exist if image originated from a qpoe

        for (dim=1; dim<=IM_NDIM(in); dim=dim+1) {

	   call sprintf(Memc[axbuf], SZ_LINE, "axlen%d")
	     call pargi(dim)

	   if ( imaccf (out, Memc[axbuf]) == NO ) {
	      call imaddf (out, Memc[axbuf], "i")
	      call imputi (out, Memc[axbuf], IM_LEN(in,dim)) 
	   }
	}

	call sfree(sp)

end
