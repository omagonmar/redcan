# $Header: /home/pros/xray/xdataio/RCS/_rfits2pros0.cl,v 11.0 1997/11/06 16:36:10 prosb Exp $
# $Log: _rfits2pros0.cl,v $
# Revision 11.0  1997/11/06 16:36:10  prosb
# General Release 2.5
#
# Revision 9.1  1997/10/03 21:45:52  prosb
# JCC(10/97) - Add force to strfits.
#
# Revision 9.0  1995/11/16 18:56:45  prosb
# General Release 2.4
#
#Revision 8.3  1995/05/04  16:36:40  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.2  1994/10/05  13:51:31  dvs
#Added new fits2qp params.
#
#Revision 8.1  94/09/07  17:40:57  janet
#*** empty log message ***
#
#Revision 8.0  94/06/27  15:17:04  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/15  16:01:48  janet
#jd - added 'if access' conditional around deletes.
#
#Revision 7.0  93/12/27  18:43:03  prosb
#General Release 2.3
#
#Revision 1.2  93/12/21  14:53:53  mo
#MC	12/22/93		Define the 'toutfits' string
#
#Revision 1.1  93/12/16  10:04:12  mo
#Initial revision
#
#Revision 6.2  93/08/18  11:44:09  mo
#MC	8/18/93		Fix calling sequence and upgrade default buffers
#			to 2048/4096
#
#Revision 6.1  93/07/26  18:20:31  dennis
#Updated fits2qp calling sequences for RDF.
#
#Revision 6.0  93/05/24  16:22:43  prosb
#General Release 2.2
#
#Revision 5.3  93/03/23  16:56:59  mo
#no changes
#
#Revision 5.2  93/03/19  11:07:58  mo
#MC	3/19/93		Add evr and qlt file to converter
#
#Revision 5.1  93/01/20  09:40:12  mo
#MC	1/20/93		Update macro to correct bad CRPIX header values
#
#Revision 5.0  92/10/29  22:33:04  prosb
#General Release 2.1
#
#Revision 4.5  92/10/16  15:14:55  mo
#MC	10/16/92 Added the new FITS2QP parameter ( mpe_ascii_fits)
#
#Revision 4.4  92/07/27  15:59:03  jmoran
#JMORAN fixed renaming prob when only have single OBS for "_eph.tab" files
#
#Revision 4.3  92/07/14  17:21:24  jmoran
#JMORAN  changed datatype from default to int for tape009 (_mex.pl) file call
#        to strfits
#
#Revision 4.2  92/06/25  15:08:32  jmoran
#JMORAN Added code to display the ephemeris output filename
#
#Revision 4.1  92/05/06  15:57:29  jmoran
#JMORAN took out parameters "mode" and "flpar" from strfits, keypar, and 
#tmerge
#
#Revision 4.0  92/04/27  14:52:41  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/17  10:02:53  jmoran
#JMORAN added code to write out PSPC exposure PL file
#
#Revision 3.2  92/04/16  09:38:03  jmoran
#JMORAN added code to write out the split orbit table file
#
#Revision 3.0  91/08/02  01:11:48  prosb
#General Release 1.1
#
#Revision 1.3  91/08/01  21:54:29  mo
#MC	8/1/91		Fix some typos
#
#Revision 1.2  91/07/26  10:27:08  mo
#MC		7/26/91		Fixed to run for PSPC ( can't deal with -.pl
#				file )
#
#Revision 1.1  91/07/25  08:39:20  mo
#Initial revision
#
#
# Module:       rfits2pros.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert ROSAT files into PROS format
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} TK	initial version 7/91
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
procedure rfits2pros(inpfile,instrument,outpfile)
# ======================================================================

  string inpfile   	  	  {prompt="input filename [root]"}
