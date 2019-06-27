# $Header: /home/pros/xray/xproto/xexamine_r/RCS/xesetup2.x,v 1.2 1998/04/24 16:14:28 prosb Exp $
# $Log: xesetup2.x,v $
# Revision 1.2  1998/04/24 16:14:28  prosb
# Patch Release 2.5.p1
#
# Revision 1.1  1998/02/25 19:53:13  prosb
# Initial revision
#
#
# JCC(1/98) - updated to display a QPOE which is not a square.
#
# Revision 11.0  1997/11/06 16:38:40  prosb
# General Release 2.5
#
# ---------------------------------------------------------------------
# Module:       XESETUP.X
# ---------------------------------------------------------------------

include <coords.h>
include <error.h>
include <gset.h>
include <imhdr.h>
include <rosat.h>
include <qpoe.h>
include "xexamine2.h"

# ---------------------------------------------------------------------------
#
# Function:     xe_setup2
# Purpose:      Initialize and query graphics, input file, file params      
#
# ---------------------------------------------------------------------------
procedure xe_setup2 (xe, xn)

pointer xe, xn          	# u: struct pointer

pointer sp              	# l: allocation space pointer
pointer imgroot         	# l: root name of input file
pointer isection        	# l: image section
pointer imhead          	# l: pointer to struct with header info
pointer tty             	# l: i/o pointers
pointer device          	# l: image device

int     devx, devy      	# l: size of device in image pixels
int     cl_index, cl_size       # l: qpparse pointer
int     ylen			# l: length of y-axis

int     clgeti()
int     qp_access()
int     ttygeti()
pointer immap()
pointer ttygdes()
real    clgetr()

int     block_tmp

begin

        call smark (sp)
        call salloc (device, SZ_PATHNAME, TY_CHAR)
        call salloc (imgroot, SZ_PATHNAME, TY_CHAR)
        call salloc (isection, SZ_FILTER, TY_CHAR)

        # Zero out structure before we begin
        call aclri (Memi[xe], XE_SIZE)

        XE_DISPLAY(xe) = clgeti ("display")

        # Open the graphic windo and determine the size in image pixels
        call clgstr("graphics", Memc[device], SZ_PATHNAME)

        tty = ttygdes(Memc[device])
        devx = ttygeti (tty, "xr")
        devy = ttygeti (tty, "yr")
        call ttycdes (tty)
        if ( devx != devy ) {
          call error (1, "graph device not square")
        }
        XE_GWDTH(xe) = devx    #JCC = 512

        if ( XE_DISPLAY(xe) >= 2 ) {
           call printf ("\ngraph dimension: %d x %d\n")
             call pargi (devx)
             call pargi (devy)
        }

        # Check if input is a qpoe - we only work on Qpoes
        call imparse (Memc[XE_QPNAME(xn)], Memc[imgroot], SZ_PATHNAME,
            Memc[XE_FILT(xn)], SZ_FILTER, Memc[isection], SZ_FILTER,
            cl_index, cl_size)

        # Save the qpoe root as the input filename
        call strcpy (Memc[imgroot], Memc[XE_QPNAME(xn)], SZ_PATHNAME)

        if ( qp_access (Memc[XE_QPNAME(xn)], READ_ONLY) == NO ) {
            call printf ("\n")
            call error (1, "Task requires Qpoe file input")
        }

        # Open the input Qpoe and retrieve params
        XE_IM(xe) = immap (Memc[XE_QPNAME(xn)], READ_ONLY, 0)
        call get_imhead (XE_IM(xe), imhead)

        # Open the wcs transformation image - same as above but without
        #   image sections
        call imgimage (Memc[XE_QPNAME(xn)], Memc[XE_WCSNAME(xn)], SZ_PATHNAME)
        XE_WIM(xe) = immap ( Memc[XE_WCSNAME(xn)], READ_ONLY, 0)

        #JCC - DEGTOSA=(3600.0*($1)) # degree to arcsecond
        # XE_DAS = arcseconds per pixel
        XE_DAS(xe) =  real(DEGTOSA(abs(QP_CDELT1(imhead))))

        ########################
        XE_DLEN(xe) = IM_LEN(XE_IM(xe),1)      #JCC:  AXLEN1 in QPOE
        XE_DLEN2(xe)= IM_LEN(XE_IM(xe),2)      #JCC:  AXLEN2 in QPOE
        ylen = XE_DLEN2(xe)
        #JCC  if ( XE_DLEN(xe) != ylen ) {
	#JCC      call error (1, "Qpoe file must be square\n")
        #JCC  }

        XE_LEN(xe) = XE_GWDTH(xe)          #JCC: always 512

        #JCC: replace: XE_BL(xe) = max (XE_DLEN(xe)/XE_GWDTH(xe), 1)
        #     with the following two lines, so QPOE no need to be a square.
        block_tmp  = max (XE_DLEN(xe)/XE_GWDTH(xe), ylen/XE_GWDTH(xe) )

        #if (XE_DLEN(xe)==XE_DLEN2(xe))        #JCC - for a square QPOE
            XE_BL(xe)= max (block_tmp,   1)   #JCC- not work if AXLEN2<AXLEN1
        #else      #JCC - a non-square QPOE
           #XE_BL(xe)  = max (block_tmp+1, 1)   #JCC- test "+1"    
        ########################

        # assume  QP_CDELT1 = QP_CDELT2
        #JCC - XE_AS = arcseconds per pixel 
        XE_AS(xe) =  real(DEGTOSA(abs(QP_CDELT1(imhead)))) * XE_BL(xe)
        XE_ZOOM(xe) = XE_BL(xe)
        XE_SAVZM(xe) = XE_BL(xe)


        # Retrieve the auto-block factor from the param file, if 0 we set
        # a default of 2
        XE_FACTOR(xe) = clgeti ("auto")
        if ( XE_FACTOR(xe) == 0 ) {
          XE_FACTOR(xe) = 2
        }

        # Retrieve the detect cellsize from the param file, if 0 we set
        # a default of 30
        XE_CSIZE(xe) = clgeti ("cellsize")
        if ( XE_CSIZE(xe) == 0 ) {
          XE_CSIZE(xe) = 30
        }

        # Init the bkden to the user param, if 0.0 we will run the task
	# bkden if the detect source code is invoked.
        XE_BKDEN(xe) = clgetr ("bkden")
        call clputr ("bkden.value", XE_BKDEN(xe))

        call printf ("bkden=%f\n")
          call pargr (XE_BKDEN(xe))
        call flush (STDOUT)

        #JCC - XE_DLEN(xe) = AXLEN1 ;  
        #JCC - XE_LEN(xe) = 512 ;
        #JCC - ylen = AXLEN2 in QPOE = XE_DLEN2(xe) ;
        if ( XE_DISPLAY(xe) >= 2 ) {
      call printf ("\ndetector: arcsec/pix = %.1f, len_x = %d, len_y = %d\n\n")
             call pargr (XE_DAS(xe))
             call pargi (XE_DLEN(xe))
             call pargi (ylen)
           call printf ("display: arcsec/pix = %.1f, len = %d, block = %d\n\n")
             call pargr (XE_AS(xe))
             call pargi (XE_LEN(xe))
             call pargi (XE_BL(xe))
        }

        # display the menu before we start
        if ( XE_DISPLAY(xe) > 0 ) {
          call menu_disp2()
        }

        call sfree(sp)

