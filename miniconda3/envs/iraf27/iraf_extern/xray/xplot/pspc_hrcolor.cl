# $Header: /home/pros/xray/xplot/RCS/pspc_hrcolor.cl,v 11.0 1997/11/06 16:38:27 prosb Exp $
# $Log: pspc_hrcolor.cl,v $
# Revision 11.0  1997/11/06 16:38:27  prosb
# General Release 2.5
#
# Revision 9.1  1997/02/28 21:11:14  prosb
# JCC(2/28/97) - add the package name to imcalc.
#
#Revision 9.0  1995/11/16  19:04:36  prosb
#General Release 2.4
#
#Revision 8.1  1995/05/23  15:55:45  prosb
#JCC - Updated to accept PSPCB or PSPCC as header keyword INSTRUME.
#
#Revision 8.0  1994/06/27  17:01:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:47:31  prosb
#General Release 2.3
#
#Revision 6.1  93/12/15  11:40:02  mo
#MC	12/15/93		Add user defined PI bands for 3 colors
#
#Revision 6.0  93/05/24  16:39:57  prosb
#General Release 2.2
#
#Revision 1.1  93/01/26  10:50:41  prosb
#Initial revision
#
#
# Module:	pspc_hrcolor.cl
# Project:	PROS -- ROSAT RDC
# Purpose:	Calculates an approximate PSPC x-ray color image
# Description:	This shortcut algorithm for calculating the x-ray
#		color images was given to F. Fiore by Tomaso Belloni.
#		It separates the qpoe file into three pi bands and
#		than scales these to reflect the color in a full image.
#		Tomaso smoothed with a 15 arcsec gaussian, which I (jso)
#		have changed to 12 arcesec.  Thanks Fabrizio.
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} jso   -- initial version -- 25 Jan 93
#		{1} <who> -- <does what>     -- <when>
#
#
# ======================================================================
procedure pspc_hrcolor(qpoe,block,region_str,out_file)
# ======================================================================

string	qpoe=""		{prompt="PSPC qpoe filename"}
int	block=1		{prompt="desired block factor"}
string	region_str=""	{prompt="desired image subsection, e.g. [842:1353,842:1353]"}
string	out_file	{prompt="output image filename"}
string	red		{"11:40", prompt="red pi channels",mode="h"}
string	green		{"41:100", prompt="green pi channels",mode="h"}
string	blue		{"101:240", prompt="blue pi channels",mode="h"}
bool	clobber		{no, prompt="OK to overwrite existing output file?",mode="h"}
int	display		{1, prompt="Display level",mode="h"}

