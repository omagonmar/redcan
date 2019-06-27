# $Header: /home/pros/xray/xproto/xexamine_r/RCS/xesubs2.x,v 1.2 1998/04/24 16:14:29 prosb Exp $
# $Log: xesubs2.x,v $
# Revision 1.2  1998/04/24 16:14:29  prosb
# Patch Release 2.5.p1
#
# Revision 1.1  1998/02/25 19:54:36  prosb
# Initial revision
#
#
# JCC(1/8/98) - Updated to display QPOE which is not a square
#
# Revision 11.0  1997/11/06 16:38:41  prosb
# General Release 2.5
#
# Revision 9.1  1997/07/18 21:14:03  prosb
# #JCC(6/19/97) - iraf2.11 has fixed the inconsistency between the QPOE
#                 and IMAGE coordinate systems. Therefore, the factor
#                 of 0.5 pixel is no longer needed in xexamine.
#
# ---------------------------------------------------------------------
# Module:       XESUBS2.X
# ---------------------------------------------------------------------

include <gset.h>
include <imhdr.h>
include <ctype.h>
include <ext.h>
include <mach.h>
include <fset.h>
include <rosat.h>
include <qpoe.h>
include "xexamine2.h"

# ---------------------------------------------------------------------------
#
# Function:     interp_key2
# Purpose:      interpret the cursor key and invoke the appropriate
#               procedure to invode the command
#
# ---------------------------------------------------------------------
procedure interp_key2 (xe, xn, wx, wy, wcs, key, strval, done)

pointer xe, xn		# i: pointer to structure
int	key		# i: user input key
int	wcs		# i: wcs param
int 	wx		# i: cursor x position
int	wy		# i: cursor y position
char 	strval[ARB]	# i: string buffer		
bool    done		# u: set when 'quit' received


char    ch		# l: character parsing var

int	cmd		# l: parsed commans
int     ip		# l: buff pointer

int     cctoc()

begin

        if ( XE_DISPLAY(xe) >= 4 ) {
	   call output_key2 (key, wx, wy)
        }

        #  identify the input key and perform command
	switch (key) {

           #  ? ... is for Menu
           case '?':
	      call menu_disp2 ()

           #  a ... Auto-expand and display
           case 'a':
	      call auto_expand2 (xe, xn, wx, wy)

	   #  b ... is for Block factor display
	   case 'b':
	      call block_query2 (xe)

	   #  c ... is for Coordinate-Cursor-position display
	   case 'c':
              call coord_query2 (xe, wx, wy)

           #  d ... is for Display
           case 'd':
              call disp_cmd2 (xe, xn, wx, wy)

           #  p ... is for Proj
	   case 'p':
              call proj_img2 (xe, xn)

           #  r ... is for Re-display
           case 'r':
	      call redisplay2 (xe, xn)

           # s ... is for source position
           case 's':
              call find_bpos2 (xe, xn, wx, wy)

           #  u ... is for Undo last command
           case 'u':
	      call undo_cmd2 (xe, xn)

	   #  : commands that change attributes
	   case ':':
	       for (ip=1; IS_WHITE(strval[ip]); ip=ip+1)
	           ;
               if ( cctoc (strval, ip, ch) > 0 )
                  cmd = ch
	       for (; IS_WHITE(strval[ip]); ip=ip+1)
	           ;

               switch (cmd) {

		  # set New Block factor
                  case 'b':
		     call set_block2(xe, strval, ip)

	          # set New Auto block factor
                  case 'a':
		     call set_factor2 (xe, strval, ip)

	          # set New Detect cell size 
                  case 'c':
		     call set_cellsize2 (xe, strval, ip)
               }

	    #   q ... is to Quit
            case 'q':
                done = TRUE
                call imunmap(XE_IM(xe))
                call imunmap(XE_WIM(xe))

            default:
	       call printf ("\n** Undefined Command -> try \"?\" for Menu **\n\n")
	}

end

