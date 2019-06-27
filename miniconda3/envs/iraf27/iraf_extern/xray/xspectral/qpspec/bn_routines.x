#$Header: /home/pros/xray/xspectral/qpspec/RCS/bn_routines.x,v 11.0 1997/11/06 16:43:27 prosb Exp $
#$Log: bn_routines.x,v $
#Revision 11.0  1997/11/06 16:43:27  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:43  prosb
#General Release 2.4
#
#Revision 8.1  1994/10/04  01:19:54  dennis
#Corrected error in bn_off_axis():  Formerly used QP_CDELT1(shead) for
#degrees per pixel for computing DS_MEAN_EVENT_OFFAXIS_ANGLE(ds);
#corrected to use QP_INPXX(shead).
#
#Revision 8.0  94/06/27  17:35:59  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/18  18:14:22  dennis
#Eliminated restrictions on allowed regions; corrected Einstein IPC 
#orthodox region check and its warning message.
#
#Revision 7.1  94/04/09  00:51:20  dennis
#Changes to calculate mean off-axis angle of counted events, in addition to 
#off-axis angle of center of region.
#
#Revision 7.0  93/12/27  18:58:14  prosb
#General Release 2.3
#
#Revision 6.5  93/12/03  01:41:14  dennis
#Added poisserr, to select Poisson or Gaussian error estimation from data.
#
#Revision 6.4  93/11/03  00:25:41  dennis
#Make background contribution to error 0.0 if no background, and make 
#charged particle contribution to errors 0.0 if no charged particle 
#counting
#
#Revision 6.3  93/10/22  18:28:46  dennis
#Added SRG_HEPC1, SRG_LEPC1 cases, for DSRI.
#
#Revision 6.2  93/10/15  23:50:32  dennis
#Changed computation of estimated errors, to use one_sigma().
#
#Revision 6.1  93/07/02  14:46:58  mo
#MC	7/2/93		Correct boolean initializations to use TRUE/FALSE
#			and correct test syntax (RS6000 port)
#
#Revision 6.0  93/05/24  16:53:38  prosb
#General Release 2.2
#
#Revision 5.7  93/05/13  23:48:19  dennis
#In bn_getxy(), check for accelerators in region spec; they're not allowed.
#
#Revision 5.6  93/05/12  15:44:22  orszak
#>> jso - passed in dobkgd so that vign_correct can give an error if
#         there is no background.
#
#Revision 5.5  93/05/08  17:55:04  orszak
#jso - changed display levels.
#
#Revision 5.4  93/05/08  17:49:36  orszak
#jso - removed include ext.h
#
#Revision 5.3  93/05/05  00:40:54  dennis
#In bn_getxy(), corrected handling of FIELD (which has no center coords).
#
#Revision 5.2  93/05/01  12:40:12  orszak
#jso - changes to do vignetting subtraction
#
#Revision 5.1  93/04/27  00:23:30  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  22:46:43  prosb
#General Release 2.1
#
#Revision 4.3  92/10/22  15:31:57  orszak
#jso - float should be real
#
#Revision 4.2  92/10/22  14:00:14  orszak
#jso - fix for the change to doubles in MWCS.
#
#Revision 4.1  92/07/09  11:11:38  prosb
#jso - changed a help message for clearity.
#
#Revision 4.0  92/04/27  15:28:56  prosb
#General Release 2.0:  April 1992
#
#Revision 3.6  92/04/01  11:01:35  prosb
#jso - add a routine to check if a region ends in .pl and if so aviod the
#      rg2_qpparse calls that cannot deal with it.
#
#Revision 3.3  91/10/25  22:45:04  prosb
#jso - if polygon it should return, but should it zero out x and y?
#      i will have to check this.
#
#Revision 3.2  91/09/22  19:07:06  wendy
#Added
#
#Revision 3.1  91/08/09  11:37:14  prosb
#jso - fix format statement
#
#Revision 3.0  91/08/02  01:59:03  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:41:04  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:07:05  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#	BN_ROUTINES - subroutines to support creation of spectra from qpoe
#

include <mach.h>

include <regparse.h>
include <spectral.h>

include "qpspec.h"
include "../source/pspc.h"
# Following include by {l,h}epc1 intro., allan 930713, and 931005
include "../source/hepc1.h"
include "../source/lepc1.h"

