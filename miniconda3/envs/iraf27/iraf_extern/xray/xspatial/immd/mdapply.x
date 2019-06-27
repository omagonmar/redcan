#$Header: /home/pros/xray/xspatial/immd/RCS/mdapply.x,v 11.2 2000/01/04 22:28:48 prosb Exp $
#$Log: mdapply.x,v $
#Revision 11.2  2000/01/04 22:28:48  prosb
# copy from pros_2.5 (or pros_2.5_p1)
#
#Revision 9.0  1995/11/16  18:52:18  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:14:57  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:54  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:26  prosb
#General Release 2.2
#
#Revision 5.1  93/04/07  13:36:00  orszak
#jso - changes to add lorentzian model
#
#Revision 5.0  92/10/29  21:34:10  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:41:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:08  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:29  pros
#General Release 1.0
#
#
# Module:	MDAPPLY.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	routine to apply model function(s) to a data buffer
# External:	md_apply()
# Local:
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} M.VanHilst	28 Nov 1988 	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#


include "mdset.h"


#
# Function:	md_apply
# Purpose:	given the parameter structure, apply data to model buffer
# Parameters:	See argument declarations
# Returns:	1/sum of function over defined area
# Uses:		md_boxcar(), md_expo(), md_file(), md_gauss(), md_hipass(),
#		md_impulse(), md_king(), md_power(), md_tophat(), md_lorentz()
# Pre-cond:	model(s) must be completely defined in func structure
# Post-cond:	model data is added to mbuf
# Exceptions:
# Method:	Add model data as described in function structure(s).  Models
#		may be chained in a link list, in which case all models are
#		applied to the buffer.
# Notes:	Buffer can be complex or real (as indicated by flag).  Buffer
#		is added to, but may be cleared first if clear flag is set.
#
procedure md_apply ( mbuf, width, height, mdfunclist, cmplx, clear )

real	mbuf[ARB]	# i: 2D model data buffer
int	width, height	# i: dimensions of model buffer
pointer mdfunclist	# i: link list of model parameter structures
int	cmplx		# i: flag if buffer is complex data(1), else real(0)
int	clear		# i: flag to request buffer to be cleared(1), else(0)

pointer mdfunc		# l: ptr to structure of model parameters

begin
	# check structure pointer
	if( mdfunclist == 0 )
	    call error (1, "mda - missing model structure")
	# clear buffer if requested
	if( clear == 1 ) {
	    if( cmplx == 0 )
		call aclrr (mbuf, width * height)
	    else
		call aclrx (mbuf, width * height)
	}
	mdfunc = mdfunclist
	while( mdfunc != 0 ) {
	    # add model data
	    switch( MD_FUNCTION(mdfunc) ) {
	    case MDBOXCAR:
		call md_boxcar (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_WIDTH(mdfunc), MD_HEIGHT(mdfunc),
		     MD_VAL(mdfunc), cmplx)
	    case MDEXPO:
		call md_expo (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_RADIUS(mdfunc), MD_VAL(mdfunc), cmplx)
	    case MDFILE:
		call md_file (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_FILENAME(mdfunc), MD_VAL(mdfunc), cmplx)
	    case MDGAUSS:
		call md_gauss (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_SIGMA(mdfunc), MD_VAL(mdfunc), cmplx)
	    case MDHIPASS:
		call md_hipass (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_RADIUS(mdfunc), MD_VAL(mdfunc), cmplx)
	    case MDIMPULS:
		call md_impulse (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_VAL(mdfunc), cmplx)
	    case MDKFILE:
		call md_file (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_FILENAME(mdfunc), MD_VAL(mdfunc), cmplx)
	    case MDFUNC:
		call my_model (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_RADIUS(mdfunc), MD_POWER(mdfunc),
		     MD_VAL(mdfunc), cmplx)
	    case MDKING:
		call md_king (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_RADIUS(mdfunc), MD_POWER(mdfunc),
		     MD_VAL(mdfunc), cmplx)
	    case MDKFUNC:
		call my_kmodel (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_RADIUS(mdfunc), MD_POWER(mdfunc),
		     MD_VAL(mdfunc), cmplx)
	    case MDLOPASS:
		call md_tophat (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_RADIUS(mdfunc), MD_VAL(mdfunc), cmplx)
	    case MDPOWER:
		call md_power (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_RADIUS(mdfunc), MD_POWER(mdfunc),
		     MD_VAL(mdfunc), cmplx)
	    case MDTOPHAT:
		call md_tophat (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_RADIUS(mdfunc), MD_VAL(mdfunc), cmplx)
	    case MDLORENT:
		call md_lorentz (mbuf, width, height,
		     MD_XCEN(mdfunc), MD_YCEN(mdfunc),
		     MD_SIGMA(mdfunc), MD_VAL(mdfunc), cmplx)
	    default:
		call printf ("WARNING: unknown model type\n")
	    }
	    mdfunc = MD_NEXT(mdfunc)
	}
end
