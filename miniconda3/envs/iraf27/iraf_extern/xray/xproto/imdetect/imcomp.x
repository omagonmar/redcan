#$Header: /home/pros/xray/xproto/imdetect/RCS/imcomp.x,v 11.2 1998/04/24 16:14:08 prosb Exp $
#$Log: imcomp.x,v $
#Revision 11.2  1998/04/24 16:14:08  prosb
#Patch Release 2.5.p1
#
#Revision 11.1  1998/01/06 20:39:56  prosb
#JCC(12/16/97) - rename vector v to vv
#
#Revision 11.0  1997/11/06 16:39:56  prosb
#General Release 2.5
#
#Revision 1.1  1997/10/06 15:18:52  prosb
#Initial revision
#
#Revision 1.1  1997/10/06 15:12:12  prosb
#Initial revision
#
##JCC(3/21/97)
#             - smooth_factor -> usr_smooth
#             - cxfactor      -> req_blkx
#             - cyfactor      -> req_blky

#Revision 1.6  1997/03/05  14:55:20  prosb
#JCC(3/5/97) - display "lines" for a higer debugger level.
#
#Revision 1.5  1997/03/03  21:45:49  prosb
#JCC(3/3/97) - allocate the size (MAX_SUBCELLS*MAX_SUBCELLS) for obuf
#
#Revision 1.4  1997/02/19  15:14:16  prosb
#JCC(2/18/97) - add and pass "xshift & yshift"
#
#Revision 1.3  1997/02/10  21:57:20  prosb
#JCC(2/10/97) - increase the allocation of "obuf" to 4100*4100
#
#Revision 1.2  1997/01/24  15:44:32  prosb
#JCC(1/23/97)- Increase the allocation of "obuf" for evt_window
#
#Revision 1.1  1996/11/04  21:52:16  prosb
#Initial revision
#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/imcomp.x (rev9.0)
#               - bugfix for "integer divide by zero" (xres)
#               - add display and compress_factor(comp_fact) for log2phy 
#               - remove xdetsize/ydetsize from parameter
#               - updated to get current_block (curr_bl) from the code
#                 calc_curr_block (& comment out few lines in get_window)
#               - rename the image pointer from "im" to "sbim"
#
include "detect.h"               #JCC-add for MAX_SUBCELLS
include <imset.h>
include <imhdr.h>
include <error.h>
include "../../lib/ext.h"     #JCC- use /pros/xray/lib/ext.h

#------------------------------------------------------------------------
# IMCOMPRESS - Compress an image from one file to another.
#------------------------------------------------------------------------
procedure imcomp(sbim,req_blkx,req_blky,usr_smooth, obuf,outxdim,
         outydim,xcomp_fact,ycomp_fact,display,xshift,yshift)

pointer sbim				# i: input image pointer
int     req_blkx        #i: request block in x-dim input from smooth_image.x 
int     req_blky        #i: request block in y-dim input from smooth_image.x 
int	usr_smooth      #i: user input for smooth factor ("subcells")

#JCC int xdetdim			# i: xdetsize (x_det_size) 
#JCC int ydetdim		        # i: ydetsize (y_det_size) 

pointer obuf			# o: pointer of evt_window[x,y]
int	outxdim			# o: output x dimension of evt_window[x,y]
int	outydim			# o: output y dimension of evt_window[x,y] 

pointer	xbuf				# l: temp buffer for collapse
pointer	ttbuf				# l: temp buffer for collapse
int	first
int     ii, jj, kk	         	# loop counters
int	inxdim				# useable input x dimension
#int	inydim				# useable input y dimension
int	line				# output line counter
int 	npixels				# pixels / input line
int     num_img				# number of 2d images
int     num_rows
int	out				# pointer to current output row
int	xres, yres                      # local adjusted compress factor

pointer vv				# input image vector
	
pointer ibuf				# input buffer pointer
pointer sp				# memory stack pointer
pointer tbuf 				# temporary buffer pointer

pointer imgnls(), imgnli(), imgnll(), imgnlr(), imgnld(), imgnlx()

#JCC (10/29/96)
int    xcomp_fact, ycomp_fact  #compress factor of source or bkgd for log2phy 
int    curr_blx, curr_bly      #current block 
int    display
real   xshift, yshift

begin

	call smark(sp)
	call salloc (vv, IM_MAXDIM, TY_LONG)
 
#   Initialize position vectors to line 1, col 1, band 1, ...
	call amovkl (long(1), Meml[vv], IM_MAXDIM)
	line = 1
	npixels = IM_LEN(sbim,1)
 
#JCC(3/21/97)-  if ( xres > IM_LEN(sbim,1) )
#       call error(EA_ERROR, "Compress Factor .gt. IMG Dim 1")

