#$Header: /home/pros/xray/xplot/imcontour/RCS/imc_rddata.x,v 11.0 1997/11/06 16:38:09 prosb Exp $
#$Log: imc_rddata.x,v $
#Revision 11.0  1997/11/06 16:38:09  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:57  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:13  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/15  15:02:30  janet
#jd - alloc's badrow with a calloc instead of salloc to init space to 0.
#
#Revision 7.0  93/12/27  18:48:36  prosb
#General Release 2.3
#
#Revision 6.1  93/12/17  08:59:39  janet
#jd - updated to fix prosbug #656, reading -00 DEC.
#
#Revision 6.0  93/05/24  16:41:07  prosb
#General Release 2.2
#
#Revision 5.1  93/04/06  11:53:58  janet
#added check for No sources in list, skip src marking if true.
#
#Revision 5.0  92/10/29  22:35:11  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:42  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/24  16:44:32  janet
#*** empty log message ***
#
#Revision 3.1  92/01/15  13:31:11  janet
#*** empty log message ***
#
#Revision 3.0  91/08/02  01:24:03  prosb
#General Release 1.1
#
#Revision 1.2  91/07/26  11:23:58  janet
#*** empty log message ***
#
#Revision 1.1  91/07/26  03:02:38  wendy
#Initial revision
#
#Revision 2.2  91/05/30  12:37:00  janet
#added position check that skips the input Src when out of range and
#prints warning.
#
#Revision 2.0  91/03/06  23:21:01  pros
#General Release 1.0
#
# ---------------------------------------------------------------------
#
# Module:	IMC_RDDATA.X 
# Project:	PROS -- ROSAT RSDC
# Purpose:	Retrieve data from appropriate input file
# Includes:	get_image_data(), get_sigma_data(), 
#               get_src_ascii_data(), get_src_tab_data()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte -- October 1989 -- initial version
#		{1} JD -- May 1991 -- Updated get_src_data to skip 
#                   bad input lines, correctly handle neg declinations,
#                   and warn user and skip neg ra's, and out of range
#                   positions
#               {2} JD -- Sep 1991 -- Added routine get_src_tab_data
#                         to input src ra/dec from a stsdas table file
#
# ---------------------------------------------------------------------

include <imset.h>
include <imhdr.h>
include <tbset.h>
include <error.h>
include <gset.h>
include <precess.h>
include <math.h>
include <ctype.h>
include "imcontour.h"

# ---------------------------------------------------------------------
#
# Function:	 get_image_data()
# Purpose:	 read image data into photon buffer
# Returns:	 photon buffer of image data
# Pre-condition: input image already opened
#
# ---------------------------------------------------------------------
procedure get_image_data (im, display, photons)

pointer im			# i: image file handle
int     display                 # i: display level
pointer	photons			# o: stored photons

int	i			# l: loop counter
int     cols, rows		# l: number of rows and columns
long    iv[IM_MAXDIM]		# l: input vector buf
pointer imbuf                   # l: row input buffer

pointer imgnlr()
# int     imaccf()
# real    imgetr()

begin

#  Check binroll in header
#        if ( imaccf (im, "x_binroll") == YES) {
#	   if (imgetr (im, "x_binroll") != 0.0) {
#	      call error(1,"Images Must have Binned Roll of 0.0")
#	   }
#	} else {
#	   call printf("NO X-ray Header -- Binned roll assumed 0.0\n")
#	}

#   Read in image - get photons
	cols = IM_LEN(im,1)
	rows = IM_LEN(im,2)
#  	if ( cols != rows ) {
#  	   call error(1,"# of Cols and Rows in Image must be Equal")
# 	}

	if ( display > 0 ) { 
	   call printf ("\n\t Input Image Size is %d x %d Pixels \n\n")
             call pargi (cols)
             call pargi (rows)
	}
	
	call calloc (photons, cols*rows, TY_REAL)
        call amovkl (long(1), iv, IM_MAXDIM)

        for (i=1; i<=rows; i=i+1) {
	   if (imgnlr (im, imbuf, iv) != EOF) { 
	      call aaddr (Memr[imbuf], Memr[photons+(i-1)*cols], 
			  Memr[photons+(i-1)*cols], cols)
 	   }
	}

