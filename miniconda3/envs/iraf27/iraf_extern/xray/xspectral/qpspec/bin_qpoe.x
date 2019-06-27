# $Header: /home/pros/xray/xspectral/qpspec/RCS/bin_qpoe.x,v 11.0 1997/11/06 16:43:26 prosb Exp $
# $Log: bin_qpoe.x,v $
# Revision 11.0  1997/11/06 16:43:26  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:31:40  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:35:52  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/18  18:05:56  dennis
#Removed (to init_qpoe()) calls to bn_getradius() and to bn_getxy(); 
#part of correcting the check for an orthodox Einstein IPC region.
#
#Revision 7.1  94/04/09  00:55:23  dennis
#Changes to calculate mean off-axis angle of counted events, in addition to 
#off-axis angle of center of region.
#
#Revision 7.0  93/12/27  18:58:11  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:53:34  prosb
#General Release 2.2
#
#Revision 5.3  93/05/12  15:43:30  orszak
#jso - passed in dobkgd so that vign_correct can give an error if
#      there is no background.
#
#Revision 5.2  93/05/01  12:39:43  orszak
#jso - changes to do vignetting subtraction
#
#Revision 5.1  93/04/27  00:23:14  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  22:46:39  prosb
#General Release 2.1
#
#Revision 4.2  92/10/22  15:32:15  orszak
#jso - float should be real
#
#Revision 4.1  92/10/22  13:59:46  orszak
#jso - fix for the change to doubles in MWCS.
#
#Revision 4.0  92/04/27  15:28:52  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/03/05  12:57:51  orszak
#Initial revision
#
#
# Function:	qp_binning
# Purpose:	Actually does the extraction from the qpoe file.
# Pre-cond:	
#
# Post-cond:	
#		
# Method:	
# Description:	
# Notes:	
#

include <spectral.h>

include "qpspec.h"

procedure bin_qpoe(shead, sio, spm, sbn, bio, bpm, bbn, ds, 
	           system, dotimenorm, dobkgd, display)

int	bbn			# i: instrument-specific binning parameters
int	display			# i: display level
int	dobkgd			# i: YES if we have bkgd
int	dotimenorm              # i: YES for live time normalization
int	ii			# l: loop variable
int	sbn			# i: instrument-specific binning parameters

real	sdistance_mean		# l: mean source photon off axis distance 
				#	in pixels
real	bdistance_mean		# l: mean bkgd photon off axis distance 
				#	in pixels

pointer	bcounts			# l: counts in bkgd
pointer	bio			# i: bkgd event pointer
pointer	bncounts		# o: counts in normalized bkgd
pointer	bnerrors		# l: error on normalized bkgd
pointer	bpm			# i: bkgd pixel mask pointer
pointer	bscounts		# o: counts in bkgd-subtracted source
pointer	bserrors		# o: error on bscountss
pointer	ds			# i: data set record pointer
pointer	scounts			# o: counts in source
pointer	shead			# i: source X-ray header
pointer	sio			# i: source event pointer
pointer	sp			# l: stack pointer
pointer	spm			# i: source pixel mask pointer
pointer	system			# i: systematic errors

begin

	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#---------------------------------------------------------------
	# if time normalization is required, get ratio of live times and
	# factor it into constant normfactor with user norm factor
	#---------------------------------------------------------------
	call bn_norm(sbn, bbn, dobkgd, dotimenorm, display)

	#--------------
	# Flush display
	#--------------
	if ( display >=1 )
	    call flush(STDOUT)

	#-----------------------------------
	# bin up photons in each pha channel
	#-----------------------------------
	call calloc(scounts, BN_INDICES(sbn), TY_REAL)
	call aclrr(Memr[scounts], BN_INDICES(sbn))
	call calloc(bcounts, BN_INDICES(bbn), TY_REAL)
	call aclrr(Memr[bcounts], BN_INDICES(bbn))

	call bn_bin(sio, Memr[scounts], BN_INDICES(sbn), sbn, sdistance_mean)
	call bn_area(spm, DS_SAREA(ds))

	#--------------------------------------------------------
	# bin up background photons; including off-axis histogram
	#--------------------------------------------------------

	if ( dobkgd == YES ) {
	    BN_INST(bbn)  = BN_INST(sbn)
	    BN_FULL(bbn)  = BN_FULL(sbn)
	    BN_XREF(bbn)  = BN_XREF(sbn)
	    BN_YREF(bbn)  = BN_YREF(sbn)
	    BN_BOFF(bbn)  = BN_BOFF(sbn)
	    BN_XOFF(bbn)  = BN_XOFF(sbn)
	    BN_YOFF(bbn)  = BN_YOFF(sbn)
	    BN_NOAH(bbn)  = BN_NOAH(sbn)
	    if ( BN_NOAH(bbn) != 0 ) {
		do ii = 0, BN_NOAH(bbn) {
		    BN_OAHAN(bbn, ii) = BN_OAHAN(sbn, ii)
		}
	    }

	    call bn_bin(bio, Memr[bcounts], BN_INDICES(bbn), bbn, 
							bdistance_mean)
	    call bn_area(bpm, DS_BAREA(ds))
	} else
	    DS_BAREA(ds) = 0.0

	#-----------------------------------------
	# display the source and bkgd counts
	#-----------------------------------------
	if ( display >= 3 ) {
	    call bn_rawdisp("SOURCE DATA", Memr[scounts], BN_INDICES(sbn))
	    if( dobkgd == YES )
		call bn_rawdisp("BKGD DATA", Memr[bcounts], BN_INDICES(bbn))
	}

	#---------------------------------------------------------------------
	# allocate space for the bkgd-subtracted source, normalized bkgd, errs
	#---------------------------------------------------------------------
	call calloc(bscounts, BN_INDICES(sbn), TY_REAL)
	call calloc(bserrors, BN_INDICES(sbn), TY_REAL)
	call calloc(bncounts, BN_INDICES(sbn), TY_REAL)
	call calloc(bnerrors, BN_INDICES(sbn), TY_REAL)

	#--------------------------------------------------
	# normalize the background and subtract from source
	#--------------------------------------------------
	call bn_bkgdsub(Memr[scounts], DS_SAREA(ds), BN_INDICES(sbn),
			Memr[bcounts], DS_BAREA(ds), Memr[bscounts],
			Memr[bserrors], Memr[bncounts], Memr[bnerrors],
			BN_NORMFACTOR(sbn), Memr[system], shead,
			sbn, bbn, dobkgd, display)

	DS_SOURCE(ds)		= scounts
	DS_BKGD(ds)		= bncounts
	DS_OBS_DATA(ds)		= bscounts
	DS_OBS_ERROR(ds)	= bserrors

	call mfree(bcounts, TY_REAL)
	call mfree(bnerrors, TY_REAL)

	#--------------------------
	# display the final results
	#--------------------------
	if ( display >= 3 )
	   call bn_finaldisp(Memr[DS_SOURCE(ds)], Memr[DS_BKGD(ds)],
			Memr[DS_OBS_DATA(ds)], Memr[DS_OBS_ERROR(ds)],
			BN_INDICES(sbn))

	#------------------------------------------------
	# Save off-axis angle of center of source region, 
	#  and mean off-axis angle of source photons
	#------------------------------------------------
	call bn_off_axis(sdistance_mean, shead, ds)

	#---------------
	# free the stack
	#---------------
	call sfree(sp)

end
