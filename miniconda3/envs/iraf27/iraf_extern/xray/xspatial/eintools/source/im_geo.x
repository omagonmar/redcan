# $Header: /home/pros/xray/xspatial/eintools/source/RCS/im_geo.x,v 11.0 1997/11/06 16:31:34 prosb Exp $
# $Log: im_geo.x,v $
# Revision 11.0  1997/11/06 16:31:34  prosb
# General Release 2.5
#
# Revision 9.1  1997/06/11 18:03:17  prosb
# JCC(6/11/97) - change INDEF to INDEFR.
#
# Revision 9.0  1995/11/16 18:49:44  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:13:15  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       im_geo.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     geo_setup, im_rotate, im_scale
# Internal:	do_geo 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 10/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
# These routines are an interface between the geotran library and
# imio routines.  The main routines are:
# 
#    geo_setup  -- called to set up the geo structure
#    im_rotate  -- used to rotate an image file
#    im_scale   -- used to scale an image file
#
# Other image routines could be added easily, since the geotran
# routines are so general.
#
#--------------------------------------------------------------------------

include <math.h>
include <imhdr.h>
include "et_err.h"
include "../geotran/geotran.h"


#--------------------------------------------------------------------------
# Procedure:    geo_setup
#
# Purpose:      To set up the geo structure used by the geotran routines
#
# Input variables:
#               interpolant	type of interpolation to use
#		boundary	which boundary condition?
#		constant	value of constant for boundary extension
#		xsample		coordinate surface subsampling factor - x
#		ysample		coordinate surface subsampling factor - y
#		fluxconserve	flag: preserve total image flux? 
#
# Return value:
#               pointer to geo structure 
#
# Description:  This routine sets aside memory and fills in several
#		elements of the geo structure used by the main routines
#		in the geotran library.  The definitions of interpolant,
#		boundary, constant, xsample, ysample, and fluxconserve
#		are given in the help page for the task geotran.  
#		
#		Use "mfree(p_geo,TY_STRUCT)" to free the geo structure.
#--------------------------------------------------------------------------
pointer procedure geo_setup(interpolant,boundary,constant,
				xsample,ysample,fluxconserve)
char	interpolant[SZ_LINE]  # i: type of interpolation to use
char	boundary[SZ_LINE]     # i: which boundary condition?
real	constant	      # i: value of constant for boundary extension
real	xsample		# i: coordinate surface subsampling factor - x
real	ysample		# i: coordinate surface subsampling factor - y
bool	fluxconserve    # i: flag: preserve total image flux?

### LOCAL VARS ###

pointer p_geo		# pointer to geo structure
char    str[SZ_LINE]    # temporary string for strdic() routine

### EXTERNAL FUNCTION DECLARATIONS ###

int	strdic()	# returns index to word in dictionary [sys/fmtio]
int	btoi()		# returns integer equiv of boolean [sys/etc]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # set aside memory for geo structure
        #----------------------------------------------
        call malloc( p_geo, LEN_GEOSTRUCT, TY_STRUCT)

        #------------------------------------------------------
        # Fill in geo structure.  This code (basically) comes
	#    from t_geotran() in the geotran library.
        #------------------------------------------------------
        GT_GEOMODE(p_geo) = GT_NONE  # we are not using a database
        GT_INTERPOLANT(p_geo) = strdic(interpolant, str, SZ_LINE, 
            ",nearest,linear,poly3,poly5,spline3,")
        GT_BOUNDARY(p_geo) = strdic (boundary, str, SZ_LINE,
            ",constant,nearest,reflect,wrap,")
        GT_CONSTANT(p_geo) = constant
        GT_XSAMPLE(p_geo) = xsample
        GT_YSAMPLE(p_geo) = ysample
        GT_FLUXCONSERVE(p_geo) = btoi(fluxconserve)
	
        #----------------------------------------------
        # return pointer to geo structure.
        #----------------------------------------------
	return p_geo
end