end

# ---------------------------------------------------------------------
#
# Function:	 get_sigma_data()
# Purpose:	 read error image data apply the error to the photon data
# Returns:	 photon buffer with error image data applied
# Pre-condition: input error image already opened
# Notes:         return_data = img_data / sqrt(error_data)
#
# ---------------------------------------------------------------------
procedure get_sigma_data (er, im, photons)

pointer er 			# i: error image file handle
pointer im			# i: image file handle
pointer	photons			# i/o: stored photons

pointer	errbuf			# l: error photons
pointer	sqrt_err		# l: sqrt of error photons
int	i,j			# l: loop counter
int     cols, rows		# l: number of rows and columns img
int     ecols, erows		# l: number of rows and columns in error img
int     pptr                    # l: photon array pointer
long    iv[IM_MAXDIM]		# l: input vector buf

pointer imgnlr()
# int     imaccf()
# real    imgetr()

begin

#  Check binroll in header
#        if ( imaccf (er, "x_binroll") == YES) {
#	   if (imgetr (er, "x_binroll") != 0.0) {
#	      call error(1,"Images Must have Binned Roll of 0.0")
#	   }
#	} else {
#	   call printf("NO X-ray Header -- Binned roll assumed 0.0\n")
#	}

#   Read in image - get photons

#   Image & Error Image must be same size
	cols = IM_LEN(im,1)
	rows = IM_LEN(im,2)
	ecols = IM_LEN(er,1)
	erows = IM_LEN(er,2)
	if ( ( ecols != cols ) | ( erows != rows ) ) {
	   call error(1,"Size of Image & Error Image must be Equal")
	}

	call calloc (sqrt_err, ecols, TY_REAL)
        call amovkl (long(1), iv, IM_MAXDIM)

        for (i=1; i<=erows; i=i+1) {
           pptr = (i-1)*cols
	   if (imgnlr (er, errbuf, iv) != EOF) { 
              for (j=1; j<=ecols; j=j+1) {
	         if (Memr[errbuf+(j-1)] <= 0.0) { 
                   Memr[photons+pptr+(j-1)] = 0.0
	         } else { 
                   Memr[photons+pptr+(j-1)] = Memr[photons+pptr+(j-1)] /
					      sqrt (Memr[errbuf+(j-1)])
		 }
	      }
 	   }
	}
	call mfree (sqrt_err, TY_REAL)

end

# ---------------------------------------------------------------------
#
# Function:	 get_ascii_src_data()
# Purpose:	 retrieve source data from ascii file input
# Returns:	 number of sources and pixel positions
#
# ---------------------------------------------------------------------

procedure get_ascii_src_data (debug, doimg, fname, img_fname, 
		              nsrcs, xpos, ypos)

int     debug			# i: debug level
bool    doimg			# i: image to get info?
char	fname[ARB]		# i: source ascii file name
char    img_fname[ARB]          # i: contour image name

int     nsrcs			# o: number of sources
pointer xpos			# o: x source positions
pointer ypos			# o: y source positions


