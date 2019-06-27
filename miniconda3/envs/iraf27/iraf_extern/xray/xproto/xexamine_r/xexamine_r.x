# $Header: /home/pros/xray/xproto/xexamine_r/RCS/xexamine_r.x,v 1.2 1998/04/24 16:14:33 prosb Exp $
# $Log: xexamine_r.x,v $
# Revision 1.2  1998/04/24 16:14:33  prosb
# Patch Release 2.5.p1
#
# Revision 1.1  1998/02/25 19:51:56  prosb
# Initial revision
#
#
# JCC(1/98) - Updated 'xexamine' to allow a non-square QPOE
#
# Revision 11.0  1997/11/06 16:38:43  prosb
# General Release 2.5
#
# ---------------------------------------------------------------------
#
# Module:       XEXAMINE.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Task to display and manipulate qpoe graphically
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- August 1992 -- initial version
#               {1} JD -- Sept 92 -- added wcsname 
#				     (image name  w/ section stripped)
#               {2} JD -- Nov 92 -- added source detection 's' command
#               {#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------
include <ctype.h>
include <ext.h>
include <mach.h>
include <fset.h>
include "xexamine2.h"

procedure t_xexamine_r()

bool    done			# indicates that session is complete

int     key			# cursor input key
int     in_wcs
int     pause
int     wcs

pointer strval			# colon commad parsing buffer
  
pointer gwindo			# graphics windo pointer
pointer sp			# salloc pointer
pointer xe, xn			# pointer to struct 
        
real    wx, wy			# cursor graphics coords

bool    ck_none()		# check against no input file
int     imdrcur()		# image cursor reading

begin
        call fseti (STDOUT, F_FLUSHNL, YES)

        call smark(sp)
        call salloc (gwindo,    SZ_LINE,     TY_CHAR)
	call salloc (strval,	SZ_LINE,     TY_CHAR)

        call malloc (xn, XE_BUFF, TY_STRUCT)
        call malloc (xe, XE_SIZE, TY_STRUCT)

        call malloc (XE_QPNAME(xn),SZ_PATHNAME, TY_CHAR)
        call malloc (XE_ONAME(xn), SZ_PATHNAME, TY_CHAR)
        call malloc (XE_UNAME(xn), SZ_PATHNAME, TY_CHAR)
        call malloc (XE_WCSNAME(xn),SZ_PATHNAME, TY_CHAR)
        call malloc (XE_FILT(xn),  SZ_PATHNAME, TY_CHAR)

#JCC(1/28/98)
call printf("===============================================\n")
call printf("  The xplot package is required for this task. \n")
call printf("===============================================\n")

        # Read in image name and assure that a filename was input
        call clgstr("qpoe", Memc[XE_QPNAME(xn)], SZ_PATHNAME)
        call rootname ("", Memc[XE_QPNAME(xn)], EXT_QPOE, SZ_PATHNAME)
        if ( ck_none (Memc[XE_QPNAME(xn)]) ) {
           call error (1, "Reference qpoe filename required!!")
        }
        call printf ("\n << Note!! User specified Blocking and Image Sections are ignored >>\n\n")

        # Init the graphics, detector, and image params
        call xe_setup2 (xe, xn)

        # Display the image before we start
        wx = float (XE_DLEN(xe)) / 2.0 ; 
        ########################
        #JCC(1/98)- wy = wx
        #JCC(1/98)- allow non-square QPOE ; replace the line wy=wx with : 
        wy = float (XE_DLEN2(xe)) / 2.0 ;
        ########################

        call disp_cmd2 (xe, xn, wx, wy)   #display image for the first time 

        ########################
        #JCC - (wx,wy) should start with (AXLEN1/2, AXLEN2/2)
        if ( XE_DISPLAY(xe) >= 5 ) {
           call printf ("\nwx,wy start with %8.2f %8.2f\n\n")
           call pargr (wx)
           call pargr (wy)
        }
        ########################

        # Save the input image name for 'restore' and 'undo' commands
        call strcpy (Memc[XE_QPNAME(xn)], Memc[XE_ONAME(xn)], SZ_PATHNAME)
        call strcpy (Memc[XE_QPNAME(xn)], Memc[XE_UNAME(xn)], SZ_PATHNAME)

        in_wcs = 1
        pause = YES
        done = FALSE
        call clgstr ("graphics", Memc[gwindo], SZ_LINE)

	# Loop on cursor read-in until the 'quit' command is input
        #
        # JCC -  strval is an output from imdrcur(iraf code) -NULL string
        #
        while (imdrcur (Memc[gwindo], wx, wy, wcs, key, Memc[strval],
			SZ_LINE, in_wcs, pause) != EOF ) {

#
#JCC - screen display when display=5 in xexamine_r.par
#JCC   ==    240.00   236.99 201 99             (==   wx, wy, wcs, key)
#JCC   Key = c, Tv coords = (240.0  ,  237.0)   (from interp_keys/output_key2)
#
            if ( XE_DISPLAY(xe) >= 5 ) {
               call printf ("==  %8.2f %8.2f %d %d **%s**\n")
                  call pargr (wx)
                  call pargr (wy)
                  call pargi (wcs)
                  call pargi (key)
                  call pargstr (Memc[strval])    #JCC - a NULL string
	    }

	    # Interpret the key-stroke and perform the action
            #JCC-screen display:   Key = c, Tv coords = (240.0  ,  237.0)
            call interp_key2 (xe, xn, wx, wy, wcs, key, Memc[strval], done)

            if ( done ) { 
               break
	    }
	}

        call mfree (XE_QPNAME(xn), TY_CHAR)
        call mfree (XE_ONAME(xn),  TY_CHAR)
        call mfree (XE_UNAME(xn),  TY_CHAR)
        call mfree (XE_FILT(xn),   TY_CHAR)
        call mfree (XE_QPNAME(xn), TY_CHAR)

        call mfree (xe, TY_STRUCT)
        call mfree (xn, TY_STRUCT)

        call sfree (sp)
end
