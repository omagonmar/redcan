# JCC(1/16/98) - Rename the output-region-text-file to "foo_ruf.reg" 
# JCC(7/97) - change MAX_SRCS to 2000 and move it to detect.h
#           - limit the loop up to MAX_SRCS
#           - change the output formats for x, y, dx, dy
#           - add parameter max_src_num and pass it to chk_all()
#
#Revision 1.13  1997/06/23 21:25:28  prosb
#JCC(6/23/97) - field_ul_x, field_ul_y only used in get_windwo()
#
#Revision 1.12  1997/05/22 18:24:49  prosb
#JCC(5/22/97) - display a message at the end of run.
#JCC(4/8/97)  - redefine  box_x_max -> usr_xbox
#                         box_y_max -> usr_ybox
#
#JCC(3/20/97) 
#             - move evt_window before the end of det_run loop
#             - Replace checks.f with chk_all.x
#             - max_num_blobs --> usr_max_bb 
#             - blob_size_limit --> usr_bb_size 
#             - rough_pos_out  --> rowcnt
#             - num_det_cell_sizes --> numcellsize (usr par)
#             - x_cell_size*  --> xcellsize*  (usr par)
#             - y_cell_size*  --> ycellsize*  (usr par)
#             - num_x_subcells  -> outxdim
#             - num_y_subcells  -> outydim
#             - y_subcell  -> yindx
#             - detect_slide  -> usr_smooth
#             - don't pass ycellsize to chk_all() - never be used
#
#Revision 1.7  1997/03/13  18:45:55  prosb
#JCC(3/13/97) - Change the dimension of colptr from 11 to 10.
#
#Revision 1.6  1997/02/19  15:14:14  prosb
#JCC(2/18/97) - add "xshift & yshift "
#
#Revision 1.5  1997/02/10  21:57:18  prosb
#JCC(2/10/97) - pass display to contig.f 
#             - comment out "bim & bk_window" (with #&& in the front)
#
#Revision 1.4  1997/01/24  15:44:29  prosb
#JCC(1/23/97) - display outydim when display.ge.5
#             - truncate to 6 letters (flag1s)
#
#Revision 1.3  1996/12/05  20:33:33  prosb
#JCC(12/5/96) - add the capability to read the prf lookup table in imdetect
#                 get mission from QP_MISSTR(simhead)
#                 get instrume from QP_INSTSTR(simhead)
#                 get prf_sigma from the user parameter (new par)
#                 get energy from the user parameter    (new par)
#
#Revision 1.2  1996/11/15  16:46:33  prosb
#JCC(11/12/96) - change the output column name from xcell to cellx/y,
#                so it can be used directly as an input to BEPOS.
#
#Revision 1.1  1996/11/04  21:52:47  prosb
#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/imdetect.x (rev9.0)
#               - remove xcenter/ycenter & xdetsize/ydetsize from parameter
#                  (i.e. remove det_center[2], x_det_cen/y_det_cen )
#               - pass "sim & comp_fact_src" to "get_window and checks"
#
# -------------------------------------------------------------------------
# Module:       imdetect
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert Einstein exposure file into an IRAF -.pl mask
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet Deponte initial Fortran version 1986 
#		{1} MC ported to IRAF with input image files
#               {n} <who> -- <does what> -- <when>
# -------------------------------------------------------------------------
include	"detect.h"
include "../../lib/ext.h"     #JCC- use /pros/xray/lib/ext.h
                                 # another one in  /pros/xray/xtiming/fft/ext.h
include <qpoe.h>    # QP_CDELT,QP_CRPIX,QP_INSTSTR,QP_MISSTR - /pros/xray/lib
include <coords.h>  # DEGTOSA   - /pros/xray/lib/
include <mach.h>    # EPSILONR     /iraf/iraf_5.5.1/unix/hlib/mach.h

define	MAX_CELLS	5
##define	MAX_SRCS	1000     # was 5000
define  XX              1
define  YY              2

#  t_imdet  -- main task for doing a rough detect on an IRAF image file
procedure t_imdet()