bool    colfmt, spfmt		# l: ascii src list formats
bool    badfmt	 		# l: ascii src list error formats
char    sgn			# l: assign sign to a char string
pointer dhstr
pointer badrow                  # l: buffer with bad format row numbers to skip
#pointer buf                    # l: tangent buffer
pointer in			# l: ascii src list logical unit
pointer label			# l: label string of 7 col input
pointer line 			# l: line buffer
pointer oct			# l: coord transfer pointer
pointer sp			# l: salloc mark pointer
int	i,j,k			# l: loop counter
int     idx			# l: string index
int     isystem, osystem	# l: in/out coord sys indexes
int     numcol			# l: # cols in ascii src list 
int     place			# l: BOF position
int     rh, rm, dh, dm		# l: ra/dec hours & minutes
int     brnum, rnum             # l: bad row and row num pointers
int     rowone			# l: number of input columns
real    rs, ds			# l: ra/dec seconds
real 	ra, dec			# l: ra/dec in degrees
real    xpix, ypix              # l: x/y pixel position of src
double  iepoch, oepoch		# l: in/out epoch
double  iequix, oequix		# l: in/out equinox
double  tx, ty			# l: position

int     fscan(), open(), seek(), nscan(), stridx(), ctoi()

begin
	define HOURS 2
	define PIXELS 4
	define SZ_LABEL 10
        define BR_MAX 100

	call smark (sp)
        call salloc (dhstr,   SZ_LINE, TY_CHAR)
        call salloc (line,    SZ_LINE, TY_CHAR)
        call salloc (label,   SZ_LINE, TY_CHAR)

	call calloc (badrow,  BR_MAX,  TY_INT)

#   Setup the coordinate system for conversion to pixels
        call set_coord_sys (debug, doimg, img_fname, isystem, iequix,
                            iepoch, osystem, oequix, oepoch, oct)

#   Open the source ascii file
	in = open(fname, READ_ONLY, TEXT_FILE)
	nsrcs = 0
        brnum = 0
	colfmt = false; spfmt = false; badfmt = false

#   count the number of input lines so that buffer space can be allocated
#   and determine the input source format 3, 6, or 7 columns used
	while ( fscan(in) != EOF ) {
	   do i = 1, 7 {
	      call gargwrd (Memc[line], SZ_LINE)
	   }
	   numcol = nscan()
	   nsrcs = nsrcs + 1
	   if ( nsrcs == 1 ) {
              rowone = numcol
	      if ( rowone == 2 ) {
		colfmt = true
	        call printf ("\nSrc input has Colon delimeters & 2 Cols\n")
	      } else if ( rowone == 3 ) {
		colfmt = true
	        call printf ("\nSrc input has Colon delimeters & 3 Cols\n")
	      } else if ( rowone == 6 ) {
		spfmt = true
	        call printf ("\nSrc input has Space delimeters & 6 Cols\n")
	      } else if ( rowone == 7 ) {
		spfmt = true
	        call printf ("\nSrc input has Space delimeters & 7 Cols\n")
	      } else {
	        badfmt = true
	        call printf ("\nSrc Input has Undefined Format\n")
	      }
	   } else if ( numcol != rowone ) {
	      call printf ("\n** Warning: Skipping Row %d Undefined Format **\n")
		call pargi (nsrcs)
#   keep list of line numbers where the file in general is correct but a line
#   within the file is bad (differs from line 1) and skip when storing source 
#   positions.  If line 1 has bad format your out of luck.
              if ( brnum < BR_MAX ) {
                 brnum = brnum + 1
                 Memi[badrow+brnum-1] = nsrcs
	      } else {
		 call printf ("> %d Errors in Src List - Check Format\n")
		    call pargi (BR_MAX)
	         badfmt = true
	      }
	   }
        }

