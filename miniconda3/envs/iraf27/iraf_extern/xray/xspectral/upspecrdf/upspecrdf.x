# $Header: /home/pros/xray/xspectral/upspecrdf/RCS/upspecrdf.x,v 11.0 1997/11/06 16:43:39 prosb Exp $
# $Log: upspecrdf.x,v $
# Revision 11.0  1997/11/06 16:43:39  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:32:03  prosb
# General Release 2.4
#
#Revision 8.2  1994/09/09  17:49:22  dennis
#Corrected handling of POISSERR keyword.
#
#Revision 8.1  94/07/07  19:34:59  dennis
#Added Einstein MPC case.
#
#Revision 8.0  94/06/27  17:36:40  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:58:43  prosb
#General Release 2.3
#
#Revision 1.6  93/11/20  04:11:31  dennis
#Corrected loss of qpspec-specific header parameters in creating auxiliary 
#files.
#
#Revision 1.5  93/11/15  16:56:39  dennis
#Added ds_getoahan(), to get degrees per instrument pixel and offaxis angles.
#
#Revision 1.4  93/10/29  21:07:21  dennis
#Send correct scale factor (QP_INPXX, not QP_CDELT1) to ds_putoah().
#
#Revision 1.3  93/10/22  19:26:16  dennis
#Added arg to ds_putoah() to enable converting offaxis angles from 
#pixels to arcmin.
#
#Revision 1.2  93/09/30  23:31:52  dennis
#Changed conditional to test QP_FORMAT instead of QP_REVISION.
#Also eliminate BAL histogram from _obs.tab header.
#
#Revision 1.1  93/09/25  02:06:14  dennis
#Initial revision
#
#
# Module:	upspecrdf.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	convert a pre-RDF _obs.tab spectral data file to RDF format, 
#		pulling out off-axis histogram or BAL histogram data into 
#		separate auxiliary files
# Local:	skip_obs(), ds_getoahan()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Dennis Schmidt, initial version, 9/24/93
#		{n} <who> -- <does what> -- <when>
#

include	<ext.h>
include <tbset.h>
include	<spectral.h>


procedure t_upspecrdf()

bool	clobber
bool	ok			# condition code from dos_open(), on NO return

int	display
int	parnum
int	i, j
int	pspcel
int	cardindex

pointer	sp			# program stack pointer
pointer	ssp			# single-pass stack pointer

pointer	fnlist_buffer
pointer	fnlist_handle

pointer	obs_table

pointer	bal_table		# _bal.tab table file name
pointer	bal_xtable		# _bal.tab table file temporary name
pointer	soh_table		# _soh.tab table file name
pointer	soh_xtable		# _soh.tab table file temporary name
pointer	boh_table		# _boh.tab table file name
pointer	boh_xtable		# _boh.tab table file temporary name

pointer	bal_tp			# BAL histogram table pointer
pointer	bal_cp			# pointer to array of BAL column pointers
pointer	soh_tp			# source offaxis histogram table pointer
pointer	soh_cp			# pointer to array of SOH column pointers
pointer	boh_tp			# background offaxis histogram table pointer
pointer	boh_cp			# pointer to array of BOH column pointers
pointer	obs_tp			# observed spectral data table pointer
pointer	obs_cp			# pointer to array of OBS column pointers

pointer	ds
pointer	qphead			# QPOE header struct from table
pointer	pname			# table header parameter name buffer

pointer	fntopnb()
int	fntgfnb()
bool	clgetb()
int	clgeti()
int	ds_tbhgti()
int	dos_open()

