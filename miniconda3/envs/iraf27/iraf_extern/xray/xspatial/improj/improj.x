# $Header: /home/pros/xray/xspatial/improj/RCS/improj.x,v 11.0 1997/11/06 16:30:17 prosb Exp $
# $Log: improj.x,v $
# Revision 11.0  1997/11/06 16:30:17  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:47:03  prosb
# General Release 2.4
#
#Revision 8.1  1994/08/19  17:15:46  dennis
#Replaced call to rg_parse_f(), which didn't support WCS, with call to
#new routine rg_objects(), which does.
#
#Revision 8.0  94/06/27  14:57:16  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:11:44  prosb
#General Release 2.2
#
#Revision 5.1  93/04/27  00:20:45  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:29:19  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:36:33  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  91/08/02  12:17:29  mo
#Initial revision
#
# ----------------------------------------------------------------------------
#
# Module:	Improj
# Project:	PROS -- ROSAT RSDC
# Purpose:	Performs a geometric projection on an image file
# Description:	First the xcen, ycen, width, height, & angle of individual 
#		projections along the X axis are computed.  With these 
#		parameters a mask is made. The mask is applied to the image 
#		file and the photons in each bin are counted.  This is also
# 		repeated for the Y axis.  A table file is created and the 
#		proj data is written to the file.	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte -- initial version -- October 1988
#		{1} Janet DePonte -- updated to use scan lib -- July 1989
#		{2} MVH -- added field case, float output -- September 1989
#		{3} MVH -- changed ydim to xdim on line 333 -- 11 Oct 1989
#		{4} MC  -- Updated the include files.       -- 20 Feb 1990
#		{5} JD  -- Moved file opens and checks closer to the
#                          paramter gets            .       -- 26 Mar 1990
#		{n} <who> -- <does what> -- <when>
#
#------------------------------------------------------------------------------

include <ctype.h>
include <imhdr.h>
include <error.h>
include <math.h>
include <pmset.h>
include <mach.h>	# get EPSILOND
include <ext.h>
include <regparse.h>
include <scset.h>

procedure t_improj()

double	yprj			# temp sum for orthogonal proj

bool    clobber			# clobber old table file y/n
bool    got_box			# indicates whether we have the proj box

pointer buff			# excluded regions buffer pointer
pointer cmdbuff			# buffer for 1 excluded reg
pointer img_fname		# input image filename
pointer region			# region description
pointer tbl_fname		# output table filename

int	depth
int	display			# display on/off
int	dotable			# flag that a table file is requested
int 	i, j, k			# loop counters
int     indices			# num of tables rows
int     min, max		# min and max indices
int     maxargs			# maximum number of arguments
int	naxes
int	num_bins[2]		# number of projection bins
int	num_rg			# number of input regions
int	is_ortho			# orthogonal full image projection
int	plaxlen[2]		# l: unused array to pass to rg_objects()
int     x, y			# array subscripts
int	x_dim, y_dim		# x and y dimensions of field
int	nvals			# number of vals returned
int	xoff			# offset to current array element

real    ang[2]			# angles for projection
real    bin_center		# center of first bin
real	box_cen[2]		# input box x & y center
real    cos_ang			# cosine of the angle
real    dim[2]		 	# dimension of projection box
real    gp_ang 			# output angle 
real    gp_cen[2]		# output x & y coordinates
real    gp_height		# output height
real	gp_width		# output width
real    sin_ang			# sine of the angle
real	step[2]			# bin width in x & y

long	axlen[PL_MAXDIM]	# array of axis lengths
long	v[IM_MAXDIM]		# array of axis indexes

pointer area			# projection area
pointer area_cp[2]		# area column pointer for table
pointer counts			# projection counts
pointer counts_cp[2]		# counts column pointer for table
pointer xproj			# array pointers for orthogonal proj
pointer	yproj
pointer	xarea
pointer	yarea
pointer im			# image pointer
pointer	parsing			# pointer to parsing control structure
bool	bjunk			# unneeded return from parser request setup
pointer	regobj			# ptr to current region object structure
pointer	reg			# reg structure attached to regobj structure
pointer mp			# mask pointer
pointer pm			# pixel mask pointer
pointer	sl
pointer sp			# stack pointer
pointer tp			# table pointer

