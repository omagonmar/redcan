#$Header: /home/pros/xray/xspectral/source/RCS/pspc_fold.x,v 11.0 1997/11/06 16:42:22 prosb Exp $
#$Log: pspc_fold.x,v $
#Revision 11.0  1997/11/06 16:42:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:57  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:35  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:33  prosb
#General Release 2.3
#
#Revision 6.1  93/12/02  13:54:16  dennis
#Corrected logic error that made pspc_energy() accept any value for nbounds 
#instead of just PSPC_CHANNELS + 1 or PSPC_PITCH + 1.
#
#Revision 6.0  93/05/24  16:52:25  prosb
#General Release 2.2
#
#Revision 5.4  93/05/04  16:44:17  orszak
#jso - added some memory clearing.
#
#Revision 5.3  93/02/10  14:04:51  orszak
#jso - fixed my bug in the filter (i was multipling the filter factor
#      into the static offar array).  also cleaned up the code.  will add
#      more comments latter.
#
#Revision 5.2  93/01/30  12:46:30  prosb
#jso - fixed the filter parameter so that it works correctly on all observation.
#      will add a warning to qpspec if the observation is highly shadowed.
#
#Revision 5.1  93/01/21  17:07:10  prosb
#jso - changed error message to help us out.
#
#Revision 5.0  92/10/29  22:46:06  prosb
#General Release 2.1
#
#Revision 4.1  92/10/06  10:32:04  prosb
#jso - a big hack to add a rebin option.  this will add up the important
#      data and put them in the DS structure.
#
#Revision 4.0  92/04/27  18:17:45  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/25  11:26:15  orszak
#jso - no change for first installation of new qpspec, but removed 
#      possible profanity.
#
#Revision 3.1  91/09/22  19:07:00  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:00  prosb
#General Release 1.1
#
#Revision 2.3  91/07/19  17:17:15  orszak
#jso - made change to allow users to change the PSPC data files, without
#      the files having to be read in each time pspc_fold is called.  this
#      was accomplished by looking for changes in the parameter at which
#      time the files are reread.
#
#Revision 2.2  91/07/12  16:35:52  prosb
#jso - made spectral.h system wide
#
#Revision 2.1  91/04/15  17:46:13  john
#Fix up some overindexing of the effective area tables.  This bug was intro-
#duced when the offaxis histogram format was changed.
#Make all caliberation tables static instead of malloced.
#
#Revision 2.0  91/03/06  23:06:53  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# PSPC_FOLD.X
#

include <mach.h>

include <spectral.h>

include "pspc.h"

procedure pspc_fold(fp, model, nbins)

pointer	fp					# i: file pointer
double	model[nbins]				# i: spectral model
int	nbins					# i: ???

bool	init

char	dtmat_fname[SZ_FNAME]
char	filter_fname[SZ_FNAME]
char	offar_fname[SZ_FNAME]
char	egrid_fname[SZ_FNAME]
char	fname[SZ_FNAME]

int	ii
int	jj
int	bytes
int	fd					# file descriptor for io

real	matrix[PSPC_RSPBINS, PSPC_CHANNELS]	# detector response matrix
real	center[PSPC_RSPBINS]			# detector response bins
real	widths[PSPC_RSPBINS]
real	edges[PSPC_RSPBINS + 1]			# computed bin edges
real	filter[PSPC_RSPBINS]			# filter effective area
real	offar[0:PSPC_RSPBINS, PSPC_OFFAR]	# offaxis angle effective area

pointer	unlogged				# model unlogged
pointer	rebinned				# model in PSPC_RSPBINS
pointer	efftarea
pointer	eff_off_area				# the 14 off axis area for obs
pointer	response
pointer	dataset
pointer	sp
pointer	spectrum

bool	strne()
bool	clgetb()

int	open()
int	read()

data	init	/ FALSE /

