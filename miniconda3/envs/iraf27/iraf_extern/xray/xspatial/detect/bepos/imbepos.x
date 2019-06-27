#$Header: /home/pros/xray/xspatial/detect/bepos/RCS/imbepos.x,v 11.0 1997/11/06 16:31:54 prosb Exp $
#$Log: imbepos.x,v $
#Revision 11.0  1997/11/06 16:31:54  prosb
#General Release 2.5
#
#Revision 9.1  1996/11/15 16:38:25  prosb
#*** empty log message ***
#
#JCC(11/14/96) - Display a "warning" message when the input is not QPOE
#              - Remove unused variable "cell_area"
#              - calc_bpos() is just same as calcbs() and it's in calcbs.x 
#
#Revision 9.0  1995/11/16  18:50:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:34  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:36:38  mo
#MC	7/2/93		Correct 'int' function usage to NOT be boolean
#
#Revision 6.0  93/05/24  16:14:34  prosb
#General Release 2.2
#
#Revision 5.2  93/05/13  11:55:21  janet
#jd - updated printout, added xexamine degug level, added .5 to out positions.
#
#Revision 5.1  92/11/24  12:22:32  janet
#Changed 'bkcts' to 'bkcellcts' .
#
#Revision 5.0  92/10/29  21:31:53  prosb
#General Release 2.1
#
#
#***********************************************************************
#   general description:
#   imbepos reads the rough positions and related parameters calculated
#   by detect as input to determine whether it really is a source, the
#   position of the source, and statistical probabilities.  the algorithm
#   uses the liklihood ratio parameter technique (cf. preprint by w. cash,
#   and memos by s. murray, ssm-102-78 ans ssm-103-78).
#   the method was used for the einstein ipc and is given in detail in sao
#   special report 393 by harnden, fabricant, harris, and schwarz.
#
#***********************************************************************

include <ext.h>
include <imhdr.h>
include <mach.h>
include <math.h>
include <tbset.h>
include <fset.h>
include "bepos.h"

define windo_dim                512
define sqarcsec_per_sqarcmin    3600.0
define DEGTOSA                  (3600.0*($1))

procedure t_bepos() 

bool 	clobber			# clobber existing file?
bool 	good_position
bool 	hit_max_iter 		# indicates if we hit the max 
				# num of convergence iterations
bool 	out_of_bnds 		# indicates if the coords went out
				#   of the src_windo boundaries

int 	bin_coords[2,2] 	# bin circle min  max coords in 
#int 	cell_area 		# detect cell area in pixels
int 	cnts_in_bin 		# tally of photons in the bin circle
int 	cur_src 		# current src ptr
int 	debug 			# debug level
int	eqkey
int 	error_code 		# code indicating failure
int 	max_conf_iter 		# max num of iter for confidence
int 	max_iter		# max num  of iter for convergence
# int 	num_coeff 		# num of snr coefficients
int 	num_of_conf         	# num of confidence levels
int 	num_rpos_srcs 	    	# num of rough position srcs
int     pcflag                  # position confidence flag 0/1
int 	pos_out 		# bepos output 
int 	reason_for_failure[10]  # debug tally of failure causes
				# pos of det cell size
int 	yx_cell_size[2]     	# x  y det cell sizes

pointer  bp_tab			# bepos file name
pointer  bp_bin			# bepos file name
pointer  bintemp
pointer  icolptr[15]
pointer  im
pointer  imw, ict
pointer  instr
pointer  ocolptr[25]
pointer  otp
pointer  poe_fname 		# poe file name
pointer  rough_fname 		# rough file name
pointer  rtp
pointer  sp
pointer  src_windo		# poe photon array at zm 1
pointer  tabtemp
pointer  telescope
pointer ptp
pointer pcolptr[10]

real    aa, bb, cc, dd, ee
real 	arcsec_per_pix 		# num of arcsecs per pixel
real 	b_to_s_factor 		# b/s factor
real 	bin_efficiency 		# fraction of cts falling inside the

			        #    bin circle