#&&  char bkmap_filename[SZ_PATHNAME]
char poe_filename[SZ_PATHNAME]          # qpoe file
char rpos_filename[SZ_PATHNAME]         # output ruf table file
char tempname[SZ_PATHNAME]
#JCC char rpos_regname[SZ_PATHNAME]     # output region text file : foo_ruf.reg
#JCC char atempname[SZ_PATHNAME]        # output region text file : foo_ruf.reg

bool	clobber

int usr_bb_size                 # blob size limit from user 
int blob_limits_rec[BLOB_LIMITS_FIELDS,MAX_BLOBS]
                                # rec of max's and min's of a blob in Y & X
int blobs_written		# current # blobs written to rough_info
int usr_ybox                    # max box dimensions in subcells from user par
int usr_xbox                    # max box dimensions in subcells from user par
int cell_area		        # area of a subcell in arcsecs
int cwf_type		        # count weight factor type
int display		        # debug output level
int det_run		        # index to main prog loop over det_cell_sizes
int usr_smooth                  # user input for smooth factor ("subcells") 
int field_ul_y		        # upper left Y pixel pos of the poe file
int field_ul_x		        # upper left X pixel pos of the poe file
int flagged_line[MAX_SUBCELLS]  # 1 line of subcells flagged above or
                                # below threshold
int ii
int usr_max_bb                  # user input:  max #blobs allowed per field 
int num_coeff		        # num of snr cooeficients
int numcellsize	        # usr input: num of different detect cell sizes
int outxdim		# output dim of evt_window from imcomp.x 
int outydim		# output dim of evt_window from imcomp.x 
int yindx		# index to current line in final processing window

int prev_line[MAX_SUBCELLS]     # last current_line of blob ptrs 
int rowcnt                      # row index written to root_ruf.tab 
int xcellsize		# user input: size of a detect cell in the y direction
int ycellsize		# user input: size of a detect cell in the Y direction
int xcellsize_buf[MAX_CELLS]  # detect cell sizes in the y direction
int ycellsize_buf[MAX_CELLS]  # detect cell sizes in the Y direction
int x_zoom			# zoom in the X direction
int y_zoom			# zoom in the y direction

#JCC int x_det_cen              # poe center in x
#JCC int x_det_size		# size in x
#JCC int y_det_cen		# poe center in y
#JCC int y_det_size		# size in y
#JCC real det_center[2]		# poe center coords
#&&  pointer bk_window, bim     # bim: image pointers to bkgd

real blob_pos_sums_rec[BLOB_SUM_FIELDS,MAX_BLOBS]
                                # position sums for centroid calculation
real cell_size_snr_thresh	# computed threshold for a particular cell size
real cell_snr_factor	        # snr_thresh detect reducing factor
real field_bk_dens		# bk density of the field
real snr_coeff[0:100]	        # input snr cooeficients from sys param
real snr_thresh_min		# snr thresh lower limit

#real bk_window[MAX_SUBCELLS,MAX_SUBCELLS]  #smoothed and zoomed bkgd array
#int  evt_window[MAX_SUBCELLS,MAX_SUBCELLS])#smoothed and zoomed poe file array
pointer evt_window
pointer	tp, fd, immap()
pointer	 colptr[10], tbtopn(), open()
###pointer colptr[11], tbtopn(), open()

int     clgeti()
bool	clgetb()
real	clgetr()

int  xcomp_fact_src             #compress factor for source
int  ycomp_fact_src             #compress factor for source
real xshift, yshift

pointer	sim

#JCC (12/5/96) - begin
#pointer ssp
pointer simhead                 # poe file
pointer prf_ptp                 # pointer to prfcoeffs.tab
pointer prf_colptr[10]          # pointer to columns in prfcoeffs.tab

real    arcsec_per_pix		# arc seconds per pixel
real    prf_sigma               # prf for the src
real    energy                  # energy(keV) : user input for prfcoeffs.tab
real    aa, bb, cc, dd, ee      # coeff in prfcoeffs.tab

int     eqkey                   # in prfcoeffs.tab
int     strlen()
bool    srcflag               # sources exceeds MAX_SRCS
int     max_src_num, mxsrc    # from user
int     access()                # access file function