begin

	call smark(sp)

	dataset = FP_OBSERSTACK(fp,FP_CURDATASET(fp))

	if ( DS_NPHAS(dataset) != PSPC_CHANNELS ) {
	    call error(1, "FIT: Number of channels does not match instrument response, or rebin is being used with free paramters.")
	}

	if ( DS_NOAH(dataset) != PSPC_OFFAR ) {
	    call error(1, "FIT: Number of offaxis histogram bins does not match instrument response")
	}

	if ( (DS_FILTER(dataset) != 0) && (DS_FILTER(dataset) != 1) ) {
	    call error(1, "FIT: value of FILTER is not 0 or 1.")
	}

	# read in pspc data file names; if they have changed we want to
	# reinitalize.

	# response matrix file
	call strcpy(dtmat_fname, fname, SZ_FNAME)
	call clgstr(ROS_DTMAT, dtmat_fname, SZ_FNAME)
	if ( strne(fname, dtmat_fname) ) {
	    init = FALSE
	}

	# filter file
	call strcpy(filter_fname, fname, SZ_FNAME)
	call clgstr(ROS_FILTE, filter_fname, SZ_FNAME)
	if ( strne(fname, filter_fname) ) {
	    init = FALSE
	}

	# off axis coefficients
	call strcpy(offar_fname, fname, SZ_FNAME)
	call clgstr(ROS_OFFAR, offar_fname, SZ_FNAME)
	if ( strne(fname, offar_fname) ) {
	    init = FALSE
	}

	# response bin centers and widths
	call strcpy(egrid_fname, fname, SZ_FNAME)
	call clgstr(ROS_EGRID, egrid_fname, SZ_FNAME)
	if ( strne(fname, egrid_fname) ) {
	    init = FALSE
	}

	if ( !init ) {

	    # read in response matrix (  PSPC_RSPBINS x PSPC_CHANNELS )
	    #
	    fd = open(dtmat_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, matrix, PSPC_RSPBINS*PSPC_CHANNELS*SZ_REAL)
	    call close(fd)

	    # read in filter
	    #
	    fd = open(filter_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, filter, PSPC_RSPBINS * SZ_REAL)
	    call close(fd)

	    # read in off axis coefficients (PSPC_RSPBINS +1) x PSPC_OFFAR
	    #
	    fd = open(offar_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, offar, (PSPC_RSPBINS + 1)*PSPC_OFFAR*SZ_REAL)
	    call close(fd)

	    # read in response bin centers and widths
	    #
	    fd = open(egrid_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, center, PSPC_RSPBINS * SZ_REAL)
	    bytes = read(fd, widths, PSPC_RSPBINS * SZ_REAL)
	    call close(fd)

	    # Build a set of edges that correspond to the response matrix
	    #
	    do ii = 1, PSPC_RSPBINS {
		edges[ii] = center[ii] - widths[ii] /2
	    }

	    edges[PSPC_RSPBINS + 1] =
			center[PSPC_RSPBINS] + widths[PSPC_RSPBINS]/2

	    # convert edges in eV to KeV
	    #
	    call amulkr(edges, .001, edges, PSPC_RSPBINS + 1)

	    init = TRUE
	}

	call salloc(response, PSPC_RSPBINS * PSPC_CHANNELS, TY_REAL)
	call aclrr(Memr[response], PSPC_RSPBINS * PSPC_CHANNELS)

	call salloc(efftarea, PSPC_RSPBINS, TY_REAL)
	call aclrr(Memr[efftarea], PSPC_RSPBINS)

	call salloc(eff_off_area, (PSPC_RSPBINS + 1)*PSPC_OFFAR, TY_REAL)
	call aclrr(Memr[eff_off_area], (PSPC_RSPBINS + 1)*PSPC_OFFAR)

	#------------------------------------------------------------------
	# Calculate the spectral response of the PSPC for this observation.
	#	First, if the observation is filtered multiple the
	#	off-axis effective areas bye the filtering factor.
	#	Second, sum the off -axis effective areas over the
	#	off-axis histogram for this observation.
	#	Third, multiple the effective area with the detector
	#	response .
	#------------------------------------------------------------------

	#---------------------------------------------------------------
	# Apply the filter to the effective area table, if necessary.
	# By apply it here the off-axis histogram will insure that it
	# is correctly applied for any source in the field, and with the
	# wobble (except for shadows at the edge).
	#
	# The index runs from 1 to RSPBINS because the first location
	# in the caliberation file is the angle for this line.
	#---------------------------------------------------------------
	do jj = 1, PSPC_OFFAR {
	    do ii = 1, PSPC_RSPBINS {
		Memr[eff_off_area + (jj-1)*PSPC_RSPBINS + ii-1] = offar[ii, jj]
	    }
	}

	if ( (DS_FILTER(dataset) == 1) ) {
	    do jj = 0, PSPC_FILT_ANG - 1 {
		do ii = 0, PSPC_RSPBINS - 1 {
		    Memr[eff_off_area + jj*PSPC_RSPBINS + ii] =
			Memr[eff_off_area + jj*PSPC_RSPBINS + ii] * filter[ii+1]
		}
	    }
	}

	#------------------------------------------------------------
	# Sum the contributed areas over the offaxis histogram.
	#
	# The index runs from 1 to RSPBINS because the first location
	# in the caliberation file is the angle for this line.
	#------------------------------------------------------------
	do jj = 0, PSPC_OFFAR - 1 {
	    do ii = 0, PSPC_RSPBINS - 1 {
		Memr[efftarea + ii] = Memr[efftarea + ii] +
		DS_OAH(dataset, jj) * Memr[eff_off_area + jj*PSPC_RSPBINS + ii]
	    }
	}

	#---------------------------------------------------------
	# Apply the computed effective area to the response matrix
	#---------------------------------------------------------
	do jj = 1, PSPC_CHANNELS {
	    do ii = 1, PSPC_RSPBINS {
		Memr[response + (jj-1)*PSPC_RSPBINS + ii-1] =
				matrix[ii, jj] * Memr[efftarea + ii - 1]
	    }
	}

	call salloc(unlogged, SPECTRAL_BINS, TY_DOUBLE)
	call salloc(rebinned, PSPC_RSPBINS, TY_DOUBLE)

	call unlog_array(model, Memd[unlogged], SPECTRAL_BINS)

	call aclrd(Memd[rebinned], PSPC_RSPBINS)
	call rebin_model(Memd[unlogged], Memd[rebinned], edges, PSPC_RSPBINS)

	spectrum = DS_PRED_DATA(dataset)

	call aclrr(Memr[spectrum], PSPC_CHANNELS)


	# Apply the detector response to the rebinned model spectrum
	#
	do jj = 0, PSPC_CHANNELS - 1 {
	    do ii = 0, PSPC_RSPBINS - 1 {
		Memr[spectrum + jj] = Memr[spectrum + jj] +
					Memd[rebinned + ii] *
					Memr[response + jj*PSPC_RSPBINS + ii]
	    }
	}

	if ( clgetb("rebin") ) {
	    call do_single_chan(spectrum, dataset)
	}

	call sfree(sp)

