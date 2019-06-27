#$Header: /home/pros/xray/lib/regions/RCS/rgfield.x,v 11.0 1997/11/06 16:19:13 prosb Exp $
#$Log: rgfield.x,v $
#Revision 11.0  1997/11/06 16:19:13  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:30  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:52  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:44  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:14  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:20:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:26  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:37  pros
#General Release 1.0
#

#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_field()


include <pmset.h>
include "rgset.h"


########################################################################
#
# rg_field
#
# Mark (as per rgop) an entire pixel list or pixel mask with id
#
# Input: handle of pm or pl file open for writing
# Input: value to write in mask for all pixels
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_field ( pl, id, depth, rgop, rop, pltype)

pointer	pl		# i: handle for open pl or pm
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

int	yval			# l: pixel y coord of a line
int	width			# l: width of pixel mask
int	naxes, axlen[PL_MAXDIM]	# l: dimensions as returned by pl_gsize()
int	v[PL_MAXDIM]		# l: array of axis starting index
int	ranges[RL_LENELEM,3]	# l: line coded as runlist for rg_plpi()
pointer	buf			# l: int buffer for use by rg_plpi()
pointer	sp			# l: stack pointer

begin
	call smark (sp)
	# get the image size
	if( pltype == 1 )
	    call pm_gsize (pl, naxes, axlen, depth)
	else
	    call pl_gsize (pl, naxes, axlen, depth)
	width = axlen[1]
	# initialize all dimensions to start at 1
	call amovki (1, v, PL_MAXDIM)
	# set line width parameter, one run per line
	RL_AXLEN(ranges) = width
	RL_LEN(ranges) = 2
	RL_V(ranges,2) = id
	# allocate pixel array buffer
	call salloc (buf, width, TY_INT)

	# install full field scan points
	RL_X(ranges,2) = 1
	RL_N(ranges,2) = width
	do yval = 1, axlen[2] {
	    v[2] = yval
	    call rg_plpi (pl, v, ranges, Memi[buf], depth, width,
			  rgop, rop, pltype)
	}
	call sfree (sp)
end
