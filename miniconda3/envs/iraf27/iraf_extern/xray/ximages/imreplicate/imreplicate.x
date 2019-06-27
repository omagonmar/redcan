#$Header: /home/pros/xray/ximages/imreplicate/RCS/imreplicate.x,v 11.0 1997/11/06 16:28:27 prosb Exp $
#$Log: imreplicate.x,v $
#Revision 11.0  1997/11/06 16:28:27  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:31  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:20  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:26:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:07:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:26:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:29:50  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/23  17:40:11  janet
#blocked from working on qpoes, update ck_none tests.
#
#Revision 3.0  91/08/02  01:17:19  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:51:14  pros
#General Release 1.0
#
include <imset.h>
include <imhdr.h>
include <error.h>
include <ext.h>
include <qpoe.h>

define  SZ_EXPR 1024

#------------------------------------------------------------------------
# IMREPLICATE - Replicate an image from one file to another.
#------------------------------------------------------------------------

procedure t_imreplicate ()

bool	clobber				# clobber old filename

pointer in_image			# input image filename
pointer out_image			# output image filename
pointer tempname			# temp image filename

int     i, j, k				# loop counters
int     rfactor				# replication factor
int     yfactor				# y replication factor
int     num_rows			# number of rows in input image
int     num_img				# number of 2-D images

pointer iv				# input image vector
pointer ov				# output image vector
	
pointer in				# input image pointer
pointer out				# output image pointer
pointer ibuf				# input buffer pointer
pointer obuf				# output buffer pointer	
pointer sp				# stack memory pointer
pointer tbuf 				# temporary buffer pointer
pointer filter
pointer imgroot

bool    clgetb()			# get parm bool function
bool    ck_none()                       # check for 'none' filename spec
bool	streq()				# string compare function

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
	call salloc (in_image, SZ_PATHNAME, TY_CHAR)
	call salloc (out_image, SZ_PATHNAME, TY_CHAR)
	call salloc (tempname, SZ_PATHNAME, TY_CHAR)
	call salloc (iv, IM_MAXDIM, TY_LONG)
	call salloc (ov, IM_MAXDIM, TY_LONG)
        call salloc (filter, SZ_EXPR, TY_CHAR)
        call salloc (imgroot, SZ_PATHNAME, TY_CHAR)
 
#   Input file name
        call clgstr ("in_image", Memc[in_image], SZ_PATHNAME)
        if ( (ck_none (Memc[in_image])) || (streq ("", Memc[in_image])) ) {
           call error(1, "requires image file as input")
        }

#   Check if input is a qpoe file - we only work on images
	call qpparse (Memc[in_image], Memc[imgroot], SZ_PATHNAME,
                      Memc[filter], SZ_EXPR)

        if ( qp_access (Memc[imgroot], READ_ONLY) == YES ) {
            call printf ("\n")
            call error (1, "Run IMCOPY on Qpoe files before running IMREPLICATE")
        }

#   Input output filename
        call clgstr ("out_image", Memc[out_image], SZ_PATHNAME)
        call rootname (Memc[in_image],Memc[out_image], EXT_IMG, SZ_PATHNAME)
        if ( (ck_none (Memc[out_image])) || ( streq("", Memc[out_image])) ) {
           call error(1, "Output filename missing")
        }
	clobber = clgetb("clobber")
	call clobbername (Memc[out_image], Memc[tempname], clobber, SZ_PATHNAME)

#   Input replication factor
	rfactor = clgeti ("rfactor")
	
#   Open/create the images
	in  = immap (Memc[in_image], READ_ONLY, 0)
	call new_imcopy (in, Memc[tempname], out)
 
#   Copy input header and update arc_secs_per_pixel
	# look for a wcs
	ifnoerr (mw = mw_openim(out) ) {
	    # get logical terms
	    call mw_gltermd(mw, ltm, ltv, 2)
	    # convert scale factors
	    ltm[1,1] = ltm[1, 1] * rfactor
	    ltm[2,2] = ltm[2, 2] * rfactor
	    #set logical terms
	    call mw_sltermd(mw, ltm, ltv, 2)
	    # and save the wcs
	    call mw_saveim(mw, out)
	}
 
#   Initialize position vectors to line 1, col 1, band 1, ...
	call amovkl (long(1), Meml[iv], IM_MAXDIM)
	call amovkl (long(1), Meml[ov], IM_MAXDIM)
 
#   Setup new output image header
	num_img = 1
	num_rows = 1
        yfactor = 1

        IM_LEN(out,1) = IM_LEN(in,1) * rfactor
	if ( IM_NDIM(in) >= 2 )
	{
	   IM_LEN(out,2) = IM_LEN(in,2) * rfactor
   	   yfactor = rfactor
	   num_rows = IM_LEN(in,2)
	   for (i=3; i<= IM_NDIM(in); i=i+1)
	   {
	      IM_LEN(out,i) = IM_LEN(in,i)
	      num_img = num_img * IM_LEN(out,i)
	   }
	}

	switch (IM_PIXTYPE(out))
	{
	case TY_SHORT:
           call malloc (tbuf, IM_LEN(out,1), TY_SHORT) 
	case TY_INT:
           call malloc (tbuf, IM_LEN(out,1), TY_INT) 
	case TY_LONG:
           call malloc (tbuf, IM_LEN(out,1), TY_LONG) 
	case TY_REAL:
           call malloc (tbuf, IM_LEN(out,1), TY_REAL) 
	case TY_DOUBLE:
           call malloc (tbuf, IM_LEN(out,1), TY_DOUBLE) 
	case TY_COMPLEX:
           call malloc (tbuf, IM_LEN(out,1), TY_COMPLEX) 
	}
 