#
# BN_RAWDISP -- display the counts of the separate channels
#

procedure bn_rawdisp(title, counts, indices)

char	title[ARB]		# i: title

int	indices			# i: number of separate regions
int	ii			# l: loop counter

real	counts[ARB]		# i: buffer for counts

begin

	#--------------
	# display title
	#--------------
	call printf("\n%s:\n")
	 call pargstr(title)

	call printf("BIN\t\tCOUNTS\n")

	#----------------------------------
	# display each count level and area
	#----------------------------------
	for ( ii=1; ii<=indices; ii=ii+1) {
	    call printf("%-10d\t%f\n")
	     call pargi(ii)
	     call pargr(counts[ii])
	}

	call flush(STDOUT)

end

#---------------------------------------------------------------
#
#	BN_BKGDSUB -- normalize the background and subtract from
#	the source.
#
#---------------------------------------------------------------

procedure bn_bkgdsub(src_cnts, src_area, sindices, bkgd_cnts, bkgd_area,
	bkgd_sub_cnts, bkgd_sub_err, bkgd_norm_cnts, bkgd_norm_err,
	normfactor, system, shead, sbn, bbn, dobkgd, display)

real	src_cnts[ARB]			# i: counts in source
real	src_area			# i: area in source
int	sindices			# i: number of source channels
real	bkgd_cnts[ARB]			# i: counts in bkgd
real	bkgd_area			# i: area in bkgd
real	bkgd_sub_cnts[ARB]		# o: counts in bkgd-subtracted source
real	bkgd_sub_err[ARB]		# o: error on bkgd_sub_cnts
real	bkgd_norm_cnts[ARB]		# o: counts in normalized bkgd
real	bkgd_norm_err[ARB]		# o: error on bkgd_norm_cnts
real	normfactor			# i: constant normalization factor
real	system[ARB]			# i: systematic error
pointer	shead				# i: source X-ray header
pointer	sbn
pointer	bbn
int	dobkgd				# i: YES if we have bkgd
int	display				# i: display level

int	ii				# l: loop counter

real	avg_mvr				# l: average master veto rate
real	tempnorm			# l: temp normalization
real	temperr1			# l: temp buffer for error component
real	temperr2			# l: temp buffer for error component

int	poisserr			# l: YES/NO:  Poisson/Gaussian errors
					#     (if estimating errors from data)

pointer	bkgd_particles			# l: charged particles in background
pointer	src_particles			# l: charged particles in source
pointer	bkgd_less_part_cnts		# l: background counts less particles
pointer	src_less_part_cnts		# l: source counts less particles
pointer	bkgd_less_part_err		# l: bkgd counts less particles error
pointer	src_less_part_err		# l: source counts less particles error
pointer	eff_area_norm			# l: proportion of eff area

bool	clgetb()

