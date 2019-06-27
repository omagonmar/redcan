# $Header: /home/pros/xray/xinstall/RCS/fits2ein.cl,v 11.0 1997/11/06 16:41:00 prosb Exp $
# $Log: fits2ein.cl,v $
# Revision 11.0  1997/11/06 16:41:00  prosb
# General Release 2.5
#
# Revision 9.1  1997/10/03 21:36:13  prosb
# JCC(10/97) - Add force to strfits.
#
# Revision 9.0  1995/11/16 19:27:17  prosb
# General Release 2.4
#
#Revision 8.1  1995/05/04  18:43:03  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits
#
#Revision 8.0  1994/06/27  17:27:07  prosb
#General Release 2.3.1
#
#Revision 1.1  94/06/15  16:07:20  janet
#Initial revision
#
#
# Module:       FITS2EIN.CL
# Project:      PROS -- ROSAT RSDC
# Purpose:      Install the PROS Einstein cd-rom lookup files
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>    
#               {n} <who> -- <does what> -- <when>
#
# make sure the correct packages are loaded

procedure fits2ein()

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

    if( access("eoscat_info.fits") ){
	    strfits ("eoscat_info.fits",
	"", "eincdromdata$eoscat_info.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }
	
    if( access("hrievt_info.fits") ){
	    strfits ("hrievt_info.fits",
	"", "eincdromdata$hrievt_info.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }

    if( access("hriimg_info.fits") ){
	    strfits ("hriimg_info.fits",
	"", "eincdromdata$hriimg_info.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }

    if( access("ipcevt_info.fits") ){
	    strfits ("ipcevt_info.fits",
	"", "eincdromdata$ipcevt_info.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }

    if( access("ipcu_info.fits") ){
	    strfits ("ipcu_info.fits",
	"", "eincdromdata$ipcu_info.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }

    if( access("slew_info.fits") ){
	    strfits ("slew_info.fits",
	"", "eincdromdata$slew_info.tab", template="none", long_header=no,
	short_header=yes, datatype="default", blank=0., scale=yes, xdimtogf=no,
	oldirafname=no, offset=0, force=yes)
    }

end
