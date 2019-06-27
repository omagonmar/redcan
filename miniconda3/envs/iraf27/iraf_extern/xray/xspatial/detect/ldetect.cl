# $Header: /home/pros/xray/xspatial/detect/RCS/ldetect.cl,v 11.0 1997/11/06 16:32:42 prosb Exp $
# $Log: ldetect.cl,v $
# Revision 11.0  1997/11/06 16:32:42  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:19  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:11:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:07  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  13:02:18  janet
#jd - added snr thresh parameter for maximum liklihood calc
#
#Revision 6.0  93/05/24  16:13:23  prosb
#General Release 2.2
#
#Revision 5.1  93/01/08  11:03:13  janet
#added  6" cell for ROSAT HRI, 6" & 9" for Einstein HRI in param list.
#
#Revision 5.0  92/10/29  21:33:38  prosb
#General Release 2.1
#
#Revision 1.4  92/10/19  14:11:47  janet
#changed snr_thresh_min to snr_thresh.
#
#Revision 1.3  92/10/14  10:13:08  janet
#removed snr coeffs params. also removed from bepos.
#
#Revision 1.2  92/10/14  10:09:58  janet
#update to carry cellmap qpoe name with pi filters to bepos.
#
#Revision 1.1  92/10/07  11:22:21  janet
#Initial revision
#
#
# Module:       ldetect.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      'canned' local detect task
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version -- Oct 92
#               {n} <who> -- <does what> -- <when>
# ----------------------------------------------------------------------------
# ldetect - 'canned' local detect task 
# ----------------------------------------------------------------------------
procedure ldetect (qpoe, tab)

 file   qpoe	{ prompt="qpoe file ", mode="a"}
 file   tab     { prompt="Output table root", mode="a"}
 int    rh_cellsize {prompt="ROSAT HRI Cellsize in arcsecs - 6|9|12|24|36|48",mode="a"}
 int    rp_cellsize {prompt="ROSAT PSPC Cellsize in arcsecs - 30 [h/b]| 45 [s]| 60 [s/h/b]| 120 [s/h/b]",mode="a"}
 int    eh_cellsize {prompt="Einstein HRI Cellsize in arcsecs - 6|9|12|24|48",mode="a"}
 int    ei_cellsize {prompt="Einstein IPC Cellsize in arcsecs - 144 [h/b]| 240 [s]",mode="a"}
 string eband       {"broad",prompt="Energy Band",mode="a", min="soft|hard|broad"}
 string region  {"default", prompt="Region Descriptor from which to compute bkden", mode="h"}
 real   radius {7.5, prompt="Radius for default region in arc minutes", mode="h"}
 real   fluctuation {1.0, prompt="Background Fluctuation", mode="h"}
 int    max_bkiter {3, prompt="Maximum Iterations", mode="h"}
 real   value {0.0, prompt="Computed bkden", mode="h"}
 real   snr_thresh {2.75, prompt="Minimum SNR Threshold Rough Position", mode="h"}
 real   mlsnr_thresh {3.0, prompt="Minimum SNR Threshold for Maximum Likelihood", mode="h"}
 real	prf_sigma {0.0, prompt="Prf sigma in arcsecs (0.0 for default calculation", mode="h"}
 real   energy {0.0, prompt="Energy (KeV) (0.0 for default coeffs)", mode="h"}
 file   prf_table {"xspatialdata$prfcoeffs.tab", prompt="Prf coefficient table", mode="h"}
 int    max_iter {50, prompt="Maximum Position search iterations", mode="h"}
 int    max_conf_iter {20, prompt="Maximum confidence iterations", mode="h"}
 int    num_conf_levels {2, prompt="Number of confidence levels", mode="h"}
 real   conf_68 {2.3, prompt="Confidence 68", mode="h"}
 real   conf_90 {4.61, prompt="Confidence 90", mode="h"}
 real   refine_limit {45.0, prompt="Refine limit", mode="h"}
 real   optimum_radius {1.8, prompt="Optimum radius sigma", mode="h"}
 real   c_conv_epsilon {1.0, prompt="Convergence epsilon c-statistic", mode="h"}
 real   s_conv_epsilon {1.0, prompt="Convergence epsilon src cnts", mode="h"}
 string cenx_keywd {"CRPIX1", prompt="X center hdr keyword for off-axis angle calc", mode="h"}
 string ceny_keywd {"CRPIX2", prompt="Y center hdr keyword for off-axis angle calc", mode="h"}
 bool   clobber {no, prompt="OK to overwrite exisiting output file?", mode="h"}
 int    display {2, prompt="Display level", mode="h"}


begin

   bool  clob
 
   int   csize

   real  minsnr
   real  mlminsnr

   file imname
   file qpname
   file tabname
   file bname

   string band
   string instrum
   string mission
   string postab
   string ruftab
   string snrimh

   qpname = qpoe
   tabname = tab
   minsnr = snr_thresh
   mlminsnr = mlsnr_thresh
   clob = clobber
   disp = display

# -----------------------------------------------------------
    if ( !deftask("images") ) {
       error(1, "Requires images to be loaded !")
    }

    imgets (image=qpname, param="telescope")
    mission = imgets.value

    imgets (image=qpname, param="instrument")
    instrum = imgets.value

    if ( instrum == "PSPCB" || instrum == "PSPCC" ) {
        instrum = "PSPC"
    } else if ( instrum == "IPC-1" ) {
        instrum = "IPC"
    }

# -----------------------------------------------------------
    if ( mission == "ROSAT" && instrum == "HRI" ) {
       csize = rh_cellsize
       band = "broad"
    } else if ( mission == "ROSAT" && instrum == "PSPC" ) {
       csize = rp_cellsize
       band = eband
    } else if ( mission == "EINSTEIN" && instrum == "IPC" ) {
       csize = ei_cellsize
       band = eband
    } else if ( mission == "EINSTEIN" && instrum == "HRI" ) {
       csize = eh_cellsize
       band = "broad"
    } else {
       print ("Unknown Mission/Instrument")
    }

   print " "
   print "... Running Cellmap ..."
   _rtname (qpname, tabname, ".imh")
   imname = s1
   cellmap (qpname, imname, 0, 0, 0, 0, csize, band, query=no, clobber=clob)

   print " "
   print "... Running Snrmap ..."
   _rtname (imname, tabname, "_snr.imh")
   snrimh = s1
   snrmap (imname, snrimh, clobber=clob)

   print " "
   print "... Running Lpeaks ..."
   _rtname (imname, tabname, "_ruf.tab")
   ruftab = s1
   lpeaks (snrimh, ruftab, thresh=minsnr, display=disp, clobber=clob)

   print " "
   print "... Running Bkden ..."
   bkden (imname, region, fluctuation=fluctuation, max_iter=max_bkiter, 
          display=disp, radius=radius, value=value)

   print " "
   print "... Running Bepos ..."
   _rtname (imname, tabname, "_pos.tab")
   postab = s1
   bname = s2
   bepos (bname, ruftab, postab, bkden.value, 
	  prf_table=prf_table, prf_sigma=prf_sigma, energy=energy, 
          snr_thresh=mlminsnr, display=disp, clobber=clob, 
	  max_iter=max_iter, max_conf_iter=max_conf_iter, 
          num_conf_levels=num_conf_levels, conf_68=conf_68, conf_90=conf_90, 
          refine_limit=refine_limit, optimum_radius=optimum_radius, 
          c_conv_epsilon=c_conv_epsilon, s_conv_epsilon=s_conv_epsilon, 
          cenx_keywd=cenx_keywd, ceny_keywd=ceny_keywd)
end
