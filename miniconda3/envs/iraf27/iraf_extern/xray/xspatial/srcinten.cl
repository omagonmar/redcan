# $Header: /home/pros/xray/xspatial/RCS/srcinten.cl,v 11.0 1997/11/06 16:33:35 prosb Exp $
# $Log: srcinten.cl,v $
# Revision 11.0  1997/11/06 16:33:35  prosb
# General Release 2.5
#
# Revision 9.1  1997/02/28 20:52:22  prosb
# JCC(2/28/97) - add the package name to imcalc.
#
#Revision 9.0  1995/11/16  18:37:05  prosb
#General Release 2.4
#
#Revision 1.11  1995/07/11  19:22:16  prosb
#JCC - Update the display messages for higher display level.
#
#Revision 1.5  1994/09/19  16:06:46  jcc 
#JCC - add the algorithm to compute UPPER LIMIT.
#
#Revision 1.4  94/09/15  10:42:47  jcc 
#JCC - remove imcnts and get the total count from obs table instead;
#      get ra,dec,x,y,radius from obs header; set display to zero when
#      running qp tasks; add a screen display for each step processing.
#
#Revision 1.3  94/09/14  14:18:25  jcc 
#JCC - remove imcopy
#
#Revision 1.2  94/09/14  13:20:45  janet
#jd - made a few updates with jcc.
#
#Revision 1.1  94/09/14  12:37:57  jcc 
#JCC - Initial revision
#
#
# Module:       srcinten.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JCC -- initial version -- Aug 94
#               {n} <who> -- <does what> -- <when>
# ----------------------------------------------------------------------------
procedure srcinten(source,region,bkgd,bkgdregion)

# qpspec auto params
file   source   {"",prompt="source qpoe file",mode="a"}
string region   {"",prompt="source region descriptor",mode="a"}
string bkgd     {"",prompt="background qpoe file",mode="a"}
string bkgdregion   {"",prompt="bkgd region descriptor",mode="a"}
file   otb_root {"",prompt="output root name (_ccr.tab)", mode="a"}

# qpspec hidden params
int  display   {1,prompt="display level",mode="h"}
bool clobber   {no,prompt="delete old copies of table files?",mode="h"}
bool deltmpfil {yes,prompt="delete temp files?",mode="h"}
bool vign_correct {no,prompt="perform vignetting correction on background?",mode="h"}
file qefile    {"xspatialdata$hri_qegeom.imh",prompt="qegeometry file",mode="h"}
real nsigma     {3.0,prompt="signal to noise ratio",mode="h"}

begin

file    src
file    eqs2sq 
file    otb_name
file    qe_geom

string  bk
string  breg
string  reg
string  vign_expr	# equation to calculate vign
string  qe_expr		# equation to calculate qe
string  prf_enexpr, prf_edexpr, prf_expr 
string  src_img

int    disp		# display level
int    num_row, irow
int    xpix,ypix

real   local_vign	
real   vign_corr	# vignetting correction factor
real   exptime		# exposure time
real   totcnt		# total count
real   bkgcnt		# background count
real   netcnt           # net count
real   neterr		# net count error
real   qe_corr
real   prf_corr, local_prf	#prf variables
real   a10,a20,a30		#prf variables
real   s10,s30,s21,s22,s23,s24	#prf variables
real   s1sq,s2sq,s3sq		#prf variables
real   rr, rsq   		#rr: radius of source region in arcsec
real   en10,en30,ed10,ed30,en1030,ed1030      	#prf variables
real   all_corr, corr_netcnt, corr_neterr
real   cntrate, cntraterr	#corrected count rate and error
real   pi,ra_nom,dec_nom,sarea,degpix,sx,sy,degsec
real   snratio, nthresh, uplimit, uplimrate

real test_s2sq, test_enum, test_eden, test_enp
string test_enexpr

bool   clob
bool   deltmp		# delete temp file? y/n

# make sure xspectral is already defined, packages can't be loaded in scripts!
   if( !deftask("xspectral") )
      error(1, "Requires xspectral to be loaded!")

   src = source
   reg = region

   bk = bkgd
   if ( bk == "" || bk == "none" || bk == "NONE" ) {
      breg = ""
   } else {
      breg = bkgdregion
   }

   nthresh = nsigma
   disp = display
   clob  = clobber
   deltmp = deltmpfil
   qe_geom = qefile

# Add the extension to the output table
    _rtname (otb_root, otb_name, "_ccr.tab")
    otb_name = s1

    if ( access(otb_name) && !clob )
       error (1,"Output file already exists!!")
    else if (access(otb_name) && clob )
       delete (otb_name)

