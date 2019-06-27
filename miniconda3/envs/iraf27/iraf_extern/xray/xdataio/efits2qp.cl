# $Log: efits2qp.cl,v $
# Revision 11.0  1997/11/06 16:36:23  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:56:52  prosb
# General Release 2.4
#
#Revision 8.1  1994/10/05  13:51:01  dvs
#Added new fits2qp params
#
#Revision 8.0  94/06/27  15:17:16  prosb
#General Release 2.3.1
#
#Revision 1.10  94/05/17  13:23:16  prosb
#krm - deleted parameter 'dataset', and added parameters 'inst' and
#'datatype'.
#
#Revision 1.9  94/05/16  13:02:54  prosb
#krm - added qpcopy call for slew data, to screen out the y=1 events.
#
#Revision 1.8  94/05/06  14:29:35  prosb
#krm - moved sortsize parameter to the bottom of the list.
#
#Revision 1.7  94/05/06  10:54:35  prosb
#krm - 5/6/94 - for ipcu data, applied a filter of [y=2:]
#in the qpsort call.  this screens out the y=1 photons to
#avoid the iraf 2.10.2 regions bug.
#
#Revision 1.6  94/04/29  13:37:34  prosb
#krm - added standard header
#
#Revision 1.5  94/04/22  13:58:26  prosb
#krm - changed display level for input FITS file name from 1 to 0.
#
#Revision 1.4  94/04/13  17:13:07  prosb
#krm - 4/13/94 - For the IPCU case, removed the creation of the file
#"./dummy.qp".  The intermediate file is now called "root_unsrtd.qp",
#where "root" is the full "root" of the output qpoe file name.  This
#removes the restriction that the intermediate file be created in the
#current dirctory.  The file will now be written to wherever the output
#qpoe will go.
#
#Revision 1.3  94/03/17  13:48:12  prosb
#KRM - changed display level for qpsort call from 0 to 1.
#
#Revision 1.2  94/03/17  12:50:16  prosb
#KRM - Added a call to _rtname to fix a bug associated with entering 
#"" or "." for the output qpoefile name.
#
# $Header: /home/pros/xray/xdataio/RCS/efits2qp.cl,v 11.0 1997/11/06 16:36:23 prosb Exp $
# Kathleen R. Manning
# March 17, 1994

# Module:       efits2qp
# Author:       Kathleen R. Manning
# Project:      PROS -- XDATAIO
# Purpose : 	To convert an Einstein FITS file (containing BINTABLE 
#		extensions) to an IRAF/PROS QPOE file
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
#
# Input parameters :
#
#	fitsfile 	FITS filename
#	inst		Einstein instrument
#	datatype	datatype of FITS file
#	qpoefile	name of output QPOE file
#	clobber 	overwrite any existing file
#	display		debug output level (0=none)
#	qp_mkindex	make an index on y, x, set to "no" for ipcu data
# other qpoe params	qpoe parameters used by FITS2QP and QPSORT
#
# Description :
#	
#	This task converts the input FITS file to a QPOE file
#	using FITS2QP.  The "dataset" from which the FITS file was
#	derived is determined by the values of the input parameters
#	"inst" and "datatype".  For example, "inst=ipc" and "datatype=event"
#	would be considered from the "ipcevt" dataset.
#
#	The task sets the conversion parameters (such as header cards) that 
#	are appropriate to the dataset.  The task also performs some special 
#	actions :
#
#		1) For ipcevt and hrievt, run QPADDAUX to convert
#		   the tgr records to a tsi extension.
#
#		2) For ipcu data, create a temporary QPOE file
#		   "root_unsrtd.qp".  This file is then sorted by QPSORT
#		   and written to the user specified QPOE file name.
#		   "root_unsrtd.qp" is then deleted.
#
#               ***NOTE*** The QPSORT call places a filter of [y=2:]
#                  on the input qpoe file.  This removes the y=1 photons
#                  which do not occur in the screened data.  There is
#                  an IRAF (2.10.2) bug that causes the y=1 photons to be
#                  accepted by ALL applied region specifications.
#                  When the IRAF bug is fixed, this filter should be
#                  removed.
#
#		3) For slew data, the y=1 photons are screened out as 
#	 	   well (see note above). FITS2QP creates a temporary QPOE 
#		   file "root_stemp.qp".  This file is then copied by QPCOPY
#		   with the [y=2:] filter applied, to the user specified
#		   QPOE file name.  "root_stemp.qp" is then deleted.
#
# Algorithm :
#
#	- copy automatic parameters into local variables
#	- set appropriate parameters for FITS2QP call
#	- run FITS2QP
# 	- run QPADDAUX for hrievt and ipcevt
#	- run QPSORT/DELETE for ipcu
#	- run QPCOPY/DELETE for slew 
#
#--------------------------------------------------------------------------

