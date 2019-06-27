#$Header: /home/pros/xray/xspatial/immd/RCS/mdinit.x,v 11.2 2000/01/04 22:28:42 prosb Exp $
#$Log: mdinit.x,v $
#Revision 11.2  2000/01/04 22:28:42  prosb
# copy from pros_2.5 (or pros_2.5_p1)
#
#Revision 9.0  1995/11/16  18:52:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:14  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:10  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:16:34  mo
#MC	remove erronous 'int procedure' declaration.
#
#Revision 6.0  93/05/24  16:20:48  prosb
#General Release 2.2
#
#Revision 5.1  93/04/07  13:36:29  orszak
#jso - changes to add lorentzian model
#
#Revision 5.0  92/10/29  21:34:26  prosb
#General Release 2.1
#
#Revision 4.1  92/10/01  11:20:15  prosb
#jso - added some new lines.
#
#Revision 4.0  92/04/27  14:42:12  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:13  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:51  pros
#General Release 1.0
#
#
# Module:       MDINIT.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      initialze model parameter structures.
# External:     pointer md_salloc(), md_link(), int md_getparams(), md_place(),
#		mddb()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M.VanHilst  initial version 	28 November 1988
#		{1} D.Meleedy	md_getparams more verbose  15 November 1990
#               {n} <who> -- <does what> -- <when>
#

include <error.h>
include "mdset.h"


######################################################################
#
# md_alloc
#
# Salloc a new model parameter structure, clear it, and set its type
# 
# Input: code for model type
# Returns: pointer to new model parameter structure
#
######################################################################

pointer procedure md_alloc ( functype )

int	functype	# i: code for type of model function

pointer mdfunc		# o: pointer to new function parameter structure

begin
	call malloc (mdfunc, MD_LEN, TY_STRUCT)
	call aclri (Memi[mdfunc], MD_LEN)
	MD_FUNCTION(mdfunc) = functype
	return(mdfunc)
end


######################################################################
#
# md_link
#
# Add a model parameter structure to the end of a link list.
# If the list is empty, initialize the list to the given structure.
#
# Input: pointer to first (or any) model parameter structure in list
# Input: pointer to new parameter structure (or list) to be added to list
#
######################################################################

procedure md_link ( mdfunclist, mdfunc )

pointer mdfunclist	# i: pointer to function parameter structure list
pointer mdfunc		# i: pointer to function parameter structure

pointer mdlast		# l: pointer to last structure in link list

begin
	if( mdfunclist == 0 ) {
	    mdfunclist = mdfunc
	    return
	}
	mdlast = mdfunclist
	while( MD_NEXT(mdlast) != 0 ) {
	    mdlast = MD_NEXT(mdlast)
	}
	MD_NEXT(mdlast) = mdfunc
end


######################################################################
#
# md_getparams
#
# Given the parameter structure with function type set:
# fill in function parameters to describe the shape of the function.
#
# Models assign values for pixels based on position relative to a center.
#
# Input: pointer to model parameter structure, function type must be set
# Return: -1 if function type unknown
#	   0 if function radius is zero or negative
#	   1 if parameters are acceptable
#
######################################################################

int procedure md_getparams ( mdfunc )

pointer mdfunc		# i: structure for model parameters

int	isfile		# l: flag that function is file (has no radius)
real	clgetr()	# get real param from cl or param file
int	imaccess()