#JCC  - end

begin
        #call smark (ssp)

####JCC(3/20/97) - initilize 
        tp  =  0
        rowcnt = 0       # row index written to root_ruf.tab
        call aclrl (colptr, 10)

        blobs_written = 0
        call aclri (blob_limits_rec, BLOB_LIMITS_FIELDS*MAX_BLOBS)
        call aclrr (blob_pos_sums_rec, BLOB_SUM_FIELDS*MAX_BLOBS)
        call aclri (prev_line, MAX_SUBCELLS)

        call aclri (flagged_line, MAX_SUBCELLS)
        call aclri (xcellsize_buf, MAX_CELLS)
        call aclri (ycellsize_buf, MAX_CELLS)

        call aclrr (snr_coeff, 100)
        evt_window = 0
####end



	call clgstr("infile",poe_filename,SZ_PATHNAME)
#&&     call clgstr("backgroundfile",bkmap_filename,SZ_PATHNAME)
	call clgstr("outfile",rpos_filename,SZ_PATHNAME)

        arcsec_per_pix = clgetr( "pixelsize")  #can't replace it from QPOE
        cell_snr_factor = clgetr( "snrfactor")
        usr_smooth = clgeti("subcells")

	usr_bb_size = clgeti("blobsize")
	usr_xbox = clgeti("boxxmax")
	usr_ybox = clgeti("boxymax")
	cwf_type = clgeti("ctwtfactor")
	display = clgeti("display")
#JCC    det_center[1] = clgeti("xcenter")
#JCC   	det_center[2] = clgeti("ycenter")
	usr_max_bb= clgeti("maxblobs")
	numcellsize = clgeti("numcellsizes")

        max_src_num = clgeti("max_src_num")   #JCC(7/97)
        if (max_src_num <= MAX_SRCS)
           mxsrc = max_src_num
        else 
           mxsrc = MAX_SRCS

	do ii = 1,numcellsize
	{
	    xcellsize_buf[ii] = clgeti("xcellsize")
	    ycellsize_buf[ii] = clgeti("ycellsize")
	}
#JCC    x_det_size = clgeti("xdetsize")
#JCC    y_det_size = clgeti("ydetsize")
	clobber=clgetb("clobber")

#JCC (12/5/96) -add "prf_sigma & energy"
        prf_sigma = clgetr ("prf_sigma")
        energy = clgetr ("energy")

	call rootname(poe_filename,rpos_filename,EXT_RUF,SZ_PATHNAME)
#JCC(1/98) call rootname(rpos_filename,rpos_regname,".reg",SZ_PATHNAME)
	call clobbername(rpos_filename,tempname,clobber,SZ_PATHNAME)
#JCC(1/98) call clobbername(rpos_regname,atempname,clobber,SZ_PATHNAME)

#   Get the field bkground density (in cts/sq arcmin)
	field_bk_dens = clgetr("fieldbkdens")

#    Convert from floating point to integer precision
        #JCC x_det_cen = det_center[1]
        #JCC y_det_cen = det_center[2]

	sim = immap( poe_filename, READ_ONLY, 0 )
#&&     bim = immap( bkmap_filename, READ_ONLY , 0 )  # bk_windom removed

#JCC(1/98) fd = open(atempname,NEW_FILE,TEXT_FILE)   
        if (access("foo_ruf.reg", 0, 0)== YES)
           call delete("foo_ruf.reg")
	fd = open("foo_ruf.reg",NEW_FILE,TEXT_FILE)  #JCC(1/98)-region text file

	tp = tbtopn(tempname,NEW_FILE,0)
	call tbcdef(tp,colptr[1],"blob","number","%5d",TY_INT,1,1)
	call tbcdef(tp,colptr[2],"peak","number","%4d",TY_INT,1,1)
	call tbcdef(tp,colptr[3],"x","pixels","%10.2f",TY_REAL,1,1)
	call tbcdef(tp,colptr[4],"y","pixels","%10.2f",TY_REAL,1,1)
	call tbcdef(tp,colptr[5],"dx","pixels","%10.2f",TY_REAL,1,1)
	call tbcdef(tp,colptr[6],"dy","pixels","%10.2f",TY_REAL,1,1)
	call tbcdef(tp,colptr[7],"res?","logical","%2d",TY_INT,1,1)
	call tbcdef(tp,colptr[8],"min r","pixels","%10.2f",TY_REAL,1,1)
	call tbcdef(tp,colptr[9],"cellx","pixels","%3d",TY_INT,1,1)
	call tbcdef(tp,colptr[10],"celly","pixels","%3d",TY_INT,1,1)
	call tbtcre(tp)

	call tbhadt(tp,"source",poe_filename)
