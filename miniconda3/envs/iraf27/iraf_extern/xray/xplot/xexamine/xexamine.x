# $Header: /home/pros/xray/xplot/xexamine/RCS/xexamine.x,v 11.0 1997/11/06 16:38:43 prosb Exp $
# $Log: xexamine.x,v $
# Revision 11.0  1997/11/06 16:38:43  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:07  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:24:57  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:50:08  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:42:52  prosb
#General Release 2.2
#
#Revision 5.1  92/12/01  14:46:16  janet
#*** empty log message ***
#
#Revision 1.3  92/10/14  16:34:41  janet
#fixed typo in printf statement.
#
#Revision 1.2  92/10/01  09:35:16  janet
#added wcs name (image name with section stripped) for wcs i/o.
#
#Revision 1.1  92/09/30  12:08:32  janet
#Initial revision
#
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
include "xexamine.h"

procedure t_xexamine()

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

        # Read in image name and assure that a filename was input
        call clgstr("qpoe", Memc[XE_QPNAME(xn)], SZ_PATHNAME)
        call rootname ("", Memc[XE_QPNAME(xn)], EXT_QPOE, SZ_PATHNAME)
        if ( ck_none (Memc[XE_QPNAME(xn)]) ) {
           call error (1, "Reference qpoe filename required!!")
        }
        call printf ("\n << Note!! User specified Blocking and Image Sections are ignored >>\n\n")

        # Init the graphics, detector, and image params
        call xe_setup (xe, xn)

        # Display the image before we start
        wx = float (XE_DLEN(xe)) / 2.0 ; wy = wx
        call disp_cmd (xe, xn, wx, wy)

        # Save the input image name for 'restore' and 'undo' commands
        call strcpy (Memc[XE_QPNAME(xn)], Memc[XE_ONAME(xn)], SZ_PATHNAME)
        call strcpy (Memc[XE_QPNAME(xn)], Memc[XE_UNAME(xn)], SZ_PATHNAME)

        in_wcs = 1
        pause = YES
        done = FALSE
        call clgstr ("graphics", Memc[gwindo], SZ_LINE)

	# Loop on cursor read-in until the 'quit' command is input
        while (imdrcur (Memc[gwindo], wx, wy, wcs, key, Memc[strval],
			SZ_LINE, in_wcs, pause) != EOF ) {

            if ( XE_DISPLAY(xe) >= 5 ) {
               call printf ("%8.2f %8.2f %d %d %s\n")
                  call pargr (wx)
                  call pargr (wy)
                  call pargi (wcs)
                  call pargi (key)
                  call pargstr (Memc[strval])
	    }

	    # Interpret the key-stroke and perform the action
            call interp_key (xe, xn, wx, wy, wcs, key, Memc[strval], done)

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
