# $Header: /home/pros/xray/xspectral/qpspec/RCS/vign_correct.x,v 11.0 1997/11/06 16:43:36 prosb Exp $
# $Log: vign_correct.x,v $
# Revision 11.0  1997/11/06 16:43:36  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:31:58  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:36:31  prosb
#General Release 2.3.1
#
#Revision 7.2  94/04/25  20:28:53  dennis
#Made the off-axis angle always be a positive quantity.
#
#Revision 7.1  94/02/01  20:16:58  dennis
#In particle_bkgd(): (1) new local variable area_min2, to correct error of 
#changing value of input parameter area; (2) corrected conversion of area 
#units from pixels to (arcmin**2); (3) changed variable names, to match 
#Plucinsky et al paper and comments in file particle_bkgd.tab.
#
#Revision 7.0  93/12/27  18:58:36  prosb
#General Release 2.3
#
#Revision 6.3  93/12/02  13:47:33  dennis
#Corrected vignetting correction computation, doing it in PI space instead 
#of in energy space.
#
#Revision 6.2  93/11/03  00:28:31  dennis
#vign_correct() now passes back avg_mvr, for bn_bkgdsub() to use as flag 
#in error computations.
#
#Revision 6.1  93/07/02  14:47:49  mo
#MC	7/2/93		Enclose constants in (parens) (RS6000 port)
#
#Revision 6.0  93/05/24  16:54:09  prosb
#General Release 2.2
#
#Revision 1.5  93/05/12  15:47:01  orszak
#jso - added warning if the user tries to run this with no background.
#
#Revision 1.4  93/05/08  17:46:54  orszak
#jso - this should be it.  amoung other things fixed bug in particle
#      calculation and added comments.  also changed table column
#      names and rebin procedures.
#
#Revision 1.3  93/05/06  08:31:00  orszak
#jso - corrected mistake on access to the offar array.
#
#
# Module:	vign_correct.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	to calculation values neccessary to preform vignetting
#		corrected background subtraction
# External:	
# Local:	particle_bkgd
# Description:	This routine calculates the effective area ratio between
#		the source and the background, and also gets the charged
#		particle contribution for each.  See spec in
#		/pros/doc/spectral/qpspec_bkgd.txt
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JSO  initial version Apr 93
#		{n} <who> -- <does what> -- <when>
#

include <mach.h>
include <spectral.h>

include	"qpspec.h"
include	"../source/pspc.h"

define	ROS_PI_OFFAR	"ros_pi_offar"

procedure vign_correct(src_particles, bkgd_particles, eff_area_norm, avg_mvr, 
		sbn, bbn, indices, sarea, barea, shead, dobkgd, display)

real	eff_area_norm[ARB]	# o: effective area normalization factor
real	src_particles[ARB]	# o: source particles
real	bkgd_particles[ARB]	# o: background particles
real	avg_mvr			# o: average master veto rate
pointer	sbn			# i: source pointer
pointer	bbn			# i: background pointer
int	indices			# i: number of bins
real	sarea			# i: area in source
real	barea			# i: area in background
pointer	shead			# i: pointer to qpoe header
int	dobkgd			# i: YES if we have bkgd
int	display			# i: display level

int	ipitch			# counter for PSPC_PITCH bins
int	ibin			# counter for indices bins 
				#		(PSPC_PITCH or PSPC_CHANNELS)
int	iangle			# counter for PSPC_OFFAR offaxis angles
int	bytes			# bytes read
int	fd			# file descriptor

pointer	bkd_area		# rebinned background effective area
pointer	bkd_eff_area		# background effective area
pointer	offar			# off axis effective areas
pointer	offar_fname		# offar filename
pointer	sp			# stack pointer
pointer	src_area		# rebinned source effective area
pointer	src_eff_area		# source effective area

int	open()
int	read()
int	pspc_pi()
real	clgetr()