#--------------------------------------------------------------------------
# Procedure:    im_rotate
#
# Purpose:      To rotate an IRAF image
#
# Input variables:
#               ip_in		input image
#		p_geo		pointer to geo structure
#		nxblock		size of blocks to do rotation in - x
#		nyblock		size of blocks to do rotation in - y
#		xin,yin		reference pixel in input image
#		xout,yout	destination of reference pixel in 
#				output image
#		rot_angle	rotation angle (in degrees)
#
# Output variables:
#		ip_out		output rotated image
#
# Description:  This routine rotates the input image to create the
#		output image ip_out by rotating counterclockwise by
#		the rotation angle.  It will also shift the reference
#		pixel from (xin,yin) to (xout,yout).  The variables
#		nxblock and nyblock determine how many pixels are
#		rotated at a time -- thus if your machine is low on
#		memory, use lower values for nxblock and nyblock.
#
#		The output image must already exist.  For instance,
#		one could use "ip_out=immap(FILENAME,NEW_COPY,ip_in)"
#		to create the new image.
#
#		The geotran library is used to calculate the rotation.
#		See help geotran to get more information on how the
#		rotation is calculated.  
#--------------------------------------------------------------------------
procedure im_rotate(ip_in,ip_out,p_geo,nxblock,nyblock,
		    xin,yin,xout,yout,rot_angle)
pointer ip_in	    # i: input image
pointer ip_out      # o: output rotated image
pointer p_geo	    # i: pointer to geo structure
int	nxblock	    # i: size of blocks to do rotation in - x
int	nyblock     # i: size of blocks to do rotation in - y
real	xin,yin     # i: reference pixel 
real  	xout,yout   # i: destination of reference pixel
real  	rot_angle   # i: rotation angle, in degrees

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # set up rotation   #JCC(97): INDEF->INDEFR
        #----------------------------------------------
        call geoset(p_geo, INDEFR, INDEFR, INDEFR, INDEFR, 1., 1., 
                INDEFI, INDEFI, xin, yin, INDEFR, INDEFR, 
		xout, yout, INDEFR, INDEFR, rot_angle, rot_angle)

        #----------------------------------------------
        # do rotation
        #----------------------------------------------
	call do_geo(ip_in,ip_out,p_geo,nxblock,nyblock)
end

#--------------------------------------------------------------------------
# Procedure:    im_scale
#
# Purpose:      To scale an IRAF image
#
# Input variables:
#               ip_in		input image
#		p_geo		pointer to geo structure
#		nxblock		size of blocks to do rotation in - x
#		nyblock		size of blocks to do rotation in - y
#		xscale, yscale  scale of final image
#
# Output variables:
#		ip_out		output rotated image
#
# Description:  This routine scales the input image to create the
#		output image ip_out by the amounts specified in
#		xscale and yscale.  The scale must be non-negative.
#		The x- and y- dimensions of the final image will be xscale 
#		and yscale times the x- and y-dimensions of the input 
#		image.  Thus if xscale=2, yscale=2, the output image
#		will be precisely twice the size of the input image.
#		
#		The output image must already exist.  For instance,
#		one could use "ip_out=immap(FILENAME,NEW_COPY,ip_in)"
#		to create the new image.
#
#		The geotran library is used to calculate the scaling.
#		See help geotran to get more information on how the
#		scaling is calculated.  
#
# Note:		It would be a waste of time to call this routine with
#		scales of 1.0 and 1.0, but this routine will not check
#		for you!
#
#		
#--------------------------------------------------------------------------
procedure im_scale(ip_in,ip_out,p_geo,nxblock,nyblock, xscale,yscale)
pointer ip_in	    # i: input image
pointer ip_out      # o: output rotated image
pointer p_geo	    # i: pointer to geo structure
int	nxblock	    # i: size of blocks to do rotation in - x
int	nyblock     # i: size of blocks to do rotation in - y
real	xscale      # i: x-factor of input scale
real    yscale	    # i: y-factor of input scale

### LOCAL VARS ###

int	n_col       # number of columns in final image
int	n_line	    # number of lines in final image

### EXTERNAL FUNCTION DECLARATIONS ###