#   Setup new output image header
#	xres = IM_LEN(sbim,1) / req_blkx  	# set x dim resolution 
#	yres = IM_LEN(sbim,2) / req_blky
        num_img = 1			        # init # images after dim 2
        num_rows = 1

#JCC    xres = xdetdim / IM_LEN(sbim,1)           # current_block
#JCC    yres = ydetdim / IM_LEN(sbim,2)

#	if( xres * IM_LEN(sbim,1) != xdetdim ) call error(ZOOM_ERROR,"")

#-----------------------------
# JCC (10/25/96) - get current block from calc_curr_block.x
#       it should be the value from qpoe [ block = curr_block ]
        call calc_curr_block(sbim,display,curr_blx,curr_bly,xshift,yshift)
#-----------------------------

# JCC (10/23/96) - bugfix for "integer divide by zero"
        xres = max (1, req_blkx / curr_blx )     #xres: CompreFactor
        yres = max (1, req_blky / curr_bly )     #yres: CompreFactor

        if (display >= 3 )
        {
         call printf("\n\nimcomp : comp_fact = max(1,request_blk/current_blk)")
          call printf("\nimcomp : request_blk = %d  %d ")
          call pargi( req_blkx)
          call pargi( req_blky)
          call printf("\nimcomp : current_blk = %d  %d ")
          call pargi( curr_blx)
          call pargi( curr_bly)
          call printf("\nimcomp : compress_factor = %d  %d \n")
          call pargi( xres)
          call pargi( yres)
        }

#JCC (10/29/96) save xres/yres as comp_fact for the code log2phy.
        xcomp_fact = xres
        ycomp_fact = yres

# **** MC change out*dim and im*dim to be 511 to be consistent w/ detect code
	outxdim = IM_LEN(sbim,1) / xres + 
			min(1,min(IM_LEN(sbim,1),xres)) - (usr_smooth-1)

	outydim = IM_LEN(sbim,2) / yres +
			min(1,min(IM_LEN(sbim,2),yres)) - (usr_smooth-1)
# useable input dimension - maybe up to c*factor less than IM_LEN
	inxdim = min(IM_LEN(sbim,1),outxdim * xres ) 
#	inydim = min(IM_LEN(sbim,2),outydim * yres )

        if ( IM_NDIM(sbim) >= 2 )
  	{
           if ( yres > IM_LEN(sbim,2) )
	      call error(EA_ERROR, "Compress Factor .gt. IMG Dim 2")
           num_rows = IM_LEN(sbim,2)
	   for (ii=3; ii<= IM_NDIM(sbim); ii=ii+1) 
	   {
 	      num_img = num_img * IM_LEN(sbim) 
	   }
        }

        first = usr_smooth/2 
	switch (IM_PIXTYPE(sbim)) 
	{
	case TY_SHORT: 
	   call malloc (xbuf, npixels, TY_SHORT) 
	   call malloc (tbuf, npixels, TY_SHORT) 
	case TY_INT:   
	   call malloc (xbuf, npixels, TY_INT) 
	   call malloc (tbuf, npixels, TY_INT) 
	case TY_LONG:  
	   call malloc (xbuf, npixels, TY_LONG) 
	   call malloc (tbuf, npixels, TY_LONG) 
	case TY_REAL:  
  	   call malloc (xbuf, npixels, TY_REAL) 
  	   call malloc (tbuf, npixels, TY_REAL) 
	case TY_DOUBLE: 
	   call malloc (xbuf, npixels, TY_DOUBLE) 
	   call malloc (tbuf, npixels, TY_DOUBLE) 
	case TY_COMPLEX: 
	   call malloc (xbuf, npixels, TY_COMPLEX) 
	   call malloc (tbuf, npixels, TY_COMPLEX) 
	}

#JCC(1/23/97)-increase the allocation of obuf for evt_window 
#JCC    call calloc (obuf, outxdim*outydim, TY_REAL) 
#JCC    call calloc (obuf, 4100*4100, TY_REAL) 
        call calloc (obuf, MAX_SUBCELLS*MAX_SUBCELLS, TY_REAL) 
	call calloc (ttbuf, npixels, TY_REAL) 
