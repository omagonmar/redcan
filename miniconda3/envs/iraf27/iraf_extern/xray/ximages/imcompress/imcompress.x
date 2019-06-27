#$Header: /home/pros/xray/ximages/imcompress/RCS/imcompress.x,v 11.0 1997/11/06 16:28:06 prosb Exp $
#$Log: imcompress.x,v $
#Revision 11.0  1997/11/06 16:28:06  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:58  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:31  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:17:00  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/23  17:39:20  janet
#blocked from working on qpoes, update ck_none tests.
#
#Revision 3.0  91/08/02  01:17:10  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:49:22  pros
#General Release 1.0
#
# Module:       IMCOMPRESS
# Project:      PROS -- ROSAT RSDC
# Purpose:      Program to create a 'blocked' output image file
# External:     imcompress
# Local:        all others
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD    initial version <when>    
#               {1} MC -- Update the include files
#			  remove multiplication from collapse routine
#							-- 2/13/91

include <imhdr.h>
include <error.h>
include <ext.h>

define  SZ_EXPR 1024

#------------------------------------------------------------------------
# IMCOMPRESS - Compress an image from one file to another.
#------------------------------------------------------------------------

procedure t_imcompress ()

bool	clobber				# clobber old filename

pointer extn				# file extension
pointer in_image			# input image filename
pointer out_image			# output image filename
pointer tempname			# temp image filename

int     cfactor				# compress factor
int     i, j, 				# loop counters
int 	npixels				# pixels / input line
int     num_img				# number of 2d images
int     num_rows
int	pixels				# pixels to compress
int     res				# resolution

pointer iv				# input image vector
pointer ov				# output image vector
	
pointer ibuf				# input buffer pointer
pointer in				# input image pointer
pointer fname				# file name pointer
pointer obuf				# output buffer pointer	
pointer out				# output image pointer
pointer sp				# memory stack pointer
pointer tbuf 				# temporary buffer pointer
pointer filter
pointer imgroot

bool	clgetb()			# get parm bool function
bool    streq()				# string equal compare function
bool    ck_none()                       # check for 'none' filename spec

int     clgeti()			# get parm int function
int     qp_access()

# WCS stuff
pointer	mw				# l: mwcs structure
double	ltm[2,2]			# l: mwcs logical term matrix
double	ltv[2]				# l: mwcs logical term vector
pointer	mw_openim()			# l: open a wcs

pointer immap()				# open image function
pointer imgnls(), imgnli(), imgnll(), imgnlr(), imgnld(), imgnlx()
pointer impnls(), impnli(), impnll(), impnlr(), impnld(), impnlx()

begin

	call smark(sp)
	call salloc (extn, SZ_FNAME, TY_CHAR)
	call salloc (fname, SZ_PATHNAME, TY_CHAR)
	call salloc (in_image, SZ_PATHNAME, TY_CHAR)
	call salloc (out_image, SZ_PATHNAME, TY_CHAR)
	call salloc (tempname, SZ_PATHNAME, TY_CHAR)
	call salloc (iv, IM_MAXDIM, TY_LONG)
	call salloc (ov, IM_MAXDIM, TY_LONG)
        call salloc (filter, SZ_EXPR, TY_CHAR)
        call salloc (imgroot, SZ_PATHNAME, TY_CHAR)

 
#   Get filenames and check validity
        call clgstr ("in_image", Memc[in_image], SZ_PATHNAME)
        if ( (ck_none (Memc[in_image])) || (streq ("", Memc[in_image])) ) {
           call error(1, "requires image file as input")
        }

#   Check if input is a qpoe - we only work on images
	call qpparse(Memc[in_image], Memc[imgroot], SZ_PATHNAME,
                     Memc[filter], SZ_EXPR)

        if ( qp_access (Memc[imgroot], READ_ONLY) == YES ) {
            call printf ("\n")
            call error (1, "Use IMCOPY with block factor [bl=?] for Qpoe files")
        }

