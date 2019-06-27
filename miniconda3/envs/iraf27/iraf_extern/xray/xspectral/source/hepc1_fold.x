#$Header: /home/pros/xray/xspectral/source/RCS/hepc1_fold.x,v 11.0 1997/11/06 16:42:20 prosb Exp $
#$Log: hepc1_fold.x,v $
#Revision 11.0  1997/11/06 16:42:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:52  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:00  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:44  prosb
#General Release 2.3
#
#Revision 1.1  93/10/22  19:57:37  dennis
#Initial revision
#
#
# Module:	hepc1_fold.x
# Project:	PROS -- ROSAT RSDC
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
#
# Copy of pspc_fold.x, changed PSPC -> HEPC1 
# 				allan 93/07/13
#
# HEPC1_FOLD.X
#

include <mach.h>

include <spectral.h>

include "hepc1.h"

procedure hepc1_fold(fp, model, nbins)

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

real	matrix[HEPC1_RSPBINS, HEPC1_CHANNELS]	# detector response matrix
real	center[HEPC1_RSPBINS]			# detector response bins
real	widths[HEPC1_RSPBINS]
real	edges[HEPC1_RSPBINS + 1]			# computed bin edges
real	filter[HEPC1_RSPBINS]			# filter effective area
real	offar[0:HEPC1_RSPBINS, HEPC1_OFFAR]	# offaxis angle effective area

