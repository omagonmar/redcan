#$header$
#$log$
#
# JCC(11/19/97) - Update the loop index for flag_line() and linecp().
#      flag_line: It now ignores the rightmost and leftmost columns 
#                 instead of ignoring two rightmost columns when 
#                 looking for local maxima.
#      licecp   : The array is now indexed "1:ndim" instead of 
#                 "0:ndim-1" as before. 
#    find_peaks : fixed not to ignore the 2nd row. 
#                                                   
# ---------------------------------------------------------------------
#
# Module:       LP_SUBS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Lpeaks task subroutine
# Includes:     
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- Dec 1991 -- initial version 
#				     converted from fap's lpeaks.c prog
#               {#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------

include <imhdr.h>
include <mach.h>
include <tbset.h>
include <ext.h>

# ---------------------------------------------------------------------
#
# Function:       FIND_PEAKS.X
# Purpose:        determine the location of the local maxima of pixels
# Precondition:   input image already opened 
#
# ---------------------------------------------------------------------
procedure find_peaks(im, otp, ocolptr, ict, thresh, cell, display)

pointer         im		#i: image pointer
pointer         otp		#i: output table pointer
pointer 	ocolptr[ARB]    #i: output table column pointers
pointer         ict             #i: input image wcs pointer
real      	thresh		#i: snr threshold
int     	cell[ARB]       #i: x/y cell size in pixels
int             display         #i: display level

int             i		#l: loop counter
int             xdim		#l: image dim in x		
int             ydim		#l: image dim in x
int     	rpos_out	#l: current number of positions

pointer 	l1,l2,l3 	#l: 3 line pointers
pointer 	line1		#l: prev line buff
pointer 	line2		#l: cur line buff
pointer         line3		#l: next line buff
pointer      	sp

pointer imgl2r()
real    imgetr()

begin

#  Get image dimensions
  	xdim = imgetr(im,"naxis1")
  	ydim = imgetr(im,"naxis2")
#	if ( xdim != ydim ) {
#	   call error (1, "xdim of image != ydim")
#	}

#  Allocate space
        call smark(sp)
        call salloc (line1, xdim, TY_REAL)
        call salloc (line2, xdim, TY_REAL)
        call salloc (line3, xdim, TY_REAL)

#  Initialize by reading first two image lines
#  JCC(11/19/97) - For some reason, the 2nd call to "imgl2r"
#                  makes Memr[l1..] same as Memr[l2..]; 
#                  So, updated to call linecp right after EACH imgl2r.
#                - imgl2r gets  "Memr[l1] : Memr[l1+ndim-1] "
#
        l1 = imgl2r(im,1)   # 1st line of the image
    	call linecp(xdim, Memr[l1],Memr[line1])  

        l2 = imgl2r(im,2)   # now l1=l2=2nd line of the image
    	call linecp(xdim, Memr[l2],Memr[line2])

#   Initialize number of detected positions
        rpos_out = 0
        if ( display > 1 ) { 
          call printf("\n")
          call printf ("src#  logx    logy     physx     physy    cellx/y     snr\n")
          call printf ("---------------------------------------------------------\n")
          call printf("\n")
        }

#  Get each sybsequent line (starting at line 2) 
     	for(i=2; i<ydim; i=i+1){ 
          l3 = imgl2r(im,i+1)
      	  call linecp (xdim, Memr[l3], Memr[line3])

	  call flag_line(xdim, thresh, i, Memr[line1], Memr[line2], Memr[line3],
                         rpos_out, cell, otp, ocolptr, ict, display)

    	  call linecp(xdim,Memr[line2],Memr[line1])
    	  call linecp(xdim,Memr[line3],Memr[line2])
	}

        call sfree(sp)
end

# ---------------------------------------------------------------------
#
# Function:       FLAG_LINE.X
# Purpose:        identify pixel location greater than neighbors
# Precondition:   
#
# ---------------------------------------------------------------------
procedure flag_line (xdim, thresh, curline, line1, line2, line3, 
		     rpos_out, cell, otp, ocolptr, ict, display)

int   	xdim		#i: length of line
real  	thresh		#i: snr threshold
int   	curline		#i: current line counter
real  	line1[ARB]	#i: previous line
real  	line2[ARB]	#i: current line
real  	line3[ARB]	#i: next line
real    lxpix, lypix	#i: x/y pixel in image coords
int     rpos_out	#u: current number of rough positions
int	cell[ARB]	#i: x/y cell size in pixels
int     display         #i: display level
pointer otp		#i: output table pointer
pointer ocolptr[ARB]	#i: table column pointers
pointer ict		#i: image wcs pointer

int   j			#l: position pointer

begin

#  Get each element on the line if it exceeds the threshold, and test it


#JCC(11/97)- It should ignore the rightmost and leftmost columns instead 
#            of ignoring the 2 rightmost columns.
#       for (j=1; j<xdim-1; j=j+1) {       
        for (j=2; j<xdim;   j=j+1) {       
	
            if (line2[j] > thresh) {
#
#       for each element above threshold, test if it's a local maximum
#	by comparing with previous and subsequent elements on same line,
#	and with neighboring elements on previous and subsequent lines.
#	In the event of equality, the first element is taken. This is
#	accomplished by testing for 'greater than' with previous elements
#	or lines, and 'greater than or equal to' with subsequent ones.
# 
	      if ( (line2[j] > line1[j-1]) &&
                   (line2[j] > line1[j]) &&
                   (line2[j] > line1[j+1]) ) {
	          
                if ( (line2[j] > line2[j-1]) &&
                     (line2[j] >= line2[j+1]) ) {

	          if ( (line2[j] >= line3[j-1]) &&
                       (line2[j]>=line3[j]) &&
                       (line2[j]>=line3[j+1]) ) {

		    rpos_out = rpos_out + 1
                    lxpix = real (j)
                    lypix = real (curline)
                    call wr_rpos (otp, ocolptr, ict, rpos_out, lxpix, 
                                  lypix, cell, line2[j], display)
	          }
		}
              }
	    }
	  }