#   Only process file with defined line formats 
        if ( !badfmt && (nsrcs > 0) ) {
	   call malloc (xpos, nsrcs, TY_REAL)
	   call malloc (ypos, nsrcs, TY_REAL)
	   i = 0
	   rnum = 0
           brnum = 1

#   reset file ptr to beginning
 	   place = seek(in, 0)
	   call printf ("\nConvert sky coordinates to image pixels\n")
           call flush(STDOUT)

#   Scan file for ra & dec
	   while ( fscan(in) != EOF ) {
              rnum = rnum + 1

#   If the current src number matches one in the bad src list then skip
	      if ( rnum == Memi[badrow+brnum-1] ) {
                 brnum = brnum+1
                 nsrcs = nsrcs - 1
              } else {

#   Column format -> hh:mm:ss.s  dd:mm:ss.s <- format
	         if ( colfmt ) {
                    ra = 0.0; dec = 0.0
		    if ( numcol == 3 ) {
                       call gargwrd (Memc[label], SZ_LINE)
                    }
	            call gargr (ra); call gargr (dec)
 	            call gargstr (Memc[line], SZ_LINE)
                    if ( ra < 0 ) {
		       badfmt = true
                    }

#   Space format -> rh rm rs dh dm ds <- format
	         } else if ( spfmt ) {
                    rh=0; rm=0; rs=0.0
                    dh=0; dm=0; ds=0.0
	            if ( numcol == 7 ) {
		       call gargwrd (Memc[label], SZ_LINE)
		    }
#   Read in the RA
		    call gargi (rh); call gargi (rm); call gargr (rs)

#   Read in the DEC, the hours are read as character so we can check for
#   a 'negative sign' in the string when DEC is 00.
 		    call gargwrd (Memc[dhstr], SZ_LINE)
                    call gargi (dm); call gargr (ds)
		    call gargstr (Memc[line], SZ_LINE)

#   Convert DEC in a string to an integer
                    idx=1
#   check to see if a '+' sign preceeds the degrees in DEC, increment
#   the index if found.
		    sgn = '+'
                    j = stridx (sgn, Memc[dhstr])
		    if ( j > 0 ) {
		         idx=idx+1 
		    }
                    k = ctoi (Memc[dhstr], idx, dh)
	
#                   call printf ("dhstr = %s, dh = %d, j=%d\n")
#                     call pargstr (Memc[dhstr])
#                     call pargi(dh)
#                     call pargi(j)
# 		    call flush (STDOUT)

#   Convert ra/dec handling case of negative declination
		    if ( rh >= 0 ) {
		       ra = real(rh) + real(rm)/60.0 + rs/3600.0
		    } else {
                       badfmt = true
                    }

		    if ( dh > 0 ) {
		       dec = real(dh) + real(dm)/60.0 + ds/3600.0

		    } else if ( dh < 0 ) { 
		       dec = real(dh) - real(dm)/60.0 - ds/3600.0

		    } else if ( dh == 0 ) {
		       dec = real(dm)/60.0 + ds/3600.0

#   check for a '-' before 00 DEC and flip the declination if found 
		       sgn = '-'
                       j = stridx (sgn, Memc[dhstr])
		       if ( j > 0 ) {
		          dec = -dec
		       }
                    }
	         }

#   convert ra in hours to degrees
 	         tx = ra * 15.0;  ty = dec 

#   find which pixels correspond to the ra and dec
                 call precess (tx, ty, isystem, iequix, iepoch,
                               tx, ty, osystem, oequix, oepoch, debug)
	         If ( oct != NULL ) {
                    call mw_c2trand(oct, tx, ty, tx, ty, 0)
	         }

#   Convert to real
		 xpix = real (tx)
                 ypix = real (ty)

#   Bad fmt gets set when ra is negative - display warning and skip the src
                 if ( badfmt ) {
	   	    call sprintf (Memc[line], SZ_LINE,
                    "** Warning: Skipping Source with RA -%h - Bad Format **")
                      call pargr (ra)
                    call printf ("%s\n")
		      call pargstr (Memc[line])
                    nsrcs = nsrcs - 1
                    badfmt = false

#   Everthing is fine and we store the positions for graphing later
		 } else {
		    i = i + 1
 	            Memr[xpos+i-1] = xpix
		    Memr[ypos+i-1] = ypix

	            if ( debug >= 2 ) {
	               call printf ("Src %-3d: %-13h %-13h  %-.2f %-.2f\n")
	               call pargi(i)
	               call pargr(ra)
	               call pargr(dec)
 	               call pargr(Memr[xpos+i-1])
 	               call pargr(Memr[ypos+i-1])
	            }
	         }
	      }
	   }
	} else if ( badfmt ) {
	   call printf ("Bad format in Source List - No Sources Labeled\n")
        } else if (nsrcs <= 0 ) {
	   call printf ("Table Empty - No Sources to Label\n")
	}
	call close(in)
        call sfree(sp)
        call mfree (badrow,TY_INT)

