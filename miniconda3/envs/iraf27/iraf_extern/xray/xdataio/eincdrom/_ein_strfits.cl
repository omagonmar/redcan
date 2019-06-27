# $Log: _ein_strfits.cl,v $
# Revision 11.0  1997/11/06 16:36:32  prosb
# General Release 2.5
#
# Revision 9.1  1997/10/03 21:42:51  prosb
# JCC(10/97) - Add force to strfits.
#
# Revision 9.0  1995/11/16 19:00:26  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:22:46  prosb
#General Release 2.3.1
#
#Revision 1.1  94/05/03  15:14:14  prosb
#Initial revision
#
# $Header: /home/pros/xray/xdataio/eincdrom/RCS/_ein_strfits.cl,v 11.0 1997/11/06 16:36:32 prosb Exp $
# Module:       _ein_strfits.cl
# Author:       Kathleen R. Manning
# Project:      PROS -- EINSTEIN CDROM
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
#
# Description :
#
# Used by the _get_ein_files.cl task.
#
# This task is used to convert the input FITS file (fitsfile) using the IRAF 
# "strfits" task.  The output (".imh" or ".tab") file name, outfile, is 
# constructed from user input.  The name of this file is stored in s2, so that 
# it is accessible to the calling routine.
#
# Since "strfits" does not clobber files, the tasks "_clobname" and 
# "_fnlname" are used.
#

procedure _ein_strfits(fitsfile, out_root, out_ext)

string fitsfile		{prompt="input FITS file name"}
string out_root		{prompt="root name for output file"}
string out_ext		{prompt="extension of output file"}
bool clobber		{yes, prompt="okay to clobber output file?", mode="h"}
int display		{1, prompt="display level", mode="h"}

begin

    # local copies of input parameters

    string c_fitsfile	 	# input FITS file, to be converted
    string c_out_root		# root name for output file
    string c_out_ext		# extension of output file, ie. "_src.tab"

    # local variables
    
    string outfile = ""		# string to hold output file name
    string tempfile = ""	# temporary file name
    string empty = ""

    # get input values

    c_fitsfile = fitsfile
    c_out_root = out_root
    c_out_ext = out_ext

    if ( display > 2 )
    {
	print ("")
	print ("*** Running _ein_strfits ***")
    }

    if ( display > 0 )
    {
	print ("")
        print ("Converting FITS file : "//c_fitsfile)
        print ("")
    }

    # construct output file name and get temporary file name

    _rtname(c_out_root, empty, c_out_ext)
    outfile = s1

    if ( display > 2 )
    {
	print ("Outfile is : "//outfile)
    }
 
    _clobname(outfile, empty, clobber=clobber)
    tempfile = s1

    if ( display > 2 )
    {
	print ("Tempfile is : "//tempfile)
	print ("")
    }

    strfits(c_fitsfile, empty, tempfile, template=empty, long_header=no,
        short_header=yes, datatype="default", blank=0.,
        scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

    # strfits in TABLES 1.3.1 needs to be flushed!

    flpr strfits

    # rename tempfile to output file name

    _fnlname(tempfile, outfile)

    # return output file name

    s2 = outfile

end
