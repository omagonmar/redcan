# $Header: /home/pros/xray/xspatial/eintools/be_ds_rotate/RCS/bk_tools.x,v 11.0 1997/11/06 16:31:19 prosb Exp $
# $Log: bk_tools.x,v $
# Revision 11.0  1997/11/06 16:31:19  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:04  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/31  10:41:46  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       bk_tools.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     be_ds_rotate
# Internal:	bk_check_scale,bk_check_images,bk_check_pi,
#		bk_check_rest, scale_rbkmap, bk_hdr, bk_hist
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include "../tables/bkfac.h"
include "../source/et_err.h"
include "../source/band.h"
include <qpoe.h>
include <imhdr.h>
include <mach.h>
	
#--------------------------------------------------------------------------
# Procedure:    be_ds_rotate()
#
# Purpose:      Rotate bright Earth and deep survey maps via BKFAC table
#
# Input variables:
#               qpoe_name       input qpoe file name
#               bkfac_name      input background factors table
#		rbkmap_name	output background map
#		final_rbkmap_name  name of final background map [for history]
#               be_name         name of bright Earth map
#               ds_name         name of deep survey map
#		xscale		final x-scale of map
#		yscale		final y-scale of map
#		use_original_data  using original (lvl 1) data?
#		band		which band? [see ../source/band.h]
#               pi_range        PI range (e.g. "2:4" or "7:8,10:12")
#               br_edge_reg     region for be/ds to remove bright edge
#               display         display level
#
# Description:  This is the main routine which creates the rotated
#		background map from the background factors table.
#		It will do the following:
#
#		* verify that input images are "reasonable"
#		* create unscaled background map by rotating BE &
#		  DS maps and summing them up via the entries in
#		  the BKFAC table (see bk_rotate.x for details)
#		* scale the final map to the same degrees-per-pixel
#		  as the input image file, multiplied by xscale & yscale
#		* add header and history information to the final
#		  rotated background map
#
#		We are using the geotran library to perform the 
#		actual interpolated rotations and scaling.  The
#		routine bk_geo_setup will read in more parameters
#		("interpolant", "boundary", etc.) and set up the
#		geo structure and return a pointer to this structure.
#
#		The main header information for the final image will
#		come from the input qpoe file.
#		(This includes the WCS information.)
#
#		If "use_original_data" is true, then the user is
#		recreating an original bkgd map using level one 
#		weights and maps.  This is only relevent for
#		checking various header values.
#
#		We use "mk_rbkmap()" to create an unscaled rotated
#		background map; this is a temporary file we must
#		create.  This map is then passed to scale_rbkmap()
#		which performs the final scaling on the temporary
#		file.
#--------------------------------------------------------------------------

procedure be_ds_rotate(qpoe_name,bkfac_name,rbkmap_name,final_rbkmap_name,
		be_name,ds_name,xscale,yscale,use_original_data,band,
		pi_range,br_edge_reg,display)
char 	bkfac_name[ARB]  # i: background factors table
char	qpoe_name[ARB]	 # i: qpoe file
char 	rbkmap_name[ARB] # i: name of output rotated background map
char 	final_rbkmap_name[ARB] # i: name of final bkgd map [for history]
char 	be_name[ARB]	 # i: pathname of BE map
char 	ds_name[ARB]	 # i: pathname of DS map
double	xscale		 # i: how much to scale final bkgd map [x]
double	yscale		 # i: how much to scale final bkgd map [y]
bool	use_original_data # i: are we recreating original bkgd map?
int	band		 # i: which band (used for reading BKFAC table)  
char	pi_range[ARB]    # i: check that this matches the other pi ranges!
char    br_edge_reg[ARB] # i: region for be/ds to remove bright edge
int	display		 # i: display level (0-5)

### LOCAL VARS ###

pointer ip_be		 # image pointer for BE map
pointer ip_ds		 # image pointer for DS map
pointer ip_rbkmap	 # image pointer for final rotated bkgd map
pointer ip_unscaled_rbkmap # image pointer for unscaled bkgd map
pointer mw_qp		 # MWCS descriptor [for qpoe]
pointer mw_be		 # MWCS descriptor [for bright Earth map]
pointer	qp		 # qpoe
pointer	qphead		 # qpoe header!
pointer sp		 # stack pointer
pointer p_unscaled_rbkmap_name # temporary unscaled bkgd map name