end

# ----------------------------------------------------------------------------
# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
#
# slightly modified to call PROS xdisplay task ... taken from imexamine
#
# XE_DISPLAY -- Display an image.  For the sake of convenience in this
# prototype program we do this by calling a task via the cl.  This is an
# interface violation which we try to mitigate by using a CL parameter to
# hide the knowledge of how to format the command (as well as make it easy
# for the user to control how images are displayed).
# ----------------------------------------------------------------------------

procedure xe_display2 (xe, image, frame)

pointer	xe			#I imexamine descriptor
char	image[ARB]		#I image to be displayed
int	frame			#I frame in which to display image

int	nchars
pointer	sp, d_cmd, d_args, d_template, im
int	gstrcpy(), strmac()
#int    ie_getnframes()
pointer	immap()

begin
	call smark (sp)
	call salloc (d_cmd, SZ_LINE, TY_CHAR)
	call salloc (d_args, SZ_LINE, TY_CHAR)
	call salloc (d_template, SZ_LINE, TY_CHAR)

	# Verify that the named image or image section exists.
	iferr (im = immap (image, READ_ONLY, 0)) {
	    call erract (EA_WARN)
	    call sfree (sp)
	    return
	} else
	    call imunmap (im)

	# Get the display command template.
	call clgstr ("t_xdisplay", Memc[d_template], SZ_LINE)

	# Construct the macro argument list, a sequence of EOS delimited
	# strings terminated by a double EOS.

	call aclrc (Memc[d_args], SZ_LINE)
	nchars = gstrcpy (image, Memc[d_args], SZ_LINE) + 1
	call sprintf (Memc[d_args+nchars], SZ_LINE-nchars, "%d")
	    call pargi (frame)

	# Expand the command template to form the CL command.
	nchars = strmac (Memc[d_template], Memc[d_args], Memc[d_cmd], SZ_LINE)

	# Send the command off to the CL and wait for completion.
	call clcmdw (Memc[d_cmd])
#	nchars = ie_getnframes (ie)

	call sfree (sp)
end

# ---------------------------------------------------------------------------
#
# Function:     xe_tvproj2
# Purpose:      interpret the cursor key and invoke the appropriate
#               procedure to invode the command
#
# ---------------------------------------------------------------------
procedure xe_tvproj2 (xe, image, dim)

pointer	xe			#I imexamine descriptor
char	image[ARB]		#I image to be displayed
int     dim			#I dimension of graphics windo

int	nchars
pointer	sp, d_cmd, d_args, d_template, im
int	gstrcpy(), strmac()
pointer	immap()