real 	bin_radius 		# radius of the bin circle
real 	bkcellcts		# computed bk cts in det cell
real    bkcts_in_det_cell   	# bkgd tally centered at the
real 	bkdensity 		# bkgd density in cts/arcmin**2
real 	bk_cts 			# bk tally det cell size around 
				#   best position
#real    cell_size_snr_thresh 	# snr thresh for a cell size
#real    cell_snr_factor 	# snr scale factor
real    alpha			# approx. for the integral of the 
			        #   prf over the detect cell
real    beta
real    c0_final 		# final computed c-statistic
real    det_center[2]
real    conv_epsilon[2] 	# convergence epsilon for c  s
real    conf_levels[10] 	# confidence levels for pos conf calc
real    e_bepos_xy[2] 	   	# bepos in array element coords
real    e_rough_xy[2] 		# rough pos in array element coords
real	energy			# energy (keV)
real    init_b0 		# initial bkgd cnts estimate
real    init_c0 		# initial cstatistic estimate
real    init_s0 		# initial src cts estimate
real    opt_radius_sigma 	# optimum radius 

real    p_bepos_xy[2] 		# bepos in array pixel coords
real    p_rough_xy[2] 		# rough pos in array pixel coords
real    pbkden 			# bkgd density in pixels
real    pos_confidences[10] 	# calc pos confidence of conf_levels
real    prob_src_nonzero        # calc probability that src is nonzero
real    refine_limit 		# limit between rough  best pos
real    s0_final 		# final computed src cnts
real    snr 			# calc snr value
#real    snr_coeff[0:100]    	# input snr coefficients from sys param
real    snr_thresh 		# signal-to-noise ratio threshold
#real    snr_thresh_min 	# signal-to-noise ratio threshold min
real    src_cts 		# photon tally det cell size around 
				#   best position
real	srcts_in_det_cell   	# photon tally centered at the rough 
real    src_sigma 		# prf for the src
real    prf_sigma 		# prf for the src


bool    clgetb()
int     clgeti()
int     qpc_isqpoe()
pointer immap()
pointer mw_sctran()
pointer mw_openim()
pointer tbtopn()
real    clgetr()

begin

      call fseti (STDOUT, F_FLUSHNL, YES)

      call smark(sp)
      call salloc (poe_fname, SZ_PATHNAME, TY_CHAR)
      call salloc (rough_fname, SZ_PATHNAME, TY_CHAR)
      call salloc (bp_tab, SZ_PATHNAME, TY_CHAR)
      call salloc (bp_bin, SZ_PATHNAME, TY_CHAR)
      call salloc (bintemp, SZ_PATHNAME, TY_CHAR)
      call salloc (instr, SZ_LINE, TY_CHAR)
      call salloc (tabtemp, SZ_PATHNAME, TY_CHAR)
      call salloc (telescope, SZ_LINE, TY_CHAR)
      call salloc (src_windo, windo_dim*windo_dim, TY_INT)

      pos_out =  0

#   read system parameters 
#      cell_snr_factor = clgetr ("fine_snr_factor")
      snr_thresh = clgetr ("snr_thresh")
      clobber = clgetb("clobber")

#   read program parameters 
      max_conf_iter = clgeti ("max_conf_iter")
      max_iter = clgeti ("max_iter")
      num_of_conf = clgeti ("num_conf_levels")
      debug = clgeti ("display")
      conf_levels[1] = clgetr("conf_68")
      conf_levels[2] = clgetr("conf_90")
      conv_epsilon[c] = clgetr ("c_conv_epsilon") 
      conv_epsilon[s] = clgetr ("s_conv_epsilon")
      opt_radius_sigma = clgetr ("optimum_radius_sigma")
      refine_limit = clgetr ("refine_limit")

#    Open the Qpoe file for reading
      if ( debug != 10 ) {
        call printf ("\n*** PI bands must be Respecified with input QPOE ***\n\n")
      }
      call clgstr ("qpoe", Memc[poe_fname], SZ_PATHNAME)
      call rootname ("", Memc[poe_fname], EXT_QPOE, SZ_PATHNAME)
      if ( (qpc_isqpoe(Memc[poe_fname])== NO) ) {
#JCC (11/14/96) - Display a warning message when the input is not QPOE
#        call error (1,"Input QPOE file not Accessible!!")
         call printf("Warning - Input file is not QPOE !!\n")
      }

      im = immap (Memc[poe_fname], READ_ONLY, 0)
      imw = mw_openim(im)
      ict = mw_sctran(imw, "logical", "world", 3B)
      call get_hdrinfo (im, debug, arcsec_per_pix, Memc[instr], 
 		        Memc[telescope], det_center)