## table info:

int	n_bkf		 # number of BKFAC rows
pointer p_bkf_info	 # pointer to BKFAC info [see gt_info.x]
pointer	col_ptr[N_COL_BKFAC] # column pointers for BKFAC
pointer tp_bkf		 # table to BKFAC

### geo structure info:

int	nxblock		 # size of blocks to do rotation/scaling in - x
int	nyblock	 	 # size of blocks to do rotation/scaling in - y
pointer p_geo		 # pointer to geo structure

### EXTERNAL FUNCTION DECLARATIONS ###

pointer bk_geo_setup() # returns pointer to geo structure [bk_rotate.x]
int     gt_open()     # returns number of rows in table [../tables/gt_file.x]
pointer immap()       # returns pointer to image [sys/imio]
pointer qp_loadwcs()    # pointer to MWCS descriptor [sys/qpoe]
pointer mw_openim()     # pointer to MWCS descriptor [sys/imio]
pointer qp_open()       # returns pointer to QPOE [sys/qpoe]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # allocate space on the stack for the strings
        #----------------------------------------------
        call smark(sp)
        call salloc( p_unscaled_rbkmap_name, SZ_PATHNAME, TY_CHAR)

        #----------------------------------------------
	# create temporary background file 
        #----------------------------------------------
	call mktemp("bkmap",Memc[p_unscaled_rbkmap_name],SZ_PATHNAME)

        #----------------------------------------------
	# open qpoe and read header
        #----------------------------------------------
        qp=qp_open(qpoe_name,READ_ONLY,0)
        call get_qphead(qp,qphead)

        #----------------------------------------------
	# open images
        #----------------------------------------------
        ip_unscaled_rbkmap=immap(Memc[p_unscaled_rbkmap_name],NEW_IMAGE,0)
        ip_be=immap(be_name,READ_ONLY, 0)
        ip_ds=immap(ds_name,READ_ONLY, 0)

        #----------------------------------------------
	# read MWCS descriptors
        #----------------------------------------------
	mw_qp=qp_loadwcs(qp)
	mw_be=mw_openim(ip_be)

        #----------------------------------------------
	# open table file
        #----------------------------------------------
	call bkf_setup(use_original_data,band,p_bkf_info)
	n_bkf = gt_open(bkfac_name,READ_ONLY,tp_bkf,col_ptr,p_bkf_info)

        #----------------------------------------------
	# check values: checks scales, image sizes,
	# PI ranges, nominal RA & DEC, counts & times
        #----------------------------------------------
	call bk_check_scale(xscale,yscale,display)
	call bk_check_images(ip_be,ip_ds,mw_be,mw_qp,tp_bkf)
	call bk_check_pi(pi_range,band,ip_be,ip_ds,
				use_original_data,tp_bkf,display)
	call check_nom(qphead,tp_bkf,display)
	call bk_check_rest(qp,ip_be,ip_ds,
			use_original_data,band,tp_bkf,br_edge_reg,display)

	if (display>0)
	{
	    call printf("\nThis task will be rotating %d image(s).\n\n")
	     call pargi(n_bkf)
	}

        #----------------------------------------------
	# do some initial setup to bkmap file
        #----------------------------------------------
	p_geo=bk_geo_setup(nxblock,nyblock)
	call rbkmap_setup(ip_be,ip_unscaled_rbkmap,display)
	
        #----------------------------------------------
	# make rotated image!
        #----------------------------------------------
	call mk_rbkmap(ip_be,ip_ds,tp_bkf,col_ptr,p_bkf_info,n_bkf,
			mw_be,mw_qp,p_geo,nxblock,nyblock,
			ip_unscaled_rbkmap,display)

	call scale_rbkmap(mw_be,xscale,yscale,Memc[p_unscaled_rbkmap_name],
			   ip_unscaled_rbkmap,rbkmap_name,
			   p_geo,nxblock,nyblock,ip_rbkmap,display)

        #----------------------------------------------
	# copy image header from qpoe
        #----------------------------------------------
	call bk_hdr(qphead,pi_range,ip_rbkmap)

        #----------------------------------------------
	# add history
        #----------------------------------------------
	call bk_hist(ip_rbkmap,bkfac_name,final_rbkmap_name)

        #----------------------------------------------
	# close final images
        #----------------------------------------------
	call gt_free_info(p_bkf_info)
	call tbtclo(tp_bkf)

        #----------------------------------------------
	# close everything and free memory
        #----------------------------------------------
	call mfree(qphead,TY_STRUCT)
	call mw_close(mw_qp)
	call mw_close(mw_be)
        call imunmap(ip_be)
        call imunmap(ip_ds)
        call imunmap(ip_rbkmap)
	call qp_close(qp)
	call mfree(p_geo,TY_STRUCT)

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree(sp)
end