# ---------------------------------------------------------------------
#
# Function:     find_bpos2
# Purpose:      determine the source position by building a ruf table
#               and invoking bepos.
#
# ---------------------------------------------------------------------
procedure find_bpos2 (xe, xn, wx, wy)
pointer         xe, xn          # i: xexamine struct pointer
real            wx, wy          # i: cursor x & y readout

pointer blname			# l: bkden name
pointer ksection, isection	# l: parsed name sections
pointer img_rootname		# l: qpoe root name
pointer omw, oct                # l: wcs pointers
pointer otp			# l: output table handle
pointer ocolptr[10]		# l: output table col ptr
pointer qpname			# l: rebuilt qpoe name (no block)
pointer ruftab			# l: temp ruf position table
pointer sp			# l: buffer pointer

int     cl_index, cl_size       # l: name parsing counters
int     rownum			# l: output rpos row

real    px, py                  # l: position in physical pixels

pointer tbtopn()
pointer mw_openim()
pointer mw_sctran()
real    clgetr()

begin

        call smark (sp)
        call salloc (img_rootname,      SZ_PATHNAME, TY_CHAR)
        call salloc (isection,          SZ_FNAME,    TY_CHAR)
        call salloc (ksection,          SZ_FNAME,    TY_CHAR)
        call salloc (qpname,            SZ_PATHNAME, TY_CHAR)
        call salloc (blname,            SZ_PATHNAME, TY_CHAR)
        call salloc (ruftab,            SZ_FNAME,    TY_CHAR)

	call printf ("\nDetect Cell size = %d arcsecs\n\n")
           call pargi (XE_CSIZE(xe))

        # Parse the image name and separate the name root (img_rootname)
        # from the image section (isection) and filter (ksection).
        call imparse (Memc[XE_QPNAME(xn)], Memc[img_rootname], SZ_PATHNAME,
            Memc[ksection], SZ_FNAME, Memc[isection], SZ_FNAME,
            cl_index, cl_size)

        # Rebuild the qpoe name (remove blocks from the name)
        call sprintf (Memc[qpname], SZ_PATHNAME, "%s%s")
           call pargstr (Memc[img_rootname])
           call pargstr (Memc[XE_FILT(xn)])

        # create a name for the ruf positions table (input to bepos)
        call mktemp ("ruf", Memc[ruftab], SZ_FNAME)
        call addextname (Memc[ruftab], ".tab", SZ_FNAME)

        # retrieve the physical coords from the wcs
        omw = mw_openim(XE_WIM(xe))
        oct = mw_sctran(omw, "logical", "physical", 3B)
        call mw_c2tranr(oct, wx, wy, px, py)
        call mw_close(omw)

        # we will always write just one row
        rownum = 1

        # open the ruf table file
        otp = tbtopn (Memc[ruftab], NEW_FILE, 0)
        call tbcdef(otp,ocolptr[1],"x","phys pixels","%7.2f",TY_REAL,1,1)
        call tbcdef(otp,ocolptr[2],"y","phys pixels","%7.2f",TY_REAL,1,1)
        call tbcdef(otp,ocolptr[3],"cellx","pixels","%4d",TY_INT,1,1)
        call tbcdef(otp,ocolptr[4],"celly","pixels","%4d",TY_INT,1,1)
        call tbtcre(otp)

        # write 1 row to table output
        call tbrptr (otp, ocolptr[1], px, 1, rownum)
        call tbrptr (otp, ocolptr[2], py, 1, rownum)
        call tbrpti (otp, ocolptr[3], XE_CSIZE(xe), 1, rownum)
        call tbrpti (otp, ocolptr[4], XE_CSIZE(xe), 1, rownum)
        call tbtclo(otp)

	# first check if the User picked a value for bkden 

        if ( XE_BKDEN(xe) < EPSILONR ) {
           call sprintf (Memc[blname], SZ_PATHNAME, "%s%s%s")
             call pargstr (Memc[img_rootname])
             call pargstr (Memc[ksection])
             call pargstr (Memc[XE_FILT(xn)])

           # determine the bkden, call bkden task
           call xe_bkden2(xe, Memc[XE_ONAME(xn)])
           XE_BKDEN(xe) = clgetr ("bkden.value")
        }

        # determine the source position, call bepos task
        call xe_bepos2(xe, Memc[qpname], Memc[ruftab])

        #  rough position table file only temporary ... delete it
        call tbtdel (Memc[ruftab])

        call sfree (sp)