pointer	unlogged				# model unlogged
pointer	rebinned				# model in HEPC1_RSPBINS
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

	if ( DS_NPHAS(dataset) != HEPC1_CHANNELS ) {
	    call error(1, "FIT: Number of channels does not match instrument response, or rebin is being used with free paramters.")
	}

	if ( DS_NOAH(dataset) != HEPC1_OFFAR ) {
	    call error(1, "FIT: Number of offaxis histogram bins does not match instrument response")
	}

	if ( (DS_FILTER(dataset) != 0) && (DS_FILTER(dataset) != 1) ) {
	    call error(1, "FIT: value of FILTER is not 0 or 1.")
	}

	# read in hepc1 data file names; if they have changed we want to
	# reinitalize.

	# response matrix file
	call strcpy(dtmat_fname, fname, SZ_FNAME)
	call clgstr(SRG_H1_DTMAT, dtmat_fname, SZ_FNAME)
	if ( strne(fname, dtmat_fname) ) {
	    init = FALSE
	}

	# filter file
	call strcpy(filter_fname, fname, SZ_FNAME)
	call clgstr(SRG_H1_FILTE, filter_fname, SZ_FNAME)
	if ( strne(fname, filter_fname) ) {
	    init = FALSE
	}

	# off axis coefficients
	call strcpy(offar_fname, fname, SZ_FNAME)
	call clgstr(SRG_H1_OFFAR, offar_fname, SZ_FNAME)
	if ( strne(fname, offar_fname) ) {
	    init = FALSE
	}

	# response bin centers and widths
	call strcpy(egrid_fname, fname, SZ_FNAME)
	call clgstr(SRG_H1_EGRID, egrid_fname, SZ_FNAME)
	if ( strne(fname, egrid_fname) ) {
	    init = FALSE
	}

	if ( !init ) {

	    # read in response matrix (  HEPC1_RSPBINS x HEPC1_CHANNELS )
	    #
	    fd = open(dtmat_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, matrix, HEPC1_RSPBINS*HEPC1_CHANNELS*SZ_REAL)
	    call close(fd)

	    # read in filter
	    #
	    fd = open(filter_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, filter, HEPC1_RSPBINS * SZ_REAL)
	    call close(fd)

	    # read in off axis coefficients (HEPC1_RSPBINS +1) x HEPC1_OFFAR
	    #
	    fd = open(offar_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, offar, (HEPC1_RSPBINS + 1)*HEPC1_OFFAR*SZ_REAL)
	    call close(fd)

	    # read in response bin centers and widths
	    #
	    fd = open(egrid_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, center, HEPC1_RSPBINS * SZ_REAL)
	    bytes = read(fd, widths, HEPC1_RSPBINS * SZ_REAL)
	    call close(fd)

	    # Build a set of edges that correspond to the response matrix
	    #
	    do ii = 1, HEPC1_RSPBINS {
		edges[ii] = center[ii] - widths[ii] /2
	    }

	    edges[HEPC1_RSPBINS + 1] =
			center[HEPC1_RSPBINS] + widths[HEPC1_RSPBINS]/2

	    # convert edges in eV to KeV
	    #
#	    call amulkr(edges, .001, edges, HEPC1_RSPBINS + 1)

	    init = TRUE
	}

	call salloc(response, HEPC1_RSPBINS * HEPC1_CHANNELS, TY_REAL)
	call aclrr(Memr[response], HEPC1_RSPBINS * HEPC1_CHANNELS)

	call salloc(efftarea, HEPC1_RSPBINS, TY_REAL)
	call aclrr(Memr[efftarea], HEPC1_RSPBINS)

	call salloc(eff_off_area, (HEPC1_RSPBINS + 1)*HEPC1_OFFAR, TY_REAL)
	call aclrr(Memr[eff_off_area], (HEPC1_RSPBINS + 1)*HEPC1_OFFAR)

	#------------------------------------------------------------------
	# Calculate the spectral response of the HEPC1 for this observation.
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
	do jj = 1, HEPC1_OFFAR {
	    do ii = 1, HEPC1_RSPBINS {
		Memr[eff_off_area + (jj-1)*HEPC1_RSPBINS + ii-1] = offar[ii, jj]
	    }
	}

	if ( (DS_FILTER(dataset) == 1) ) {
	    do jj = 0, HEPC1_FILT_ANG - 1 {
		do ii = 0, HEPC1_RSPBINS - 1 {
		    Memr[eff_off_area + jj*HEPC1_RSPBINS + ii] =
			Memr[eff_off_area + jj*HEPC1_RSPBINS + ii] * filter[ii+1]
		}
	    }
	}

	#------------------------------------------------------------
	# Sum the contributed areas over the offaxis histogram.
	#
	# The index runs from 1 to RSPBINS because the first location
	# in the caliberation file is the angle for this line.
	#------------------------------------------------------------
	do jj = 0, HEPC1_OFFAR - 1 {
	    do ii = 0, HEPC1_RSPBINS - 1 {
		Memr[efftarea + ii] = Memr[efftarea + ii] +
		DS_OAH(dataset, jj) * Memr[eff_off_area + jj*HEPC1_RSPBINS + ii]
	    }
	}

	#---------------------------------------------------------
	# Apply the computed effective area to the response matrix
	#---------------------------------------------------------
	do jj = 1, HEPC1_CHANNELS {
	    do ii = 1, HEPC1_RSPBINS {
		Memr[response + (jj-1)*HEPC1_RSPBINS + ii-1] =
				matrix[ii, jj] * Memr[efftarea + ii - 1]
	    }
	}

	call salloc(unlogged, SPECTRAL_BINS, TY_DOUBLE)
	call salloc(rebinned, HEPC1_RSPBINS, TY_DOUBLE)

	call unlog_array(model, Memd[unlogged], SPECTRAL_BINS)

	call aclrd(Memd[rebinned], HEPC1_RSPBINS)
	call rebin_model(Memd[unlogged], Memd[rebinned], edges, HEPC1_RSPBINS)

	spectrum = DS_PRED_DATA(dataset)

	call aclrr(Memr[spectrum], HEPC1_CHANNELS)


	# Apply the detector response to the rebinned model spectrum
	#
	do jj = 0, HEPC1_CHANNELS - 1 {
	    do ii = 0, HEPC1_RSPBINS - 1 {
		Memr[spectrum + jj] = Memr[spectrum + jj] +
					Memd[rebinned + ii] *
					Memr[response + jj*HEPC1_RSPBINS + ii]
	    }
	}

	if ( clgetb("rebin") ) {
	    call do1_single_chan(spectrum, dataset)
	}

	call sfree(sp)

