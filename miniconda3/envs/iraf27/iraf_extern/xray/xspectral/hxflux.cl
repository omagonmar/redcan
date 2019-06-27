# $Header: /home/pros/xray/xspectral/RCS/hxflux.cl,v 11.0 1997/11/06 16:43:46 prosb Exp $
# $Log: hxflux.cl,v $
# Revision 11.0  1997/11/06 16:43:46  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:27:45  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:28:04  prosb
#General Release 2.3.1
#
#Revision 1.2  94/06/15  15:34:58  janet
#jd - task to run qpspec,fit,xflux for ROSAT HRI data.
#
#
# Module:       hxflux.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      'canned' ROSAT HRI flux determination
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version -- Apr 94
#               {n} <who> -- <does what> -- <when>
# ----------------------------------------------------------------------------
procedure hxflux (source, region, bkgd, bkgdregion, table, observed, model, energy, distance)

# qpspec, fit, xflux auto params
file 	source   {"",prompt="source qpoe file",mode="a"}
string 	region   {"",prompt="source region descriptor",mode="a"}
string	bkgd     {"",prompt="background qpoe file",mode="a"}
string 	bkgdregion   {"",prompt="bkgd region descriptor",mode="a"}
file	table    {"",prompt="root name for output files [root_obs.tab, etc.]",mode="a"}
string  observed {"",prompt="observed spectrum [root_obs.tab]",mode="a"}
string  model    {"",prompt="spectral model, e.g. abs(logNH)*pow(alpha)",mode="a"}
string	energy   {"",prompt="energy or range of energies in keV",mode="a"}
string	distance {"",prompt="distance or redshift e.g. 5kpc or 1.0z",mode="a"}

# hidden qpspec params:
string	exposure {"NONE",prompt="source exposure mask or NONE",mode="h"}
real expthresh   {0.0,prompt="min. percent of exp. time for inclusion in source",mode="h", min=0.0,max=100.0}
string	bkgdexposure {"NONE",prompt="bkgd exposure mask or NONE",mode="h"}
real	bkgdthresh {0.0,prompt="min. percent of exp. time for inclusion in bkgd",mode="h", min=0.0,max=100.0}
pset	pkgpars  {"",prompt="Spectral package parameters",mode="h"}
bool	full     {no,prompt="produce full channel spectrum?",mode="h"}
bool	timenorm {yes,prompt="normalize by time?",mode="h"}
real	normfactor {1.0,prompt="user-specified normalization factor",mode="h"}
string	syserr   {"",prompt="systematic error",mode="h"}
string	detx     {"detx",prompt="type of binning",mode="h"}
string	dety     {"dety",prompt="type of binning",mode="h"}
string	ros_hri_binning {"pha",prompt="type of binning for ROSAT HRI",mode="h"}

# hidden fit params
int	max_iterations {400,prompt="Maximum number of iterations",mode="h"}
bool	verbose   {no,prompt="Print parameter values during search.",mode="h"}
real	tolerance {1.e-3,prompt="Convergence tolerance",mode="h"}
bool	rebin     {no,prompt="rebin to one channel",mode="h"}

# hidden xflux parameters
string	defaultunits {"kpc",prompt="default units of distance for luminance computation",mode="h"}
real	Hubble_constant {50.0,prompt="Hubble constant (km/s/Mpc)",mode="h"}
real	deceleration_constant {0.0,prompt="deceleration constant",mode="h"}

bool	save_files {no,prompt="save intermediate table files?",mode="h"}
bool	clobber {no,prompt="delete old copies of table files?",mode="h"}
int	display {1,prompt="0=no disp, 1=spectral info, 2=QPOE info",mode="h"}

begin

file   src
file   tab
file   tabroot
string bk
string breg
string dist
string mod
string nrg
string reg

string key
string instr
string tel
string buf

# ----------------------------
#  make auto param assignments
# ----------------------------
   src = source

#  error checking to verify that input is ROSAT HRI only
   keypar (src,"TELESCOPE")
   tel = keypar.value
   keypar (src,"INSTRUMENT")
   instr = keypar.value
   if ( tel == "ROSAT" && instr == "HRI" ) {
   } else {
      buf = "QPOE events are " // (tel) // " " // (instr)
      print ("") 
      print (buf)
      error (1, "Only ROSAT HRI data accepted as input!")
   }

   reg = region
   bk = bkgd
   if ( bk == "" || bk == "none" || bk == "NONE" ) {
      breg = ""
   } else {
      breg = bkgdregion
   }
   tab = table
   mod = model
   nrg = energy
   dist = distance

   _rtname (src, tab, "")
   tabroot = s1
#  print (s1)

# -------------------------
# first run qpspec
# -------------------------
  qpspec (src, reg, bk, breg, tabroot,
        exposure=exposure, expthresh=expthresh, bkgdexposure=bkgdexposure, 
        bkgdthresh=bkgdthresh, pkgpars="", clobber=clobber, display=display, 
        full=full, timenorm=timenorm, normfactor=normfactor, 
        syserr=syserr, detx=detx, dety=dety, 
          ein_ipc_binn="pha", bal_histo="0", ein_hri_binn="pha", 
          ros_pspc_bin="pi", vign_correct=no, 
          ros_pi_offar="xspectraldata$ros_pi_offar.ieee", avg_mvr=0.0, 
          particle_dat="0", particle_tab="xspectraldata$particle_bkgd.tab", 
        ros_hri_binning=ros_hri_binning, 
          srg_lepc1_bi="pi", srg_hepc1_bi="pi", channels=16, binning="pha", 
          inst_syserr="0.0", radius=3., noah=0, oahelements=1, oah1="0", 
          xdopti=0.0, ydopti=0.0)

# -------------------------
# then fit
# -------------------------
  # pkgpars.intermediate = tabroot
  # pkgpars.chisquare = tabroot
  # pkgpars.prd_dir = "dummy.tab"

  fit (pkgpars.observed=tabroot, pkgpars.model=mod, 
       pkgpars.intermediate=tabroot, pkgpars.chisquare=tabroot,
       pkgpars.prd_dir="dummy.tab",
       max_iterations=max_iterations, verbose=verbose, tolerance=tolerance, 
       rebin=rebin)

# -------------------------
# then xflux
# -------------------------
  xflux (nrg, dist, tabroot, pkgpars="", defaultunits=defaultunits, 
         Hubble_constant=Hubble_constant, 
         deceleration_constant=deceleration_constant, clobber=clobber)

# -------------------------
# delete intermediate files
# -------------------------
  if ( !save_files ) {

# -- qpspec files --
    s2 = tabroot // "_boh.tab"
    delete (s2, ver-, >& "dev$null")

    s2 = tabroot // "_obs.tab"
    delete (s2, ver-, >& "dev$null")

    s2 = tabroot // "_soh.tab"
    delete (s2, ver-, >& "dev$null")

# -- fit files --
    s2 = tabroot // "_csq.tab"
    delete (s2, ver-, >& "dev$null")
    
    s2 = tabroot // "_int.tab"
    delete (s2, ver-, >& "dev$null")

    s2 = "dummy_prd.tab"
    delete (s2, ver-, >& "dev$null")
  }
  # pkgpars.intermediate = "."
  # pkgpars.prd_dir = ""
  # pkgpars.chisquare = "."

end
