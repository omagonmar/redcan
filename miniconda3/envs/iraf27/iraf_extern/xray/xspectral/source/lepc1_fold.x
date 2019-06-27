#$Header: /home/pros/xray/xspectral/source/RCS/lepc1_fold.x,v 11.0 1997/11/06 16:42:26 prosb Exp $
#$Log: lepc1_fold.x,v $
#Revision 11.0  1997/11/06 16:42:26  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:05  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:31  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:06  prosb
#General Release 2.3
#
#Revision 1.2  93/11/05  09:44:46  mo
#MC	11/5/93		Updated with Allan's latest fix
#
#Revision 1.1  93/10/22  19:58:16  dennis
#Initial revision
#
#
# Module:	lepc1_fold.x
# Project:	PROS -- ROSAT RSDC
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
#
# Another copy, for LEPC1, allan 93/10/05
# Copy of pspc_fold.x, changed PSPC -> HEPC1 
# 				allan 93/07/13
# Energies from egr file is in keV!
# 931103, allan
#
# LEPC1_FOLD.X
#

include <mach.h>

include <spectral.h>

include "lepc1.h"

procedure lepc1_fold(fp, model, nbins)

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

real	matrix[LEPC1_RSPBINS, LEPC1_CHANNELS]	# detector response matrix
real	center[LEPC1_RSPBINS]			# detector response bins
real	widths[LEPC1_RSPBINS]
real	edges[LEPC1_RSPBINS + 1]			# computed bin edges
real	filter[LEPC1_RSPBINS]			# filter effective area
real	offar[0:LEPC1_RSPBINS, LEPC1_OFFAR]	# offaxis angle effective area

pointer	unlogged				# model unlogged
pointer	rebinned				# model in LEPC1_RSPBINS
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

	if ( DS_NPHAS(dataset) != LEPC1_CHANNELS ) {
	    call error(1, "FIT: Number of channels does not match instrument response, or rebin is being used with free paramters.")
	}

	if ( DS_NOAH(dataset) != LEPC1_OFFAR ) {
	    call error(1, "FIT: Number of offaxis histogram bins does not match instrument response")
	}

	if ( (DS_FILTER(dataset) != 0) && (DS_FILTER(dataset) != 1) ) {
	    call error(1, "FIT: value of FILTER is not 0 or 1.")
	}

	# read in lepc1 data file names; if they have changed we want to
	# reinitalize.

	# response matrix file
	call strcpy(dtmat_fname, fname, SZ_FNAME)
	call clgstr(SRG_L1_DTMAT, dtmat_fname, SZ_FNAME)
	if ( strne(fname, dtmat_fname) ) {
	    init = FALSE
	}

	# filter file
	call strcpy(filter_fname, fname, SZ_FNAME)
	call clgstr(SRG_L1_FILTE, filter_fname, SZ_FNAME)
	if ( strne(fname, filter_fname) ) {
	    init = FALSE
	}

	# off axis coefficients
	call strcpy(offar_fname, fname, SZ_FNAME)
	call clgstr(SRG_L1_OFFAR, offar_fname, SZ_FNAME)
	if ( strne(fname, offar_fname) ) {
	    init = FALSE
	}

	# response bin centers and widths
	call strcpy(egrid_fname, fname, SZ_FNAME)
	call clgstr(SRG_L1_EGRID, egrid_fname, SZ_FNAME)
	if ( strne(fname, egrid_fname) ) {
	    init = FALSE
	}

	if ( !init ) {

	    # read in response matrix (  LEPC1_RSPBINS x LEPC1_CHANNELS )
	    #
	    fd = open(dtmat_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, matrix, LEPC1_RSPBINS*LEPC1_CHANNELS*SZ_REAL)
	    call close(fd)

	    # read in filter
	    #
	    fd = open(filter_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, filter, LEPC1_RSPBINS * SZ_REAL)
	    call close(fd)

	    # read in off axis coefficients (LEPC1_RSPBINS +1) x LEPC1_OFFAR
	    #
	    fd = open(offar_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, offar, (LEPC1_RSPBINS + 1)*LEPC1_OFFAR*SZ_REAL)
	    call close(fd)

	    # read in response bin centers and widths
	    #
	    fd = open(egrid_fname, READ_ONLY, BINARY_FILE)
	    bytes = read(fd, center, LEPC1_RSPBINS * SZ_REAL)
	    bytes = read(fd, widths, LEPC1_RSPBINS * SZ_REAL)
	    call close(fd)

	    # Build a set of edges that correspond to the response matrix
	    #
	    do ii = 1, LEPC1_RSPBINS {
		edges[ii] = center[ii] - widths[ii] /2
	    }

	    edges[LEPC1_RSPBINS + 1] =
			center[LEPC1_RSPBINS] + widths[LEPC1_RSPBINS]/2

	    # convert edges in eV to KeV
	    #
#	    call amulkr(edges, .001, edges, LEPC1_RSPBINS + 1)

	    init = TRUE
	}

	call salloc(response, LEPC1_RSPBINS * LEPC1_CHANNELS, TY_REAL)
	call aclrr(Memr[response], LEPC1_RSPBINS * LEPC1_CHANNELS)

	call salloc(efftarea, LEPC1_RSPBINS, TY_REAL)
	call aclrr(Memr[efftarea], LEPC1_RSPBINS)

	call salloc(eff_off_area, (LEPC1_RSPBINS + 1)*LEPC1_OFFAR, TY_REAL)
	call aclrr(Memr[eff_off_area], (LEPC1_RSPBINS + 1)*LEPC1_OFFAR)

	#------------------------------------------------------------------
	# Calculate the spectral response of the LEPC1 for this observation.
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
	do jj = 1, LEPC1_OFFAR {
	    do ii = 1, LEPC1_RSPBINS {
		Memr[eff_off_area + (jj-1)*LEPC1_RSPBINS + ii-1] = offar[ii, jj]
	    }
	}

	if ( (DS_FILTER(dataset) == 1) ) {
	    do jj = 0, LEPC1_FILT_ANG - 1 {
		do ii = 0, LEPC1_RSPBINS - 1 {
		    Memr[eff_off_area + jj*LEPC1_RSPBINS + ii] =
			Memr[eff_off_area + jj*LEPC1_RSPBINS + ii] * filter[ii+1]
		}
	    }
	}

	#------------------------------------------------------------
	# Sum the contributed areas over the offaxis histogram.
	#
	# The index runs from 1 to RSPBINS because the first location
	# in the caliberation file is the angle for this line.
	#------------------------------------------------------------
	do jj = 0, LEPC1_OFFAR - 1 {
	    do ii = 0, LEPC1_RSPBINS - 1 {
		Memr[efftarea + ii] = Memr[efftarea + ii] +
		DS_OAH(dataset, jj) * Memr[eff_off_area + jj*LEPC1_RSPBINS + ii]
	    }
	}

	#---------------------------------------------------------
	# Apply the computed effective area to the response matrix
	#---------------------------------------------------------
	do jj = 1, LEPC1_CHANNELS {
	    do ii = 1, LEPC1_RSPBINS {
		Memr[response + (jj-1)*LEPC1_RSPBINS + ii-1] =
				matrix[ii, jj] * Memr[efftarea + ii - 1]
	    }
	}

	call salloc(unlogged, SPECTRAL_BINS, TY_DOUBLE)
	call salloc(rebinned, LEPC1_RSPBINS, TY_DOUBLE)

	call unlog_array(model, Memd[unlogged], SPECTRAL_BINS)

	call aclrd(Memd[rebinned], LEPC1_RSPBINS)
	call rebin_model(Memd[unlogged], Memd[rebinned], edges, LEPC1_RSPBINS)

	spectrum = DS_PRED_DATA(dataset)

	call aclrr(Memr[spectrum], LEPC1_CHANNELS)


	# Apply the detector response to the rebinned model spectrum
	#
	do jj = 0, LEPC1_CHANNELS - 1 {
	    do ii = 0, LEPC1_RSPBINS - 1 {
		Memr[spectrum + jj] = Memr[spectrum + jj] +
					Memd[rebinned + ii] *
					Memr[response + jj*LEPC1_RSPBINS + ii]
	    }
	}

	if ( clgetb("rebin") ) {
	    call dol1_single_chan(spectrum, dataset)
	}

	call sfree(sp)