end


# ---------------------------------------------------------------------
#
# Function:      get_tab_src_data()
# Purpose:       retrieve source data from table file input
# Returns:       number of sources and pixel positions
#
# ---------------------------------------------------------------------

procedure get_tab_src_data (debug, doimg, fname, img_fname, nsrcs, 
			    xpos, ypos)

int     debug                   # i: debug level
bool    doimg                   # i: image to get info?
char    fname[ARB]              # i: source table file name
char    img_fname[ARB]          # i: contour image name

int     nsrcs                   # o: number of sources
pointer xpos                    # o: x source positions
pointer ypos                    # o: y source positions

pointer oct                     # l: coord transfer pointer
pointer tp                      # l: table pointer
pointer racol, deccol           # l: ra/dec column pointers
pointer raname, decname         # l: ra/dec column names
pointer sp                      # l: stack pointer
bool    nullflag[25]
int     row			# l: current table row
int     i                       # l: loop counter
int     isystem, osystem        # l: in/out coord sys indexes
int     numrows                 # l: number of table rows
double  iequix, oequix          # l: in/out equinox
double  iepoch, oepoch          # l: in/out epoch
double  tx, ty
real    ra, dec

bool    streq()
int     tbtopn()
int     tbpsta()

begin

	call smark (sp)
        call salloc (raname,  SZ_LINE, TY_CHAR)
        call salloc (decname, SZ_LINE, TY_CHAR)

#   Set up the coordinate system for the Src Input
	call set_coord_sys (debug, doimg, img_fname, isystem, iequix, 
			    iepoch, osystem, oequix, oepoch, oct)

#   Open the table file with ra/dec columns
	tp = tbtopn (fname, READ_ONLY, 0)
        nsrcs = tbpsta (tp, TBL_NROWS)
        if ( nsrcs > 0 ) {

	   call clgstr ("racol" , Memc[raname], SZ_LINE)
           if ( streq("NONE", Memc[raname]) | streq("", Memc[raname]) ) {
              call error (1, "Column Name Not Found!!")
           } else {
              call initcol (tp, Memc[raname], racol)
           }

	   call clgstr ("deccol", Memc[decname], SZ_LINE)
           if ( streq("NONE", Memc[decname]) | streq("", Memc[decname]) ) {
              call error (1, "Column Name Not Found!!")
           } else {
              call initcol (tp, Memc[decname], deccol)
           }

#   Init the src pos buffers
           i = 0
           numrows = nsrcs
	   call malloc (xpos, nsrcs, TY_REAL)
	   call malloc (ypos, nsrcs, TY_REAL)

#   Read the src ra/dec and convert from degrees to pixels 
           do row = 1, numrows {
	      call tbrgtr (tp, racol, ra, nullflag, 1, row)
	      call tbrgtr (tp, deccol, dec, nullflag, 1, row)

              if ( ra < 0 ) {
                 nsrcs = nsrcs - 1
              } else {
                 tx = double ( ra ) 
                 ty = double ( dec )

	         call precess ( tx, ty, isystem, iequix, iepoch, 
                                tx, ty, osystem, oequix, oepoch, debug)
                 if ( oct != NULL ) {
		    call mw_c2trand (oct, tx, ty, tx, ty, 0)
                 }

	         i = i+1
                 Memr[xpos+i-1]= real (tx)
	         Memr[ypos+i-1]= real (ty)

                 if ( debug >= 2 ) {
                    ra = ra / 15.0
	            call printf ("Src %-3d: %-13h  %-13h %-.2f %-.2f\n")
                    call pargi (i)
                    call pargr (ra)
	            call pargr (dec)
	            call pargr (Memr[xpos+i-1])
	            call pargr (Memr[ypos+i-1])
	         }
	      }
	   }
	} else {
           call printf ("Ascii List Empty - No Sources to Label\n")
        }
        call tbtclo (tp)
        call sfree(sp)
