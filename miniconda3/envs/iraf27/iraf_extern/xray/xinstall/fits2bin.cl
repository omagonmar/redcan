#$Header: /home/pros/xray/xinstall/RCS/fits2bin.cl,v 11.0 1997/11/06 16:40:59 prosb Exp $
#$Log: fits2bin.cl,v $
#Revision 11.0  1997/11/06 16:40:59  prosb
#General Release 2.5
#
#Revision 9.1  1997/10/03 21:36:00  prosb
#JCC(10/97) - Add force to strfits.
#
#Revision 9.0  1995/11/16 19:27:14  prosb
#General Release 2.4
#
#Revision 8.1  1995/05/04  18:43:24  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.0  1994/06/27  17:27:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:52:17  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  18:20:16  mo
#ADd new SRG files and stuff
#
#Revision 6.0  93/05/24  16:45:39  prosb
#General Release 2.2
#
#Revision 5.2  93/05/21  22:25:05  mo
#MC	5/21/93		Update with latest response matrices.
#
#Revision 5.1  92/12/04  16:23:35  mo
#MC	12/4/92		Added latest DRM matrix to conversion.  Also
#			made it smarter, to check for existing files
#			before attempting conversion.  Now it can be
#			run on a single additional file, without requiring
#			all the old files to be reloaded as well.
#
#Revision 5.0  92/10/29  22:41:49  prosb
#General Release 2.1
#
#Revision 4.3  92/10/16  14:26:11  mo
#MC	10/16/92		Add the compmat.ieee file
#
#Revision 4.2  92/10/08  09:31:56  mo
#MC	10/8/92		Added XLOCAL for ROSBB.
#
#Revision 4.1  92/06/16  16:56:05  mo
#MC	6/15/92		Add the 'compmat' spectral response matrix
#			to the list of file conversions
#
#Revision 4.0  92/04/27  15:25:03  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/04/24  09:17:44  jmoran
#Initial revision
#

procedure fits2bin()

begin

string ffile
string ofile
string outfile
string msg
string delim
# make sure the correct packages are loaded

# xray...
if ( defpac ("xray") )
        print "xray found"
else
        error (1, "Requires xray to be loaded!")

# xdataio...
if ( defpac ("xdataio") )
        print "xdataio found"
else
        error (1, "Requires xdataio to be loaded!")

# xlocal...
#if ( defpac ("xlocal") )
#        print "xlocal found"
#else
#        error (1, "Requires xlocal to be loaded!")
#
## rosbb...
#if ( defpac ("rosbb") )
#	print "rosbb found"
#else
#	error (1, "Requires rosbb to be loaded!")
#
# stsdas or tables...
#if ( defpac ("stsdas") ) {
#	print "stsdas found"
#	# fitsio...
#	if ( defpac ("fitsio") )
#		print "fitsio found"
#	else
#        	error (1, "Requires fitsio to be loaded!")
#} 
#else
#{
	if ( defpac ("tables") )
		print "tables found"
	else
		error (1, "Requires stsdas OR tables to be loaded!")
#}

# images...
if ( defpac ("images") )
	print "images found"
else
	error (1, "Requires images to be loaded!")

delim = "-----------------------------------------------------"

ffile = "dtmat_5.fits"
ofile = "dtmat_5.imh"
outfile = "xspectraldata$dtmat_5.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{    
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
     datatype="default", blank=0., scale=yes, xdimtogf=no, 
     oldirafname=no, offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}


ffile = "dtmat_5_4_8.fits"
ofile = "dtmat_5_4_8.imh"
outfile = "xspectraldata$dtmat_5_4_8.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{    
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
     datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
     offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "dtmat_6.fits"
ofile = "dtmat_6.imh"
outfile = "xspectraldata$dtmat_6.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{    
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
    offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "dtmat_31.fits"
ofile = "dtmat_31.imh"
outfile = "xspectraldata$dtmat_31.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{    
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
    offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "dtmat_36.fits"
