# $Header: /home/pros/xray/xdataio/RCS/_rarc2pros0.cl,v 11.0 1997/11/06 16:36:04 prosb Exp $
# $Log: _rarc2pros0.cl,v $
# Revision 11.0  1997/11/06 16:36:04  prosb
# General Release 2.5
#
# Revision 9.2  1997/10/03 21:44:26  prosb
# JCC(10/97) - Add force to strfits.
#
# Revision 9.1  1997/02/28 21:03:11  prosb
# JCC(2/28/97) - add the package name to imcalc.
#
#Revision 9.0  1995/11/16  18:56:33  prosb
#General Release 2.4
#
#Revision 8.4  1995/10/02  19:48:20  prosb
#JCC - When clob+, imdelete *.imh for wh*_events.mt & wh*_quality.mt.
#
#Revision 8.3  1995/05/04  16:42:14  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.2  94/10/05  13:51:38  dvs
#Added new fits2qp params.
#
#Revision 8.1  94/09/07  17:43:46  janet
#jd - added imdelete to clean up intermediate file.
#
#Revision 8.0  94/06/27  15:16:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:42:46  prosb
#General Release 2.3
#
#Revision 1.2  93/12/21  14:50:19  mo
#MC	12/22/93		Fix bug that did an upimgrdf on the eni
#				file even for US data when it didn't exist
#
#Revision 1.1  93/12/16  10:03:10  mo
#Initial revision
#
#Revision 6.2  93/10/05  15:08:23  mo
#MC	10/5/93		Make sure 'clob' parameter gets passed to all
#			the tasks
#
#Revision 6.1  93/07/26  18:21:55  dennis
#Updated fits2qp calling sequences for RDF.
#
#Revision 6.0  93/05/24  16:22:37  prosb
#General Release 2.2
#
#Revision 1.7  93/05/21  18:41:00  mo
#MC	5/21/93		Add energy image for PSPC
#
#Revision 1.6  93/03/26  15:35:19  mo
#MC	3/26/93		Add support for a few more files
#
#Revision 1.5  93/03/19  11:09:10  mo
#MC	3/19/93		Add quality file support
#
#Revision 1.4  93/03/02  14:40:50  mo
#MC	3/2/93		Works as long as the EVENT FITS files exists
#
#Revision 1.3  93/01/29  16:00:33  janet
#also added the 1 to the error call  - jd.
#
#Revision 1.2  93/01/29  15:57:35  janet
#removed 'call' from in front of an error stmt.
#jd.
#
#Revision 1.1  93/01/20  09:39:55  mo
#Initial revision
#
#
#
# Module:       rarc2pros.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert ROSAT files into PROS format
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC	initial version 12/92
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
procedure rarc2pros(inpfile,instrument)
# ======================================================================

  string inpfile   	  	  {prompt="input filename [root]"}
#  string outpfile                 {".",prompt="output filename"} 
  string instrument               {min="hri|pspc", prompt="instrument"}
  bool  clobber                   {no,prompt="Okay to delete existing file?",mode="h"}
  bool sort			  {yes,prompt="Sort resulting (mpe) QPOE file?"}
  bool correct			  {yes,prompt="Correct WCS header parameters?"}
  int   qp_psize                  {2048,prompt="system page size",mode="h"}
  int   qp_blen                   {4096,prompt="system bucket len",mode="h"}


  begin

# Declare the intrinsic parameters:
 
	int US = 1
	int MPE = 2
	int UNKNOWN = 3

	string buf
	string infile			# input file suite
	string outfile			# output file suite
        string tab_file
	string instr			# instrument	
	string infits = ""		# HRI/PSPC input event file
	string inimg = ""		# HRI image file
	string inim1 = ""		# PSPC broad image file
	string inim2 = ""		# PSPC soft image file
	string inim3 = ""		# PSPC hard image file
	string ineni = ""		# PSPC energy map
	string inbk1 = ""		# PSPC broad background file
	string inbk2 = ""		# PSPC soft background file
	string inbk3 = ""		# PSPC hard background file
	string inbkg = ""		# HRI background file
	string insky = ""		# HRI/PSPC sky table
	string insrc = ""		# HRI/PSPC source table
	string inmex = ""		# PSPC exposure image
	string insp = ""		# PSPC spectral source table
	string ineph = ""		# ephemeris (orbit)data file
	string inevr = ""		# eventrates file
	string inqlt = ""		# quality file
	string outfits = ""
        string outfitimh = ""
	string toutfits = ""
	string mexoutfits = ""
	string outqp = ""
	string outpl = ""
	string toutpl = ""
	string msg = ""
        string orb_lst
        string eph_root
        string temp_str
	string key
	string equal
	string test
	bool   clob


        bool qpii
	int ftype
        int  qpp
        int  qpb
        int  qpbl
        int  qpd
        bool qpix
        string qpk
        int idx1
        int idx2 
        bool exp_rename
	bool mpe
	bool ascii
	bool lsort

	real pspcximg, pspcyimg, hriximg, hriyimg
	real scale

        qpii = yes
        qpp  = qp_psize
        qpb  = qp_blen
        qpbl = 1
        qpd  = 0
        qpix = no
