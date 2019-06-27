# $Log: _fileinfo.cl,v $
# Revision 11.0  1997/11/06 16:36:33  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:00:27  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:22:49  prosb
#General Release 2.3.1
#
#Revision 1.1  94/05/03  15:08:30  prosb
#Initial revision
#
# $Header: /home/pros/xray/xdataio/eincdrom/RCS/_fileinfo.cl,v 11.0 1997/11/06 16:36:33 prosb Exp $
# Module:       _fileinfo
# Author:       Kathleen R. Manning
# Project:      PROS -- EINSTEIN CDROM
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
#
# Description :
#
# Used by the ECD2PROS task to create the "dataset" name, and the
# complete FITS file names that will be accessed.
#
# No error checking on the input parameters is required by this task.
# The ECD2PROS, _SPECINFO and _EINCDINFO tasks do all the necessary
# checking before this task is called
#
# Algorithm :
#
# For each "inst"/"datatype" pair, construct the "dataset" name
# (i.e. 'ipc'/'unscreened' will become 'ipcu').  Construct and return
# the main data file name (data_file), as well as the FITS extension
# identifier (ie, "xp", "xi", "f3d").  If the "aux" parameter is set,
# construct and return the names of the appropriate auxiliary data files.
#
#

procedure _fileinfo(fits_root, fits_ext, inst, datatype, aux, hour, dir)

string fits_root	{prompt="input FITS root"}
string fits_ext		{prompt="input FITS extension, (i.e. 'a', 'b', etc.)"}
string inst		{min="ipc|hri", prompt="Einstein instrument"}
string datatype		{min="event|image|slew|unscreened", prompt="Datatype"}
string hour		{prompt="Sequence hour"}
string dir		{prompt="Pathname to CD"}
bool aux                {prompt="Using auxiliary data?"}
string dataset		{"unknown", prompt="Dataset (i.e. 'ipcevt')", mode="h"}
string data_file	{"unknown", prompt="Main data file", mode="h"}
string data_ext         {"unknown", prompt="ext of main data file", mode="h"}
string tca_file		{"unknown", prompt="hrievt tcor file", mode="h"}
string exp_file		{"unknown", prompt="eoscat exposure file", mode="h"}
string bka_file		{"unknown", prompt="ipcu bkg file", mode="h"}
string bta_file		{"unknown", prompt="ipcu timing file", mode="h"}
string sda_file		{"unknown", prompt="ipcu source data file", mode="h"}
string lsa_file		{"unknown", prompt="ipcu list file", mode="h"}

begin

    # local copies of input parameters

    string c_fits_root      # FITS root
    string c_fits_ext       # FITS extension
    string c_inst           # input instrument (ipc|hri)
    string c_datatype       # input datatype (event|image|slew|unscreened)
    bool c_aux              # auxiliary flag
    string c_hour           # hour of ra (directory)
    string c_dir            # directory to CD

    # local variables
 
    string data_root        # full path name, without the

# get input parameters

    c_fits_root = fits_root
    c_fits_ext = fits_ext
    c_inst = inst
    c_datatype = datatype
    c_aux = aux
    c_hour = hour
    c_dir = dir

# initialize return parameters 

    data_ext  = "unknown"
    dataset   = "unknown"
    data_file = "unknown"
    tca_file  = "unknown"
    exp_file  = "unknown"
    bka_file  = "unknown"
    bta_file  = "unknown"
    sda_file  = "unknown"
    lsa_file  = "unknown"

    # construct root to main data file

    data_root = c_dir//"data/"//c_hour//"/"//c_fits_root

    # construct name dataset and data_ext
    # construct name of auxiliary files

    if ( "event" == c_datatype )
    {
	data_ext = "xp"

	if ( "ipc" == c_inst )
	{
	    dataset = "ipcevt"
	}
	else if ( "hri" == c_inst )
	{
	    dataset = "hrievt"
	    
	    if ( c_aux )
	    {
		tca_file = c_dir//"auxdata"//"/timecor/"//c_hour//"/"//c_fits_root//".tc"//c_fits_ext
	    }
	}
    }
    else if ( "image" == c_datatype )
    {
	data_ext = "xi"
	if ( "ipc" == c_inst )
	{
	    dataset = "eoscat"

	    if ( c_aux )
	    {
		exp_file = data_root//".re"//c_fits_ext
	    }
	}
	else if ( "hri" == c_inst )
	{
	    dataset = "hriimg"
	}
    }
    else if ( "unscreened" == c_datatype )
    {
	dataset = "ipcu"
	data_ext = "up"
	if ( c_aux )
	{
            bka_file = data_root//".bk"//c_fits_ext
            bta_file = data_root//".bt"//c_fits_ext
            sda_file = data_root//".sd"//c_fits_ext
            lsa_file = data_root//".ls"//c_fits_ext
	}	    
    }
    else if ( "slew" == c_datatype )
    {
	dataset = "slew"
	data_ext = "f3d"
    }

    # construct name of main data file

    if ( "slew" == c_datatype )
    {
	data_file = data_root//"."//data_ext
    }
    else 
    {
	data_file = data_root//"."//data_ext//c_fits_ext
    }

end