end

# ---------------------------------------------------------------------
#
# Function:     menu_disp2
# Purpose:      Display the Menu of defined Commands
#
# ---------------------------------------------------------------------
procedure menu_disp2 ( )

begin

	call printf ("\n")
	call printf ("                Xexamine Key Menu:\n")
	call printf (" -------------------------------------------------------------------\n")
        call printf (" The following Keys must be entered in the Saoimage window:\n\n")
  	call printf (" a   = Expand & display qpoe by auto-expand increment \n")
        call printf (" b   = Block & auto-expand factor query\n")
        call printf (" c   = Cursor Coordinate query [hh:mm:ss.s dd:mm:ss.s, degs, pixels]\n")
        call printf (" d   = Display Qpoe centered at Cursor\n")
        call printf (" p   = Overlay Projection onto Display\n")
  	call printf (" r   = Redisplay original Qpoe\n")
  	call printf (" s   = Local Source detect\n")
        call printf (" u   = Undo; return to previous display\n")
        call printf ("\n")
        call printf (" ?   = Menu display\n")
        call printf (" q   = QUIT\n")
	call printf ("\n")
        call printf (" The following commands must be entered in the IRAF window:\n\n")
        call printf (" : a <#> = change auto-expand factor (i.e. : a 4) \n")
        call printf (" : b <#> = change block factor (i.e. : b 16) \n")
        call printf (" : c <#> = change detect cell size (i.e. : c 12) \n")
	call printf (" -------------------------------------------------------------------\n")
        call printf ("\n")

end

# --------------------------------------------------------------------
#
# Function:     auto_expand2
# Purpose:   	Compute a new block factor (current block / auto-factor), 
#		re-display the image at the new block centered on the cursor, 
#		& image sectioned to fill the graphics device.   
#
# --------------------------------------------------------------------
procedure auto_expand2 (xe, xn, wx, wy)

pointer 	xe, xn		# i: xexamine struct pointer
real		wx, wy		# i: cursor x & y readout

begin

	#  Save the current name in the undo buffer
	call strcpy (Memc[XE_QPNAME(xn)], Memc[XE_UNAME(xn)], SZ_PATHNAME)

	#  Compute a new block factor, going back to the original block
	#  when we get to 0.
        XE_SAVZM(xe) = XE_ZOOM(xe)
        XE_ZOOM(xe) = XE_ZOOM(xe) / XE_FACTOR(xe)
        if ( XE_ZOOM(xe) <= 0 ) {
	   XE_ZOOM(xe) = XE_BL(xe)
                
        }

	# Build a new name and display the image
	call build_imname2 (xe, xn, wx, wy)
	call disp_img2 (xe, xn)

end

# -------------------------------------------------------------------
#
# Function:     block_query2
# Purpose:  	Display the current block factor and auto-block factor    
#
# -------------------------------------------------------------------
procedure block_query2 (xe)

pointer xe 	# i: xexamine struct pointer

begin
	call printf ("\nBlock = %d, Auto block factor = %d\n\n")
          call pargi (XE_ZOOM(xe))
          call pargi (XE_FACTOR(xe))
end

# -------------------------------------------------------------------
#
# Function:     coord_query2
# Purpose: 	Display the coordinates of the cursor in
#               (hh:mm:ss.s dd:mm:ss.s, degrees, phys pixels)     
#
# -------------------------------------------------------------------
procedure coord_query2 (xe, wx, wy)

pointer	xe		# i: xexamine struct pointer
real    wx, wy		# i: cursor x & y readout