# ----------------------------------------------
# clean old temp files if they are still around
# ----------------------------------------------
   if (access("ah_boh.tab")) {
      delete ("ah_boh.tab",ver-, >& "dev$null")
   }
   if (access("ah_soh.tab")) {
      delete ("ah_soh.tab",ver-, >& "dev$null")
   }
   if (access("ah_obs.tab")) {
      delete ("ah_obs.tab",ver-, >& "dev$null")
   }
   if (access("src_tmp.qp")) {
      delete ("src_tmp.qp",ver-, >& "dev$null")
   }
   if (access("qecorr_tmp.imh")) {
      imdelete ("qecorr_tmp.imh",ver-, >& "dev$null")
   }
   if (access("qecorr_cnt.tab")) {
      delete ("qecorr_cnt.tab",ver-, >& "dev$null")
   }
   if (access("ccr.dat")) {
      delete ("ccr.dat",ver-, >& "dev$null")
   }
   if (access("ccr.hd")) {
      delete ("ccr.hd",ver-, >& "dev$null")
   }

# -----------------------------------------------------------
# create the aspect histogram tables: (ah_soh.tab,ah_obs.tab) 
# -----------------------------------------------------------
#
   print ("\n --- Running SRCINTEN task ---")
   print ("\n --- Creating aspect histogram table from qpoe ---")

   qpspec (src, reg, bk, breg, table="ah", exposure="NONE", expthresh=0.,
        bkgdexposure="NONE", bkgdthresh=0., pkgpars="", clobber=clob, 
        display=0, full=no, timenorm=yes, normfactor=1., 
        syserr="", detx="detx", dety="dety", ein_ipc_binn="pha", 
        bal_histo="", ein_hri_binn="pha", ros_pspc_bin="pi", 
        vign_correct=vign_correct, 
        ros_pi_offar="xspectraldata$ros_pi_offar.ieee",
        avg_mvr=0., particle_dat="", 
        particle_tab="xspectraldata$particle_bkgd.tab", ros_hri_binn="pha",
        srg_lepc1_bi="pi", srg_hepc1_bi="pi", channels=16, binning="pha",
        inst_syserr="0.0", radius=3., noah=0, oahelements=1, oah1="0", 
        xdopti=0., ydopti=0.)

# ----------------------------------------------
# Read parameters from ah_obs.tab and its header 
# ----------------------------------------------
   keypar ("ah_obs.tab", "livetime", value="")
   exptime = real(keypar.value)

   keypar ("ah_obs.tab", "ra_nom", value="")
   ra_nom = real(keypar.value)

   keypar ("ah_obs.tab", "dec_nom", value="")
   dec_nom = real(keypar.value)

   keypar ("ah_obs.tab", "x", value="")
   sx = real(keypar.value)

   keypar ("ah_obs.tab", "y", value="")
   sy = real(keypar.value)

   keypar ("ah_obs.tab", "sarea", value="")
   sarea = real(keypar.value)

   keypar ("ah_obs.tab", "rcdlt2", value="")
   degpix = real(keypar.value)

   tabpar ("ah_obs.tab", "cts_tot", 1, value="", undef=no)
   totcnt = real(tabpar.value)
   if (disp >=2)  print("\n total count = ", totcnt)

   tabpar ("ah_obs.tab", "ccts_bkg", 1, value="", undef=no)
   bkgcnt = real(tabpar.value)
   if (disp >=2)  print(" background count = ", bkgcnt)

   tabpar ("ah_obs.tab", "net", 1, value="", undef=no)
   netcnt = real(tabpar.value)
   if (disp >=2)  print(" net count = ", netcnt)

   tabpar ("ah_obs.tab", "neterr", 1, value="", undef=no)
   neterr = real(tabpar.value)
   if (disp >=2)  print(" net count error = ", neterr)

   pi = 3.1415926535897932385
   degsec = 3600.0
   rr =(sqrt(sarea/pi)) * degpix * degsec

   snratio = netcnt/neterr
   if (disp >=2) print (" signal to noise ratio = ", snratio)

# -------------------------------------------------
# Calculate vign correction factor from ah_soh.tab.
# -------------------------------------------------
#
   print ("\n --- Computing vignetting correction factor ---")

# put a new column "local_vign" in ah_soh.tab
   vign_expr="(1.0-0.00149*off_ax_rad-0.000307*(off_ax_rad**2))*frac_time"
   tcalc (table="ah_soh.tab", outcol="local_vign", equals=vign_expr,
        datatype="real", colunits="", colfmt="")

# get the number of row from ah_soh.tab
   tinfo ("ah_soh.tab", ttout=no, nrows=0, ncols=0, npar=0,
        rowlen=0, rowused=0, allrows=0, maxpar=0, maxcols=0,
        tbltype="", tblversion=0)
   num_row = tinfo.nrows
#  if (disp >=2) {
#     print ("\n", num_row, "rows in ah_soh.tab")
#  }

