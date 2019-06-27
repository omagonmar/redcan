# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/bsubs.x,v 11.0 1997/11/06 16:31:52 prosb Exp $
# $Log: bsubs.x,v $
# Revision 11.0  1997/11/06 16:31:52  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:32  prosb
# General Release 2.4
#
#Revision 8.1  1994/09/07  17:36:39  janet
#jd - moved prf_lookup & init_prftab to spatlib library.
#
#Revision 8.0  94/06/27  15:12:06  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:54  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  13:05:47  janet
#jd - upated hdr reads to use qpoe struct and not access the header directly.
#
#Revision 6.0  93/05/24  16:13:48  prosb
#General Release 2.2
#
#Revision 5.2  93/05/13  11:50:45  janet
#jd - added error check on input table columns.
#
#Revision 5.1  93/05/05  16:01:24  janet
#adjusted display levels for xexamine.
#
#Revision 5.0  92/10/29  21:31:13  prosb
#General Release 2.1
#
#Revision 1.3  92/10/14  09:40:49  janet
#table lookup bug fix.
#
#Revision 1.2  92/10/06  09:02:15  janet
#energy lookup in prf coeff table set to nearest value when the
#match is not exact.
#
#Revision 1.1  92/09/25  10:49:59  janet
#Initial revision
#
#
# Module:       bsubs.x
# Project:      PROS -- ROSAT RSDC
# Description:  includes:   init_outtab, init_intab, get_hdrinfo, 
#			    compute_offaxis_ang, prf_lookup, init_prftab 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version  -- 9/92
#               {n} <who> -- <does what> -- <when>
#
# -----------------------------------------------------------------------

include "bepos.h"
include <mach.h>
include <tbset.h>
include <ext.h>
include <coords.h>
include <qpoe.h>

define  DEF_ENERGY 0.0

# ------------------------------------------------------------------------
# init_outtab - initialize the output table
# ------------------------------------------------------------------------
procedure init_outtab (otp, ocolptr)

pointer otp
pointer ocolptr[ARB]

begin
      call tbcdef(otp,ocolptr[1],"ra","degrees","%9.4f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[2],"dec","degrees","%9.4f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[3],"x","pixels","%7.2f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[4],"y","pixels","%7.2f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[5],"srccnts","photons","%13.4f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[6],"bkcnts","photons","%13.4f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[7],"cellcnts","photons","%13.4f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[8],"framecnts","photons","%13.4f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[9],"pconf","","%7.2f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[10],"snr","","%7.2f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[11],"cellx","","%4d",TY_INT,1,1)
      call tbcdef(otp,ocolptr[12],"celly","","%4d",TY_INT,1,1)
      call tbcdef(otp,ocolptr[13],"fsflag","","%1d",TY_INT,1,1)
      call tbtcre(otp)

#   Next 3 column were in original bepos output, include above tbtcre line
#   above for inclusion.
#      call tbcdef(otp,ocolptr[9],"nonzero","","%7.2f",TY_REAL,1,1)
#      call tbcdef(otp,ocolptr[10],"minrad","","%7.1f",TY_REAL,1,1)
#      call tbcdef(otp,ocolptr[13],"detx","pixels","%7.2f",TY_REAL,1,1)
#      call tbcdef(otp,ocolptr[14],"dety","pixels","%7.2f",TY_REAL,1,1)

end

# ------------------------------------------------------------------------
# init_intab - initialize the input rough positions table
# ------------------------------------------------------------------------
procedure init_intab (rtp, icolptr, num_rpos_srcs)

pointer rtp             # i: input table handle
pointer icolptr[ARB]    # i: column pointer
int     num_rpos_srcs   # i: number of input ruf positions

int     i               # l: loop counter
int     tbpsta()

begin

      # get the number of ruf positions
      num_rpos_srcs = tbpsta (rtp, TBL_NROWS)

      # init the columns we expect in this file
      call tbcfnd (rtp, "x", icolptr[1], 1)
      call tbcfnd (rtp, "y", icolptr[2], 1)
      call tbcfnd (rtp, "cellx", icolptr[3], 1)
      call tbcfnd (rtp, "celly", icolptr[4], 1)
      do i = 1, 4 {
         if ( icolptr[i] == NULL ) {
            call error (1, "All Input columns (x, y, cellx, celly) not found")
         }
      }

end

# ------------------------------------------------------------------------
procedure get_hdrinfo (im, display, arcsec_per_pix, instr, telescope,
                       det_center)

pointer im
int     display
real    arcsec_per_pix
char    instr[ARB]
char    telescope[ARB]
real    det_center[ARB]

real    xpixsize                # x pixel size in arcsecs
real    ypixsize                # y pixel size in arcsecs

pointer sp
pointer xcenter, ycenter

pointer imhead
bool    streq()

begin

      call smark (sp)
      call salloc (xcenter, SZ_LINE, TY_CHAR)
      call salloc (ycenter, SZ_LINE, TY_CHAR)

      call get_imhead (im, imhead)

#   get the arcsecs per pix from the header
      xpixsize = real(DEGTOSA(abs(QP_CDELT1(imhead))))
      ypixsize = real(DEGTOSA(abs(QP_CDELT2(imhead))))
      if ( ( xpixsize - ypixsize ) > EPSILONR ) {
        call error (1, "Input must have square pixels")
      }
      arcsec_per_pix = xpixsize

#  get the instrument and telescope
      call strcpy (QP_MISSTR(imhead), telescope, SZ_LINE)
      call inst_itoc(QP_INST(imhead), QP_SUBINST(imhead), instr, SZ_LINE)

#  get the center
      call clgstr ("cenx_keywd", Memc[xcenter], SZ_LINE)
      call clgstr ("ceny_keywd", Memc[ycenter], SZ_LINE)

      if ( streq(Memc[xcenter],"CRPIX1") ) {
         det_center[x] = QP_CRPIX1(imhead)
      } else { 
	call error (1, "Don't recognize cenx_keywd")
      }
      if ( streq(Memc[ycenter],"CRPIX2") ) {
         det_center[y] = QP_CRPIX2(imhead)
      } else {
         call error (1, "Don't recognize ceny_keywd")
      }

#  display hdr info
      if ( display >= 3 && display != 10 ) {
        call printf ("\nTelescope & instrument= %s %s; arcsec_per_pix = %f\n")
           call pargstr (telescope)
           call pargstr (instr)
           call pargr (arcsec_per_pix)
        call printf ("Center params = %s, %s; Center = %f, %f\n\n")
           call pargstr (Memc[xcenter])
           call pargstr (Memc[ycenter])
           call pargr (det_center[x])
           call pargr (det_center[y])
      }

      call sfree (sp)

end

# ----------------------------------------------------------------------------
# Compute the off-axis angle in pixels
# ----------------------------------------------------------------------------
procedure compute_offaxis_ang (xpos, ypos, xcenter, ycenter, offang)

real    xpos,    ypos
real    xcenter, ycenter
real    offang

begin

# compute the off axis angle in pixels
        offang = sqrt ((xpos - xcenter)**2 + (ypos - ycenter)**2 )

end
