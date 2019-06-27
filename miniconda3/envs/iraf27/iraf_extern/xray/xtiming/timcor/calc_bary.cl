# -----------------------------------------------------------------------
# Module:       calc_bary.cl
# Description:  Convert Rev0 FITS ephemeris files in MPE or US data formats
#               to RDF format using upephrdf, then call calc_bary.
#               Have to have write access in working dir ... temp file 
#               created
# Initial version:  jd - 8/93
# -----------------------------------------------------------------------

procedure calc_bary(split_orb,orb_corr,st_alp,st_dec)

file split_orb {"",prompt="input ephemeris table",mode="a"}
file orb_corr  {prompt="root name for output file(s) [root_cor(ephem).tab]", mode="a"}
real   st_alp {prompt="input RA (hh:mm:ss.s)", mode="a"}
real   st_dec {prompt="input DEC (dd:mm:ss.s)", mode="a"}
file ephem_fname {"xtimingdata$de200.tab",prompt="ephemeris barycenter corr table",mode="h"}
string day_col  {"MJD_INT",prompt="Input table col name of date",mode="h"}
string sec_col  {"MJD_FRAC",prompt="Input table col name of seconds",mode="h"}
string xsat_col {"SAT_X",prompt="Input table col name of x-satellite",mode="h"}
string ysat_col {"SAT_Y",prompt="Input table col name of y-satellite",mode="h"}
string zsat_col {"SAT_Z",prompt="Input table col name of z-satellite",mode="h"}
file  tbl_fname {"xtimingdata$jdleap.tab",prompt="jdleap calibration table name",mode="h"}
bool   clobber {no,prompt="delete old copy of output file",mode="h"}
int    display {1,prompt="0=no disp, 1=header", mode="h"}

begin

   file   ephfile
   file   rdffile
   file   orbfile
   file   rname
   int    disp
   bool   clob
   real   ra
   real   dec

   ephfile = split_orb
   orbfile = orb_corr

   ra = st_alp
   dec = st_dec
   clob = clobber
   disp = display

   _rtname (ephfile, orbfile, "_ephem.tab")
   rdffile= s1

   # ------------------------------------------------------------
   # Update the Ephemeris file to RDF format if the input is Rev0
   # ------------------------------------------------------------
   _upephrdf (ephfile, rdffile, clobber=clob, display=disp)

   # ------------------------------------------------------------
   # Set the input file name for calc_bary; it's dependent on 
   # whether there was a file converion in upephrdf
   # ------------------------------------------------------------
   if ( _upephrdf.value == no ) {
        copy (ephfile, rdffile, verbose=no)
   }

   if ( disp > 0 ) {
      print ("Output ephemeris table: " // rdffile) 
      print ("\nComputing Correction table ...")
   }

   # --------------------------------------------------------------
   # ... and finally run calc_bary, input file is always RDF format
   # --------------------------------------------------------------
   _clc_bary (rdffile, orbfile, ra, dec, 
          ephem_fname=ephem_fname, day_col=day_col, sec_col=sec_col, 
          xsat_col=xsat_col, ysat_col=ysat_col, zsat_col=zsat_col, 
          tbl_fname=tbl_fname, clobber=clob, display=disp)

end
