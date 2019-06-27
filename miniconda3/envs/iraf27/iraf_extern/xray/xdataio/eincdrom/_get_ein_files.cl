# $Log: _get_ein_files.cl,v $
# Revision 11.0  1997/11/06 16:37:09  prosb
# General Release 2.5
#
# Revision 9.1  1997/10/03 21:43:06  prosb
# no change.
#
# Revision 9.0  1995/11/16 19:00:34  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:23:07  prosb
#General Release 2.3.1
#
#Revision 1.3  94/05/17  13:32:09  prosb
#krm - for efits2qp update, pass in c_inst and c_datatype instead of
#dataset.
#
#Revision 1.2  94/05/16  15:35:24  prosb
#krm - added the calc_bary keywords ALPHA_SOURCE and DELTA_SOURCE to the
#IPCU cor.tab file header.
#
#These could potentially be used by apply_bary to check distances.
#
#Revision 1.1  94/05/03  15:11:03  prosb
#Initial revision
#
# $Header: /home/pros/xray/xdataio/eincdrom/RCS/_get_ein_files.cl,v 11.0 1997/11/06 16:37:09 prosb Exp $
# Module:       _get_ein_files
# Author:       Kathleen R. Manning
# Project:      PROS -- EINSTEIN CDROM
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
#
# Description :
#
# _get_ein_files is used by the xdataio.eincdrom.ecd2pros task to retrieve
# or convert FITS files from the Einstein CD-rom archive.  The task _fileinfo
# is used to construct the names of the required FITS files.  The tasks 
# _ein_copy and _ein_strfits are used to copy or convert the files.
#
# NOTE : No error checking is performed on the input information.  The ecd2pros
# task does this work with the help of the _specinfo and ecdinfo tasks before
# invoking this task.
#
# ***** NOTE ***** There is a BUG in the TABLES 1.3.1 version of STRFITS
# related to converting internal FITS extensions > 10.  The ST code
# adds a "1" to the requested extension number for each digit other than
# the first.  This bug only effects the conversion of the individual source 
# table extensions in the IPCU source data file.  This procedure includes
# kludged code to accomodate this bug.  See code for details.
#
# ST has been notified of this bug (4/94).
#

procedure _get_ein_files(specifier, is_fits, out_root, inst, datatype, fits_root, fits_ext, hour, cd_dir)

string specifier	{prompt="input specifier"}
bool is_fits		{prompt="is specifier a FITS file name?"}
string out_root		{prompt="root name for output files"}
string inst		{min="hri|ipc", prompt="Einstein instrument"}
string datatype		{min="event|image|slew|unscreened", prompt="datatype"}
string fits_root	{prompt="root of FITS file name"}
string fits_ext		{prompt="extension of FITS file name"}
string hour		{prompt="hour of ra"}
string cd_dir		{prompt="directory path to CD"}
bool im			{yes, prompt="retrieve image data?", mode="h"}
bool aux 		{no, prompt="retrieve auxillary data?", mode="h"}
bool convert		{yes, prompt="convert FITS files to IRAF/PROS format?", mode="h"}
bool clobber            {no, prompt="okay to delete existing file?",mode="h"}
int display             {1, prompt="display level", mode="h"}
bool qp_internals       {yes, prompt="prompt for qpoe internals?", mode="h"}
int qp_pagesize         {2048, prompt="page size for qpoe file", mode="h"}
int qp_bucketlen        {4096, prompt="bucket length for qpoe file", mode="h"}
int sortsize            {1000000, prompt="bytes to alloc. per sort", mode="h"}
bool qp_mkindex         {yes, prompt="make an index on y, x", mode="h"}
string qp_key           {"",prompt="key on which to make index", mode="h"}
int qp_debug            {0, prompt="qpoe debug level", mode="h"}