#--------------------------------------------------------------------------
# Procedure:    bk_check_scale
#
# Purpose:      Check that the xscale & yscale are legal
#
# Input variables:
#		xscale		x-scale of final image
#		yscale		y-scale of final image
#               display         display level
#
# Description:  This routine checks that the xscale & yscale input
#		values are legal.  To be valid, they must be positive
#		and greater than 0.  A warning is given if the
#		scales are greater than 2.0.
#--------------------------------------------------------------------------
procedure bk_check_scale(xscale,yscale,display)
double xscale	# i: x-scale
double yscale   # i: y-scale
int    display  # i: display level
begin
	if (xscale<EPSILOND || yscale<EPSILOND)
	{
	    call error(1,
		"xscale and yscale must be positive")
	}

	if ((xscale>2 || yscale>2) && display>0)
	{
	    call printf(
             "\nWARNING: Input xscale & yscale (%.2f,%.2f) will produce\n")
	     call pargd(xscale)
	     call pargd(yscale)
	    call printf(
	     "a final image more than double the size of the input QPOE file.\n")
	    call flush(STDOUT)
	}
end

#--------------------------------------------------------------------------
# Procedure:    bk_check_image
#
# Purpose:      Check that the input images are "legal"
#
# Input variables:
#               ip_be           bright Earth image pointer
#               ip_ds           deep survey image pointer
#               mw_be		MWCS info for bright Earth
#		mw_qp		MWCS info for QPOE
#		tp_bkf          BKFAC table
#
# Description:  This routine checks that the input images are "legal",
#		i.e., that they pass the following tests:
#
#		* BE & DS maps must be two-dimensional maps
#
#		* BE & DS maps must be the same size and have the
#		  same pixel type, matching WCS block factors
#
#		* BE, DS, QP must have non-zero WCS roll angles,
#		  and their WCS x- and y- scalings must match.
#
#		* QPOE and BKFAC must have matching WCS scalings
#		  (since BKFAC was supposedly made from QPOE!)
#
#		These should be all the conditions necessary to
#		allow us to rotate the bkgd maps!
#
#               If any of these conditions fail, this routine gives
#		an ERROR.
#--------------------------------------------------------------------------
procedure bk_check_images(ip_be,ip_ds,mw_be,mw_qp,tp_bkf)
pointer ip_be	# i: BE image pointer
pointer ip_ds	# i: DS image pointer
pointer mw_be	# i: MWCS descriptor for BE map
pointer mw_qp	# i: MWCS descriptor for QPOE
pointer tp_bkf	# i: BKFAC table pointer

### LOCAL VARS ###

pointer mw_ds   # MWCS descriptor for DS map
double  r_be[2],r_ds[2],r_qp[2] # reference point for BE, DS, QPOE
double  w_be[2],w_ds[2],w_qp[2] # world reference point for BE, DS, QPOE
double  arc_be[2],arc_ds[2],arc_qp[2] # X/Y scale factors for BE, DS, QPOE
double  roll_be,roll_ds,roll_qp # WCS roll for BE, DS, QPOE
double  rcrpx1,rcrpx2  # X/Y scale factors for BKFAC map

### EXTERNAL FUNCTION DECLARATIONS ###