begin

	#--------------------------------------------
	# note: bkgd_norm_err could be allocated here
	#--------------------------------------------
	call calloc(src_particles, sindices, TY_REAL)
	call calloc(bkgd_particles, sindices, TY_REAL)
	call calloc(src_less_part_cnts, sindices, TY_REAL)
	call calloc(bkgd_less_part_cnts, sindices, TY_REAL)
	call calloc(src_less_part_err, sindices, TY_REAL)
	call calloc(bkgd_less_part_err, sindices, TY_REAL)
	call calloc(eff_area_norm, sindices, TY_REAL)

	#-----------------------------------------------------------------
	# This routine will calculate and return: 
	# - the charged particle contribution to the background and source
	# - the background normalization factor correcting for vignetting
	# - the average master veto rate (used as a flag below)
	#-----------------------------------------------------------------
	if ( clgetb("vign_correct") ) {
	    call vign_correct(Memr[src_particles], Memr[bkgd_particles],
		Memr[eff_area_norm], avg_mvr, sbn, bbn, sindices, src_area,
		bkgd_area, shead, dobkgd, display)
	}
	else {
	    for ( ii=1; ii<=sindices; ii=ii+1 ) {
		Memr[eff_area_norm + ii -1] = 1.0
	    }
	    avg_mvr = 0.0
	}

	#--------------------------------------------
	# get final norm factor with area, time, etc.
	#--------------------------------------------
	if ( bkgd_area > EPSILONR ) {
	    tempnorm = (src_area/bkgd_area) * normfactor
	}
	else {
	    tempnorm = normfactor
	}


	if (shead != NULL)
	    poisserr = QP_POISSERR(shead)
	else
	    poisserr = YES

	#----------------------------------------------------------------
	# subtract normalized background from each source in each channel
	#----------------------------------------------------------------
	for ( ii=1; ii<=sindices; ii=ii+1 ) {

	    #---------------------------------------------
	    # charged particles subtracted from background
	    #---------------------------------------------
	    Memr[bkgd_less_part_cnts + ii - 1] =
			bkgd_cnts[ii] - Memr[bkgd_particles + ii - 1]

	    #-----------------------
	    # normalized bkgd counts
	    #-----------------------
	    bkgd_norm_cnts[ii] = Memr[bkgd_less_part_cnts + ii - 1] *
			tempnorm * Memr[eff_area_norm + ii - 1]

	    #-----------------------------------------
	    # charged particles subtracted from source
	    #-----------------------------------------
	    Memr[src_less_part_cnts + ii - 1] =	src_cnts[ii] -
			Memr[src_particles + ii - 1]

	    #------------------------------
	    # bkgd-subtracted source counts
	    #------------------------------
	    bkgd_sub_cnts[ii] = Memr[src_less_part_cnts + ii - 1] -
			bkgd_norm_cnts[ii]

	    #-----------------------------------------------
	    # error on charge particle subtracted background
	    #-----------------------------------------------
	    if (dobkgd == YES) {
		call one_sigma (bkgd_cnts[ii], 1, poisserr, temperr1)
		if ( (BN_INST(sbn) == ROSAT_PSPC) && (avg_mvr >= EPSILONR) )
		    call one_sigma (Memr[bkgd_particles + ii - 1], 1, 
							poisserr, temperr2)
		else
		    temperr2 = 0.0
	    } else {
		temperr1 = 0.0
		temperr2 = 0.0
	    }
	    Memr[bkgd_less_part_err + ii - 1] = 
			sqrt( temperr1 * temperr1 + temperr2 * temperr2 )

	    #------------------------------------------
	    # error on normalized bkgd counts from data
	    #------------------------------------------
	    bkgd_norm_err[ii] = Memr[bkgd_less_part_err + ii - 1] *
			tempnorm * Memr[eff_area_norm + ii - 1]

	    #-------------------------------------------
	    # error on charge particle subtracted source
	    #-------------------------------------------
	    call one_sigma (src_cnts[ii], 1, poisserr, temperr1)
	    if ( (BN_INST(sbn) == ROSAT_PSPC) && (dobkgd == YES) && 
						(avg_mvr >= EPSILONR) )
		call one_sigma (Memr[src_particles + ii - 1], 1, 
							poisserr, temperr2)
	    else
		temperr2 = 0.0
	    Memr[src_less_part_err + ii - 1] = 
			sqrt( temperr1 * temperr1 + temperr2 * temperr2 )

	    #--------------------------------
	    # error on bkgd-subtracted counts
	    #--------------------------------
	    bkgd_sub_err[ii] = sqrt(Memr[src_less_part_err + ii - 1] *
			Memr[src_less_part_err + ii - 1] +
			(bkgd_norm_err[ii]*bkgd_norm_err[ii]))

	    #------------------------
	    # add in systematic error
	    #------------------------
	    if ( system[ii] > EPSILONR )
		bkgd_sub_err[ii] = sqrt( bkgd_sub_err[ii]*bkgd_sub_err[ii] +
		(bkgd_sub_cnts[ii]*bkgd_sub_cnts[ii]*system[ii]*system[ii]) )
	}

	call mfree(src_particles, TY_REAL)
	call mfree(bkgd_particles, TY_REAL)
	call mfree(src_less_part_cnts, TY_REAL)
	call mfree(bkgd_less_part_cnts, TY_REAL)
	call mfree(src_less_part_err, TY_REAL)
	call mfree(bkgd_less_part_err, TY_REAL)
	call mfree(eff_area_norm, TY_REAL)

end

#-----------------------------------------------------------
#
# BN_FINALDISP -- display results: counts, area, errors, etc.
#
#-------------------------------------------------------------

