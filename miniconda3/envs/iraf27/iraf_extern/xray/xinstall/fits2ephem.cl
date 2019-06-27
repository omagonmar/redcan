#$Header: /home/pros/xray/xinstall/RCS/fits2ephem.cl,v 11.4 1998/04/24 16:13:57 prosb Exp $
#$Log: fits2ephem.cl,v $
#Revision 11.4  1998/04/24 16:13:57  prosb
#Patch Release 2.5.p1
#
#Revision 11.3  1998/02/25 19:25:01  prosb
#JCC(12/97) - add comments for hri_qegeom.
#
#Revision 11.0  1997/11/06 16:41:02  prosb
#General Release 2.5
#
#Revision 9.2  1997/10/06 16:29:19  prosb
#JCC(10/6/97)- Updated to create the ASC image file.
#
#Revision 9.1  1997/10/03 21:36:25  prosb
#JCC(10/97) - Add force to strfits.
#
#Revision 9.0  1995/11/16 19:27:18  prosb
#General Release 2.4
#
#Revision 8.4  1995/10/17  16:25:25  prosb
#JCC - Create hri_qegeom.imh from fits file.
#
#Revision 8.2  1995/09/20  16:54:07  prosb
#JCC - Updated to add a new calibration file "jdleap.tab".
#
#Revision 8.1  1995/05/04  18:42:37  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.0  1994/06/27  17:27:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:52:19  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  18:22:08  mo
#MC	update
#
#Revision 6.0  93/05/24  16:45:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:41:51  prosb
#General Release 2.1
#
#Revision 4.1  92/10/06  12:17:48  jmoran
#JMORAN         added strfits call for ein_to_utc.fits
#
#Revision 4.0  92/04/27  15:25:07  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/04/24  09:17:49  jmoran
#Initial revision
#

procedure fits2ephem()

begin
# make sure the correct packages are loaded

# stsdas or tables...
if ( defpac ("tables") ) {
	print "tables found"

} else {
    if ( defpac ("stsdas") ) {
	print "stsdas found"

	# fitsio...
	if ( defpac ("fitsio") )
        	print "fitsio found"
	else
        	error (1, "Requires fitsio to be loaded!")
    }
    else
		error (1, "Requires stsdas OR tables to be loaded!")

}
;

# xray...
if ( defpac ("xray") )
        print "xray found"
else
        error (1, "Requires xray to be loaded!")

if( !access("de200.fits") ){
    print("          Missing file de200.fits -- skipping")
}
else
{    
    strfits ("de200.fits",
    "", "xtimingdata$de200.tab", template="none", long_header=no,
    short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
    oldirafname=no, offset=0, force=yes)
}

if( !access("scc_to_utc.fits") ){
    print("          Missing file scc_to_utc.fits -- skipping")
}
else
{    
    strfits ("scc_to_utc.fits",
    "", "xtimingdata$scc_to_utc.tab", template="none", long_header=no,
    short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
    oldirafname=no, offset=0, force=yes)
}

if( !access("ein_to_utc.fits") ){
    print("          Missing file ein_to_utc.fits -- skipping")
}
else
{    
    strfits ("ein_to_utc.fits",
    "", "xtimingdata$ein_to_utc.tab", template="none", long_header=no,
    short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
    oldirafname=no, offset=0, force=yes)
}

#jcc - new calibration file "jdleap.tab"
if( !access("jdleap.fits") ){
    print("          Missing file jdleap.fits -- skipping")
}
else
{
    strfits ("jdleap.fits",
    "", "xtimingdata$jdleap.tab", template="none", long_header=no,
    short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
    oldirafname=no, offset=0, force=yes)
}

#jcc - Get hri_qegeom.imh from fits file.

if( access("xspatialdata$hri_qegeom.imh") )
   imdelete ("xspatialdata$hri_qegeom.imh",yes,verify=no,default_acti=yes)

#JCC(12/97)
#oldirafname=yes - use the IRAFNAME string in FITS header as the output 
#                  filename (ie: "hri_qegeom.imh") and put it in the 
#                  directory "xspatialdata".
strfits ("hri_qegeom.fits",
    " ","xspatialdata$dummy_img.imh",template="none",long_header=no,
    short_header=yes,datatype="default",blank=0.,scale=yes,xdimtogf=no,
    oldirafname=yes,offset=0, force=yes)
#
# JCC (10/6/97) - convert fits to image for ASC using strfits
#
strfits ("asc_hrc.fits",
" ", "xspatialdata$asc_hrc", template="none", long_header=no, short_header=yes,
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no,
offset=0, force=yes )
end
