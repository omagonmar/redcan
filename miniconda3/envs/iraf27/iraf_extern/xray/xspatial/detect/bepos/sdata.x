#$Header: /home/pros/xray/xspatial/detect/bepos/RCS/sdata.x,v 11.0 1997/11/06 16:32:09 prosb Exp $
#$Log: sdata.x,v $
#Revision 11.0  1997/11/06 16:32:09  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:51:07  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:13:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:33:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:18:32  prosb
#General Release 2.2
#
#Revision 5.1  93/05/13  11:56:25  janet
#jd - included xexamine debug level in printout conditional.
#
#Revision 5.0  92/10/29  21:32:07  prosb
#General Release 2.1
#
#Revision 4.1  92/09/25  11:14:03  janet
#added to variable defs.
#
#Revision 4.0  92/04/27  14:39:07  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/23  18:14:33  janet
#added pixlim var for evaluation of eq before min/max func. error caught n vax com,pile.
#
#Revision 1.1  92/03/29  14:33:23  janet
#Initial revision
#
#Revision 3.0  91/08/02  01:20:32  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:01:09  pros
#General Release 1.0
#
#include <mach.h>
include <ctype.h>
include <tbset.h>
include <imhdr.h>
include "bepos.h"

# ---------------------------------------------------------------------
# read rough position data from input table for current source
# ---------------------------------------------------------------------

procedure sdata (cur_src, debug, windo_dim, as_per_pix, col, src_windo, 
		 cts, yx_cell_size, e_rough_xy, p_rough_xy, rtp, im)


int 	cur_src			# i: current src number
int 	debug			# i: debug level
int 	windo_dim		# i: dimension of src_windo

pointer col[ARB]		# i: points to table columns
pointer rtp			# i: rough pos tabel pointer
pointer im			# i: image input pointer
pointer src_windo		# i: sourece windo data

real    as_per_pix              # i: arc seconds per pixel

int 	yx_cell_size[2]       	# o: det cell size in x & y in pixels

real	cts			# o: tally in det cell size
real  	e_rough_xy[2]		# o: rough pos in elements
real  	p_rough_xy[2] 		# o: rough pos in pixels
real    yx_csize[2]       	# o: det cell size in x & y

bool    nullflag[25]
int 	lx, ux			# l: lower and upper x coord
int 	ly, uy			# l: lower and upper y coord
int     i, j			# l: loop counters
int     pixlim			# l: pixel read limit

int     imgs2i()

begin

#   Read rough info for current src

      call tbrgtr (rtp, col[1], p_rough_xy[x], nullflag, 1, cur_src)
      call tbrgtr (rtp, col[2], p_rough_xy[y], nullflag, 1, cur_src)
      call tbrgti (rtp, col[3], yx_cell_size[x], nullflag, 1, cur_src)
      call tbrgti (rtp, col[4], yx_cell_size[y], nullflag, 1, cur_src)

#     call tbrgtr (rtp, col[3], minimum_radius, nullflag, 1, cur_src)

      if ( debug >= 4 && debug != 10 ) {
         call printf ("\nrpos %d -> %f %f %d %d\n")
           call pargi (cur_src)
           call pargr (p_rough_xy[x])
           call pargr (p_rough_xy[y])
           call pargi (yx_cell_size[x])
           call pargi (yx_cell_size[y])
      }

#   Convert cell size in arcseconds to pixels
      yx_csize[x] = yx_cell_size[x] / as_per_pix
      yx_csize[y] = yx_cell_size[y] / as_per_pix

      yx_cell_size[x] = nint (yx_csize[x])
      yx_cell_size[y] = nint (yx_csize[y])

#    READ from POE_FILE into SRC_WINDO at position P_ROUGH_XY at zoom 1
#       and size WINDO_DIM
      pixlim = int(p_rough_xy[x]) - windo_dim / 2 
      lx = max(1, pixlim)
      pixlim = lx + windo_dim-1
      ux = min(IM_LEN(im,1), pixlim) 

      pixlim = int(p_rough_xy[y]) - windo_dim /2
      ly = max(1, pixlim) 
      pixlim = ly + windo_dim-1
      uy = min(IM_LEN(im,2), pixlim) 

      if ( debug >= 5 && debug != 10 ) {
         call printf ("qpoe read limits: lx=%d, ux=%d, ly=%d, uy=%d\n")
            call pargi (lx)
            call pargi (ux)
            call pargi (ly)
            call pargi (uy)
      }
      src_windo = imgs2i (im,lx,ux,ly,uy)
      if ( debug > 5 && debug != 10 ) {
         do j = 1, windo_dim{
             do i = 1, windo_dim{
	         call printf ("(%d,%d) -> %d\n")
                  call pargi (i)
		  call pargi (j)
		  call pargi (Memi[src_windo+(j-1)*windo_dim+i-1])
             }
          }
      }

#   convert the rough position from pixel coords to element coords
      e_rough_xy[x] = windo_dim / 2
      e_rough_xy[y] = windo_dim / 2

      call srcnts(Memi[src_windo],windo_dim,yx_cell_size,e_rough_xy,debug,cts)

end


# -------------------------------------------------------------------------
procedure srcnts (src_windo,windo_dim,yx_cell_size,e_rough_xy,debug,cts)

int     src_windo[windo_dim,windo_dim] # i: image section around src
int 	windo_dim		# i: dimension of src_windo
int     yx_cell_size[2]       	# i: det cell size in x & y
real  	e_rough_xy[2]		# i: rough pos in elements
int     debug                   # i: debug level
real    cts			# o: tally in det cell size

int 	lx, ux			# l: lower and upper x coord
int 	ly, uy			# l: lower and upper y coord
int     i, j			# l: loop counter
int     pixlim			# l: pixel read limit

begin

#   count up photons inside a box DET_CELL_SIZE on a side
        pixlim = e_rough_xy[x] - yx_cell_size[x] / 2
	lx = max(1,pixlim)
	pixlim = e_rough_xy[y] - yx_cell_size[y] /2
	ly = max(1,pixlim)
	
	pixlim = lx + yx_cell_size[x] - 1
	ux = min(windo_dim, pixlim) 
        pixlim = ly + yx_cell_size[y] - 1
	uy = min(windo_dim, pixlim) 

        if ( debug >= 5 && debug != 10 ) {
           call printf ("src windo read limits: lx=%d, ux=%d, ly=%d, uy=%d\n")
             call pargi (lx)
             call pargi (ux)
             call pargi (ly)
             call pargi (uy)
        }


	cts = 0.0
	do j = ly, uy {

           do i = lx, ux {
               cts = cts + src_windo[i,j]
           }
        }

end
