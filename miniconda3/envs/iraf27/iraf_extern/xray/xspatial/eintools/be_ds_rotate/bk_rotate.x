# $Header: /home/pros/xray/xspatial/eintools/be_ds_rotate/RCS/bk_rotate.x,v 11.0 1997/11/06 16:31:18 prosb Exp $
# $Log: bk_rotate.x,v $
# Revision 11.0  1997/11/06 16:31:18  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:02  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/31  10:41:39  prosb
#Initial revision
#
#
#
#--------------------------------------------------------------------------
# Module:       bk_rotate.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     bk_geo_setup, rbkmap_setup, mk_rbkmap
# Internal:	bk_rotate
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
#  Routines which rotate maps to create a background map.
#

include "../tables/bkfac.h"
include "../source/et_err.h"
include <imhdr.h>
	
#--------------------------------------------------------------------------
# Procedure:    bk_geo_setup
#
# Purpose:      Read in parameters to set up GEO structure
#
# Output Variables:
#		nxblock, nyblock   size of blocks to do rot/scaling in
#
# Return Value:
#		p_geo		pointer to GEO structure
#
# Description:  The geotran code requires several parameters; this
#		routine will load these parameters from the CL and fill
#		in the GEO structure.  (See geo_setup.)  Two parameters
#		are also needed which, for some reason, weren't included
#		in the GEO data structure.  These values, nxblock and
#		nyblock, must be passed back separately.
#
#		Space is set aside for p_geo and needs to be cleared
#		after it is used.  (Use "mfree(p_geo,TY_STRUCT)".)
#--------------------------------------------------------------------------

pointer procedure bk_geo_setup(nxblock,nyblock)
int	nxblock,nyblock	# o: size of blocks to do rotation/scaling

### LOCAL VARS ###

pointer p_geo		# returning GEO structure
real	constant	# parameter "constant"
pointer p_interpolant	# "interpolant" parameter
pointer p_boundary	# "boundary" parameter
real	xsample,ysample # "xsample,ysample" parameters
pointer sp		# stack pointer

### EXTERNAL FUNCTION DECLARATIONS ###

pointer geo_setup() # Returns pointer to GEO struct [source/im_geo.x]
int     clgeti()  # returns integer CL parameter [sys/clio]
real	clgetr()  # returns real CL parameter [sys/clio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # allocate space on stack & set aside memory
        #   for strings
        #----------------------------------------------
	call smark(sp)
	call salloc( p_interpolant, SZ_LINE, TY_CHAR)
	call salloc( p_boundary, SZ_LINE, TY_CHAR)

        #----------------------------------------------
	# load in geo variables
        #----------------------------------------------
        call clgstr("interpolant",Memc[p_interpolant],SZ_LINE)
        call clgstr("boundary",Memc[p_boundary],SZ_LINE)
	constant=clgetr("constant")
        xsample = clgetr ("xsample")
        ysample = clgetr ("ysample")
        nxblock = clgeti ("nxblock")
        nyblock = clgeti ("nyblock")


        #----------------------------------------------
	# Fill in geo structure.  The interpolant &
	# boundary strings are no longer needed after
	# this.
        #----------------------------------------------
	p_geo = geo_setup(Memc[p_interpolant],Memc[p_boundary],
			constant,xsample,ysample,true)

        #----------------------------------------------
	# Free memory
        #----------------------------------------------
	call sfree(sp)

        #----------------------------------------------
	# Return GEO pointer.
        #----------------------------------------------
	return p_geo
end