procedure efits2qp(fitsfile, inst, datatype, qpoefile)

# input parameters 

string fitsfile		{prompt="input FITS file name"}
string inst             {min="hri|ipc", prompt="Einstein instrument"}
string datatype         {min="event|slew|unscreened", prompt="datatype of FITS file"}
string qpoefile		{".", prompt="output IRAF/PROS QPOE file name"}
bool clobber		{no, prompt="okay to delete existing file?",mode="h"}
int display		{1, prompt="display level", mode="h"}
bool qp_internals	{yes, prompt="prompt for qpoe internals?", mode="h"}
int qp_pagesize		{2048, prompt="page size for qpoe file", mode="h"}
int qp_bucketlen	{4096, prompt="bucket length for qpoe file", mode="h"}
bool qp_mkindex		{yes, prompt="make an index on y, x", mode="h"}
string qp_key		{"",prompt="key on which to make index", mode="h"}
int qp_debug 		{0, prompt="qpoe debug level", mode="h"}
int sortsize            {1000000, prompt="bytes to alloc. per sort", mode="h"}

begin

	# local variables
	
	string c_fitsfile	# local copy of parameter fitsfile
	string c_inst		# local copy of instrument type
	string c_datatype	# local copy of fits datatype
	string c_qpoefile	# local copy of parameter qpoefile
	string dataset		# derived from input inst and datatype
	string fits_qpoe	# qpoe file to be output by FITS2QP
	string sort_qpoe	# qpoe file to be output by QPSORT (ipcu data)
	string copy_qpoe	# qpoe file to be output by QPCOPY (slew data)
	bool c_qp_mkindex       # local copy for qp_mkindex
	string efits_cards	# fits_cards to pass to FITS2QP
	string ewcs_cards	# wcs_cards to pass to FITS2QP
	string ewhich_gti	# which_gti to pass to FITS2QP

	# check that FITS2QP and QPADDAUX are accessible

	if ( !deftask ("fits2qp") )
	{
	    beep
            error (1, "Requires xray.xdataio to be loaded!")
	}
	if ( !deftask ("qpaddaux") )
	{
	    beep
	    error (1, "Requires xray.xdataio to be loaded!")
	}

	# get fitsfile name.  run conversion if it's valid.

	c_fitsfile = fitsfile

	if ( !access (c_fitsfile) )
	{
	    beep
	    error(1,"Cannot access input FITS file " // c_fitsfile)
	}

	else
	{

	    c_inst = inst

	    if ( "ipc" == c_inst )
	    {
		c_datatype = datatype

		if ( "slew" == c_datatype ) 
		{
		    dataset = "slew"
		}
		if ( "event" == c_datatype ) 
	 	{
		    dataset = "ipcevt"
		}
		if ( "unscreened" == c_datatype )
		{
		    dataset = "ipcu"
		}
	    }
	    if ( "hri" == c_inst )
	    {
		c_datatype = "event"
		dataset = "hrievt"
	    }		

	    # if ipcu, check that QPSORT is accessible
		
	    if ( (dataset == "ipcu") && (!deftask ("qpsort")) )
	    {
    	     	beep
	   	error(1, "Requires xray/ximages to be loaded!")
	    }
	
	    # if slew, check that QPCOPY is accessible

	    if ( (dataset == "slew") && (!deftask ("qpcopy")) )
	    {
		beep
		error(1, "Requires xray/ximages to be loaded!")
	    }

       	    # check clobber and output qpoefile name for 
            # compatibility.  this is to accomodate the ipcu/slew
            # case, where we may not find out until the qpsort/qpcopy
            # call whether or not we will need to clobber

	    c_qpoefile = qpoefile
	    _rtname(c_fitsfile, c_qpoefile, ".qp")
	    c_qpoefile = s1

            if ( !clobber && access(c_qpoefile) )
            {
		beep
                error(1, "Output file " // c_qpoefile //" exists and clobber is set to no!")
            }

	    if ( display > 0 ) 
	    { 
		print("")
		print ("Using FITS file ", c_fitsfile, " to create QPOE file.")
	    }
	    if ( display > 2 )
	    {
		print("dataset is : ", dataset, ", qpoefile is : ", c_qpoefile)
		print("")
	    }

	    # if fitsfile is from the ipcu dataset, FITS2QP will 
	    # create an intermediate file "root_unsrtd.qp" which will be 
	    # sorted by QPSORT to the user specified qpoefile name
	    
 	    # if fitsfile is from the slew dataset, FITS2QP will
	    # create an intermediate file "root_stemp.qp" which will be
	    # copied by QPCOPY to the user specified qpoefile name

	    if ( dataset == "ipcu" ) 
	    { 
	     	sort_qpoe = c_qpoefile
		_rtname(c_qpoefile, "", "_unsrtd.qp")
		fits_qpoe = s1
	    }
	    else if ( dataset == "slew" )
	    {
		copy_qpoe = c_qpoefile
		_rtname(c_qpoefile, "", "_stemp.qp")
		fits_qpoe = s1
	    }
	    else
	    {
	 	fits_qpoe = c_qpoefile
	    }

	    # set special fits_cards for ipcevt data
		
	    if ( dataset == "ipcevt" )
	    {
	   	efits_cards = "xdataio$fitsipc.cards"
	    }
	    else 	
	    {
		efits_cards = "xdataio$fits.cards"
	    }

	    # set special wcs_cards for ipcu data
            # force qp_mkindex to be "no" for ipcu data
            # set which_gti appropriately, "all" for ipcu
     	    # "standard" for everything else 

	    if ( dataset == "ipcu" )
	    {
		ewcs_cards = "xdataio$wcsipc1.cards"
		c_qp_mkindex = no
		ewhich_gti = "all"
	    }
	    else 
	    {
		ewcs_cards = "xdataio$wcs.cards"
		c_qp_mkindex = qp_mkindex
		ewhich_gti = "standard"
	    }

	    # run FITS2QP

	    if ( display > 1 ) 
	    {
		print ("")
		print ("Running FITS2QP")
	    }
		
	    print ("")
	    fits2qp(c_fitsfile, fits_qpoe,
		naxes=0, axlen1=0, axlen2=0, mpe_ascii_fi=no, 
              	clobber=clobber,
              	oldqpoename=no, display=display, 
              	fits_cards=efits_cards,
             	qpoe_cards="xdataio$qpoe.cards",
             	ext_cards="xdataio$ext.cards",
              	wcs_cards=ewcs_cards, old_events="EVENTS", 
             	std_events="STDEVT", rej_events="REJEVT", 
            	which_events="old", oldgti_name="GTI",
            	allgti_name="ALLGTI", stdgti_name="STDGTI", 
           	which_gti=ewhich_gti, 
                scale=yes, key_x="x", key_y="y",
		qp_internals=qp_internals, 
            	qp_pagesize=qp_pagesize,
            	qp_bucketlen=qp_bucketlen, qp_blockfact=1,
            	qp_mkindex=c_qp_mkindex, qp_key=qp_key, 
            	qp_debug=qp_debug)

	    # run QPADDAUX for hrievt or ipcevt data
     	    # convert "tgr" records to "tsi" extension

	    if ((dataset == "hrievt") || (dataset == "ipcevt")) 
	    {

		if ( display > 1 )
		{
		    print ("")
		    print ("Running QPADDAUX")
		}

	    	qpaddaux (fits_qpoe, "", "convtgr", display=display, 
		    datarep=0)
	    }

	    # run QPSORT for ipcu data

	    if (dataset == "ipcu")
	    {

		if ( display > 1 ) 
		{
		    print ("")
		    print ("Running QPSORT")
		}

		# filter out y=1 photons, to avoid the IRAF 2.10.2
		# regions bug

	    	qpsort (fits_qpoe//"[y=2:]","", sort_qpoe, 
		    "", "position", exposure="NONE", expthresh=0.,
		    clobber=clobber, display=1, sortsize=sortsize,
		    qp_internals=qp_internals, qp_pagesize=qp_pagesize,
		    qp_bucketlen=qp_bucketlen, qp_blockfact=1, 
		    qp_mkindex=yes, qp_key=qp_key, qp_debug=qp_debug)

	    	# delete "root_unsrtd.qp"
		
		if ( display > 1 ) 
		{
		   print("")
		   print("Deleting temporary file ", fits_qpoe)
		}

		delete (fits_qpoe, yes, verify=no,
		    default_acti=yes, allversions=yes, subfiles=yes)
	    }

	    # run QPCOPY for slew data

	    if ( "slew" == dataset ) 
	    {
		
		if ( display > 1 )
		{
		    print ("")
		    print ("Running QCOPY")
		}

                # filter out y=1 photons, to avoid the IRAF 2.10.2
                # regions bug

		qpcopy (fits_qpoe//"[y=2:]", "", copy_qpoe, 
		   "", exposure="NONE", expthresh=0., clobber=clobber, 
		   display=display, qp_internals=qp_internals, 
		   qp_pagesize=qp_pagesize, qp_bucketlen=qp_bucketlen, 
		   qp_blockfact=1, qp_mkindex=yes, qp_key="", qp_debug=0)
		
		# delete "root_stemp.qp"

		if ( display > 1 )
		{
		    print ("")
		    print("Deleting temporary file ", fits_qpoe)
		}

		delete (fits_qpoe, yes, verify=no,
		    default_acti=yes, allversions=yes, subfiles=yes)
	    }
	}

end