bool	fp_equald()     # returns TRUE if doubles are equal [sys/gio]
double  tbhgtd()        # returns double table header [tables]
pointer mw_openim()     # pointer to MWCS descriptor [sys/imio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# Check dimensions
        #----------------------------------------------
	if (IM_NDIM(ip_be)!=2)
	{
	    call error(ET_WRONG_DIMENSION,
		"bright Earth image must be in two dimensions")
	}

	if (IM_NDIM(ip_ds)!=2)
	{
	    call error(ET_WRONG_DIMENSION,
		"deep survey image must be in two dimensions")
	}

        #----------------------------------------------
	# check image sizes
        #----------------------------------------------
	if (IM_LEN(ip_be,1)!=IM_LEN(ip_ds,1) ||
	    IM_LEN(ip_be,2)!=IM_LEN(ip_ds,2) )
	{
	    call eprintf("Deep survey dimensions: %d x %d\n")
	     call pargi(IM_LEN(ip_ds,1))
	     call pargi(IM_LEN(ip_ds,2))
	    call eprintf("Bright Earth dimensions: %d x %d\n")
	     call pargi(IM_LEN(ip_be,1))
	     call pargi(IM_LEN(ip_be,2))
	    call error(ET_WRONG_SIZE,
		"deep survey and bright Earth images must be same size")
	}

        #----------------------------------------------
	# check pixtypes
        #----------------------------------------------
	if (IM_PIXTYPE(ip_be)!=IM_PIXTYPE(ip_ds))
	{
	    call error(ET_WRONG_PIXTYPE,
	    "deep survey and bright Earth images must have same pixel type")

	}
	
        #----------------------------------------------
	# Read in WCS info on ds, be, and qpoe
        #----------------------------------------------
	mw_ds=mw_openim(ip_ds)
	call bkwcs(mw_be,r_be,w_be,arc_be,roll_be)
	call bkwcs(mw_ds,r_ds,w_ds,arc_ds,roll_ds)
	call bkwcs(mw_qp,r_qp,w_qp,arc_qp,roll_qp)

        #----------------------------------------------
	# check wcs info: roll, block, ref. point
        #----------------------------------------------
	if (! ( fp_equald(roll_be,0.0D0)) && fp_equald(roll_ds,0.0D0)
	      && fp_equald(roll_qp,0.0D0))
	{
	    call error(ET_WRONG_WCS_ROLL,
	     "Input images have non-zero roll angle in WCS information")
	}

	if (! (fp_equald(arc_be[1],arc_ds[1])) &&
	      (fp_equald(arc_be[2],arc_ds[2])))
	{
	    call error(ET_WRONG_WCS_BLOCK,
	     "Input be & ds images must have same WCS block factor")
	}

	if (! ( fp_equald(r_be[1],r_ds[1]) && 
	        fp_equald(r_be[2],r_ds[2]) &&
		fp_equald(w_be[1],w_ds[1]) && 
	        fp_equald(w_be[2],w_ds[2])
		    ))
	{
	    call error(ET_WRONG_WCS_REF,
	     "Input BE and DS images must have same reference points")
	}

        #----------------------------------------------
	# Load in x- and y- scaling from table
        #----------------------------------------------
	rcrpx1=tbhgtd(tp_bkf,BK_RCRPX1)
	rcrpx2=tbhgtd(tp_bkf,BK_RCRPX2)

        #----------------------------------------------
	# Check WCS x- & y- scaling
        #----------------------------------------------
	if (! (fp_equald(abs(arc_be[1]),abs(arc_be[2]))) &&
		(fp_equald(abs(arc_ds[1]),abs(arc_ds[2]))) &&
		(fp_equald(abs(arc_qp[1]),abs(arc_qp[2]))) &&
		(fp_equald(abs(rcrpx1),abs(rcrpx2))))
	{
	    call error(ET_WRONG_WCS_BLOCK,
	     "Input files must have equal WCS x- and y- scaling")
	}

	if (! (fp_equald(arc_qp[1],rcrpx1)) &&
	      (fp_equald(arc_qp[2],rcrpx2)))
	{
	    call error(ET_WRONG_WCS_BLOCK,
	     "QPOE and BKFAC table must have same WCS scaling")
	}

        #----------------------------------------------
	# clear memory
        #----------------------------------------------
	call mw_close(mw_ds)
end


