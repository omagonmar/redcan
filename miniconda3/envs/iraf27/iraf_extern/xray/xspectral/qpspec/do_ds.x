# $Header: /home/pros/xray/xspectral/qpspec/RCS/do_ds.x,v 11.0 1997/11/06 16:43:28 prosb Exp $
# $Log: do_ds.x,v $
# Revision 11.0  1997/11/06 16:43:28  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:31:46  prosb
# General Release 2.4
#
#Revision 8.1  1994/09/09  01:02:13  dennis
#Corrected error introduced with use of put_tbhead() in PROS 2.3:
#LIVETIME header parameter in the table files is restored to reflecting
#the gti's in the time-filtered input .qp file, instead of being just a
#copy of LIVETIME in the .qp file.
#
#Revision 8.0  94/06/27  17:36:09  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/18  18:04:46  dennis
#Removed "extended" parameter, as part of removing all restrictions on 
#allowed regions.
#
#Revision 7.1  94/01/07  00:42:26  dennis
#Made mask summary cards come last.
#
#Revision 7.0  93/12/27  18:58:19  prosb
#General Release 2.3
#
#Revision 6.3  93/10/29  21:05:34  dennis
#Send correct scale factor (QP_INPXX, not QP_CDELT1) to ds_putoah().
#
#Revision 6.2  93/10/22  19:06:46  dennis
#Get offaxis angles from BN struct, and pass them on to ds_putoah() 
#in DS struct.
#
#Revision 6.1  93/09/25  02:11:48  dennis
#Changed to accommodate the new file formats (RDF).
#
#Revision 6.0  93/05/24  16:53:45  prosb
#General Release 2.2
#
#Revision 5.1  93/05/12  15:45:07  orszak
#jso - freed some memory.
#
#Revision 5.0  92/10/29  22:46:48  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:29:07  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/03/05  12:59:53  orszak
#Initial revision
#
#
# Function:	do_ds
# Purpose:	Fill the dataset entry.
# Pre-cond:	
#		
# Post-cond:	
#		
# Method:	
# Description:	
# Notes:	
#

include <mach.h>

include <spectral.h>

include "qpspec.h"

procedure do_ds(simage, shead, stitle, sbn, bimage, btitle, bbn, ds, 
		obs_xtable, bal_xtable, soh_xtable, boh_xtable, 
		bh, macro, systemstr, dobkgd, display)

char	bimage[ARB]		# i: background qpoe name
char	macro[ARB]		# i: macro name of event element
char	simage[ARB]		# i: source qpoe name
char	systemstr[ARB]		# i: string for systematic error

char	obs_xtable[ARB]		# i: _obs.tab table file temporary name
char	bal_xtable[ARB]		# i: _bal.tab table file temporary name
char	soh_xtable[ARB]		# i: _soh.tab table file temporary name
char	boh_xtable[ARB]		# i: _boh.tab table file temporary name

int	display			# i: display level
int	dobkgd			# i: YES if we have background

pointer	bh			# i: bal histo pointer
pointer	bbn			# i: instrument-specific binning parameters
pointer	btitle			# i: background region summary pointer
pointer	ds			# i: data set record pointer
pointer	sbn			# i: instrument-specific binning parameters
pointer	shead			# i: source X-ray header
pointer	stitle			# i:  source region summary pointer

int	ii			# l: an index

pointer	bal_tp			# l: BAL histogram table pointer
pointer	bal_cp			# l: pointer to array of BAL column pointers
pointer	soh_tp			# l: source offaxis histogram table pointer
pointer	soh_cp			# l: pointer to array of SOH column pointers
pointer	boh_tp			# l: background offaxis histogram table pointer
pointer	boh_cp			# l: pointer to array of BOH column pointers
pointer	obs_tp			# l: observed spectral data table pointer
pointer	obs_cp			# l: pointer to array of OBS column pointers

#int	btoi()			# convert boolean to int