#&&     call tbhadt(tp,"background",bkmap_filename)

#JCC    call tbhadi(tp,"xdim",x_det_size)
#JCC    call tbhadi(tp,"ydim",y_det_size)
	call tbhadi(tp,"slide",usr_smooth)
#JCC    call tbhadi(tp,"xcenter",x_det_cen)
#JCC    call tbhadi(tp,"ycenter",y_det_cen)

#******************************************************************
#JCC(12/5/96) -  begin 
#             -  if prf_sigma=0, then read prfcoeffs.tab and
#                get snr_coeff[0:4] from the table  
#******************************************************************
      if ( prf_sigma <= EPSILONR ) {   
          call get_imhead (sim, simhead) 

#     open and read prf coeff. table 
          call init_prftab (prf_ptp, prf_colptr)

#     input "instrument and mission" to read prfcoeffs.tab
          call prf_lookup (prf_ptp, prf_colptr,QP_INSTSTR(simhead),
          QP_MISSTR(simhead), energy, display, eqkey, aa, bb, cc, dd, ee)

          snr_coeff[0] = aa
          snr_coeff[1] = bb
          snr_coeff[2] = cc
          snr_coeff[3] = dd
          snr_coeff[4] = ee
          num_coeff = 3        # from "num_144_snr_coeffs" in imdetect.par
          snr_thresh_min = 2.  # from "snr_144_thresh_min" in imdetect.par 

#     display hdr info
          if ( display >= 5 )  {
             call printf("  QP_MISSTR==%s,  QP_INSTSTR==%s,\n")
             if( strlen(QP_MISSTR(simhead)) != 0 )
                call pargstr(QP_MISSTR(simhead))
             else
                call pargstr("UNKNOWN")
             if( strlen(QP_INSTSTR(simhead)) != 0 )
                call pargstr(QP_INSTSTR(simhead))
             else
                call pargstr("UNKNOWN")

             call printf ("\n  arcsec_per_pix = %f\n")
             call pargr (arcsec_per_pix )
   
             call printf (" energy, eqkey = %f, %d \n")
             call pargr(energy)
             call pargi(eqkey)

             call printf (" aa, bb, cc, dd, ee = %f, %f, %f, %f, %f \n")
             call pargr(aa)
             call pargr(bb)
             call pargr(cc)
             call pargr(dd)
             call pargr(ee)
          }   # end of display 
      }   # end of prf_sigma
#******************************************************************
#JCC(12/5/96) - end
#******************************************************************
 
