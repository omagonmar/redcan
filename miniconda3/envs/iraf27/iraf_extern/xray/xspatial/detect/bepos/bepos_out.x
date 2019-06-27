#$Header: /home/pros/xray/xspatial/detect/bepos/RCS/bepos_out.x,v 11.0 1997/11/06 16:31:51 prosb Exp $
#$Log: bepos_out.x,v $
#Revision 11.0  1997/11/06 16:31:51  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:50:31  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:51  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:13:45  prosb
#General Release 2.2
#
#Revision 5.1  93/05/13  11:49:51  janet
#jd - updated printout display to hh:mm:ss.s, dd:mm:ss.s from degrees.
#
#Revision 5.0  92/10/29  21:31:10  prosb
#General Release 2.1
#
#Revision 4.3  92/10/19  14:07:26  janet
#updated screen print of determined best positions.
#
#Revision 4.2  92/10/14  09:40:04  janet
#updated table header column descriptor comments.
#
#Revision 4.1  92/09/25  10:44:09  janet
#changed order of columns in table & updated header description of bkcts
#
#Revision 4.0  92/04/27  14:38:41  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/23  18:11:50  janet
#added table hdr descriptions.
#
#Revision 3.0  91/08/02  01:20:14  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:00:10  pros
#General Release 1.0
#
include <mach.h>
include <ctype.h>
include <tbset.h>
include "bepos.h"

# ------------------------------------------------------------------------
# write bepos output info to the table file
# -- converted to spp - 7/92
# ------------------------------------------------------------------------

procedure bepos_out (cell_size, as_per_pix, num_out, debug, num_conf, 
                     framecnts, cellcnts, bxy, rxy, pos_conf, prob_nonzero, 
                     snr, pcflag, otp, ocolptr, ict, display, alpha, beta)

pointer otp			# best position logical unit

int cell_size[2]    		# det cell size in x & y
int num_out			# output src number 		
int debug			# debug level
int num_conf			# num of confidences
int ocolptr[ARB]		# output table column pointer
int display			# display level
int pcflag                      # 0/1 confidence flag

int  csize[2]                   # cell size in arcsecs
real as_per_pix			# Instument arcseconds per pixel
real framecnts			# bk cnts det cell size around
real cellcnts			# src cnts det cell size around
real bxy[2] 			# best src position in pixels
real wxy[2] 			# best src position in world coords (degrees)
real rxy[2]			# rough position in pixels
real pos_conf[ARB]		# computed position confidences
real prob_nonzero		# probability src is nonzero
real snr			# computed snr
real alpha, beta

pointer ict

short	spos_conf[2,2]

real srcnts
real bkcnts
real totcnts

begin

        num_out = num_out + 1

#  Convert back from pixels to arcsecs
#  - the program units are pixels, but the world sees arcsecs
        csize[x] = cell_size[x] * as_per_pix
        csize[y] = cell_size[y] * as_per_pix

#  Convert wcs physical coords to world coords
        call mw_c2tranr (ict, bxy[x], bxy[y], wxy[x], wxy[y])

#  Compute source counts and bk counts using eq. from Table 26
#  Ldetect Algebra, eq (8) and (5) in the Einstein yellow 
#  (science specs).
#  1.77777 = 16/9, 2.77777 = 25/9

        totcnts = cellcnts+framecnts

#  from eq. 8
        srcnts = (((1.77777*cellcnts)-framecnts)/((2.77777*alpha)-beta))

#  from eq. 5
        bkcnts = (((alpha*totcnts)-(beta*cellcnts))/((2.77777*alpha)-beta))

#  Write table format output
        call tbrptr (otp, ocolptr[1],  wxy[x], 1, num_out)
        call tbrptr (otp, ocolptr[2],  wxy[y], 1, num_out)
  	call tbrptr (otp, ocolptr[3],  bxy[x], 1, num_out)
  	call tbrptr (otp, ocolptr[4],  bxy[y], 1, num_out)
  	call tbrptr (otp, ocolptr[5],  srcnts, 1, num_out)
  	call tbrptr (otp, ocolptr[6],  bkcnts, 1, num_out)
  	call tbrptr (otp, ocolptr[7],  cellcnts, 1, num_out)
  	call tbrptr (otp, ocolptr[8],  framecnts, 1, num_out)
  	call tbrptr (otp, ocolptr[9],  pos_conf[2], 1, num_out)
  	call tbrptr (otp, ocolptr[10], snr, 1, num_out)
  	call tbrpti (otp, ocolptr[11], csize[x], 1, num_out)
  	call tbrpti (otp, ocolptr[12], csize[y], 1, num_out)
  	call tbrpti (otp, ocolptr[13], pcflag, 1, num_out)

	spos_conf[1,1] = -(short(pos_conf[1]+.5E0))
	spos_conf[2,1] = short(pos_conf[1]+.5E0)
	spos_conf[1,2] = -(short(pos_conf[1]+.5E0))
	spos_conf[2,2] = short(pos_conf[1]+.5E0)

        if ( display > 1 ) {
          call printf ("%4d  %12H  %12h %8.1f %8.1f %7d %7d %7.1f\n")
            call pargi (num_out)
            call pargr (wxy[x])
            call pargr (wxy[y])
            call pargr (bxy[x])
            call pargr (bxy[y])
            call pargr (cellcnts)
            call pargr (framecnts)
            call pargr (snr)
        }

end

# ---------------------------------------------------------------------------
procedure write_tbhead (otp, debug, qpoename, rufname, bkden, snrthresh)

pointer otp		# output positions table pointer
int     debug		# display level
char    qpoename   	# input rough positions filename
char    rufname   	# input rough positions filename
real    bkden   	# input field background density
real    snrthresh	# signal-to-noise ratio thresh

begin

#   Describe the columns in the table with a definition
	call tbhadt (otp, "cinfo", "--- BePos Column description ---")
	call tbhadt (otp, "ra", "right ascension in degrees")
	call tbhadt (otp, "dec", "declination in degrees")
	call tbhadt (otp, "x", "x pixel position in physical coordinates")
	call tbhadt (otp, "y", "y pixel position in physical coordinates")
	call tbhadt (otp, "srccnts", "source strength (source counts only) in assumed point source")
	call tbhadt (otp, "bkcnts", "background counts in the detect cell")
	call tbhadt (otp, "cellcnts", "counts at final position in a detect cell size box")
	call tbhadt (otp, "framecnts", "counts at final position in a frame around a detect cell size box")
        call tbhadt (otp, "pconf", "position error in pixels at 90% confidence")
	call tbhadt (otp, "snr", "signal-to-noise ratio") 
	call tbhadt (otp, "cellx", "x detect cell size in arc-seconds")
	call tbhadt (otp, "celly", "y detect cell size in arc-seconds")
	call tbhadt (otp, "fsflag", "false source probability flag: ")
	call tbhadt (otp, "fsf0", "    1 means observed photon distribution is consistent") 
	call tbhadt (otp, "fsf1", "      with gaussian PRF for a point source")
	call tbhadt (otp, "fsf2", "    0 means observed photon distribution is inconsistent") 

	call tbhadt (otp, "fsf3", "      with gaussian PRF for a point source")

#   Write some useful info to the header too
	call tbhadt (otp, "tinfo", "--- Task Info ---")
	call tbhadt (otp, "binfo", "bkden in counts/arcmin**2")
	call tbhadr (otp, "bkden", bkden)
	call tbhadr (otp, "snr_thresh", snrthresh)
	call tbhadt (otp, "RufTab", rufname)
	call tbhadt (otp, "Qpoe", qpoename)

end