procedure bn_finaldisp(scounts, bncounts, bscounts, bserrors, indices)

int	ii			# l: loop counters
int	indices			# i: number of separate regions

real	bncounts[ARB]		# i: normalized bkgd counts
real	bscounts[ARB]		# i: bkgd-subtracted counts
real	bserrors[ARB]		# i: errors on bkgd-subtracted counts
real	scounts[ARB]		# i: raw counts

begin

	#--------------
	# display title
	#--------------
	call printf("\nBKGD-SUBTRACTED DATA:\n")
	call printf("BIN%3wRAW%8wBKGD%7wNET%8wNETERR\n")

	# display each set of counts, brightness, error, etc.
	do ii=1, indices {
	    call printf("%-4d%2w%-9.2f%2w%-9.4f%2w%-9.2f%2w%-9.4f\n")
	     call pargi(ii)
	     call pargr(scounts[ii])
	     call pargr(bncounts[ii])
	     call pargr(bscounts[ii])
	     call pargr(bserrors[ii])
	}

	call flush(STDOUT)

end

#--------------------------------------------------------------------------
#
#	BN_NORM -- create the final normalization factor from the
#	user specified normalization and the time normalization.
#
#--------------------------------------------------------------------------

procedure bn_norm(sbn, bbn, dobkgd, dotimenorm, display)

double	blive			# l: bkgd live time
double	slive			# l: source live time

int	display			# i: display level
int	dobkgd			# i: do we have bkgd?
int	dotimenorm		# i: add time normalization

pointer	bbn			# i: instrument-specific binning parameters
pointer	sbn			# i: instrument-specific binning parameters

begin

	#--------------------------------------------------------------
	# init time normalization factor and save initial normalization
	#---------------------------------------------------------------
	BN_TNORM(sbn) = 1.0
	BN_NORMFACTOR(sbn) = BN_UNORM(sbn)

	#--------------------
	# init STDOUT display
	#--------------------
	if( display >= 4 ) {
	    call printf("\n")
	    call flush(STDOUT)
	} # end if display

	#---------------------------------------------
	# see if we are doing time normalization
	#----------------------------------------
	if ( dotimenorm == YES ) {

	    #--------------------------------
	    # Get source and bkgd live times
	    #-------------------------------
	    if ( dobkgd == NO ) {
		if ( display >= 4 )
		    call printf("no bkgd file - using 1.0 for time norm factor\n")
	     } # end if no background

	    #--------------------------------------------------
	    # if there is a background time norm is calculated
	    #--------------------------------------------------
	    else {

		#--------------------
		# get the good times
		#--------------------
		slive = BN_GOODTIME(sbn)
		blive = BN_GOODTIME(bbn)

		#-------------------
		# display good times
		#-------------------
		if ( display >= 4 ) {
		    call printf("source good time: %.2f\n")
		     call pargd(slive)
		    call printf("bkgd good time: %.2f\n")
		     call pargd(blive)
		} # end if display

		#---------------------------------
		# check to make sure they are okay
		#---------------------------------
		if ( (slive <= EPSILOND) || (blive <= EPSILOND) ) {
		    call eprintf("bad goodtime - using 1.0 for time norm factor\n")
		    call flush(STDERR)
		    BN_TNORM(sbn) = 1.0
		} # end if bad times

		#-------------------------------------
		# if they are okay calculate time norm
		#-------------------------------------
		else {
		    BN_TNORM(sbn) = real(slive / blive)
		} # end else good times
	    } # end else background
	} # end if dotimenorm

	#----------------------------------------------------------
	# display original user and final time normalization factor
	#----------------------------------------------------------
	if ( display >= 4 ) {
	    call printf("user normalization: %.2f\n")
	     call pargr(BN_UNORM(sbn))

	    call printf("time normalization: %.2f\n")
	     call pargr(BN_TNORM(sbn))
	} # end if display

	#--------------------------------------
	# calculate final normalization factor
	#-------------------------------------
	BN_NORMFACTOR(sbn) = BN_UNORM(sbn) * BN_TNORM(sbn)

	#---------------------------
	# display final norm factor
	#--------------------------
	if ( display >= 4 ) {
	    call printf("user+time normalization: %.2f\n")
	     call pargr(BN_NORMFACTOR(sbn))
	    call flush(STDOUT)
	} # end if display