begin

	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#-------------------
	# and allocate space
	#-------------------
	call salloc(offar_fname, SZ_FNAME, TY_CHAR)

	call salloc(offar, (PSPC_PITCH + 1)*PSPC_OFFAR, TY_REAL)
	call aclrr(Memr[offar], (PSPC_PITCH + 1)*PSPC_OFFAR)

	call salloc(src_eff_area, PSPC_PITCH, TY_REAL)
	call aclrr(Memr[src_eff_area], PSPC_PITCH)

	call salloc(bkd_eff_area, PSPC_PITCH , TY_REAL)
	call aclrr(Memr[bkd_eff_area], PSPC_PITCH)

	call salloc(src_area, indices, TY_REAL)
	call aclrr(Memr[src_area], indices)

	call salloc(bkd_area, indices, TY_REAL)
	call aclrr(Memr[bkd_area], indices)

	#----------------------------------------------------------
	# check that this is the PSPC and that there's a background
	#----------------------------------------------------------
	if ( BN_INST(sbn) == ROSAT_PSPC && dobkgd == YES ) {

	    #-----------------------------------------------------------
	    # read in offaxis coefficients (PSPC_PITCH + 1) x PSPC_OFFAR
	    #-----------------------------------------------------------
	    call clgstr(ROS_PI_OFFAR, Memc[offar_fname], SZ_FNAME)
	    fd = open(Memc[offar_fname], READ_ONLY, BINARY_FILE)
	    bytes = read(fd, Memr[offar], (PSPC_PITCH+1)*PSPC_OFFAR*SZ_REAL)
	    call close(fd)

	    #---------------------------------------------------------------
	    # Compute the offaxis weighted effective area for each PI bin.
	    #
	    # The index (offset) runs from 1 (rather than 0) to PSPC_PITCH 
	    # because the first entry in each column of the calibration file 
	    # is the angle for the column; the coefficients start with the 
	    # second entry in the column.
	    #---------------------------------------------------------------

	    do ipitch = 1, PSPC_PITCH {
		do iangle = 0, PSPC_OFFAR - 1 {
		    Memr[src_eff_area + ipitch - 1] = 
			Memr[src_eff_area + ipitch - 1] +
			BN_OAH(sbn, iangle) * 
				Memr[offar + iangle * (PSPC_PITCH+1) + ipitch]
		    Memr[bkd_eff_area + ipitch - 1] = 
			Memr[bkd_eff_area + ipitch - 1] +
			BN_OAH(bbn, iangle) * 
				Memr[offar + iangle * (PSPC_PITCH+1) + ipitch]
		}
		if (indices != PSPC_PITCH)
		    ibin = pspc_pi(ipitch)
		else
		    ibin = ipitch

		if ((ibin > 0) && (ibin <= indices)) {
		    Memr[src_area + ibin - 1] = Memr[src_area + ibin - 1] + 
						Memr[src_eff_area + ipitch - 1]
		    Memr[bkd_area + ibin - 1] = Memr[bkd_area + ibin - 1] + 
						Memr[bkd_eff_area + ipitch - 1]
		}
	    }

	    do ibin = 1, indices {
		eff_area_norm[ibin] = 
			Memr[src_area + ibin - 1] / Memr[bkd_area + ibin - 1]
	    }

	    if ( display >= 3 ) {
		call bn_rawdisp("EFF_AREA_NORM", eff_area_norm, indices)
	    }

	    avg_mvr = clgetr("avg_mvr")

	    call particle_bkgd(src_particles, avg_mvr, indices, sarea,
			sbn, shead, display)

	    if ( display >= 3 ) {
		call bn_rawdisp("SOURCE PARTICLES", src_particles, indices)
	    }

	    call particle_bkgd(bkgd_particles, avg_mvr, indices, barea,
			bbn, shead, display)

	    if ( display >= 3 ) {
		call bn_rawdisp("BKGD PARTICLES", bkgd_particles, indices)
	    }

	} # end if (PSPC and dobkgd)

	#----------------------------------------------------------------
	# if it is not the ROSAT PSPC or if no background, give a warning 
	# and make everything safe
	#----------------------------------------------------------------
	else {

	    call eprintf(
  "QPSPEC WARNING: 'vign_correct' only applicable for PSPC with background;\n")
	    call eprintf("                setting values to have no effect.\n")
	    call flush(STDERR)

	    do ibin = 1, indices {
		src_particles[ibin] = 0.0
		bkgd_particles[ibin] = 0.0
		eff_area_norm[ibin] = 1.0
	    }
	    avg_mvr = 0.0
	} # end else

	call sfree(sp)

	return
end

#---------------------------------------------------------------
# Function:	particle_bkgd
# Purpose:	Calculate the energy and angle dependent
#		charged particle bkgd.
# Description:	Based on: 
#		Snowden et al., 1992, Ap.J., 393, 819; and 
#		Plucinsky, Snowden, Briel, Hasinger, Pfefferman, 
#			1993, Ap.J., 418, 519
# Modified:	{0} JSO  initial version Apr 93
#		{n} <who> -- <does what> -- <when>
#
#---------------------------------------------------------------

define	NUM_COEFF	19

procedure particle_bkgd(bkgd, avg_mvr, indices, area, bn, head, display)

