#$Header: /home/pros/xray/lib/pros/RCS/xcmask.x,v 11.0 1997/11/06 16:21:20 prosb Exp $
#$Log: xcmask.x,v $
#Revision 11.0  1997/11/06 16:21:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:50  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:16  prosb
#General Release 2.3
#
#Revision 6.1  93/11/30  11:47:47  prosb
#MC	11/30/93		Update the bad qp_addf routine 
#
#Revision 6.0  93/05/24  15:54:52  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:55  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:50:44  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:02:26  wendy
#General
#
#Revision 2.0  91/03/07  00:07:49  pros
#General Release 1.0
#
#
#	XCMASK.X -- composite mask routines
#
include <qpset.h>
include <qpioset.h>

#
# UPDATE_QPCOMPOSITE --  update "composite" mask in a qpoe file
#  this mask is the combination of all masks through which
#  photons have been filtered to make this qpoe file
#
procedure update_qpcomposite(qp, pl, regions)

pointer	qp				# i: qpoe handle
pointer	pl				# i: handle of mask to add
char	regions[ARB]			# i: region descriptor
char	tregions[SZ_LINE]		# l: upper case version of regions
int	olen				# l: length of old composite mask
int	tlen				# l: temp length for pl_save
int	nlen				# l: length of new composite mask
int	nareas1				# l: number of areas
int	nareas2				# l: number of areas
int	i				# l: loop counter
pointer	obuf				# l: buffer for old composite
pointer	opl				# l: pl handle for old composite
pointer	nbuf				# l: buffer for new composite
pointer	npl				# l: pl handle for new composite
pointer	areas2				# l: pointer to area array
pointer	areas1				# l: pointer to area array

int	qp_accessf()			# l: qpoe param existence
int	qp_geti()			# l: get int param
int	qp_read()			# l: read a qpoe param
int	rg_plmask()			# l: create reg/exp mask
int	pl_save()			# l: save pl to buffer
int	pl_open()			# l: open a pl mask
bool	strne()				# l: string compare

begin
	# see if there is a composite mask already
	if( qp_accessf(qp, "XS-NCMSK") == YES ){
	    # get size of old composite mask
	    olen = qp_geti(qp, "XS-NCMSK")
	    # allocate space for old composite mask
	    call calloc(obuf, olen, TY_SHORT)
	    # read the mask into the buffer
	    if( qp_read(qp, "XS-CMASK", Mems[obuf], olen, 1, "s") != olen)
		call error(1, "wrong size for composite mask")
	    # open a null plio mask
	    opl = pl_open(NULL)
	    # load the composite
	    call pl_load(opl, obuf)
	    # delete the old composite mask param - size might change
	    call qp_deletef(qp, "XS-CMASK")
	    # get region into upper case
	    call strcpy(regions, tregions, SZ_LINE)
	    call strupr(tregions)
	    # if we have a region (not field), then use the old composite
	    # as a stencil for the new mask.  Otherwise, use the new mask
	    # as a stencil for the old composite
	    if( (tregions[1] != EOS) && (strne("field", tregions)) ){
		npl = rg_plmask(opl, pl, 1)
		# calculate the area for each region in the input mask
		call rg_areas(pl, areas1, nareas1)
		# calculate the area for each region in composite mask
		call rg_areas(npl, areas2, nareas2)
		# this can't happen
		if( nareas1 != nareas2 )
		    call error(1, "input region narea != composite narea")
		# issue a warning if area decreased because of composite
		do i=1, nareas2{
		    if( Memi[areas2+i-1] < Memi[areas1+i-1] ){
			call printf("\nWarning: area of composite mask < area of input regions\n")
			call printf("Please be sure you understand why this is so (you filtered regions twice!)\n")
			break
		    }
		}
		# and store in the qpoe file
		call put_qparea(qp, areas2, nareas2)
		# free the area arrays
		call mfree(areas1, TY_INT)
		call mfree(areas2, TY_INT)
	    }
	    else{
		npl = rg_plmask(pl, opl, 1)
		# calculate the area for each region in composite mask
		call rg_areas(npl, areas2, nareas2)
		# and store in the qpoe file
		call put_qparea(qp, areas2, nareas2)
		# free the area arrays
		call mfree(areas2, TY_INT)
	    }
	    # save the new composite to a buffer
	    nbuf = NULL
	    nlen = pl_save(npl, nbuf, tlen, 0)
	    # make a new qpoe param to hold the composite
	    call qpx_addf(qp, "XS-CMASK", "s", nlen, "composite mask", 0)
	    # write the mask to the qpoe file
	    call qp_write(qp, "XS-CMASK", Mems[nbuf], nlen, 1, "s")
	    # update the size
	    call qp_addi(qp, "XS-NCMSK", nlen, "Mask size")
	    # close the old and new composite mask
	    call pl_close(opl)
	    call pl_close(npl)
	    # free up space
	    call mfree(obuf, TY_SHORT)
	    call mfree(nbuf, TY_SHORT)
	}
	# first time through with a composite mask - just store it
	else{
	    # save the new composite to a buffer
	    nbuf = NULL
	    nlen = pl_save(pl, nbuf, tlen, 0)
	    # make a new qpoe param to hold the composite
	    call qpx_addf(qp, "XS-CMASK", "s", nlen, "composite mask", 0)
	    # write the mask to the qpoe file
	    call qp_write(qp, "XS-CMASK", Mems[nbuf], nlen, 1, "s")
	    # make a new qpoe param to hold the size of the composite
	    call qpx_addf(qp, "XS-NCMSK", "i", 1,
			"size of composite mask (shorts)", 0)
	    # update the size
	    call qp_addi(qp, "XS-NCMSK", nlen, "Mask size")
	    # calculate the area for each region in composite mask
	    call rg_areas(pl, areas2, nareas2)
	    # and store in the qpoe file
	    call put_qparea(qp, areas2, nareas2)
	    # free the area arrays
	    call mfree(areas2, TY_INT)
	    # free up space
	    call mfree(nbuf, TY_SHORT)
	}
end

#
# DISP_QPCOMPOSITE -- display composite mask
#
procedure disp_qpcomposite(qp, ncols, nrows, x1, x2, y1, y2)

pointer	qp				# i: qpoe handle
int	ncols				# i: number of cols to display
int	nrows				# i: number of rows to display
int	x1, x2, y1, y2			# i: display limits
int	len				# l: length of composite mask
pointer	buf				# l: buffer for composite
pointer	pl				# l: pl handle for composite

int	qp_accessf()			# l: qpoe param existence
int	qp_geti()			# l: get int param
int	qp_read()			# l: read a qpoe param
int	pl_open()			# l: open a pl mask

begin
	call printf("\n\t\t\tComposite Mask\n")
	if( qp_accessf(qp, "XS-NCMSK") == YES ){
	    # get size of old composite mask
	    len = qp_geti(qp, "XS-NCMSK")
	    # allocate space for old composite mask
	    call calloc(buf, len, TY_SHORT)
	    # read the mask into the buffer
	    if( qp_read(qp, "XS-CMASK", Mems[buf], len, 1, "s") != len)
		call error(1, "wrong size for composite mask")
	    # open a null plio mask
	    pl = pl_open(NULL)
	    # load the composite
	    call pl_load(pl, buf)
	    # display the mask in zoom mode
	    call rg_pldisp(pl, ncols, nrows, x1, x2, y1, y2)
	    # close the plio mask
	    call pl_close(pl)
	    # free up space
	    call mfree(buf, TY_SHORT)
	}
	else
	    call printf("No composite mask available\n")
end
