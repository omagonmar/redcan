# $Header: /home/pros/xray/xdataio/RCS/xrfits.cl,v 11.0 1997/11/06 16:37:50 prosb Exp $
# $Log: xrfits.cl,v $
# Revision 11.0  1997/11/06 16:37:50  prosb
# General Release 2.5
#
# Revision 9.1  1997/10/03 21:47:18  prosb
# JCC(10/97) - Add force to strfits.
#
# Revision 9.0  1995/11/16 18:57:23  prosb
# General Release 2.4
#
#Revision 8.2  1995/05/04  16:36:22  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.1  1994/09/07  17:39:50  janet
#dvs - fixed typo in print message, removed misplaced 'with'.
#
#Revision 8.0  94/06/27  15:18:15  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/04  17:25:45  mo
#MC	5/4/94		Replace _rtname with STRIDX to just replace the
#			"." extension and not the PROS "_" extension
#
#Revision 7.0  93/12/27  18:44:20  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:00  prosb
#General Release 2.2
#
#Revision 1.1  93/05/21  18:41:24  mo
#Initial revision
#
#
# Module:       XRFITS
# Project:      PROS -- ROSAT RSDC
# Purpose:      Utility to run TABLES/STRFITS for XRAY data
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright

procedure xrfits(fitsfile,outfile,oldirafname)

 string fitsfile {prompt="input fits filename",mode="a"}
 string outfile  {prompt="Output filename",mode="a"}
 bool   oldirafname  {yes, prompt="Override output filename with internal IRAF name?",mode="a"}
 string filelist {"",prompt="file list",mode="h"}
 bool	long     {no,prompt="Print FITS header cards?",mode="h"}
 bool	short    {yes,prompt="Print short header?",mode="h"}
 string datatype {"default",min="|unsigned|short|integer|default|real|double|complex|",prompt="IRAF data type",mode="h"}
 int    blank    {0,min=0,prompt="Blank value",mode="h"}
 int    offset   {0,prompt="Tape file offset",mode="h"}
 bool   st       {no, prompt="Special ST multigroup format?",mode="h"}
 bool   scale    {yes, prompt="Scale image data?",mode="h"}
#

begin

    string ofile
    string ifile
    bool oldname
    int exti	
	print("This task produces IRAF/IMAGES (.imh) or TABLES (.tab)")
	print("*** It does NOT produce IRAF/QPOE files (.qp) - see FITS2QP")
        ifile = fitsfile
        ofile = outfile
	oldname = oldirafname

#        _rtname(ofile,"",".imh")
#       _rtname(ofile,ofile,".tab")
#        ofile = s1
	exti = stridx(".",ofile)
	if( exti > 0 )
	{
	    ofile = substr(ofile,1,exti-1) // ".imh"
	}
	else
	{
	    ofile = ofile // ".imh"
	}

	strfits (ifile,
	filelist, ofile, template="none", long_header=long, 
	short_header=short, datatype=datatype, blank=blank, scale=scale, 
	xdimtogf=st, oldirafname=oldname, offset=offset, force=yes)

end
