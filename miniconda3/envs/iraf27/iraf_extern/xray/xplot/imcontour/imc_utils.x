#$Header: /home/pros/xray/xplot/imcontour/RCS/imc_utils.x,v 11.0 1997/11/06 16:38:12 prosb Exp $
#$Log: imc_utils.x,v $
#Revision 11.0  1997/11/06 16:38:12  prosb
#General Release 2.5
#
#Revision 9.2  1997/06/11 17:58:18  prosb
#JCC(6/11/97) - change INDEF to INDEFR.
#
#Revision 9.1  1997/03/05 19:23:06  prosb
#JCC(3/5/97) - use mw_open to set the wcs flag in has_wcs()
#
#Revision 9.0  1995/11/16  19:09:03  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:23  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/15  11:56:15  janet
#jd - fixed PIXMM comparison to 0
#
#Revision 7.0  93/12/27  18:48:47  prosb
#General Release 2.3
#
#Revision 6.2  93/12/17  08:56:42  janet
#jd - added 'fill' param for tv display.
#
#Revision 6.1  93/07/02  15:10:36  mo
#MC	7/2/93		Remove redundant == TRUE (RS6000 port)
#
#Revision 6.0  93/05/24  16:41:17  prosb
#General Release 2.2
#
#Revision 5.1  93/04/06  11:56:44  janet
#updated for non-square image display, scale based on longest side.
#
#Revision 5.0  92/10/29  22:35:20  prosb
#General Release 2.1
#
#Revision 4.1  92/10/25  18:55:39  mo
#MC     Make CDELT DP
#
#Revision 4.0  92/04/27  17:32:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/24  16:45:05  janet
#removed ra/dec/as input when not wcs in image hdr.  defaults to pix plot.
#
#Revision 3.1  92/04/22  15:16:00  janet
#*** empty log message ***
#
#Revision 3.0  91/08/02  01:24:06  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:45  wendy
#Initial revision
#
#Revision 2.1  91/04/03  12:04:35  janet
#Updated code to work on input image with WCS but no xray hdr.  Added has_wcs.
#
#Revision 2.0  91/03/06  23:21:12  pros
#General Release 1.0
#
# ---------------------------------------------------------------------
#
# Module:       IMC_UTILS()
# Project:      PROS -- ROSAT RSDC
# Purpose:      imcontour utility routines
# Includes:     graph_open(), map_params(), grid_scale(), prj_const()
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- October 1989 -- initial version
#               {1} JD -- July 1991 -- Changed Scale features to accept
#                         1 y scale value and ratio.  Removed separate
#                         scales for Sky and PIX maps and replaced with
#                         a single parameter.
#               {2} JD -- July 1991 -- Updated Mrk_srcs to check that
#                         source position is in field.  Also added addi-
#                         tional options for marking sources. Digit/char/
#                         or char&digit.
#               {3} JD -- Apr 1992 -- removed ra/dec input from param file
#                         when no wcs available.  With new wcslab software,
#                         it only got written to the legend and a pixel plot
#                         was displayed through wcslab.  This way my code
#                         will handle the pixel plot and the user will
#                         get a message.
#               {4} JD -- Dec 1992 -- grid_scale - updated so that default 
#		          scale is based on the longer image axis length
#                         when plotting to std plot, also updated imd plot
#			  to pick up graph limits from the previously opened
#			  device which in this case will be from the 'display'
#			  task.
#               {n} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------

include <gset.h>
include <math.h>
include <imhdr.h>
include <qpoe.h>
include <mach.h>
include "imcontour.h"
include "clevels.h"

# ---------------------------------------------------------------------
#
# Function:     graph_open()
# Purpose:      open the graphics device
# Returns:      graphics pointer and constants structure pointer
#
# ---------------------------------------------------------------------
procedure graph_open (device, sdevice, debug, gp, devgc)

char    device[ARB]             # i: graphics device string
char    sdevice[ARB]            # i: scale device string
int     debug                   # i: display level
pointer gp                      # o: Graphics descriptor pointer
real    devgc[4]                # o: device mm in x & y & aspect ratio
                                #    from graphcap file

pointer sgp                     # l: Scale descriptor pointer
char    sstr[4]                 # l: scale device
char    gstr[4]                 # l: graph device

pointer gopen()
bool    streq()
real    ggetr()

begin