end

#---------------------------------------------
#
#  BN_AREA -- get total area in source or bkgd
#
#---------------------------------------------

procedure bn_area(pl, area)

real	area			# o: area in regions
int	ii			# l: loop counter
int	nareas			# l: number of separate areas

pointer	areas			# l: areas in each separate region
pointer	pl			# i: pl handle for region

begin

	#---------------------------------
	# get area in each separate region
	#---------------------------------
	call rg_areas(pl, areas, nareas)

	#------------
	# add them up
	#------------
	area = 0.0
	for ( ii=0; ii<nareas; ii=ii+1) {
	    area = area + real(Meml[areas+ii])
	}

	#-------------------
	# free up area space
	#-------------------
	call mfree(areas, TY_LONG)

end

#------------------------------------------------------------------
#
#	BN_BIN -- bin up photons into a spectrum the pha (or pi)
#	value is used as an offset into the result buffer
#
#------------------------------------------------------------------

define LEN_EVBUF	512

procedure bn_bin(io, spectrum, len, bn, distance_mean)

bool	good			# l: is the photon good

int	len			# i: length of spectrum, ie. indices

pointer	bn			# i: binning pointer
pointer	io			# i: event handle

real	spectrum[ARB]		# o: array to hold spectrum
real	distance_sum		# l: sum of photon off axis distances in pixels
real	distance_mean		# o: mean photon off axis distance in pixels

int	evl[LEN_EVBUF]		# l: event pointer from qpio_getevent
int	ii			# l: loop coutner
int	jj			# l: spectrum offset
int	mval			# l: mask from qpio_getevent
int	nev			# l: number of events returned

real	sum			# l: total photons in spectrum

int	pspc_pi()		# get proper crunched PSPC channel
int	hepc1_pi()		# Copy from above
int	lepc1_pi()		# Copy from above
int	qpio_getevents()	# get qpoe events