#   First sum rows vertically over the compression factor and then reduce 
#   horizontally in the procedure collapse.
 
        for (ii=1; ii<=num_img; ii=ii+1)    # iter over number of 2-D images
	{
	   switch (IM_PIXTYPE(sbim)) 
	   {
	   case TY_SHORT: 
              call aclrs(Mems[tbuf], npixels)   # zero SHORT temp buf
	   case TY_INT:   
              call aclri(Memi[tbuf], npixels)   # zero INT temp buf
	   case TY_LONG:  
              call aclrl(Meml[tbuf], npixels)   # zero LONG temp buf
	   case TY_REAL:  
              call aclrr(Memr[tbuf], npixels)   # zero REAL temp buf
	   case TY_DOUBLE: 
              call aclrd(Memd[tbuf], npixels)   # zero DOUBLE temp buf
	   case TY_COMPLEX: 
              call aclrx(Memx[tbuf], npixels)   # zero COMPLEX temp buf
	   }
           for (jj=1; jj<=num_rows; jj=jj+1)    # iter over rows in image
	   {         
	      switch (IM_PIXTYPE(sbim)) 
	      {
	      case TY_SHORT: 
	         if (imgnls (sbim, ibuf, Meml[vv]) != EOF) # get and sum next row
	            call aadds (Mems[ibuf], Mems[tbuf], Mems[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_INT:   
	         if (imgnli (sbim, ibuf, Meml[vv]) != EOF) # get and sum next row
	            call aaddi (Memi[ibuf], Memi[tbuf], Memi[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_LONG:  
	         if (imgnll (sbim, ibuf, Meml[vv]) != EOF) # get and sum next row
	            call aaddl (Meml[ibuf], Meml[tbuf], Meml[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_REAL:  
	         if (imgnlr (sbim, ibuf, Meml[vv]) != EOF) # get and sum next row
	            call aaddr (Memr[ibuf], Memr[tbuf], Memr[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_DOUBLE: 
	         if (imgnld (sbim, ibuf, Meml[vv]) != EOF) # get and sum next row
	            call aaddd (Memd[ibuf], Memd[tbuf], Memd[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_COMPLEX: 
	         if (imgnlx (sbim, ibuf, Meml[vv]) != EOF) # get and sum next row
	            call aaddx (Memx[ibuf], Memx[tbuf], Memx[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      }

              if ( mod(jj,yres)==0 || num_rows==1) #is it time to collapse??
	      { 		                   # collapse summed rows
	         switch (IM_PIXTYPE(sbim)) 
	   	 {
	   	    case TY_SHORT: 
                        call collapses(Mems[tbuf],Mems[xbuf], Memr[ttbuf],
				         xres,  inxdim, usr_smooth)
                        call aclrs (Mems[tbuf], npixels)   # zero tbuf

	    	    case TY_INT:   
                        call collapsei(Memi[tbuf],Memi[xbuf], Memr[ttbuf],
				         xres,  inxdim, usr_smooth)
                        call aclri (Memi[tbuf], npixels)   # zero tbuf

	   	    case TY_LONG:  
                    	call collapsel(Meml[tbuf],Meml[xbuf], Memr[ttbuf],
				         xres,  inxdim, usr_smooth)
                        call aclrl (Meml[tbuf], npixels)   # zero tbuf
		        
	   	    case TY_REAL:  
                        call collapser(Memr[tbuf],Memr[xbuf], Memr[ttbuf],
				         xres,  inxdim, usr_smooth)
                        call aclrr (Memr[tbuf], npixels)   # zero tbuf

	   	    case TY_DOUBLE: 
                    	call collapsed(Memd[tbuf],Memd[xbuf], Memr[ttbuf],
				         xres,  inxdim, usr_smooth)
                        call aclrd (Memd[tbuf], npixels)   # zero tbuf
		        
	   	    case TY_COMPLEX: 
                    	call collapsex(Memx[tbuf],Memx[xbuf], Memr[ttbuf],
				         xres,  inxdim, usr_smooth)
                        call aclrx (Memx[tbuf], npixels)   # zero tbuf
		        
	   	 }

		 if( line > 1 && line < num_rows -1 )
		 {
		     out = (line-1-first)*outxdim
		     do kk=1,usr_smooth
		     {
		         call aaddr(Memr[ttbuf],Memr[obuf+out],
		 	            Memr[obuf+out], outxdim)
			 out=out+outxdim
		     }
		 }
		 line = line+1;
              }
           }
        }

        if (display.ge.3) {
           call eprintf("imcomp:  lines = %d \n")
           call pargi( line )
        }
         
	call sfree (sp)
	switch (IM_PIXTYPE(sbim)) 
	{
	case TY_SHORT: 
	   call mfree(xbuf, TY_SHORT) 
	   call mfree(tbuf, TY_SHORT) 
	case TY_INT:   
	   call mfree(xbuf, TY_INT) 
	   call mfree(tbuf, TY_INT) 
	case TY_LONG:  
	   call mfree(xbuf, TY_LONG) 
	   call mfree(tbuf, TY_LONG) 
	case TY_REAL:  
  	   call mfree(xbuf, TY_REAL) 
  	   call mfree(tbuf, TY_REAL) 
	case TY_DOUBLE: 
	   call mfree(xbuf, TY_DOUBLE) 
	   call mfree(tbuf, TY_DOUBLE) 
	case TY_COMPLEX: 
	   call mfree(xbuf, TY_COMPLEX) 
	   call mfree(tbuf, TY_COMPLEX) 
	}
	call mfree(ttbuf, TY_REAL) 
end