begin
	#===================================================================
	# Fill in the dataset structure
	#===================================================================

	#-----------------------------------------------
	# Put the BAL histogram in the dataset structure
	#-----------------------------------------------
	DS_BAL_HISTGRAM(ds) = bh

	#------------------------------------------------
	# Put header information in the dataset structure
	#------------------------------------------------
	DS_MISSION(ds)		= QP_MISSION(shead)

	DS_INSTRUMENT(ds)	= QP_INST(shead)
	DS_SUB_INSTRUMENT(ds)	= QP_SUBINST(shead)

	call strcpy(QP_OBSID(shead), DS_SEQNO(ds), SZ_LINE)

	DS_FILTER(ds)		= QP_FILTER(shead)

	DS_NPHAS(ds)		= BN_INDICES(sbn)

	DS_SOURCE_RADIUS(ds)	= BN_RADIUS(sbn)

#	DS_POINT(ds) = btoi(!extended)

	DS_ARCFRAC(ds) = BN_ARCFRAC(sbn)

	#--------------------------------------------------------------
	# Get the timing information and put into the dataset structure
	#--------------------------------------------------------------

	#--------------------------------------------------------------
	# First try to get live time correction from qpoe header; if it
	# is not there use what we set in the instrument section (from 
	# parameter file).
	#---------------------------------------------------------------
	if ( (  QP_DEADTC(shead)       > EPSILON) ||
	     ( (QP_DEADTC(shead) -1.0) > EPSILON)    ) {
	    DS_LIVECORR(ds) = QP_DEADTC(shead)
	}
	else {
	    DS_LIVECORR(ds) = BN_LTCOR(sbn)
	}

	#------------------------------------------
	# Everything else should be in the goodtime
	#------------------------------------------
	if ( BN_GOODTIME(sbn) > EPSILOND )
	    DS_LIVETIME(ds) = real(BN_GOODTIME(sbn)) * DS_LIVECORR(ds)
	else
	    call error(1, "QPSPEC: problem with timing; no good times for this QPOE file.")

	#-------------------------------------------------------------------
	# If there are off-axis histograms put them in the dataset structure 
	#-------------------------------------------------------------------
	if ( BN_NOAH(sbn) != 0 ) {
	    call calloc(DS_OAHANPTR(ds), BN_NOAH(sbn), TY_REAL)
	    call calloc(DS_OAHPTR(ds), BN_NOAH(sbn), TY_REAL)
	    call calloc(DS_BK_OAHPTR(ds), BN_NOAH(sbn), TY_REAL)
	    DS_NOAH(ds) = BN_NOAH(sbn)
	    do ii = 0, BN_NOAH(sbn) - 1 {
		DS_OAHAN(ds, ii) = BN_OAHAN(sbn, ii)
		DS_OAH(ds, ii) = BN_OAH(sbn, ii)
		DS_BK_OAH(ds, ii) = BN_OAH(bbn, ii)
	    }
	}

	#---------------------------------------------------------------
	# calculate the energy bounds and place in the dataset structure
	#---------------------------------------------------------------
	call ds_energy_bounds(ds)


	#===================================================================
	# Now make the table files
	#===================================================================

	switch ( DS_INSTRUMENT(ds) )  {

	 case EINSTEIN_IPC:
	    #------------------------------
	    # Make BAL histogram table file
	    #------------------------------
	    call ds_create_bal(bal_xtable, bal_tp, bal_cp)
	    call qps_puthead(bal_tp, simage, shead, stitle, sbn, 
				bimage, btitle, ds, macro, systemstr, dobkgd)
	    call ds_putbal(bal_tp, bal_cp, bh)
	    call tbtclo(bal_tp)
	    call mfree(bal_cp, TY_POINTER)

	 case EINSTEIN_HRI:
	    #----------------------------
	    # (No auxiliary file to make)
	    #----------------------------

	 default:
	    #---------------------------------------------------------
	    # Make source and background offaxis histogram table files
	    #---------------------------------------------------------
	    call ds_create_oah(soh_xtable, soh_tp, soh_cp, 
	                       boh_xtable, boh_tp, boh_cp)
	    call qps_puthead(soh_tp, simage, shead, stitle, sbn, 
				bimage, btitle, ds, macro, systemstr, dobkgd)
	    call qps_puthead(boh_tp, simage, shead, stitle, sbn, 
				bimage, btitle, ds, macro, systemstr, dobkgd)
	    call ds_putoah(soh_tp, soh_cp, boh_tp, boh_cp, ds, QP_INPXX(shead))
	    call tbtclo(soh_tp)
	    call tbtclo(boh_tp)
	    call mfree(soh_cp, TY_POINTER)
	    call mfree(boh_cp, TY_POINTER)
        }

	#----------------------------------
	# Make observed spectral data table
	#----------------------------------
	call ds_create_spec(obs_xtable, obs_tp, obs_cp)
	call qps_puthead(obs_tp, simage, shead, stitle, sbn, 
				bimage, btitle, ds, macro, systemstr, dobkgd)
	call ds_putspec(obs_tp, obs_cp, ds)
	call tbtclo(obs_tp)
	call mfree(obs_cp, TY_POINTER)


	#===================================================================
	# Finish up
	#===================================================================

	#------------------------
	# display if requested to
	#------------------------
	call ds_disp(ds, display)

	#------------------------------
	# free locally-allocated memory
	#------------------------------
	if ( BN_NOAH(sbn) != 0 ) {
	    call mfree(DS_BK_OAHPTR(ds), TY_REAL)
	    call mfree(DS_OAHPTR(ds), TY_REAL)
	    call mfree(DS_OAHANPTR(ds), TY_REAL)
	}
