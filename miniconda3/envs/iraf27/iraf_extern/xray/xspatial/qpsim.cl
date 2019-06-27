# $Header: /home/pros/xray/xspatial/RCS/qpsim.cl,v 11.0 1997/11/06 16:33:18 prosb Exp $
# $Log: qpsim.cl,v $
# Revision 11.0  1997/11/06 16:33:18  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:35:42  prosb
# General Release 2.4
#
#Revision 1.3  1995/05/17  14:52:08  prosb
#JCC - Updated with new QPCREATE parameters.
#
#Revision 1.1  1995/05/17  14:36:59  prosb
#Initial revision
#
# Module:       qpsim.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      CL wrapper for the simevt program
# Description:	Calls the simevt program as well as qpcreate and qpappend
#		Performs all file i/o checking for simevt
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} KRM -- intitial version -- 8/94

procedure qpsim.cl(srctab, refqp, outroot)

string srctab		{prompt="Input source table file"}
string refqp		{"xspatial$data/hdummy.qp",prompt="Reference QPOE file"}
string outroot		{prompt="Root name for output files"}
real livetime		{0., min=0.,prompt="Livetime for simulated data", mode="h"}
string prftab		{"xspatialdata$prfcoeffs.tab", prompt="Prf coefficient table", mode="h"}
bool clobber		{no, prompt="OK to clobber existing files?", mode="h"}
int display		{1, prompt="display level", mode="h"}
bool sort		{yes, prompt="sort by position?", mode="h"}
int ssize		{1000000, prompt="max number of events per sort", mode="h"}
bool qpint		{yes, prompt="prompt for qp internals?", mode="h"}
int psize		{4096, prompt="page size for qpoe file", mode="h"}
int bsize		{8192, prompt="bucket length of qpoe file", mode="h"}
bool mkindex		{no, prompt="make an index on y, x?", mode="h"}
string key		{"", prompt="key on which to make index", mode="h"}
int debug		{0, prompt="qpoe debug level", mode="h"}

begin

    # local variables

    file c_srctab	# local copy of source table name
    file c_refqp	# local copy of reference qpoe file name
    file c_outroot	# local copy of output root
    file filetemp       # temp file input before root is checked/added

    string empty=""	# used for rootname calls
    string ext=""	# used in rootname calss

    string evtlist	# name of event list, output of simevt
    string temp_evtlist # temp name of event list
    string evthead	# name of event header, output of simevt
    string temp_evthead # temp name of event header

    string simqp	# qpoe output by qpcreate, contains simulated data
		
    string outqp	# final output file, created by qpappend
    string tempqp	# temporary output file name

    string applist	# name of list for qpappend call

    # make sure that required tasks are accessible

    if ( !deftask("_simevt") )
    {
	beep 
	error(1, "Requires xray.xspatial package to be loaded!")
    }
    if ( !deftask("qpcreate") ) 
    {
	beep 
	error(1, "Requires xray.xproto package to be loaded!")
    }
    if ( !deftask("qpappend") )
    {
	beep
	error(1, "Requires xray.xdataio package to be loaded!")
    }

    # get input file names 
    
    filetemp = srctab
    _rtname (filetemp, c_srctab, ".tab")
    c_srctab = s1       
    
    if ( !access(c_srctab) ) 
    {
	beep
	error(1, "Cannot access input source table!")
    }    

    filetemp = refqp
    _rtname (filetemp, c_refqp, ".qp")
    c_refqp = s1       

    if ( !access(c_refqp) )
    {
	beep
	error(1, "Cannot access reference QPOE file!")
    }

    # construct output file names
    #
    # evtlist, evthead  - output from simevt
    # simqp  	- output from qpcreate
    # applist	- list for qpappend call
    # outqp  	- output from qpappend
    #

    c_outroot = outroot

    if ( display > 2 ) 
    {
	print("")
	print("Input values ")
	print("")
	print("source tab : "//c_srctab)
	print("ref qp 	  : "//c_refqp)
	print("out root   : "//c_outroot)
    }

    # NOTE, for the event list and header name we will tack on a "qpc"
    # to the names if the specified output root is "".  This insures
    # that the table file created in qpcreate has a name unique to the
    # input source table file.

    if ("" == c_outroot) 
    {
	ext = "qpc.evtlist"
    }
    else
    {
	ext = ".evtlist"
    }

    _rtname(c_srctab, c_outroot, ext)
    evtlist = s1
    _clobname(evtlist, empty, clobber=clobber)
    temp_evtlist = s1

    if ("" == c_outroot)
    {
        ext = "qpc.evthead"
    }
    else
    {
        ext = ".evthead"
    }

    _rtname(c_srctab, c_outroot, ext)
    evthead = s1
    _clobname(evthead, empty, clobber=clobber)
    temp_evthead = s1

    _rtname(c_srctab, c_outroot, "_sim.qp")
    simqp = s1

    applist = mktemp(c_outroot//"app.lst")

    _rtname(c_srctab, c_outroot, ".qp")
    outqp = s1
    _clobname(outqp, empty, clobber=clobber)
    tempqp = s1

    if ( display > 2 ) 
    {
	print("")
	print("QPSIM file names")
	print("")
	print("    evthead : "//evthead)
 	print("    evtlist : "//evtlist)
 	print("    sim qp  : "//simqp)
	print("    append list : "//applist)
 	print("    out qp  : "//outqp)
    }

    if ( display > 0 )
    {
	print("")
	print("### Generating simulated data ###")
	print("")
    }

    _simevt(c_srctab, c_refqp, temp_evtlist, temp_evthead, livetime=livetime,
	   display=display, prf_table=prftab)

    _fnlname(temp_evtlist, evtlist)
    _fnlname(temp_evthead, evthead)

    if ( display > 0 ) 
    {
	print("")
	print("### Creating QPOE with simulated data ###")
	print("")
    }

    qpcreate(evtlist, simqp, "xspatialdata$qpoe.cd", evthead, nskip=0, 
             nlines=0, nrows=0, esize="small", sort=sort, clobber=clobber, 
             display=display, ssize=ssize, qpi=qpint, psize=psize, bsize=bsize, 
             xkey="x", ykey="y", qpkey=key, debug=debug)
    
    if ( debug == 0 ) 
    {
	delete(evtlist, yes, verify=no)
	delete(evthead, yes, verify=no)
    }

    print(c_refqp, >> applist)
    print(simqp, >> applist)

    if ( display > 0 )
    {
	print("")
	print("### Appending simulated data to reference QPOE ###")
	print("")
    }
      
    qpappend("@"//applist, "", tempqp, "small", exposure="NONE", expthresh=0.,
	     clobber=clobber, display=display, sort=sort, sorttype="y x", 
	     sortsize=ssize, qp_internals=qpint, qp_pagesize=psize,
	     qp_bucketlen=bsize, qp_blockfact=1, qp_mkindex=mkindex,
	     qp_key=key, qp_debug=debug)

    if ( display > 0 )
    {
	print("")
	print("Renaming output file : "//outqp)
	print("")
    }
    
    _fnlname(tempqp, outqp)

    if ( debug == 0 ) 
    {
	delete(applist, yes, verify=no)
	delete(simqp)
    }

end
