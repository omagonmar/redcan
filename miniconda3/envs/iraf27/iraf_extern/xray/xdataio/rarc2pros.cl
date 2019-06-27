#$Header: /home/pros/xray/xdataio/RCS/rarc2pros.cl,v 11.0 1997/11/06 16:37:46 prosb Exp $
#$Log: rarc2pros.cl,v $
#Revision 11.0  1997/11/06 16:37:46  prosb
#General Release 2.5
#
#Revision 9.1  1997/10/03 21:46:10  prosb
#no change.
#
#Revision 9.0  1995/11/16 18:57:07  prosb
#General Release 2.4
#
#Revision 8.5  1995/10/02  19:44:23  prosb
#JCC - Updated to check the fits file (*fits) only for RDF format.
#
#Revision 8.3  1995/06/09  14:07:11  prosb
#JCC - Updated to fix the problem described in hp14:
#      "wp*.fits should not be allowed in MPE REV0 FITS files".
#
#Revision 8.2  1995/05/22  19:18:31  prosb
#JCC - Updated to allow users to specify an output filename
#      when autoname="no".
#    - Added the condition checking for "No FITS files found".
#
#Revision 8.0  1994/06/27  15:17:45  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/08  14:38:39  janet
#jd - deleted files.lst at end of script.
#
#Revision 7.0  93/12/27  18:43:53  prosb
#General Release 2.3
#
#Revision 6.4  93/12/15  12:04:47  mo
#no changes
#
#Revision 6.3  93/12/15  12:03:29  mo
#MC	12/15/93	Updated for REV0 and RDF formats
#
#
#
# Module:       rarc2pros.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert ROSAT files into PROS format
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC	initial version 10/93
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
procedure rarc2pros(inpfile,instrument,outpfile)
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
	string msg,msg1,msg2,msg3,msg4
	string tfile
        string outname                  #JCC
	int	rdf
	int	cnt
        int     ii, jj
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
        outname = outpfile             #JCC
	full = unscreened

	rdf = 0
	cnt = 1
	if( access("files.lst") )
		delete("files.lst", ver-, >& "dev$null")
	files( infile//"*fits", > "files.lst" )
	list = "files.lst"
	while( fscan (list,s1) != EOF )  {
	   if (rdf == 0)  {
	     tfile = s1
	     if( access(tfile) )
                catfits (tfile, "", format_file="", log_file="foo.log", 
			long_header=yes, short_header=yes, ext_print=yes, 
			offset=0) | 
		match ("REVISION", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,rdf)
	    cnt = cnt+1
           }
	}

        if ((cnt==1)&&(rdf != 0))        #JCC.("wh*_*.mt" for rev0)
        {  error(1,"FITS files ("//infile//"*fits) are not found.")
        }

	if( rdf == 0 ){
	  msg = "Files are in Rev 0 format"
          print(msg)
	  if( full )
	     error (1,"Unscreened events not available in Rev 0 format")
	}
	else {
          ii =  stridx("w",tfile)          ##JCC
          jj =  stridx("p",tfile)
          if (ii==1 && jj==2)  {
    msg1 ="ERROR: MPE REV0 fits files in the US data archive with filenames"
    msg2 ="       like wp<sequence number>.fits are invalid input to rarc2pros"
    msg3 ="       and will cause the program to misinterpret the data formats"
    msg4 ="       and eventually fail. Delete this file and re-run rarc2pros." 
             print(msg1)
             print(msg2)
             print(msg3)
             print(msg4)
             error(1,"rarc2pros ()")
          }
          else  {
	     msg = "Files are in RDF format"
             print(msg)
          }
        }

	if( rdf == 0 )
	{
	    _rarc2pros0 (infile, instr , 
		correct=yes, clobber=clobber, qp_psize=qp_psize, 
		qp_blen=qp_blen, sort = yes)
	}
	else
	{
	    _rdfarc2pros (infile,instr,unscreened=full,outpfile=outname,
                autoname=autoname, 
		clobber=clobber, qpi=qpi, qp_psize=qp_psize, qp_blen=qp_blen, 
		qp_blfact=qp_blfact, qp_index=qp_index, qp_ky=qp_ky, 
		qp_deb=qp_deb)
	}

	if( access("files.lst") )
		delete("files.lst", ver-, >& "dev$null")
  end
