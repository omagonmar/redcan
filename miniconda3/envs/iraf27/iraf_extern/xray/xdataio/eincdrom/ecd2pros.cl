# $Log: ecd2pros.cl,v $
# Revision 11.0  1997/11/06 16:36:36  prosb
# General Release 2.5
#
# Revision 9.1  1997/10/03 21:43:18  prosb
# no change.
#
# Revision 9.0  1995/11/16 19:00:43  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:23:26  prosb
#General Release 2.3.1
#
#Revision 1.4  94/05/06  14:35:25  prosb
#krm - moved sortsize parameter to the bottom of the list.
#
#Revision 1.3  94/05/06  11:13:18  prosb
#This time I *actually* moved outroot parameter; I had to move
#it in the procedure declaration.
#
#Revision 1.2  94/05/06  11:08:40  prosb
#Moved outroot parameter after inst & datatype parameters, since
#this is the order in which they are read.
#
#Revision 1.1  94/05/03  15:15:15  prosb
#Initial revision
#
# $Header: /home/pros/xray/xdataio/eincdrom/RCS/ecd2pros.cl,v 11.0 1997/11/06 16:36:36 prosb Exp $
# Module:       ecd2pros.cl
# Author: 	Kathleen R. Manning
# Project:      PROS -- EINSTEIN CDROM
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
#
# Purpose :   	To copy or convert FITS files from the Einstein Data Archive
#		on CD-rom.  
#
# Description :	This task is used to access and convert data from the Einstein
#		Data Archive on CD-rom.  The task will either : (1) copy the
#		FITS files for the desired observation to a specified location
#		or (2) convert the FITS files to the appropriate IRAF/PROS
#		files.  
#
#		The FITS files availlable to the user for copy or conversion 
#		are as follows :
#
#		Dataset 		Files
#
#		IPCEVT			main data file (".xpa")
#		
#		HRIEVT			main data file (".xpa")
#					time corrections file (".tca")
#		
#		EOSCAT			main data file (".xia")
#					detected source table file (ext of ".xia")
#					exposure image file (".rea")
#
#		HRIIMG			main data file (".xia")
#					
#		SLEW			main data file (".f3d")
#
#		IPCU 			main data file (".upa")
#					OBS table file (ext of ".upa")
#					background factors file (".bka")
#					time corrections file (".bta")
#					source data file (".sda")
#					output file from std processing (".lsa")
#
# Algorithm : 	The user inputs a specifier of the form sequence number,
#		FITS file name, or a file containing a list of specifiers.
#		The _specinfo and ecdinfo tasks are used to parse the
#		input specifier, and the user is prompted for instrument,
#		datatype, and output root as required.  The _get_ein_files 
#		task does all the work of copying and converting files for 
#		a single input specifier.
#
#		The two cases to consider are : (1) the user input a single
#		specifier, or (2) the user input a list of specifiers.
#
#		In the first case, the input values are parsed and checked
#		for validity.  The user is then prompted for an output
#		root name.  All relevant info is passed to _get_ein_files
#		for processing.
#
#		In the second case, the user is prompted for an instrument
#		and datatype, and is constrained to these values for all
#		of the specifiers in the list.  All output files are written
#		to ".", and the item specifier is used to construct the output 
#		file names.
#
#		Each item in the list is treated separately, checked for
#		validity, and passed along to _get_ein_files for processing.
#
#		The script will skip a list item for the following
#		reasons :
#			1. the specifier's inst does not match input value
#			2. the specifier's datatype does not match input value
#			3. the specifier is not valid.
#			4. the required FITS file could not be accessed
#
#		example : ecd2pros "9004" "/pool1/krm/" "ipc" "image" aux+ convert-
#

procedure ecd2pros(specifier, inst, datatype, outroot)

# input parameters

