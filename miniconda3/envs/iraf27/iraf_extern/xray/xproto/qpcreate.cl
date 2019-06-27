#$Header: /home/pros/xray/xproto/RCS/qpcreate.cl,v 11.2 1999/09/21 15:20:20 prosb Exp $
#$Log: qpcreate.cl,v $
#Revision 11.2  1999/09/21 15:20:20  prosb
#JCC(7/16/98) - Updated to fix qpsim bug, which complaining sim.qp
#               not exist because it's named as sim.qp.qp.
#
#Revision 11.0  1997/11/06 16:39:10  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:26:18  prosb
#General Release 2.4
#
#Revision 8.4  1995/05/04  19:02:39  prosb
#JCC - Add param. "key_x & key_y" for FITS2QP.
#
#Revision 8.3  94/10/05  13:54:39  dvs
#Added new fits2qp params.
#
#Revision 8.2  94/09/07  17:47:30  janet
#jd - replaced NONE with "" (blank) for variable key and qp_key.
#
#Revision 8.1  94/09/07  14:30:41  janet
#jd - put double quotes around NONE.
#
#Revision 8.0  94/06/27  17:25:27  prosb
#General Release 2.3.1
#
#Revision 1.1  94/03/25  13:40:47  mo
#Initial revision
#
#
# ----------------------------------------------------------------------------
# module:	qpcreate.cl
# description:	Create a PROS QPOE file from an input ASCII event list.
#
# ----------------------------------------------------------------------------
procedure qpcreate(evtlist,outfile,coldef,headdef)
    string	evtlist {prompt="input ASCII event-list",mode="a"}
    string	outfile { prompt="Output QPOE file name",mode="a"}
    string	coldef	{ ".",prompt="column definition file",mode="a"}
    string	headdef { ".",prompt="header parameter defintions",mode="a"}
    int		nskip   { 0, prompt="number of lines to skip in evtlist",mode="h"}
    int		nlines   {0, prompt="number of lines in evtlist per row",mode="h"}
    int		nrows   {0, prompt="number of rows to read in evtlist",mode="h"}
    string	esize  {"",prompt="QPOE event definition",mode="h"}
    bool	sort { yes, prompt="sort by position?",mode="h"}
    bool	clobber { no, prompt="OK to delete existing output file?",mode="h"}
    int		display {1,min=0,max=5,prompt="0=no disp, 1=header",mode="h"}
    int	ssize {1000000, prompt="max number of events per sort",mode="h"}
    bool qpi	{yes, prompt="prompt for qp internals?",mode="h"}
    int	psize	{4096,prompt="page size for qpoe file",mode="h"}
    int bsize	{8192,prompt="bucket length of qpoe file",mode="h"}
    string xkey {"x",prompt="index key for x coordinate QPOE events"}
    string ykey {"y",prompt="index key for y coordinate QPOE events"}
    string qpkey  {"",prompt="key on which to make index",mode="h"}
    int	debug   {0,min=0,max=5,prompt="qpoe debug level"}
#  jd (9/94) - wasn't being used and since one time it's yes and the other 
#              no, decided it better stay hardcoded.
#    bool mkindex {no,prompt="make an index on y, x?",mode="h"}

begin
    string	evt
    string	qp	
    string	col	
    string	head	
    string	tab
    string	fits
    string	buf
    string	temp
#    string	bbuf
    bool	clob
    int 	deb

# make sure tcreate is already defined, as packages can't be loaded in scripts!
        if( !deftask("tcreate") )
            error(1, "Requires tables to be loaded to find tcreate!")
        if( !deftask("xwfits") )
            error(1, "Requires xdataio to be loaded to find xwfits!")
        if( !deftask("fits2qp") )
            error(1, "Requires xdataio to be loaded to find fits2qp!")

        evt = evtlist
	qp  = outfile
	col = coldef
	head = headdef 
	clob = clobber
	temp = mktemp("tcr")
	deb = debug

#  Build default output filenames
	_rtname(evt,col,".cd")
	col = s1
	_rtname(evt,head,".hd")
	head = s1
	_rtname(evt,"",".tab")
	tab = s1
	_rtname(evt,"",".fits")
	fits = s1
	_rtname(evt,qp,".qp")
	qp = s1
	_rtname(temp,temp,".qp")
	temp = s1