real	bkgd[ARB]		# o: charged particle counts
real	avg_mvr			# i: average master veto rate
int	indices			# i: number of energy channels
real	area			# i: area of region in pixels
pointer	bn			# i: bn pointer
pointer	head			# i: qpoe header pointer
int	display			# i: display level

int	ii			# counter
int	jj			# counter
real	area_min2		# area of region in (arcmin**2)

#------------------------------------------------
# The following reals are the coefficients - they
# are described fully in the table header
#------------------------------------------------
real	c1
real	c2
real	c3
real	c4
real	d3
real	d4
real	ai
real	bi
real	ae
real	be
real	aal
real	bal
real	ei
real	fi
real	ee
real	const1
real	const2
real	const3
real	const4
#------------------------------------------
# end of coefficients
#------------------------------------------

real	lt_t			# livetime term
real	internal_t		# internal term
real	temp_t			# temporary aluminum term
real	al_t			# aluminum term
real	ext_t			# external term

real	date			# date of observation
real	pi			# pi bin

pointer	buf			# buffer with coefficients
pointer	coln			# table column name
pointer	cp			# table column pointer
pointer	edges			# energy boundaries for 256 channels
pointer	energies		# energy boundaries for 34 channels
pointer	fname			# particle coeff. table name
pointer	nullflag		# null flag
pointer	sp			# stack pointer
pointer	summed_bkgd		# particles summed over off axis histogram
pointer	temp_bkgd		# 256 channel x 14 off-axis angle particles
pointer	temp_str		# string if user does not like default column
pointer	tp			# table pointer

bool	ck_empty()
bool	streq()
pointer	tbtopn()