#--------------------------------------------------------------------------
# Procedure:    bk_check_pi
#
# Purpose:      Check that the PI band matches between input files
#
# Input variables:
#               pi_range        user-specified PI range
#		band		which band is range? (soft/hard/other)
#               ip_be           bright Earth image pointer
#               ip_ds           deep survey image pointer
#		use_original_data  is user making original lvl1 bkgd map?
#               tp_bkf          BKFAC table
#               display         display level
#
# Description:  This routine checks that the PI ranges match between
#		the following:
#		   * user-input pi range (pi_range)
#		   * pi-range in BKFAC table
#		   * pi-range in bright Earth and deep survey maps
#
#		Note that the BKFAC table may not have a header keyword
#		for the pi-range if we are using "original data".  In
#		this case, the table comes from the unscreened CDROM,
#		and we use "band" to determine what the pi range should
#		be.  (If the "band" is set to OTHER_BAND and we are
#		using original data, give an error.)
#
#		Only a warning is given if a difference is found.
#
#		It is assumed that "band" matches "pi_range".
#
# Note:         It is possible to get an error when there is no problem.
#               For instance, the pi ranges "2:3,3:4" will be considered
#               different from "2:4".
#--------------------------------------------------------------------------

procedure bk_check_pi(pi_range,band,ip_be,ip_ds,
			use_original_data,tp_bkf,display)
char    pi_range[ARB]   # i: user-specified PI range
int	band		# i: band of above range.
pointer ip_be		# i: bright Earth image
pointer ip_ds		# i: deep survey image
bool	use_original_data # i: is user making original bkgd map?
pointer	tp_bkf		# i: BKFAC table
int	display		# i: input display value

### LOCAL VARS ###

pointer	p_bk_pi_range	# BKFAC pi range

### EXTERNAL FUNCTION DECLARATIONS ###

bool    streq()         # TRUE if strings are equal [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# Read PI range from BKFAC table.  But if using
	# original data, we must set it ourselves.
        #----------------------------------------------
	if (use_original_data)
	{
	    switch(band)
            {
            	case HARD_BAND:
		    call band2range("hard",p_bk_pi_range)
             	case SOFT_BAND:
		    call band2range("soft",p_bk_pi_range)
             	default:
                    call error(1,
                      "Original data must use hard or soft band")
	    }
	}
	else
	{
	    call malloc(p_bk_pi_range,SZ_LINE,TY_CHAR)
	    call tbhgtt(tp_bkf,BK_PIBAND,Memc[p_bk_pi_range],SZ_LINE)
	}	

        call strip_whitespace(Memc[p_bk_pi_range])

        #----------------------------------------------
        # compare pi-range to that found in BKFAC table
        #----------------------------------------------
        if (!streq(pi_range,Memc[p_bk_pi_range]) && display>0)
        {
            call printf("\nWARNING: BKFAC table PI band differs:\n")
            call printf("Found (%s), expected (%s).\n")
             call pargstr(Memc[p_bk_pi_range])
             call pargstr(pi_range)
            call flush(STDOUT)
        }

        #----------------------------------------------
	# Check BE, DS and BK pi ranges.
        #----------------------------------------------
	call beds_check_pi(ip_be,ip_ds,Memc[p_bk_pi_range],display)
	
        #----------------------------------------------
	# Free memory
        #----------------------------------------------
	call mfree(p_bk_pi_range,TY_CHAR)
end