begin

	#--------------------------------
	# initialize the spectrum to zero
	#--------------------------------
	call aclrr(spectrum, len)

	#----------------------------------------------------------------------
	# initialize the offaxis histogram and cumulative offaxis angle to zero
	#----------------------------------------------------------------------
	if ( BN_NOAH(bn) != 0 ) {
	    call aclrr(BN_OAH(bn, 0), BN_NOAH(bn))
	}
	distance_sum = 0.

	#----------------------
	# get photons until EOF
	#----------------------
	while ( qpio_getevents (io, evl, mval, LEN_EVBUF, nev) != EOF ) {

	    #---------------------
	    # fill in the spectrum
	    #---------------------
	    do ii = 1, nev {

		#-------------------
		# get the PH channel
		#-------------------
		jj = Mems[evl[ii]+BN_BOFF(bn)]
		good = TRUE

		#---------------------------------
		# do instrument specific stuff
		# (I wish I could have moved this)
		#---------------------------------
		switch( BN_INST(bn) ) {

		#------------------------------
		# Einstein IPC
		#	a> Discard channel zero
		#------------------------------
		case EINSTEIN_IPC:
		    if ( jj == 0 ) {
			good = FALSE
		    }

		#-----------------------------------
		# Einstein HRI
		#	a> only one channels allowed
		#-----------------------------------
		case EINSTEIN_HRI:
		    jj = 1

		#----------------------------------------
		# Rosat HRI
		#	a> full- gives one channel
		#	b> Discard channel zero for full+
		#----------------------------------------
		case ROSAT_HRI:
		    if ( BN_FULL(bn) == NO ) {
			jj = 1
		    }
		    else {
			if ( jj == 0 ) {
			    good = FALSE
			}
		    }

		#--------------------------------------------------
		# Rosat PSPC
		#	a> if full- crunch spectrum, otherwise okay
		#--------------------------------------------------
		case ROSAT_PSPC:
		    if ( BN_FULL(bn) == NO ) {

			#-----------------------------------------
			# discard photons outside of the threshold
			#-----------------------------------------
			if ( jj < PSPC_LOTHRESH || jj > PSPC_HITHRESH ) {
			    good = FALSE
			}

			#----------------
			# crunch spectrum
			#----------------
			else {
			    jj = pspc_pi(jj)
			}
		    } # end if full no

		#--------------------------------------------------
		# SRGOB HEPC-1
		#	a> if full- crunch spectrum, otherwise okay
		#--------------------------------------------------
		case SRG_HEPC1:
		    if ( BN_FULL(bn) == NO ) {

			#-----------------------------------------
			# discard photons outside of the threshold
			#-----------------------------------------
			if ( jj < HEPC1_LOTHRESH || jj > HEPC1_HITHRESH ) {
			    good = false
			}

			#----------------
			# crunch spectrum
			#----------------
			else {
			    jj = hepc1_pi(jj)
			}
		    } # end if full no
		#--------------------------------------------------
		# SRG LEPC-1
		#	a> if full- crunch spectrum, otherwise okay
		#--------------------------------------------------
		case SRG_LEPC1:
		    if ( BN_FULL(bn) == NO ) {

			#-----------------------------------------
			# discard photons outside of the threshold
			#-----------------------------------------
			if ( jj < LEPC1_LOTHRESH || jj > LEPC1_HITHRESH ) {
			    good = false
			}

			#----------------
			# crunch spectrum
			#----------------
			else {
			    jj = lepc1_pi(jj)
			}
		    } # end if full no

		#----------------------------
		# Default - assume PH is okay
		#----------------------------
		default:

		} # end switch on instrument

		#---------------------------------------------
		# Now we are back to code for every instrument
		#---------------------------------------------

		#----------------------------------------
		# check that the PH is within the indices
		#----------------------------------------
		if ( ( jj < 1 ) || ( jj > len ) && good ) {
		    call eprintf("QPSPEC WARNING: discarding photon out of PHA/PI range. Value: %d\n")
		     call pargi(jj)
		    call flush(STDERR)
		    good = FALSE
		} # end if bad PH
		else {

		    #----------------------------------------
		    # Compute the offaxis histogram in pixels
		    #----------------------------------------
		    if ( BN_NOAH(bn) != 0 && good ) {
			call bn_do_oah(evl, ii, bn, good, distance_sum)
		    }
		} # end else good PH

		#---------------------------------------------
		# If it is still a good photon add to spectrum
		#---------------------------------------------
		if ( good ) {
			spectrum[jj] = spectrum[jj] + 1.0D0
		}

	    } # do
	} # end while

	#-------------------------------------------------
	# convert BN_OAH bins from counts to percents, and 
	#  compute mean offaxis distance
	#-------------------------------------------------
	if ( BN_NOAH(bn) != 0 ) {
	    sum = 0
	    do ii = 1, len {
		sum = sum + spectrum[ii]
	    } # end do

	    if ( sum != 0 ) {
		do ii = 0, BN_NOAH(bn) - 1 {
		    BN_OAH(bn, ii) = BN_OAH(bn, ii) / sum
		} 
		distance_mean = distance_sum / sum
	    } else {	# sum == 0
		distance_mean = 0.
	    } # end if sum
	} # end if off axis

end

#----------------------------------------------------------------------
#
#	BN_DO_OAH - Bin the off axis histogram in pixels
#
#----------------------------------------------------------------------

procedure bn_do_oah(evl, ii, bn, good, distance_sum)

bool	good			# o: is this a good photon

int	evl[ARB]		# i: event pointer from qpio_getevent
int	ii			# i: what photon we have

pointer	bn			# i: pointer to binning

int	kk			# l: oah index

real	distance		# l: photon off axis distance in pixels
real	distance_sum		# o: sum of photon off axis distances in pixels
real	leftx			# l: photon effective area in left bin
real	width			# l: width of histogram bin