begin
	call smark (sp)
	call salloc (d_cmd, SZ_LINE, TY_CHAR)
	call salloc (d_args, SZ_LINE, TY_CHAR)
	call salloc (d_template, SZ_LINE, TY_CHAR)

	# Verify that the named image or image section exists.
	iferr (im = immap (image, READ_ONLY, 0)) {
	    call erract (EA_WARN)
	    call sfree (sp)
	    return
	} else
	    call imunmap (im)

	# Get the display command template.
	call clgstr ("t_proj", Memc[d_template], SZ_LINE)

	# Construct the macro argument list, a sequence of EOS delimited
	# strings terminated by a double EOS.

	call aclrc (Memc[d_args], SZ_LINE)
	nchars = gstrcpy (image, Memc[d_args], SZ_LINE) + 1

#        call sprintf (Memc[d_args+nchars], SZ_LINE-nchars, "%d %d")
#            call pargi (dim)
#            call pargi (dim)

	# Expand the command template to form the CL command.
	nchars = strmac (Memc[d_template], Memc[d_args], Memc[d_cmd], SZ_LINE)

	# Send the command off to the CL and wait for completion.
	call clcmdw (Memc[d_cmd])

	call sfree (sp)
end

# ---------------------------------------------------------------------------
#
# Function:     xe_bepos2
# Purpose:      interpret the cursor key and invoke the appropriate
#               procedure to invode the command
#
# ---------------------------------------------------------------------
procedure xe_bepos2 (xe, image, ruftab)

pointer xe                      #I imexamine descriptor
char    image[ARB]              #I image to be displayed
char    ruftab[ARB]             #I rough positions table

int     nchars, nchars2, nchars3

pointer sp, im
pointer d_cmd, d_args, d_template
pointer postab

int     gstrcpy()
int     strmac()
pointer immap()

begin
        call smark (sp)
        call salloc (d_cmd, SZ_LINE*2, TY_CHAR)
        call salloc (d_args, SZ_LINE*2, TY_CHAR)
        call salloc (d_template, SZ_LINE*2, TY_CHAR)

        call salloc (postab, SZ_LINE, TY_CHAR)

        # Verify that the named image or image section exists.
        iferr (im = immap (image, READ_ONLY, 0)) {
            call erract (EA_WARN)
            call sfree (sp)
            return
        } else
            call imunmap (im)

        # Get the display command template.
        call clgstr ("t_bepos", Memc[d_template], SZ_LINE*2)

        call mktemp ("pos", Memc[postab], SZ_FNAME)
        call addextname (Memc[postab], ".tab", SZ_FNAME)

        # Construct the macro argument list, a sequence of EOS delimited
        # strings terminated by a double EOS.

        # Add arg1 - the qpoe name
        call aclrc (Memc[d_args], SZ_LINE)
        nchars = gstrcpy (image, Memc[d_args], SZ_LINE*2) + 1

        # Add arg2 - the rough positions name (a temp file)
        nchars2 = gstrcpy (ruftab, Memc[d_args+nchars], SZ_LINE*2) + nchars+1

        # Add arg3 - the best positions name (a temp file)
        nchars3 = gstrcpy (Memc[postab], Memc[d_args+nchars2], SZ_LINE*2) + nchars2+1

#         call printf ("d_args = %s\n")
#           call pargstr (Memc[d_args])

        # Expand the command template to form the CL command.
        nchars = strmac (Memc[d_template], Memc[d_args], Memc[d_cmd], SZ_LINE*2)

#         call printf ("d_cmd = %s\n")
#           call pargstr (Memc[d_cmd])

        # Send the command off to the CL and wait for completion.
        call clcmdw (Memc[d_cmd])

        call tbtdel (Memc[postab])

        call sfree (sp)
end

# ---------------------------------------------------------------------------
#
# Function:     xe_bkden2
# Purpose:      interpret the cursor key and invoke the appropriate
#               procedure to invoke the command
#
# ---------------------------------------------------------------------
procedure xe_bkden2 (xe, image)

pointer	xe			#I imexamine descriptor
char	image[ARB]		#I image to be displayed

int	nchars
pointer	sp, d_cmd, d_args, d_template, im
int	gstrcpy(), strmac()
pointer	immap()

begin
	call smark (sp)
	call salloc (d_cmd, SZ_LINE, TY_CHAR)
	call salloc (d_args, SZ_LINE, TY_CHAR)
	call salloc (d_template, SZ_LINE, TY_CHAR)

	# Verify that the named image or image section exists.
	iferr (im = immap (image, READ_ONLY, 0)) {
	    call erract (EA_WARN)
	    call sfree (sp)
	    return
	} else
	    call imunmap (im)

	# Get the display command template.
	call clgstr ("t_bkden", Memc[d_template], SZ_LINE)

	# Construct the macro argument list, a sequence of EOS delimited
	# strings terminated by a double EOS.

	call aclrc (Memc[d_args], SZ_LINE)
	nchars = gstrcpy (image, Memc[d_args], SZ_LINE) + 1

	# Expand the command template to form the CL command.
	nchars = strmac (Memc[d_template], Memc[d_args], Memc[d_cmd], SZ_LINE)

	# Send the command off to the CL and wait for completion.
	call clcmdw (Memc[d_cmd])

	call sfree (sp)
end