bool	fp_equalr() # returns true if reals are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # check that scales are non-zero, so we don't
	#   divide by zero.
        #----------------------------------------------
	if (fp_equalr(xscale,0.0) || fp_equalr(yscale,0.0))
	{
	   call eprintf("IM_SCALE: xscale=%f, gscale=%f.\n")
	    call pargr(xscale)
	    call pargr(yscale)
	   call error(ET_ZERO_SCALE,
	       "Scales must be non-zero.")
	}

        #----------------------------------------------
        # calculate size of final image
        #----------------------------------------------
	n_col = nint(IM_LEN(ip_in,1)*xscale)
	n_line= nint(IM_LEN(ip_in,2)*yscale)

        #----------------------------------------------
        # set up scale   #JCC(97) - INDEF->INDEFR
        #----------------------------------------------
        call geoset(p_geo, 1.0, real(n_col), 1.0, real(n_line), 1.0, 1.0,
                INDEFI, INDEFI, INDEFR, INDEFR, INDEFR, INDEFR, INDEFR,
                INDEFR, 1.0/xscale, 1.0/yscale, 0.0, 0.0)

        #----------------------------------------------
        # do scale!
        #----------------------------------------------
	call do_geo(ip_in,ip_out,p_geo,nxblock,nyblock)
end



#--------------------------------------------------------------------------
# Procedure:    do_geo
#
# Purpose:      main routine to call geotran routines
#
# Input variables:
#               ip_in		input image
#		p_geo		pointer to geo structure
#		nxblock		size of blocks to do rotation in - x
#		nyblock		size of blocks to do rotation in - y
#
# Output variables:
#		ip_out		output rotated image
#
# Description:  This routine calls the appropriate geotran routines
#		to perform the appropriate transformation.  The
#		programmer must call geoset() (in geotran library)
#		before calling this routine.
#
# Note:		This code comes just about straight from the t_geotran()
#		routine.  It does not yet modify the WCS information.
#		We may want to add this later.
#--------------------------------------------------------------------------
procedure do_geo(ip_in,ip_out,p_geo,nxblock,nyblock)
pointer ip_in	    # i: input image
pointer ip_out      # o: output rotated image
pointer p_geo	    # i: pointer to geo structure
int	nxblock	    # i: size of blocks to do rotation in - x
int	nyblock     # i: size of blocks to do rotation in - y

### LOCAL VARS ###

pointer sx1,sy1,sx2,sy2  # coordinate surfaces

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # set up coordinate surfaces
        #----------------------------------------------
        call geoformat (ip_in , ip_out, p_geo, sx1, sy1, sx2, sy2)

        #----------------------------------------------
        # transform the image (calling appropriate
	#    geotran routine)
        #----------------------------------------------
        if (IM_LEN(ip_out,1) <= nxblock && IM_LEN(ip_out,2) <= nyblock)
	{
           if (GT_XSAMPLE(p_geo) > 1.0 || GT_YSAMPLE(p_geo) > 1.0)
           {
	      call geosimtran (ip_in, ip_out, p_geo, sx1, sy1, sx2, sy2,
                        int (IM_LEN(ip_out,1)), int (IM_LEN(ip_out,2)))
           }
	   else
	   {
              call geoimtran (ip_in, ip_out, p_geo, sx1, sy1, sx2, sy2,
                        int (IM_LEN(ip_out,1)), int (IM_LEN(ip_out,2)))
           }
        } 
	else 
	{
           if (GT_XSAMPLE(p_geo) > 1.0 || GT_YSAMPLE(p_geo) > 1.0)
	   {
               call geostran (ip_in, ip_out, p_geo, sx1, sy1, sx2, sy2,
				 nxblock,nyblock)
           }
	   else
           {
	       call geotran (ip_in, ip_out, p_geo, sx1, sy1, sx2, sy2, 
				nxblock, nyblock)
	   }
	}

        #----------------------------------------------
        # free memory
        #----------------------------------------------
        call gsfree(sx1)
        call gsfree(sx2)
        call gsfree(sy1)
        call gsfree(sy2)
end


