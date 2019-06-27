#$Log: _qp_get_obs.cl,v $
#Revision 11.0  1997/11/06 16:37:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:00:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:23:11  prosb
#General Release 2.3.1
#
#Revision 7.3  94/06/01  12:13:22  prosb
#Changed _qp_get to _qp_get_obs
#
#Revision 7.2  94/05/04  11:09:24  prosb
#Moved from qp_get to _qp_get.
#
#Revision 7.1  94/03/02  14:31:02  prosb
#Replaced ipc_qpoe_cards with ipcevt_fits_cards, to go with
#recent changes to fits2qp.
#
#Revision 7.0  93/12/27  18:46:15  prosb
#General Release 2.3
#
#Revision 6.3  93/09/30  12:26:40  prosb
#Added support for "qpoeipc.cards", a new set of qpoe cards neede
#for IPCEVT fits files.  (They were designed to make up for the error
#in the fits files which had the OBSERVER keyword be an integer
#instead of a string.)
#
#Revision 6.2  93/07/28  10:34:31  prosb
#(dvs) Added call to qpaddaux to convert tgr extension to a tsi extension.
#This will only occur on hri and ipc event data, not slew data.
#
#Revision 6.1  93/06/07  12:00:09  dvs
#Updated qp_get to use new fits2qp parameters.
#
#Revision 6.0  93/05/24  17:11:25  prosb
#General Release 2.2
#
#Revision 1.1  93/04/13  09:48:01  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/RCS/_qp_get_obs.cl,v 11.0 1997/11/06 16:37:03 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       qp_get.cl
# Project:      PROS -- EINSTEIN CDROM
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/93 -- initial version 
#		{1} David Van Stone -- 6/93 -- modified fits2qp parameters
#		{2} David Van Stone -- 7/93 -- added qpaddaux call
#		{3} David Van Stone -- 9/93 -- need ipcqpoe_cards for IPCEVT1
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Task:		qp_get
#
# Purpose:      To create a QPOE file associated with a given specifier
#		(sequence number or FITS file name) from on-line Einstein CDs.
#
# Input parameters:
#               dataset     	which Einstein dataset (ipc, hri, slew)
#		specifier   	FITS filename OR sequence number
#		qpoefile    	name of output qpoe file 
#		clobber		overwrite output qpoe file?
#		display		text display level (0=none, 5=full)
#		eincdpar	PSET to use for eincdrom parameters
#		(+ other input parameters identical to those for fits2qp)
#
# Description:  This task locates the FITS file name (corresponding to
#		the specifier), then calls xdataio.fits2qp to convert
#		it into a qpoe file.
#		If the user enters a sequence number as a specifier,
#		this task will first find the corresponding FITS filename
#		by looking in the sequence number index file for the dataset.
#
# Algorithm:    * copy automatic parameters into local vars
#		* call _spec2root to find the root to use for the qpoe file
#		* call _rtname to set the root of the output qpoe file
#		* call _fitsnm_get to find the name of the FITS file
#		* call _fits_find to find the pathname of the FITS file
#		* call fits2qp to convert the FITS file into a qpoe file
#		* call qpaddaux to convert tgr extention to tsi extension
#
#--------------------------------------------------------------------------

procedure qp_get (dataset,specifier,qpoefile)

### PARAMETERS ###

string 	dataset		# which Einstein dataset (ipc, hri, slew)
string 	specifier	# FITS filename OR sequence number
file 	qpoefile   	# name of output qpoe file 
bool 	clobber 	# overwrite qpoefile?
int  	display 	# text display level (0=none, 5=full)
pset 	eincdpar	# PSET to use for eincdrom parameters
     ### params for fits2qp ###
int  	naxes 
int  	axlen1
int  	axlen2
bool 	mpe_ascii_file
string 	events 
bool 	oldqpoename 
string 	fits_cards
string  ipcevt_fits_cards
string 	qpoe_cards
string  ext_cards
string  wcs_cards
bool 	qp_internals
int  	qp_pagesize 
int  	qp_bucketlen
int  	qp_blockfactor 
bool  	qp_mkindex 
string  qp_key
int  	qp_debug 


begin

### LOCAL VARS ###

	string 	c_dataset	# local copy of parameter "dataset"
	string 	c_specifier	# local copy of parameter "specifier"
	file   	c_qpoefile	# local copy of parameter "qpoefile"
	file 	e_qpoefile	# qpoefile with root and extension added
	file 	fitsname	# name of fits file to convert to qpoe 
	file 	fitspath	# path of fits file to convert to qpoe 
	string 	root		# root to use for extending qpoefile name
	string  c_fits_cards    # local copy of parameter "fitscards" corresponding
				# to the correct dataset.

### BEGINNING OF CL SCRIPT ###

	# copy automatic parameters into local vars
	 c_dataset   = dataset
	 c_specifier = specifier
	 c_qpoefile  = qpoefile

	# call _spec2root to find the root to use for the qpoe file
	 _spec2root (c_dataset,c_specifier,display=display)
	 root = _spec2root.root

	# call _rtname to set the root of the output qpoe file
	 _rtname ( root, c_qpoefile, ".qp" )
	 e_qpoefile = s1

	# call _fitsnm_get to find the name of the FITS file
	 _fitsnm_get (c_dataset,c_specifier,display=display,eincdpar=eincdpar)
   	 fitsname    = _fitsnm_get.fitsnm


	# call _fits_find to find the pathname of the FITS file
	 _fits_find(c_dataset,fitsname,display=display,eincdpar=eincdpar)
	 fitspath=_fits_find.fits_path

   	 if (display>0)
   	 {
      	   	print("")
      	   	print("Using FITS file ",fitspath," to create QPOE file.")
      	   	print("")
   	 }

	# Find which fitscards set of cards we need.
         if (c_dataset=="ipcevt")
         {
	    c_fits_cards=ipcevt_fits_cards
	 }
	 else
	 {
	    c_fits_cards=fits_cards
	 }
	# call fits2qp to convert the FITS file into a qpoe file.
	# (NOTE: if display>0, this task displays the message
	#    "Writing output QPOE file: {qpoefilename}")
	#
	 fits2qp (fitspath,e_qpoefile,
	    naxes=naxes, axlen1=axlen1, axlen2=axlen2, 
	    mpe_ascii_fi=mpe_ascii_fits, clobber=clobber, 
	    oldqpoename=oldqpoenam, display=display, fits_cards=c_fits_cards,
	    qpoe_cards=qpoe_cards, ext_cards=ext_cards, wcs_cards=wcs_cards,
	    old_events=old_event, std_events=std_events,
	    rej_events=rej_events, which_events=which_events, 
	    oldgti_name=oldgti_name, allgti_name=allgti_name, 
	    stdgti_name=stdgti_name, which_gti=which_gti, 
	    qp_internals=qp_internals, qp_pagesize=qp_pagesize, 
	    qp_bucketlen=qp_bucketlen, qp_blockfact=qp_blockfact, 
	    qp_mkindex=qp_mkindex, qp_key=qp_key, qp_debug=qp_debug) 


	# call qpaddaux to convert tgr extension to tsi extension
	# (Only do this for hri event and ipc event, which have tgr extensions.)
	 if (c_dataset=="hrievt" || c_dataset=="ipcevt")
	 {
		 if (display>1)
		 {
                        print("")
	                print("Calling qpaddaux to convert tgr to tsi extension.")
        	        print("")
		 }		

		# (NOTE: datarep is not used, since we are are only working within
		#        the qpoe file.)
		 qpaddaux (e_qpoefile, "", "convtgr", display=0, datarep=0)
	 }
end
