# $Log: _ein_copy.cl,v $
# Revision 11.0  1997/11/06 16:36:30  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:00:24  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:22:42  prosb
#General Release 2.3.1
#
#Revision 1.3  94/05/20  13:44:43  prosb
#krm - replaced "copy" call with a call to "_cp_wo_attr".  This
#is to avoid the IRAF 2.10.2 bug.  It has been fixed in 2.10.3, 
#but this version has not yet been released to the world.
#
#Revision 1.2  94/05/19  11:18:01  prosb
#krm - STDOUT message for IPCU "lsa" file and HRIEVT "tca" file
#so that it is clear that these files are ascii, as opposed to
#FITS.
#
#Revision 1.1  94/05/03  15:12:54  prosb
#Initial revision
#
# $Header: /home/pros/xray/xdataio/eincdrom/RCS/_ein_copy.cl,v 11.0 1997/11/06 16:36:30 prosb Exp $
# Module:       _ein_copy.cl
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
# This task is used to copy the input FITS file (fitsfile) using the IRAF 
# "copy" task.  The output FITS file name (outfile) is constructed from 
# user input.  The name of this file is stored in s2, so that it is 
# accessible to the calling routine.
#
# Since "copy" does not clobber files, the tasks "_clobname" and 
# "_fnlname" are used.
#
# (5/20/94 - KRM) Replaced the "copy" calls with a call to the 
# eincdrom task _cp_wo_attr.  The current release version of 
# IRAF (2.10.2) has a bug in the copy command.  It has been 
# fixed in IRAF 2.10.3.  
#

procedure _ein_copy(fitsfile, out_root, file_ext, fits_ext)

string fitsfile		{prompt="input FITS file name"}
string out_root		{prompt="output file root"}
string file_ext		{prompt="output file extension, eg: 'tc'"}
string fits_ext		{prompt="FITS file extension, eg: 'a'"}
bool clobber		{yes, prompt="clobber output file?", mode="h"}
int display		{1, prompt="display level", mode="h"}

begin

    # local copies of input variables
   
    string c_fitsfile = ""	# input FITS file to be copied
    string c_out_root = ""      # root name of output file
    string c_file_ext = ""	# output FITS file identifier (ie, "xp")
    string c_fits_ext = ""	# extension of FITS file (ie, "a"

    # local variables

    string outfile = ""		# string to hold output file name
    string tempfile = ""	# temporary file name 
    string empty = ""		# empty string to pass to _clobname

    # get input values

    c_fitsfile = fitsfile
    c_out_root = out_root
    c_file_ext = file_ext
    c_fits_ext = fits_ext

    if ( display > 2 )
    {
	print ("")
	print ("*** Running _ein_copy ***")
    }

    if ( display > 0 )
    {
	if ( ("ls" == c_file_ext) || ("tc" == c_file_ext) ) 	
	{
	    print ("")
	    print ("Copying ascii file : "//c_fitsfile)
	}
	else 
	{
	    print ("")
            print ("Copying FITS file : "//c_fitsfile)
	}
    }

    # construct output file name and temporary file name

    outfile = c_out_root//"."//c_file_ext//c_fits_ext

    if ( display > 2 )
    {
        print ("Outfile is : "//outfile)
    }
 
    _clobname(outfile, empty, clobber=clobber)
    tempfile = s1

    if ( display > 2 )
    {
        print ("Tempfile is : "//tempfile)
    }

#    copy(c_fitsfile, tempfile, verbose=no)
    _cp_wo_attr(c_fitsfile, tempfile, clobber=clobber)

    # rename tempfile to output file name

    _fnlname(tempfile, outfile)

    if ( display > 0 )
    {
        print ("")
        print ("Writing file : "//outfile)
    }

    # return outfile name

    s2 = outfile

end