begin

	call smark(sp)
	call salloc(fnlist_buffer, SZ_PATHNAME, TY_CHAR)
	call salloc(obs_table, SZ_PATHNAME, TY_CHAR)
	call salloc(pname, SZ_LINE, TY_CHAR)

	clobber = clgetb("clobber")
	display	= clgeti("display")

	#----------------------------
	# get the list of table files
	#----------------------------
	call clgstr("fnlist_buffer", Memc[fnlist_buffer], SZ_PATHNAME)
	fnlist_handle = fntopnb(Memc[fnlist_buffer], NO)

	#------------------------------
	# update each table in the list
	#------------------------------
	while (fntgfnb(fnlist_handle, Memc[obs_table], SZ_PATHNAME) != EOF) {
	    call rootname(Memc[obs_table], Memc[obs_table], EXT_OBS, 
								SZ_PATHNAME)
	    #------------------------
	    # get info from the table
	    #------------------------
	    call ds_get(Memc[obs_table], qphead, ds)

	    if (QP_FORMAT(qphead) > 0)  {
		call skip_obs(Memc[obs_table], qphead, ds, true)
		next
	    }

	    #------------------------------------------------
	    # open the table file again, this time read/write
	    #------------------------------------------------
	    if (dos_open(Memc[obs_table], obs_tp, obs_cp, ok) == NO)  {
		call skip_obs(Memc[obs_table], qphead, ds, ok)
		next
	    }

	    #------------------------------------------------------------------
	    # unless the old-style file already has a POISSERR parameter, 
	    #  correct QP_POISSERR: pre-RDF files have Gaussian error estimates
	    #------------------------------------------------------------------
	    call tbhfkw (obs_tp, "POISSERR", parnum)
	    if (parnum == 0)
		QP_POISSERR(qphead) = NO

	    #------------------------------------------------------------------
	    # for each of the header parameters being retired, get the 
	    # parameter number, then delete it without asking for confirmation;
	    # also, fill out the standard set of header parameters;
	    # also, make any required auxiliary files
	    #------------------------------------------------------------------
	    call tbhfkw (obs_tp, "SEQNO", parnum)
	    call tbhdel (obs_tp, parnum)

	    call tbhfkw (obs_tp, "LIVECORR", parnum)
	    call tbhdel (obs_tp, parnum)

	    call put_tbhead(obs_tp, qphead)

	    switch ( DS_INSTRUMENT(ds) ) {

	      case EINSTEIN_IPC:
		# - - - - - - - - - - - - - - - - - - - - - - - -
		# delete bal header parameters from _obs.tab file
		# - - - - - - - - - - - - - - - - - - - - - - - -
		if (BH_ENTRIES(DS_BAL_HISTGRAM(ds)) > 0)  {

		    do i = 1, BH_ENTRIES(DS_BAL_HISTGRAM(ds))  {
			call sprintf(pname, SZ_LINE, "BAL_%-2d")
			 call pargi(i)

			call tbhfkw (obs_tp, pname, parnum)
			call tbhdel (obs_tp, parnum)

			call sprintf(pname, SZ_LINE, "BFRAC_%-2d")
			 call pargi(i)

			call tbhfkw (obs_tp, pname, parnum)
			call tbhdel (obs_tp, parnum)
		    }

		    call tbhfkw (obs_tp, "BAL_LO", parnum)
		    call tbhdel (obs_tp, parnum)

		    call tbhfkw (obs_tp, "BAL_HI", parnum)
		    call tbhdel (obs_tp, parnum)

		    call tbhfkw (obs_tp, "BAL_INC", parnum)
		    call tbhdel (obs_tp, parnum)

		    call tbhfkw (obs_tp, "BAL_STEPS", parnum)
		    call tbhdel (obs_tp, parnum)

		    call tbhfkw (obs_tp, "BAL_EPS", parnum)
		    call tbhdel (obs_tp, parnum)

		    call tbhfkw (obs_tp, "BAL_MEAN", parnum)
		    call tbhdel (obs_tp, parnum)

		    call tbhfkw (obs_tp, "BAL_SPATIAL", parnum)
		    call tbhdel (obs_tp, parnum)
		}
		call tbhfkw (obs_tp, "NBALS", parnum)
		call tbhdel (obs_tp, parnum)

		# - - - - - - - - - - - - - - - - - - - -
		# make separate bal histogram table file
		# - - - - - - - - - - - - - - - - - - - -
		call smark(ssp)
		call salloc(bal_table, SZ_PATHNAME, TY_CHAR)
		call strcpy("", Memc[bal_table], SZ_PATHNAME)
		call rootname(Memc[obs_table], Memc[bal_table], EXT_BAL,
								SZ_PATHNAME)
		call salloc(bal_xtable, SZ_PATHNAME, TY_CHAR)
		call strcpy("", Memc[bal_xtable], SZ_PATHNAME)
		call clobbername(Memc[bal_table], Memc[bal_xtable], clobber,
								SZ_PATHNAME)

		call ds_create_bal(Memc[bal_xtable], bal_tp, bal_cp)
		call tbhcal(obs_tp, bal_tp)
		call ds_puthead(bal_tp, qphead, ds)
		call ds_putbal(bal_tp, bal_cp, DS_BAL_HISTGRAM(ds))
		call tbtclo(bal_tp)
		call mfree(bal_cp, TY_POINTER)

		call finalname(Memc[bal_xtable], Memc[bal_table])
		call sfree(ssp)


	      case EINSTEIN_HRI:
	      case EINSTEIN_MPC:
		# - - - - - - - - - - - -
		# (nothing special to do)
		# - - - - - - - - - - - -

	      default:
		# - - - - - - - - - - - - - - - - - - - - - - - -
		# delete OAH header parameters from _obs.tab file
		# - - - - - - - - - - - - - - - - - - - - - - - -
		pspcel = ds_tbhgti(obs_tp, "PSPCELEM")
		if (pspcel > 0)  {
		    i = 0
		    while ( i < DS_NOAH(ds) ) {
			cardindex = ( i / pspcel ) + 1

			call sprintf(pname, SZ_LINE, "PSPCOH%d")
			 call pargi(cardindex)

			call tbhfkw (obs_tp, pname, parnum)
			call tbhdel (obs_tp, parnum)

			call sprintf(pname, SZ_LINE, "BACKOH%d")
			 call pargi(cardindex)

			call tbhfkw (obs_tp, pname, parnum)
			call tbhdel (obs_tp, parnum)

			for ( j = 0; i < DS_NOAH(ds) && j < pspcel; j = j + 1 )
			    i = i + 1
		    }
		}

		call tbhfkw (obs_tp, "PSPCNOH", parnum)
		call tbhdel (obs_tp, parnum)

		call tbhfkw (obs_tp, "PSPCELEM", parnum)
		call tbhdel (obs_tp, parnum)

		#------------------------------------
		# get scale factor and offaxis angles
		#------------------------------------
		call ds_getoahan(ds, qphead)
		call tbhadr(obs_tp, "XS-INPXX", QP_INPXX(qphead))

		# - - - - - - - - - - - - - - -
		# make separate OAH table files
		# - - - - - - - - - - - - - - -
		call smark(ssp)
		call salloc(soh_table, SZ_PATHNAME, TY_CHAR)
		call strcpy("", Memc[soh_table], SZ_PATHNAME)
		call rootname(Memc[obs_table], Memc[soh_table], EXT_SOH,
								SZ_PATHNAME)
		call salloc(soh_xtable, SZ_PATHNAME, TY_CHAR)
		call strcpy("", Memc[soh_xtable], SZ_PATHNAME)
		call clobbername(Memc[soh_table], Memc[soh_xtable], clobber,
								SZ_PATHNAME)

		call salloc(boh_table, SZ_PATHNAME, TY_CHAR)
		call strcpy("", Memc[boh_table], SZ_PATHNAME)
		call rootname(Memc[obs_table], Memc[boh_table], EXT_BOH,
								SZ_PATHNAME)
		call salloc(boh_xtable, SZ_PATHNAME, TY_CHAR)
		call strcpy("", Memc[boh_xtable], SZ_PATHNAME)
		call clobbername(Memc[boh_table], Memc[boh_xtable], clobber,
								SZ_PATHNAME)

		call ds_create_oah(Memc[soh_xtable], soh_tp, soh_cp,
		                   Memc[boh_xtable], boh_tp, boh_cp)
		call tbhcal(obs_tp, soh_tp)
		call tbhcal(obs_tp, boh_tp)
		call ds_puthead(soh_tp, qphead, ds)
		call ds_puthead(boh_tp, qphead, ds)
		call ds_putoah(soh_tp, soh_cp, boh_tp, boh_cp, ds, 
							QP_INPXX(qphead))
		call tbtclo(soh_tp)
		call tbtclo(boh_tp)
		call mfree(soh_cp, TY_POINTER)
		call mfree(boh_cp, TY_POINTER)

		call finalname(Memc[soh_xtable], Memc[soh_table])
		call finalname(Memc[boh_xtable], Memc[boh_table])
		call sfree(ssp)
		if (DS_NOAH(ds) > 0)
		    call mfree(DS_OAHANPTR(ds), TY_REAL)
	    }

	    #--------------------------------
	    # write the revised _obs.tab file
	    #--------------------------------
	    call tbtclo(obs_tp)
	    call mfree(obs_cp, TY_POINTER)

	    #--------------------------------------
	    # if requested to, display this dataset
	    #--------------------------------------
	    call ds_disp(ds, display)

	    call mfree(qphead, TY_STRUCT)
	    call mfree(DS_FILENAME(ds), TY_CHAR)
	    call mfree(ds, TY_STRUCT)
	}

	call fntclsb(fnlist_handle)

	call sfree(sp)