#--------------------------------------------------------------------------
# Procedure:    bk_check_rest
#
# Purpose:      Check other characteristics of input data: time & counts
#
# Input variables:
#               qp              QPOE
#               ip_be           bright Earth image pointer
#               ip_ds           deep survey image pointer
#		use_original_data  is user making original lvl1 bkgd map?
#		tp_bkf		BKFAC table pointer
#               br_edge_reg     region for be/ds to remove bright edge
#               display         display level
#
# Description:  This routine checks the livetime and image counts in
#		the image files to the QPOE file.  It checks the
#		following:
#
#		* BECTS & DSCTS header keywords in BKFAC table matches
#		  actual counts in BE & DS maps, applying the br_edge_reg.
#		  This will ensure that the user is using the same BE &
#		  DS maps and bright edge region as when the BKFAC table
#		  was created.
#
#		* Livetime in DS map matches the DSTIME header keyword
#		  in the BKFAC table.  Again, this checks that the
#		  same DS map used to make the BKFAC table is used for
#		  this routine.
#
#		Even the original-data BKFAC table will have the DSTIME,
#		BECTS, and DSCTS keywords.  However, because of a level
#		one processing bug, the counts in the original BE & DS
#		maps do NOT match the values in the header. 
#
#		For instance, the hard band DSMAP says it has 155846
#		counts (in its header), when it actually has 157109 counts.
#		The four header values are stored as 
#		BK_[BE/DS][HARD/SOFT]_ORIG macros in bkmap.h.
#
#		There is no point in reporting these differences; we 
#		thus compare the BE/DS headers with the macro values
#
#		Only WARNINGS are given if differences are found. 
#		A "difference" is termed to be 1.0 seconds in time
#		or 1.0 counts.
#--------------------------------------------------------------------------
procedure bk_check_rest(qp,ip_be,ip_ds,
		use_original_data,band,tp_bkf,br_edge_reg,display)
pointer qp		# i: QPOE file
pointer ip_be		# i: BE image
pointer ip_ds		# i: DS image
bool	use_original_data # i: is user creating original bkgd maps?
int	band		# i: band requested (soft/hard/other)
pointer	tp_bkf		# i: BKFAC table
char    br_edge_reg[ARB] # i: region to exclude bright edge
int	display		# i: display level

### LOCAL VARS ###

double	area		     # [unused] area from im_cts
double	bects,bects_actual   # BE cts: from BKFAC table, and calculated
double	dscts,dscts_actual   # DS cts: from BKFAC table, and calculated
double	dstime,dstime_actual # DS livetime: from BKFAC table and from DS map

### EXTERNAL FUNCTION DECLARATIONS ###

double  im_cts()      # returns no. coutns in image [lib/pros/im_cts.x]
double	get_dstime()  # returns DS time from DS map [source/bkmap.x]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# Calculate actual BE and DS counts
        #----------------------------------------------
	if (use_original_data)
	{
	  switch(band)
          {
             case HARD_BAND:
		bects_actual=BK_BEHARD_ORIG
		dscts_actual=BK_DSHARD_ORIG
             case SOFT_BAND:
		bects_actual=BK_BESOFT_ORIG
		dscts_actual=BK_DSSOFT_ORIG
             default:
                call error(1,
                     "Original data must use hard or soft band")
	  }
	}
	else
	{
	   bects_actual=im_cts(ip_be,br_edge_reg,area)
	   dscts_actual=im_cts(ip_ds,br_edge_reg,area)
	}	

        #----------------------------------------------
	# Read bects, dscts, dstime from BKFAC table
        #----------------------------------------------
	call bkf_rdinfo(use_original_data,band,tp_bkf,bects,dscts,dstime)

        #----------------------------------------------
    	# compare BE/DS counts
        #----------------------------------------------
	if (abs(bects-bects_actual)>1.0 && display>0)
	{
	    call printf("\nWARNING: Bright Earth map counts differ:\n")
	    call printf("Found %.3f actual counts, expected %.3f.\n")
	     call pargd(bects_actual)
	     call pargd(bects)
	    call flush(STDOUT)
	}

	if (abs(dscts-dscts_actual)>1.0 && display>0)
	{
	    call printf("\nWARNING: Deep survey map counts differ:\n")
	    call printf("Found %.3f actual counts, expected %.3f.\n")
	    call pargd(dscts_actual)
	     call pargd(dscts)
	    call flush(STDOUT)
	}

        #----------------------------------------------
	# check dstimes.
        #----------------------------------------------
	dstime_actual=get_dstime(ip_ds)
	if (abs(dstime-dstime_actual)>1.0 && display>0)
	{
	    call printf("\nWARNING: Deep survey livetime differs:\n")
	    call printf("Found %.3f, expected %.3f.\n")
	     call pargd(dstime_actual)
	     call pargd(dstime)
	    call flush(STDOUT)
	}
end

