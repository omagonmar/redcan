#$Header: /home/pros/xray/xdataio/RCS/upqpoerdf.cl,v 11.0 1997/11/06 16:37:48 prosb Exp $
#$Log: upqpoerdf.cl,v $
#Revision 11.0  1997/11/06 16:37:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:14  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:17:57  prosb
#General Release 2.3.1
#
#Revision 1.1  94/05/15  11:36:02  janet
#Initial revision
#
#
#
#
# Module:       upqpoerdf.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert Rev 0 ROSAT files into RDF format
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC	initial version 3/94
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
procedure upqpoerdf(inpfile)
# ======================================================================

  string inpfile   	  	  {prompt="input filename [root]"}
#  string instrument	          {min="hri|pspc", prompt="instrument"}
#  bool	debug			  {no,prompt="retain temp files?",mode="h"}
  int display			  {1,prompt="display level",mode="h"}
  int   qp_psize                  {2048,prompt="system page size",mode="h"}
  int   qp_blen                   {4096,prompt="system bucket len",mode="h"}

  struct *filelist

  begin

# Declare the intrinsic parameters:
 
	string infile			# input file suite
	string tempfile			# output file suite
	string dlist
	string test = ''
	string buf = ''
	string key  = ''
	string keyx  = ''
	string keyy  = ''
	int	disp
	int     psize
	int	blen

	struct onefile

# make sure packages are loaded
        if ( !deftask ("_upqp2rdf") )
          error (1, "Requires xray/xdataio to be loaded!")
        if ( !deftask ("qpgapmap") )
          error (1, "Requires xray/xdataio to be loaded!")


# Get query parameters 
	infile = inpfile	
	disp = display
	psize = qp_psize
	blen = qp_blen

	if( disp > 0 )
	    print("Converting file headers to RDF ...")
	_upqp2rdf(infile,display=disp)
#	delete(filelist,ver-,>&"dev$null")
	dlist = mktemp("tmp$dlt")
	sections(infile,> dlist)
	filelist = dlist
	if( disp > 0 )
	    print("Calculating ROSAT/HRI detector coordinates...")
	while( fscan(filelist,onefile) != EOF )
	{
#	    print(onefile)
            _rtname(onefile, "", ".qp")
            onefile = s1
#	    print(onefile)
	    imhead(onefile,long+) | match("INSTRUME","", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
	    if( disp > 3 )
	        print("INSTRUME value as scanned from input file: ",test)
	    test = substr(test, 2, 4)
	    if( disp > 3 )
	        print("INSTRUME value for test: ",test)
	    if( test == "HRI" )
	    {
	        imhead(onefile,long+) | match("TELESCOP","", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
	        if( disp > 3 )
	            print("TELESCOP value as scanned from input file: ",test)
		test = substr(test,2,6)
	        if( disp > 3 )
	            print("TELESCOP value test: ",test)
 	        if( test == "ROSAT" )
	        {
	            imhead(onefile,long+) | match("RAWX","", stop=no, print_file_n=yes, metacharacte=yes) | scan(keyx)
	            imhead(onefile,long+) | match("RAWY","", stop=no, print_file_n=yes, metacharacte=yes) | scan(keyy)
	            if( disp > 4 )
	                print("search for RAWX,RAWY returned: ",keyx, ",",keyy)
		    if( keyx == "RAWX" && keyy == "RAWY" )
		    {
		        keyx=""
		        keyy=""
	                imhead(onefile,long+) | match("DETX","", stop=no, print_file_n=yes, metacharacte=yes) | scan(keyx)
	                imhead(onefile,long+) | match("DETY","", stop=no, print_file_n=yes, metacharacte=yes) | scan(keyy)
	                if( disp > 4 )
	                    print("search for DETX,DETY returned: ",keyx, ",",keyy)
		        if( keyx == "" && keyy == "" )
		        {
		            tempfile = mktemp("rdf")
		            tempfile = tempfile // ".qp"
        		    qpgapmap(onefile,"",tempfile,"full",exposure="NONE",
			    expthresh=0.,gapmap="xspatialdata$283cgapmap4.ieee",
			    detx="detx", 
		            dety="dety", rawx="rawx", rawy="rawy", pha="pha", 
			    random=yes, xoffset=2047.5, yoffset=2047.5, 
			    clobber=yes, display=0, sort=no, sorttype="y x",
			    sortsize=1000000, qp_internals=yes, 
			    qp_pagesize=psize, qp_bucketlen=blen, 
			    qp_blockfact=1, qp_mkindex+, qp_key="", qp_debug=0)

	                   delete(onefile, yes, verify-,default_ac+,subfiles+,>& "dev$null")

			  if( disp > 3 )
			      print("renaming file ",tempfile," to ",onefile)
	                  rename(tempfile, onefile)
		          if( disp > 0 )
		          {
		              buf = "Writing output file - " // onefile 
			      print(buf)
		          }
		      } # if DETX,Y doesn't exist in file
		      else
		      {
			if( disp > 0 )
			    print(onefile," - Detector coordinates already exist")
		      }
	            }   # if RAWX,Y doesn't exist in file
		    else
		    {
		        if( disp > 0 )
			  print(onefile," - Required RAW coordinates don't exist - skipping")
		    }
		}	# if ROSAT Telescope
		else
		{
		    if( disp > 0 )
		        print(onefile," - not ROSAT data file - skipping")
		}
	    }		# if HRI instrument
	    else
	    {
	        if( disp > 0 )
		  print(onefile," - not HRI data file - skipping")
	    }
	}		# while next filename
end