#  string outpfile   	  	  {".",prompt="output directory (or filename if auto=no)"}
  string instrument	          {min="hri|pspc", prompt="instrument"}
  string outpfile   	  	  {".",prompt="output filename"} 
  bool	autoname		  {yes,prompt="Rename to IRAFNAME?",mode="h"}
  bool	corkey			  {yes,prompt="Correct CRPIX keywords",mode="h"}
  bool	clobber			  {no,prompt="Okay to delete existing file?",mode="h"}
  bool	qpi			  {no,prompt="Specify QP internal parameters?",mode="h"}
  int	qp_psize		  {2048,prompt="system page size",mode="h"}
  int	qp_blen			  {4096,prompt="system bucket len",mode="h"}
  int   qp_blfact		  {1,prompt="qpoe blocking factor",mode="h"}
  bool	qp_index		  {yes,prompt="make position index?",mode="h"}
  string qp_ky			  {"",prompt="sort key(s) for index",mode="h"}
  int	qp_deb		 	 {0,prompt="qp debug print level",mode="h"}

  begin

# Declare the intrinsic parameters:
 
	string infile			# input file suite
	string outfile			# output file suite
        string tab_file
	string instr			# instrument	
	string infits = ""		# HRI/PSPC input event file
	string inimg = ""		# HRI image file
	string inim1 = ""		# PSPC broad image file
	string inim2 = ""		# PSPC soft image file
	string inim3 = ""		# PSPC hard image file
	string inbk1 = ""		# PSPC broad background file
	string inbk2 = ""		# PSPC soft background file
	string inbk3 = ""		# PSPC hard background file
	string inbkg = ""		# HRI background file
	string insky = ""		# HRI/PSPC sky table
	string insrc = ""		# HRI/PSPC source table
	string inmex = ""		# PSPC exposure image
	string insp = ""		# PSPC spectral source table
	string ineph = ""               # Emphemeris input file
	string outfits = ""
	string toutfits = ""
	string msg = ""			# user display message
	string orb_lst
	string evr_lst
	string qlt_lst
        string eph_root
        string evr_root
        string qlt_root
        string temp_str
	string key
	string equal
	string test
	bool   auto
	bool   clob
	bool   correct

	bool qpii
	int  qpp
	int  qpb
	int  qpbl
	int  qpd
        bool qpix
	string qpk
	int idx1
	int idx2 
	bool exp_rename
	real pspcximg, pspcyimg, hriximg, hriyimg

	test = ""
        pspcximg = 256.51666666666667D0
        pspcyimg = pspcximg
        hriximg = 256.46875D0
        hriyimg = 256.53125D0

	qpii = qpi
	qpp  = qp_psize
	qpb  = qp_blen
	qpbl = qp_blfact
	qpd  = qp_deb
        qpix = qp_index
	qpk = qp_ky
	correct = corkey

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
        orb_lst = "tempbary_orb.lst"
        eph_root= "tempbary_so"
	evr_root= "temppspc_evr"
	evr_lst = "temppspc_evr.lst"
	qlt_root= "temppspc_qlt"
	qlt_lst = "temppspc_qlt.lst"

#---------------------------------------------------------------
# Delete the orbit list and intermediate tab files if they exist
#---------------------------------------------------------------
        delete(orb_lst, ver-, >& "dev$null")
        delete(evr_lst, ver-, >& "dev$null")
        delete(qlt_lst, ver-, >& "dev$null")

        temp_str = eph_root // "*.tab"
        delete(temp_str, ver-, >& "dev$null")

        temp_str = eph_root // "*.hhh"
        delete(temp_str, ver-, >& "dev$null")

        temp_str = eph_root // "*.imh"
        imdelete(temp_str, yes, ver-, >& "dev$null")

        temp_str = evr_root // "*.tab"
        delete(temp_str, ver-, >& "dev$null")

        temp_str = evr_root // "*.imh"
        imdelete(temp_str, yes, ver-, >& "dev$null")

        temp_str = evr_root // "*.hhh"
        delete(temp_str, ver-, >& "dev$null")
        
	temp_str = qlt_root // "*.tab"
        delete(temp_str, ver-, >& "dev$null")

        temp_str = qlt_root // "*.hhh"
        delete(temp_str, ver-, >& "dev$null")

        temp_str = qlt_root // "*.imh"
        imdelete(temp_str, yes, ver-, >& "dev$null")


