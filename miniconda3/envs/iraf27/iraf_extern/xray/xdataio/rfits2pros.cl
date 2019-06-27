#$Header: /home/pros/xray/xdataio/RCS/rfits2pros.cl,v 11.0 1997/11/06 16:36:29 prosb Exp $
#$Log: rfits2pros.cl,v $
#Revision 11.0  1997/11/06 16:36:29  prosb
#General Release 2.5
#
#Revision 9.2  1997/10/03 21:47:10  prosb
#no change.
#
#Revision 9.0  1995/11/16 18:57:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:17:51  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/27  12:23:16  janet
#jd - forced autoname to false for rev0 data
#
#Revision 7.0  93/12/27  18:43:59  prosb
#General Release 2.3
#
#Revision 6.4  93/12/21  14:54:17  mo
#MC	12/22/93		Propagate the outpfile parameter correctly
#				to sub-scripts
#
#Revision 6.3  93/12/15  12:05:11  mo
#MC	12/15/93	Updated for REV0 and RDF support
#
#
#
# Module:       rfits2pros.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert ROSAT files into PROS format
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC	initial version 10/93
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
procedure rfits2pros(inpfile,instrument,outpfile)
# ======================================================================

  string inpfile   	  	  {prompt="input filename [root]"}
  string instrument	          {min="hri|pspc", prompt="instrument"}
  string outpfile   	  	  {".",prompt="output filename"} 
  bool	unscreened		  {no,prompt="include rejected events?",mode="h"} 
  bool	autoname		  {yes,prompt="Rename to IRAFNAME?",mode="h"}
  bool	corkey			  {yes,prompt="Correct CRPIX keywords",mode="h"}
  bool	clobber			  {no,prompt="Okay to delete existing file?",mode="h"}
  bool	qpi			  {no,prompt="Specify QP internal parameters?",mode="h"}
  int	qp_psize		  {2048,prompt="system page size",mode="h"}
  int	qp_blen			  {4096,prompt="system bucket len",mode="h"}
  int   qp_blfact		  {1,prompt="qpoe blocking factor",mode="h"}
  bool	qp_index		  {yes,prompt="make position index?",mode="h"}
  string qp_ky			  {"y x",prompt="sort key(s) for index",mode="h"}
  int	qp_deb		 	 {0,prompt="qp debug print level",mode="h"}

  begin

# Declare the intrinsic parameters:
 
	string infile			# input file suite
	string instr			# instrument	
	string key
	string msg
	string tfile
	string outfile
	int	rdf
	int	cnt
	bool	full

# make sure packages are loaded
        if ( !deftask ("fits2qp") )
          error (1, "Requires xray/xdataio to be loaded!")
        if ( !deftask ("strfits") )
          error (1, "Requires tables or stsdas/fitsio to be loaded!")
        if (!defpac("tables"))
            error(1, "Tables package must be loaded.")

#---------------------
# Initialize variables
#---------------------


# Get query parameters 
	infile = inpfile	
	instr = instrument
	full = unscreened
	rdf = 0
	cnt = 1
	while( rdf == 0 && cnt < 50 )
	{
	    tfile = infile//"000" + cnt
#	    print(tfile)
	    if( access(tfile) )
                catfits (tfile, "", format_file="", log_file="foo.log", 
			long_header=yes, short_header=yes, ext_print=yes, 
			offset=0) | 
		match ("REVISION", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,rdf)
	    cnt = cnt+1
	}
	if( !autoname || rdf == 0 )
	    outfile = outpfile
	else
	    outfile ="."

	if( rdf == 0 ){
	    msg = "Files are in Rev 0 format"
	    if( full )
	      error (1,"Unscreened events not available in Rev 0 format")
	}
	else
	    msg = "Files are in RDF format"
	print(msg)
	if( rdf == 0 )
	{
	    _rfits2pros0 (infile, instr , outfile, autoname=no, 
		corkey=yes, 
		clobber=clobber, qpi=qpi, qp_psize=qp_psize, qp_blen=qp_blen, 
		qp_blfact=qp_blfact, qp_index=qp_index, qp_ky=qp_ky, 
		qp_deb=qp_deb)
	}
	else
	{
	    _rdffits2pros (infile, instr , full, outfile, autoname=autoname, 
		clobber=clobber, qpi=qpi, qp_psize=qp_psize, qp_blen=qp_blen, 
		qp_blfact=qp_blfact, qp_index=qp_index, qp_ky=qp_ky, 
		qp_deb=qp_deb)
	}
  end