ofile = "dtmat_36.imh"
outfile = "xspectraldata$dtmat_36.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{    
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
    offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "compmat.fits"
ofile = "compmat.imh"
outfile = "xspectraldata$compmat.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
    offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}


ffile = "dtmat.fits"
ofile = "dtmat.imh"
outfile = "xspectraldata$dtmat.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
    offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "hepc1_rmdat.fits"
ofile = "hepc1_rmdat.imh"
outfile = "xspectraldata$hepc1_mc.rmdat"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "lepc1_rmdat.fits"
ofile = "lepc1_rmdat.imh"
outfile = "xspectraldata$lepc1_mc.rmdat"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "egrid.fits"
ofile = "egrid.imh"
outfile = "xspectraldata$egrid.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
    offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "hepc1_egr.fits"
ofile = "hepc1_egr.imh"
outfile = "xspectraldata$hepc1_mc.egr"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "lepc1_egr.fits"
ofile = "lepc1_egr.imh"
outfile = "xspectraldata$lepc1_mc.egr"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "filter1_5.fits"
ofile = "filter1_5.imh"
outfile = "xspectraldata$filter1_5.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "filter.fits"
ofile = "filter.imh"
outfile = "xspectraldata$filter.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "filter2_5.fits"
ofile = "filter2_5.imh"
outfile = "xspectraldata$filter2_5.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "hepc1_window.fits"
ofile = "hepc1_window.imh"
outfile = "xspectraldata$hepc1.window"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "lepc1_window.fits"
ofile = "lepc1_window.imh"
outfile = "xspectraldata$lepc1.window"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}


ffile = "offar1_5.fits"
ofile = "offar1_5.imh"
outfile = "xspectraldata$offar1_5.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "offar1_6.fits"
ofile = "offar1_6.imh"
outfile = "xspectraldata$offar1_6.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "offar.fits"
ofile = "offar.imh"
outfile = "xspectraldata$offar.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "sodart1_ofa.fits"
ofile = "sodart1_ofa.imh"
outfile = "xspectraldata$sodart1.ofa"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "ros_pi_offar.fits"
ofile = "ros_pi_offar.imh"
outfile = "xspectraldata$ros_pi_offar.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "offar2_5.fits"
ofile = "offar2_5.imh"
outfile = "xspectraldata$offar2_5.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "offar2_6.fits"
ofile = "offar2_6.imh"
outfile = "xspectraldata$offar2_6.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "hri_dtmat_1.fits"
ofile = "hri_dtmat_1.imh"
outfile = "xspectraldata$hri_dtmat_1.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
  strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

#ffile = "hri_dtmat_15.fits"
#ofile = "hri_dtmat_15.imh"
#outfile = "xspectraldata$hri_dtmat_15.ieee"
#if( !access(ffile) ){
#    msg = "          Missing file "//ffile//" -- skipping"
#    print(delim)
#    print ( msg )
#    print(delim)
# }
#else
#{
# strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
#   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
#   offset=0, force=yes)
#    _im2bin (outfile,"", ofile, clobber=no, display=1)
#    imdelete (ofile, yes, verify=no, default_acti=yes)
#}


ffile = "hri_eff_area.fits"
ofile = "hri_eff_area.imh"
outfile = "xspectraldata$hri_eff_area.ieee"
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
 strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
    _im2bin (outfile,"", ofile, clobber=no, display=1)
    imdelete (ofile, yes, verify=no, default_acti=yes)
}

ffile = "particle_bkgd.fits"
ofile = "xspectraldata$particle_bkgd.tab"
outfile = ofile
if( !access(ffile) ){
    msg = "          Missing file "//ffile//" -- skipping"
    print(delim)
    print ( msg )
    print(delim)
}
else
{
 strfits (ffile, "", ofile, template="none", long_header=no, short_header=yes, 
   datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, 
   offset=0, force=yes)
}
end