#   Convert bkdensity in cts/sq arc-min to bkden in cts/sq pixel
      bkdensity = clgetr ("bkden")
      pbkden=(arcsec_per_pix**2 * bkdensity)/sqarcsec_per_sqarcmin

#   Open the rough pos file for reading rough src info
      call clgstr ("rough_fname", Memc[rough_fname], SZ_PATHNAME)
      call rootname (Memc[poe_fname], Memc[rough_fname],EXT_RUF, SZ_PATHNAME)
      rtp = tbtopn (Memc[rough_fname], READ_ONLY, 0)

#   Open output best positions table
      call clgstr ("bepos_tab", Memc[bp_tab], SZ_PATHNAME)
      call rootname (Memc[rough_fname], Memc[bp_tab], EXT_POS, SZ_PATHNAME)
      call clobbername(Memc[bp_tab],Memc[tabtemp],clobber,SZ_PATHNAME)
      otp = tbtopn (Memc[tabtemp], NEW_FILE, 0)

#   Init the input and output table columns
      call init_outtab (otp, ocolptr)
      call init_intab (rtp, icolptr, num_rpos_srcs)

#   Check if the User set src_sigma & energy
     prf_sigma = clgetr ("prf_sigma")
     energy = clgetr ("energy")
     if ( prf_sigma <= EPSILONR ) {
        call init_prftab (ptp, pcolptr)
        call prf_lookup (ptp, pcolptr, Memc[instr], Memc[telescope], 
		         energy, debug, eqkey, aa, bb, cc, dd, ee)
     }

#   Print out the input qpoe and bkden used
      if ( debug >= 1 && debug != 10 ) {
	call printf ("\nInput Qpoe: %s\n")
           call pargstr (Memc[poe_fname])
        call printf ("bkden = %f (cts/sq arc-min), %f (cts/sq pixel)\n\n")
          call pargr (bkdensity)
          call pargr (pbkden)
      }

#   Setup display level with src detection printout
      if ( debug > 1 ) {
         call printf ("\n%d Rough Position(s) Input\n")
           call pargi (num_rpos_srcs)

         call printf ("\n src#      ra            dec       physx    physy  cellcnts framecnts snr\n")
         call printf ("---------------------------------------------------------------------------\n")
      }