end

# ---------------------------------------------------------------------
#
# Function:      set_coord_sys ()
# Purpose:       set up the coordinate system for source input
# Returns:       input / ouput coordinat systems
#
# ---------------------------------------------------------------------

procedure set_coord_sys (debug, doimg, img_fname, isystem, iequix, iepoch, 
			 osystem, oequix, oepoch, oct)

int     debug                   # i: debug level
bool    doimg			# i: whether input image exists
char    img_fname[ARB]          # i: source table file name
int     isystem, osystem        # o: in/out coord sys indexes
double  iequix, oequix          # o: in/out equinox
double  iepoch, oepoch          # o: in/out epoch
pointer oct                	# o: coord transfer pointer

pointer imw, omw                # l: in/out wcs pointer
pointer str                     # l: isystem format string
pointer ict                	# l: coord transfer pointer
pointer istring, ostring        # l: output coord sytem string
pointer sp                      # l: stack pointer

pointer mw_sctran()

begin

	call smark (sp)
        call salloc (str,     SZ_LINE, TY_CHAR)
        call salloc (istring, SZ_LINE, TY_CHAR)
        call salloc (ostring, SZ_LINE, TY_CHAR)

#  Setting up coordinate system - parsect
        call clgstr("isystem", Memc[str], SZ_LINE)
        if ( ( Memc[str] == NULL ) && ( doimg ) ) {
           call str2wcs(img_fname, Memc[istring], imw, isystem, iequix, iepoch)
        } else {
           call str2wcs(Memc[str], Memc[istring], imw, isystem, iequix, iepoch)
        }

        if ( imw != NULL ) {
           ict = mw_sctran (imw, "logical", "world", 3)
           if ( debug >= 4 ) {
              call printf ("Setting ict to World coords\n")
           }
        } else {
           ict = NULL
           if ( debug >= 4 ) {
              call printf ("Setting ict to Null\n")
           }
        }

        if ( doimg ) {
          call str2wcs(img_fname, Memc[ostring], omw, osystem, oequix, oepoch)
        } else {
          call printf ("No Image Available to set Src list out system\n")
#         call salloc (buf, SZ_LINE, TY_CHAR)
#         call clgstr("osystem", Memc[str], SZ_LINE)
#         call sprintf (Memc[buf],SZ_LINE,"tangent %f %f %f %f = %f %f 0.0 %s")
#           call pargr (IMPIXX(plt_const)*.5)
#           call pargr (IMPIXY(plt_const)*.5)
#           call pargr (-1.*SATODEG(SAPERPIXX(plt_const)))
#           call pargr (SATODEG(SAPERPIXX(plt_const)))
#           call pargd (RADTODEG(CEN_RA(plt_const)))
#           call pargd (RADTODEG(CEN_DEC(plt_const)))
#           call pargstr (Memc[str])
#         call printf ("%s\n")
#           call pargstr(Memc[buf])
#         call str2wcs(Memc[buf], Memc[ostring], omw, osystem, oequix, oepoch)
        }

        if ( omw != NULL ) {
           oct = mw_sctran (omw, "world", "logical", 3)
           if ( debug >= 4 ) {
              call printf ("Setting oct to logical coords\n")
           }
        } else {
           oct = NULL
           if ( debug >= 4 ) {
              call printf ("Setting oct to Null\n")
           }
        }

        call sfree (sp)

end