begin

	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#-------------------
	# and allocate space
	#-------------------
	call salloc(coln, SZ_FNAME, TY_CHAR)

	call salloc(fname, SZ_FNAME, TY_CHAR)

	call salloc(temp_str, SZ_FNAME, TY_CHAR)

	call salloc(buf, NUM_COEFF, TY_REAL)
	call aclrr(Memr[buf], NUM_COEFF)

	call salloc(nullflag, NUM_COEFF, TY_INT)

	call salloc(temp_bkgd, PSPC_PITCH*PSPC_OFFAR, TY_REAL)
	call aclrr(Memr[temp_bkgd], PSPC_PITCH*PSPC_OFFAR)

	call salloc(summed_bkgd, PSPC_PITCH, TY_REAL)
	call aclrr(Memr[summed_bkgd], PSPC_PITCH)

	call salloc(energies, indices+1, TY_REAL)
	call aclrr(Memr[energies], indices+1)

	call salloc(edges, PSPC_PITCH+1, TY_REAL)
	call aclrr(Memr[edges], PSPC_PITCH+1)

	if ( avg_mvr <  -EPSILONR ) {
	    call error (1, "QPSPEC: average Master Veto rate less than zero.")
	}
	else if ( avg_mvr > 170.0 ) {
	    call error (1, "QPSPEC: Equations invalid for MV rate over 170.")
	}

	#-------------------------------------
	# get the date and decide which column
	#-------------------------------------
	date = QP_MJDOBS(head)

	if ( date < 48043.0 ) {
	    call error(1, "QPSPEC: No coefficients; date before launch.")
	}
	else if ( date < 48282.0 ) {
	    call strcpy( "48043.0", Memc[coln], SZ_FNAME)
	}
	else if ( date < 48294.0 ) {
	    call error(1, "QPSPEC: No coefficients; PSPC viewed sun.")
	}
	else if ( date < 48408.0 ) {
	    call strcpy( "48294.0", Memc[coln], SZ_FNAME)
	}
	else if ( date < 48541.0 ) {
	    call strcpy( "48408.0", Memc[coln], SZ_FNAME)
	}
	else {
	    call strcpy( "48541.0", Memc[coln], SZ_FNAME)
	}

	call clgstr("particle_data_column", Memc[temp_str], SZ_FNAME)
	if ( !ck_empty(Memc[temp_str]) ) {
	    call strcpy(Memc[temp_str], Memc[coln], SZ_FNAME)
	}

	if ( display > 3 ) {
	    call printf("table column: %s\n")
	     call pargstr(Memc[coln])
	}

	#------------------------------------------------------------------
	# we have to check the column name because tbcfnd only gives a SEGV
	#------------------------------------------------------------------
	if ( !streq(Memc[coln], "48043.0") &&
	     !streq(Memc[coln], "48294.0") &&
	     !streq(Memc[coln], "48408.0") &&
	     !streq(Memc[coln], "48541.0") ) {
	    call error(1, "QPSPEC: invalid particle table column name")
	}

	#--------------------
	# get data table name
	#--------------------
	call clgstr("particle_table", Memc[fname], SZ_FNAME)

	#-------------------
	# read in data table
	#-------------------
	tp = tbtopn(Memc[fname], READ_ONLY, 0)
	call tbcfnd(tp, Memc[coln], cp, 1)
	call tbcgtr(tp, cp, Memr[buf], Memi[nullflag], 1, NUM_COEFF)
	call tbtclo(tp)

	#------------------------------------------------------------
	# set coeffiecents - i do this so that we can cross reference
	# with any up dates to the paper
	#------------------------------------------------------------
	c1 = Memr[buf + 0]
	c2 = Memr[buf + 1]
	c3 = Memr[buf + 2]
	c4 = Memr[buf + 3]
	d3 = Memr[buf + 4]
	d4 = Memr[buf + 5]
	ai = Memr[buf + 6]
	bi = Memr[buf + 7]
	ae = Memr[buf + 8]
	be = Memr[buf + 9]
	aal = Memr[buf + 10]
	bal = Memr[buf + 11]
	ei = Memr[buf + 12]
	fi = Memr[buf + 13]
	ee = Memr[buf + 14]
	const1 = Memr[buf + 15]
	const2 = Memr[buf + 16]
	const3 = Memr[buf + 17]
	const4 = Memr[buf + 18]

	#-----------------------------------------------------------
	# Here is the beef.  This equation comes from the paper
	# and we calculate the charged particles for each energy bin
	# and off-axis angle.
	#-----------------------------------------------------------

	do jj = 0, PSPC_OFFAR - 1 {

	    do ii = 1, PSPC_PITCH {

		pi = ii + 0.5

		#---------------
		# live time term
		#---------------
		lt_t = 1 / ( 1 - const1 * avg_mvr )

		#----------------------------------------------
		# internal term
		# (convert the off-axis angles back to degrees)
		#----------------------------------------------
		internal_t = (ai + bi*avg_mvr) *
			( ei + fi*abs(BN_OAHAN(bn, jj)*60.0*QP_INPXX(head)) ) *
			( c1*(pi**c2) + c3*pi + c4 )

		#--------
		# Al term
		#--------
		temp_t = const2 * ( const3 - pi**0.5)**2
		al_t = ee * ( aal + bal*avg_mvr ) *
			( const4*(pi**(-0.75))*exp(temp_t) )

		#-------------
		# eternal term
		#-------------
		ext_t = ee * ( ae + be*avg_mvr ) * ( d3*pi + d4 )

		#------------------------
		# bring them all together
		#------------------------
		Memr[temp_bkgd + jj*PSPC_PITCH + ii - 1] =
				lt_t * ( internal_t + al_t + ext_t )

	    } # end do over pi bins

	} # end do over angles

	#------------------------------------------------
	# weight the charged particle contribution to the
	# off-axis histogram
	#------------------------------------------------
	do jj = 0, PSPC_OFFAR - 1 {
	    do ii = 0, PSPC_PITCH - 1 {
		Memr[summed_bkgd + ii] = Memr[summed_bkgd + ii] +
			BN_OAH(bn, jj) * Memr[temp_bkgd + jj*PSPC_PITCH + ii]
	    }
	}

	call pspc_energy(Memr[edges], PSPC_PITCH+1)

	call pspc_energy(Memr[energies], indices+1)
	
	if ( display == 5 ) {
	    do ii = 0, PSPC_PITCH - 1 {
		call printf("particle bkgd: %g\n")
		 call pargr(Memr[summed_bkgd + ii])
	    }
	}

	call rebin_particles(Memr[summed_bkgd], Memr[edges], PSPC_PITCH,
			bkgd[3], Memr[energies], indices)

	#--------------------------------------------------------
	# if the user puts in an average master veto rate of zero
	# they get NO charged particles.
	#--------------------------------------------------------
	if ( avg_mvr <  EPSILONR ) {
	    call amulkr(bkgd, 0.0, bkgd, indices)
	}

	#---------------------
	# multiply by the time
	#---------------------
	call amulkr(bkgd, BN_GOODTIME(bn), bkgd, indices)

	#------------------------------------
	# multiply by the area in (arcmin**2)
	#------------------------------------
	area_min2 = area * ( abs( real(QP_CDELT1(head)) ) * 60.0 ) ** 2
	call amulkr(bkgd, area_min2, bkgd, indices)

	call sfree(sp)

end
