#$Header: /home/pros/xray/xspatial/detect/bepos/RCS/sav_snr.x,v 11.0 1997/11/06 16:32:08 prosb Exp $
#$Log: sav_snr.x,v $
#Revision 11.0  1997/11/06 16:32:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:51:05  prosb
#General Release 2.4
#
Revision 8.0  1994/06/27  15:13:07  prosb
General Release 2.3.1

Revision 7.0  93/12/27  18:33:25  prosb
General Release 2.3

Revision 6.0  93/05/24  16:17:54  prosb
General Release 2.2

#Revision 5.0  92/10/29  21:31:20  prosb
#General Release 2.1
#
#Revision 4.1  92/09/25  10:52:22  janet
#use local bkgd & write counts in the frame around det cell
#
#Revision 4.0  92/04/27  14:38:45  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/23  18:12:33  janet
#added pixlim var to store vals before min/max performed.  caught on vax compile.
#
#Revision 1.1  92/03/29  14:33:32  janet
#Initial revision
#
#Revision 2.0  91/03/07  00:00:17  pros
#General Release 1.0
#
include <imhdr.h>
include "bepos.h"

# -------------------------------------------------------------------------
#  compute the signal-to-noise ratio
#  jd - converted to SPP 7/92
# -------------------------------------------------------------------------
procedure calc_snr (im, debug, yx_cell_size, p_bepos_xy, bcts, scts, snr)

pointer im                      # image handle
int     debug                   # debug level
int     yx_cell_size[2]         # x & y det cell size

real    p_bepos_xy[2]           # best position in pixels

real    bcts                    # src bkgd cnts at best pos
real    scts                    # src cnts at best position
real    snr                     # calc snr ratio
pointer im_windo                # poe photon array at zoom 1
int     i,j                     # loop counters
int     lx, ux                  # lower and upper x vals
int     ly, uy                  # lower and upper y vals
int     pixlim                  # pixel limit for min/max call
int     xsize, ysize
int     xpixcell, ypixcell
int     imgs2i()

begin

#   Initialize best source counts, best bkgd counts, and the snr
      scts = 0.0
      bcts = 0.0

#  Get the Src Counts from a detect cell size box at the source position

#      pixlim = int(p_bepos_xy[x]) - (yx_cell_size[x] / 2)
#      lx = max (1, pixlim)
#      pixlim = lx + yx_cell_size[x] - 1
#      ux = min(IM_LEN(im,1), pixlim)
#
#      pixlim = int(p_bepos_xy[y]) - (yx_cell_size[y] / 2)
#      ly = max(1, pixlim)
#      pixlim = ly + yx_cell_size[y] - 1
#      uy = min(IM_LEN(im,2), pixlim)
#
#      src_windo = imgs2i (im,lx,ux,ly,uy)
#
#      do j = 1, yx_cell_size[y] {
#         do i = 1, yx_cell_size[x] {
#             scts = scts + Memi[src_windo+(j-1)*yx_cell_size[y]+i-1]
#         }
#      }

#  Get the Src & Bkgd Counts from a box around the detect cell center 
#  at the source position
      xsize = (yx_cell_size[x] / 3 ) * 5

      pixlim = int(p_bepos_xy[x]) - (xsize / 2)
      lx = max (1, pixlim)
      pixlim = lx + xsize - 1
      ux = min(IM_LEN(im,1), pixlim)

      ysize = (yx_cell_size[y] / 3 ) * 5

      pixlim = int(p_bepos_xy[y]) - (ysize / 2)
      ly = max(1, pixlim)
      pixlim = ly + ysize - 1
      uy = min(IM_LEN(im,2), pixlim)

      im_windo = imgs2i (im,lx,ux,ly,uy)

      if ( debug >= 4 ) {
         call printf ("Best Pos = %f %f %d %d\n")
           call pargr (p_bepos_xy[x])
           call pargr (p_bepos_xy[y])
           call pargi (yx_cell_size[x])
           call pargi (yx_cell_size[y])
         call printf ("Final bk windo limits: lx=%d, ux=%d, ly=%d, uy=%d\n")
           call pargi (lx)
           call pargi (ux)
           call pargi (ly)
           call pargi (uy)
      }

#   Sum the bkgd counts - counts within a 5x5 box detect cell size box
      do j = 1, ysize {
         do i = 1, xsize {
             bcts = bcts + Memi[im_windo+(j-1)*ysize+i-1]
         }
      }

#   Sum the Src counts - counts in the center 3x3 detect cell size box
      xpixcell = xsize / 5
      ypixcell = ysize / 5
      do j = ypixcell+1 , ysize-ypixcell {
         do i = xpixcell+1, xsize-xpixcell {
             scts = scts + Memi[im_windo+(j-1)*ysize+i-1]
         }
      }

#   Comput the signal-to-noise ratio 
#   SNR = ((25/9)*C - T ) / (sqrt(16/9**2-1)*C + T)
      if ( scts > 0.0 ) {
#         snr = (scts - bcts) / sqrt (scts)
          snr = (2.7777*scts - bcts) / (((1.7777**2 - 1)*scts + bcts)**0.5)
      } else {
         snr = 0.0
      }

#   Give the counts in the outer 5x5 frame around the src region
    bcts = bcts - scts

      if ( debug >= 4 ) {
        call printf ("Final src and bkgd counts: %f, %f\n")
         call pargr (scts)
         call pargr (bcts)
      }

end