end

procedure pspc_energy(energies, nbounds)

real	energies[nbounds]
int	nbounds

int	ii
int	N

real	edges[PSPC_PITCH + 1]
real	elower
real	DE256
real	A
real	A2
real	Y

begin

	if ((nbounds != PSPC_CHANNELS + 1) && (nbounds != PSPC_PITCH + 1)) {
	    call error(1, 
	 "FIT: Requested number of energy bounds does not match detector bins")
	}

	# This code is translated from MPE:PSPC functions
	# se:geten.for
	# pspc.genlib:xmpinv.for
	#

	do ii = 1, PSPC_PITCH + 1 {
	    edges[ii] = ii / 0.1
	}

	if ( nbounds == PSPC_PITCH + 1 ) {
	    do ii = 1, PSPC_PITCH + 1 {
		energies[ii] = edges[ii]
	    }
	}

	else {

	    DE256  = edges[2] - edges[1]
	    elower = edges[PSPC_LOTHRESH]

	    A = 2.45
	    A2= A*A

	    do ii = 1, nbounds - 1 {
		energies[ii] = elower

		Y = A * (A + sqrt(A2 + 16.0 * elower)) * .25
		N = Y / DE256 + .5

		elower = elower + N * DE256
	    }

	    energies[nbounds] = elower
	}

	# eV --> KeV
	call amulkr(energies, .001, energies, nbounds)

end

int procedure pspc_pi(nn)

int	nn

int	ii
int	bin
int	compr[PSPC_PITCH]

pointer	e34
pointer	e256
pointer	sp

bool	init

data	init	/ FALSE /

begin

	if ( !init ) {

	    call smark(sp)

	    call salloc(e34, PSPC_CHANNELS + 1, TY_REAL)
	    call salloc(e256, PSPC_PITCH + 1, TY_REAL)

	    call pspc_energy(Memr[e34], PSPC_CHANNELS + 1)
	    call pspc_energy(Memr[e256], PSPC_PITCH + 1)

	    bin = 1
	    do ii = 0, PSPC_HITHRESH {
		if ( Memr[e256 + ii] >= Memr[e34 + bin] ) {
		    bin = bin + 1
		}

		compr[ii + 1] = bin
	    }

	    call sfree(sp)

	    init = TRUE

	}

	if ( nn < PSPC_LOTHRESH ) return 0
	if ( nn > PSPC_HITHRESH ) return 35

	return compr[nn]

end

procedure do_single_chan(spectrum, dataset)

pointer	dataset
pointer	spectrum

int	display
int	jj

real	net_cnts
real	net_err
real	pred_cnts

begin

	display = 1

	pred_cnts = 0.0
	net_cnts = 0.0
	net_err	= 0.0

	do jj = 0, PSPC_CHANNELS - 1 {

	    if ( Memi[DS_CHANNEL_FIT(dataset) + jj] != 0 ) {
		pred_cnts = pred_cnts + Memr[spectrum + jj]
		net_cnts = net_cnts + Memr[DS_OBS_DATA(dataset) + jj]
		net_err = net_err +
			(Memr[DS_OBS_ERROR(dataset) + jj] *
				Memr[DS_OBS_ERROR(dataset) + jj])
		Memi[DS_CHANNEL_FIT(dataset) + jj] = 0
	    }
	}

	DS_NPHAS(dataset) = 1
	Memr[DS_LO_ENERGY(dataset)] = Memr[DS_LO_ENERGY(dataset)]
	Memr[DS_HI_ENERGY(dataset)] = Memr[DS_HI_ENERGY(dataset) +
						PSPC_CHANNELS - 1]
	Memr[DS_OBS_DATA(dataset)] = net_cnts
	Memr[DS_OBS_ERROR(dataset)] = sqrt(net_err)
	Memr[DS_PRED_DATA(dataset)] = pred_cnts
	Memi[DS_CHANNEL_FIT(dataset)] = 1

end
