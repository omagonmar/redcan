# $Header: /home/pros/xray/xdataio/RCS/_rdfrall.cl,v 11.0 1997/11/06 16:35:58 prosb Exp $
# $Log: _rdfrall.cl,v $
# Revision 11.0  1997/11/06 16:35:58  prosb
# General Release 2.5
#
# Revision 9.1  1997/10/03 21:45:36  prosb
# JCC(10/97) - Add force to strfits.
#
# Revision 9.0  1995/11/16 18:56:43  prosb
# General Release 2.4
#
#Revision 8.2  1995/05/04  16:37:03  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.1  1994/10/05  13:51:35  dvs
#Added new fits2qp params.
#
#Revision 8.0  94/06/27  15:17:01  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/26  19:06:42  janet
#jd - replaced printf with print statement.
#
#Revision 7.0  93/12/27  18:43:00  prosb
#General Release 2.3
#
#Revision 1.1  93/12/22  13:51:40  janet
#Initial revision
#
#
# ------------------------------------------------------------------------
# rdfrall.cl -  Merges and filters the BAS fits file to make a QPOE deffilt
#                  with GTIs that reflect the ALL or STD data. 
#   
#    1) Converts an RDF basic FITS file to STD events & REJ events files
#    2) Set number of TSIs to 0 in REJ file
#    3) Append the STD & REJ events to make an ALL Events Qpoe
#    4) Build a Time Filter for the ALL qpoe by applying the TSI limits
#       as a housekeeping screen, creates a time filter.
#    5) Copy the ALL events Qpoe through the TSI time filter
#
#    - there is a provision (using hidden params) for creating the std 
#      qpoe by filtering the ALL events for debugging.  This only works 
#      for the HRI.
#
#    - a calib table that matches tsi and qlm names for each instrument
#      one expects to run this on is pointed to by param hkscr.  If some-
#      one want to run on an instrument not defined, it must be added to 
#      the table.
# 
# ------------------------------------------------------------------------
 
procedure rdfrall (basfits, qpoe, instr)

string basfits {prompt="Input FITS File",mode="a"}
string qpoe    {prompt="Output Qpoe File name",mode="a"}
string instr   {prompt="Instrument (hri|pspc)",mode="a"}
bool   status  {no, prompt="Screen on Status in Event rec?",mode="h"}
string hkscr   {"xdataiodata$tsiqlm.tab",prompt="tsi/qlm mtch table",mode="h"}
int    qp_psize {2048,prompt="system page size",mode="h"}
int    qp_blen  {4096,prompt="system bucket len",mode="h"}
bool   clobber  {no, prompt="OK to overwrite exisiting output file?", mode="h"}
bool   debug    {no,prompt="retain temp files?",mode="h"}
string which_qlm {"all",prompt="which QLM extension? [all|standard]",mode="h"}
int    all_ext   {6,prompt="Qpoe extension number for ALL events",mode="h"}
int    std_ext   {5,prompt="Qpoe extension number for STANDARD events",mode="h"}

begin

  bool   clob		# clobber file if it exists? y/n
  bool   stt		# screen status attribute - hotspots & edges? y/n
  bool   deb            # delete temp file? y/n

  int    buflen		# buffer length
  int    qpbuck		# qpoe busket size
  int    qppage		# qpoe page size

  file   bfits		# basic fits file name
  file   scrhk		# tsi/qlm stationary name match table (calib file)
  file   qp		# output qpoe name

  string buf = ""	# temporary buffer
  string whqlm = ""	# ALL events or STANDARD events?
  string extn = ""	# extension number in fits file
  string ftype = ""	# file type; RDF or rev0
  string inst = ""      # instrument

  # ------------------
  # get i/o parameters
  # ------------------
  bfits = basfits
  qp = qpoe
  inst = instr

  scrhk = hkscr
  whqlm = which_qlm
  clob = clobber
  deb = debug
  stt = status
  qppage = qp_psize
  qpbuck = qp_blen

  # --------------------------------------------------------
  # check that input FITS file is RDF by looking at the name 
  # --------------------------------------------------------