pointer omw, oct	# l: wcs pointers
real    dx, dy		# l: position in degrees
real    px, py		# l: position in physical pixels

pointer mw_openim()
pointer mw_sctran()

begin

	omw = mw_openim(XE_WIM(xe))

#   we subtract 0.5 from the tv position (wx,wy) to make the qpoe coordinate 
#   transformation consistent with image convention.
	oct = mw_sctran(omw, "logical", "physical", 3B)
#JCC(6/19/97) - don't subtract 0.5 to get wcs
#JCC    call mw_c2tranr(oct, (wx-0.5), (wy-0.5), px, py)
        call mw_c2tranr(oct, wx, wy, px, py)

	oct = mw_sctran(omw, "physical", "world", 3B)
        call mw_c2tranr(oct, px, py, dx, dy)

        call mw_close(omw)
        call printf ("\n%12H %12h  (%10.5f, %10.5f)  (%-7.1f,%7.1f)\n\n")
           call pargr (dx)
           call pargr (dy)
           call pargr (dx)
           call pargr (dy)
           call pargr (px)
           call pargr (py)
end

# -------------------------------------------------------------------
#
# Function:     disp_cmd2
# Purpose:      display the current image at the current block
#
# -------------------------------------------------------------------
procedure disp_cmd2(xe, xn, wx, wy)

pointer 	xe, xn		# i: xexamine struct pointer
real		wx, wy		# i: cursor x & y readout

begin

	call strcpy ( Memc[XE_QPNAME(xn)], Memc[XE_UNAME(xn)], SZ_PATHNAME)
        XE_SAVZM(xe) = XE_ZOOM(xe)
	call build_imname2 (xe, xn, wx, wy)
	call disp_img2 (xe, xn)

end

# -------------------------------------------------------------------
#
# Function:     redisplay2
# Purpose:      Redisplay the Original image
#    
#
# -------------------------------------------------------------------
procedure redisplay2 (xe, xn)

pointer 	xe, xn		# i: xexamine struct pointer

begin

	call strcpy (Memc[XE_ONAME(xn)], Memc[XE_QPNAME(xn)], SZ_PATHNAME)
        XE_SAVZM(xe) = XE_ZOOM(xe)
        XE_ZOOM(xe) = XE_BL(xe)
        call disp_img2 (xe, xn)
end

# -------------------------------------------------------------------
#
# Function:     undo_cmd2
# Purpose:      Restore the last filename as the current file and display
#
# -------------------------------------------------------------------
procedure undo_cmd2(xe, xn)

pointer 	xe, xn		# i: xexamine struct pointer

begin
	call strcpy (Memc[XE_UNAME(xn)], Memc[XE_QPNAME(xn)], SZ_PATHNAME)
        XE_ZOOM(xe) = XE_SAVZM(xe)
	call disp_img2 (xe, xn)
end

# -------------------------------------------------------------------
#
# Function:     set_block2
# Purpose:      Set a new block factor for the image display
#
# -------------------------------------------------------------------
procedure set_block2(xe, strval, ip)

pointer xe		# i: struct pointer
char 	strval[ARB]	# i: command buffer
int     ip		# i: parser pointer

int	block 		# input block 

int     ctoi()

begin


# parse the block factor out of the string and assign it to struct var
	if ( IS_DIGIT(strval[ip]) ) {

           if ( ctoi (strval, ip, block) > 0 ) {

              XE_ZOOM(xe) = block
	      call printf ("\nNew Block = %d\n\n")
                 call pargi (XE_ZOOM(xe))

           }

	} else {
	   call printf ("Syntax is -> :z # <- try again\n")
        }

end


# -------------------------------------------------------------------
#
# Function:     set_factor2
# Purpose:      Set a zoom factor; used with Auto-expand 
#
# -------------------------------------------------------------------
procedure set_factor2(xe, strval, ip)

pointer xe		# struct pointer
char 	strval[ARB]	# command buffer
int     ip		# buff pointer

int	factor		# new block factor

