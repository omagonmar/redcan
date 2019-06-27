#$Header: /home/pros/xray/xinstall/RCS/fits2edemo.cl,v 11.0 1997/11/06 16:41:00 prosb Exp $
#$Log: fits2edemo.cl,v $
#Revision 11.0  1997/11/06 16:41:00  prosb
#General Release 2.5
#
#Revision 9.1  1997/10/03 20:43:32  prosb
#No change.
#
#Revision 9.0  1995/11/16  19:27:15  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:27:05  prosb
#General Release 2.3.1
#
#Revision 1.1  94/06/15  16:08:58  janet
#Initial revision
#
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

procedure fits2edemo()

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

# Convert i5803 screened Einstein IPC data for Eincddemo
if( access("i5803.fits") ){
   efits2qp ("i5803.fits",
   "ipc", "event", "eincdromdemo$i5803.qp", clobber=no, display=1, 
   qp_internals=yes, qp_pagesize=2048, qp_bucketlen=4096, qp_mkindex=yes, 
   qp_key="", qp_debug=0, sortsize=1000000)
}

# Convert i5803 unscreened Einstein IPC data for Eincddemo
if( access("i5803u.fits") ){
   efits2qp ("i5803u.fits",
   "ipc", "unscreened", "eincdromdemo$i5803u.qp", clobber=no, display=1, 
   qp_internals=yes, qp_pagesize=2048, qp_bucketlen=4096, qp_mkindex=yes, 
   qp_key="", qp_debug=0, sortsize=1000000)
}

end
