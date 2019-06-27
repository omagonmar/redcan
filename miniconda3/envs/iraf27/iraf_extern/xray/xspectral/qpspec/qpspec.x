# $Header: /home/pros/xray/xspectral/qpspec/RCS/qpspec.x,v 11.0 1997/11/06 16:43:34 prosb Exp $
# $Log: qpspec.x,v $
# Revision 11.0  1997/11/06 16:43:34  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:31:55  prosb
# General Release 2.4
#
#Revision 8.1  1994/08/10  14:06:24  dvs
#Now passing good time filter (gtf) from init_qpoe to do_bal_histo
#to help make bal histogram.
#
#Revision 7.1  94/05/18  18:20:38  dennis
#Removed extended parameter, and removed (to init_qpoe.x) the source 
#region parsing setup; these are part of allowing arbitrary regions and 
#providing rapid feedback on region descriptor syntax errors.
#
#Revision 7.0  93/12/27  18:58:33  prosb
#General Release 2.3
#
#Revision 6.1  93/09/25  02:10:25  dennis
#Changed to accommodate the new file formats (RDF).
#
#Revision 6.0  93/05/24  16:54:04  prosb
#General Release 2.2
#
#Revision 5.6  93/05/20  03:30:03  dennis
#Expanded source region parameter buffer to SZ_LINE chars.
#
#Revision 5.5  93/05/12  15:46:22  orszak
#jso - removed reference to memory that is not passed.
#
#Revision 5.4  93/05/04  18:23:04  orszak
#jso - i used memory correctly.
#
#Revision 5.3  93/05/04  16:53:51  orszak
#jso - made the error message cleaner.
#
#Revision 5.1  93/04/27  00:23:59  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  22:46:59  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:29:28  prosb
#General Release 2.0:  April 1992
#
#Revision 3.5  92/03/05  12:57:24  orszak
#jso - new version for qpspec upgrade.
#
#
# Module:	qpspec
# Project:	PROS -- ROSAT RSDC
# Purpose:	To create the spectral dataset from a qpoe file.
# Description:	This file will create a spectral dataset from a qpoe file.
#		It will extract the counts in the spectral bins, background
#		subtract, calculate errors.  For Einstein IPC it will
#		extract the BAL histogram; for ROSAT PSPC it will calculate
#		the source and background off-axis histogram.
#
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0}   initial version before 3/91
#		{2} Jeff Orszak -- restructured -- 2/92
#
#--------------------------------------------------------------------------

include <ctype.h>
include <ext.h>

include <spectral.h>
include "qpspec.h"

procedure t_qpspec()

bool	clobber			# clobber old table file

int	display			# display level
int	dobkgd			# YES if we have background
int	dotimenorm		# YES for live time normalization

pointer	balstr			# BAL histogram string
pointer	bbn			# background instrument binning parameters
pointer	bh			# BAL histogram pointer
pointer	bhead			# background qpoe header
pointer	bim			# background qpoe pointer
pointer	bimage			# background qpoe file name
pointer	bio			# background event pointer
pointer	bpm			# background pixel mask pointer
pointer	btitle			# background region summary pointer
pointer	ds			# data set record pointer
pointer gtf			# good time filter
pointer	macro			# macro name of event element
pointer	np			# parameter file pointer
pointer	sbn			# source instrument binning parameters
pointer	shead			# source qpoe header
pointer	sim 			# source qpoe pointer
pointer	simage			# source qpoe file name
pointer	sio			# source event pointer
pointer	sp			# stack pointer
pointer	spm			# source pixel mask pointer
pointer	stitle			# source region summary pointer
pointer	system			# systematic errors pointer
pointer	systemstr		# string for systematic error

pointer	obs_table	 	# _obs.tab table file name
pointer	obs_xtable	 	# _obs.tab table file temporary name
pointer	bal_table	 	# _bal.tab table file name
pointer	bal_xtable	 	# _bal.tab table file temporary name
pointer	soh_table	 	# _soh.tab table file name
pointer	soh_xtable	 	# _soh.tab table file temporary name
pointer	boh_table	 	# _boh.tab table file name
pointer	boh_xtable	 	# _boh.tab table file temporary name

