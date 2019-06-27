# $Header: /home/pros/xray/xspatial/RCS/rosprf.cl,v 11.0 1997/11/06 16:33:23 prosb Exp $
# $Log: rosprf.cl,v $
# Revision 11.0  1997/11/06 16:33:23  prosb
# General Release 2.5
#
# Revision 9.1  1997/02/28 21:13:00  prosb
# JCC(2/28/97) - add the package name to imcalc.
#
#Revision 9.0  1995/11/16  18:35:44  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:55:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:30:58  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:10:00  prosb
#General Release 2.2
#
#Revision 1.5  93/05/13  09:25:08  orszak
#jso - changed parameters so that only dimensions are input (my old think
#      was that immodel was working like plcreate and using an image name
#      as a reference; this is obviously wrong otherwise the script would
#      not work). also made pixel_size an auto parameter at dan's request
#      and changed the display from immodel for disp=0.
#
#Revision 1.4  93/05/10  15:46:52  prosb
#jso - oops, almost didn't fix that bug -- it is now.
#
#Revision 1.3  93/05/10  15:43:15  prosb
#jso - i moved the conversion factor for the pixel units.  this makes
#      the normalization more reasonable, but should not change anything
#      physical.  OOPS, almost forgot i found a bug in one term which
#      i corrected.
#
#Revision 1.2  93/05/10  10:58:45  prosb
#jso - redirected output that imcnts gives even when disp=0.
#
#Revision 1.1  93/05/06  17:29:34  orszak
#Initial revision
#
#
# Module:	rosprf.cl
# Project:	PROS -- ROSAT RDC
# Purpose:	Creates an image with a model of the PRF (PSF).
# Description:	This script will run immodel to create a image
#		of the HRI and PSPC PRF (PSF).
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} jso   -- initial version -- May 93
#		{1} <who> -- <does what>     -- <when>
#
#
# ======================================================================
procedure rosprf(x_dim,y_dim,center,instrument,out_file,energy,pixel_size)
# ======================================================================

int	x_dim=512		{prompt="image x dimension"}
int	y_dim=512		{prompt="image y dimension"}
string	center="256 256"	{prompt="center of PRF"}
string	instrument=""		{min="PSPC|pspc|HRI|hri",prompt="instrument"}
string	out_file=""		{prompt="output image filename"}
real	energy=1.0		{prompt="energy [keV] for PSPC calculation"}
real	pixel_size=0.5		{prompt="pixel size [arcsec]"}
bool	clobber			{no, prompt="OK to overwrite existing output file?", mode="h"}
int	display			{1, prompt="Display level", mode="h"}