#   if stdgraph or stdplot is imd device, assign the other also
         call sprintf (gstr, 3, "%.3s")
           call pargstr (device)
         if ( streq (gstr, "imd") ) {
            call strcpy (device, sdevice, SZ_LINE)
         }

         call sprintf (sstr, 3, "%.3s")
           call pargstr (sdevice)
         if ( streq(sstr,"imd") ) {
            call strcpy (sdevice, device, SZ_LINE)
         }

         if ( debug > 0 ) {
            call printf ("\n\t Plot Device is %s & Scale Device is %s\n\n")
             call pargstr (device)
             call pargstr (sdevice)
         }

#   Open graphics
        sgp = gopen (sdevice, NEW_FILE+AW_DEFER, STDGRAPH)
#   get the mm in x and y along with the aspect ratio from the scale device
        devgc[XMM] = ggetr (sgp, "xs") * 1000.0
        devgc[YMM] = ggetr (sgp, "ys") * 1000.0
        devgc[AR] = ggetr (sgp, "ar")
        if  ( debug >= 5 ) {
           call printf ("Scale Device params xs = %f, ys = %f, ar = %f\n")
              call pargr (devgc[XMM])
              call pargr (devgc[YMM])
              call pargr (devgc[AR])
        }
#   determine whether the scale device is printer or gterm window
        if (streq (sdevice, "stdplot") | streq(sdevice, "STDPLOT") ) {
           devgc[DEV] = PAPER
        } else {
           devgc[DEV] = SCREEN
        }

#   determine whether scale and graph device are the same
#   - open graph device if not
        if ( streq (device, sdevice) ) {
           call greactivate (sgp, AW_CLEAR)
           gp = sgp
        } else {
           call gclose(sgp)
           gp = gopen (device, NEW_FILE, STDGRAPH)
        }
        call gclear (gp)
        call gseti (gp, G_TXQUALITY, GT_HIGH)

end
# ---------------------------------------------------------------------
#
# Function:     map_parms()
# Purpose:      retrieve map parameters; field center, image scale, area
# Returns:      ra, dec, block factor, axis len in radians, img size in pixels
#
# ---------------------------------------------------------------------
procedure map_parms (doimg, map, im, plt_const, display, posdiff)

bool    doimg                   # i: do we have an image to plot
int     map                     # i: sky or pixel map
int     display                 # i: debug output level
pointer im                      # i: image handle
pointer plt_const               # i: plot struct constants pointer
real    posdiff

pointer imhead                  # l: image header struct pointer
pointer sp                      # l: stack pointer
pointer sclbuf                  # l: input buffer for scales
pointer omw, oct
int     nchar                   # l: chars returns from pixmm string
int     ip                      # l: ctor pointer
int     wcshead                 # l: indicates whether wcs available
real    pixmm[2]                # l: pix per mm in x & y
real    asmm[2]                 # l: arc secs per mm in x & y
real    aspix[2]                # l: arc secs per pix in x & y
real    rra, rdec
#real    tra, tdec
real    xpixcen, ypixcen
real    fakesize
real    xy_ratio                # l: x to y scale ratio

#double clgetd()
real    clgetr()
real    ctor()
pointer mw_sctran()
pointer mw_openim()
int     has_wcs()

begin
        call smark(sp)
        call calloc (sclbuf, SZ_LINE, TY_CHAR)

        fakesize = 0.0
        posdiff = 0.0
        DEFSCALE(plt_const) = DEFAULT

#   Get current image dimension
        if ( doimg ) {
           IMPIXX(plt_const) = real (IM_LEN(im,1))
           IMPIXY(plt_const) = real (IM_LEN(im,2))
           call get_imhead (im, imhead)
           wcshead = has_wcs(im)
        } else {
           IMPIXX(plt_const) = fakesize
           IMPIXY(plt_const) = fakesize
        }
        xpixcen = IMPIXX(plt_const)*0.5
        ypixcen = IMPIXY(plt_const)*0.5