#--------------------------------------------------------------------------
# Procedure:    scale_rbkmap
#
# Purpose:      Scale output rotated bkgd map to requested size
#
# Input variables:
#		mw_be		MWCS descriptor for BE map
#		xscale, yscale	requested x & y scale
#		unscaled_rbkmap_name  file name of unscaled rbkmap
#		ip_unscaled_rbkmap    image pointer for unscaled rbkmap
#		rbkmap_name	output rbkmap name
#		p_geo		GEOTRAN info
#		nxblock,nyblock	size of block to do scaling in [for geo]
#               display         display level
#
# Output variables:
#		ip_rbkmap	image pointer for output rbkmap
#
# Description:  This routine will scale the input rotated background
#		map to the user-specified scaling.  The input 
#		bkgd map has a pixel size matching the bright Earth
#		scaling; the WCS info the the bright Earth describes
#		the relation between the BE pixel size and the IPC
#		pixel size.  If the user asks for xscale=1.0 and
#		yscale=1.0, this routine will produce a final image
#		with the same pixel size as the standard IPC instrument.
#		If the user gives different xscale or yscale, the final
#		image will be scaled accordingly.
#
#		(For instance, if xscale=0.5 and yscale=0.5, the final
#		image will be one quarter the size of the standard
#		IPC image.)
#		
#
#		This routine checks first if any scaling needs to be
#		done.  If so, it calls "im_scale" and creates the new
#		scaled bkgd map.  If not, it simply moves the temporary
#		unscaled map into the scaled map.
#
#		Upon entering the routine, ip_unscaled_rbkmap should be
#		an already opened image pointing to the image referred
#		to in unscaled_rbkmap_name.  This routine will delete
#		this file, close the image, and return with ip_rbkmap
#		pointing to the final image, named by rbkmap_name.
#
#		It is assumed the p_geo, nxblock, and nyblock have 
#		already been set up.  (See bk_geo_setup.)
#
# Note:		The geotran routines require real (not double) scales -- we
#		might lose some precision.  Not that we could ever really
#		want double-precision scaling.
#--------------------------------------------------------------------------

procedure scale_rbkmap(mw_be,xscale,yscale,unscaled_rbkmap_name,
			   ip_unscaled_rbkmap,rbkmap_name,
			   p_geo,nxblock,nyblock,ip_rbkmap,display)

pointer	mw_be		 # i: MWCS descriptor for bright Earth
double	xscale,yscale	 # i: final x- and y- scale for bkmap
char 	unscaled_rbkmap_name[ARB] # i: unscaled bkmap file name
pointer	ip_unscaled_rbkmap # io: image pointer to unscaled bkmap
char    rbkmap_name[ARB] # i: output rbkmap name
pointer p_geo		 # i: pointer to GEO into
int	nxblock,nyblock  # i: number of pixels to use in scaling [see geo code]
pointer	ip_rbkmap	 # o: pointer to output bkmap.
int	display		 # i: display level

### LOCAL VARS ###

double  r_be[2]         # reference point for BE map (unused)
double  w_be[2]         # world reference point (unused)
double  arc_be[2]       # scale factors for X&Y for BE map
double  roll_be         # BE roll (unused)
real    x_finalscale	# actual scale to apply on image, x-scale
real    y_finalscale	# actual scale to apply on image, y-scale

### EXTERNAL FUNCTION DECLARATIONS ###

