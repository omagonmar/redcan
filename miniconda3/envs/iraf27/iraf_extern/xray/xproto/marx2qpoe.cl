#$Header: /home/pros/xray/xproto/RCS/marx2qpoe.cl,v 1.3 1998/04/24 16:14:21 prosb Exp $
#$Log: marx2qpoe.cl,v $
#Revision 1.3  1998/04/24 16:14:21  prosb
#Patch Release 2.5.p1
#
#Revision 1.2  1998/02/06 22:41:03  prosb
#*** empty log message ***
#
#Revision 1.1  1998/01/27 17:14:18  prosb
#Initial revision
#
# JCC(1/98) - Convert MARX EVENT FITS into a QPOE file.
#
# ======================================================================
procedure marx2qpoe(inp_fits, out_qpoe, DetectorType, key_x, key_y)
# ======================================================================

  string  inp_fits    {prompt="input fits filename"}
  string  out_qpoe    {prompt="output qpoe filename"}
  int     DetectorType   {1,min=1,max=4,prompt="Detector Type: (1)ASC-I (2)ASC-S (3)HRC-I (4)HRC-S  "}
  string  key_x       {"chipx",prompt="index key for x coordinate"}
  string  key_y       {"chipy",prompt="index key for y coordinate"}

  int     axlen1      {1024,prompt="dimension of qpoe axis #1"}
  int     axlen2      {1024,prompt="dimension of qpoe axis #2"}
  int     display     {1,min=0,max=5,prompt="display level",mode="h"}
  bool    clobber     {no,prompt="Okay to delete existing qpoe file?",mode="h"}
  bool   DeleteInterm {yes,prompt="Okay to delete intermediate file?",mode="h"}

  string  fits_cards  {"xdataio$fits.cards",prompt="definitions for fits cards",mode="h"}
  string  qpoe_cards  {"xdataio$qpoexrcf.cards",prompt="definitions for qpoe cards",mode="h"}
  string  ext_cards   {"xdataio$ext.cards",prompt="definitions for ext cards",mode="h"}
  string  wcs_cards   {"xdataio$wcsmarx.cards",prompt="definitions for wcs cards",mode="h"}

  int    qp_pagesize  {16384,prompt="page size for qpoe file",mode="h"}
  int    qp_bucketlen {32767,prompt="bucket length for qpoe file",mode="h"}

  #int   qp_psize     {2048,prompt="system page size",mode="h"}
  #int   qp_blen      {4096,prompt="system bucket len",mode="h"}
  #int   qp_blfact    {1,prompt="qpoe blocking factor",mode="h"}
  #bool  qp_index     {yes,prompt="make position index?",mode="h"}
  #string qp_ky       {"y x",prompt="sort key(s) for index",mode="h"}
  #int   qp_deb       {0,prompt="qp debug print level",mode="h"}

  begin

  string infits, outqpoe,xxkey, yykey   #query parameters 
  int    dettype                        # query parameter
  int    axlen_x, axlen_y   #internal set unless coord. not in chip or tdet     
  string sorttypekey 

# make sure xdataion is loaded.
        if ( !deftask ("fits2qp") )
          error (1, "Requires xray/xdataio to be loaded!")

#---------------------
# Initialize variables
#---------------------

# Get query parameters
        infits = inp_fits
        outqpoe = out_qpoe
        dettype = DetectorType
        xxkey = key_x
        yykey = key_y

# set axlen_x & axlen_y according to DetectorType and (xxkey,yykey)
        axlen_x = 1024
        axlen_y = 1024

#   DetectorType = (1)ASC-I (2)ASC-S (3)HRC-I (4)HRC-S

        if (display==5)
             print("DetectorType",dettype)

        if (dettype == 1)       # ACIS-I
        {
           if ((xxkey=="chipx")&&(yykey=="chipy"))
           { 
              axlen_x = 1024
              axlen_y = 1024
           }
           else if ((xxkey=="tdetx")&&(yykey=="tdety"))
           {
              axlen_x = 8192
              axlen_y = 8192
           }
        }
        else if ( dettype == 2)   #ACIS-S
        {
           if ((xxkey=="chipx")&&(yykey=="chipy"))
           {
              axlen_x = 1024
              axlen_y = 1024
           }
           else if ((xxkey=="tdetx")&&(yykey=="tdety"))
           {
              axlen_x = 6144
              axlen_y = 1024
           }
        }
        else if ( dettype == 3)   #HRC-I
        {
           if ((xxkey=="chipx")&&(yykey=="chipy"))
           {
              axlen_x = 16384
              axlen_y = 16384
           }
           else if ((xxkey=="tdetx")&&(yykey=="tdety"))
           {
              axlen_x = 16384
              axlen_y = 16384
           }
        }
        else if ( dettype == 4)   #HRC-S
        {
           if ((xxkey=="chipx")&&(yykey=="chipy"))
           {
              axlen_x = 16384
              axlen_y = 4096
           }
           else if ((xxkey=="tdetx")&&(yykey=="tdety"))
           {
              axlen_x = 49152
              axlen_y = 4096
           }
        }
       else 
       {
           axlen_x = axlen1
           axlen_y = axlen2
       }

#---------------------------------------------------------------
# Delete intermediate qpoe files if it exists.
#---------------------------------------------------------------
        if( access("ttiimmx.qp") )
            delete("ttiimmx.qp", ver-, >& "dev$null")

#---------------------------------------------------------------
# Create a QPOE indexed with (key_x,key_y)
#---------------------------------------------------------------
        fits2qp (fits=infits, qpoe="ttiimmx.qp", naxes=2, axlen1=axlen_x, 
          axlen2=axlen_y, mpe_ascii_fi=no, clobber=clobber, oldqpoename=no, 
          display=display, fits_cards=fits_cards, qpoe_cards=qpoe_cards, 
          ext_cards=ext_cards, wcs_cards=wcs_cards, old_events="EVENTS", 
          std_events="STDEVT", rej_events="REJEVT", which_events="old", 
          oldgti_name="GTI", allgti_name="ALLGTI", stdgti_name="STDGTI", 
          which_gti="old", scale=yes, key_x=xxkey, key_y=yykey, 
          qp_internals=yes, qp_pagesize=qp_pagesize, 
          qp_bucketlen=qp_bucketlen, qp_blockfact=1, qp_mkindex=no, 
          qp_key="", qp_debug=0)

#---------------------------------------------------------------
# Sort the QPOE with yykey as the primary key and xxkey as the 
# secondary key.   ccdid = ????
#---------------------------------------------------------------
       sorttypekey = yykey//" "//xxkey

       ##show qmfiles
       ##show home
       ##show dev
       ##print ("axlen_x=",axlen_x)
       ##print ("axlen_y=",axlen_y)
       ##print ("detect type = ", dettype)
       ##print ("sorttypekey=",sorttypekey,"jcc")

       if (display==5)
       {   
           print(yykey)
           print(xxkey)
           print(sorttypekey)
       }

       qpsort (input_qpoe="ttiimmx.qp",region="", qpoe=outqpoe, eventdef="", 
         sorttype=sorttypekey, exposure="NONE", expthresh=0.,
         clobber=clobber, display=1, sortsize=1000000, qp_internals=yes, 
         qp_pagesize=2048, qp_bucketlen=4096, qp_blockfact=1, 
         qp_mkindex=yes, qp_key="", qp_debug=0)

#---------------------------------------------------------------
# Delete intermediate qpoe files if it exists.
#---------------------------------------------------------------
        if((access("ttiimmx.qp")) && (DeleteInterm))
            delete("ttiimmx.qp", ver-, >& "dev$null")
end