#   Check if we have an xray image header on this file - read the vals if true
#   Get ra & dec from hdr (default to user input if not in hdr)
        if ( wcshead == YES ) {
           omw = mw_openim(im)

#   Get Ra & Dec for plotting and labeling the plot
           oct = mw_sctran(omw, "logical", "world", 3B)
           call mw_c2tranr(oct, xpixcen, ypixcen, rra, rdec)
           call mw_close(omw)

#          if ( ( map == SKY ) &&
#              ( QP_CROTA2(imhead)< -EPSILONR || QP_CROTA2(imhead)> EPSILONR )){
#               map = PIXEL
#               call printf ("\n**Rotation Angle = %.2f - 
#		              Only PIXEL Map Availab le**\n\n")
#                 call pargr(QP_CROTA2(imhead))
#          }

#   If sky map display Warning if center is not tangent direction
#          if ( map == SKY ) {
#             tra = QP_CRVAL1(imhead); tdec = QP_CRVAL2(imhead)
#             if (tra != rra | tdec != rdec) {
#                posdiff = sqrt ((tdec-rdec)**2 + ((tra-rra)*cos(tdec))**2 )
#                call printf ("\n**Grid Inaccurate: Image center - projection di
#		 rection = %.4f deg.**\n\n")
#                  call pargr (posdiff)
#                if ( display >= 2 ) {
#                    call printf ("\n")
#                   call printf ("Tangent Direction in degrees: %f %f\n")
#                    call pargr (QP_CRVAL1(imhead))
#                    call pargr (QP_CRVAL2(imhead))
#
#                   call printf ("Image Center in degrees: %f %f\n\n")
#                    call pargr (rra)
#                    call pargr (rdec)
#                }
#             }
#          }
           CEN_RA(plt_const) = DEGTORAD(rra)
           CEN_DEC(plt_const) = DEGTORAD(rdec)
        } else if ( map == SKY ) {
#   taking out the possibility to make a sky map when no wcs available, apr 92.
             map = PIXEL
             call printf ("No WCS available in header, setting map to PIXEL\n")
             call flush(STDOUT)
#            CEN_RA(plt_const) = HRSTORAD(clgetd ("racen"))
#            CEN_DEC(plt_const) = DEGTORAD(clgetd ("deccen"))
        }

        if ( map == SKY ) {

#   Get arcsecs_per_pixel from hdr (default to user if not in hdr)
           if ( wcshead == YES ) {
#   take absolute because ra stored as negative in wcs
              aspix[1] = real(DEGTOSA(abs(QP_CDELT1(imhead))))
           } else {
              call clgstr ("arcsecs_pix", Memc[sclbuf], SZ_LINE)
              ip = 1
              nchar = ctor(Memc[sclbuf], ip, aspix[1])
           }
           SAPERPIXX(plt_const) = aspix[1]

           if ( wcshead == YES ) {
#   take absolute because I always want a positive
              aspix[2] = real(DEGTOSA(abs(QP_CDELT2(imhead))))
           } else {
              nchar = ctor(Memc[sclbuf], ip, aspix[2])
              if ( aspix[2] == 0.0 ) {
                 aspix[2] = aspix[1]
              }
           }
           SAPERPIXY(plt_const) = aspix[2]

#   Get original x dimension from hdr (default to current imlen if not in hdr)
           asmm[2] = clgetr ("scale")
           xy_ratio = clgetr ("xy_scale_ratio")
           asmm[1] = asmm[2] * xy_ratio
           SAPERMMX(plt_const) = asmm[1]
           SAPERMMY(plt_const) = asmm[2]
           if (SAPERMMX(plt_const) < EPSILONR) {
              PIXMMX(plt_const) = 0.0
           } else {
#             SAPERMMX(plt_const)=SAPERMMX(plt_const)*cos(CEN_DEC(plt_const))
              PIXMMX(plt_const) = SAPERMMX(plt_const) / SAPERPIXX(plt_const)
              DEFSCALE(plt_const) = USER
           }
           if (SAPERMMY(plt_const) < EPSILONR) {
              PIXMMY(plt_const) = 0.0
           } else {
              PIXMMY(plt_const) = SAPERMMY(plt_const) / SAPERPIXY(plt_const)
           }

        } else if ( map == PIXEL ) {
           pixmm[2] = clgetr ("scale")
           xy_ratio = clgetr ("xy_scale_ratio")
           pixmm[1] = pixmm[2] * xy_ratio
           PIXMMX(plt_const) = pixmm[1]
           PIXMMY(plt_const) = pixmm[2]
        }

        if ( display >= 3 ) {
           call printf ("img center x = %f, y = %f\n")
              call pargr (xpixcen)
              call pargr (ypixcen)
           call printf("ra %f --- dec %f\n")
              call pargd(RADTODEG(CEN_RA(plt_const)))
              call pargd(RADTODEG(CEN_DEC(plt_const)))
           if ( map == SKY ) {
              call printf("arcsec per pix x: %f --- y: %f\n")
                call pargr(SAPERPIXX(plt_const))
                call pargr(SAPERPIXY(plt_const))
           }
        }
        call sfree(sp)