bool    fp_equalr()     # returns TRUE if reals are equal [sys/gio]
pointer immap()         # returns pointer to image [sys/imio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# Calculate WCS info for BE
        #----------------------------------------------
	call bkwcs(mw_be,r_be,w_be,arc_be,roll_be)
	
        #----------------------------------------------
	# Calculate final scales, x & x
        #----------------------------------------------
	x_finalscale=arc_be[1]*xscale
	y_finalscale=arc_be[2]*yscale

	if (display>4)
	{
	   call printf("\nFinal scales: %.3f,%.3f\n")
	    call pargr(x_finalscale)
	    call pargr(y_finalscale)
	}

        #----------------------------------------------
	# Check if we need to scale or not
        #----------------------------------------------
	if (fp_equalr(x_finalscale,1.0E0) && fp_equalr(y_finalscale,1.0E0))
	{
	    if (display>2)
	    {
	       	call printf(
	"Input image is same size as bkgd files -- no scaling needed!\n")
	    }

            #----------------------------------------------
	    # Move unscaled map to scaled map.  Open new
	    # map.
            #----------------------------------------------
	    call imunmap(ip_unscaled_rbkmap)
	    call imrename (unscaled_rbkmap_name, rbkmap_name)
	    ip_rbkmap=immap(rbkmap_name,READ_WRITE,0)
	}
	else
	{
            #----------------------------------------------
	    # open final image
            #----------------------------------------------
	    ip_rbkmap=immap(rbkmap_name,NEW_COPY,ip_unscaled_rbkmap)

	    if (display>0)
	    {
	      	call printf("\nScaling background map to (%.2f,%.2f)...\n")
	       	 call pargd(xscale)
	       	 call pargd(yscale)
	      	call flush(STDOUT)
	    }

            #----------------------------------------------
	    # produce scaled image.  (ip_rbkmap will 
	    # remain open.)
            #----------------------------------------------
	    call im_scale(ip_unscaled_rbkmap,ip_rbkmap,p_geo,nxblock,nyblock,
				x_finalscale,y_finalscale)

            #----------------------------------------------
	    # close other image
            #----------------------------------------------
            call imunmap(ip_unscaled_rbkmap)
		   
            #----------------------------------------------
	    # delete temporary image
            #----------------------------------------------
            call imdelete(unscaled_rbkmap_name)
	}
end

#--------------------------------------------------------------------------
# Procedure:    bk_hdr
#
# Purpose:      Fill in header keywords in bkgd map
#
# Input variables:
#               qphead          QPOE header
#               pi_range	PI range bkgd map was calculated for
#               ip_rbkmap       image pointer
#
# Description:  Fills in the following header keywords in the bkgd map:
#
#       all header keywords from QPHEAD
#       BK_PIBAND: PI band used to create bkgd map.
#
# Note:         For some reason, using just put_imhead does not
#               write out the WCS information -- we have to do 
#               that separately.
#--------------------------------------------------------------------------

procedure bk_hdr(qphead,pi_range,ip_rbkmap)
pointer qphead		# i: QPOE header
char	pi_range[ARB]	# i: PI range
pointer ip_rbkmap	# io: bkgd map image pointer

pointer mw         # MWCS descriptor (for QPOE)

begin
        #------------------------------------------------
        # put wcs info
        #------------------------------------------------
        call qph2mw(qphead, mw)
        call mw_ssystem(mw, "world")
        call mw_saveim(mw, ip_rbkmap)
        call mw_close(mw)

        #------------------------------------------------
        # put qphead information
        #------------------------------------------------
	call put_imhead(ip_rbkmap,qphead)

        #------------------------------------------------
        # write PIBAND
        #------------------------------------------------
	call imastr(ip_rbkmap,BK_PIBAND,pi_range)
end

#--------------------------------------------------------------------------
# Procedure:    bk_hist
#
# Purpose:      Fill in history header keywords in bkgd map
#
# Input variables:
#               ip_rbkmap       image pointer
#               bkfac_name      file name of input BKFAC map
#		rbkmap_name	file name of output bkgd map
#
# Description:  Writes history to bkgd map.
#--------------------------------------------------------------------------
procedure bk_hist(ip_rbkmap,bkfac_name,rbkmap_name)
pointer ip_rbkmap	 # io: image pointer
char	bkfac_name[ARB]	 # i: BKFAC name
char	rbkmap_name[ARB] # i: rotated bkgd map name

### LOCAL VARS ###
	
pointer sp       # stack pointer
pointer p_hist   # pointer to history string
int     len      # length of history string

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen() # returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for filter string
        #----------------------------------------------
        call smark(sp)
        len = strlen(bkfac_name)+
              strlen(rbkmap_name)+
              SZ_LINE
        call salloc(p_hist, len, TY_CHAR)

        #----------------------------------------------
        # Create main history string
        #----------------------------------------------
        call sprintf(Memc[p_hist], len, "%s -> %s")
         call pargstr(bkfac_name)
         call pargstr(rbkmap_name)
	
        #----------------------------------------------
        # Write history string to file
        #----------------------------------------------
        call put_imhistory(ip_rbkmap, "be_ds_rotate", Memc[p_hist], "")

        #----------------------------------------------
        # Free up memory
        #----------------------------------------------
        call sfree(sp)
end