#        qpk = "y x"
        qpk = ""


# make sure packages are loaded
        if ( !deftask ("fits2qp") )
          error (1, "Requires xray/xdataio to be loaded!")
        if ( !deftask ("mperfits") )
          error (1, "Requires xray/xdataio to be loaded!")
        if ( !deftask ("strfits") )
          error (1, "Requires tables or stsdas/fitsio to be loaded!")
        if ( !deftask ("qpsort") )
          error (1, "Requires xray/ximages to be loaded!")

#---------------------
# Initialize variables
#---------------------
        orb_lst = "tempbary_orb.lst"
        eph_root= "tempbary_so"
	pspcximg = 256.51666666666667D0
	pspcyimg = pspcximg
	hriximg = 256.46875D0
	hriyimg	= 256.53125D0

#---------------------------------------------------------------
# Delete the orbit list and intermediate tab files if they exist
#---------------------------------------------------------------
        delete(orb_lst, ver-, >& "dev$null")

        if (access("tempbary_so.imh"))
            imdelete("tempbary_so.imh", yes,verify=no,default_action=yes)

        temp_str = eph_root // "*.tab"
        delete(temp_str, ver-, >& "dev$null")

        temp_str = eph_root // "*.hhh"
        delete(temp_str, ver-, >& "dev$null")

        temp_str = eph_root // "*.imh"
        delete(temp_str, ver-, >& "dev$null")

        delete("dummy.qp", ver-, >& "dev$null")
        delete("dummy_mex.pl", ver-, >& "dev$null")

# Get query parameters 
	infile = inpfile	
	instr = instrument
#	auto = autoname		
#	if( !auto )
#	    outfile = outpfile
#        else
        outfile = "."
	clob = clobber

	ftype = UNKNOWN
	mpe = no
        _rtname(infile, infits, ".fits")
	infits = s1
	if( access( infits ) ) {
	    mpe = no
	    print ("assuming US data" )
	    ftype = US 
	}
	else
	{
	    infits = ""
	    if( instr == "pspc" )
               _rtname(infile, infits, "_events.tfits")
	    else
               _rtname(infile, infits, "_events.mt")
	    infits = s1
	    if( access( infits ) ) {
	        mpe = yes 
	        print ("assuming MPE data" )
		ftype = MPE
	    }
#	    else
#		error(1,"Unknown data origin for conversion")
	}

	key = ""
	test = ""
	

	if( mpe )
	{
	    ascii = yes
	    lsort = no
	}
	else
	{
	    ascii = no
	    lsort = yes
	}