end

# ---------------------------------------------------------------------
#
# Function:     has_wcs()
# Purpose:      check if wcs params are available from header
# Notes:        get_imhead must be called before this routine
#
# ---------------------------------------------------------------------
int procedure has_wcs(im)

pointer im

#JCC
pointer mw, mw_open()
errchk  mw_open()
#int    x_accessf()

begin

#JCC(3/5/97)- if an error from mw_open, return NO wcs.
        iferr (mw = mw_open (NULL, 2) )  {
           call mw_close(mw)
           return (NO)
        }
#JCC    if ( x_accessf(im, "CRVAL1") == NO)
#JCC       return (NO)
#JCC    if ( x_accessf(im, "CRVAL2") == NO)
#JCC       return (NO)
#       if ( x_accessf(im, "CDELT1") == NO)
#          return (NO)
#       if ( x_accessf(im, "CDELT2") == NO)
#          return (NO)
#       if ( x_accessf(im, "CROTA2") == NO)
#          return (NO)

        call mw_close(mw)
        return (YES)

end

# ---------------------------------------------------------------------
#
# Function:     grid_scale()
# Purpose:      setup grid windows for skymap and pixel maps
# Notes:        The coordinate parameters for the various plotting windows
#               are set up and are later referred to by the names assigned
#               in this routine.
#
# ---------------------------------------------------------------------
procedure grid_scale (gp, im, plt_const, debug, devgc)

pointer gp                      # i: graphics pointer
pointer im                      # i: image pointer
pointer plt_const               # i: constants structure pointer
int     debug                   # i: debug level
real    devgc[4]                # i: device mm in x & y and aspect ratio

int     frame                   # l: display frame

bool    fill                    # l: indicates whether to fill graph window
bool    setx, sety              # l: indicates whether x/y limits are set

real    skymmy, skymmx          # l: Width of chart in mm
real    im_mmx, im_mmy          # l: half the number of pixels on a side
real    dist, midpt
real    vl, vr, vb, vt          # l: virtual box coords
real    wl, wr, wb, wt          # l: windo box coords
real    pl, pr, pb, pt

bool    clgetb()