#  buflen = strlen (bfits)
#  buf = substr (bfits, buflen-8, buflen)
#  if ( buf == "_bas.fits" ) {
#     ftype = "RDF"
#  }
#
#  if ( ftype != "RDF" ) {
#     print ("\n")
#     error (1, " !! Input FITS file MUST be RDF to retrieve ALL events !!\n")
#
#  } else {
#     # -----------------------------------------
#     # Error if output file exists and clob = NO
#     # -----------------------------------------
#     _rtname (qp, "", ".qp")
#     qp = s1
#     if (access(qp)) {
#        if (clob) {
#           delete (qp, ver-, >& "dev$null")
#        } else {
#           error (1, "Clobber = NO & Output Qpoe file exists !")
#        }
#     }
#     # -----------------------------------------
#     # build QLM extension name; ALL or STD
#     # -----------------------------------------
     if ( whqlm == "all" ) {
        extn = "["//all_ext//"]"
     } else if ( whqlm == "standard" ) {
        extn = "["//std_ext//"]"
     } else {
        error (1, "QLM are -> all <- or -> standard <-")
     }

     # ----------------------------------------------
     # clean old temp files if they are still around
     # ----------------------------------------------
     if (access("stdevt.qp")) {
        delete ("stdevt.qp",ver-, >& "dev$null")
     }
     if (access("rejevt.qp")) {
        delete ("rejevt.qp", ver-, >& "dev$null")
     }
     if (access("allevt.qp")) {
        delete ("allevt.qp", ver-, >& "dev$null")
     }
     if (access("hk.scr")) {
        delete ("hk.scr", ver-, >& "dev$null")
     }
     if (access("hk.flt")) {
        delete ("hk.flt", ver-, >& "dev$null")
     }
     if (access("fnames.tmp")) {
        delete ("fnames.tmp", ver-, >& "dev$null")
     }
     if (access("qlm.tab")) {
        delete ("qlm.tab", ver-, >& "dev$null")
     }
     if (access("qlm.hhh")) {
        delete ("qlm.hhh", ver-, >& "dev$null")
     }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1) Converts an RDF basic FITS file to STD events & REJ events files
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     print "--- Convert FITS to STD Events QPOE ---"
     if( inst == "hri" ){
     fits2qp (bfits, "stdevt.qp", 
       naxes=0, axlen1=0, axlen2=0, mpe_ascii_fi=no, clobber=clob,
       oldqpoename=no, display=0, fits_cards="xdataio$fits.cards",
       qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
       wcs_cards="xdataio$wcshri.cards", old_events="EVENTS", std_events="STDEVT",
       rej_events="REJEVT", which_events="standard", oldgti_name="GTI",
       allgti_name="ALLGTI", stdgti_name="STDGTI", which_gti="all",
       scale=yes, key_x="x", key_y="y",
       qp_internals=yes, qp_pagesize=qppage, qp_bucketlen=qpbuck, 
       qp_blockfact=1, qp_mkindex=no, qp_key="", qp_debug=0)

     print "--- Convert FITS to REJ Events QPOE ---"
     fits2qp (bfits, "rejevt.qp", 
       naxes=0, axlen1=0, axlen2=0, mpe_ascii_fi=no, clobber=clob,
       oldqpoename=no, display=0, fits_cards="xdataio$fits.cards",
       qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
       wcs_cards="xdataio$wcshri.cards", old_events="EVENTS", std_events="STDEVT",
       rej_events="REJEVT", which_events="rejected", oldgti_name="GTI",
       allgti_name="ALLGTI", stdgti_name="STDGTI", which_gti="all",
       scale=yes, key_x="x", key_y="y",
       qp_internals=yes, qp_pagesize=qppage, qp_bucketlen=qpbuck, 
       qp_blockfact=1, qp_mkindex=no, qp_key="", qp_debug=0)
    }

    else if( inst == "pspc"){
     fits2qp (bfits, "stdevt.qp", 
       naxes=0, axlen1=0, axlen2=0, mpe_ascii_fi=no, clobber=clob,
       oldqpoename=no, display=0, fits_cards="xdataio$fits.cards",
       qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
       wcs_cards="xdataio$wcspspc.cards", old_events="EVENTS", std_events="STDEVT",
       rej_events="REJEVT", which_events="standard", oldgti_name="GTI",
       allgti_name="ALLGTI", stdgti_name="STDGTI", which_gti="all",
       scale=yes, key_x="x", key_y="y",
       qp_internals=yes, qp_pagesize=qppage, qp_bucketlen=qpbuck, 
       qp_blockfact=1, qp_mkindex=no, qp_key="", qp_debug=0)

     print "--- Convert FITS to REJ Events QPOE ---"
     fits2qp (bfits, "rejevt.qp", 
       naxes=0, axlen1=0, axlen2=0, mpe_ascii_fi=no, clobber=clob,
       oldqpoename=no, display=0, fits_cards="xdataio$fits.cards",
       qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
       wcs_cards="xdataio$wcspspc.cards", old_events="EVENTS", std_events="STDEVT",
       rej_events="REJEVT", which_events="rejected", oldgti_name="GTI",
       allgti_name="ALLGTI", stdgti_name="STDGTI", which_gti="all",
       scale=yes, key_x="x", key_y="y",
       qp_internals=yes, qp_pagesize=qppage, qp_bucketlen=qpbuck, 
       qp_blockfact=1, qp_mkindex=no, qp_key="", qp_debug=0)
    }
    else
	error("Unsupported instrument")

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2) Extract the QLM extension, and convert it to a table 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     xrfits (bfits//extn, "qlm.tab", no, filelist="", long=no, short=yes, 
#        datatype="default", blank=0, offset=0, scale=yes)
     strfits (bfits//extn," ","qlm.tab", template="none", long_header=no, 
      short_header=yes, datatype="default", blank=0., 
      scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 3) Set TSIs to 0 so we only get one copy when we merge qpoes
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     qphedit ("rejevt.qp", "NTSI", "0", 
       add=no, delete=no, verify=no, show=yes, update=yes)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 4) Build the qpappend list of files to append
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      buf="stdevt.qp\nrejevt.qp"
#      buf="rejevt.qp\nstdevt.qp"
      print (buf, > "fnames.tmp")

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 5) Append the STD & REJ events to make an ALL Events Qpoe
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     print "--- Append STD & REJ Events to make ALL Events ---"
     qpappend ("@fnames.tmp", "", "allevt.qp", "", 
       exposure="NONE", expthresh=0., clobber=clob, display=0,
       sort=yes, sorttype="y x", qp_internals=yes,
       qp_pagesize=qppage, qp_bucketlen=qpbuck, qp_blockfact=1, qp_mkindex=yes,
       qp_key="", qp_debug=0)

     # ------------------------
     # clean up temp qpoes
     # ------------------------
     if (!deb) {
        delete ("stdevt.qp", ver-, >& "dev$null")
        delete ("rejevt.qp", ver-, >& "dev$null")
     }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 6) Build a Time Filter for the qpoe by applying the TSI limits
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# qlm.tab is output from xrfits above

     print "--- Build a time filter from HK screens ---"
     mkhkscr (inst, "qlm.tab", "hk.scr", hklookup=scrhk, clobber=yes, display=0)

     hkfilter ("allevt.qp[@hk.scr]", "hk.flt", 
       hkformat="XS-TSIREC", hkparam="TSI", display=0, clobber=yes)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 7) Copy the ALL Qpoe through the HK time filter
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     print "--- Copy the Qpoe thru the hk time filter : Final Qpoe created ---"
     if (stt) {
        buf = "allevt.qp[@hk.flt,status=0]"
     } else { 
        buf = "allevt.qp[@hk.flt]"
     }
     qpcopy (buf, "", qp, "", exposure="NONE", expthresh=0., clobber=clob, 
       display=0, qp_internals=yes, qp_pagesize=qppage, qp_bucketlen=qpbuck, 
       qp_blockfact=1, qp_mkindex=yes, qp_key="", qp_debug=0)

     buf = "Writing final Qpoe - " // qp
     print (buf)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 8) Clean directory of temp files
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if (!deb) {
        delete ("allevt.qp", ver-, >& "dev$null")

        delete ("hk.scr", ver-, >& "dev$null")
        delete ("hk.flt", ver-, >& "dev$null")
        delete ("fnames.tmp", ver-, >& "dev$null")
        delete ("qlm.tab", ver-, >& "dev$null")
        delete ("qlm.hhh", ver-, >& "dev$null")
     }
#  }

end
     