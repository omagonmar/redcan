# $Header: /home/pros/xray/xinstall/RCS/fits2spat.cl,v 11.0 1997/11/06 16:41:03 prosb Exp $
# $Log: fits2spat.cl,v $
# Revision 11.0  1997/11/06 16:41:03  prosb
# General Release 2.5
#
# Revision 9.3  1997/10/03 21:37:02  prosb
# JCC(10/97) - Add force to strfits.
#
# Revision 9.2  1995/12/13 17:09:11  prosb
# JCC - Change "hdummy.qp" to "xspatialdata$hdummy.qp".
#       And call "datarep" at the end of the code.
#
#Revision 9.0  95/11/16  19:27:21  prosb
#General Release 2.4
#
#Revision 8.2  1995/11/03  15:56:06  prosb
#JCC - Updated to convert hdummy.fits to hdummy.qp.
#
#Revision 8.1  1995/05/04  18:41:37  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.0  1994/06/27  17:27:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:52:24  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  18:21:25  mo
#MC	Update with now 2.3 files
#
#Revision 6.0  93/05/24  16:45:49  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:41:56  prosb
#General Release 2.1
#
#Revision 4.1  92/10/16  14:26:56  mo
#MC		add the detect tables
#
#
#
# Module:       FITS2SPAT.CL
# Project:      PROS -- ROSAT RSDC
# Purpose:      Install the PROS spatial calibration files
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>    
#               {n} <who> -- <does what> -- <when>
#
# make sure the correct packages are loaded

procedure fits2spat()

begin


# stsdas or tables...
if ( defpac ("tables") ) 
        print "tables found"
else
        error (1, "Requires tables to be loaded!")

# xray...
if ( defpac ("xray") )
        print "xray found"
else
        error (1, "Requires xray to be loaded!")

if ( defpac ("xdataio") )
                print ("xdataio found")
else
{
                error (1, "Requires xdataio to be loaded!")
}
;

    if( access("einvignfits.fits") ){
	    strfits ("einvignfits.fits",
	"", "xspatialdata$einvignfits.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }
	
    if( access("prfcoeffs.fits") ){
	strfits ("prfcoeffs.fits",
	"", "xspatialdata$prfcoeffs.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }

    if( access("tsiqlm.fits") ){
	strfits ("tsiqlm.fits",
	"", "xdataiodata$tsiqlm.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }

#JCC - Add fits2qp :  convert hdummy.fits to xspatialdata$hdummy.qp
   if( access("hdummy.fits") ){
      fits2qp("hdummy.fits","xspatialdata$hdummy.qp",naxes=0,axlen1=0,axlen2=0,
         mpe_ascii_fi=no, clobber=yes, oldqpoename=no, display=1, 
         fits_cards="xdataio$fits.cards", qpoe_cards="xdataio$qpoe.cards", 
         ext_cards="xdataio$ext.cards", wcs_cards="xdataio$wcs.cards", 
         old_events="EVENTS", std_events="STDEVT", rej_events="REJEVT", 
         which_events="old", oldgti_name="GTI", allgti_name="ALLGTI", 
         stdgti_name="STDGTI", which_gti="standard", scale=yes,
         key_x="x", key_y="y", qp_internals=yes, qp_pagesize=2048, 
         qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=no, qp_key="", 
         qp_debug=0)
   }

#JCC - Run "datarep" at the end of the code.
    if( access("283cgapmap4.ieee") ){
	datarep("283cgapmap4.ieee", "xspatialdata$283cgapmap4.ieee", 
		"gapmap.tpl", "ieee", oformat="host")
    }

end