end

# Energy procedure differs from the PSPC by reading LOW and HIGH
# from par-file pkgpars.par
# 931005, allan

procedure lepc1_energy(energies, nbounds)

real	energies[nbounds]
int	nbounds

real 	low_en
real	high_en
real 	increment

int 	ii

real	clgetr()

begin
	low_en = clgetr("srg_lepc1_low_energy")
	high_en = clgetr("srg_lepc1_high_energy")
	
	increment = (high_en - low_en) / (nbounds -1 )

	do ii = 1,nbounds {
		energies[ii] = low_en + increment*(ii-1)
	}
end

# Original pspc_pi procedure.
int procedure lepc1_pi(nn)

int	nn

int	ii
int	bin
int	compr[LEPC1_PITCH]

pointer	e34
pointer	e256
pointer	sp

bool	init

data	init	/ FALSE /

begin

	if ( !init ) {

	    call smark(sp)

	    call salloc(e34, LEPC1_CHANNELS + 1, TY_REAL)
	    call salloc(e256, LEPC1_PITCH + 1, TY_REAL)

	    call lepc1_energy(Memr[e34], LEPC1_CHANNELS + 1)
	    call lepc1_energy(Memr[e256], LEPC1_PITCH + 1)

	    bin = 1
	    do ii = 0, LEPC1_HITHRESH {
		if ( Memr[e256 + ii] >= Memr[e34 + bin] ) {
		    bin = bin + 1
		}

		compr[ii + 1] = bin
	    }

	    call sfree(sp)

	    init = TRUE

	}

	if ( nn < LEPC1_LOTHRESH ) return 0
# Change 35->129 for LEPC
	if ( nn > LEPC1_HITHRESH ) return 129

	return compr[nn]

end

procedure dol1_single_chan(spectrum, dataset)

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

	do jj = 0, LEPC1_CHANNELS - 1 {

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
						LEPC1_CHANNELS - 1]
	Memr[DS_OBS_DATA(dataset)] = net_cnts
	Memr[DS_OBS_ERROR(dataset)] = sqrt(net_err)
	Memr[DS_PRED_DATA(dataset)] = pred_cnts
	Memi[DS_CHANNEL_FIT(dataset)] = 1

end