#   Functions
bool    clgetb()		# get bool param function
bool	streq()			# string compare

int	clgeti()		# get integer param function
int     strlen()
int	mio_glsegd()
int	imgnld()

pointer immap()			# image open
pointer	rg_open_parser()	# prepare parser for requests
bool	rg_objlist_req()	# set up request for region object list
				#  from parser
bool	rg_openmask_req()	# set up request for opened region mask 
				#  from parser
pointer mio_openo()		# open a masked image (for MIO)
pointer pm_newmask()
pointer	sl_open()
pointer sl_pm()

begin

#   Mark the stack
        call smark(sp)
	call salloc (img_fname, SZ_PATHNAME, TY_CHAR)
        call salloc (tbl_fname, SZ_PATHNAME, TY_CHAR)
        call salloc (cmdbuff,   SZ_LINE,     TY_CHAR)
	call salloc (region,    SZ_LINE,     TY_CHAR)
	buff = NULL

#   Init constants
	indices = 0
	maxargs = 1024
        x = 1
	y = 2
	dotable = YES
	got_box = false
	display = clgeti("display")

#  Get input parameters 
        call clgstr ("image", Memc[img_fname], SZ_PATHNAME)
#   Open the image file and set the bins if needed
	im = immap(Memc[img_fname], READ_ONLY, 0)
	if ( IM_NDIM(im) != 2 )
	{
	   call sfree(sp)
	   call error(1, "INPUT Must be 2-dimensional image!")
	}
	x_dim = IM_LEN(im,1)
	y_dim = IM_LEN(im,2)

	is_ortho = NO
	call clgstr("region", Memc[region], SZ_LINE)
#    DEVELOPMENT DEBUG CALL
	if ( display > 7 )
	{
	   call printf("%s\n")
	      call pargstr(Memc[region])
	}

	num_rg = 0
#   Parse the region descriptor 
	parsing = rg_open_parser()
	bjunk = rg_objlist_req(parsing)

	call rg_objects(parsing, Memc[region], im, plaxlen, REFTY_IM)