#   Get output filename
        call clgstr ("out_image", Memc[out_image], SZ_PATHNAME)
        call rootname (Memc[in_image],Memc[out_image], EXT_IMG, SZ_PATHNAME)
        if ( (ck_none (Memc[out_image])) || ( streq("", Memc[out_image])) ) {
           call error(1, "Output filename missing")
        }
	clobber = clgetb ("clobber")
        call clobbername (Memc[out_image], Memc[tempname], clobber, SZ_PATHNAME)

#   Input the compress factor  
        cfactor = clgeti ("cfactor")

#   Open/create the images
	in  = immap (Memc[in_image], READ_ONLY, 0)

#   Open output image and copy input image header
	call new_imcopy (in, Memc[tempname], out)
 
#   Copy input header and update arcsecs per pixel
	# look for a wcs
	ifnoerr (mw = mw_openim(out) ) {
	    # get logical terms
	    call mw_gltermd(mw, ltm, ltv, 2)
	    # convert scale factors
	    ltm[1,1] = ltm[1, 1] / cfactor
	    ltm[2,2] = ltm[2, 2] / cfactor
	    #set logical terms
	    call mw_sltermd(mw, ltm, ltv, 2)
	    # and save the wcs
	    call mw_saveim(mw, out)
	}

#   Initialize position vectors to line 1, col 1, band 1, ...
	call amovkl (long(1), Meml[iv], IM_MAXDIM)
	call amovkl (long(1), Meml[ov], IM_MAXDIM)
	npixels = IM_LEN(in,1)
 
#   Setup new output image header
        if ( cfactor > IM_LEN(in,1) )
	   call error(EA_ERROR, "Compress Factor .gt. IMG Dim 1")
	res = IM_LEN(in,1) / cfactor  	# set x dim resolution 
        num_img = 1			# init # images after dim 2
        num_rows = 1

	IM_LEN(out,1) = IM_LEN(in,1) / cfactor
        if ( IM_NDIM(in) >= 2 )
  	{
           if ( cfactor > IM_LEN(in,2) )
	      call error(EA_ERROR, "Compress Factor .gt. IMG Dim 2")
           IM_LEN(out,2) = IM_LEN(in,2) / cfactor
           num_rows = IM_LEN(in,2)
	   for (i=3; i<= IM_NDIM(in); i=i+1) 
	   {
 	      num_img = num_img * IM_LEN(out,i) 
	   }
        }

	switch (IM_PIXTYPE(out)) 
	{
	case TY_SHORT: 
	   call malloc (tbuf, npixels, TY_SHORT) 
	case TY_INT:   
	   call malloc (tbuf, npixels, TY_INT) 
	case TY_LONG:  
	   call malloc (tbuf, npixels, TY_LONG) 
	case TY_REAL:  
   	   call malloc (tbuf, npixels, TY_REAL) 
	case TY_DOUBLE: 
	   call malloc (tbuf, npixels, TY_DOUBLE) 
	case TY_COMPLEX: 
	   call malloc (tbuf, npixels, TY_COMPLEX) 
	}

	pixels = cfactor * res

