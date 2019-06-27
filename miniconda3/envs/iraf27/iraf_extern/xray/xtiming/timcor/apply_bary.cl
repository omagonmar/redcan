# JCC(1/99) - new script for apply_bary (y2k);output has no key *DATE*
# JCC(3/99) - copy the key *DATE* from input to output;
# JCC(9/99) - remove print statements ;
# JCC(11/99) - comment out qphedit ;
# ======================================================================
procedure apply_bary(input_qpoe, tblfile, eventdef, qpoe)
# ======================================================================
 string input_qpoe {"",prompt="input qpoe file name"}
 string tblfile   {prompt="input correction table filename"}
 string eventdef  {"large",prompt="event definition"}
 string qpoe      {"",prompt="output qpoe file name"}
 string region    {"",prompt="region descriptor",mode="h"}
 string scc_to_ut {"xtimingdata$scc_to_utc.tab",prompt="SCC to UTC table",mode="h"}
 string exposure  {"NONE",prompt="exposure mask",mode="h"}
 real   expthresh {0.,prompt="min. percent of exp. time for inclusion",mode="h"}
 string tbl_i1 {"IT1",prompt="Corr. table col name of uncorrected int date",mode="h"}
 string tbl_r1 {"RT1",prompt="Corr. table col name of uncorrected real date",mode="h"}
 string tbl_i2 {"IT2",prompt="Corr. table col name of corrected int date",mode="h"}
 string tbl_r2 {"RT2",prompt="Corr. table col name of corrected real date",mode="h"}
 bool   clobber    {no,prompt="delete old copy of output file",mode="h"}
 int    display    {1,min=0,max=5,prompt="0=no disp, 1=header",mode="h"}
 bool   sort       {no,prompt="sort events?",mode="h"}
 string sorttype   {"position",prompt="type of sort",mode="h"}
 int    sortsize   {1000000,prompt="bytes to alloc. per sort",mode="h"}
 bool qp_internals {yes,prompt="prompt for qpoe internals?",mode="h"}
 int  qp_pagesize  {1024,prompt="page size for qpoe file",mode="h"}
 int  qp_bucketlen {2048,prompt="bucket length for qpoe file",mode="h"}
 int  qp_blockfact {1,prompt="block factor for imio",mode="h"}
 bool qp_mkindex   {no,prompt="make an index on y, x",mode="h"}
 string qp_key     {"",prompt="key on which to make index",mode="h"}
 int  qp_debug     {0,prompt="qpoe debug level",mode="h"}

#-----------------------------
begin
 string in_qpoe, tbfile, evdef, qpoe2    # query parameters
 string date      # keypar("DATE")
 bool   fdate     # found DATE
 string zerodate,rdfdate,procdate,dateobs,dateend
 bool   fzerodate,frdfdate,fprocdate,fdateobs,fdateend

#-----------------------------
# make sure xdataion is loaded
#-----------------------------
#JCC(1/98) - load  xtiming & timcor 
       if (!defpac("xtiming")) { xtiming } ;
       if (!defpac("timcor"))  { timcor } ;
       if (!defpac("ximages"))  { ximages } ;

#---------------------
# Initialize variables
#---------------------

# Get query parameters

 in_qpoe = input_qpoe
 tbfile = tblfile
 evdef = eventdef
 qpoe2 = qpoe

#------------------------------------
#JCC(3/99)-get *DATE* keywords from input qpoe, 
#          then copy them to the output after running _abary.
#------------------------------------
 keypar (in_qpoe, "DATE", silent=no, value=".")
 date=keypar.value
 fdate=keypar.found
 # if (fdate) print("DATE=",date)

 keypar (in_qpoe, "ZERODATE", silent=no, value=".")
 zerodate=keypar.value
 fzerodate=keypar.found
 # if (fzerodate) print("ZERODATE=",zerodate)

 keypar (in_qpoe, "RDF_DATE", silent=no, value=".")
 rdfdate=keypar.value
 frdfdate=keypar.found
 # if (frdfdate) print("RDF_DATE=",rdfdate)

 keypar (in_qpoe, "PROCDATE", silent=no, value=".")
 procdate=keypar.value
 fprocdate=keypar.found
 # if (fprocdate) print("PROCDATE=",procdate)

 keypar (in_qpoe, "DATE-OBS", silent=no, value=".")
 dateobs=keypar.value
 fdateobs=keypar.found
 # if (fdateobs) print("DATE-OBS=",dateobs)

 keypar (in_qpoe, "DATE_END", silent=no, value=".")
 dateend=keypar.value
 fdateend=keypar.found
 # if (fdateend) print("DATE_END=",dateend)

 if (!fdateend)  
 {  
    keypar (in_qpoe, "DATE-END", silent=no, value=".")
    dateend=keypar.value
    fdateend=keypar.found
 }

#------------------------------------
# delete *DATE* from input qpoe file
#------------------------------------
#qphedit(in_qpoe,"DATE","NONE",add=no,delete=yes,verify=no,show=no,update=yes)
#qphedit(in_qpoe,"RDF_DATE","NONE",add=no,delete=yes,verify=no,show=no,update=yes)
#qphedit(in_qpoe,"ZERODATE","NONE",add=no,delete=yes,verify=no,show=no,update=yes)
#qphedit(in_qpoe,"PROCDATE","NONE",add=no,delete=yes,verify=no,show=no,update=yes)
#qphedit(in_qpoe,"DATE-OBS","NONE",add=no,delete=yes,verify=no,show=no,update=yes)
#qphedit(in_qpoe,"DATE_END","NONE",add=no,delete=yes,verify=no,show=no,update=yes)
#qphedit(in_qpoe,"DATE-END","NONE",add=no,delete=yes,verify=no,show=no,update=yes)

_abary(input_qpoe=in_qpoe, tblfile=tbfile, eventdef=evdef, 
qpoe=qpoe2, region=region, scc_to_ut=scc_to_ut, exposure=exposure, 
expthresh=expthresh, tbl_i1=tbl_i1, tbl_r1=tbl_r1, tbl_i2=tbl_i2, 
tbl_r2=tbl_r2, clobber=clobber, display=display, sort=sort, 
sorttype=sorttype, sortsize=sortsize, qp_internals=qp_internals, 
qp_pagesize=qp_pagesize, qp_bucketlen=qp_bucketlen, qp_blockfact=qp_blockfact, 
qp_mkindex=qp_mkindex, qp_key=qp_key, qp_debug=qp_debug)

#qphedit(qpoe2,"DATE-OBS","NONE",add=no,delete=yes,verify=no,show=no,update=yes)
#qphedit(qpoe2,"DATE-END","NONE",add=no,delete=yes,verify=no,show=no,update=yes)

#-----------------------------------------
# JCC(3/99)-copy *DATE* to the output qpoe
#-----------------------------------------
#if (fdate) qphedit(qpoe2,"DATE",date,add=yes,delete=no,verify=no,show=no,update=yes)

#if (fzerodate) qphedit(qpoe2,"ZERODATE",zerodate,add=yes,delete=no,verify=no,show=no,update=yes)

#if (frdfdate) qphedit(qpoe2,"RDF_DATE",rdfdate,add=yes,delete=no,verify=no,show=no,update=yes)

#if (fprocdate) qphedit(qpoe2,"PROCDATE",procdate,add=yes,delete=no,verify=no,show=no,update=yes)

#if (fdateobs) qphedit(qpoe2,"DATE-OBS",dateobs,add=yes,delete=no,verify=no,show=no,update=yes)

#if (fdateend) qphedit(qpoe2,"DATE_END",dateend,add=yes,delete=no,verify=no,show=no,update=yes)


end