#   Search the input region list for proj region and excluded regions
	   for (regobj = OBJLISTPTR(parsing);  regobj != NULL;  
						regobj = V_NEXT(regobj))
	   {
	      num_rg = num_rg + 1
	      reg = V_ARG1(1, regobj)
#   Check if proj region ... and save some parameters
	      if ( R_CODE(reg) == FIELD )
	      {
	         if( (V_INCL(regobj) != YES) || (got_box) )
		    call error(EA_FATAL, "FIELD excluded or not unique")
		 dim[x] = real(x_dim)
		 dim[y] = real(y_dim)
	         call rg_summaryadd("field ; ", buff)
#   Only want one box - note that we found our box
		 got_box = true
		 is_ortho = YES
	      }
	      else if ( (V_INCL(regobj) == YES) && 
	                ((R_CODE(reg) == ROTBOX) || (R_CODE(reg) == BOX)) &&
			(!got_box) )
	      {
                 box_cen[x] = Memr[R_ARGV(reg)]
	         box_cen[y] = Memr[R_ARGV(reg) + 1]
	         dim[x] = Memr[R_ARGV(reg) + 2]
	         dim[y] = Memr[R_ARGV(reg) + 3]
		 if( R_ARGC(reg) > 4 )
		    ang[x] = Memr[R_ARGV(reg) + 4]
		 else
		 ang[x] = 0.0
#   Check for orthogonal box (will require more work)
#		 if ( (ang[x] > -EPSILON) && (ang[x] < EPSILON) )
#		 {
#		    call sprintf(Memc[cmdbuff], SZ_LINE,
#				 "box %.2f %.2f %.2f %.2f ; ")
#	             call pargr(box_cen[x])
#	             call pargr(box_cen[y])
#	             call pargr(dim[x])
#	             call pargr(dim[y])
#		     call rg_summaryadd(Memc[cmdbuff], buff)
#		    is_ortho = YES
#		 }
#   Only want one box - note that we found our box
		 got_box = true
	      }
#   Check if region is an excluded regions and save in buffer
	      else if ( V_INCL(regobj) == NO ) {
	         switch ( R_CODE(reg) )
		 {
		 case ANNULUS:
		    call sprintf(Memc[cmdbuff], SZ_LINE, "-annulus ")
		 case BOX:
		    call sprintf(Memc[cmdbuff], SZ_LINE, "-box ")
		 case CIRCLE:
		    call sprintf(Memc[cmdbuff], SZ_LINE, "-circle ")
		 case ELLIPSE:
		    call sprintf(Memc[cmdbuff], SZ_LINE, "-ellipse ")
		 case PIE:
		    call sprintf(Memc[cmdbuff], SZ_LINE, "-pie ")
		 case POINT:
		    call sprintf(Memc[cmdbuff], SZ_LINE, "-point ")
		 case POLYGON:
		    call sprintf(Memc[cmdbuff], SZ_LINE, "-polygon ")
		 case ROTBOX:
		    call sprintf(Memc[cmdbuff], SZ_LINE, "-rotbox ")
	         }
#    Write the argument list
	         do k=1, R_ARGC(reg)
	         { 
	            call sprintf(Memc[cmdbuff + strlen(Memc[cmdbuff])],
				 SZ_LINE, "%.2f ")
	              call pargr(Memr[R_ARGV(reg) + k - 1])
	         }
	         call sprintf(Memc[cmdbuff + strlen(Memc[cmdbuff])],
			      SZ_LINE, "; ")
	         call rg_summaryadd(Memc[cmdbuff], buff)
	      }
#   Check if we have more than one included region - error if true
	      else if ( (V_INCL(regobj) == YES) && (got_box) )
		 call error(EA_FATAL,
		    ">1 Included region given - only 1 BOX or FIELD Accepted")
	   }
#   ...and finally check if we got our proj region - error if not
           if ( !got_box )
	      call error(EA_FATAL, 
			 "BOX or FIELD proj region missing from input!!")
#    close the parser
	call rg_close_parser(parsing)

#    DEVELOPMENT DEBUG CALL
	if ( (display > 6) && (buff != NULL) )
	{
	   call printf("%s\n")
	      call pargstr(Memc[buff])
	}

        call clgstr ("table", Memc[tbl_fname], SZ_PATHNAME)
	call rootname (Memc[img_fname], Memc[tbl_fname], EXT_PROJ, SZ_PATHNAME)
	if (streq(Memc[tbl_fname], "NONE")) dotable = NO
	else clobber = clgetb("clobber")
        num_bins[x] = clgeti ("x_bins")
        num_bins[y] = clgeti ("y_bins")

#    Init the table file
	if ( dotable == YES )
	   call init_table(Memc[tbl_fname], tp, clobber, counts_cp, area_cp)