begin

    # local copies of input parameters 
   
    string c_specifier		# input specifier
    bool c_is_fits		# is specifier a FITS file name?
    string c_out_root		# root name for output files
    string c_inst		# instrument type
    string c_datatype		# datatype
    string c_fits_root		# FITS root
    string c_fits_ext		# FITS extension
    string c_hour		# hour of ra
    string c_cd_dir		# pathname to CD

    # local variables, return values of _fileinfo

    string dataset		# dataset (ie, ipcevt, hrievt, etc.)
    string data_ext		# extension of main data file
    string data = ""		# _fileinfo.data_file (all)
    string tca = ""            	# _fileinfo.tca_file (hrievt)
    string exp = ""            	# _fileinfo.exp_file (eoscat)
    string bka = ""            	# _fileinfo.bka_file (unscreened)
    string bta = ""            	# _fileinfo.bta_file (unscreened)
    string sda = ""            	# _fileinfo.sda_file (unscreened)
    string lsa = ""            	# _fileinfo.lsa_file (unscreened)

    # other variables
  
    string empty = ""		# empty string for _rtname call

    string usrs_tab_ver = ""    # user's tables version
    string wbug_tab_ver = "V1.3.1 - December 1993"   # version with bug

    # variables needed for IPCU data conversion

    string outfile = ""		# name of output file
    string catfile = ""		# SRCCAT file, listing of detected sources
    int n_sources = 0		# number of detected sources from SRCCAT table
    int i_source = 0		# loop invariant, individual source number
    string srcfits = ""		# FITS file name for extracting individual source
				# spectra
    int ext_obs = 0		# FITS extension of source spectra tables
    int ext_bal = 0		# FITS extension of source bal histogram
    string tab_ext = ""		# for the construction of the individual
				# source table file names

    string corfile		# time corrections file
    real ALPHA			# to be written to ipcu cor.tab file
    real DELTA			# to be written to ipcu cor.tab file

    # get input values 

    c_specifier = specifier
    c_is_fits = is_fits
    c_out_root = out_root
    c_inst = inst
    c_datatype = datatype
    c_fits_root = fits_root
    c_fits_ext = fits_ext
    c_hour = hour
    c_cd_dir = cd_dir

    if ( display > 2 )
    {
	print ("*** Running _get_ein_files ***")
 	print ("")
	print ("Input specifier is : "//c_specifier)
	print ("is_fits is : "//c_is_fits)
	print ("Output root is : "//c_out_root)
	print ("fits_root is : "//fits_root)
	print ("fits_ext is : "//fits_ext)
	print ("hour of ra is : "//c_hour)
	print ("pathname to CD is : "//c_cd_dir)
	print ("im is : "//im)
	print ("aux is : "//aux)
	print ("convert is : "//convert)
	print ("clobber is : "//clobber)
    }	

    # _fileinfo will construct dataset name and all relavent FITS file 
    # names

    _fileinfo(c_fits_root, c_fits_ext, c_inst, c_datatype, aux, c_hour, c_cd_dir)

    # get FITS file names from _fileinfo
   
    dataset  = _fileinfo.dataset
    data_ext = _fileinfo.data_ext
    data = _fileinfo.data_file
    tca =  _fileinfo.tca_file
    exp =  _fileinfo.exp_file
    bka =  _fileinfo.bka_file
    bta =  _fileinfo.bta_file
    sda =  _fileinfo.sda_file
    lsa =  _fileinfo.lsa_file

    if ( display > 2 )
    {
	print ("dataset is : "//dataset)
    }
     
    # check "im", "aux", and "dataset" for compatibility

    if ( aux && ( ("hrievt" != dataset) && ("eoscat" != dataset) && ("ipcu" != dataset)) )
    {
	print ("")
	print ("Warning, there is no auxiliary data availlable for the "//inst//"/"//c_datatype//" dataset!")
	print ("")
	aux = no

	if ( ! im )
	{
	    print ("No action performed.")
	}
    }

    # get root name for output files

# ***** *
#  We use rtname to combine the input specifier and the output
#  root.  In the special case that the user input a fits identifier
#  (ie. i0987n23.xpa) and specified a null ("") for the output root,
#  _rtname will NOT strip off the extension (ie. ".xpa") from the
#  input specifier.  We need to do this so that if we are converting 
#  to IRAF/PROS files, we can tack on the one letter extension 
#  (ie. the "a") that will make the output root unique (ie. i0987n23a). 
# ******

    if ( (c_is_fits) && ("" == c_out_root) )
    {
	c_out_root = c_fits_root
    }
    else 
    {
        _rtname(c_specifier, c_out_root, empty)
        c_out_root = s1
    }

    # if convert = "no", we'll copy

    if ( ! convert )
    {
	if ( im )			
	{
	    if ( "slew" == dataset )
	    {
		_ein_copy(data, c_out_root, data_ext, empty, clobber=clobber, display=display)
	    }
	    else 
	    {
		_ein_copy(data, c_out_root, data_ext, c_fits_ext, clobber=clobber, display=display)
	    }

	}
	if ( aux )
	{

	    if ( "hrievt" == dataset ) 
	    {
		_ein_copy(tca, c_out_root, "tc", c_fits_ext, clobber=clobber, display=display)
	    }
	    else if ( "eoscat" == dataset )
	    {
		 _ein_copy(exp, c_out_root, "re", c_fits_ext, clobber=clobber, display=display)
	    }
	    else if ( "ipcu" == dataset )
	    {
		_ein_copy(bka, c_out_root, "bk", c_fits_ext, clobber=clobber, display=display)
		_ein_copy(bta, c_out_root, "bt", c_fits_ext, clobber=clobber, display=display)
		_ein_copy(sda, c_out_root, "sd", c_fits_ext, clobber=clobber, display=display)
		_ein_copy(lsa, c_out_root, "ls", c_fits_ext, clobber=clobber, display=display)
	    }
	}
		
    }

    else         	# convert files 
    {
	# if out_root was derived from a FITS file name, tack on FITS
	# extension so we have a unique identifier 
	# (except for slew, which is always unique)

     	if ( is_fits && ("slew" != dataset) )
	{
	    c_out_root = c_out_root//c_fits_ext
	}

	if ( im )	
	{
	    # call efits2qp for ipcevt, hrievt, slew and ipcu data

	    if ( ("ipcevt" == dataset) || ("hrievt" == dataset) || ("slew" == dataset ) || ("ipcu" == dataset) )
	    {
	    	_rtname(c_out_root, empty, ".qp")
		outfile = s1

		if ( display > 1 )
		{
		    print ("Outfile is : "//outfile)
		}

		efits2qp(data, c_inst, c_datatype, outfile, clobber=clobber, 
		   display=display, qp_internals=qp_internals, 
		   qp_pagesize=qp_pagesize, qp_bucketlen=qp_bucketlen,
		   sortsize=sortsize, qp_mkindex=qp_mkindex, qp_key=qp_key,
		   qp_debug=qp_debug)
	    }

	    # call strfits for image data (eoscat and hriimg)

	    else if ("image" == datatype )
	    {
		# for eoscat, there are two extensions in the main FITS file

		if ( "eoscat" == dataset )
		{
		    _ein_strfits(data//"[0]", c_out_root, ".imh", clobber=clobber, display=display)
		}
		else 
		{
		    _ein_strfits(data, c_out_root, ".imh", clobber=clobber, display=display)
		}
	    }
	}

	if ( aux )
	{

	# Note, it may seem like we have duplicated code for the 
	# hrievt "tca" file and the ipcu "lsa" file, when in fact
	# the roots could be different from the convert- case

	    if ( "hrievt" == dataset )
	    {
		_ein_copy(tca, c_out_root, "tc", c_fits_ext, clobber=clobber, display=display)
	    }		

	    else if ( "eoscat" == dataset ) 
	    {
		# get source table 

		_ein_strfits(data//"[1]", c_out_root, "_src.tab", clobber=clobber, display=display)
		
		# get exposure file 

		 _ein_strfits(exp, c_out_root, "_exp.imh", clobber=clobber, display=display)
	    }

	    else if ( "ipcu" == dataset )
	    {
		# OBS table from main data file

		_ein_strfits(data//"[1]", c_out_root, "OBS.tab", clobber=clobber, display=display)
             
		# BKGround factors table file

		_ein_strfits(bka//"[1]", c_out_root, "BKWCS.tab", clobber=clobber, display=display)
		
		# TIMCOR table file

		_ein_strfits(bta//"[1]", c_out_root, "_cor.tab", clobber=clobber, display=display)

		# edit the table file header to contain the calc_bary
		# header words ALPHA_SOURCE & DELTA_SOURCE.  These could
	 	# potentially be used by the apply_bary task.

		corfile = s2

		keypar(input=corfile, keyword="RA_NOM", value="", mode="al")
		ALPHA = real(keypar.value)/15.
		
		keypar(input=corfile, keyword="DEC_NOM", value="", mode="al")
		DELTA = real(keypar.value)

		parkey(value=ALPHA, output=corfile, keyword="ALPHA_SOURCE", add=yes, mode="al")
		parkey(value=DELTA, output=corfile, keyword="DELTA_SOURCE", add=yes, mode="al")

		# Ascii LIST file (".out" file)
			
                _ein_copy(lsa, c_out_root, "ls", c_fits_ext, clobber=clobber, display=display)
		
		# SRCCAT table file

		_ein_strfits(sda//"[1]", c_out_root, "CAT.tab", clobber=clobber, display=display)

		# get name of SRCCAT file, so we can extract the number of
		# sources from it later.  _ein_strfits writes this name to s2

		catfile = s2

		# EINDET table file
		
		_ein_strfits(sda//"[2]", c_out_root, "DET.tab", clobber=clobber, display=display)

		# EINCTS table file		

		_ein_strfits(sda//"[3]", c_out_root, "CTS.tab", clobber=clobber, display=display)

		# EINCPTS table file

		_ein_strfits(sda//"[4]", c_out_root, "CPTS.tab", clobber=clobber, display=display

		# EINVAR table file

		_ein_strfits(sda//"[5]", c_out_root, "VAR.tab", clobber=clobber, display=display)

                # get the number of sources from the SRCCAT table

                tinfo (catfile, ttout=no)
                n_sources = tinfo.nrows
	
	   	# get user's version of TABLES

		usrs_tab_ver = tables.version

		# Now loop through the individual source tables.
		# Note we have to kludge the FITS extension number
		# for TABLES 1.3.1.  We take advantage that all
		# of the "obs.tab" files are even numbered exts,
		# and the "bal.tab" files are odd numbered exts.
		# This code also assumes that there is no extension
		# > 999.
		
		i_source = 1
		while ( i_source <= n_sources )
		{
        	    # get source spectrum table

		    tab_ext = "src"//i_source//"_obs.tab"
		    ext_obs = 2*i_source + 4

		    if ( usrs_tab_ver != wbug_tab_ver )
		    {
			srcfits = sda//"["//ext_obs//"]"
		    }

	# ********* begin kludge
		    else 
		    {
			if ( ext_obs <= 8 ) 
			{
			    srcfits = sda//"["//ext_obs//"]"
			}
		    	else if ( 10 == ext_obs) 
		    	{ 
			    srcfits = sda//"[09]"
		    	}
			else if ( (ext_obs >= 12) && (ext_obs <= 98) )
			{
			    ext_obs = ext_obs - 1
			    srcfits = sda//"["//ext_obs//"]"
			} 
		        else if ( 100 == ext_obs ) 
			{
			    srcfits = sda//"[098]"
			}
			else 
		 	{
			    ext_obs = ext_obs - 2
			    srcfits = sda//"["//ext_obs//"]"
			}
		    }
	#********** end kludge

		    _ein_strfits(srcfits, c_out_root, tab_ext, clobber=clobber, display=display)

		    # get the source bal histo table
			
		    tab_ext = "src"//i_source//"_bal.tab"
		    ext_bal = 2*i_source + 5  

		    if ( usrs_tab_ver != wbug_tab_ver )
		    {
			srcfits = sda//"["//ext_bal//"]"
		    }

	#********** begin kludge
		    else 
		    {
			if ( ext_bal <= 9 )
			{
			    srcfits = sda//"["//ext_bal//"]"
			}
		    	else if ( (ext_bal >= 11) && (ext_bal <= 99) ) 
		    	{			
			    ext_bal = ext_bal - 1
			    srcfits = sda//"["//ext_bal//"]"
		    	}
			else if ( 101 == ext_bal ) 
			{
			    srcfits = sda//"[099]"
			}
			else 
			{
			    ext_bal = ext_bal - 2
			    srcfits = sda//"["//ext_bal//"]"
			}
		    }
	#********** end kludge

		    _ein_strfits(srcfits, c_out_root, tab_ext, clobber=clobber, display=display
		    i_source += 1
	   	}
	    }
 	}								
    }				
		
end