begin

	#---------------------------------
	# Declare the intrinsic parameters
	#---------------------------------

	int	xx			# i: image x dimension
	int	yy			# i: iamge y dimension
	string	cen			# i: center of PRF (PSF)
	string	inst			# i: instrument name
	string	out_name		# o: output image filename
	real	ener			# i: energy for PSPC
	real	pix_siz			# i: pixel size
	bool	clob			# i: clobber old output?
	int	disp			# i: display level

	int	task_disp		# display levels for tasks

	string	im			# dimension string for immodel
	string	disp_str		# display level for tstat
	string	t1_name			# temp string for first component
	string	t2_name			# temp string for second component
	string	t3_name			# temp string for third component
	string	tbl_name		# temp string for imcnts table
	string	src_str			# for source position  intensity
	string	calc_str		# string for imcalc

	real	norm_fac		# total counts for normalization
	real	g1_arg			# HRI first gauss pixel corrected arg1
	real	g2_arg			# HRI second gauss pixel corrected arg1
	real	ex_arg			# HRI exponential pixel corrected arg1

	#-------------------------------------------------
	# the following are for the PSPC energy dependence
	#-------------------------------------------------
	real	f_scat
	real	r_break
	real	alpha
	real	r_scat
	real	a_term1
	real	a_term2
	real	a_term3
	real	a_scat
	real	r_exp
	real	exp_term1
	real	f_exp
	real	a_exp
	real	r_gaus
	real	f_gaus
	real	a_gaus
	real	PI

	PI = 3.141592

	#------------------------------
	# make sure packages are loaded
	#------------------------------
	if ( !deftask ("immodel") ) {
	    error (1, "Requires xspatial to be loaded.")
	}
	if ( !deftask ("imcnts") ) {
	    error (1, "Requires xspatial to be loaded.")
	}
	if ( !deftask ("imcalc") ) {
	    error (1, "Requires ximages to be loaded.")
	}
	if ( !deftask ("tstat") ) {
	    error (1, "Requires tables to be loaded.")
	}

	#---------------------
	# Get query parameters
	#---------------------
	xx       = x_dim
	yy       = y_dim
	cen      = center
	inst     = instrument
	out_name = out_file
	pix_siz  = pixel_size
	clob     = clobber
	disp     = display

	if ( disp > 2 ) {
	    task_disp = disp
	}
	else {
	    task_disp = 0
	}

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

	#----------------------------
	# make image dimension string
	#----------------------------
	im = ""
	im = xx // " " // yy

	if ( disp > 4 ) {
	    print(im)
	}

	#---------------------------------------------
	# add the intensity to the the center position
	#---------------------------------------------
	src_str = ""
	src_str = cen // " 1"

	if ( disp > 4 ) {
	    print(src_str)
	}

	#-------------------------------------------------------------
	# construct names for temporary images (this insures they have
	# correct directory path)
	#-------------------------------------------------------------
	_rtname (out_name, "", "_t1.imh")
	t1_name=s1

	_rtname (out_name, "", "_t2.imh")
	t2_name=s1

	_rtname (out_name, "", "_t3.imh")
	t3_name=s1

	_rtname (out_name, "", "_tcnt.tab")
	tbl_name=s1

	#-----------------------------------------------------
	# Use the instrument parameter to determine the model.
	# We can only do ROSAT PSPC and ROSAT HRI
	#-----------------------------------------------------

	if ( inst == "HRI" || inst == "hri") {

	    if ( disp > 0 ) {
		print("Creating model for ROSAT HRI")
	    }

	    #------------------------------
	    # convert arg1 to correct units
	    #------------------------------
	    g1_arg = 0.5*4.3716/pix_siz
	    g2_arg = 0.5*8.0838/pix_siz
	    ex_arg = 0.5*63.38 /pix_siz

	    #--------------------------------------
	    # run immodel to create first component
	    #--------------------------------------
	    if ( disp > 0 ) {
		disp_str = "STDOUT"
	    }
	    else {
		disp_str = "dev$null"
	    }
	    immodel (image=im, outname=t1_name, function="gauss",
		arg1=g1_arg, arg2=0.0, model_file="",
		normalize=no, scale=0.9638, sources=src_str,
		clobber=clob, display=task_disp,
		mode=h, > disp_str )

	    #---------------------------------------
	    # run immodel to create second component
	    #---------------------------------------
	    if ( disp > 0 ) {
		disp_str = "STDOUT"
	    }
	    else {
		disp_str = "dev$null"
	    }
	    immodel (image=t1_name, outname=t2_name, function="gauss",
		arg1=g2_arg, arg2=0.0, model_file="",
		normalize=no, scale=0.1798, sources=src_str,
		clobber=clob, display=task_disp,
		mode=h, > disp_str )

	    imdelete (images=t1_name, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	    #--------------------------------------
	    # run immodel to create third component
	    #--------------------------------------
	    if ( disp > 0 ) {
		disp_str = "STDOUT"
	    }
	    else {
		disp_str = "dev$null"
	    }
	    immodel (image=t2_name, outname=t3_name, function="exp",
		arg1=ex_arg, arg2=0.0, model_file="",
		normalize=no, scale=0.0009, sources=src_str,
		clobber=clob, display=task_disp,
		mode=h, > disp_str )

	    imdelete (images=t2_name, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	}

	else if ( inst == "PSPC" || inst == "pspc") {

	    #--------------------
	    # Get query parameter
	    #--------------------
	    ener = energy

	    if ( ener < 0.2 || ener > 1.7 ) {
		error(1, "Invalid energy requested; try between 0.2 and 1.7 keV.")
	    }

	    #---------------------------------------------
	    # calculate (easy) energy dependent quantities
	    #---------------------------------------------
	    f_scat = 0.059*(ener**1.43)
	    r_break = 14.365/ener
	    alpha = 2.119 + 0.212*ener
	    r_scat = 1.33 / ener
	    #-------------------------
	    # convert to correct units
	    #-------------------------
	    r_break = 60.0*r_break/pix_siz
	    r_scat  = 60.0*r_scat /pix_siz

	    #-------------------------------
	    # calculate scattering amplitude
	    #-------------------------------
	    a_term1 = log( 1 + (4.0*r_break*r_break)/(r_scat*r_scat) )
	    a_term2 = ( (alpha-2.0) * (r_scat*r_scat/4.0 + r_break*r_break) )
	    a_term2 = 2.0*r_break*r_break/a_term2
	    a_term3 = 2.0*PI*r_scat*r_scat/4.0

	    a_scat = f_scat/( a_term3 * (a_term1+a_term2) )

	    #-----------------------------------------------------
	    # calculate energy dependent quantities of exponential
	    #-----------------------------------------------------
	    #-----------------------------------------------
	    # r_exp is the r_t (e-folding angle) in the memo
	    #-----------------------------------------------
	    r_exp = sqrt( (50.61/(ener**1.472)) + 6.80*(ener**5.62) )
	    r_exp = r_exp/60.0
	    #-------------------------
	    # convert to correct units
	    #-------------------------
	    r_exp  = 60.0*r_exp /pix_siz

	    exp_term1 = -1.618 + 0.507*ener + 0.148*(ener**2)
	    f_exp = 10**exp_term1
	    a_exp = f_exp/(2*PI*r_exp*r_exp)

	    #-------------------------------------------------------
	    # calculate energy dependent quantities of gaussian core
	    #-------------------------------------------------------
	    f_gaus = 1.0 - f_scat - f_exp

	    r_gaus = sqrt( 108.7/(ener**0.888) + 1.121*(ener**6) )
	    r_gaus = r_gaus/60.0
	    #-------------------------
	    # convert to correct units
	    #-------------------------
	    r_gaus = 60.0*r_gaus/pix_siz

	    a_gaus = f_gaus/(2*PI*r_gaus*r_gaus)

	    if ( disp > 0 ) {
		print("Creating model for ROSAT PSPC")
	    }

	    #------------------------------------------------
	    # run immodel to create first component - lorentz
	    #------------------------------------------------
	    if ( disp > 0 ) {
		disp_str = "STDOUT"
	    }
	    else {
		disp_str = "dev$null"
	    }
	    immodel (image=im, outname=t1_name, function="lorentz",
		arg1=r_scat, arg2=0.0, model_file="",
		normalize=no, scale=a_scat, sources=src_str,
		clobber=clob, display=task_disp,
		mode=h, > disp_str )

	    #-----------------------------------------------------
	    # run immodel to create second component - exponential
	    #-----------------------------------------------------
	    if ( disp > 0 ) {
		disp_str = "STDOUT"
	    }
	    else {
		disp_str = "dev$null"
	    }
	    immodel (image=t1_name, outname=t2_name, function="exp",
		arg1=r_exp, arg2=0.0, model_file="",
		normalize=no, scale=a_exp, sources=src_str,
		clobber=clob, display=task_disp,
		mode=h, > disp_str )

	    imdelete (images=t1_name, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	    #------------------------------------------------------
	    # run immodel to create third component - gaussian core
	    #------------------------------------------------------
	    if ( disp > 0 ) {
		disp_str = "STDOUT"
	    }
	    else {
		disp_str = "dev$null"
	    }
	    immodel (image=t2_name, outname=t3_name, function="gauss",
		arg1=r_gaus, arg2=0.0, model_file="",
		normalize=no, scale=a_gaus, sources=src_str,
		clobber=clob, display=task_disp,
		mode=h, > disp_str )

	    imdelete (images=t2_name, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	}

	#---------------------------------------------------------
	# Report an error if we cannot do the requested instrument
	#---------------------------------------------------------
	else {
	    error(1, "Instrument must be ROSAT PSPC or ROSAT HRI.")
	}

	#------------------------------------------------
	# run imcnts to get total counts for normaliztion
	#------------------------------------------------
	if ( task_disp > 4 ) {
	    disp_str = "STDOUT"
	}
	else {
	    disp_str = "dev$null"
	}
	imcnts (source=t3_name, region="none", bkgd="none",
		bkgdregion="", table=tbl_name, exposure="NONE",
		expthresh=0.0, err="NONE", matchbkgd=no,
		bkgdexposure="NONE", bkgdthresh=0.0, addbkgderr=yes,
		bkgderr="NONE", timenorm=no, normfactor=1.0,
		clobber=clob, display=task_disp, > disp_str )

	#-------------------------------------------
	# Find the normalization from the table file
	#-------------------------------------------
	if ( task_disp > 4 ) {
	    disp_str = "STDOUT"
	}
	else {
	    disp_str = ""
	}
	tstat (intable=tbl_name, column="net", outtable=disp_str,
		lowlim=INDEF, highlim=INDEF, rows="-", n_tab="table",
		n_nam="column", n_nrows="nrows", n_mean="mean",
		n_stddev="stddev", n_median="median", n_min="min",
		n_max="max", nrows=INDEF, mean=INDEF, stddev=INDEF,
		median=INDEF, vmin=INDEF, vmax=INDEF, mode="h")

	norm_fac = tstat.mean

	#--------------------------------------------------------
	# If we get here we should delete the old image, i.e., we
	# should not get to the error message.
	#--------------------------------------------------------
	if ( access(out_name) ) {
	    if ( clob ) {
		imdel (out_name)
	    }
	    else {
		error(1, "Clobber = NO & Output file exists!")
	    }
	}

	#-------------------------------
	# Calculate the normalized image
	#-------------------------------
	calc_str = ""

	calc_str = '"' // out_name // '"' // "=" // '"' // t3_name // '"' //
		"/" // norm_fac

	if ( disp > 4 ) {
	    print (calc_str)
	}

	if ( disp > 0 ) {
	    print("Writing output model: ", out_name, ".")
	}

	ximages.imcalc(input=calc_str,clobber=no,zero=0.0,debug=0,mode=h)

	imdelete (images=t3_name, go_ahead=yes, verify=no,
		default_action=yes, mode=h)

	delete (files=tbl_name, go_ahead=yes, verify=no,
		default_action=yes, allversions=yes, subfiles=yes, mode=h)

end