begin

        setx = FALSE
        sety = FALSE

        if ( clgetb ("perim") ) {
#   Set plot size to chart scale and width
           vl = 0.10;  vr = 0.80
           vb = 0.10;  vt = 0.90
        } else {
           vl = 0.0;  vr = 1.0
           vb = 0.0;  vt = 1.0
        }
        skymmx = (vr - vl) * devgc[XMM]
        skymmy = (vt - vb) * devgc[YMM]

        if ( devgc[DEV] == PAPER ) {

# Set default scale - the scale is based on the longest axis of the
# input image if they are not equal.  
           if ( (PIXMMX(plt_const) < EPSILONR ) && 
                (PIXMMY(plt_const) < EPSILONR ) ) {
		if ( IMPIXX(plt_const) >= IMPIXY(plt_const) ) {
                   pl = 1.0;  pr = IMPIXX(plt_const)
                   PIXMMX(plt_const) = IMPIXX(plt_const) / skymmx

                   PIXMMY(plt_const) = PIXMMX(plt_const)
                   setx = TRUE 
		} else { 

                   pb = 1.0;  pt = IMPIXY(plt_const)
                   PIXMMY(plt_const) = IMPIXY(plt_const) / skymmy
                
                   PIXMMX(plt_const) = PIXMMY(plt_const)
                   sety = TRUE
	        }
	   }

#   Set x space when image scale < sky scale ... reduce plotting width
           if ( ! setx ) {

              im_mmx = IMPIXX(plt_const) / PIXMMX(plt_const)
              if ( im_mmx < skymmx ) {

                 dist = ( im_mmx / devgc[XMM] ) * 0.5
                 midpt = ((vr-vl) *.5) + vl

                 vl = midpt - dist;  vr = midpt + dist
                 skymmx = (vr - vl) * devgc[XMM]

                 pl = 1.0; pr = IMPIXX(plt_const)

#   Set x space when image scale > sky scale ... chop off end of image
              } else {
                 if ( im_mmx > skymmx ) {

                    dist = skymmx * PIXMMX(plt_const) * 0.5
                    midpt = IMPIXX(plt_const) * 0.5

                    pl = midpt - dist; pr = midpt + dist
#                } else {
#                    call error (1, "Xscale out of range")
                 }
              }
           }

           if ( ! sety ) {

#   Set Y space when image scale < sky scale ... reduce plotting height
              im_mmy = IMPIXY(plt_const) / PIXMMY(plt_const)
              if ( im_mmy < skymmy ) {

                 dist = ( im_mmy / devgc[YMM] ) * 0.5
                 midpt = ((vt-vb) *.5) + vb

                 vb = midpt - dist;  vt = midpt + dist
                 skymmy = (vt - vb) * devgc[YMM]

                 pb = 1; pt = IMPIXY(plt_const)

#   Set Y space when image scale > sky scale ... chop off ends of image
              } else {

                 if ( im_mmy > skymmy ) {

                    dist = skymmy * PIXMMY(plt_const) * 0.5
                    midpt = IMPIXY(plt_const) *.5
                    pb = midpt - dist; pt = midpt + dist

#                } else {
#                   call error (1, "Yscale out of range")
                 }
              }
           }

#   Scale device is NOT stdplot - we don't compute absolute scale but only
#                                 assure that the pixels are square
        } else if ( devgc[DEV] == SCREEN ) {
           if ( PIXMMX(plt_const) < EPSILONR ) {
             PIXMMX(plt_const) = IMPIXX(plt_const) / skymmx
           }

           if ( PIXMMY(plt_const) < EPSILONR ) {
              PIXMMY(plt_const) = IMPIXY(plt_const) / skymmy
           }

           if ( devgc[AR] < 1.0 ) {
              pl = 1; pr = IMPIXX(plt_const)
              midpt = IMPIXY(plt_const) * 0.5
              dist = ((vt - vb)/(vr - vl)*devgc[AR]*IMPIXY(plt_const)) * 0.5
              pb = midpt - dist; pt = midpt + dist

           } else if ( devgc[AR] > 1.0 ) {
              pb = 1; pt = IMPIXY(plt_const)
              midpt = IMPIXX(plt_const) * 0.5
              dist = ((vr - vl)/(vt - vl)*devgc[AR]*IMPIXX(plt_const)) * 0.5
              pl = midpt - dist; pr = midpt + dist

           } else {
              pl = 1; pr = IMPIXX(plt_const)
              pb = 1; pt = IMPIXY(plt_const)
           }

           frame=1
           fill = clgetb ("fill")
           if ( fill ) {
              vl= 0.0; vr= 1.0; vb= 0.0; vt= 1.0 
           } else {
              #vl= INDEF; vr= INDEF; vb= INDEF; vt= INDEF
              vl= INDEFR; vr= INDEFR; vb= INDEFR; vt= INDEFR  #JCC(97)
           }
           call wl_imd_viewport (frame, im, pl, pr, pb, pt, vl, vr, vb, vt)

        } else {
           call error(1,"Graphics Output must be to SCREEN or PAPER")
        }

        if ( debug >= 3 ) {
           call printf("virtual windo: %f, %f, %f, %f\n")
              call pargr(vl); call pargr(vr); call pargr(vb); call pargr(vt)
           call printf("pixel windo: %f, %f, %f, %f\n")
              call pargr(pl); call pargr(pr); call pargr(pb); call pargr(pt)
        }

#   Set the plot window for IMAGE in pixels
        call gseti  (gp, G_WCS, PIX_WCS)
        call gsview (gp, vl, vr, vb, vt)
        call gswind (gp, pl, pr, pb, pt)

#   Set the plot window for SKYPLOT in MM
        call gseti (gp, G_WCS, MM_R_WCS)
        call gsview (gp, vl, vr, vb, vt)
        wt = skymmy / 2.0; wb = -wt
        wl = skymmx / 2.0; wr = -wl
        call gswind (gp, wl, wr, wb, wt)

#   Set the plot window/viewport for the legend
        call gseti (gp, G_WCS, LEGEND_WCS)
        vl = 0.815;  vr = 0.99
        vb = 0.05;    vt = 0.90
        call gsview (gp, vl, vr, vb, vt)
        wl = 0.0;  wr = 1.0
        wb = real (TEXT_LINES) + 0.5;  wt = 0.5
        call gswind (gp, wl, wr, wb, wt)

#   Set the plot window/viewport for the title
        call gseti (gp, G_WCS, TITLE_WCS)
        vl = 0.10;  vr = 0.80
        vb = 0.91;    vt = 0.99
        call gsview (gp, vl, vr, vb, vt)
        wl = 1.0;  wr = 80.0
        wb = 0.0;  wt = 1.0
        call gswind (gp, wl, wr, wb, wt)