end

#procedure hepc1_energy(energies, nbounds)
#
#real	energies[nbounds]
#int	nbounds
# 
#int	ii
#int	N
# 
#real	edges[HEPC1_PITCH + 1]
#real	elower
#real	DE256
#real	A
#real	A2
#real	Y
#
#begin
#
#	if ( !(( nbounds != HEPC1_CHANNELS + 1 ) ||
#		( nbounds != HEPC1_PITCH + 1  )) ) {
#	    call error(1, "FIT: Requested number of energy bounds does not match detector bins")
#	}
# 
#	# This code is translated from MPE:PSPC functions
#	# se:geten.for
#	# hepc1.genlib:xmpinv.for
#	#
# 
#	do ii = 1, HEPC1_PITCH + 1 {
#	    edges[ii] = ii / 0.1
#	}
# 
#	if ( nbounds == HEPC1_PITCH + 1 ) {
#	    do ii = 1, HEPC1_PITCH + 1 {
#		energies[ii] = edges[ii]
#	    }
#	}
#
#	else {
#
#	    DE256  = edges[2] - edges[1]
#	    elower = edges[HEPC1_LOTHRESH]
#
#	    A = 2.45
#	    A2= A*A
#
#	    do ii = 1, nbounds - 1 {
#		energies[ii] = elower
#
#		Y = A * (A + sqrt(A2 + 16.0 * elower)) * .25
#		N = Y / DE256 + .5
## 
#		elower = elower + N * DE256
#	    }
#
#	    energies[nbounds] = elower
#	}
#
#	# eV --> KeV
#	call amulkr(energies, .001, energies, nbounds)
#
#end

# Energy procedure differs from the PSPC by reading LOW and HIGH
# from par-file pkgpars.par
# 931005, allan

procedure hepc1_energy(energies, nbounds)

real	energies[nbounds]
int	nbounds

real 	low_en
real	high_en
real 	increment

int 	ii

real	clgetr()

begin
	low_en = clgetr("srg_hepc1_low_energy")
	high_en = clgetr("srg_hepc1_high_energy")
	
	increment = (high_en - low_en) / (nbounds -1 )

	do ii = 1,nbounds {
		energies[ii] = low_en + increment*(ii-1)
	}
end

# Original pspc_pi procedure.
int procedure hepc1_pi(nn)

int	nn

int	ii
int	bin
int	compr[HEPC1_PITCH]

pointer	e34
pointer	e256
pointer	sp

bool	init

data	init	/ FALSE /

begin

	if ( !init ) {

	    call smark(sp)

	    call salloc(e34, HEPC1_CHANNELS + 1, TY_REAL)
	    call salloc(e256, HEPC1_PITCH + 1, TY_REAL)

	    call hepc1_energy(Memr[e34], HEPC1_CHANNELS + 1)
	    call hepc1_energy(Memr[e256], HEPC1_PITCH + 1)

	    bin = 1
	    do ii = 0, HEPC1_HITHRESH {
		if ( Memr[e256 + ii] >= Memr[e34 + bin] ) {
		    bin = bin + 1
		}

		compr[ii + 1] = bin
	    }

	    call sfree(sp)

	    init = TRUE

	}

	if ( nn < HEPC1_LOTHRESH ) return 0
#	if ( nn > HEPC1_HITHRESH ) return 35
 	if ( nn > HEPC1_HITHRESH ) return 129

	return compr[nn]

end

procedure do1_single_chan(spectrum, dataset)

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

	do jj = 0, HEPC1_CHANNELS - 1 {

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
						HEPC1_CHANNELS - 1]
	Memr[DS_OBS_DATA(dataset)] = net_cnts
	Memr[DS_OBS_ERROR(dataset)] = sqrt(net_err)
	Memr[DS_PRED_DATA(dataset)] = pred_cnts
	Memi[DS_CHANNEL_FIT(dataset)] = 1

end
