#$Header: /home/pros/xray/xtiming/RCS/timsort.cl,v 11.0 1997/11/06 16:46:06 prosb Exp $
#$Log: timsort.cl,v $
#Revision 11.0  1997/11/06 16:46:06  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:32:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:37:55  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/20  14:18:12  janet
#jd - changed region default for esize to "".
#
#Revision 7.0  93/12/27  19:04:38  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:55:12  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:05:54  janet
#jd - asigned clobber to a variable in the macro.
#
#Revision 5.0  92/10/29  23:06:52  prosb
#General Release 2.1
#
#Revision 4.1  92/10/23  10:06:54  mo
#MC	Update default parameters.
#
#Revision 4.0  92/04/27  15:30:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:00:02  prosb
#General Release 1.1
#
#Revision 2.2  91/07/21  18:10:54  mo
#MC	7/21/91		Updated for new package structure and
#			also for force QPI parameter for guarantee 
#			mkindex = no for these timsorted files.
#
#Revision 2.1  91/03/26  11:47:28  janet
#Updated Source and Bkgd filename prompt strings.
#
#Revision 2.0  91/03/06  22:32:29  pros
#General Release 1.0
#
# ----------------------------------------------------------------------------
# module:	timsort.cl
# description:	Create a time-sorted photon file from an input QPOE file.
# There is an option to create a background file in addition to the default
# source file.  This file is the primary input to the timing analysis package.
#
# ----------------------------------------------------------------------------
procedure timdatset(image,soutfile,sregion,boutfile,bregion)
    string	image {prompt="input qpoe file name",mode="a"}
    string	sregion	{ prompt="source region descriptor",mode="a"}
    string	exp  { "NONE",prompt="exposure mask",mode="h"}
    real	ethresh { 0.0, min = 0.0, max=100.0, prompt="min. percent of exp time for inclusion",mode="h"}
    string	soutfile { prompt="Output time-ordered file name",mode="a"}
    string	bregion	{ prompt="background region descriptor",mode="a"}
    string	boutfile { "NONE",prompt="Output time-ordered bkgd file name",mode="a"}
    string	esize   {"",prompt="QPOE event size",mode="h"}
    bool	clobber { no, prompt="OK to delete existing output file?",mode="h"}
    int		display {0,min=0,max=5,prompt="0=no disp, 1=header",mode="h"}

    int	ssize {1000000, prompt="max number of events per sort",mode="h"}
    bool qpi	{yes, prompt="prompt for qp internals?",mode="h"}
    int	psize	{4096,prompt="page size for qpoe file",mode="h"}
    int bsize	{8192,prompt="bucket length of qpoe file",mode="h"}
#    bool mkindex	{no,prompt="make an index on y, x?",mode="h"}
#    string key	{"NONE",prompt="key on which to make index",mode="h"}
    int	debug   {0,min=0,max=5,prompt="qpoe debug level"}
    begin
    string	btds
    string	tds
    string	img
    string	reg
    string	breg
    string	buf
    string	bbuf
    bool	clob
# make sure imcalc is already defined, as packages can't be loaded in scripts!
        if( !deftask("qpsort") )
            error(1, "Requires ximages to be loaded to find qpsort!")

        img = image
	tds = soutfile
	reg = sregion
	btds = boutfile
	clob = clobber
#  Build default output filenames
	_rtname(img,tds,"_sti.qp")
	tds = s1
	_rtname(img,btds,"_bti.qp")
	btds = s1
#  Check for NO background 
	if( btds == "NONE" )
		breg = "NONE"
	else
		breg = bregion
	;

#
# Check for existing output file ( may have been input with or without the .imh
#	extension )
	buf = "starting source creation - " // tds
	print( buf )
	qpsort(img,reg,tds,esize,"time",
	    exposure=exp, expthresh=ethresh, clobber=clob, 
	    display=display,sortsize=ssize, qp_internals=qpi, qp_pagesize=psize,
	    qp_bucketlen=bsize,
	    qp_mkindex=no, qp_key="NONE", qp_debug=debug)
	if( breg != "NONE" ){
	    buf = "starting  bkgd  creation - " // btds
	    print( buf )
	    qpsort (img,breg,btds,esize,"time",
	        exposure=exp, expthresh=ethresh, clobber=clob, 
	        display=display,sortsize=ssize, qp_internals=qpi, 
		qp_pagesize=psize, qp_bucketlen=bsize,
	        qp_mkindex=no, qp_key="NONE", qp_debug=debug)
	}
	;
end