#	print( "mpe=", mpe )
	if (instr == "hri") {

#		Create HRI PROS qpoe file - root.qp
	    if( mpe )
		_rtname(infile, infits, "_events.mt")
	    else
	        _rtname(infile, infits, ".fits")

		infits = s1
	        _rtname(infile, outfile, ".qp")
		outfits = s1
		outqp = "dummy.qp"

               if( !access(infits) )
		   _errmsg(infits)
                else
		{
		    fits2qp (infits, outqp, naxes=2, axlen1=8192, axlen2=8192, 
			 mpe_ascii_fits=ascii, clobber=clob, 
			 oldqpoename=no, display=1, 
			 fits_cards="xdataio$fits.cards", 
			 qpoe_cards="xdataio$qpoe.cards", 
			 ext_cards="xdataio$ext.cards", 
			 wcs_cards="xdataio$wcs.cards", 
			 old_events="EVENTS", std_events="STDEVT", 
			 rej_events="REJEVT", which_events="old", 
			 oldgti_name="GTI", allgti_name="ALLGTI", 
			 stdgti_name="STDGTI", which_gti="standard", 
			 scale=yes, key_x="x", key_y="y",
                         qp_internals=yes, qp_pagesize=qpp, qp_bucketlen=qpb, 
			 qp_blockfact=qpbl, qp_mkindex=lsort, qp_key=qpk, 
			 qp_debug=qpd)

		    if( mpe && sort)
		    {
		        msg = " Sorting file "//outqp
		        print (msg)
			qpsort (outqp,
			"", outfits, "", "position", exposure="NONE", 
		        expthresh=0., clobber=clob, display=1, 
			qp_internals=yes, qp_pagesize=qpp, qp_bucketlen=qpb,
			qp_blockfact=qpbl, qp_mkindex=yes, qp_key=qpk, 
			qp_debug=qpd)
        		delete("dummy.qp", ver-, >& "dev$null")
		    }
		    else 
		    {
			msg = "renaming QPOE file to "//outfits
			print(msg)
			rename(outqp,outfits)
#        		delete("dummy.qp", ver-, >& "dev$null")
		    }
                    upqpoerdf(outfits)
		}

# 		Create HRI PROS Image map - root_img.imh
    if( ftype == UNKNOWN )
    {
	inimg = ""
        _rtname(infile, inimg, "_img.fits")
        inimg = s1
        if( access( inimg ) ) {
            mpe = no
            ftype = US 
        }   
        else
        {   
            inimg = ""
            _rtname(infile, inimg, "_image.mt")
            inimg = s1
            if( access( inimg ) ) {
                mpe = yes
                print ("assuming MPE data" )
                ftype = MPE
            }
        }
    }  
    else
    {
	    inimg = ""
	    if( mpe )
		_rtname(infile, inimg, "_image.mt")
	    else
		_rtname(infile, inimg, "_img.fits")

		inimg = s1
    }
                _rtname(infile, outfile, "_img.imh")
    	        outfits = s1
		if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

               if( !access(inimg) )
		   _errmsg(inimg)
                else
		{
		if( mpe )
		    mperfits (inimg,
		    "", outfits, make_image=yes, long_header=no, short_header=yes, 
		    datatype="", blank=0., scale=yes, oldirafname=no, offset=0)
		else
		{
           strfits (inimg, " ", outfits, template="none", long_header=no,
	        short_header=yes, datatype="default", blank=0., 
	        scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes )
		    if( correct )
		    {
		    hedit (outfits, "CRPIX1", hriximg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    hedit (outfits, "CRPIX2", hriyimg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    }
		}
		upimgrdf(outfits)
		}
#		}

# 		Create HRI PROS backround map image - root_bkh.imh
    if( ftype == UNKNOWN )
    {
	inbkg = ""
        _rtname(infile, inbkg, "_bkg.fits")
        inbkg = s1
        if( access( inbkg ) ) {
            mpe = no
            ftype = US 
        }   
        else
        {   
	    inbkg = ""
            _rtname(infile, inbkg, "_bkg.mt")
            inbkg = s1
            if( access( inbkg ) ) {
                mpe = yes
                ftype = MPE
            }
        }
    }  
    else
    {
	    inbkg = ""
	    if( mpe )
		_rtname(infile, inbkg, "_bkg.mt")
	    else
		_rtname(infile, inbkg, "_bkg.fits")

		inbkg = s1
    }
	        _rtname(infile, outfile, "_bkg.imh")
		outfits = s1
		if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

               if( !access(inbkg) )
                   _errmsg(inbkg) 
                else
		{
		if( mpe )
		    mperfits (inbkg,
		    "", outfits, make_image=yes, long_header=no, short_header=yes, 
		    datatype="", blank=0., scale=yes, oldirafname=no, offset=0)
		else
		{
	strfits (inbkg, " ", outfits, template="none", long_header=no,
		 short_header=yes, datatype="default", blank=0., 
		 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		    if( correct )
		    {
		    hedit (outfits, "CRPIX1", hriximg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    hedit (outfits, "CRPIX2", hriyimg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    }
		}
		upimgrdf(outfits)
		}

# 		Create HRI PROS Sky Catalog Table - root_sky.tab
    if( ftype == UNKNOWN )
    {  
	insky = ""
        _rtname(infile, insky, "_sky.fits")
        insky = s1
        if( access( insky ) ) {
            mpe = no    
            ftype = US 
        }   
        else
        {   
	    insky = ""
            _rtname(infile, insky, "_sky.mt")
            insky = s1 
            if( access( insky ) ) {
                mpe = yes   
                ftype = MPE
            }
        }   
    } 	    
    else
    {
	    insky = ""
	    if( mpe )
		_rtname(infile, insky, "_sky.mt")
	    else
		_rtname(infile, insky, "_sky.fits")

		insky = s1
    }
	    _rtname(infile, outfile, "_sky.tab")
	    outfits = s1
	    if( access(outfits) && clob )
              delete(outfits, ver-, >& "dev$null")

            if( !access(insky) )
                   _errmsg(insky) 
            else
	strfits (insky, " ", outfits, template="none", long_header=no, 
	     short_header=yes, datatype="default", blank=0., scale=no, 
             xdimtogf=no, oldirafname=no, offset=0, force=yes )

#### Start eventrates
    if( ftype == UNKNOWN )
    {  
        inevr = ""
        _rtname(infile, inevr, ".evr")
        inevr = s1
        if( access( inevr ) ) {
            mpe = no   
            ftype = US 
        }   
        else
        {   
            inevr = ""
            _rtname(infile, inevr, "_eventrates.mt")
            inevr = s1 
            if( access( inevr ) ) {
                mpe = yes  
                ftype = MPE
            }
        }    
    }       
    else
    {   
            inevr = ""
            if( mpe )
                _rtname(infile, inevr, "_eventrates.mt")
            else
                _rtname(infile, inevr, ".evr")
            inevr = s1
    }
               _rtname(infile, outfile, "_evr.tab")
               outfits = s1
	    if( access(outfits) && clob )
              delete(outfits, ver-, >& "dev$null")
      # JCC - Added to delte *_evr.tab.imh
            outfitimh = outfits//".imh"
            if( access(outfitimh) && clob )
              imdelete(outfitimh, ver-, >& "dev$null")
 
               if( !access(inevr) )
                   _errmsg(inevr) 
                else
		{
           strfits (inevr, " ", outfits, template="none", long_header=no,
               short_header=yes, datatype="default", blank=0., scale=no,
               xdimtogf=no, oldirafname=no, offset=0, force=yes )
                   _rtname(infile, outfile, "_evr.hhh")
               	   outfits = s1
		   delete(outfits,ver-,>&"dev$null")
		}
#### End eventrates
# 		Create HRI PROS Detected Source Table - root_src.tab
	    if( mpe )
		_rtname(infile, insrc, "_src.mt")
	    else
 		_rtname(infile, insrc, "_src.fits")

	    insrc = s1
	    _rtname(infile, outfile, "_src.tab")
	    outfits = s1
	    if( access(outfits) && clob )
              delete(outfits, ver-, >& "dev$null")

            if( !access(insrc) && !mpe )
                   _errmsg(insrc) 
            else
		 if( !mpe )
         strfits (insrc," ", outfits, template="none", long_header=no, 
             short_header=yes, datatype="default", blank=0., scale=no, 
             xdimtogf=no, oldirafname=no, offset=0, force=yes )
	} # end HRI
	else  {
	  if (instr == "pspc") {
## 		Create PSPC PROS qpoe file - root.qp
#	    print("mpe=",mpe)
#	    print("infile=",infile)
#	    print("infits=",infits)
	    infits = ""
	    if ( mpe )
	        _rtname(infile, infits, "_events.tfits")
	    else
	        _rtname(infile, infits, ".fits")
	    infits = s1
	    _rtname(infile, outfile, ".qp")
	    outfits = s1

	    outqp = "dummy.qp"

#	    print("mpe=",mpe)
#	    print("infile=",infile)
#	    print("infits=",infits)
               if( !access(infits) )
                   _errmsg(infits) 
                else
                {   
                    fits2qp (infits, outqp, naxes=2, 
			 axlen1=15360, axlen2=15360,
                         mpe_ascii_fits=ascii,
                         clobber=clob,oldqpoename=no, 
                         display=1, fits_cards="xdataio$fits.cards",
                         qpoe_cards="xdataio$qpoe.cards",
                         ext_cards="xdataio$ext.cards",
                         wcs_cards="xdataio$wcs.cards",
			 old_events="EVENTS", std_events="STDEVT", 
			 rej_events="REJEVT", which_events="old", 
			 oldgti_name="GTI", allgti_name="ALLGTI", 
			 stdgti_name="STDGTI", which_gti="standard", 
                         scale=yes, key_x="x", key_y="y",
			 qp_internals=yes, qp_pagesize=qpp,
                         qp_bucketlen=qpb, qp_blockfact=qpbl,
                         qp_mkindex=lsort, qp_key=qpk, qp_debug=qpd)
 
                    if( mpe && sort )
                    {
		        msg = " Sorting file "//outqp
		        print (msg)
                        qpsort (outqp,
                        "", outfits, "", "position", exposure="NONE",
                        expthresh=0., clobber=clob, display=1, qp_internals=yes,
                        qp_pagesize=qpp, qp_bucketlen=qpb,
                        qp_blockfact=qpbl, qp_mkindex=yes, qp_key=qpk,
                        qp_debug=qpd)
        		delete("dummy.qp", ver-, >& "dev$null")
 
                    }
		    else 
		    {
#			if( auto )
#			{
			msg = "renaming QPOE file to "//outfits
			print ( msg )
			rename(outqp,outfits)
#        		delete("dummy.qp", ver-, >& "dev$null")
#		 	}	
		    }
                    upqpoerdf(outfits)
                }   
 
# 		Create PSPC PROS broad image - root_im1.imh
    if( ftype == UNKNOWN )
    {  
	inim1=""
        _rtname(infile, inim1, "_im1.fits")
        inim1 = s1
        if( access( inim1 ) ) {
            mpe = no    
            ftype = US 
        }   
        else
        {   
	    inim1=""
            _rtname(infile, inim1, "_image1.ifits")
            inim1 = s1 
            if( access( inim1 ) ) {
                mpe = yes   
                ftype = MPE
            }
        }   
    } 
    else
    {
	    inim1=""
	    if( mpe )
	        _rtname(infile, inim1, "_image1.ifits")
	    else
	        _rtname(infile, inim1, "_im1.fits")

		inim1 = s1
    }
	        _rtname(infile, outfile, "_im1.imh")
		outfits = s1
		if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

               if( !access(inim1) )
                   _errmsg(inim1) 
                else
		{
		if( mpe )
		    mperfits (inim1,
		    "", outfits, make_image=yes, long_header=no, short_header=yes, 
		    datatype="", blank=0., scale=yes, oldirafname=no, offset=0)
		else
		{
	strfits (inim1, " ", outfits, template="none", long_header=no,
	        short_header=yes, datatype="default", blank=0., 
	        scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes )
		    if( correct)
		    {
		    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no, 
			   verify=no, show=no, update=yes)	
		    }
		}
		upimgrdf(outfits)
		}

# 		Create PSPC PROS soft image - root_im2.imh
    if( ftype == UNKNOWN )
    {  
	inim2 = ""
        _rtname(infile, inim2, "_im2.fits")
        inim2 = s1
        if( access( inim2 ) ) {
            mpe = no    
            ftype = US 
        }   
        else
        {   
	    inim2 = ""
            _rtname(infile, inim2, "_image2.ifits")
            inim2 = s1 
            if( access( inim2 ) ) {
                mpe = yes   
                ftype = MPE
            }
        }   
    } 
    else
    {
	    inim2 = ""
	    if( mpe )
	        _rtname(infile, inim2, "_image2.ifits")
	    else 
	        _rtname(infile, inim2, "_im2.fits")
	    inim2 = s1
    }
	        _rtname(infile, outfile, "_im2.imh")
		outfits = s1
		if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

               if( !access(inim2) )
		   _errmsg(inim2)
                else
		{
		if( mpe )
		    mperfits (inim2,
		    "", outfits, make_image=yes, long_header=no, short_header=yes, 
		    datatype="", blank=0., scale=yes, oldirafname=no, offset=0)
		else
		{
	strfits (inim2, " ", outfits, template="none", long_header=no,
	   short_header=yes, datatype="default", blank=0., 
	   scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes )
		    if( correct)
		    {
		    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    }
		}
		upimgrdf(outfits)
		}

# 		Create PSPC PROS hard image - root_im3.imh
    if( ftype == UNKNOWN )
    {  
	inim3 = ""
        _rtname(infile, inim3, "_im3.fits")
        inim3 = s1
        if( access( inim3 ) ) {
            mpe = no    
            ftype = US 
        }   
        else
        {   
	    inim3 = ""
            _rtname(infile, inim3, "_image3.ifits")
            inim3 = s1 
            if( access( inim3 ) ) {
                mpe = yes   
                ftype = MPE
            }
        }   
    } 
    else
    {
	    inim3 = ""
	    if( mpe )
	        _rtname(infile, inim3, "_image3.ifits")
	    else
	        _rtname(infile, inim3, "_im3.fits")
	    inim3 = s1
    }
	        _rtname(infile, outfile, "_im3.imh")
		outfits = s1
		if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

               if( !access(inim3) )
                   _errmsg(inim3) 
                else
		{
		if( mpe )
		    mperfits (inim3,
		    "", outfits, make_image=yes, long_header=no, short_header=yes, 
		    datatype="", blank=0., scale=yes, oldirafname=no, offset=0)
		else
		{
	strfits (inim3, " ", outfits, template="none", long_header=no,
	       short_header=yes, datatype="default", blank=0., 
	       scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes )
		    if( correct )
		    {
		    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    }
		}
		upimgrdf(outfits)
		}


#               Create PSPC PROS ENERGY IMAGE - root_eni.imh
    if( ftype == UNKNOWN )
    { 
        ineni = ""
        _rtname(infile, ineni, "_eni.fits")
        ineni = s1
        if( access( ineni ) ) {
            mpe = no
            ftype = US
        }
        else
        {
            ineni = ""
            _rtname(infile, ineni, "_imageec.ifits")
            ineni = s1
            if( access( ineni ) ) {
                mpe = yes
                ftype = MPE
            }
        }
    }
    else
    {
            ineni = ""
            if( mpe )
                _rtname(infile, ineni, "_imageec.ifits")
            else
                _rtname(infile, ineni, "_eni.fits")
            ineni = s1
    }
                _rtname(infile, outfile, "_eni.imh")
                outfits = s1
		if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
 
               if( !access(ineni) )
		  if( mpe )
                   _errmsg(ineni) 
                else
                {
                if( mpe )
		{
                    mperfits (ineni,
                    "", outfits, make_image=yes, long_header=no, short_header=yes,
                    datatype="", blank=0., scale=yes, oldirafname=no, offset=0)
		    upimgrdf(outfits)
		 }
#                else
#                {
#           strfits (ineni, " ", outfits, template="none", long_header=no,
#            short_header=yes, datatype="default", blank=0.,
#            scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes )
# 		     if( correct )
#                   {
#                    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no,
#                           verify=no, show=no, update=yes)
#                    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no,
#                           verify=no, show=no, update=yes)
#                    }
#                }      
                }
 
# 		Create PSPC PROS Exposure image - root_mex.imh
    if( ftype == UNKNOWN )
    {  
	inmex = ""
        _rtname(infile, inmex, "_mex.fits")
        inmex = s1
        if( access( inmex ) ) {
            mpe = no    
            ftype = US 
        }   
        else
        {   
	    inmex = ""
            _rtname(infile, inmex, "_mexmap.ifits")
            inmex = s1 
            if( access( inmex ) ) {
                mpe = yes   
                ftype = MPE
            }
        }   
    } 
    else
    {
	    inmex = ""
	    if( mpe )
	        _rtname(infile, inmex, "_mexmap.ifits")
	    else
	        _rtname(infile, inmex, "_mex.fits")
		inmex = s1
    }
	        _rtname(infile, outfile, "_mex.imh")
		outfits = s1
		if( access(outfits) && clob )
                     imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")

               if( !access(inmex) )
                   _errmsg(inmex) 
                else
		{
		if( mpe )
		{
		    mperfits (inmex,
		    "", outfits, make_image=yes, long_header=no, short_header=yes, 
		    datatype="", blank=0., scale=yes, oldirafname=no, offset=0)
		    mexoutfits = outfits
		}
		else
		{
	strfits (inmex, " ", outfits, template="none", long_header=no,
	        short_header=yes, datatype="default", blank=0., 
	        scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes )
		    if( correct )
		    {
		    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no, 
			   verify=no, show=no, update=yes)		
		    }
		}
		upimgrdf(outfits)

                  #------------------------------------------------
                   # Create PSPC PROS Exposure PL file - root_mex.pl
                   #------------------------------------------------
 
                   _rtname(infile, outfile, "_mex.pl")
		   outpl = s1
                   _rtname(infile, outfile, "_mexi.imh")
		   toutpl = s1
                   exp_rename = no
#                   if( !auto )
#                   {
                      toutfits = toutpl
                      outfits = outpl
                      exp_rename = no
#                   }
#                   else
#                   {
#                      outfits = "dummy_mex.pl"
#                      exp_rename = yes
#                   }
	    if( access(outfits) && clob )
              delete(outfits, ver-, >& "dev$null")
 
#		{
		if( mpe )
		{
		    minmax (mexoutfits,
		    force=no, update=yes, verbose=yes, minval=0., 
		    maxval=0, iminval=INDEF, imaxval=INDEF, minpix="", 
		    maxpix="")
		    scale = 32767.0E0 / (minmax.maxval) 
		    if( scale != 0) 
		    {
                        buf="\""//toutfits//"\""//"="//"int("//scale//"*"//"\""//mexoutfits//"\""//")"
		        imcalc(buf,clobber=clob, zero=0., debug=0)
		    }
		    else
		    {
                     msg = "          MAXVAL in "//mexoutfits//" is zero -- skipping"
                     print("----------------------------------------------------"
                     print ( msg )
                     print("----------------------------------------------------"
		   }
#		    mperfits (inmex,
#		    "", outfits, make_image=yes, long_header=no, short_header=yes, 
#		    datatype="integer", blank=0., scale=no, oldirafname=no, offset=0)
		}
		else
		{
	strfits (inmex, " ", toutfits, template="none", long_header=no,
	       short_header=yes, datatype="integer", blank=0., 
	       scale=no, xdimtogf=no, oldirafname=no, offset=0, force=yes )
#		    if( correct )
#		    {
#		    hedit (outfits, "CRPIX1", pspcximg, add=no, delete=no, 
#			   verify=no, show=no, update=yes)		
#	 	    hedit (outfits, "CRPIX2", pspcyimg, add=no, delete=no, 
#			   verify=no, show=no, update=yes)		
#		    }
#		    imcopy(toutfits, outfits,verbose-)
		}
#		upimgrdf(outfits)
#		}
		imcopy(toutfits, outfits,verbose-)		
# jd added del (7/94)
                imdelete(toutfits,yes,ver-,default_acti+,>&"dev$null")

                   #----------------------------------------------------------
                   # if auto-rename is true, then get the appropriate filename 
                   # from the HISTORY record and rename the file
                   # "dummy_mex.pl" to that name
                   #----------------------------------------------------------
                   if (exp_rename)
		   {
		      imrename( "dummy_mex.imh" , outpl )

                   } # end if (exp_rename)
                } # end if input file exists


	if( !mpe )
	{
#----------------------------------------------------------------------------
#
#               Create PSPC PROS spectral src table - root_sp.tab
#
#----------------------------------------------------------------------------
#	        _rtname(infile, insp, "_sp.tfits")
	        _rtname(infile, insp, "_sp.fits")

		insp = s1
	        _rtname(infile, outfile, "_sp.tab")
		outfits = s1
	    if( access(outfits) && clob )
              delete(outfits, ver-, >& "dev$null")
#
               if( !access(insp) )
                   _errmsg(insp) 
                else
	strfits (insp, " ", outfits, template="none", long_header=no,
	    short_header=yes, datatype="default", blank=0., scale=no, 
	    xdimtogf=no, oldirafname=no, offset=0, force=yes )
#
#----------------------------------------------------------------------------
#
#               Create PSPC PROS src table - root_src.tab
#
#----------------------------------------------------------------------------
## 		Create PSPC PROS master src table - root_src.tab
	        _rtname(infile, insrc, "_src.fits")
		insrc = s1
#		if( !auto ){
	            _rtname(infile, outfile, "_src.tab")
		    outfits = s1
##		}
##		else
##		    outfits = "dummy_src.tab"
	    if( access(outfits) && clob )
              delete(outfits, ver-, >& "dev$null")

               if( !access(insrc) )
                   _errmsg(insrc) 
                else
	strfits (insrc, " ", outfits, template="none", long_header=no,
	     short_header=yes, datatype="default", blank=0., scale=no, 
	     xdimtogf=no, oldirafname=no, offset=0, force=yes )

#----------------------------------------------------------------------------
#
#               Create PSPC PROS sky table - root_sky.tab
#
#----------------------------------------------------------------------------
# 		Create PSPC PROS sky table - root_sky.tab
	        _rtname(infile, insky, "_sky.fits")
		insky = s1
#		if( !auto ){
	            _rtname(infile, outfile, "_sky.tab")
		    outfits = s1
##		}
##		else
# #		    outfits = "dummy_sky.tab"

	    if( access(outfits) && clob )
              delete(outfits, ver-, >& "dev$null")
               if( !access(insky) )
                   _errmsg(insky) 
                else
	strfits (insky, " ", outfits, template="none", long_header=no,
	     short_header=yes, datatype="default", blank=0., scale=no, 
	     xdimtogf=no, oldirafname=no, offset=0, force=yes )

	} # end (if !mpe)

#### Start eventrates
    if( ftype == UNKNOWN )
    {
        inevr = ""
        _rtname(infile, inevr, ".evr")
        inevr = s1
        if( access( inevr ) ) {
            mpe = no
            ftype = US
        }
        else
        {
            inevr = ""
            _rtname(infile, inevr, "_eventrates.tfits")
            inevr = s1
            if( access( inevr ) ) {
                mpe = yes
                ftype = MPE
            }
        }
    }
    else
    {
            inevr = ""
            if( mpe )
                _rtname(infile, inevr, "_eventrates.tfits")
            else
                _rtname(infile, inevr, ".evr")
            inevr = s1
    }
                _rtname(infile, outfile, "_evr.tab")
               outfits = s1
	    if( access(outfits) && clob )
              delete(outfits, ver-, >& "dev$null")
       # JCC - Added to delte *_evr.tab.imh 
            outfitimh = outfits//".imh"
            if( access(outfitimh) && clob )
              imdelete(outfitimh, ver-, >& "dev$null")

               if( !access(inevr) )
                   _errmsg(inevr) 
                else
           strfits (inevr, " ", outfits, template="none", long_header=no,
             short_header=yes, datatype="default", blank=0., scale=no,         
             xdimtogf=no, oldirafname=no, offset=0, force=yes )
#### End eventrates
 
	  }
	  else
		error(1, "Unsupported instrument!")
       }
#-------------------------------------------------------------------------
# SPLIT ORBIT SECTION OF SCRIPT
#-------------------------------------------------------------------------
    if( ftype == UNKNOWN )
    {  
	ineph = ""
        _rtname(infile, ineph, ".so")
        ineph = s1
        if( access( ineph ) ) {
            mpe = no    
            ftype = US 
        }   
        else
        {   
	    ineph = ""
	    if( instr == "pspc" )
                _rtname(infile, ineph, "_orbit.tfits")
	    else
                _rtname(infile, ineph, "_orbit.mt")
            ineph = s1 
            if( access( ineph ) ) {
                mpe = yes   
                ftype = MPE
            }
        }   
    } 
    else
    {
	ineph = ""
	if( mpe )
	   if( instr == "pspc" )
                _rtname(infile, ineph, "_orbit.tfits")
	    else
                _rtname(infile, ineph, "_orbit.mt")
        else
            _rtname(infile, ineph, ".so")
        ineph = s1
    }
 
    if( !access(ineph) )
        _errmsg(ineph) 
    else
    {

#---------------
# Call "strfits"
#---------------
        strfits(ineph, "", eph_root, template="none", long_header=no,
           short_header=yes, datatype="default", blank=0.,
           scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes )
        
	delete(eph_root//".hhh",ver-,>&"dev$null")


#----------------------------------------------------------------------
# Make a tab file out of the original filename.  Parse out the filename 
# prior to the underscore "_" and concat a "eph.tab" on the end.
#----------------------------------------------------------------------
#        if(!auto)
#        {
           _rtname(infile, outfile, "_eph.tab")
           tab_file = s1
#        }
#        else
#        {
#           tab_file = substr(outfits, 1, stridx("_", outfits)) // "eph.tab" 
#        }

	if( !mpe )
	{
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
        
	}
	else # if mpe file - just need a rename
	{
            if (access(tab_file))
            {
               if (clob)
                  delete(tab_file, ver-, >& "dev$null")
               else
                  error(1, "Clobber set to 'no' and " // tab_file // " exists")
            }
	    rename("tempbary_so.tab", tab_file)
	}
        msg = "Writing ephemeris output file: " // tab_file
        print(msg)
 
    } # end if access input file
#-------------------------------------------------
# Delete the orbit list and intermediate tab files
#-------------------------------------------------
        delete(orb_lst, ver-, >& "dev$null")
 
        if (access("tempbary_so.imh"))
            delete("tempbary_so.imh", verify=no, >& "dev$null")
        if (access("tempbary_so.hhh"))
            imdelete("tempbary_so.hhh", verify=no, >& "dev$null")

        temp_str = eph_root // "*.tab"
        delete(temp_str, ver-, >& "dev$null")
 
        temp_str = eph_root // "*.hhh"
        delete(temp_str, ver-, >& "dev$null")
 
#-------------------------------------------------------------------------
# QUALITY SECTION OF SCRIPT
#-------------------------------------------------------------------------
    if( ftype == UNKNOWN )
    {
        inqlt = ""
	if( instr == "pspc")
           _rtname(infile, inqlt, "_quality.tfits")
	else
           _rtname(infile, inqlt, "_quality.mt")
        inqlt = s1
        if( access( inqlt ) ) {
            mpe = yes
            ftype = MPE
        }
        else
        {   
            inqlt = ""
            _rtname(infile, inqlt, ".asp")
            inqlt = s1
            if( access( inqlt ) ) {
                mpe = yes
                print ("assuming MPE data" )
                ftype = MPE
            }
        }
    }
    else
    {
        inqlt = ""
        if( mpe )
	  if( instr == "pspc")
            _rtname(infile, inqlt, "_quality.tfits")
	  else
            _rtname(infile, inqlt, "_quality.mt")
	else
	    _rtname(infile, inqlt, ".asp")
	inqlt = s1

    }

                _rtname(infile, outfile, "_qlt.hhh")
               outfits = s1
	      if( access(outfits) )
                delete(outfits, ver-, >& "dev$null")
                _rtname(infile, outfile, "_qlt.tab")
               outfits = s1
	      if( access(outfits) && clob )
                delete(outfits, ver-, >& "dev$null")
      # JCC - Added to delte *_evr.tab.imh
            outfitimh = outfits//".imh"
            if( access(outfitimh) && clob )
              imdelete(outfitimh, ver-, >& "dev$null")
 
               if( !access(inqlt) )
		   _errmsg(inqlt)
                else
		{
           strfits (inqlt, " ", outfits, template="none", long_header=no,
               short_header=yes, datatype="default", blank=0., scale=no, 
               xdimtogf=no, oldirafname=no, offset=0, force=yes )
#		imdelete(outfits//".imh",yes,ver-,default_action=yes,>&"dev$null")
		}
 

  end
