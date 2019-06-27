# -----------------------------------------------------------------------
# Module:       upephrdf.cl
# Description:  Convert Rev0 FITS ephemeris files in MPE or US data formats
#               to RDF format for calc_bary code.  Only columns effecting
#               calc_bary are updated. 
#               MJDINT & MJDFRAC are added to the table, and the Satellite
#               vector column names are changed to new RDF names
# Initial version:  jd - 8/93 
# -----------------------------------------------------------------------
procedure _upephrdf (table)
  string  table   {prompt="Input Table File",mode="a"}
  string  otable  {prompt="Output Table File",mode="a"}
  bool    value   {"no",prompt="Indicates whether a file was converted",mode="h"}
  bool    clobber {no,prompt="OK to overwrite exisiting output file?", mode="h"}
  int     display {0,prompt="Display Level", mode="h"}

begin

   string tbl        # input table filename
   string otbl       # output table filename

   file   tablist    # table list for tmerge
   file   tempfile   # temporary output table file

   bool   clob       # ok to cloober exisiting file

   int    disp       # display level

   string day	     # day column name
   string sec	     # sec column name
   string xsat	     # xsat column name
   string ysat	     # ysat column name
   string zsat	     # zsat column name
   
   tbl  = table
   otbl = otable
   clob = clobber
   disp = display

   #   Check if we can overwrite file if it exists
    _rtname (tbl, otbl, ".tab")
    otbl= s1
    if (access(otbl)) {
       if ( clob ) {
          del (otbl)
       } else {
          error (1, "Clobber = NO & Output TABLE exists !")
       }
    }

   #  ---------------------------------------------------------------------
   #  if RDF_VERS is NOT in the header, then we recognise this file as REV0
   #  ---------------------------------------------------------------------
   _keychk (tbl, "RDF_VERS")
   if( _keychk.value == "" ) {

       #  ------------------------------------
       #  Is the Rev0 file MPE or US format? 
       #  ------------------------------------
       _keychk (tbl, "ORIGIN")
       if( _keychk.value == "ESO-MIDAS" ) {

          # ---------------------------------------------------------
          # Origin is ESO-MIDAS so it is MPE; column names are DATE,
          #        DAYSEC, XSATELLITE, YSATELLITE, ZSATELLITE ...
          #        data format is the same as US. 
          # ---------------------------------------------------------

          if ( disp > 0 ) {
             print ("\nConverting Rev0 MPE format EPH file to RDF format ...")
          }

          day="DATE"
          sec="DAYSEC"
          xsat="XSATELLITE"
          ysat="YSATELLITE"
          zsat="ZSATELLITE"

       } else {

          # ------------------------------------------------
          # Origin is US; column names are IUT1_SO, IUT2_SO, 
          #        ISAT_SOX, ISAT_SOY, ISAT_SOZ ...
          #        data format is the same as MPE. 
          # ------------------------------------------------

          if ( disp > 0 ) {
             print ("\nConverting Rev0 US format EPH file to RDF format ...")
          }
          day="IUT1_SO"
          sec="IUT2_SO"
          xsat="ISAT_SOX"
          ysat="ISAT_SOY"
          zsat="ISAT_SOZ"
      }
      # --------------------------------------------------------
      # Read DAY and DATE; compute MJDINT & MJDFRAC, & write to
      # MJD temporary table
      # --------------------------------------------------------
      tempfile = "mjd.tab"
      _utmjd (tbl, tempfile, day_col=day, sec_col=sec, 
              clobber=yes, display=disp )

      # ------------------------------------------
      # Merge MJD temp table with Ephemeris table 
      # ------------------------------------------
      tablist = tbl //","// tempfile
      tmerge (tablist, otbl, "merge")

      # ------------------------------------
      # update column headings to RDF names
      # ------------------------------------
      tchcol (otbl, xsat, "SAT_X", "", "", verbose=no)
      tchcol (otbl, ysat, "SAT_Y", "", "", verbose=no)
      tchcol (otbl, zsat, "SAT_Z", "", "", verbose=no)

      tdelete (tempfile)
      _upephrdf.value=yes

      if ( disp > 0 ) {
         print ("Output file: " // otbl )
      }

   } else { 
     if ( disp > 0 ) {
        print ("\nRDF input ... No conversion!!")
     }
     _upephrdf.value=no
   }

end