int     ctoi()


begin

# parse the auto-block factor out of the string and assign it to struct var
	if ( IS_DIGIT(strval[ip]) ) {

           if ( ctoi (strval, ip, factor) > 0 ) {

              XE_FACTOR(xe) = factor
	      call printf ("\nNew Auto Block factor = %d\n\n")
                 call pargi (XE_FACTOR(xe))

           }

	} else {
	   call printf ("Syntax is -> :f # <- try again\n")
        }
end

# -------------------------------------------------------------------
#
# Function:     set_cellsize2
# Purpose:      Set a cell size for source detection
#
# -------------------------------------------------------------------
procedure set_cellsize2(xe, strval, ip)

pointer xe		# i: struct pointer
char 	strval[ARB]	# i: command buffer
int     ip		# i: parser pointer

int	cellsize	# input cell size in arcseconds

int     ctoi()

begin


# parse the block factor out of the string and assign it to struct var
	if ( IS_DIGIT(strval[ip]) ) {

           if ( ctoi (strval, ip, cellsize) > 0 ) {

              XE_CSIZE(xe) = cellsize
	      call printf ("\nNew Cellsize = %d\n\n")
                 call pargi (XE_CSIZE(xe))

           }

	} else {
	   call printf ("Syntax is -> : c # <- try again\n")
        }

end

# -------------------------------------------------------------------
#
# Function:     disp_img2
# Purpose:      Open the current image, & call the Xdisplay task 
#
# -------------------------------------------------------------------
procedure disp_img2 (xe, xn)

pointer xe, xn		#i: struct pointer

int     frame		#l: frame for display

pointer immap()

begin

#  Open the current image and display.
        call imunmap(XE_IM(xe))
        XE_IM(xe) = immap ( Memc[XE_QPNAME(xn)], READ_ONLY, 0)

#  Also open the image for wcs transformations - no img section allowed.
        call imgimage ( Memc[XE_QPNAME(xn)], Memc[XE_WCSNAME(xn)], SZ_PATHNAME)

        call imunmap(XE_WIM(xe))
        XE_WIM(xe) = immap ( Memc[XE_WCSNAME(xn)], READ_ONLY, 0)

	if ( XE_DISPLAY(xe) > 0 ) {
           call printf ("Displaying: = %s\n")
              call pargstr (Memc[XE_QPNAME(xn)])
	}

        call xe_display2 (xe, Memc[XE_QPNAME(xn)], frame)

end

# -------------------------------------------------------------------
#
# Function:     proj_img2
# Purpose:      Open the current image and overlay an x/y projection 
#
# -------------------------------------------------------------------
procedure proj_img2 (xe, xn)

pointer xe, xn		# struct pointer

pointer immap()

begin

#  Open the current image and overlay a projection of the axes 
        call imunmap(XE_IM(xe))
        XE_IM(xe) = immap (Memc[XE_QPNAME(xn)], READ_ONLY, 0)

#  Also open the image for wcs transformations - no img section allowed.
        call imgimage ( Memc[XE_QPNAME(xn)], Memc[XE_WCSNAME(xn)], SZ_PATHNAME)
        call imunmap(XE_WIM(xe))
        XE_WIM(xe) = immap ( Memc[XE_WCSNAME(xn)], READ_ONLY, 0)

	if ( XE_DISPLAY(xe) > 0 ) {
           call printf ("Tvproj-ing: = %s\n")
              call pargstr (Memc[XE_QPNAME(xn)])
	}

        call xe_tvproj2(xe, Memc[XE_QPNAME(xn)], XE_GWDTH(xe))

end

# -------------------------------------------------------------------
#
# Function:     build_imname2
# Purpose:      Parse the current image name and build a new name.
#		Append the current block to the known filter, compute
#		new image section coordinates to fill the graphics
#		device.
#
# -------------------------------------------------------------------
procedure build_imname2 (xe, xn, lx, ly)

pointer 	xe, xn			# i: xexamine struct pointer
real		lx, ly			# i: cursor x & y readout