end

#
# SKIP_OBS -- inform user that an _obs.tab file is already in RDF, and 
#              clean up to go on to the next file
#             [Note:  I have made the wording less specific than that, so 
#              that the temporary routine downspecrdf can also use it]
#
procedure skip_obs(table, qphead, ds, ok)

char	table[ARB]
pointer	qphead
pointer	ds
bool	ok

begin
	if (ok)
	    call eprintf("File %s does not need to be converted.\n")
	else
	    call eprintf("Not converting file %s.\n")
	 call pargstr(table)
	call mfree(qphead, TY_STRUCT)
	call mfree(DS_FILENAME(ds), TY_CHAR)
	call mfree(ds, TY_STRUCT)
end

#
# DS_GETOAHAN -- get instrument image scale (deg/pixel) and offaxis angles
#

# include "qpspec.h"
include "../source/pspc.h"
include "../source/rhri.h"
include "../source/hepc1.h"
include "../source/lepc1.h"

procedure ds_getoahan(ds, qph)

pointer	ds			# i: DS structure
pointer	qph			# i: QPOE header struct from table

pointer	sp			# l: stack pointer

pointer	np			# l: pset parameter pointer
pointer	fname			# l: offar file name
int	fd			# l: offar file descriptor
pointer	offar			# l: off axis histogram calibration file
int	bytes_read		# l: returned by read