#   Set the plot window/viewport for the tangent warning
        call gseti (gp, G_WCS, WARN_WCS)
        vl = 0.10;  vr = 0.80
        vb = 0.01;    vt = 0.10
        call gsview (gp, vl, vr, vb, vt)
        wl = 1.0;  wr = 80.0
        wb = 0.0;  wt = 1.0
        call gswind (gp, wl, wr, wb, wt)

#  Set up projection constants
        SAPERMMX(plt_const) = SAPERPIXX(plt_const)*PIXMMX(plt_const)
        SAPERMMY(plt_const) = SAPERPIXY(plt_const)*PIXMMY(plt_const)
        call prj_const (plt_const)
        PLATE_SCALE_X(plt_const) = double(SATORAD(SAPERMMX(plt_const)))
        PLATE_SCALE_Y(plt_const) = double(SATORAD(SAPERMMY(plt_const)))
end


# ---------------------------------------------------------------------
#
# Function:     prj_const()
# Purpose:      Find constants of transformation between spherical and
#               rectangular coordinates using gnomonic projection.
# Notes:        The constants are stored in a structure pointed to by
#               plt_const.
#
# ---------------------------------------------------------------------
procedure prj_const (plt_const)

pointer plt_const       # i: Chart constants structure

begin

#  CEN_RA and CEN_DEC are in radians

        SIN_A(plt_const) = sin (CEN_RA (plt_const))
        COS_A(plt_const) = cos (CEN_RA (plt_const))
        SIN_D(plt_const) = sin (CEN_DEC(plt_const))
        COS_D(plt_const) = cos (CEN_DEC(plt_const))

        COSA_SIND(plt_const) = COS_A(plt_const) * SIN_D(plt_const)
        SINA_SIND(plt_const) = SIN_A(plt_const) * SIN_D(plt_const)
        COSA_COSD(plt_const) = COS_A(plt_const) * COS_D(plt_const)
        SINA_COSD(plt_const) = SIN_A(plt_const) * COS_D(plt_const)
end
# ---------------------------------------------------------------------
#
# Function:     mrk_srcs()
# Purpose:      Mark the Source input from ascii list onto graph
#
# ---------------------------------------------------------------------
procedure mrk_srcs (gp, num_srcs, xpos, ypos)

pointer gp                      # i: graphics pointer
int     num_srcs                # i: number of srcs
pointer xpos, ypos              # i: x and y position buffers

define SZ_MARK  10

char    srcmark[SZ_MARK]        # l: input src mark
char    marker[SZ_MARK]         # l: display src mark
bool    digit_mrk               # l: indicates whether mark is digit
bool    digit                   # l: indicates whether mark is char & digit
int     i                       # l: loop counter
real    wl, wr, wb, wt          # l: window boundaries
real    xpix, ypix              # l: x/y pixel position

bool    streq()

begin
        digit=false
        digit_mrk=false

# Input Source Marker can be displayed in 3 forms
#     1) character 2) digit 3) character and a digit

        call clgstr ("src_mark", srcmark, SZ_MARK)
        if ( streq ( srcmark[1], "#" ) ) {
           digit = true
        } else if ( streq ( srcmark[2], "#" ) ) {
           call sprintf(srcmark[2], SZ_MARK, " ")
           digit_mrk = true
        }

# Set the Graphics windo to Pixel
        call gseti (gp, G_WCS, PIX_WCS)
#        call gseti (gp, G_TXFONT, GT_NORMAL)
        call ggwind (gp, wl, wr, wb, wt)

# Plot sources stored as pixel positions
        do i = 1, num_srcs {
           xpix = Memr[xpos+i-1]
           ypix = Memr[ypos+i-1]

# Check that the position is within the window bounds
           if ((wl <= xpix && xpix <= wr) && (wb <= ypix && ypix <= wt)){
             if ( digit ) {
                call sprintf (marker, SZ_MARK, "%d")
                  call pargi (i)
             } else if ( digit_mrk ) {
                call sprintf (marker, SZ_MARK, "%s %d")
                  call pargstr (srcmark[1])
                  call pargi (i)
             } else {
                  call sprintf (marker, SZ_MARK, "%s")
                  call pargstr (srcmark)
             }
             call gtext (gp, xpix, ypix, marker, "h=l;v=c;q=h;s=.6")
           }
        }

end
