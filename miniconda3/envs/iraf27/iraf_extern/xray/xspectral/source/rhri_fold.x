# $Header: /home/pros/xray/xspectral/source/RCS/rhri_fold.x,v 11.0 1997/11/06 16:43:19 prosb Exp $
# $Log: rhri_fold.x,v $
# Revision 11.0  1997/11/06 16:43:19  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:31:07  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:55  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:44  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:19  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:18:07  prosb
#General Release 2.0:  April 1992
#
#Revision 1.5  92/04/10  16:21:28  orszak
#jso - disable 15 channels for this build.
#
#Revision 1.4  92/04/06  14:42:52  orszak
#jso - this should get everything working okay.
#
#Revision 1.3  92/04/06  10:20:25  orszak
#jso - the wrong one was put in. this should be thew correct copy.
#
#
# Module:	rhri_fold.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Fold the predicted data through the ROSAT HRI response
# External:	
# Local:	
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} jso - initial version - Apr 92
#		{n} <who> -- <does what> -- <when>
#

include <mach.h>

include <spectral.h>

include "pspc.h"
include "rhri.h"

procedure rhri_fold(fp, model, nbins)

pointer	fp			# file pointer
double	model[nbins]		# model data
int	nbins			# number of bins of data

bool	init

int	bytes
int	fd			# file descriptor for io
int	ii
int	jj

pointer	dtmat_fname
pointer	dtmat_fname15
pointer	efftarea
pointer	egrid_fname
pointer	fname
pointer	matrix			# detector response matrix for 1 channel
pointer	matrix15		# detector response matrix for 15 channels
pointer	hri_eff_area		# HRI effective area calibration
pointer	hri_eff_area_fname
pointer	offar			# offaxis angle effective area for PSPS
pointer	offar_fname
pointer	rebinned		# model in RHRI_RSPBINS
pointer	response
pointer	response15
pointer	sp
pointer dataset
pointer spectrum
pointer unlogged		# model unlogged

real	center[RHRI_RSPBINS]
real	widths[RHRI_RSPBINS]
real	edges[RHRI_RSPBINS + 1]

data	init	/ FALSE /

bool	strne()

int	open()
int	read()