begin

	#-------------------------------------------------
	# Calculate photons distance from (optical) center
	#-------------------------------------------------
	distance = sqrt(real( (Mems[evl[ii] + BN_XOFF(bn)] - BN_XREF(bn))**2 +
			      (Mems[evl[ii] + BN_YOFF(bn)] - BN_YREF(bn))**2) )

	#---------------------------------------------------------
	# Check that distance is outside first off axis histogram.
	# If not we have a problem, and discard the photon.
	#---------------------------------------------------------
	if ( distance < BN_OAHAN(bn, 0) ) {
	    call eprintf("QPSPEC WARNING: photon distance = %8.2f does not\n")
	     call pargr(distance)
	    call eprintf("fall within offaxis histogram.  Value too low;\n")
	    call eprintf("discarding photon.\n")
	    call flush(STDERR)
	    good = FALSE
	}

	#-------------------------------------------------------
	# Check that distance is inside last off axis histogram.
	# If not put photon in last histogram bin.
	#-------------------------------------------------------
	else if ( distance > BN_OAHAN(bn, BN_NOAH(bn) -1) ) {
	    call eprintf("QPSPEC WARNING: photon distance = %8.2f does not\n")
	     call pargr(distance)
	    call eprintf("fall within offaxis histogram.  Value too high;\n")
	    call eprintf("photon being placed in last histogram bin.\n")
	    call flush(STDERR)
	    BN_OAH(bn, BN_NOAH(bn) -1) = BN_OAH(bn, BN_NOAH(bn) -1) + 1
	    distance_sum = distance_sum + distance
	}

	#-------------------------------------------
	# if it is okay calculate off axis histogram
	#-------------------------------------------
	else {

	    for ( kk = 1; distance > BN_OAHAN(bn, kk); kk = kk+1 )
		;

	    #-----------------------------------------------------------
	    # The effective area contribution of each photon is computed
	    # for the oah points on either side of it.
	    #-----------------------------------------------------------
	    width = BN_OAHAN(bn, kk) - BN_OAHAN(bn, kk -1)
	    leftx = ( BN_OAHAN(bn, kk) - distance ) / width

	    BN_OAH(bn, kk-1) = BN_OAH(bn, kk-1) + leftx
	    BN_OAH(bn, kk)   = BN_OAH(bn, kk)   + ( 1 - leftx )

	    distance_sum = distance_sum + distance

	} # end else

end

#------------------------------------------------------------------
#
#	BN_GETXY -- get the center (if one is defined) of the first 
#	            include region of a region descriptor
#
#------------------------------------------------------------------

procedure bn_getxy(reglist, x, y)

pointer	reglist			# i: ptr to list of region object structures
real	x			# o: x center
real	y			# o: y center

pointer	regobj			# l: ptr to current region object structure
pointer	reg			# l: reg structure attached to regobj structure

begin
	x = 0.0
	y = 0.0

	if (reglist != NULL) {
	    # look for the first include region
	    for (regobj = reglist;  regobj != NULL;  regobj = V_NEXT(regobj)) {
		if ( V_INCL(regobj) == YES ) {

#		    if (M_INST(V_SLICES(regobj)) != 0 ||
#		        M_INST(V_ANNULI(regobj)) != 0    )
#			call error(1, "no region accelerators allowed")

		    reg = V_ARG1(1, regobj)
		    # any shape except field or polygon has a center
		    if (R_CODE(reg) != FIELD && R_CODE(reg) != POLYGON) {
			x = Memr[R_ARGV(reg)]
			y = Memr[R_ARGV(reg) + 1]
	            } # end if not FIELD and not POLYGON

		    #------------
		    # main return
		    #------------
		    return

		} # end if include region
	    } # end for
	} # end if reglist != NULL

	#---------------
	# default return
	#---------------
end

#-------------------------------------------------------------------------
#
#	BN_GETRADIUS -- get the new arc-minute radius for single circle.
#
#-------------------------------------------------------------------------

procedure bn_getradius(reglist, sbn, radius, arcsec)

pointer	reglist			# i: ptr to list of region object structures
int	sbn			# i: instrument-specific binning parameters
real	radius			# o: radius
real	arcsec			# i: arc seconds per pixel

pointer	regobj			# l: ptr to current region object structure
pointer	reg			# l: reg structure attached to regobj structure
real	default_radius		# l: default point source radius for the instr


