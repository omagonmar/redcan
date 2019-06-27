#$Header: /home/pros/xray/xinstall/RCS/fits2snr.cl,v 11.0 1997/11/06 16:41:02 prosb Exp $
#$Log: fits2snr.cl,v $
#Revision 11.0  1997/11/06 16:41:02  prosb
#General Release 2.5
#
#Revision 9.1  1997/10/03 21:36:41  prosb
#JCC(10/97) - Add force to strfits.
#
#Revision 9.0  1995/11/16 19:27:19  prosb
#General Release 2.4
#
#Revision 8.2  1995/05/04  18:42:05  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.1  1994/10/05  14:24:27  dvs
#Added new fits2qp params.
#
#Revision 8.0  94/06/27  17:27:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:52:22  prosb
#General Release 2.3
#
#Revision 6.1  93/07/26  18:25:29  dennis
#Updated fits2qp calling sequences for RDF.
#
#Revision 6.0  93/05/24  16:45:45  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:41:53  prosb
#General Release 2.1
#
#Revision 4.1  92/10/20  14:02:15  mo
#MC	10/20/92		Update the FITS2QP parameter
#
#Revision 4.0  92/04/27  15:25:11  prosb
#General Release 2.0:  April 1992
#
#Revision 1.3  92/04/26  18:58:33  mo
#MC	4/26/92		Remove the _exp.pl copy, since now made from FITS
#
#Revision 1.2  92/04/26  17:33:46  prosb
#no changes
#
#Revision 1.1  92/04/24  09:17:53  jmoran
#Initial revision
#

#---------------- OLD COMMENTS BEFORE THE "*.cl" WERE MOVED -----------------
#MC	4/21/92		Add the HRI SNR data file, and update for TABLES 1.2
#			calling sequences
#
#MC	3/19/92		NEW tables no longer allows using the path on the
#			dummy output filename to be transferred to the
#			IRAFNAME output file
#			So all the macros have been fixed to be executed
#			from the OUTPUT directory ( xdata$)
#
#MC	8/1/91		Release version
#
#MC	7/26/91		Update for new OBS.TAB file format, compatible with
#			FITS
#----------------------------------------------------------------------------

procedure fits2snr()

begin

# stsdas or tables...
if ( defpac ("stsdas") ) {
	print "stsdas found"

	# fitsio...
	if ( defpac ("fitsio") )
		print "fitsio found"
	else
		error (1, "Requires fitsio to be loaded!")
} else
	if ( defpac ("tables") )
		print "tables found"
	else
		error (1, "Requires stsdas OR tables to be loaded!")

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

copy ( "xrayroot$einfits/README", "README.einstein")
#copy ( "xrayroot$einfits/snr_exp.pl", "snr_exp.pl")

#the following strfits command does not work yet on  VMS ( IRAF 2.9.1 )
strfits ("xrayroot$einfits/snr_exp.fits",
"", "snr_exp.pl", template="none", long_header=no, short_header=yes, 
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
force=yes)

strfits ("xrayroot$einfits/snr_bbk.fits",
"", "snr_bbk.imh", template="none", long_header=no, short_header=yes, 
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
force=yes)

strfits ("xrayroot$einfits/snr_obs.fits",
"", "snr_obs.imh", template="none", long_header=no, short_header=yes, 
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
force=yes)

strfits ("xrayroot$einfits/iqso_obs.fits",
"", "iqso_obs.imh", template="none", long_header=no, short_header=yes,
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
force=yes)

strfits ("xrayroot$einfits/ibllac_obs.fits",
"", "ibllac_obs.imh", template="none", long_header=no, short_header=yes,
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
force=yes)

strfits ("xrayroot$einfits/mqso_obs.fits",
"", "mqso_obs.imh", template="none", long_header=no, short_header=yes,
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
force=yes)

strfits ("xrayroot$einfits/mbllac_obs.fits",
"", "mbllac_obs.imh", template="none", long_header=no, short_header=yes,
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
force=yes)

# We did this already
#strfits ("snr_obs.fits",
#"", "snr_obs.imh", template="none", long_header=no, short_header=yes,
#datatype="", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
#force=yes)

strfits ("xrayroot$einfits/snr_prd.fits",
"", "snr_prd.imh", template="none", long_header=no, short_header=yes,
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no, offset=0,
force=yes)

fits2qp ("xrayroot$einfits/snr.fits", "snr.qp", 
	naxes=0, axlen1=0, axlen2=0, mpe_ascii_fits=no, 
	clobber=no, oldqpoename=no, display=0, 
	fits_cards="xdataio$fits.cards", 
	qpoe_cards="xdataio$qpoe.cards", 
	ext_cards="xdataio$ext.cards", 
	wcs_cards="xdataio$wcs.cards", 
	old_events="EVENTS", std_events="STDEVT", 
	rej_events="REJEVT", which_events="old", 
	oldgti_name="GTI", allgti_name="ALLGTI", 
	stdgti_name="STDGTI", which_gti="old", 
        scale=yes, key_x="x", key_y="y",
	qp_internals=no, qp_pagesize=1024, qp_bucketlen=2048, 
	qp_blockfact=1, qp_mkindex=yes, qp_key="", qp_debug=0)

fits2qp ("xrayroot$einfits/h2258n58.xpa", "h8103.qp", 
	naxes=0, axlen1=0, axlen2=0, mpe_ascii_fits=no, 
	clobber=no, oldqpoename=no, display=0, 
	fits_cards="xdataio$fits.cards", 
	qpoe_cards="xdataio$qpoe.cards", 
	ext_cards="xdataio$ext.cards", 
	wcs_cards="xdataio$wcs.cards", 
	old_events="EVENTS", std_events="STDEVT", 
	rej_events="REJEVT", which_events="old", 
	oldgti_name="GTI", allgti_name="ALLGTI", 
	stdgti_name="STDGTI", which_gti="old", 
        scale=yes, key_x="x", key_y="y",
	qp_internals=no, qp_pagesize=1024, qp_bucketlen=2048, 
	qp_blockfact=1, qp_mkindex=yes, qp_key="", qp_debug=0)

end