begin

	call smark(sp)

	#---------------------------------------
	# detector response matrix for 1 channel
	#---------------------------------------
	call salloc(matrix, RHRI_RSPBINS * RHRI_CHANNELS, TY_REAL)

	#-------------------------------------------------
	# detector response matrix for 15 channels (pitch)
	#-------------------------------------------------
	call salloc(matrix15, RHRI_RSPBINS * (RHRI_PITCH - 1), TY_REAL)

	#--------------------------------------
	# offaxis angle effective area for PSPC
	#--------------------------------------
	call salloc(offar, ( RHRI_RSPBINS + 1 ) * PSPC_OFFAR, TY_REAL)

	#----------------------------------
	# HRI effective area file (on axis)
	#----------------------------------
	call salloc(hri_eff_area, RHRI_RSPBINS * RHRI_OFFAR, TY_REAL)

	#---------------------------
	# temporary file name holder
	#---------------------------
	call salloc(fname, SZ_FNAME, TY_CHAR)

	#------------------------------------
	# Detector Matrix file name 1 channel
	#------------------------------------
	call salloc(dtmat_fname, SZ_FNAME, TY_CHAR)

	#--------------------------------------
	# Detector Matrix file name 15 channels
	#--------------------------------------
	call salloc(dtmat_fname15, SZ_FNAME, TY_CHAR)

	#----------------
	# Offar file name
	#----------------
	call salloc(offar_fname, SZ_FNAME, TY_CHAR)

	#-------------------------------------
	# HRI on axis effective area file name
	#-------------------------------------
	call salloc(hri_eff_area_fname, SZ_FNAME, TY_CHAR)

	#----------------------
	# Energy grid file name
	#----------------------
	call salloc(egrid_fname, SZ_FNAME, TY_CHAR)

	#--------------------
	# assign the data set
	#--------------------
	dataset = FP_OBSERSTACK(fp,FP_CURDATASET(fp))

	#-----------------------------------
	# check that we are 1 or 15 channels
	#-----------------------------------
	if ( DS_NPHAS(dataset) == (RHRI_PITCH - 1) ) {
	    call error(1, "Fitting with the ROSAT HRI has not yet been shown to be feasible.")
	}
	else if ( DS_NPHAS(dataset) != RHRI_CHANNELS ) {
	    call error(1, "Number of channels does not match instrument response.")
	}

	#-----------------------------------------------------------------
	# check that the number of off axis histogram bins is same as PSPC
	#-----------------------------------------------------------------
	if ( DS_NOAH(dataset) != PSPC_OFFAR ) {
	    call error(1, "Number of offaxis histogram bins does not match instrument response")
	}

	#-----------------------------------------------------------
	# read in ROSAT HRI data file names; if they have changed we
	# want to reinitalize.
	#-----------------------------------------------------------

	#-------------------------------
	# response matrix file 1 channel
	#-------------------------------
	call strcpy(Memc[dtmat_fname], Memc[fname], SZ_FNAME)
	call clgstr(ROS_HRI_DTMAT, Memc[dtmat_fname], SZ_FNAME)
	if ( strne(Memc[fname], Memc[dtmat_fname]) ) {
	    init = FALSE
	}

	#---------------------------------
	# response matrix file 15 channels
	#---------------------------------
	call strcpy(Memc[dtmat_fname15], Memc[fname], SZ_FNAME)
	call clgstr(ROS_HRI_DTMAT15, Memc[dtmat_fname15], SZ_FNAME)
	if ( strne(Memc[fname], Memc[dtmat_fname15]) ) {
	    init = FALSE
	}

	#--------------------
	# effective area file
	#--------------------
	call strcpy(Memc[hri_eff_area_fname], Memc[fname], SZ_FNAME)
	call clgstr(ROS_HRI_EFFAR, Memc[hri_eff_area_fname], SZ_FNAME)
        if ( strne(Memc[fname], Memc[hri_eff_area_fname]) ) {
	    init = FALSE
	}

	#-----------------------------
	# off axis coefficients - PSPC
	#-----------------------------
	call strcpy(Memc[offar_fname], Memc[fname], SZ_FNAME)
	call clgstr(ROS_OFFAR, Memc[offar_fname], SZ_FNAME)
        if ( strne(Memc[fname], Memc[offar_fname]) ) {
	    init = FALSE
	}

	#--------------------------------
	# response bin centers and widths
	#--------------------------------
	call strcpy(Memc[egrid_fname], Memc[fname], SZ_FNAME)
	call clgstr(ROS_EGRID, Memc[egrid_fname], SZ_FNAME)
        if ( strne(Memc[fname], Memc[egrid_fname]) ) {
	    init = FALSE
	}

	if ( !init ) {

	    #------------------------------------
	    # read in response matrix - 1 channel
	    # ( RHRI_RSPBINS x RHRI_CHANNELS )
	    #------------------------------------
	    fd = open(Memc[dtmat_fname], READ_ONLY, BINARY_FILE)
	    bytes = read(fd, Memr[matrix],
				RHRI_RSPBINS * RHRI_CHANNELS * SZ_REAL)
	    call close(fd)

	    #-------------------------------------------------------
	    # read in response matrix (  RHRI_RSPBINS x RHRI_PITCH )
	    #-------------------------------------------------------
	    fd = open(Memc[dtmat_fname15], READ_ONLY, BINARY_FILE)
	    bytes = read(fd, Memr[matrix15],
				RHRI_RSPBINS * (RHRI_PITCH - 1) * SZ_REAL)
	    call close(fd)

	    #-------------------------------------------------------------
	    # read in off axis coefficients (RHRI_RSPBINS +1) x RHRI_OFFAR
	    #-------------------------------------------------------------
	    fd = open(Memc[hri_eff_area_fname], READ_ONLY, BINARY_FILE)
	    bytes = read(fd, Memr[hri_eff_area],
				RHRI_RSPBINS * RHRI_OFFAR * SZ_REAL)
	    call close(fd)

	    #-------------------------------------------------------------
	    # read in off axis coefficients (RHRI_RSPBINS +1) x PSPC_OFFAR
	    #-------------------------------------------------------------
	    fd = open(Memc[offar_fname], READ_ONLY, BINARY_FILE)
	    bytes = read(fd, Memr[offar], (RHRI_RSPBINS+1)*PSPC_OFFAR*SZ_REAL)
	    call close(fd)

	    #----------------------------------------
	    # read in response bin centers and widths
	    #----------------------------------------
	    fd = open(Memc[egrid_fname], READ_ONLY, BINARY_FILE)
	    bytes = read(fd, center, RHRI_RSPBINS * SZ_REAL)
	    bytes = read(fd, widths, RHRI_RSPBINS * SZ_REAL)
	    call close(fd)

	    #-------------------------------------------------------------
	    # Build a set of edges that correspond to the response matrix
	    #------------------------------------------------------------
	    do ii = 1, RHRI_RSPBINS {
		edges[ii] = center[ii] - widths[ii] /2
	    }

	    edges[RHRI_RSPBINS + 1] =
			center[RHRI_RSPBINS] + widths[RHRI_RSPBINS] /2

	    #---------------------------
	    # convert edges in eV to KeV
	    #---------------------------
	    call amulkr(edges, .001, edges, RHRI_RSPBINS + 1)

	    init = TRUE

	}

	call salloc(response, RHRI_RSPBINS * RHRI_CHANNELS, TY_REAL)
	call salloc(response15, RHRI_RSPBINS * (RHRI_PITCH - 1), TY_REAL)
	call salloc(efftarea, RHRI_RSPBINS, TY_REAL)
	call aclrr (Memr[efftarea], RHRI_RSPBINS)

	#------------------------------------------------------
	# Sum the contributed areas from the offaxis histogram
	# this index runs from 1 to RSPBINS, the first location
	# in the caliberation file is the angle for this line.
	#------------------------------------------------------
	do ii = 1, RHRI_RSPBINS {
	    do jj = 0, PSPC_OFFAR - 1 {
		Memr[efftarea + ii - 1] = Memr[efftarea + ii - 1] + DS_OAH(dataset, jj) * Memr[offar + jj * (RHRI_RSPBINS+1) + ii] / Memr[offar + 0  * (RHRI_RSPBINS+1) + ii]
	    }
	}

	#------
	#
	#-------
	do ii = 0, RHRI_RSPBINS - 1 {
	    Memr[efftarea + ii] = Memr[efftarea + ii] * Memr[hri_eff_area + ii]
	}

	#---------------------------------------------------------
	# Apply the computed effective area to the response matrix
	#---------------------------------------------------------

	#--------------
	# For 1 channel
	#--------------
	if ( DS_NPHAS(dataset) == RHRI_CHANNELS ) {
	    do ii = 0, RHRI_RSPBINS - 1 {
		do jj = 0, RHRI_CHANNELS - 1 {
		    Memr[response + ii + jj * RHRI_RSPBINS] =
		Memr[matrix + ii + jj * RHRI_RSPBINS] * Memr[efftarea + ii]
		}
	    }
	}

	#-------------------
	# or for 15 Channels
	#-------------------
	else {
	    do ii = 0, RHRI_RSPBINS - 1 {
		do jj = 0, (RHRI_PITCH -1) - 1 {
		    Memr[response15 + ii + jj * RHRI_RSPBINS] =
		Memr[matrix15 + ii + jj * RHRI_RSPBINS] * Memr[efftarea + ii]
		}
	    }
	}

	call salloc(unlogged, SPECTRAL_BINS, TY_DOUBLE)
	call salloc(rebinned, RHRI_RSPBINS, TY_DOUBLE)

	call unlog_array(model, Memd[unlogged], SPECTRAL_BINS)

	call rebin_model(Memd[unlogged], Memd[rebinned], edges, RHRI_RSPBINS)

	spectrum = DS_PRED_DATA(dataset)

	if ( DS_NPHAS(dataset) == RHRI_CHANNELS ) {
	    call aclrr(Memr[spectrum], RHRI_CHANNELS)
	}
	else {
	    call aclrr(Memr[spectrum], (RHRI_PITCH - 1))
	}

	#-----------------------------------------------------------
	# Apply the detector response to the rebinned model spectrum
	#-----------------------------------------------------------

	#--------------
	# For 1 channel
	#--------------
	if ( DS_NPHAS(dataset) == RHRI_CHANNELS ) {
	    do ii = 0, RHRI_RSPBINS - 1 {
		do jj = 0, RHRI_CHANNELS - 1 {
		    Memr[spectrum + jj]  = Memr[spectrum + jj] +
		    Memd[rebinned + ii] * Memr[response + ii + jj*RHRI_RSPBINS]
		}
	    }
	}

	#-------------------
	# or for 15 Channels
	#-------------------
	else {
	    do ii = 0, RHRI_RSPBINS - 1 {
		do jj = 0, (RHRI_PITCH - 1) - 1 {
		    Memr[spectrum + jj]  = Memr[spectrum + jj] +
		    Memd[rebinned + ii] * Memr[response15 + ii + jj*RHRI_RSPBINS]
		}
	    }
	}

	call sfree(sp)

end

#
# Function:	rhri_energy
# Purpose:	To "calculate" ROSAT HRI energy boundaries
# Pre-cond:	
#		
# Post-cond:	
#		
# Method:	
# Description:	
# Notes:	
#

procedure rhri_energy(energies, nbounds)

real	energies[nbounds]
int	nbounds

begin
	if ( ! (( nbounds != RHRI_CHANNELS + 1 ) ||
		( nbounds != RHRI_PITCH -1 + 1 ))   )
	    call error(1, "Requested number of energy bounds does not match detector bins")

	if ( nbounds == RHRI_CHANNELS + 1 ) {
	    energies[1]  = 0.01
	    energies[2]  = 2.57
	}
	else {
	    energies[1]  = 0.17
	    energies[2]	 = 0.33
	    energies[3]  = 0.49
	    energies[4]  = 0.65
	    energies[5]  = 0.81
	    energies[6]  = 0.97
	    energies[7]  = 1.13
	    energies[8]  = 1.29
	    energies[9]  = 1.45
	    energies[10] = 1.61
	    energies[11] = 1.77
	    energies[12] = 1.93
	    energies[13] = 2.09
	    energies[14] = 2.25
	    energies[15] = 2.41
	    energies[16] = 2.57
	}

end