string specifier 	{prompt="input FITS file name OR sequence number"}
string inst		{min="hri|ipc", prompt="Einstein instrument"}
string datatype		{min="event|image|slew|unscreened", prompt="datatype of FITS file"}
string outroot		{".", prompt="root name for output files"}
bool im			{yes, prompt="retrieve main data file?", mode="h"}
bool aux 		{no, prompt="retrieve auxiliary data files?", mode="h"}
bool convert		{yes, prompt="convert FITS files to IRAF/PROS format?", mode="h"}
bool clobber		{no, prompt="okay to delete existing files?",mode="h"}
int display		{1, prompt="display level", mode="h"}
bool qp_internals       {yes, prompt="prompt for qpoe internals?", mode="h"}
int qp_pagesize         {2048, prompt="page size for qpoe file", mode="h"}
int qp_bucketlen        {4096, prompt="bucket length for qpoe file", mode="h"}
bool qp_mkindex         {yes, prompt="make an index on y, x", mode="h"}
string qp_key           {"",prompt="key on which to make index", mode="h"}
int qp_debug            {0, prompt="qpoe debug level", mode="h"}
int sortsize            {1000000, prompt="bytes to alloc. per sort", mode="h"}
struct *inlist		{"", prompt="pointer to input list", mode="h"}