begin
	#-----------------------------------------
	# Get default point source radius from sbn
	#-----------------------------------------
	default_radius = BN_RADIUS(sbn)

	#-------------------------
	# Initialize radius to 0.0
	#-------------------------
	radius = 0.0

	#-------------------------------------------------------------
	# If we have no list of region object structures (e.g., if the 
	# region descriptor specified a .pl file without a region 
	# descriptor in its header), leave the radius as zero, and
	# give warning if the instrument is Einstein IPC
	#-------------------------------------------------------------
	if ( reglist == NULL ) {
	    if ( BN_INST(sbn) == EINSTEIN_IPC )
		call bn_extend_warn()
	}

	#-------------------------------------------------------------
	# Else (there is a list of region object structures), 
	# if it is a single circle, set radius
	#-------------------------------------------------------------
	else {
	    regobj = reglist

	    if ( (V_NEXT(regobj) != NULL)  ||
		 (V_INCL(regobj) != YES)   ||  
		 (V_NINSTS(regobj) != 3)     ) {

		# We have something other than a single simple include region
		if ( BN_INST(sbn) == EINSTEIN_IPC )
		    call bn_extend_warn()
	    }

	    else {	# We have a single simple include region
		reg = V_ARG1(1, regobj)

		if (R_CODE(reg) != CIRCLE) {
		    if ( BN_INST(sbn) == EINSTEIN_IPC )
			call bn_extend_warn()
		}

		else {	# We have a single circle

		    radius = (Memr[R_ARGV(reg) + 2] * arcsec)/60.0

		    if ( BN_INST(sbn) == EINSTEIN_IPC )
			if ( radius < 0.9 * default_radius || 
			     radius > 1.1 * default_radius   )
			    call bn_extend_warn()

		} # end else circle
	    } # end else single simple include region
	} # end else reglist != NULL

end

#-------------------------------------------------------------------------
#
#	BN_EXTEND_WARN -- Warning message for extracting extended source
#			  with the Einstein IPC.
#
#-------------------------------------------------------------------------

procedure bn_extend_warn()

begin
	call eprintf("\n")
	call eprintf(" WARNING ** PROS spectral extraction and fitting of\n")
	call eprintf(" Einstein IPC data are correct only for a single\n")
	call eprintf(" circular source of radius 3 arcmin.\n")
	call eprintf(" Source extraction will continue,\n")
	call eprintf(" but exercise caution with the results.\n")
	call eprintf("\n")

	call flush(STDERR)

end

##-----------------------------------------------------------------------------
##
##	BN_RADIUS_ERR -- warn the user that point source must be a
##			 single circle.
##
##-----------------------------------------------------------------------------
#
#procedure bn_radius_err()
#
#begin
#
#	call eprintf("\n")
#	call eprintf(" Warning *** The region for a point source must be a\n")
#	call eprintf(" SINGLE CIRCLE.  If you wish to use other shapes,\n")
#	call eprintf(" multiple regions, or to exclude regions please\n")
#	call eprintf(" set the 'extended' parameter to 'TRUE'.\n")
#
#	call flush(STDERR)
#	call error(1, "QPSPEC: point source must be a circle.")
#
#end

#----------------------------------------------------------------------------
#
#	BN_OFF_AXIS - compute the off-axis angle of the center of the region; 
#			convert both off-axis angles (region center, mean of 
#			selected events) from pixels to arcmin, and save them 
#			in the DS structure
#
#----------------------------------------------------------------------------

procedure bn_off_axis(distance_mean, shead, ds)

pointer	ds			# i: data set pointer
pointer	shead			# i: source header

real	distance_mean		# i: mean photon off axis distance in pixels
real	x_sqrd			# l: square of x coordinate
real	y_sqrd			# l: square of y coordinate

begin
	if ( DS_X(ds) > EPSILONR && DS_Y(ds) > EPSILONR ) {
	    x_sqrd = ( DS_X(ds) - real(QP_CRPIX1(shead)) )**2
	    y_sqrd = ( DS_Y(ds) - real(QP_CRPIX2(shead)) )**2
	    DS_REGION_OFFAXIS_ANGLE(ds) = sqrt( x_sqrd + y_sqrd )
	    # convert from pixels to arc-minutes
	    DS_REGION_OFFAXIS_ANGLE(ds) = DS_REGION_OFFAXIS_ANGLE(ds) *
					( real( abs(QP_CDELT1(shead)) ) * 60.0)
	}
	else {
	    DS_REGION_OFFAXIS_ANGLE(ds) = 0
	}

	if ( distance_mean > EPSILONR ) {
	    # convert from pixels to arc-minutes
	    DS_MEAN_EVENT_OFFAXIS_ANGLE(ds) = distance_mean *
					( real( abs(QP_INPXX(shead)) ) * 60.0)
	}
	else {
	    DS_MEAN_EVENT_OFFAXIS_ANGLE(ds) = 0
	}
end