# Get query parameters 
	infile = inpfile	
	instr = instrument
	auto = autoname		
	if( !auto )
	    outfile = outpfile
	else
	    outfile = "."
	clob = clobber

	if (instr == "hri") {

#		Create HRI PROS qpoe file - root.qp
	        _rtname(infile, infits, "002")
		infits = s1
		if( !auto ){
	            _rtname(infile, outfile, ".qp")
		    outfits = s1
		}
		else{
#	            _rtname(outfits, "", ".qp")
#		    outfits = s1
		    outfits = outfile//"/"//"dummy.qp"
		}

		if( !access(infits) ){
		   msg = "          Missing file "//infits//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
		fits2qp (infits, outfits, naxes=0, axlen1=0, axlen2=0, 
	         	 mpe_ascii_fits=no, 
			 clobber=clob, oldqpoename=auto, 
			 display=1, fits_cards="xdataio$fits.cards", 
			 qpoe_cards="xdataio$qpoe.cards", 
			 ext_cards="xdataio$ext.cards", 
			 wcs_cards="xdataio$wcs.cards", 
			 old_events="EVENTS", std_events="STDEVT", 
			 rej_events="REJEVT", which_events="old", 
			 oldgti_name="GTI", allgti_name="ALLGTI", 
			 stdgti_name="STDGTI", which_gti="old", 
		         scale=yes, key_x="x", key_y="y",
			 qp_internals=qpii, qp_pagesize=qpp, 
			 qp_bucketlen=qpb, qp_blockfact=qpbl, 
			 qp_mkindex=qpix, qp_key=qpk, qp_debug=qpd)

		if( auto )
		{
                    catfits (infits, "", format_file="", log_file="tmp$foo.log", long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ( "IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		    upqpoerdf(test)
		}
		else
		    upqpoerdf(outfits)
		}

# 		Create HRI PROS Image map - root_img.imh
		_rtname(infile, inimg, "003")
		inimg = s1
		if( !auto ){
	            _rtname(infile, outfile, "_img.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/" //"dummy_img.imh"

                if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inimg) ){
		   msg = "          Missing file "//inimg//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
	strfits (inimg, " ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

       		    if( correct )
		    {
	                 hedit (outfits, "CRPIX1", hriximg, add=no, delete=no, 
                           verify=no, show=no, update=yes)              
                         hedit (outfits, "CRPIX2", hriyimg, add=no, delete=no, 
                           verify=no, show=no, update=yes) 
		    }
                    upimgrdf(outfits)
		    		
		   if( auto )
		   {
	           catfits (inimg,
       		    "", format_file="", log_file="foo.log", long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
		   imrename( outfits, test, verbose=no)
		   }
		}

# 		Create HRI PROS backround map image - root_bkh.imh
		_rtname(infile, inbkg, "004")
		inbkg = s1
		if( !auto ){
	            _rtname(infile, outfile, "_bkg.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_bkg.imh"

                if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inbkg) ){
		   msg = "          Missing file "//inbkg//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
	strfits (inbkg," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., scale=yes, 
	 xdimtogf=no, oldirafname=no, offset=0, force=yes)

		    if( correct)
		    {
                    hedit (outfits, "CRPIX1", hriximg, add=no, delete=no, 
                           verify=no, show=no, update=yes)              
                    hedit (outfits, "CRPIX2", hriyimg, add=no, delete=no, 
                           verify=no, show=no, update=yes) 
		    }
                    upimgrdf(outfits)
		    if( auto )
		    {
	            catfits (inbkg,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	   short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
		   imrename( outfits, test, verbose=no)
		    }
		}
# 		Create HRI PROS Sky Catalog Table - root_sky.tab
		_rtname(infile, insky, "005")
		insky = s1
		if( !auto ){
	            _rtname(infile, outfile, "_sky.tab")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_sky.tab"

                if( access(outfits) && clob )
                   delete(outfits, ver-, >& "dev$null")

	        print ("--- outfits -->")
                print (outfits)
		if( !access(insky) ){
		   msg = "          Missing file "//insky//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
	strfits (insky, " ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., scale=no, 
	 xdimtogf=no, oldirafname=auto, offset=0, force=yes)

# 		Create HRI PROS Detected Source Table - root_src.tab
		_rtname(infile, insrc, "006")
		insrc = s1
		if( !auto ){
	            _rtname(infile, outfile, "_src.tab")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_src.tab"

                if( access(outfits) && clob )
                   delete(outfits, ver-, >& "dev$null")

		if( !access(insrc) ){
		   msg = "          Missing file "//insrc//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
	strfits (insrc," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., scale=no, 
	 xdimtogf=no, oldirafname=auto, offset=0, force=yes)
	}
	else  {
	  if (instr == "pspc") {
# 		Create PSPC PROS qpoe file - root.qp

	        _rtname(infile, infits, "002")
		infits = s1
		if( !auto ){
	            _rtname(infile, outfile, ".qp")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy.qp"

		print(infits)
		print(outfits)
		if( !access(infits) ){
		   msg = "          Missing file "//infits//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
		fits2qp (infits, outfits, naxes=0, axlen1=0, axlen2=0, 
			 mpe_ascii_fits=no, 
			 clobber=clob, oldqpoename=auto, 
			 display=1, fits_cards="xdataio$fits.cards", 
			 qpoe_cards="xdataio$qpoe.cards", 
			 ext_cards="xdataio$ext.cards", 
			 wcs_cards="xdataio$wcs.cards", 
			 old_events="EVENTS", std_events="STDEVT", 
			 rej_events="REJEVT", which_events="old", 
			 oldgti_name="GTI", allgti_name="ALLGTI", 
			 stdgti_name="STDGTI", which_gti="old", 
                         scale=yes, key_x="x", key_y="y",
			 qp_internals=qpii, qp_pagesize=qpp, 
			 qp_bucketlen=qpb, qp_blockfact=qpbl, 
			 qp_mkindex=qpix, qp_key=qpk, qp_debug=qpd)

		if( auto )
		{
                    catfits (infits, "", format_file="", log_file="tmp$foo.log",
			 long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ( "IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		    upqpoerdf(test)
		}
		else
		    upqpoerdf(outfits)
		}

# 		Create PSPC PROS broad image - root_im1.imh
	        _rtname(infile, inim1, "003")
		inim1 = s1
		if( !auto ){
	            _rtname(infile, outfile, "_im1.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_im1.imh"

                if( access(outfits) && clob )
		    imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inim1) ){
		   msg = "          Missing file "//inim1//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
	strfits (inim1, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		    if( correct)
		    {
                    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
                           verify=no, show=no, update=yes)              
                    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no, 
                           verify=no, show=no, update=yes) 
		    }
                    upimgrdf(outfits)
		    if( auto )
		    {
	            catfits (inim1, "", format_file="", log_file="foo.log", 
		    long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
 		    imrename( outfits, test, verbose=no)
		   }
		}

# 		Create PSPC PROS soft image - root_im2.imh
	        _rtname(infile, inim2, "004")
		inim2 = s1
		if( !auto ){
	            _rtname(infile, outfile, "_im2.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_im2.imh"

                if( access(outfits) && clob )
		   imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inim2) ){
		   msg = "          Missing file "//inim2//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
	strfits (inim2, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		    if( correct )
		    {
                    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
                           verify=no, show=no, update=yes)               
                    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no,  
                           verify=no, show=no, update=yes)  
		    }
                    upimgrdf(outfits)
		    if( auto )
		    {
	           catfits (inim2, "", format_file="", log_file="foo.log", 
		   long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
		   imrename( outfits, test, verbose=no)
		   }
		}
 

# 		Create PSPC PROS hard image - root_im3.imh 
		_rtname(infile, inim3, "005")
		inim3 = s1
		if( !auto ){
	            _rtname(infile, outfile, "_im3.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_im3.imh"

                if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inim3) ){
		   msg = "          Missing file "//inim3//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
	strfits (inim3, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

		    if( correct )
		    {
                    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
                           verify=no, show=no, update=yes)               
                    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no,  
                           verify=no, show=no, update=yes)  
		    }
                    upimgrdf(outfits)
		    if( auto )
		    {
	           catfits (inim3, "", format_file="", log_file="foo.log", 
		   long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
		   imrename( outfits, test, verbose=no)
		   }
		}
 
# 		Create PSPC PROS broad background image - root_bk1.imh
	        _rtname(infile, inbk1, "006")
		inbk1 = s1
		if( !auto ){
	            _rtname(infile, outfile, "_bk1.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_bk1.imh"

                if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inbk1) ){
		   msg = "          Missing file "//inbk1//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
	        {
	strfits (inbk1, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		    if( correct )
		    {
                    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
                           verify=no, show=no, update=yes)               
                    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no,  
                           verify=no, show=no, update=yes)  
		    }
                    upimgrdf(outfits)
		    if( auto )
		    {
	           catfits (inbk1, "", format_file="", log_file="foo.log", 
		   long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
		   imrename( outfits, test, verbose=no)
		   }
		}
 

# 		Create PSPC PROS soft background image - root_bk2.imh
	        _rtname(infile, inbk2, "007")
		inbk2 = s1
		if( !auto ){
	            _rtname(infile, outfile, "_bk2.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_bk2.imh"

                if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inbk2) ){
		   msg = "          Missing file "//inbk2//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
	strfits (inbk2, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		    if( correct )
		    {
                    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no,  
                           verify=no, show=no, update=yes)               
                    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no,  
                           verify=no, show=no, update=yes)  
		    }
                    upimgrdf(outfits)
		    if( auto )
		    {
	           catfits (inbk2, "", format_file="", log_file="foo.log", 
		   long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
		   imrename( outfits, test, verbose=no)
		   }
		}
 

# 		Create PSPC PROS hard background image - root_bk3.imh
	        _rtname(infile, inbk3, "008")
		inbk3 = s1
		if( !auto ){
	            _rtname(infile, outfile, "_bk3.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_bk3.imh"

                if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inbk3) ){
		   msg = "          Missing file "//inbk3//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
	strfits (inbk3, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		    if( correct )
		    {
                    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
                           verify=no, show=no, update=yes)               
                    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no,  
                           verify=no, show=no, update=yes)  
		    }
                    upimgrdf(outfits)

		    if( auto )
		    {
	           catfits (inbk3, "", format_file="", log_file="foo.log", 
		   long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
		   imrename( outfits, test, verbose=no)
		   }
		}

#----------------------------------------------------------------------------
#
# 		Create PSPC PROS Exposure image - root_mex.imh
#
#----------------------------------------------------------------------------
	        _rtname(infile, inmex, "009")
		inmex = s1
		if( !auto ){
	            _rtname(infile, outfile, "_mex.imh")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_mex.imh"

                if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

		if( !access(inmex) ){
		   msg = "          Missing file "//inmex//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
		{
	strfits (inmex, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
                    
		    if( correct )
		    {
		    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
                           verify=no, show=no, update=yes)               
                    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no,  
                           verify=no, show=no, update=yes)  
 
		    }
                    upimgrdf(outfits)
		    if( auto )
		    {
	           catfits (inmex, "", format_file="", log_file="foo.log", 
		   long_header=yes, short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
		   imrename( outfits, test, verbose=no)
		   }

		   #------------------------------------------------
		   # Create PSPC PROS Exposure PL file - root_mex.pl
		   #------------------------------------------------

		   if( !auto )
		   {
		      _rtname(infile, outfile, "_mex.pl")
		      outfits = s1
		      _rtname(infile, outfile, "_mexi.imh")
		      toutfits = s1
		      exp_rename = no
		   }
		   else
		   {
		      outfits = "dummy_mex.pl"
		      toutfits = "dummy_mex.imh"
		      exp_rename = yes
		   }

                   if( access(outfits) && clob ) {
                     delete(outfits, ver-, >& "dev$null")
                     imdelete(toutfits,yes,ver-,default_acti+,>&"dev$null")
		   }

	strfits (inmex, " ", toutfits, template="none", long_header=no,
	 short_header=yes, datatype="integer", blank=0., 
	 scale=no, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		   imcopy(toutfits,outfits,verbose-)

		   #----------------------------------------------------------
		   # if auto-rename is true, then get the appropriate filename 
		   # from the HISTORY record and rename the file
		   # "dummy_mex.pl" to that name
                   #----------------------------------------------------------
		   if (exp_rename)
		   {
		      temp_str=""
		      imgets (image = "dummy_mex.pl", param = "HISTORY")
		      temp_str = imgets.value 

		      idx1 = stridx("f", temp_str)

		      #---------------------------
		      # if keyword "file" is found
		      #---------------------------
		      if (substr(temp_str, idx1, 4) == "file")
		      {
   			  idx2 = 1
		          #------------------------------------------------
		          # skip over all whitespace between keyword "file"
			  # and the actual filename
			  #------------------------------------------------
   			  while (substr(temp_str,idx1+3+idx2,idx1+3+idx2)==" ") 
			  {
      			     idx2 = idx2 + 1
			  }

			  #-----------------------------------------------
			  # the filename is from the end of the whitespace  
			  # to the first underscore "_"
		          #-----------------------------------------------
   			  temp_str = substr(temp_str, idx1+3+idx2, 
					    stridx("_", temp_str))
   			  temp_str = temp_str // "mex.pl"
		      }

		      if (access(temp_str))
		      {
   		         if (clob)
      			    delete(temp_str, ver-, >& "dev$null")
   			 else
      			    error(1, "Clobber set to 'no' and " // temp_str // 
				     " exists")
		      }
		      rename("dummy_mex.pl", temp_str)

		   } # end if (exp_rename)
		} # end if input file exists


#----------------------------------------------------------------------------
#
# 		Create PSPC PROS spectral src table - root_sp.tab
#
#----------------------------------------------------------------------------
	        _rtname(infile, insp, "010")
		insp = s1
		if( !auto ){
	            _rtname(infile, outfile, "_sp.tab")
		    outfits = s1
	            _rtname(infile, outfile, "_sp*.tab")
		    toutfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_sp.tab"

                if( clob )
                  delete(toutfits, ver-, >& "dev$null")

		if( !access(insp) ){
		   msg = "          Missing file "//insp//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
	strfits (insp, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., scale=no, 
	 xdimtogf=no, oldirafname=auto, offset=0, force=yes)

# 		Create PSPC PROS sky table - root_sky.tab
	        _rtname(infile, insky, "011")
		insky = s1
		if( !auto ){
	            _rtname(infile, outfile, "_sky.tab")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_sky.tab"

                if( access(outfits) && clob )
                   delete(outfits, ver-, >& "dev$null")

		if( !access(insky) ){
		   msg = "          Missing file "//insky//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
	strfits (insky, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., scale=no, 
	 xdimtogf=no, oldirafname=auto, offset=0, force=yes)

# 		Create PSPC PROS master src table - root_src.tab
	        _rtname(infile, insrc, "012")
		insrc = s1
		if( !auto ){
	            _rtname(infile, outfile, "_src.tab")
		    outfits = s1
		}
		else
		    outfits = outfile//"/"//"dummy_src.tab"

                if( access(outfits) && clob )
                   delete(outfits, ver-, >& "dev$null")

		if( !access(insrc) ){
		   msg = "          Missing file "//insrc//" -- skipping"
		   print("----------------------------------------------------"
	           print ( msg )
		   print("----------------------------------------------------"
		}
	        else
	strfits (insrc, " ", outfits, template="none", long_header=no,
	 short_header=yes, datatype="default", blank=0., scale=no, 
	 xdimtogf=no, oldirafname=auto, offset=0, force=yes)

	  }
	  else
		error(1, "Unsupported instrument!")
       }

#-------------------------------------------------------------------------
# SPLIT ORBIT SECTION OF SCRIPT
#-------------------------------------------------------------------------
	if (instr == "hri")
	{
           _rtname(infile, ineph, "008")
           ineph = s1
	}

        if (instr == "pspc")
        {
           _rtname(infile, ineph, "014")
           ineph = s1
        }

	if( !access(ineph) )
	{
           msg = "          Missing file "//ineph//" -- skipping"
           print("----------------------------------------------------"
           print ( msg )
           print("----------------------------------------------------"
        }
        else
	{

#---------------
# Call "strfits"
#---------------
	strfits(ineph, "", eph_root, template="none", long_header=no,
	short_header=yes, datatype="default", blank=0.,
	scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
	
#-------------------------
# Make the orbit list file
#-------------------------
	temp_str = eph_root // "*.tab"
	files (temp_str) | sort > (orb_lst)

#--------------------------------------------------------------------------
# Get the original filename from the first intermediate tab file by calling
# "keypar".  The value is returned in keypar.value
#
# The filename to look in will end in "01.tab" if there is more than 
# one (1) OBS, else strfits will rename the "01.tab" to just ".tab",
# we must account for either case
#--------------------------------------------------------------------------
	temp_str = eph_root // "01.tab"
	if (access(temp_str))
	{
	   keypar(temp_str, "FILENAME", value = "")
	   outfits = keypar.value
	}
        else
        {
           temp_str = eph_root // ".tab"
           if (access(temp_str))
           {
              keypar(temp_str, "FILENAME", value = "")
              outfits = keypar.value
           }
        }


#----------------------------------------------------------------------
# Make a tab file out of the original filename.  Parse out the filename 
# prior to the underscore "_" and concat a "eph.tab" on the end.
#----------------------------------------------------------------------
	if(!auto)
	{
           _rtname(infile, outfile, "_eph.tab")
           tab_file = s1
        }
        else
	{
	   tab_file = substr(outfits, 1, stridx("_", outfits)) // "eph.tab" 
	}


	if (access(tab_file))
	{
	   if (clob)
              delete(tab_file, ver-, >& "dev$null")
	   else
	      error(1, "Clobber set to 'no' and " // tab_file // " exists")
	}

#--------------
# Call "tmerge"
#--------------
	temp_str = "@" // orb_lst
	tmerge(temp_str, tab_file, "append", allcols=yes, tbltype="row",
		allrows=100, extracol=0)
	
        msg = "Writing ephemeris output file: " // tab_file
        print(msg)

	} # end if access input file
#-------------------------------------------------
# Delete the orbit list and intermediate tab files
#-------------------------------------------------
        delete(orb_lst, ver-, >& "dev$null")

        temp_str = eph_root // "*.tab"
        delete(temp_str, ver-, >& "dev$null")

        temp_str = eph_root // "*.imh"
        imdelete(temp_str, yes, ver-, >& "dev$null")

        temp_str = eph_root // "*.hhh"
        delete(temp_str, ver-, >& "dev$null")

#----------------------------------------------------------------------------
#
#               Create PSPC PROS eventrates (evr) table - root_evr.tab
#
#----------------------------------------------------------------------------
    if( instr == "pspc")
    {
	insp = ""
        _rtname(infile, insp, "025")
        insp = s1
#       if( !auto ){
#           _rtname(infile, outfile, "_evr.tab")
#           outfits = s1
#       }
#       else
#           outfits = outfile//"/"//"dummy_evr.tab"
 
        if( !access(insp) ){
           msg = "          Missing file "//insp//" -- skipping"
           print("----------------------------------------------------"
           print ( msg )
           print("----------------------------------------------------"
        }
           else
	{
       strfits (insp, " ", evr_root//".tab", template="none", long_header=no,
          short_header=yes, datatype="default", blank=0., scale=no,
          xdimtogf=no, oldirafname=no, offset=0, force=yes)
 
#-------------------------
# Make the orbit list file
#-------------------------
            temp_str = evr_root // "*.tab"
            files (temp_str) | sort > (evr_lst)
 
#--------------------------------------------------------------------------
# Get the original filename from the first intermediate tab file by calling
# "keypar".  The value is returned in keypar.value
#
# The filename to look in will end in "01.tab" if there is more than
# one (1) OBS, else strfits will rename the "01.tab" to just ".tab",
# we must account for either case
#--------------------------------------------------------------------------
            temp_str = evr_root // "01.tab"
	    outfits = ""
            if (access(temp_str))
            {
               keypar(temp_str, "FILENAME", value = "")
               outfits = keypar.value
            }
            else
            {
               temp_str = evr_root // ".tab"
               if (access(temp_str))
               {
                  keypar(temp_str, "FILENAME", value = "")
                  outfits = keypar.value
               }
            }
           
#----------------------------------------------------------------------
# Make a tab file out of the original filename.  Parse out the filename
# prior to the underscore "_" and concat a "eph.tab" on the end.
#----------------------------------------------------------------------
            if(!auto)
            {
               _rtname(infile, outfile, "_evr.tab")
               tab_file = s1
            }
            else
            {
               tab_file = substr(outfits, 1, stridx("_", outfits)) // "evr.tab"
            }
 
 
            if (access(tab_file))
            {
               if (clob)
                  delete(tab_file, ver-, >& "dev$null")
               else
                  error(1, "Clobber set to 'no' and " // tab_file // " exists")
            }
 
#--------------
# Call "tmerge"
#--------------
            temp_str = "@" // evr_lst
            tmerge(temp_str, tab_file, "append", allcols=yes, tbltype="row",
                allrows=100, extracol=0)

            msg = "Writing eventrate output file: " // tab_file
            print(msg)

#-------------------------------------------------
# Delete the orbit list and intermediate tab files
#-------------------------------------------------
            delete(evr_lst, ver-, >& "dev$null")

            temp_str = evr_root // "*.tab"
            delete(temp_str, ver-, >& "dev$null")

            temp_str = evr_root // "*.imh"
            imdelete(temp_str, yes, ver-, >& "dev$null")
 
        } # end if access input file

    } # end if pspc (evr file) 
#----------------------------------------------------------------------------
#
#               Create PSPC PROS aspect quality (qlt) table - root_qlt.tab
#
#----------------------------------------------------------------------------
    if( instr == "pspc")
    {
	insp = ""
       _rtname(infile, insp, "018")
        insp = s1
#       if( !auto )
#           _rtname(infile, outfile, "_qlt.tab")
#	else
#	   _rtname(insp, outfile, "qlt.tab")
#        outfits = s1
#       }
#       else
#           outfits = outfile//"/"//"dummy_qlt.tab"
 
        if( !access(insp) ){
           msg = "          Missing file "//insp//" -- skipping"
           print("----------------------------------------------------"
           print ( msg )
           print("----------------------------------------------------"
        }
        else
	{
     strfits (insp, " ", qlt_root//".tab", template="none", long_header=no,
       short_header=yes, datatype="default", blank=0., scale=no,
       xdimtogf=no, oldirafname=no, offset=0, force=yes)
#-------------------------
# Make the orbit list file
#-------------------------
            temp_str = qlt_root // "*.tab"
            files (temp_str) | sort > (qlt_lst)
 
#--------------------------------------------------------------------------
# Get the original filename from the first intermediate tab file by calling
# "keypar".  The value is returned in keypar.value
#
# The filename to look in will end in "01.tab" if there is more than
# one (1) OBS, else strfits will rename the "01.tab" to just ".tab",
# we must account for either case
#--------------------------------------------------------------------------
            temp_str = qlt_root // "01.tab"
            outfits = ""
            if (access(temp_str))
            {
               keypar(temp_str, "FILENAME", value = "")
               outfits = keypar.value
            }
            else
            {
               temp_str = qlt_root // ".tab"
               if (access(temp_str))
               {
                  keypar(temp_str, "FILENAME", value = "")
                  outfits = keypar.value
               }
            }
 
#----------------------------------------------------------------------
# Make a tab file out of the original filename.  Parse out the filename
# prior to the underscore "_" and concat a "eph.tab" on the end.
#----------------------------------------------------------------------
            if(!auto)
            {  
               _rtname(infile, outfile, "_qlt.tab")
               tab_file = s1
            }
            else
            {
               tab_file = substr(outfits, 1, stridx("_", outfits)) // "qlt.tab"
            }
               
 
            if (access(tab_file))
            {
               if (clob)
                  delete(tab_file, ver-, >& "dev$null")
               else
                  error(1, "Clobber set to 'no' and " // tab_file // " exists")
            }
               
#--------------
# Call "tmerge"
#--------------
            temp_str = "@" // qlt_lst
            tmerge(temp_str, tab_file, "append", allcols=yes, tbltype="row",
                allrows=100, extracol=0)
 
            msg = "Writing quality output file: " // tab_file
            print(msg)
#-------------------------------------------------
# Delete the orbit list and intermediate tab files
#-------------------------------------------------
            delete(qlt_lst, ver-, >& "dev$null")

            temp_str = qlt_root // "*.tab"
            delete(temp_str, ver-, >& "dev$null")
 
            temp_str = qlt_root // "*.imh"
            imdelete(temp_str, yes, ver-, >& "dev$null")

               
	} # end (imaccess)
    } # end if pspc (qlt) file 
end