begin

	#---------------------------------
	# Declare the intrinsic parameters
	#---------------------------------

	string	qp			# i: qpoe filename
	int	blk			# i: blocking factor
	string	reg			# i: image subsection
	string	out_name		# o: output image filename
	bool	clob			# i: clobber old output?
	int	disp			# i: display level
	string	redpi
	string	greenpi
	string  bluepi

	string	inst			# qpoe file instrument
	string	mission			# qpoe file mission
	string	red_string		# red   image string for imcopy
	string	green_string		# green image string for imcopy
	string	blue_string		# blue  image string for imcopy
	string	red_name		# red   image name
	string	green_name		# green image name
	string	blue_name		# blue  image name
	string	red_smo			# red   smoothed image name
	string	green_smo		# green smoothed image name
	string	blue_smo		# blue  smoothed image name
	string	red_norm		# red   normalized image name
	string	green_norm		# green normalized image name
	string	blue_norm		# blue  normalized image name
	string	color_file		# name of file for standard color map
	string	calc_str		# string for imcalc
	string	msg

	real	blk_fac			# real value of blocking factor
	real	smo_fac			# gaussian smoothing factor (pixels)
	real	red_max			# maximum value of smoothed red image
	real	green_max		# maximum value of smoothed green image
	real	blue_max		# maximum value of smoothed blue image

	#------------------------------
	# make sure packages are loaded
	#------------------------------
	if ( !deftask ("imcopy") ) {
	    error (1, "Requires images to be loaded.")
	}
	if ( !deftask ("imsmooth") ) {
	    error (1, "Requires xspatial to be loaded.")
	}
	if ( !deftask ("imcalc") ) {
	    error (1, "Requires ximages to be loaded.")
	}

	#---------------------
	# Get query parameters
	#---------------------
	qp       = qpoe
	blk      = block
	reg      = region_str
	out_name = out_file
	clob     = clobber
	disp     = display
	redpi	 = red
	greenpi	 = green
	bluepi  = blue

	_rtname (out_name, "", ".imh")
	out_name=s1

	#------------------------------------------
	# check for error here it save time and CPU
	#------------------------------------------
	if ( access(out_name) ) {
	    if ( !clob ) {
		error(1, "Clobber = NO & Output file exists!")
	    }
	}

	#----------------------------------------------------------------
	# Retrieve Telescope and Instrument identifier from input header.
	# We can only do ROSAT PSPC.
	#----------------------------------------------------------------

	imgets (image=qp, param="telescope")
	mission = imgets.value

	imgets (image=qp, param="instrument")
	inst = imgets.value

	if ((mission!="ROSAT")|| !(inst=="PSPC"||inst=="PSPCB"||inst=="PSPCC"))         {  error(1, "Instrument must be ROSAT PSPC.")
	}

	#-------------------------------------------------------
	# 12 arcsec gaussian in pixels relative to blocked image
	#-------------------------------------------------------

	blk_fac = real(blk)

	smo_fac = 12.0 / (0.5 * blk_fac)

	#-----------------------------------------------
	# Run through each of three color images in turn
	#-----------------------------------------------
	#-------------------------
	# First make the red image
	#-------------------------
	if ( disp > 0 ) {
	  msg = "Creating red color images from PSPC qpoe file with pi="//redpi
	  print (msg)
	}

	#--------------------------------------------------
	# Define the filter string for the red color images
	#--------------------------------------------------
	red_str = ""
	red_str = qp // "[bl=" // blk // ",pi="//redpi//"]" // reg

	#--------------------------------------------------------------
	# construct names for unsmoothed images (this insures they have
	# correct directory path)
	#--------------------------------------------------------------
	_rtname (out_name, "", "_red.imh")
	red_name=s1

	imcopy (input=red_str, output=red_name, verbose=no, mode=h)

	#------------------------------------------------------------
	# construct names for smoothed images (this insures they have
	# correct directory path)
	#------------------------------------------------------------
	_rtname (out_name, "", "_rsm.imh")
	red_smo=s1

	if ( disp > 0 ) {
	    print ("Smoothing red images with 12 arcsec gaussian")
	}

	#---------------------------------------
	# run imsmooth to smooth red color image
	#---------------------------------------
	imsmooth (input_image=red_name, output_image=red_smo,
		function="gauss", arg1=smo_fac, select=0, arg2=1.0,
		model_file="", block=1, padding=0, clobber=no, errors=no,
		errarray="none", error_out="none", display=0,
		adjust_center=no, xcen=1.0, ycen=1.0, display_model=no,
		examine_model_fft=no, display_image=no, examine_image_fft=no,
		examine_convolution_fft=no, examine_complex_result=no,
		mode=h)

	imdelete (images=red_name, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	#-------------------------------
	# Find the max to normalize with
	#-------------------------------
	minmax (images=red_smo, force=yes, update=no, verbose=no,
		minval=INDEF, maxval=INDEF, iminval=INDEF, imaxval=INDEF,
		minpix="", maxpix="", mode=h)

	red_max = minmax.maxval

	#--------------------------------------------------------------
	# construct names for normalized images (this insures they have
	# correct directory path)
	#--------------------------------------------------------------
	_rtname (out_name, "", "_rnm.imh")
	red_norm=s1

	#----------------------------------
	# Make an integer image from 0 to 6
	#----------------------------------
	calc_str = ""

	calc_str = '"' // red_norm // '"' // "=int((6.0/" // red_max //
		")*" // '"' // red_smo   // '"' // ")"

	if ( disp > 4 ) {
	    print (calc_str)
	}

        ximages.imcalc(input=calc_str,clobber=no,zero=0.0,debug=0,mode=h)

	imdelete (images=red_smo, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	#-----------------------
	# now do the green image
	#-----------------------
	if ( disp > 0 ) {
	  msg = "Creating green color images from PSPC qpoe file with pi="//greenpi
	  print (msg)
	}

	#---------------------------------------------------
	# define the filter string for the green color image
	#---------------------------------------------------
	green_str = ""
	green_str = qp // "[bl=" // blk // ",pi="//greenpi//"]" // reg

	#-------------------------------------------------------------
	# construct name for unsmoothed images (this insures they have
	# correct directory path)
	#-------------------------------------------------------------
	_rtname (out_name, "", "_grn.imh")
	green_name=s1

	imcopy (input=green_str, output=green_name, verbose=no, mode=h)

	#----------------------------------------------------------
	# construct name for smoothed image (this insures they have
	# correct directory path)
	#----------------------------------------------------------
	_rtname (out_name, "", "_gsm.imh")
	green_smo=s1

	if ( disp > 0 ) {
	    print ("Smoothing green images with 12 arcsec gaussian")
	}

	#------------------------------------------
	# run imsmooth to smooth green color images 
	#------------------------------------------
	imsmooth (input_image=green_name, output_image=green_smo,
		function="gauss", arg1=smo_fac, select=0, arg2=1.0,
		model_file="", block=1, padding=0, clobber=no, errors=no,
		errarray="none", error_out="none", display=0,
		adjust_center=no, xcen=1.0, ycen=1.0, display_model=no,
		examine_model_fft=no, display_image=no, examine_image_fft=no,
		examine_convolution_fft=no, examine_complex_result=no,
		mode=h)

	imdelete (images=green_name, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	#-------------------------------
	# Find the max to normalize with
	#-------------------------------
	minmax (images=green_smo, force=yes, update=no, verbose=no,
		minval=INDEF, maxval=INDEF, iminval=INDEF, imaxval=INDEF,
		minpix="", maxpix="", mode=h)

	green_max = minmax.maxval

	#--------------------------------------------------------------
	# construct names for normalized images (this insures they have
	# correct directory path)
	#--------------------------------------------------------------
	_rtname (out_name, "", "_gnm.imh")
	green_norm=s1

	#-----------------------------------
	# Make an integer image from 0 to 36
	#-----------------------------------
	calc_str = ""

	calc_str = '"' // green_norm // '"' // "=int(6.0*(6.0/" // green_max //
		")*" // '"' // green_smo // '"' // ")"

	if ( disp > 4 ) {
	    print (calc_str)
	}

	ximages.imcalc(input=calc_str,clobber=no,zero=0.0,debug=0,mode=h)

	imdelete (images=green_smo, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	#----------------------
	# now do the blue image
	#----------------------
	if ( disp > 0 ) {
	  msg = "Creating blue color images from PSPC qpoe file with pi="//bluepi
	  print (msg)
	}

	#--------------------------------------------------
	# define the filter string for the blue color image
	#--------------------------------------------------
	blue_str = ""
	blue_str = qp // "[bl=" // blk // ",pi="//bluepi//"]" // reg

	#--------------------------------------------------------------
	# construct names for unsmoothed images (this insures they have
	# correct directory path)
	#--------------------------------------------------------------
	_rtname (out_name, "", "_blu.imh")
	blue_name=s1

	imcopy (input=blue_str, output=blue_name, verbose=no, mode=h)

	#------------------------------------------------------------
	# construct names for smoothed images (this insures they have
	# correct directory path)
	#------------------------------------------------------------
	_rtname (out_name, "", "_bsm.imh")
	blue_smo=s1

	if ( disp > 0 ) {
	    print ("Smoothing green images with 12 arcsec gaussian")
	}

	#-----------------------------------------
	# run imsmooth to smooth blue color images 
	#-----------------------------------------
	imsmooth (input_image=blue_name, output_image=blue_smo,
		function="gauss", arg1=smo_fac, select=0, arg2=1.0,
		model_file="", block=1, padding=0, clobber=no, errors=no,
		errarray="none", error_out="none", display=0,
		adjust_center=no, xcen=1.0, ycen=1.0, display_model=no,
		examine_model_fft=no, display_image=no, examine_image_fft=no,
		examine_convolution_fft=no, examine_complex_result=no,
		mode=h)

	imdelete (images=blue_name, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	#-------------------------------
	# Find the max to normalize with
	#-------------------------------
	minmax (images=blue_smo, force=yes, update=no, verbose=no,
		minval=INDEF, maxval=INDEF, iminval=INDEF, imaxval=INDEF,
		minpix="", maxpix="", mode=h)

	blue_max = minmax.maxval

	#--------------------------------------------------------------
	# construct names for normalized images (this insures they have
	# correct directory path)
	#--------------------------------------------------------------
	_rtname (out_name, "", "_bnm.imh")
	blue_norm=s1

	#------------------------------------
	# Make an integer image from 0 to 256
	#------------------------------------
	calc_str = ""

	calc_str = '"' // blue_norm // '"' // "=int(36.0*(6.0/" // blue_max //
		")*" // '"' // blue_smo  // '"' // ")"

	if ( disp > 0 ) {
	    print (calc_str)
	}

	ximages.imcalc(input=calc_str,clobber=no,zero=0.0,debug=0,mode=h)

	imdelete (images=blue_smo, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	#-----------------------------------
	# run imcalc to get full color image
	#-----------------------------------
	if ( disp > 0 ) {
	    print ("Calculating the full color image with imcalc")
	}

	#----------------------------------------------------------
	# If we get here we should delete the old image, i.e., will
	# should not get to the error message.
	#----------------------------------------------------------
	if ( access(out_name) ) {
	    if ( clob ) {
		imdel (out_name)
	    }
	    else {
		error(1, "Clobber = NO & Output file exists!")
	    }
	}

	#--------------------------------------------------------------
	# The full color image is the addition of the three color files
	#--------------------------------------------------------------
	calc_str = ""

	calc_str = '"' // out_name // '"' // "=" // '"' // red_norm //
		'"' // "+" // '"' // green_norm // '"' // "+" //
		'"' // blue_norm // '"'

	if ( disp > 4 ) {
	    print (calc_str)
	}

	ximages.imcalc(input=calc_str,clobber=no,zero=0.0,debug=0,mode=h)

	#--------------------------
	# delete three color images
	#--------------------------
	if ( disp > 0 ) {
	    print ("Deleting three partial color images")
	}

	imdelete (images=red_norm, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	imdelete (images=green_norm, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	imdelete (images=blue_norm, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	#--------------------------------------
	# Make the standard color map available
	#--------------------------------------
	_rtname (out_name, "", "_color.map")
	color_file=s1

	if ( access(color_file) ) {
	    delete (color_file)
	}

	print("# SAOimage color table",				>  color_file)
	print("PSEUDOCOLOR",					>> color_file)
	print("RED:",						>> color_file)
	print("(0.013,0.000)(0.021,1.000)(0.130,1.000)",	>> color_file)
	print("(0.504,1.000)(0.649,0.000)(1.000,0.565)",	>> color_file)
	print("GREEN:"					,	>> color_file)
	print("(0.000,0.000)(0.037,0.065)(0.273,0.806)",	>> color_file)
	print("(0.572,1.000)(1.000,0.000)",			>> color_file)
	print("BLUE:",						>> color_file)
	print("(0.000,0.000)(0.039,0.000)(0.250,0.000)",	>> color_file)
	print("(0.670,0.000)(0.750,1.000)",			>> color_file)
	print("(1.000,1.000)",					>> color_file)

	if ( disp > 0 ) {
	    print("Color map written to:", color_file, ".")
	    print("Use SAOimage 'color cmap-read' button to access it.")
	}

end