pointer 	isection , ksection     # l: image section specification
pointer 	img_filter,img_rootname # l: img filter and root
pointer 	sp			# l: space alloc pointer

int     	cl_index, cl_size	# l: name parsing counters
int     	il, ir, ib, it          # l: image window limits
#int     	ch, i, id, ip, n        # l: useful increment vars
#int     	ival[10], 		# l: parsed out block & section params
int     	hsize, zsize   		# l: detector and windo sizes
int             nchars
#int             detsize

pointer 	oct, omw		# l: wcs pointers
#pointer 	imhead			# l: imhead struct access pointer
real    	px, py			# l: physical coords
int     	zx, zy			# l: new coords

int             gstrcpy()
pointer 	mw_openim()		# l: wcs open func
pointer 	mw_sctran()		# l: wcs translate func

int        zsize_y        #JCC : zsize (zoom in x) ; zsize_y (zoom in y)

begin

        call smark (sp)
        call salloc (ksection, 		SZ_FNAME,    TY_CHAR)
        call salloc (isection, 		SZ_LINE,     TY_CHAR)
        call salloc (img_rootname,  	SZ_LINE,     TY_CHAR)
        call salloc (img_filter,        SZ_LINE,     TY_CHAR)

        # Parse the image name and separate the name root (img_rootname) 
        # from the image section (isection) and filter (ksection).
        call imparse (Memc[XE_QPNAME(xn)], Memc[img_rootname], SZ_PATHNAME,
            Memc[ksection], SZ_FNAME, Memc[isection], SZ_FNAME,
            cl_index, cl_size)

        if ( XE_DISPLAY(xe) >= 5 ) {
           call printf ("ksection=%s, isection=%s, cl_index=%d, cl_size=%d\n")
             call pargstr (Memc[ksection])
             call pargstr (Memc[isection])
             call pargi (cl_index)
             call pargi (cl_size)
        }

	# The filter section is in ksection ... parse it and separate 
	# out the block filter if there is one.
        nchars = gstrcpy (Memc[XE_FILT(xn)], Memc[img_filter], SZ_LINE) - 1 

        if ( nchars > 0 ) {
           call sprintf (Memc[img_filter+nchars], SZ_LINE-nchars, ",bl=%d]")
              call pargi(XE_ZOOM(xe))

	} else {

	   call sprintf (Memc[img_filter], SZ_LINE, "[bl=%d]")
              call pargi(XE_ZOOM(xe))
	}

        if ( XE_DISPLAY(xe) >= 5 ) {
           call printf ("filter = %s, nchars = %d, new filter = %s\n")
              call pargstr (Memc[XE_FILT(xn)])
              call pargi (nchars)
              call pargstr (Memc[img_filter])
	}

        # The image section is in isection ... parse the image section so
	# we can determine the current image center.

# commented out once I added the imgimage routine before the img open thats
# in use for the wcs.  The channel open is xe_wim.
#        i = 1; n = 0; id = BEG; ip = 0
#        call aclri (ival, 10)
         
#        for (ch= Memc[isection]; ch != EOS ; ch=Memc[isection+ip]) {
#           if (IS_DIGIT(ch)) {
#              n = (n * 10) + TO_INTEG(ch)
#           } else if ( (ch == ':') | (ch == ',') ) {
#              id = DONE
#           } else if (ch == ']') {
#              id = DONE
#           }
#
#           if ( id == DONE ) {
#              ival[i] = n
#              i = i + 1
#              id = BEG
#              n = 0
#           }
#           ip = ip + 1
#        }

	# Compute the new image section, combining the input subsection 
        # with the windo coordinates for the wcslab code
#       --- only worked for ROSAT pspc & hri --- replaced with XE_DLEN below
#        call get_imhead(XE_IM(xe), imhead)
#        if ( QP_INST(imhead) == ROSAT_PSPC ) {
#           detsize = ROSAT_PSPC_DIM
#
#        } else if ( QP_INST(imhead) == ROSAT_HRI ) {
#           detsize = ROSAT_HRI_DIM
#        }

     	omw = mw_openim(XE_WIM(xe))
	oct = mw_sctran(omw, "logical", "physical", 3B)

	# translate graph coords to logical image coords