#
# Check for existing output file ( may have been input with or without the .imh
#	extension )
	if( disp > 1 )
	{
	    buf = "starting table creation - " // tab
	    print( buf )
	}
	if( disp > 2 )
	{
	    buf = "-- column definition  - " // col
	    print( buf )
	    buf = "-- header definition  - " // head
	    print( buf )
	}
	if( access(tab) && !clob )
	{
	    buf = "Can't delete existing file - " // tab
	    error(1,buf)
	}
	else
	    delete (tab, yes, verify=no, default_acti=yes, allversions=yes, 
			subfiles=yes,>&"dev$null")

	tcreate(tab,col,evt,uparfile=head,nskip=nskip,nlines=nlines,
		nrows=nrows,hist=yes,extrapar=5,tbltype="default",
		extracol=0)
	
	if( disp > 1 )
	{
	    buf = "starting FITS creation - " // fits
	    print( buf )
	}
	if( access(fits) && !clob )
	{
	    buf = "Can't delete existing file - " // fits
	    error(1,buf)
	}
	else
	    delete (fits, yes, verify=no, default_acti=yes, allversions=yes, 
			subfiles=yes,>&"dev$null")

       xwfits (tab,fits,bin=yes,newtape=no,bscale=1.,bzero=0.,mkimg=yes )
#       xwfits (tab, fits, yes, newtape=no, bscale=1., bzero=0., mkimg=yes )
#	xwfits (tab, fits, yes, newtape=no, bscale=1., bzero=0., mkimg=yes, 
#		long=no, short=yes, fileform="", log="", bit=0, bl=1, ext=no, 
#		prec=yes, st=yes, ieee=yes, fmin=no, scale=yes, auto=yes)
	
	if( disp > 1 )
	{
	    buf = "starting QPOE creation - " // qp
	    print( buf )
	}
	if( access(qp) && !clob )
	{
	    buf = "Can't delete existing file - " // qp
	    error(1,buf)
	}
	else
	    delete (qp, yes, verify=no, default_acti=yes, allversions=yes, 
			subfiles=yes,>&"dev$null")

##JCC - Allow users access to the parameters KEY_X/Y
##    - old_events=sim.tab , created from TCREATE.
##
	fits2qp (fits,qp,naxes=0,axlen1=0, axlen2=0, mpe_ascii_fi=no, 
		 clobber=clob, oldqpoename=no, display=deb, 
	      fits_cards="xdataio$fits.cards",qpoe_cards="xdataio$qpoe.cards",
		 ext_cards="xdataio$ext.cards", wcs_cards="xdataio$wcs.cards", 
		old_events=tab, std_events="STDEVT",
		rej_events="REJEVT", which_events="old", oldgti_name="GTI",
	    allgti_name="ALLGTI",stdgti_name="STDGTI", which_gti="standard",
                scale=yes, key_x=xkey, key_y=ykey,
		qp_internals=qpi, qp_pagesize=psize, qp_bucketlen=bsize, 
		qp_blockfact=1, qp_mkindex=no, qp_key=qpkey, qp_debug=debug)
	
	if( sort ){
	    if( disp > 1 )
	    {
	        buf = "starting  sort  - " // qp
	        print( buf )
	    }
	    qpsort (qp,"",temp,esize,"position",
	        exposure="none", expthresh=0.0, clobber=clob, 
	        display=deb,sortsize=ssize, qp_internals=qpi, 
		qp_pagesize=psize, qp_bucketlen=bsize,
	        qp_mkindex=yes, qp_key="", qp_debug=debug)
	    delete (qp, yes, verify=no, default_acti=yes, allversions=yes, 
			subfiles=yes,>&"dev$null")
	    if( disp > 0 )
	    {
	        buf = "writing output file  - " // qp
	        print( buf )
	    }
	    #JCC - rename (temp, qp, field="root")  
	    rename (temp, qp)  
	}
	if( deb < 1 )  	# Clean up all the intermediate files
	{
	    delete (tab, yes, verify=no, default_acti=yes, allversions=yes, 
			subfiles=yes)
	    delete (fits, yes, verify=no, default_acti=yes, allversions=yes, 
			subfiles=yes)
	}
end