end


#
#  QPS_PUTHEAD -- write info, including qpspec-specific info, to table header
#
procedure qps_puthead(tp, simage, shead, stitle, sbn, bimage, btitle, ds, 
			macro, systemstr, dobkgd)
char	bimage[ARB]		# i: background qpoe name
char	macro[ARB]		# i: macro name of event element
char	simage[ARB]		# i: source qpoe name
char	systemstr[ARB]		# i: string for systematic error
int	dobkgd			# i: YES if we have background
pointer	btitle			# i: background region summary pointer
pointer	ds			# i: pointer to sdf record
pointer	sbn			# i: instrument-specific binning parameters
pointer	shead			# i: source X-ray header
pointer	stitle			# i: source region summary pointer
pointer	tp			# i: table pointer

begin
	#-------------------------------------------------------
	# Write the header parameters to the spectral data table
	#-------------------------------------------------------
	call ds_puthead(tp, shead, ds)

	#-----------------------------
	# correct livetime (and dtcor)
	#-----------------------------
	call tbhadr(tp, "LIVETIME", DS_LIVETIME(ds))
	call tbhadr(tp, "DTCOR", DS_LIVECORR(ds))

	#-------------------------------------------------------
	# the rest of the dataset header are instrument optional
	#-------------------------------------------------------
	call tbhadt(tp, "comment",
		"The following parameters are optional for this instrument:")

	#-----------------------------------
	# get instrument specific parameters
	#-----------------------------------

	#------------------------
	# write PI or PHA binning
	#------------------------
	call tbhadt(tp, "chantype", macro)

	#-------------------------------
	# Write out the systematic error
	#-------------------------------
	call tbhadt(tp, "syserr", systemstr)

	#--------------------------------------
	# write the normalizations to the table
	#--------------------------------------
	call tbhadr(tp, "u_norm", BN_UNORM(sbn))
	call tbhadr(tp, "t_norm", BN_TNORM(sbn))
	call tbhadr(tp, "norm", BN_NORMFACTOR(sbn))

	#----------------------------------
	# put source information into table
	#----------------------------------
	call put_tbh(tp, "source", simage, Memc[stitle])

	#--------------------------------------
	# put background information into table
	#--------------------------------------
	if ( dobkgd == YES )
	    call put_tbh(tp, "bkgd", bimage, Memc[btitle])
	else
	    call tbhadt(tp, "bkgd", "no bkgd")
end
