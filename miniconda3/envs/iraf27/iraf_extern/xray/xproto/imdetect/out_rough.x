#JCC(7/97) - add print rowcnt and break.
#          - add mxsrc (max_src_num from user par)
#
#Revision 1.5  1997/06/23 17:22:14  prosb
#JCC(6/23/97) - remove the screen display for "Det Pos"
#
#Revision 1.4  1997/03/21 22:22:52  prosb
#JCC(3/20/97) - rough_pos_out --> rowcnt
#             - x_cell_size   --> xcellsize (from usr par)
#             - y_cell_size   --> removed
#
#Revision 1.2  1997/03/13  18:48:08  prosb
#JCC(3/13/97) - Change the dimension of colptr to 10 instead of 11.
#
#Revision 1.1  1996/11/12  16:22:14  prosb
#Initial revision
#
#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/out_rough.x(rev9.0)
#
include	"detect.h"
define	rbuf_size	8

#   Write out the rough position info for each blob
# jcc(3/21/97) - remove ycellsize
procedure out_rough(display, num_sources, blobs_out, itp, fd, colptr, 
       xcellsize, min_radius, rough_pos, rowcnt, mxsrc )

int display 
int num_sources
int blobs_out
pointer itp                     # output table:    root_ruf.tab
pointer fd                      # output region:   *.reg 

int xcellsize 		# pix size of detect cell from user par
#int ycellsize 		# pix size of detect cell from user par

pointer	colptr[ARB]

real min_radius
real rough_pos[2, ARB]
real radius
int rowcnt            # row index for root_ruf.tab
      
int source_out
int res_flag
char rough_buf[SZ_LINE]
real	detx, dety      	# l: output positions in detector coords.
int mxsrc   # max_src_num from user par (replace MAX_SRCS)

begin
	radius = xcellsize / 2 
	if (num_sources > 1) 
            res_flag = 1 
        else
            res_flag = 0

        do source_out = 1, num_sources
	{
	    detx = rough_pos[1,source_out]-1.0
	    dety = 4096.0E0-rough_pos[2,source_out]
            rowcnt= rowcnt+ 1

            if (rowcnt > mxsrc )   #MAX_SRCS
               break

            if ( display > 2 ) 
	    {
                call printf("Blob#: %5d Source #: %4d  Resolved?: %2d\n")
		  call pargi(blobs_out)
		  call pargi(source_out)
		  call pargi(res_flag)
                call printf("Pixel Pos: %7.2f %7.2f   Min Radius: %8.2f\n")
		  call pargr(rough_pos[1,source_out])
		  call pargr(rough_pos[2,source_out])
		  call pargr(min_radius)
                  call printf(" ruf table row count :  %d\n")
                  call pargi(rowcnt)

                ## call printf("Det Pos: %7.2f %7.2f   Cell Size: %3d\n")
		  ## call pargr(detx)
		  ## call pargr(dety)
		  ## call pargi(xcellsize)
	    }

            call tbrpti(itp,colptr[1],blobs_out,1,rowcnt)
	    call tbrpti(itp,colptr[2],source_out,1,rowcnt)
	    call tbrptr(itp,colptr[3],rough_pos[1,source_out],1,rowcnt)
	    call tbrptr(itp,colptr[4],rough_pos[2,source_out],1,rowcnt)
	    call tbrptr(itp,colptr[5],detx,1,rowcnt)
	    call tbrptr(itp,colptr[6],dety,1,rowcnt)
	    call tbrpti(itp,colptr[7],res_flag,1,rowcnt)
	    call tbrptr(itp,colptr[8],min_radius,1,rowcnt)
	    call tbrpti(itp,colptr[9],xcellsize,1,rowcnt)
#	Independent setting of y subcell size currently disabled
	    call tbrpti(itp,colptr[10],xcellsize,1,rowcnt)

	    call sprintf(rough_buf,SZ_LINE,"circle %f %f %f\n")
            call pargr(rough_pos[1,source_out])
            call pargr(rough_pos[2,source_out])
	    call pargr(radius)
	    call putline(fd,rough_buf)
    	}   # end do source 
end