begin

    # local copies of input variables 

    string c_specifier		# local copy of parameter input specifier
    string c_outroot		# local copy of parameter output root
    string c_inst		# local copy of parameter instrument type
    string c_datatype		# local copy of parameter datatype

    # other parameters

    bool valid = "" 		# is specifier valid?
    bool is_fits = ""           # is specifier a FITS file name?
    bool is_list  = ""		# is specifier a list?
    string spec_inst = ""      	# instrument type of list item
    string spec_type = ""	# datatype of list item
    int ecdinfo_disp = 0        # display value to pass to ecdinfo

    # ecdinfo values to pass to _get_ein_files

    string fits_root		# root of FITS file name
    string fits_ext		# extenstion of FITS file name
    string hour			# hour of ra
    string cd_dir		# directory path to cd

    # check that required tasks are accessible

    if ( ! deftask ("efits2qp") )
    {
	beep
	error (1, "Requires xray.xdataio to be loaded!")
    }
    if ( ! deftask ("xrfits") )
    {
	beep
	error (1, "Requires xray.xdataio to be loaded!")
    }
    if ( ! deftask ("strfits") )
    {
	beep 
	error (1, "Requires tables.fitsio to be loaded!")
    }

    # get input specifier 

    c_specifier = specifier

    # make sure we have a valid specifier 

    _specinfo(c_specifier)
    valid = _specinfo.is_valid

    if ( display > 2 )
    {
	print ("")
	print ("Input specifier is : "//c_specifier)
	ecdinfo_disp = 1
    }

    if ( ! valid )
    {
	beep
	bye
    }    
    else
    {
        # check to see if we have a list of identifiers

	is_list = _specinfo.is_list

    	if ( display > 2 )
	{
	    print ("is_list is : "//is_list)
  	}

        if ( ! is_list )	 		# single identifier
	{
	    inlist = ""

	    # get _specinfo return values

	    c_inst = _specinfo.inst
	    c_datatype = _specinfo.datatype
	    is_fits = _specinfo.is_fits

	    # prompt for "inst" and "datatype" if we need to

	    if ( "unknown" == c_inst )
	    {
		c_inst = inst
	    }
            if ( "unknown" == c_datatype )
	    {
		c_datatype = datatype 
	    }

	    if ( display > 2 )
	    {
	 	print ("")
		print ("instrument is : "//c_inst)
		print ("datatype is : "//c_datatype)
		print ("")
		print ("*** Calling ecdinfo ***")
	    }

	    # if ecdinfo says it's valid, we are ready to roll
	    
	    ecdinfo(c_specifier, c_inst, c_datatype, display=ecdinfo_disp)

	    valid = ecdinfo.is_valid
	   
	    if ( ! valid ) 
	    {
		beep
		error(1, "Input values determined invalid by ecdinfo!")
	    }
	    else 
	    {
		fits_root = ecdinfo.fits_root
		fits_ext = ecdinfo.fits_ext
		hour = ecdinfo.hour
		cd_dir = ecdinfo.dir
		c_outroot = outroot

	   	if ( display > 2 )
		{
		    print ("Output root is : "//c_outroot)
		    print ("")
 		}

		# if we have a sequence number, make sure it's complete

		if ( ! is_fits )
		{
		    c_specifier = ecdinfo.seq
		}

		# _get_ein_files does all the work!
		
		_get_ein_files( c_specifier, is_fits, c_outroot, c_inst, 
		   c_datatype, fits_root, fits_ext, hour, cd_dir, im=im, 
		   aux=aux, convert=convert, clobber=clobber, display=display,
		   qp_internals=qp_internals, qp_pagesize=qp_pagesize, 
		   qp_bucketlen=qp_bucketlen, sortsize=sortsize, 
		   qp_mkindex=qp_mkindex, qp_key=qp_key,
		   qp_debug=qp_debug)
	    }
	}
	else				# we have a list of identifiers
	{
	    # get input list name

	    inlist = _specinfo.filename

	    if ( display > 2 )
	    {
		print ("Input list file is : "//_specinfo.filename)
		print ("")
	    }

	    # prompt for inst and datatype, and set outroot
	    # all items in the list will be extracted from the 
	    # same CD, and all output files will go to the CWD

	    c_inst = inst
	    c_datatype = datatype
	    c_outroot = "."

            if ( display > 2 )
            {
		print ("")
                print ("instrument is : "//c_inst)
                print ("datatype is : "//c_datatype)
                print ("")
            }

	    # process each specifier in the list

	    while ( fscan(inlist, s2) != EOF )
	    {
		c_specifier = s2

		print ("")
		print ("### Working on list item : "//c_specifier)

		# check out this specifier

		_specinfo(c_specifier)

           	is_fits = _specinfo.is_fits
		spec_inst = _specinfo.inst
		spec_type = _specinfo.datatype

		# check that the inst and datatype for this specifier
		# matches the input values

		if ((spec_inst != c_inst) && (spec_inst != "unknown")) 
		{
		    print("Warning : list item "//c_specifier//" does not match input 'inst'!")
		    print("Skipping this item.")
		    valid = no
		}
		else if ((spec_type != c_datatype) && (spec_type != "unknown"))
		{
		    print("Warning : list item "//c_specifier//" does not match input 'datatype'!")
		    print("Skipping this item.")
		    valid = no
		}
		else 
		{
		    if ( display > 2 )
		    {
			print("")
			print("*** Calling ecdinfo ***")
		    }
		    ecdinfo(c_specifier, c_inst, c_datatype, display=ecdinfo_disp)

	   	    # check to see if ecdinfo liked the specifier

		    valid = ecdinfo.is_valid
		    if ( ! valid )
		    {
		    	print("Warning : list item "//c_specifier//" determined invalid by ecdinfo!")
		    	print("Skipping this item. ")
			valid = no
		    }
		    else
		    {
			# if we passed these tests, we are ready to roll

			fits_root = ecdinfo.fits_root
                	fits_ext = ecdinfo.fits_ext
                	hour = ecdinfo.hour
                	cd_dir = ecdinfo.dir

                	# if we have a sequence number, make sure it's complete

	                if ( ! is_fits )
        	        {
	                    c_specifier = ecdinfo.seq
        	        }

			# _get_ein_files does all the work!

                	_get_ein_files(c_specifier, is_fits, c_outroot, c_inst,
                   	    c_datatype, fits_root, fits_ext, hour, cd_dir, 
			   im=im, aux=aux, convert=convert, clobber=clobber,
			   display=display, qp_internals=qp_internals, 
			   qp_pagesize=qp_pagesize, qp_bucketlen=qp_bucketlen,
			   sortsize=sortsize, qp_mkindex=qp_mkindex, 
			   qp_key=qp_key, qp_debug=qp_debug)

		    }
		}
	    }
	}
	    
   }
	   
end