#    Detect Sources at each detect cell size
	do det_run = 1, numcellsize
	{
             xcellsize = xcellsize_buf[det_run]
             ycellsize = ycellsize_buf[det_run]

             blobs_written = 0
             call aclri (blob_limits_rec,BLOB_LIMITS_FIELDS*MAX_BLOBS)
             call aclrr (blob_pos_sums_rec,BLOB_SUM_FIELDS*MAX_BLOBS)
             call aclri (prev_line,MAX_SUBCELLS)

#JCC(12/5/96) - add a conditional statement :
#               Get snr_coeff[0:4] ONLY if prfcoeffs.tab is not read yet.
#
             if ( prf_sigma > EPSILONR ) {      #JCC
               cell_area = xcellsize*ycellsize * arcsec_per_pix**2
               call get_snrcoeff(cell_area, num_coeff, snr_coeff, 
                                 snr_thresh_min)
             }    #JCC

             call comp_cell_snr (num_coeff, field_bk_dens, snr_coeff,
                            snr_thresh_min, cell_size_snr_thresh)

             cell_size_snr_thresh = cell_size_snr_thresh * cell_snr_factor

             if ( display > 2 ) 
	     {  call printf("Cell SNR Thresh = %f\n")
		call pargr(cell_size_snr_thresh)
             }
	     call tbhadr(tp,"snrthresh",cell_size_snr_thresh)

#     read poe and bkgd files and return an array in subcell dimensions smoothed
#     over detect cell size
# JCC (10/30/96) - updated to pass "sim & comp_fact_src" & remove x_det_cen/y_
#&&  JCC - remove bim and bk_window 
             call get_window (display, usr_smooth, sim, xcellsize,ycellsize,
              arcsec_per_pix, outxdim, outydim, evt_window, field_ul_x, 
              field_ul_y, x_zoom,y_zoom,xcomp_fact_src,ycomp_fact_src,xshift,
              yshift)

#JCC(1/23/97) - display outydim when display.ge.5 
             if (display >= 5)
             { #call flush(STDOUT)
               call printf("imdetect:  numcellsize(from par)= %d\n")
               call pargi(numcellsize)
           
               #call flush(STDOUT)
               call printf("imdetect:  outydim(from get_window)= %d\n")
               call pargi(outydim)
              }

#    slide vertically 1 subcell at a time 
             do yindx = 1, outydim 
	     {
                if (rowcnt > mxsrc )      #MAX_SRCS
                { 
                   srcflag = TRUE
                   break
                }

#    slide horizontally across each line and flag each subcell with detect 
#    cell snr above threshold
# jcc(1/23/97)  call flag_1_line_of_detect_cells (display, 
                call flag1s (display, 
                 Memr[evt_window+(yindx-1)*outxdim],outxdim,
                 cell_size_snr_thresh, flagged_line)

#    group sets of 'on' detect cells of the previous pass with those of
#    the current pass into contiguous regions called 'blobs'
                call contig(usr_bb_size,cwf_type,
                 Memr[evt_window+(yindx-1)*outxdim],
     		 flagged_line,usr_max_bb, outxdim, 
                 prev_line, yindx, blob_limits_rec, 
                 blob_pos_sums_rec, display)    # pass display - JCC

#    now that we've processed 1 line - check for blobs that haven't been
#    updated in this pass; calculate position and radius of these blobs
#    and output the information.
# JCC (10/30/96) - updated to pass "sim & comp_fact_src"
##    usr_xbox, display, evt_window, field_ul_y,field_ul_x,
                call chk_all(sim, usr_bb_size, usr_ybox,
                 usr_xbox, display, evt_window,
                 usr_max_bb, outxdim,outydim, tp,fd, 
		 colptr, yindx, xcellsize, y_zoom, x_zoom, 
                 blob_limits_rec, blobs_written, rowcnt,
                 blob_pos_sums_rec,xcomp_fact_src,ycomp_fact_src,
                 xshift, yshift, mxsrc )

 	    }  # end of yindx loop

        call imunmap(sim)
#&&     call imunmap(bim)             # remove bk_window and bim
	call mfree( evt_window, TY_REAL)
#&&     call mfree( bk_window, TY_REAL)

        }   # end of det_run loop

#   send warning if we have detected more than the max_num_sources for sys
#   reset rowcnt to only write src list for max_num_srcs
        if ( srcflag ) 
	{
           call printf("Max srcs limit ( %d ) exceeded \n")
	   call pargi( mxsrc )
	}

        call tbtclo (tp)
	call close(fd)
	call finalname(tempname,rpos_filename)
#JCC(1/98)  call finalname(atempname,rpos_regname)   # region text file

        call printf("\n -- created output table: %s --\n\n")
        call pargstr(rpos_filename)

#JCC (12/5/96) - for prfcoeffs.tab
        if ( prf_sigma <= EPSILONR ) {
          call tbtclo (prf_ptp)
        }
        #call sfree(ssp)
end