#--------------------------------------------------------------------------
# Procedure:    rbkmap_setup
#
# Purpose:      Set up initial values of rotated bkgd map
#
# Input Variables:
#               ip_be		bright Earth image
#		ip_rbkmap	rot. bkgd map image
#		display		display level
#
# Description:  This routine should be called after the bkgd map has
#		been opened as a new file with immap.  It will fill
#		in the pixel type, dimensions, length of the axes, and
#		zero out the image.  It reads in the axes length and
#		the pixtype from the bright Earth map.
#
# Note:		It is possible that creating a new image with immap will
#		automatically zero out the image...but we just want to
#		be sure!
#--------------------------------------------------------------------------
procedure rbkmap_setup(ip_be,ip_rbkmap,display)
pointer ip_be		# i: bright Earth map
pointer ip_rbkmap	# io: bkgd map
int	display		# i: display level
begin
        #----------------------------------------------
	# set up initial values of image
        #----------------------------------------------
	IM_PIXTYPE(ip_rbkmap)=IM_PIXTYPE(ip_be)
	IM_NDIM(ip_rbkmap)=2
	IM_LEN(ip_rbkmap,1)=IM_LEN(ip_be,1)
	IM_LEN(ip_rbkmap,2)=IM_LEN(ip_be,2)

        #----------------------------------------------
	# zero out image
        #----------------------------------------------
	if (display>2)
	{
	    call printf("Clearing final image...\n")
 	    call flush(STDOUT)	
	}	
	call im_zero_gen(ip_rbkmap)
end

#--------------------------------------------------------------------------
# Procedure:    mk_rbkmap
#
# Purpose:      This routine will create the rotated bkgd map from
#		the BE & DS maps!
#
# Input Variables:
#               ip_be           bright Earth image
#               ip_ds           deep survey image
#		tp_bkf		BKFAC table
#		col_ptr		column pointers for BKFAC
#		p_bkf_info	pointer to BKFAC info [see gt_info.x]
#		n_bkfac		number of BKFAC rows
#		mw_be		MWCS descriptor for bright Earth
#		mw_qp		MWCS descriptor for QPOE
#		p_geo		pointer to geo structure
#		nxblock,nyblock size of blocks to do rotation in
#               ip_rbkmap       rot. bkgd map image [to be filled in]
#               display         display level
#
# Description:  After all the setup...we can now create the background
#		map.  Generally, the background map is the weighted
#		sum of rotated bright Earth and deep survey maps.  The
#		background factors (BKFAC) table contains several rows,
#		each with the following data:
#
#		   BE_FAC:  weight to apply to bright Earth map
#		   DS_FAC:  weight to apply to deep survey map
#		   wcs info: describes how to rotate the be & ds map.
#
#		The wcs information describes a map from PROS detector
#		coordinates to sky coordinates:
#		   RCRPX1,RCRPX2: PROS detector reference point
#				  [this value doesn't change for each row]
#		   RCRVL1,RCRVL2: sky coordinates corresponding to
#				  reference points  [changes]
#		   RCROT2: rotation angle (clockwise, if x&y increase
#				  to right and up)
#
#		Our algorithm is as follows:
#
#		* Find reference points in BE & DS maps:
#
#		    Because the BE & DS maps may not be PROS detector
#		  coordinates [in fact, usually they are blocked], we
#		  must transform RCRPX1 and RCRPX2 into BE coords.
#		  We can use the WCS transformation in the BE image
#		  to do this.  (This WCS maps from BE coords into
#		  PROS detector coords.)  Call these xin and yin.
#
#		* For each row of the BKFAC table, do the following.
#
#		  * Create weighted sum of bright Earth & deep survey
#		    maps; call it ip_sum.
#
#		  * Use QPOE WCS info to map RCRVL1, RCRVL2 from sky 
#		    coordinates into image coordinates.  (Call these
#		    im_tang_x and im_tang_y.) 
#
#		  * Furthermore, use BE WCS to convert image coords
#		    back into BE coords; call these xout and yout.
#
#		  * Rotate ip_sum by RCROT2 and translate from xin,yin
#		    to xout,yout.
#
#		  * Add rotated image to ip_rbkmap
#
#		We must start with the ip_rbkmap filled with zero, of
#		course.  Note that through this algorithm we are using
#		three different WCS maps.  Yow!
#
# Note:		We must create two temporary image files; these must
#		be deleted at the end of the routine.
#--------------------------------------------------------------------------
procedure mk_rbkmap(ip_be,ip_ds,tp_bkf,col_ptr,p_bkf_info,n_bkfac,
			mw_be,mw_qp,p_geo,nxblock,nyblock,
			ip_rbkmap,display)