#   --- The work really starts here ---
#   -----------------------------------
      do cur_src = 1, num_rpos_srcs  {

	 error_code = noerror

         call sdata (cur_src, debug, windo_dim, arcsec_per_pix, icolptr, 
                     src_windo, srcts_in_det_cell, yx_cell_size, 
                     e_rough_xy, p_rough_xy, rtp, im)

         call calcef (yx_cell_size, p_rough_xy, arcsec_per_pix, det_center, 
		      eqkey, aa, bb, cc, dd, ee, prf_sigma, debug, 
                      src_sigma, alpha, beta)

#   init src cts and c-statistic
         bkcellcts = pbkden * yx_cell_size[x] * yx_cell_size[y]
         bkcts_in_det_cell = bkcellcts
         init_s0 =(srcts_in_det_cell-bkcts_in_det_cell)/alpha
         init_c0 = 0.0
         snr = 0.0

#   calculate the bin radius
         call calcor (pbkden, init_s0, opt_radius_sigma, src_sigma, 
                      b_to_s_factor, bin_efficiency, bin_radius)

	 if ( debug >= 5 && debug != 10 ) {
            call printf ("bin_efficiency=%f, bin_radius=%f\n")
               call pargr (bin_efficiency)
               call pargr (bin_radius)
	 }
#   calculate cell snr threshold
#        cell_area = yx_cell_size[x]*yx_cell_size[y]

# --- this code requires that simulations have been run and there is an
#     way to compute the snr thresh ... until this happens we will use the
#     input user param
#         call get_snrcoeff (cell_area, num_coeff, snr_coeff, snr_thresh_min)
#         call celsnr (num_coeff, bkdensity, snr_coeff, snr_thresh_min, 
#                      cell_size_snr_thresh)
#         snr_thresh = cell_size_snr_thresh * cell_snr_factor
# ----

#   inititalize bkgd cts
         init_b0 = PI * bin_radius * bin_radius * pbkden

         if ( debug >= 4 && debug != 10 ) {
            call printf ("bepos snr_thresh = %f\n")
               call pargr (snr_thresh)
          }

#   calculate the best source position
#   JCC- calc_bpos() is just same as calcbs() and it's in calcbs.x.
         call calc_bpos (debug, max_iter, windo_dim, Memi[src_windo], 
                         b_to_s_factor, bin_efficiency, bin_radius,
                         conv_epsilon, e_rough_xy, init_b0, init_c0, init_s0,
                         src_sigma, bin_coords, cnts_in_bin, hit_max_iter,
                         out_of_bnds, c0_final, e_bepos_xy, s0_final)

         call chkres (cnts_in_bin, out_of_bnds, e_bepos_xy, e_rough_xy, 
                      refine_limit, error_code, reason_for_failure, 
                      good_position)

         if ( good_position ) {

            if ( debug >= 4 && debug != 10 ) {
               call printf ("-- Yes, I've got a good position\n")
            }

#           Add 0.5 to convert from SAO pixel numbering scheme to IRAFs
            p_bepos_xy[x] = (p_rough_xy[x]-(windo_dim/2)) +
                            (e_bepos_xy[x]-1) + 0.5
            p_bepos_xy[y] = (p_rough_xy[y]-(windo_dim/2)) +
                            (e_bepos_xy[y]-1) + 0.5

#           bk_cts=bkcts_in_det_cell
            call calc_snr (im, debug, yx_cell_size, p_bepos_xy,
                           bk_cts, src_cts, snr)

            call calcfs (bin_coords, cnts_in_bin, debug, max_conf_iter, 
		num_of_conf, windo_dim, Memi[src_windo], yx_cell_size, 
                b_to_s_factor, bin_efficiency, bin_radius, conf_levels, 
                e_bepos_xy, p_bepos_xy, src_sigma, s0_final, init_b0, 
                snr_thresh, reason_for_failure, error_code, bk_cts, src_cts, 
                pos_confidences, prob_src_nonzero, pcflag, snr)

            if ( error_code == noerror ) { 
               call bepos_out (yx_cell_size, arcsec_per_pix, pos_out, 
                    debug, num_of_conf, bk_cts, src_cts, p_bepos_xy, 
                    p_rough_xy, pos_confidences, prob_src_nonzero, snr, 
                    pcflag, otp, ocolptr, ict, debug, alpha, beta)
            }

         }

         # for xexamine display ... 10 is the xexamine display level in code
         if ( debug == 10 && error_code != noerror ) {
            call printf (" No Source Found using Maximum-likelihood method & %2d"" detect cell\n")
               call pargi (int(yx_cell_size[x]*arcsec_per_pix))

         } else if ( debug >= 3 && error_code != noerror ) {
            call printf ("Throwing out Rough Src %d, error_code=%d, snr=%f, pos = %.1f, %.1f\n\n")
               call pargi (cur_src)
	       call pargi (error_code)
               call pargr (snr)
               call pargr (p_bepos_xy[x])
               call pargr (p_bepos_xy[y])
         }
      }
#   Write table header
      call write_tbhead (otp, debug, Memc[poe_fname], Memc[rough_fname], 
                         bkdensity, snr_thresh)

#   close files
      call tbtclo(otp)
      call imunmap (im)
      call tbtclo (rtp)
      call finalname (Memc[tabtemp], Memc[bp_tab])
      if ( prf_sigma <= EPSILONR ) {
        call tbtclo (ptp)
      }


      if ( debug > 0 && debug != 10 ) {
         call printf ("\nWriting %d Sources to Output file:  %s\n")
           call pargi (pos_out)
           call pargstr (Memc[bp_tab])
      }

      call sfree(sp)

end