end
	
# ---------------------------------------------------------------------
#
# Function:       WR_RPOS.X
# Purpose:        write the determined rough position to the out table
# Precondition:   
#
# ---------------------------------------------------------------------
procedure wr_rpos (otp, ocolptr, ict, rpos_out, lxpix, lypix, 
                   cell, snr, display)

pointer otp			#i: output table pointer
pointer ocolptr[ARB]		#i: table column pointer
pointer ict			#i: image wcs pointer
int     rpos_out		#i: rough position counter
int	cell[ARB]		#i: cell size in x & y
real    lxpix, lypix		#i: pixel position in image coords
real    snr			#i: snr threshold
int     display                 #i: display level

real    pxpix, pypix		#l: pixel position in physical coords

begin

#  transform image pixel coords to physical coords
        call mw_c2tranr(ict, lxpix, lypix, pxpix, pypix)

#   write row to table output
        call tbrptr (otp, ocolptr[1], pxpix, 1, rpos_out)
        call tbrptr (otp, ocolptr[2], pypix, 1, rpos_out)
        call tbrpti (otp, ocolptr[3], cell[1], 1, rpos_out)
        call tbrpti (otp, ocolptr[4], cell[2], 1, rpos_out)
        call tbrptr (otp, ocolptr[5], snr, 1, rpos_out)


        if ( display > 1 ) {
	   call printf("%4d  %6.2f  %6.2f  %8.2f  %8.2f  %3d  %3d  %8.3f\n")
	      call pargi (rpos_out)
	      call pargr (lxpix)
	      call pargr (lypix)
	      call pargr (pxpix)
	      call pargr (pypix)
              call pargi (cell[1])
              call pargi (cell[2])
	      call pargr (snr)
	}

end

# ---------------------------------------------------------------------
#
# Function:       LINECP.X
# Purpose:        copy image line from source to destination
# Precondition:   
#
# ---------------------------------------------------------------------
procedure linecp (ndim, src, dest)

int ndim		#i: number of elements to copy
real src[ARB]		#i: source line
real dest[ARB]		#o: destination line

int i

begin
#JCC(11/97) - the array index should start from 1 
# 	for (i=0; i<ndim;  i=i+1) {
  	for (i=1; i<=ndim; i=i+1) {
    	  dest[i] = src[i]
  	}
end

# ---------------------------------------------------------------------
#
# Function:       INIT_RPOS
# Purpose:        initialize the rough positions table definition
# Precondition:   
#
# ---------------------------------------------------------------------
procedure init_rpos_tab (rp_tab, imname, tabtemp, ocolptr, otp)

char    rp_tab[ARB]
char    imname[ARB]
char    tabtemp[ARB]
pointer ocolptr[ARB]
pointer otp

bool    clobber
bool    clgetb()
pointer tbtopn()

begin

      clobber = clgetb("clobber")

      call clgstr ("rpos_tab", rp_tab, SZ_PATHNAME)
      call rootname (imname, rp_tab, EXT_RUF, SZ_PATHNAME)
      call clobbername(rp_tab,tabtemp,clobber,SZ_PATHNAME)
      otp = tbtopn (tabtemp, NEW_FILE, 0)
      call tbcdef(otp,ocolptr[1],"x","phys pixels","%7.2f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[2],"y","phys pixels","%7.2f",TY_REAL,1,1)
      call tbcdef(otp,ocolptr[3],"cellx","pixels","%4d",TY_INT,1,1)
      call tbcdef(otp,ocolptr[4],"celly","pixels","%4d",TY_INT,1,1)
      call tbcdef(otp,ocolptr[5],"snr","thresh","%7.2f",TY_REAL,1,1)
      call tbtcre(otp)

end

# ---------------------------------------------------------------------
#
# Function:       WRITE_RHEAD
# Purpose:        write the rough positions table header
# Precondition:	  table open   
#
# ---------------------------------------------------------------------
procedure wr_rhead (otp, debug, imname, thresh)

pointer otp             # output positions table pointer
int     debug           # display level
char    imname[ARB]     # input snrmap filename
real    thresh          # snr threshold

begin
	call tbhadt (otp, "cinfo", "--- Lpeaks Column description ---")
        call tbhadt (otp, "x",   "x pixel position in physical coordinates")
        call tbhadt (otp, "y",   "y pixel position in physical coordinates")
        call tbhadt (otp, "cellx", "x detect cell size in arc-seconds")
        call tbhadt (otp, "celly", "y detect cell size in arc-seconds")
        call tbhadt (otp, "snr",   "signal-to-noise ratio")

        call tbhadt (otp, "tinfo", "--- Task Info ---")
        call tbhadt (otp, "Snrmap", imname)
        call tbhadt (otp, "sinfo", "snr thresh at which this data was run")
        call tbhadr (otp, "thresh", thresh)
end