pointer ip_be		# i: bright Earth image
pointer ip_ds		# i: deep survey image
pointer tp_bkf		# i: BKFAC table
pointer col_ptr[ARB]	# i: column pointers for BKFAC
pointer p_bkf_info	# i: pointer to BKFAC info
int	n_bkfac		# i: number of BKFAC rows
pointer mw_be		# i: MWCS descriptor for bright Earth
pointer mw_qp		# i: MWCS descriptor for QPOE
pointer p_geo		# i: pointer to geo structure
int	nxblock,nyblock # i: size of blocks to do rotation in
pointer ip_rbkmap	# io: rot. bkgd map image [to be filled in]
int	display		# i: display level

### LOCAL VARS ###

int	i_bkfac		# current BKFAC row
pointer p_bkfac_row	# pointer to data in BKFAC row
pointer	ct_qp		# CTRAN descriptor: WORLD->LOGICAL for QPOE
pointer ct_be		# CTRAN descriptor: WORLD->LOGICAL for bright Earth
pointer p_sum_name	# name of temporary image file for summed image
pointer ip_sum		# temp summed image
pointer p_rsum_name	# name of temporary image file for rotated image
pointer ip_rsum		# temp rotated image
double	rcrpx1,rcrpx2   # RCRPX1,RCRPX2 from BKFAC table
pointer sp		# stack pointer
double	xin,yin		# reference points in BE map

### EXTERNAL FUNCTION DECLARATIONS ###

pointer immap()     # returns pointer to image [sys/imio]
pointer mw_sctran() # returns CTRAN descriptor [sys/mwcs]
double	tbhgtd()    # returns double table header [tables]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # allocate space on the stack for the strings
        #----------------------------------------------
        call smark(sp)
        call salloc( p_sum_name, SZ_PATHNAME, TY_CHAR)
        call salloc( p_rsum_name, SZ_PATHNAME, TY_CHAR)
	call salloc( p_bkfac_row, SZ_BKFAC, TY_STRUCT)

        #----------------------------------------------
	# create two more temporary images with temporary names
        #----------------------------------------------
        call mktemp("sum",Memc[p_sum_name],SZ_PATHNAME)
        call mktemp("rsum",Memc[p_rsum_name],SZ_PATHNAME)
        ip_sum= immap(Memc[p_sum_name],NEW_COPY, ip_be)
        ip_rsum=immap(Memc[p_rsum_name],NEW_COPY, ip_be)

        #----------------------------------------------
	# Calculate CTRAN descriptors
        #----------------------------------------------
	ct_qp=mw_sctran(mw_qp,"world","logical",3B)
	ct_be=mw_sctran(mw_be,"world","logical",3B)

        #----------------------------------------------
	# calculate xin, yin
        #----------------------------------------------
	rcrpx1=tbhgtd(tp_bkf,BK_RCRPX1)
	rcrpx2=tbhgtd(tp_bkf,BK_RCRPX2)
	call mw_c2trand(ct_be,rcrpx1,rcrpx2,xin,yin)

        #----------------------------------------------
	# Loop through BKFAC table
        #----------------------------------------------
	do i_bkfac=1,n_bkfac
	{
	    if (display>0)
	    {
	      	call printf("Rotating image # %d...\n")
	       	 call pargi(i_bkfac)
	      	call flush(STDOUT)
	    }

            #----------------------------------------------
	    # Get row's worth of BKFAC data
            #----------------------------------------------
	    call gt_get_row(tp_bkf,p_bkf_info,col_ptr,i_bkfac,
				true,p_bkfac_row) 

	    if (display>4)
	    {
	      	call printf("\nBright earth factor=%g, deep survey factor=%g.\n")
	       	 call pargr(BK_BEFAC(p_bkfac_row))
	       	 call pargr(BK_DSFAC(p_bkfac_row))
	    }

            #----------------------------------------------
	    # ip_sum = BEFAC * bemap + DSFAC * dsmap
            #----------------------------------------------
	    call im_sum_gen(ip_be,dble(BK_BEFAC(p_bkfac_row)),
			   ip_ds,dble(BK_DSFAC(p_bkfac_row)),ip_sum)

            #----------------------------------------------
	    # Rotate image
            #----------------------------------------------
	    call bk_rotate(ip_sum,p_bkfac_row,p_geo,nxblock,nyblock,
			xin,yin,ct_qp,ct_be,ip_rsum,display)

            #----------------------------------------------
	    # Add rotated image cumulatively to rbkmap
            #----------------------------------------------
	    call im_cumul_gen(ip_rsum,ip_rbkmap)
	}

        #----------------------------------------------
	# close and delete temporary image files
        #----------------------------------------------
        call imunmap(ip_sum)
        call imunmap(ip_rsum)
        call imdelete(Memc[p_rsum_name])
        call imdelete(Memc[p_sum_name])

        #----------------------------------------------
	# Free memory
        #----------------------------------------------
	call mw_ctfree(ct_qp)
	call mw_ctfree(ct_be)

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end