#        lx = lx - ival[1] + 1
#        ly = ly - ival[3] + 1

	# translate logical coords to physical coords using the wcs
        call mw_c2tranr(oct, lx, ly, px, py)
        call mw_close(omw)

	# ... now compute the new image size and center from the phys coords

#        zsize = detsize / XE_ZOOM(xe)
        zsize   = XE_DLEN(xe) / XE_ZOOM(xe)  #JCC - keep it as zoom in X 
        zsize_y = XE_DLEN2(xe)/ XE_ZOOM(xe)  #JCC - new zoom factor in Y

        zx = int (px) / XE_ZOOM(xe)	
        zy = int (py) / XE_ZOOM(xe)

        if ( XE_DISPLAY(xe) >= 5 ) {
	   call printf ("zoom = %d\n")
              call pargi (XE_ZOOM(xe))
           call printf ("lx=%f, ly=%f\n")
              call pargr (lx)
              call pargr (ly)
           call printf ("px=%f, py=%f\n")
              call pargr (px)
              call pargr (py)
           call printf ("zx=%d, zy=%d, zoom_x=%d, zoom_y=%d\n")
              call pargi (zx)
              call pargi (zy)
              call pargi (zsize)
              call pargi (zsize_y)
        }

	# ... using the size and center; compute the new image section.
	# there are a few checks to assure we don't exceed our boundaries
 	hsize = XE_GWDTH(xe) / 2 

        ########################
        #JCC - checking the boundary for X
        il = max (1, (zx - hsize + 1))
        ir = zx + hsize 
        if ( ir > zsize ) {            # zsize:  zoom in X
           ir = zsize
        }

        #JCC - new : checking the boundary for Y
	ib = max (1, (zy - hsize + 1))
        it = zy + hsize 
        if ( it > zsize_y ) {          # zsize_y: zoom in Y
           it = zsize_y
        }
     
	# Store the new name with image section into the buffer for return
        call sprintf (Memc[XE_QPNAME(xn)], SZ_LINE, "%s%s[%d:%d,%d:%d]")
           call pargstr (Memc[img_rootname])
           call pargstr (Memc[img_filter])
           call pargi (il)
           call pargi (ir)
           call pargi (ib)
           call pargi (it)

        call sfree (sp)
end

# -------------------------------------------------------------------------
# debug procedure to identify and print the command key, tried to print the
# 'key' as a char but couldn't figure out how ... so we get a dump routine
# instead.
# -------------------------------------------------------------------------
procedure output_key2 (key, wx, wy)

int  key		# i: command key
real wx, wy		# i: tv coordinates

char buff[10]

begin
        #  identify the input key and print it
	switch (key) {

           case '?':
                call sprintf (buff, 10, "?")

           case 'a':
                call sprintf (buff, 10, "a")

	   case 'b':
                call sprintf (buff, 10, "b")

#JCC - 'c': write the cursor position (1:512, 1:512)
	   case 'c':
                call sprintf (buff, 10, "c")

           case 'd':
                call sprintf (buff, 10, "d")

	   case 'p':
                call sprintf (buff, 10, "p")

           case 'r':
                call sprintf (buff, 10, "r")

           case 'u':
                call sprintf (buff, 10, "u")

           case 's':
                call sprintf (buff, 10, "s")

	   case ':':
                call sprintf (buff, 10, ":")

           case 'q':
                call sprintf (buff, 10, "q")

           default:
                call sprintf (buff, 10, "unknown")
	}
#JCC - 'c': write the cursor position (1:512, 1:512)
        call printf ("\nKey = %s, Tv coords = (%-7.1f,%7.1f)\n")
              call pargstr (buff)
              call pargr (wx)
	      call pargr (wy)

end