#   Replicate the image 
 
        for (i=1; i<=num_img; i=i+1)       # iter over number of 2-D images
	{
           for (j=1; j<=num_rows; j=j+1)   # iter over number of row
	   {
	      switch (IM_PIXTYPE(out))
	      {
	      case TY_SHORT:
                 call aclrs(Mems[tbuf], IM_LEN(out,1))   # 0 temp buffer
                 if (imgnls (in, ibuf, Meml[iv]) != EOF)       # read one row
                    call expands(Mems[ibuf], Mems[tbuf], IM_LEN(in,1), rfactor)
                 else
		    call error (EA_ERROR, "Unexpected EOF - get next line")

	      case TY_INT:
                 call aclri(Memi[tbuf], IM_LEN(out,1))   # 0 temp buffer
                 if (imgnli (in, ibuf, Meml[iv]) != EOF)       # read one row
                    call expandi(Memi[ibuf], Memi[tbuf], IM_LEN(in,1), rfactor)
                 else
		    call error (EA_ERROR, "Unexpected EOF - get next line")

	      case TY_LONG:
                 call aclrl(Meml[tbuf], IM_LEN(out,1))   # 0 temp buffer
                 if (imgnll (in, ibuf, Meml[iv]) != EOF)       # read one row
                    call expandl(Meml[ibuf], Meml[tbuf], IM_LEN(in,1), rfactor)
                 else
		    call error (EA_ERROR, "Unexpected EOF - get next line")

	      case TY_REAL:
                 call aclrr(Memr[tbuf], IM_LEN(out,1))   # 0 temp buffer
                 if (imgnlr (in, ibuf, Meml[iv]) != EOF)       # read one row
                    call expandr(Memr[ibuf], Memr[tbuf], IM_LEN(in,1), rfactor)
                 else
		    call error (EA_ERROR, "Unexpected EOF - get next line")

	      case TY_DOUBLE:
                 call aclrd(Memd[tbuf], IM_LEN(out,1))   # 0 temp buffer
                 if (imgnld (in, ibuf, Meml[iv]) != EOF)       # read one row
                    call expandd(Memd[ibuf], Memd[tbuf], IM_LEN(in,1), rfactor)
                 else
		    call error (EA_ERROR, "Unexpected EOF - get next line")

	      case TY_COMPLEX:
                 call aclrx(Memx[tbuf], IM_LEN(out,1))   # 0 temp buffer
                 if (imgnlx (in, ibuf, Meml[iv]) != EOF)       # read one row
                    call expandx(Memx[ibuf], Memx[tbuf], IM_LEN(in,1), rfactor)
                 else
		    call error (EA_ERROR, "Unexpected EOF - get next line")
	      }

	      for (k=1; k<=yfactor; k=k+1) # iter over replication factor
	      {
	         switch (IM_PIXTYPE(out))
		 {
		    case TY_SHORT:
	               if (impnls (out, obuf, Meml[ov]) != EOF) # write out buf
                          call amovs(Mems[tbuf], Mems[obuf], IM_LEN(out,1))
		       else 
		          call error (EA_ERROR, "Unexpected EOF-put next line")
 	
		    case TY_INT:
	               if (impnli (out, obuf, Meml[ov]) != EOF) # write out buf
                          call amovi(Memi[tbuf], Memi[obuf], IM_LEN(out,1))
		       else 
		          call error (EA_ERROR, "Unexpected EOF-put next line")

		    case TY_LONG:
	               if (impnll (out, obuf, Meml[ov]) != EOF) # write out buf
                          call amovl(Meml[tbuf], Meml[obuf], IM_LEN(out,1))
		       else 
		          call error (EA_ERROR, "Unexpected EOF-put next line")

		    case TY_REAL:
	               if (impnlr (out, obuf, Meml[ov]) != EOF) # write out buf
                          call amovr(Memr[tbuf], Memr[obuf], IM_LEN(out,1))
		       else 
		          call error (EA_ERROR, "Unexpected EOF-put next line")

		    case TY_DOUBLE:
	               if (impnld (out, obuf, Meml[ov]) != EOF) # write out buf
                          call amovd(Memd[tbuf], Memd[obuf], IM_LEN(out,1))
		       else 
		          call error (EA_ERROR, "Unexpected EOF-put next line")

		    case TY_COMPLEX:
	               if (impnlx (out, obuf, Meml[ov]) != EOF) # write out buf
                          call amovx(Memx[tbuf], Memx[obuf], IM_LEN(out,1))
		       else 
		          call error (EA_ERROR, "Unexpected EOF-put next line")

		 }
	      }
	   }
	}

	call replicate_hist (out, Memc[in_image], Memc[out_image], rfactor)
	call imunmap (in)
	call imunmap (out)

	call finalname(Memc[tempname], Memc[out_image])
	call smark (sp)
end

# ----------------------------------------------------------------------------
#   replicate_hist - write history to output image header
# ----------------------------------------------------------------------------

procedure replicate_hist (out, in_image, out_image, rfactor)

pointer out
char    in_image[ARB]
char    out_image[ARB]
int     rfactor

char    buf[SZ_LINE]

begin

	call sprintf(buf, SZ_LINE, "%s (block=%d) -> %s")
	  call pargstr (in_image)
	  call pargi (rfactor)
	  call pargstr (out_image)
	call put_imhistory (out, "imreplicate", buf, "")

end