bool	clgetb()		# get boolean parameter

int	btoi()			# convert boolean to int
int	clgeti()		# get int parameter

pointer	clopset()		# open pset (parameter file)

real	clgetr()		# get a real param

begin

	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#---------------------
	# allocate stack space
	#---------------------

	#---------------------
	# BAL histogram string
	#---------------------
	call salloc(balstr, SZ_LINE, TY_CHAR)

	#--------------------------
	# background qpoe file name
	#--------------------------
	call salloc(bimage, SZ_PATHNAME, TY_CHAR)

	#----------------------------
	# macro name of event element
	#----------------------------
	call salloc(macro, SZ_FNAME, TY_CHAR)

	#----------------------
	# source qpoe file name
	#----------------------
	call salloc(simage, SZ_PATHNAME, TY_CHAR)

	#----------------------------
	# string for systematic error
	#----------------------------
	call salloc(systemstr, SZ_LINE, TY_CHAR)

	#-------------------------
 	# _obs.tab table file name
	#-------------------------
	call salloc(obs_table, SZ_PATHNAME, TY_CHAR)
	call strcpy("", Memc[obs_table], SZ_PATHNAME)

	#-----------------------------------
 	# _obs.tab table file temporary name
	#-----------------------------------
	call salloc(obs_xtable, SZ_PATHNAME, TY_CHAR)
	call strcpy("", Memc[obs_xtable], SZ_PATHNAME)

	#-----------------------
	# source binning records
	#-----------------------
	call calloc(sbn, SZ_BINNING, TY_STRUCT)

	#---------------------------
	# background binning records
	#---------------------------
	call calloc(bbn, SZ_BINNING, TY_STRUCT)

	#-----------------------------
	# open the pset parameter file
	#-----------------------------
	np = clopset("pkgpars")

	#---------------------------
	# get some of the parameters
	#---------------------------
	display		= clgeti("display")
	dotimenorm	= btoi(clgetb ("timenorm"))
	BN_UNORM(sbn)	= clgetr("normfactor")
	BN_TNORM(sbn) = 1.0

	#-----------------------------------------
	# allocate space for the dataset structure
	#-----------------------------------------
	call calloc(ds, LEN_DS, TY_STRUCT)

	#--------------------------------------------------------------
	# open the qpoe file and region mask for source and background; 
	#  also set up the source binning record and 
	#  get instrument-specific parameters
	#--------------------------------------------------------------
	call init_qpoe(Memc[simage], sim, sio, spm, shead, stitle, sbn, 
	               Memc[bimage], bim, bio, bpm, bhead, btitle, bbn, 
	               dobkgd, ds, display, 
	               np, Memc[balstr], bh, gtf, system, Memc[systemstr], 
	               Memc[macro])

	#-------------------------------------------------------------
	# get the _obs.tab table file name or root and develop all the 
	#  table file names
	#-------------------------------------------------------------
	call clgstr("table", Memc[obs_table], SZ_PATHNAME)
	clobber = clgetb ("clobber")
	call rootname(Memc[simage], Memc[obs_table], EXT_OBS, SZ_PATHNAME)
	call clobbername(Memc[obs_table], Memc[obs_xtable], clobber, 
								SZ_PATHNAME)
	switch ( QP_INST(shead) ) {

	 case EINSTEIN_IPC:
	    call salloc(bal_table, SZ_PATHNAME, TY_CHAR)
	    call strcpy("", Memc[bal_table], SZ_PATHNAME)
	    call rootname(Memc[obs_table], Memc[bal_table], EXT_BAL, 
								SZ_PATHNAME)
	    call salloc(bal_xtable, SZ_PATHNAME, TY_CHAR)
	    call strcpy("", Memc[bal_xtable], SZ_PATHNAME)
	    call clobbername(Memc[bal_table], Memc[bal_xtable], clobber, 
								SZ_PATHNAME)

	 case EINSTEIN_HRI:

	 default:
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
	}

	#-------------------------------------------------------------
	# store the name of the _obs.tab file in the dataset structure
	#-------------------------------------------------------------
	call calloc(DS_FILENAME(ds), SZ_PATHNAME, TY_CHAR)
	call strcpy(Memc[obs_table], Memc[DS_FILENAME(ds)], SZ_PATHNAME)

	#-----------------------
	# Some debug information
	#-----------------------
	if( display >=3 ) {
	    call msk_disp("SOURCE", Memc[simage], Memc[stitle])
	    if( dobkgd == YES )
		call msk_disp("BACKGROUND", Memc[bimage], Memc[btitle])
	}

	#--------------------
	# do the qpoe binning
	#--------------------
	call bin_qpoe(shead, sio, spm, sbn, bio, bpm, bbn, ds, 
	              system, dotimenorm, dobkgd, display)

	#--------------------
	# do BAL histograming
	#--------------------
	if ( bh > 0 ) {
	    call do_bal_histo(Memc[balstr], bh, gtf, ds, sim, sbn, display)
	}

	#------------------------------------------------
	# fill the dataset struct, make the table file(s)
	#------------------------------------------------
	call do_ds(Memc[simage], shead, stitle, sbn, 
	           Memc[bimage],        btitle, bbn, ds, 
	           Memc[obs_xtable], Memc[bal_xtable], 
	           Memc[soh_xtable], Memc[boh_xtable], 
	           bh, Memc[macro], Memc[systemstr], dobkgd, display)

	#-------------------------
	# close all the io handles
	#-------------------------
	call pl_close(spm)
	call qpio_close(sio)
	call qp_close(sim)
	if ( dobkgd == YES ) {
	    call pl_close(bpm)
	    call qpio_close(bio)
	    call qp_close(bim)
	}

	#---------------------------------------------
	# check if table names begin with number
	# (which is not legal in the rest of spectral)
	#---------------------------------------------
	if ( IS_DIGIT(Memc[obs_table + 0]) ) {
	    call eprintf("\nQPSPEC WARNING: filenames with leading digit cannot be used as input\n")
	    call eprintf("                to 'fit' task.\n")
	    call eprintf("                Rename .tab files to have leading alphabetic character.\n")
	}


	if ( display > 0 ) {
	    call printf("Output table file(s):  %s")
	     call pargstr(Memc[obs_table])
	    switch ( QP_INST(shead) ) {

	     case EINSTEIN_IPC:
		call printf(", %s")
		 call pargstr(Memc[bal_table])

	     case EINSTEIN_HRI:

	     default:
		call printf(", %s, %s")
		 call pargstr(Memc[soh_table])
		 call pargstr(Memc[boh_table])
	    }
	    call printf("\n")
	    call flush(STDOUT)
	}


	call finalname(Memc[obs_xtable], Memc[obs_table])
	switch ( QP_INST(shead) ) {

	 case EINSTEIN_IPC:
	    call finalname(Memc[bal_xtable], Memc[bal_table])

	 case EINSTEIN_HRI:

	 default:
	    call finalname(Memc[soh_xtable], Memc[soh_table])
	    call finalname(Memc[boh_xtable], Memc[boh_table])
	}

	#--------------
	# free up space
	#--------------
	call mfree(shead, TY_STRUCT)
	call mfree(stitle, TY_CHAR)

	call mfree(DS_SOURCE(ds), TY_REAL)
	call mfree(DS_BKGD(ds),TY_REAL)
	call mfree(DS_OBS_DATA(ds), TY_REAL)
	call mfree(DS_OBS_ERROR(ds), TY_REAL)
	call mfree(DS_FILENAME(ds), TY_CHAR)

	call mfree(sbn, TY_STRUCT)

	call mfree(bbn, TY_STRUCT)

	call mfree(ds, TY_STRUCT)

	if (bh!=0)
	{
	   call mfree(bh, TY_STRUCT)
	}

	if (gtf!=0)
	{
	   call mfree(gtf, TY_CHAR)
	}

	call mfree(system, TY_REAL)

	call mfree(btitle, TY_CHAR)
	if( dobkgd == YES )
		call mfree(bhead, TY_STRUCT)

	#------------------------------
	# close the pset parameter file
	#------------------------------
	call clcpset(np)

	#---------------
	# free the stack
	#---------------
	call sfree(sp)

end