begin
	# check structure pointer
	if( mdfunc == 0 )
	    call error (1, "mdg - missing model structure")
	isfile = 0
	# get type specific model function parameters
	switch( MD_FUNCTION(mdfunc) ) {
	case MDBOXCAR:
	    MD_WIDTH(mdfunc) = clgetr("arg1")
	    MD_HEIGHT(mdfunc) = clgetr("arg2")
	    call printf ("Using boxcar function with width %7.2f and height %7.2f image pixels.\n")
	    call pargr (MD_WIDTH(mdfunc))
	    call pargr (MD_HEIGHT(mdfunc))
	case MDEXPO:
	    MD_RADIUS(mdfunc) = clgetr("arg1")
	    call printf ("Using expo function with a radius of %7.2f image pixels.\n")
	    call pargr (MD_RADIUS(mdfunc))
	case MDFILE:
	    call clgstr ("model_file", MD_FILENAME(mdfunc), MD_SZFNAME)
	    if( imaccess(MD_FILENAME(mdfunc), 0) == YES )
		isfile = 1
	    else
		isfile = -1
	case MDFUNC:
	    MD_RADIUS(mdfunc) = clgetr("arg1")
	    MD_POWER(mdfunc) = clgetr("arg2")
	    call printf ("Using a user for a function with %7.2f and %7.2f as arguments to the function.\n")
	    call pargr (MD_RADIUS(mdfunc))
	    call pargr (MD_POWER(mdfunc))
	case MDGAUSS:
	    MD_SIGMA(mdfunc) = clgetr("arg1")
	    call printf ("Using the Gauss function with %7.2f = sigma.\n")
	    call pargr (MD_SIGMA(mdfunc))
	case MDHIPASS:
	    MD_RADIUS(mdfunc) = clgetr("arg1")
	    call printf ("Using hipass filter applied in k space with radius %7.2f image pixels.\n")
	    call pargr(MD_RADIUS(mdfunc))
	case MDIMPULS:
	    MD_RADIUS(mdfunc) = 0.5
	    call printf ("Point with no extent.")
	case MDKFILE:
	    call clgstr ("model_file", MD_FILENAME(mdfunc), MD_SZFNAME)
	    if( imaccess(MD_FILENAME(mdfunc), 0) == YES )
		isfile = 1
	    else
		isfile = -1
	case MDKFUNC:
	    MD_RADIUS(mdfunc) = clgetr("arg1")
	    MD_POWER(mdfunc) = clgetr("arg2")
            call printf ("Using a k space call user function with %7.2f and %7.2f as arguments to the function.\n")
            call pargr (MD_RADIUS(mdfunc))
            call pargr (MD_POWER(mdfunc))
	case MDKING:
	    MD_RADIUS(mdfunc) = clgetr("arg1")
	    MD_POWER(mdfunc) = clgetr("arg2")
	    call printf ("Using a king function with radius %7.2f and power %7.2f image pixels.\n")
	    call pargr(MD_RADIUS(mdfunc))
	    call pargr(MD_POWER(mdfunc))
	case MDLOPASS:
	    MD_RADIUS(mdfunc) = clgetr("arg1")
	    call printf ("Using a lopass filter applied in k space with a radius %7.2f image pixels.\n")
	    call pargr(MD_RADIUS(mdfunc))
	case MDPOWER:
	    MD_RADIUS(mdfunc) = clgetr("arg1")
	    MD_POWER(mdfunc) = clgetr("arg2")
	    call printf ("Using a power function with radius %7.2f and power %7.2f image pixels.\n")
            call pargr(MD_RADIUS(mdfunc))
            call pargr(MD_POWER(mdfunc))

	case MDTOPHAT:
	    MD_RADIUS(mdfunc) = clgetr("arg1")
	    call printf ("Using tophat functino with radius %7.2f image pixels.\n")
	    call pargr (MD_RADIUS(mdfunc))
	case MDLORENT:
	    MD_SIGMA(mdfunc) = clgetr("arg1")
	    call printf ("Using the Lorentzian function with %7.2f = gamma.\n")
	    call pargr (MD_SIGMA(mdfunc))
	default:
	    call printf ("Unknown function type\n")
	    return(-1)
	}
	if( isfile == -1 ) {
	    call error (0, "model file not found")
	    return(0)
	} if( (isfile == 0) && (MD_RADIUS(mdfunc) <= 0) ) {
	    return(0)
	} else
	    return(1)
end


######################################################################
#
# md_place
#
# Install location and magnitude parameters in model parameter structure
# 
# Input: pointer to model parameter structure
# Input: real coordinates (x, y) to be used as center of model function
# Input: real value to scale model function (pix = pix + (VAL * f(x,y))
#
######################################################################

procedure md_place ( mdfunc, xcen, ycen, val )

pointer mdfunc		# i: structure for model parameters
real	xcen, ycen	# i: coordinates for center of model
real	val		# i: val to apply to model function (val*f(x,y))

begin
	# check structure pointer
	if( mdfunc == 0 )
	    call error (1, "mdp - missing model structure")
	# make assignments
	MD_XCEN(mdfunc) = xcen
	MD_YCEN(mdfunc) = ycen
	MD_VAL(mdfunc) = val
end



#int procedure mddb ( mdfunc )
procedure mddb ( mdfunc )
pointer mdfunc
pointer func
begin
	func = mdfunc
	while( func != 0 ) {
	    call printf("Func %d, xcen %f, ycen %f, val %f\n")
	     call pargi (MD_FUNCTION(func))
	     call pargr (MD_XCEN(func))
	     call pargr (MD_YCEN(func))
	     call pargr (MD_VAL(func))
	    if( MD_FUNCTION(func) != MDFILE ) {
	  	call printf(" rad: %f, pow: %f \n")
		 call pargr (MD_RADIUS(func))
		 call pargr (MD_POWER(func))
	    } else {
		call printf(" file: %s\n")
		 call pargstr (MD_FILENAME(func))
	    }
	    func = MD_NEXT(func)
	}
end