#    Check for simple, orthogonal and full image, case
	if ( is_ortho == YES )
	{
#     In this case, bins out cannot exceed bins in
	   if ( (num_bins[x] > x_dim) || (num_bins[x] <= 0) )
	      num_bins[x] = x_dim
	   if ( (num_bins[y] > x_dim) || (num_bins[y] <= 0) )
	      num_bins[y] = y_dim
	   call salloc(counts, x_dim, TY_DOUBLE)
	   call salloc(xproj, x_dim, TY_DOUBLE)
	   call salloc(xarea, x_dim, TY_DOUBLE)
	   call salloc(yproj, y_dim, TY_DOUBLE)
	   call salloc(yarea, y_dim, TY_DOUBLE)
	   call aclrd(Memd[xproj], x_dim)
	   call aclrd(Memd[xarea], x_dim)
	   call aclrd(Memd[yproj], y_dim)
	   call aclrd(Memd[yarea], y_dim)
	   call amovkl(long(1), v, IM_MAXDIM)
	   if ( num_rg > 1 )
	   {
	      parsing = rg_open_parser()
	      bjunk = rg_openmask_req(parsing)
	      call rg_imcreate(parsing, Memc[buff], im)
#   DEBUG CALLS
	      if( display >= 5 )
	         call rg_pldisp(MASKPTR(parsing), 80, 40, -1, -1, -1, -1)
#      Open mask and image for mask io
	      mp = mio_openo(MASKPTR(parsing), im)
#      Do the projection in x and y
#      Get a contiguous masked segment of data (i is mask value of seg)
	      while ( mio_glsegd(mp, counts, i, v, nvals) != EOF )
	      {
		 xoff = v[1] - 1
		 call aaddd(Memd[counts], Memd[xproj + xoff],
			    Memd[xproj + xoff], nvals)
		 yprj = 0
		 do j = 1, nvals
		 {
#        Sum contribution to this line
		    yprj = yprj + Memd[counts+j-1]
#        Note pixel area counted in each column
		    Memd[xarea + xoff + j - 1] = Memd[xarea + xoff + j - 1] + 1
		 }
		 Memd[yproj + v[2] - 1] = Memd[yproj + v[2] - 1] + yprj
		 Memd[yarea + v[2] - 1] = Memd[yarea + v[2] - 1] + nvals
	      }
#	 Close and free up descriptors and their buffers
	      call mio_close(mp)
	      call rg_close_parser(parsing)
	   }
	   else
	   {
#      Do the projection in x and y
	      do i = 1, y_dim {
		 if ( imgnld(im, counts, v) != EOF )
		 {
		    call aaddd(Memd[counts], Memd[xproj], Memd[xproj], x_dim)
		    yprj = 0
		    do j = 1, x_dim
		       yprj = yprj + Memd[counts + j - 1]
		    Memd[yproj + i - 1] = yprj
		 }
	      }
#      Fill in areas which are trivially known
	      call amovkd(double(y_dim), Memd[xarea], x_dim)
	      call amovkd(double(x_dim), Memd[yarea], y_dim)
	   }

#     Done with the image, thank you
	   call imunmap(im)

#     Block fine projections to coarser array if requested
	   if( num_bins[x] < x_dim )
	      call proj_rebin(Memd[xproj], Memd[xarea], x_dim, num_bins[x])
	   if( num_bins[y] < y_dim )
	      call proj_rebin(Memd[yproj], Memd[yarea], y_dim, num_bins[y])

#     ... and display the results
	   if ( display >=1 )
	   {
	      call disp_proj_two(Memd[xproj], Memd[xarea], num_bins[x],
	 			 Memd[yproj], Memd[yarea], num_bins[y])
	   }

#    Fill the table file
	   if ( dotable == YES )
	   {
	      call fill_table(tp, Memd[xproj], Memd[xarea], num_bins[x],
			      counts_cp[x], area_cp[x], 0)
	      call fill_hdr(tp, Memc[img_fname], Memc[region], num_bins[x], 
			    num_bins[y])
	      call fill_table(tp, Memd[yproj], Memd[yarea], num_bins[y], 
			      counts_cp[y], area_cp[y], 0)
	      call fill_hdr(tp, Memc[img_fname], Memc[region], num_bins[y], 
			    num_bins[y])
	      call tbtclo(tp)
	   }
	   call sfree(sp)
	   return
	}

#    the 2nd projection is 90 degrees from the intial 
	ang[y] = ang[x] + 90.0

#    Step is the width of 1 bin if default else it's dim/bins
#    Set x step
        if ( num_bins[x] == 0 ) { 
	   num_bins[x] = dim[x]
	}
#    Set y step
        if ( num_bins[y] == 0 ) {
	   num_bins[y] = dim[y]
 	}
	step[x] = dim[x] / real(num_bins[x])
        step[y] = dim[y] / real(num_bins[y])