# Read the value of "local_vign" from ah_soh.tab and add it up.
   irow = 1
   vign_corr = 0.0

   while (irow <= num_row) {
      tabpar ("ah_soh.tab", "local_vign", irow, value="", undef=no)
      local_vign = real(tabpar.value)
      vign_corr = vign_corr + local_vign
      irow += 1
   }
   if (disp >=2)  print("\n vign_corr =", vign_corr)

# -----------------------------------------------
# Calculate prf correction factor.
# prf_enum=a10*s1sq*(1-exp(-0.5*rsq/s1s1)) +
#          a20*s2sq*(1-exp(-0.5*rsq/s2sq)) +
#          a30*s3s1*(1-(1+rr/s30)*exp(-rr/s30))
# prf_eden=a10*s1sq + a20*s2sq * a30*s3sq
# prf_corr=prf_corr+(prf_enum/prf_eden)*frac_time
# ------------------------------------------------
#
   print ("\n --- Computing prf correction factor ---")

# set prf constants 
   a10 = 0.9638
   a20 = 0.1798
   a30 = 0.0009
   s10 = 2.1858
   s21 = 3.3
   s22 = 0.019
   s23 = -0.016
   s24 = 0.0044
   s30 = 31.69

   rsq = rr * rr

   s1sq = s10 * s10
   s3sq = s30 * s30

   en10 = a10 * s1sq * (1 - exp(-0.5*rsq/s1sq))
   en30 = a30 * s3sq * (1-(1+rr/s30)*exp(-rr/s30)) 
   en1030 = en10 + en30

   ed10 = a10 * s1sq
   ed30 = a30 * s3sq
   ed1030 = ed10 + ed30

   if (display >= 5) {
      print ("\n", " rr, rsq, s1sq = ", rr, rsq, s1sq )
      print (" rsq/s1sq, exp()= ", rsq/s1sq, exp(-0.5*rsq/s1sq))
      print (" en10, en30 =", en10, en30 )
      print (" ed10, ed30 =", ed10, ed30 )
   }

# add two new column "prf_enum" & "prf_eden" to ah_soh.tab
   eqs2sq = "@xspatialdata$prfeq.lis"
   tcalc(table="ah_soh.tab",outcol="s2sq",equals=eqs2sq,
         datatype="real",colunits="",colfmt="")

   prf_enexpr=en1030//"+"//a20//"*s2sq*(1-exp(-0.5*"//rsq//"/s2sq))"
   prf_edexpr=ed1030//"+"//a20//"*s2sq"

   if (display >= 5) {
      test_enexpr=a20//"*s2sq*(1-exp(-0.5*"//rsq//"/s2sq))"
      tcalc(table="ah_soh.tab", outcol="test_en", equals=test_enexpr,
            datatype="real", colunits="", colfmt="")
   }

   tcalc(table="ah_soh.tab", outcol="prf_enum", equals=prf_enexpr,
         datatype="real", colunits="", colfmt="")

   tcalc(table="ah_soh.tab", outcol="prf_eden", equals=prf_edexpr,
         datatype="real", colunits="", colfmt="")

   prf_expr = "frac_time*(prf_enum/prf_eden)"
   tcalc(table="ah_soh.tab", outcol="local_prf", equals=prf_expr,
         datatype="real", colunits="", colfmt="")

#   if (display >= 5) {
#      test_s2sq=39.5641
#      test_enum=a10*s1sq*(1-exp(-0.5*rsq/s1sq))+a20*test_s2sq*(1-exp(-0.5*
#                rsq/test_s2sq)) + a30*s3sq*(1-(1+rr/s30)*exp(-rr/s30))
#      test_eden=a10*s1sq + a20*test_s2sq + a30*s3sq
#      test_enp = a20*test_s2sq*(1-exp(-0.5*rsq/test_s2sq))
#      print ("\n test_s2sq,  test_enp,  test_enum,  test_eden = ")
#      print (" ", test_s2sq, test_enp, test_enum,test_eden)

#      test_s2sq=220.0772
#      test_enum=a10*s1sq*(1-exp(-0.5*rsq/s1sq))+a20*test_s2sq*(1-exp(-0.5*
#               rsq/test_s2sq)) + a30*s3sq*(1-(1+rr/s30)*exp(-rr/s30))
#      test_eden=a10*s1sq + a20*test_s2sq + a30*s3sq
#      test_enp = a20*test_s2sq*(1-exp(-0.5*rsq/test_s2sq))
#      print (" ", test_s2sq, test_enp, test_enum,test_eden)
#   }

   irow = 1
   prf_corr = 0.0

   while (irow <= num_row) {
      tabpar ("ah_soh.tab", "local_prf", irow, value="", undef=no)
      local_prf = real(tabpar.value)
      prf_corr = prf_corr + local_prf
      irow += 1
   }
   if (disp >=2)  print("\n prf_corr =",prf_corr)