#--------------------------------------------------------------------------
# Procedure:    bk_rotate
#
# Purpose:      Rotate summed image into rotated summed image
#
# Input variables:
#		ip_sum		summed image to rotate
#		p_bkfac_row	row of BKFAC data
#               p_geo           pointer to geo structure
#               nxblock,nyblock size of blocks to do rotation in
#		xin,yin		summed image reference points
#		ct_qp		CTRAN descriptor: WORLD->LOGICAL for QPOE
#		ct_be		CTRAN descriptor: WORLD->LOGICAL for BE
#		ip_rsum		output image (to fill in)
#               display         display level
#
# Description:  This routine performs the rotation described in the
#		above routine, mk_rbkmap.  It will use the BE & QPOE
#		WCS information (in the CTRAN maps) to find the
#		final point which the reference point should be mapped
#		to; then it rotates and translates into ip_rsum.
#
# Note:		The GEO routines require "real" (as opposed to double-
#		precision) values; we may lose some minor precision here.
#--------------------------------------------------------------------------
procedure bk_rotate(ip_sum,p_bkfac_row,p_geo,nxblock,nyblock,
				xin,yin,ct_qp,ct_be,ip_rsum,display)
pointer ip_sum          # i: temp summed image
pointer p_bkfac_row	# i: pointer to data in BKFAC row
pointer p_geo           # i: pointer to geo structure
int     nxblock,nyblock # i: size of blocks to do rotation in
double	xin,yin		# i: reference point in input image
pointer ct_qp		# i: CTRAN descriptor: WORLD->LOGICAL for QPOE
pointer ct_be		# i: CTRAN descriptor: WORLD->LOGICAL for BE
pointer ip_rsum		# io: output rotated summed image
int	display		# i: display level

### LOCAL VARS ###

double	im_tang_x, im_tang_y # image coords of final points
double	xout,yout	     # input image coords of final points

begin
        #----------------------------------------------
	# Calculate im_tang_x,im_tang_y
        #----------------------------------------------
	call mw_c2trand(ct_qp,double(BK_RCRVL1(p_bkfac_row)),
			   double(BK_RCRVL2(p_bkfac_row)),
			im_tang_x,im_tang_y)

        #----------------------------------------------
	# Calculate xout, yout
        #----------------------------------------------
	call mw_c2trand(ct_be,im_tang_x,im_tang_y,xout,yout)

	if (display>4)
	{
	   call printf("\nRA & DEC %f,%f becomes pixels %.2f,%.2f.\n")
	    call pargr(BK_RCRVL1(p_bkfac_row))
	    call pargr(BK_RCRVL2(p_bkfac_row))
	    call pargd(im_tang_x)
	    call pargd(im_tang_y)
	   call printf("xin=%.2f,%.2f  xout=%.2f,%.2f  rot=%.3f.\n")
	    call pargr(real(xin))
	    call pargr(real(yin))
	    call pargr(real(xout))
	    call pargr(real(yout))
	    call pargr(real(BK_RCROT2(p_bkfac_row)))
	   call flush(STDOUT)
	}

        #----------------------------------------------
	# Do rotation!
        #----------------------------------------------
	call im_rotate(ip_sum,ip_rsum,p_geo,nxblock,nyblock,
			real(xin),real(xin),real(xout),real(xout),
			real(BK_RCROT2(p_bkfac_row)))
end