#    Check for reasonable memory requirements
	if( (num_bins[x] * int(dim[y])) > 50000 )
	{
	   call sfree(sp)
	   call printf("Too many x bins or large a y dimension for memory\n")
	   call error(1, "Consider Field or smaller request")
	}

#    Get correct pm dimensions by method not fooled by subsection
	pm = pm_newmask(im, 16)
	call pm_gsize(pm, naxes, axlen, depth)
	call pm_close(pm)

#    Loop on x & y projections
	do i = 1, 2
	{
#     Get the sine and cosine of the angle we're working on
	   cos_ang = cos(ang[i] / 180.0 * PI)
	   sin_ang = sin(ang[i] / 180.0 * PI) 

#     Open scan list image for writing
	   sl = sl_open(axlen[1], axlen[2])
#     Loop from high to low coordinates for more efficient assembly
#     (Scan algorithm loops across lower index regions to find placement)
	   do j = num_bins[i], 1, -1
	   {
              if ( j == num_bins[i] ) 
	      {
#      Compute the center position of the 1st bin
	         bin_center = (dim[i] - step[i]) / 2.0   
	         gp_cen[x] = box_cen[x] - bin_center * cos_ang
	         gp_cen[y] = box_cen[y] - bin_center * sin_ang
	      }
	      else
	      {
#      Compute the coordinates of subsequent bins
	         gp_cen[x] = gp_cen[x] + (cos_ang * step[i])
	         gp_cen[y] = gp_cen[y] + (sin_ang * step[i])
	      }

#     Assign width, height, and angle values
	      gp_width = step[i]
	      if (i == 1)
		 gp_height = dim[y]
	      else
		 gp_height = dim[x]
	      gp_ang = ang[i]

#     Paint each region onto scan list image
	      call sl_rotbox(sl, gp_cen[x], gp_cen[y], gp_width, gp_height,
			     gp_ang, j, SCPN)
	   }
#    Set up pm attached to a parsing control structure
	   parsing = rg_open_parser()
	   bjunk = rg_openmask_req(parsing)
#    Convert scan list image to pm
	   MASKPTR(parsing) = sl_pm (im, sl)
	   SELPLPM(parsing) = MSKTY_PM
#    DEVELOPMENT DEBUG CALL
	   if ( display >= 10 )
	      call sl_disp(sl, 80)

#    Release sl library work space
	   call sl_close (sl)
	   call sl_reset()

#    Add the excluded region(s) to our mask
	   if ( num_rg > 1 )
	      call rg_create(parsing, Memc[buff], NULL)

#    DEBUG CALL
	   if ( display >= 5 )
	      call rg_pldisp(MASKPTR(parsing), 80, 40, -1, -1, -1, -1)

#    Open mask and image for mask io
	   mp = mio_openo (MASKPTR(parsing), im)

#    Count up photons
	   call rg_pmvallims(MASKPTR(parsing), min, max)
	   indices = max - min + 1
	   call salloc (counts, indices, TY_DOUBLE)
	   call aclrd (Memd[counts], indices)
	   call salloc (area, indices, TY_DOUBLE)
	   call aclrd (Memd[area], indices)
	   call mskcnts (mp, IM_PIXTYPE(im), Memd[counts], Memd[area],
			 min, max)

#    Get rid of stuff so we can loop again or end with it gone 
	   call mio_close(mp)
	   call rg_close_parser(parsing)

#    Display the results
	   if ( display >=1 ) 
	      call disp_proj (i, Memd[counts], Memd[area], indices)

#    Fill the table file
	   if ( dotable == YES )
	   {
	     call fill_table (tp, Memd[counts], Memd[area], indices, 
			      counts_cp[i], area_cp[i], 1)
	     call fill_hdr (tp, Memc[img_fname], Memc[region], num_bins[x], 
			    num_bins[y])
	   }

	}

#    Clean things up before we quit
	if ( dotable == YES )
	   call tbtclo(tp)
	if( buff != NULL )
	   call mfree(buff, TY_CHAR)
	call imunmap(im)
	call sfree(sp)
end