#   First sum rows vertically over the compression factor and then reduce 
#   horizontally in the procedure collapse.
 
        for (i=1; i<=num_img; i=i+1)    # iter over number of 2-D images
	{
	   switch (IM_PIXTYPE(out)) 
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
           for (j=1; j<=num_rows; j=j+1)            # iter over rows in image
	   {         
	      switch (IM_PIXTYPE(out)) 
	      {
	      case TY_SHORT: 
	         if (imgnls (in, ibuf, Meml[iv]) != EOF) # get and sum next row
	            call aadds (Mems[ibuf], Mems[tbuf], Mems[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_INT:   
	         if (imgnli (in, ibuf, Meml[iv]) != EOF) # get and sum next row
	            call aaddr (Memi[ibuf], Memi[tbuf], Memi[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_LONG:  
	         if (imgnll (in, ibuf, Meml[iv]) != EOF) # get and sum next row
	            call aaddl (Meml[ibuf], Meml[tbuf], Meml[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_REAL:  
	         if (imgnlr (in, ibuf, Meml[iv]) != EOF) # get and sum next row
	            call aaddr (Memr[ibuf], Memr[tbuf], Memr[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_DOUBLE: 
	         if (imgnld (in, ibuf, Meml[iv]) != EOF) # get and sum next row
	            call aaddr (Memd[ibuf], Memd[tbuf], Memd[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      case TY_COMPLEX: 
	         if (imgnlx (in, ibuf, Meml[iv]) != EOF) # get and sum next row
	            call aaddr (Memx[ibuf], Memx[tbuf], Memx[tbuf], npixels)
	         else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      }

              if ( mod(j,cfactor) == 0 || num_rows == 1 ) # is it time to collapse??
	      { 		                    # collapse summed rows
	         switch (IM_PIXTYPE(out)) 
	   	 {
	   	    case TY_SHORT: 
	               if (impnls(out, obuf, Meml[ov]) != EOF)  
		       {
        	          call aclrs(Mems[obuf], res)
                    	  call collapses(Mems[tbuf], Mems[obuf], cfactor, pixels)
		       }
	               else
		    	  call error(EA_ERROR, "Unexpected EOF - put next line")
                       call aclrs (Mems[tbuf], npixels)   # zero tbuf

	    	    case TY_INT:   
	               if (impnli(out, obuf, Meml[ov]) != EOF)  
		       {
        	          call aclri(Memi[obuf], res)
                    	  call collapsei(Memi[tbuf], Memi[obuf], cfactor, pixels)
		       }
	               else
		    	  call error(EA_ERROR, "Unexpected EOF - put next line")
                       call aclri (Memi[tbuf], npixels)   # zero tbuf

	   	    case TY_LONG:  
	               if (impnll(out, obuf, Meml[ov]) != EOF)  
		       {
        	          call aclrl (0.0, Meml[obuf], res)
                    	  call collapsel(Meml[tbuf], Meml[obuf], cfactor, pixels)
		       }
	               else
		    	  call error(EA_ERROR, "Unexpected EOF - put next line")
                       call aclrl (Meml[tbuf], npixels)   # zero tbuf
		        
	   	    case TY_REAL:  
	               if (impnlr(out, obuf, Meml[ov]) != EOF)  
		       {
        	          call aclrr (Memr[obuf], res)
                    	  call collapser(Memr[tbuf], Memr[obuf], cfactor, pixels)
		       }
	               else
		    	  call error(EA_ERROR, "Unexpected EOF - put next line")
                       call aclrr (Memr[tbuf], npixels)   # zero tbuf
		        
	   	    case TY_DOUBLE: 
	               if (impnld(out, obuf, Meml[ov]) != EOF)  
		       {
        	          call aclrd (Memd[obuf], res)
                    	  call collapsed(Memd[tbuf], Memd[obuf], cfactor, pixels)
		       }
	               else
		    	  call error(EA_ERROR, "Unexpected EOF - put next line")
                       call aclrd (Memd[tbuf], npixels)   # zero tbuf
		        
	   	    case TY_COMPLEX: 
	               if (impnlx(out, obuf, Meml[ov]) != EOF)  
		       {
        	          call aclrx (Memx[obuf], res)
                    	  call collapsex(Memx[tbuf], Memx[obuf], cfactor, pixels)
		       }
	               else
		    	  call error(EA_ERROR, "Unexpected EOF - put next line")
                       call aclrx (Memx[tbuf], npixels)   # zero tbuf
		        
	   	 }
              }
           }
        }
                 
	call compress_hist (out, Memc[in_image], Memc[out_image], cfactor)
	call imunmap (in)
	call imunmap (out)

	call finalname(Memc[tempname], Memc[out_image])

	call sfree (sp)
	end
	
# ---------------------------------------------------------------------------	
#   compress_hist  - write history to the output image
# ---------------------------------------------------------------------------	
	
procedure compress_hist (out, in_image, out_image, cfactor)

pointer out
char    in_image[ARB]
char    out_image[ARB]
int     cfactor

char    buf[SZ_LINE]

begin

	call sprintf(buf, SZ_LINE, "%s (block=%d) -> %s")
	  call pargstr(in_image)
	  call pargi(cfactor)
	  call pargstr(out_image)
	call put_imhistory(out, "imcompress", buf, "")

end