int	ii			# l: loop variable

# int	jj			# l: loop variable
# int	oahele			# l: number of off axis elements for def instr
# pointer	tname			# l: temp name holder

pointer	clopset()		# open parameter set
real	clgpsetr()		# get real parameter from open pset

int	open()			# open a file
int	read()			# read from a file

# int	clgeti()		# get int parameter
# real	clgetr()		# get real parameter

begin
	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#-----------------------------------
	# allocate space for offar file name
	#-----------------------------------
	call salloc(fname, SZ_FNAME, TY_CHAR)

	#-------------------
	# open parameter set
	#-------------------
	np = clopset("pkgpars")

	#---------------
	# get instrument
	#---------------
	switch ( DS_INSTRUMENT(ds) ) {

	case EINSTEIN_IPC:
	    # nothing to do

	case EINSTEIN_HRI:
	    # nothing to do

	#----------
	# ROSAT HRI
	#----------
	case ROSAT_HRI:
	    #--------------------------------------------------------------
	    # if scale (degrees per instrument pixel) wasn't in the header, 
	    # get it from the parameter
	    #--------------------------------------------------------------
	    if ( QP_INPXX(qph) == 0 ) {
		QP_INPXX(qph) = clgpsetr(np, "ros_hri_pxx")
	    }

	    #========================================================
	    # Read the off axis histogram angles from the calibration
	    #========================================================

	    #-------------------------------------------------------
	    # The number of off-axis histrogram angles (from rhri.h)
	    #-------------------------------------------------------
	    DS_NOAH(ds) = PSPC_OFFAR

	    #----------------------------------
	    # allocate space for offaxis angles
	    #----------------------------------
	    call calloc(DS_OAHANPTR(ds), DS_NOAH(ds), TY_REAL)

	    #--------------------------------------
	    # allocate space for off-axis area file
	    #--------------------------------------
	    call salloc(offar, PSPC_OFFAR*(RHRI_RSPBINS + 1), TY_REAL)

	    #-------------------------------------
	    # get off-axis area file name and open
	    #-------------------------------------
	    call clgpset(np, ROS_OFFAR, Memc[fname], SZ_FNAME)
	    fd = open(Memc[fname], READ_ONLY, BINARY_FILE)

	    #--------------------------
	    # read in the off-axis area
	    #--------------------------
	    bytes_read = read(fd, Memr[offar],
				PSPC_OFFAR*(RHRI_RSPBINS + 1)*SZ_REAL)

	    #-------------------------
	    # close off-axis area file
	    #-------------------------
	    call close(fd)

	    #--------------------------
	    # set up off axis histogram
	    #--------------------------
	    for ( ii = 0; ii < PSPC_OFFAR; ii = ii + 1 ) {
		DS_OAHAN(ds, ii) =
		Memr[ offar + ii * (RHRI_RSPBINS + 1)] / 60.0 / QP_INPXX(qph)
	    }

	#-----------
	# ROSAT PSPC
	#-----------
	case ROSAT_PSPC:
	    #--------------------------------------------------------------
	    # if scale (degrees per instrument pixel) wasn't in the header, 
	    # get it from the parameter
	    #--------------------------------------------------------------
	    if ( QP_INPXX(qph) == 0 ) {
		QP_INPXX(qph) = clgpsetr(np, "ros_pspc_pxx")
	    }

	    #========================================================
	    # Read the off axis histogram angles from the calibration
	    #========================================================

	    #-------------------------------------------------------
	    # The number of off-axis histrogram angles (from pspc.h)
	    #-------------------------------------------------------
	    DS_NOAH(ds) = PSPC_OFFAR

	    #----------------------------------
	    # allocate space for offaxis angles
	    #----------------------------------
	    call calloc(DS_OAHANPTR(ds), DS_NOAH(ds), TY_REAL)

	    #--------------------------------------
	    # allocate space for off-axis area file
	    #--------------------------------------
	    call salloc(offar, PSPC_OFFAR*(PSPC_RSPBINS + 1), TY_REAL)

	    #-------------------------------------
	    # get off-axis area file name and open
	    #-------------------------------------
	    call clgpset(np, ROS_OFFAR, Memc[fname], SZ_FNAME)
	    fd = open(Memc[fname], READ_ONLY, BINARY_FILE)

	    #--------------------------
	    # read in the off-axis area
	    #--------------------------
	    bytes_read = read(fd, Memr[offar],
				PSPC_OFFAR*(PSPC_RSPBINS + 1)*SZ_REAL)

	    #-------------------------
	    # close off-axis area file
	    #-------------------------
	    call close(fd)

	    #--------------------------
	    # set up off axis histogram
	    #--------------------------
	    for ( ii = 0; ii < PSPC_OFFAR; ii = ii + 1 ) {
		DS_OAHAN(ds, ii) =
		Memr[ offar + ii * (PSPC_RSPBINS + 1)] / 60.0 / QP_INPXX(qph)
	    }

	#----------------------------------------------
	# SRG HEPC1
	#----------------------------------------------
	case SRG_HEPC1:
	    #--------------------------------------------------------------
	    # if scale (degrees per instrument pixel) wasn't in the header, 
	    # get it from the parameter
	    #--------------------------------------------------------------
	    if ( QP_INPXX(qph) == 0 ) {
		QP_INPXX(qph) = clgpsetr(np, "srg_hepc1_pxx")
	    }

	    #========================================================
	    # Read the off axis histogram angles from the calibration
	    #========================================================

	    #--------------------------------------------------------
	    # The number of off-axis histrogram angles (from hepc1.h)
	    #--------------------------------------------------------
	    DS_NOAH(ds) = HEPC1_OFFAR

	    #----------------------------------
	    # allocate space for offaxis angles
	    #----------------------------------
	    call calloc(DS_OAHANPTR(ds), DS_NOAH(ds), TY_REAL)

	    #--------------------------------------
	    # allocate space for off-axis area file
	    #--------------------------------------
	    call salloc(offar, HEPC1_OFFAR*(HEPC1_RSPBINS + 1), TY_REAL)

	    #-------------------------------------
	    # get off-axis area file name and open
	    #-------------------------------------
	    call clgpset(np, SRG_H1_OFFAR, Memc[fname], SZ_FNAME)
	    fd = open(Memc[fname], READ_ONLY, BINARY_FILE)

	    #--------------------------
	    # read in the off-axis area
	    #--------------------------
	    bytes_read = read(fd, Memr[offar],
				HEPC1_OFFAR*(HEPC1_RSPBINS + 1)*SZ_REAL)

	    #-------------------------
	    # close off-axis area file
	    #-------------------------
	    call close(fd)

	    #--------------------------
	    # set up off axis histogram
	    #--------------------------
	    for ( ii = 0; ii < HEPC1_OFFAR; ii = ii + 1 ) {
		DS_OAHAN(ds, ii) =
		Memr[ offar + ii * (HEPC1_RSPBINS + 1)] / 60.0 / QP_INPXX(qph)
	    }

	#----------
	# SRG LEPC1
	#----------
	case SRG_LEPC1:
	    #--------------------------------------------------------------
	    # if scale (degrees per instrument pixel) wasn't in the header, 
	    # get it from the parameter
	    #--------------------------------------------------------------
	    if ( QP_INPXX(qph) == 0 ) {
		QP_INPXX(qph) = clgpsetr(np, "srg_lepc1_pxx")
	    }

	    #========================================================
	    # Read the off axis histogram angles from the calibration
	    #========================================================

	    #-------------------------------------------------------
	    # The number of off-axis histrogram angles (from lepc1.h)
	    #-------------------------------------------------------
	    DS_NOAH(ds) = LEPC1_OFFAR

	    #----------------------------------
	    # allocate space for offaxis angles
	    #----------------------------------
	    call calloc(DS_OAHANPTR(ds), DS_NOAH(ds), TY_REAL)

	    #--------------------------------------
	    # allocate space for off-axis area file
	    #--------------------------------------
	    call salloc(offar, LEPC1_OFFAR*(LEPC1_RSPBINS + 1), TY_REAL)

	    #-------------------------------------
	    # get off-axis area file name and open
	    #-------------------------------------
	    call clgpset(np, SRG_L1_OFFAR, Memc[fname], SZ_FNAME)
	    fd = open(Memc[fname], READ_ONLY, BINARY_FILE)

	    #--------------------------
	    # read in the off-axis area
	    #--------------------------
	    bytes_read = read(fd, Memr[offar],
				LEPC1_OFFAR*(LEPC1_RSPBINS + 1)*SZ_REAL)

	    #-------------------------
	    # close off-axis area file
	    #-------------------------
	    call close(fd)

	    #--------------------------
	    # set up off axis histogram
	    #--------------------------
	    for ( ii = 0; ii < LEPC1_OFFAR; ii = ii + 1 ) {
		DS_OAHAN(ds, ii) =
		Memr[ offar + ii * (LEPC1_RSPBINS + 1)] / 60.0 / QP_INPXX(qph)
	    }

	#-------------------
	# Default Instrument
	#-------------------
	default:
	    call eprintf("Unrecognized instrument --\n")
	    call error(1, "  for assistance, contact RSDC")

#	    #----------------------------------------------------------
#	    # if they need an off-axis histogram they can provide it in
#	    # the parameter filer.
#	    #----------------------------------------------------------
#	    DS_NOAH(ds) = clgeti("noah")
#
#	    if ( DS_NOAH(ds) > N_OAHBINS ) {
#		call errori(1, "The maximum # of offaxis histogram bins is: ",
#				N_OAHBINS)
#	    }
#
#	    #--------------------------------------------------
#	    # if there are off-axis angles set up the histogram
#	    #--------------------------------------------------
#	    if ( DS_NOAH(ds) > 0 ) {
#		if ( QP_INPXX(qph) == 0 )
#		    QP_INPXX(qph) = clgetr("instpxx")
#		# allocate space for offaxis angles
#		call calloc(DS_OAHANPTR(ds), DS_NOAH(ds), TY_REAL)
#		oahele = clgeti("oahelements")
#		call salloc(tname, SZ_LINE, TY_CHAR)
#		ii = 0
#		while ( ii < DS_NOAH(ds) - 1 ) {
#		    call sprintf(Memc[tname], SZ_LINE, "oah%d")
#		     call pargi( ( ii/oahele ) + 1 )
#		    call clscan(Memc[tname])
#		    for ( jj = 0 ; ii + 1 <= DS_NOAH(ds)
#				&& jj < oahele ; jj = jj + 1 ) {
#			call gargr(DS_OAHAN(ds, ii))
#			ii = ii + 1
#		    }
#		}
#	    }
#
#	    #------------------------------------
#	    # correct the units of off-axis angle
#	    #------------------------------------
#	    do ii = 0, DS_NOAH(ds) - 1 {
#		DS_OAHAN(ds, ii) = (DS_OAHAN(ds, ii) / QP_INPXX(qph))
#	    }

	#------------------------------------
	# END the instrument switch statement
	#------------------------------------
	}

	#---------
	# clean up
	#---------
	call clcpset(np)
	call sfree(sp)

end