# -------------------------------------------------------------
# Make an image file from the source qpoe file in the specified
# region using the detector coordinates.
# -------------------------------------------------------------
#
   print ("\n --- Computing qe correction factor ---")
#
   qpcopy (src, reg, qpoe="src_tmp.qp", eventdef="", exposure="NONE", 
       expthresh=0., clobber=clob, display=0, qp_internals=yes,
       qp_pagesize=2048, qp_bucketlen=4096, qp_blockfact=1, 
       qp_mkindex=yes, qp_key="", qp_debug=0)

# ------------------------------------------------------
# Create a qe geometry map and qe correction image, then
# calculate qe correction factor.
# ------------------------------------------------------
   src_img="src_tmp.qp[key=(detx,dety),bl=128]"
   qe_expr="qecorr_tmp=("//src_img//"*"//qe_geom//")/"//totcnt
   ximages.imcalc (input=qe_expr, clobber=clob, zero=0., debug=0)

   imcnts ( "qecorr_tmp.imh", "NONE", "NONE", "NONE", "qecorr",
        exposure="NONE", expthresh=0., err="NONE", matchbkgd=no,
        bkgdexposure="NONE", bkgdthresh=0., addbkgderr=yes, bkgderr="NONE",
        timenorm=no, normfactor=1., clobber=clob, display=0, >& "dev$null")

   tabpar ("qecorr_cnt.tab", "net", 1, value="", undef=no)
   qe_corr = real(tabpar.value)
   if (disp >=2)  print("\n qe_corr = ", qe_corr)

# ------------------------------------------------------------
# Check the threshold and compute corrected net count rate, 
# corrected net count rate error, or corrected upper limit
# ------------------------------------------------------------ 
   all_corr = 1.0 / ( prf_corr * vign_corr * qe_corr )
   if (snratio >= nthresh) {
       corr_netcnt = all_corr * netcnt
       corr_neterr = all_corr * neterr
       cntrate = (corr_netcnt * 1000.0) / exptime
       cntraterr = (corr_neterr * 1000.0) / exptime
       uplimit = 0.0
       uplimrate = 0.0
       if (disp >= 2) {
	  print("\n signal to noise ratio is above the threshold")
	  print(" corrected count rate = ", cntrate)
       }
   }
   else  {
       cntrate = 0.0
       cntraterr = 0.0
       uplimit = (nthresh**2/2.0)*(1.0+sqrt(1.0+4.0*bkgcnt/(nthresh**2)))  
       uplimrate = uplimit*all_corr*1000.0/exptime 
       if (disp >= 2) {
          print("\n signal to noise ratio is below the threshold")
          print (" corrected upper limit rate= ", uplimrate)
       }
   }

#   print ("\n all_corr = ", all_corr)
#   print ("\n corr_netcnt = ", corr_netcnt)
#   print ("\n corr_neterr = ", corr_neterr)
#   print ("\n cntrate(c/sec) = ", cntrate)

# -------------------------------------------
# Write output data to a data file "srcoldat"
# -------------------------------------------
   print (ra_nom,dec_nom,sx,sy,rr,cntrate,cntraterr,uplimrate,
          totcnt,bkgcnt, exptime,prf_corr, qe_corr,vign_corr, 
          > "ccr.dat")

#   print (r1,r2,r3,r4,r5,r6,r7,r8,r9,r10, > "ccr.dat")

# ---------------------------------------
# Create the ascii header file for output 
# ---------------------------------------
   tprint ("ah_soh.tab", prparam=yes, prdata=no, pwidth=80, 
        plength=0, showrow=yes, showhdr=yes, showunits=yes, 
        columns="", rows="-", option="plain", align=yes, sp_col="",
        lgroup=0, > "ccr.hd" )

# ---------------------
# Create a table output
# ---------------------
   tcreate (otb_name, "xspatialdata$ccr.cd", "ccr.dat", uparfile="ccr.hd",
        nskip=0, nlines=0, nrows=0, hist=no, extrapar=5, 
        tbltype="default", extracol=0)

# --------------------
# Clean up temp qpoes.
# --------------------
   if (deltmp) {
      delete ("ah_boh.tab",ver-, >& "dev$null")
      delete ("ah_soh.tab",ver-, >& "dev$null")
      delete ("ah_obs.tab",ver-, >& "dev$null")
      delete ("src_tmp.qp",ver-, >& "dev$null")
      imdelete ("qecorr_tmp.imh",ver-, >& "dev$null")
      delete ("qecorr_cnt.tab",ver-, >& "dev$null")
      delete ("ccr.dat",ver-, >& "dev$null")
      delete ("ccr.hd",ver-, >& "dev$null")
   }

   print ("\n --- SRCINTEN created Output table: ", otb_name," ---\n")

end
