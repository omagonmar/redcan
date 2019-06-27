# $Header: /home/pros/xray/xspectral/qpspec/RCS/get_inst_pars.x,v 11.0 1997/11/06 16:43:30 prosb Exp $
# $Log: get_inst_pars.x,v $
# Revision 11.0  1997/11/06 16:43:30  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:31:48  prosb
# General Release 2.4
#
#Revision 8.1  1994/08/10  14:06:59  dvs
#Calls mk_gtifilter to make good time filter.
#
#Revision 7.2  94/05/18  18:12:23  dennis
#Removed "extended" parameter and conditioning RADIUS initialization on it; 
#part of removing all restrictions on allowed regions.
#
#Revision 7.1  94/04/25  20:26:43  dennis
#Made BN_OAHAN() always be a positive quantity (it is a radius); 
#fixes an error found by Larry, not reported yet.
#
#Revision 7.0  93/12/27  18:58:22  prosb
#General Release 2.3
#
#Revision 6.3  93/12/02  13:44:51  dennis
#Checked out for vignetting correction change, but it turned out not to 
#affect this file.
#
#Revision 6.2  93/11/12  17:54:37  dennis
#Corrected comments concerning QP_INPXX field.
#
#Revision 6.1  93/10/22  19:21:00  dennis
#Added SRG_HEPC1, SRG_LEPC1 cases, for DSRI.
#
#Revision 6.0  93/05/24  16:53:50  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:29:11  prosb
#General Release 2.0:  April 1992
#
#Revision 1.3  92/04/01  11:04:11  prosb
#jso - added ROSAT HRI off axis histogram.
#
#Revision 1.2  92/03/06  10:35:32  prosb
#jso - correction to get first build to work
#
#Revision 1.1  92/03/05  13:01:54  orszak
#Initial revision
#
#
# Function:	get_inst_pars
# Purpose:	To get instrument specific parameters and values.
# Pre-cond:	all the qpoe stuff is open
#		pset parameter file is open
#		binning records are allocated
# Post-cond:	
#		
# Method:	
# Description:	
# Notes:	
#

include <ctype.h>

include <spectral.h>

include "qpspec.h"
include "../source/pspc.h"
include "../source/rhri.h"
include "../source/hepc1.h"
include "../source/lepc1.h"

procedure get_inst_pars(np, sim, sevlist, shead, sbn, bbn, balstr, bh, gtf, system,
			systemstr, macro, display)

char	balstr[ARB]		# o: bal histo string
char	macro[ARB]		# o: macro name of event element
char    sevlist[ARB]		# i: source event list
char	systemstr[ARB]		# o: string for systematic error

int	bytes_read		# l: returned by read
int	display			# i: debug level
int	fd			# l: offar file descriptor
int	ii			# l: loop variable
int	jj			# l: loop variable
int	oahele			# l: number of off axis elements for def instr
int	type			# l: for lookup

pointer	bbn			# io: background binning parameters
pointer	bh			# o: BAL histogram pointer
pointer gtf			# o: good time filter
pointer	defsystem		# l: default string for systematic error
pointer	detx			# l: detector x
pointer	dety			# l: detector y
pointer	fname			# l: offar file name
pointer	offar			# l: off axis histogram calibration file
pointer	sbn			# io: instrument-specific binning parameters
pointer	shead			# i: source X-ray header
pointer	sim 			# i: source qpoe pointer
pointer	sp			# l: stack pointer
pointer	system			# o: systematic errors
pointer	tempstr			# l: temp string
pointer	tname			# l: temp name holder
pointer	np			# i: pset parameter pointer

bool	streq()			# string compare

int	clgeti()		# get int parameter
int	lookup()		# get qpoe macro expansion
int	open()			# open a file
int	read()			# read from a file

real	clgetr()		# get real parameter
real	clgpsetr()		# get real parameter from open pset

begin
	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#---------------------
	# allocate stack space
	#---------------------

	#------------------------------------
	# default string for systematic error
	#------------------------------------
	call salloc(defsystem, SZ_LINE, TY_CHAR)

	#-----------
	# detector x
	#-----------
	call salloc(detx, SZ_FNAME, TY_CHAR)

	#-----------
	# detector y
	#-----------
	call salloc(dety, SZ_FNAME, TY_CHAR)

	#----------------
	# offar file name
	#----------------
	call salloc(fname, SZ_FNAME, TY_CHAR)

	#------------
	# temp string
	#------------
	call salloc(tempstr, SZ_LINE, TY_CHAR)

	#-----------------
	# temp name holder
	#-----------------
	call salloc(tname, SZ_LINE, TY_CHAR)

	bh=0
	gtf=0

	#---------------
	# get instrument
	#---------------
	switch ( BN_INST(sbn) ) {

	#-------------------------------
	# Einstein IPC
	#	a) Normal binning is PHA
	#-------------------------------
	case EINSTEIN_IPC:
	    BN_INDICES(sbn) = BN_INDICES(sbn) - 1
	    call clgstr("ein_ipc_binning", macro, SZ_FNAME)
	    BN_BOFF(sbn) = lookup(sim, macro, type)
	    BN_ARCFRAC(sbn) = clgpsetr(np, "arcfrac")

	    #-------------------------------------------------------------
	    # These form defaults for these parameters, which might change
	    # before the dataset is written.
	    #-------------------------------------------------------------
	    call clgpset(np, "ein_ipc_syserr", Memc[defsystem], SZ_LINE)
	    BN_RADIUS(sbn) = clgpsetr(np, "ein_ipc_radius")
	    BN_LTCOR(sbn) = clgpsetr(np, "ein_ipc_ltcor")

	    #-----------------------------------------------------
	    # If binning is by PI channel then should use BAL=15.2
	    #-----------------------------------------------------
	    call clgstr("bal_histo", balstr, SZ_LINE)
	    if ( streq("pi", macro) ) {
		call strcpy("15.2", Memc[tempstr], SZ_LINE)
		call eprintf("\nSetting bal_histo = 15.2 for PI binning.\n")
		call flush(STDERR)
	    }
	    else {
		call strcpy("", Memc[tempstr], SZ_LINE)
	    }
	    if ( streq("", balstr) && !streq("", Memc[tempstr]) )
		call strcpy(Memc[tempstr], balstr, SZ_LINE)

	    #-------------------------------------
	    # allocate space for the BAL histogram
	    #-------------------------------------
	    call calloc(bh, LEN_BH, TY_STRUCT)
	
	    call mk_gtifilter(sevlist,sim,gtf,display)


	#-------------------------------------------------------------------
	# Einstein HRI
	#	a) if full=YES error; Einstein HRI no longer has this option
	#-------------------------------------------------------------------
	case EINSTEIN_HRI:
	    if ( BN_FULL(sbn) == NO ) {
		BN_INDICES(sbn) = 1
	    }
	    else {
		call error(1, "QPSPEC: FULL=YES is not valid for Einstein HRI.")
	    }
	    call clgstr("ein_hri_binning", macro, SZ_FNAME)
	    BN_BOFF(sbn) = lookup(sim, macro, type)

	    #-------------------------------------------------------------
	    # These form defaults for these parameters, which might change
	    # before the dataset is written.
	    #-------------------------------------------------------------
	    call clgpset(np, "ein_hri_syserr", Memc[defsystem], SZ_LINE)
	    BN_RADIUS(sbn) = clgpsetr(np, "ein_hri_radius")
	    BN_LTCOR(sbn) = clgpsetr(np, "ein_hri_ltcor")

	#-----------------------------------------------------
	# ROSAT HRI
	#	a) full=YES will give 15 (16 -1) channels some
	#	some energy information
	#-----------------------------------------------------
	case ROSAT_HRI:
	    if ( BN_FULL(sbn) == NO ) {
		BN_INDICES(sbn) = RHRI_CHANNELS
	    }
	    else {
		BN_INDICES(sbn) = RHRI_PITCH - 1
	    }
	    call clgstr("ros_hri_binning", macro, SZ_FNAME)
	    BN_BOFF(sbn) = lookup(sim, macro, type)

	    #-------------------------------------------------------------
	    # These form defaults for these parameters, which might change
	    # before the dataset is written.
	    #-------------------------------------------------------------
	    call clgpset(np, "ros_hri_syserr", Memc[defsystem], SZ_LINE)
	    BN_RADIUS(sbn) = clgpsetr(np, "ros_hri_radius")
	    BN_LTCOR(sbn) = clgpsetr(np, "ros_hri_ltcor")

	    #--------------------------------------------------------------
	    # if scale (degrees per instrument pixel) wasn't in the header, 
	    # get it from the parameter
	    #--------------------------------------------------------------
	    if ( QP_INPXX(shead) == 0 ) {
		QP_INPXX(shead) = clgpsetr(np, "ros_hri_pxx")
	    }

	    #---------------------------------------------------------
	    # Read the off axis histogram angles from the calibration.
	    #---------------------------------------------------------

	    #-------------------------------------------------------
	    # The number of off-axis histrogram angles (from rhri.h)
	    #-------------------------------------------------------
	    BN_NOAH(sbn) = PSPC_OFFAR

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

	    #--------------------------------------------------------
	    # convert off-axis histogram angles from arcmin to pixels
	    #--------------------------------------------------------
	    for ( ii = 0; ii < PSPC_OFFAR; ii = ii + 1 ) {
		BN_OAHAN(sbn, ii) = abs(
		  Memr[ offar + ii * (RHRI_RSPBINS + 1)] / 60.0 / 
							QP_INPXX(shead))
	    }

	#----------------------------------------------
	# ROSAT PSPC
	#	a) need to calculate off-axis histogram
	#----------------------------------------------
	case ROSAT_PSPC:
	    if ( BN_FULL(sbn) == NO ) {
		BN_INDICES(sbn) = PSPC_CHANNELS
	    }
	    else {
		BN_INDICES(sbn) = PSPC_PITCH
	    }
	    call clgstr("ros_pspc_binning", macro, SZ_FNAME)
	    BN_BOFF(sbn) = lookup(sim, macro, type)

	    #-------------------------------------------------------------
	    # These form defaults for these parameters, which might change
	    # before the dataset is written.
	    #-------------------------------------------------------------
	    call clgpset(np, "ros_pspc_syserr", Memc[defsystem], SZ_LINE)
	    BN_RADIUS(sbn) = clgpsetr(np, "ros_pspc_radius")
	    BN_LTCOR(sbn) = clgpsetr(np, "ros_pspc_ltcor")

	    #--------------------------------------------------------------
	    # if scale (degrees per instrument pixel) wasn't in the header, 
	    # get it from the parameter
	    #--------------------------------------------------------------
	    if ( QP_INPXX(shead) == 0 ) {
		QP_INPXX(shead) = clgpsetr(np, "ros_pspc_pxx")
	    }

	    #---------------------------------------------------------
	    # Read the off axis histogram angles from the calibration.
	    #---------------------------------------------------------

	    #-------------------------------------------------------
	    # The number of off-axis histrogram angles (from pspc.h)
	    #-------------------------------------------------------
	    BN_NOAH(sbn) = PSPC_OFFAR

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

	    #--------------------------------------------------------
	    # convert off-axis histogram angles from arcmin to pixels
	    #--------------------------------------------------------
	    for ( ii = 0; ii < PSPC_OFFAR; ii = ii + 1 ) {
		BN_OAHAN(sbn, ii) = abs(
		  Memr[ offar + ii * (PSPC_RSPBINS + 1)] / 60.0 / 
							QP_INPXX(shead))
	    }

	#----------------------------------------------
	# SRG HEPC1
	#	a) need to calculate off-axis histogram
	#----------------------------------------------
	case SRG_HEPC1:
	    if ( BN_FULL(sbn) == NO ) {
		BN_INDICES(sbn) = HEPC1_CHANNELS
	    }
	    else {
		BN_INDICES(sbn) = HEPC1_PITCH
	    }
	    call clgstr("srg_hepc1_binning", macro, SZ_FNAME)
	    BN_BOFF(sbn) = lookup(sim, macro, type)

	    #-------------------------------------------------------------
	    # These form defaults for these parameters, which might change
	    # before the dataset is written.
	    #-------------------------------------------------------------
	    call clgpset(np, "srg_hepc1_syserr", Memc[defsystem], SZ_LINE)
	    BN_RADIUS(sbn) = clgpsetr(np, "srg_hepc1_radius")
	    BN_LTCOR(sbn) = clgpsetr(np, "srg_hepc1_ltcor")

	    #--------------------------------------------------------------
	    # if scale (degrees per instrument pixel) wasn't in the header, 
	    # get it from the parameter
	    #--------------------------------------------------------------
	    if ( QP_INPXX(shead) == 0 ) {
		QP_INPXX(shead) = clgpsetr(np, "srg_hepc1_pxx")
	    }

	    #---------------------------------------------------------
	    # Read the off axis histogram angles from the calibration.
	    #---------------------------------------------------------

	    #-------------------------------------------------------
	    # The number of off-axis histrogram angles (from hepc1.h)
	    #-------------------------------------------------------
	    BN_NOAH(sbn) = HEPC1_OFFAR

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

	    #--------------------------------------------------------
	    # convert off-axis histogram angles from arcmin to pixels
	    #--------------------------------------------------------
	    for ( ii = 0; ii < HEPC1_OFFAR; ii = ii + 1 ) {
		BN_OAHAN(sbn, ii) = abs(
		  Memr[ offar + ii * (HEPC1_RSPBINS + 1)] / 60.0 / 
							QP_INPXX(shead))
	    }

	#----------------------------------------------
	# SRG LEPC1
	#	a) need to calculate off-axis histogram
	#----------------------------------------------
	case SRG_LEPC1:
	    if ( BN_FULL(sbn) == NO ) {
		BN_INDICES(sbn) = LEPC1_CHANNELS
	    }
	    else {
		BN_INDICES(sbn) = LEPC1_PITCH
	    }
	    call clgstr("srg_lepc1_binning", macro, SZ_FNAME)
	    BN_BOFF(sbn) = lookup(sim, macro, type)

	    #-------------------------------------------------------------
	    # These form defaults for these parameters, which might change
	    # before the dataset is written.
	    #-------------------------------------------------------------
	    call clgpset(np, "srg_lepc1_syserr", Memc[defsystem], SZ_LINE)
	    BN_RADIUS(sbn) = clgpsetr(np, "srg_lepc1_radius")
	    BN_LTCOR(sbn) = clgpsetr(np, "srg_lepc1_ltcor")

	    #--------------------------------------------------------------
	    # if scale (degrees per instrument pixel) wasn't in the header, 
	    # get it from the parameter
	    #--------------------------------------------------------------
	    if ( QP_INPXX(shead) == 0 ) {
		QP_INPXX(shead) = clgpsetr(np, "srg_lepc1_pxx")
	    }

	    #---------------------------------------------------------
	    # Read the off axis histogram angles from the calibration.
	    #---------------------------------------------------------

	    #-------------------------------------------------------
	    # The number of off-axis histrogram angles (from lepc1.h)
	    #-------------------------------------------------------
	    BN_NOAH(sbn) = LEPC1_OFFAR

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

	    #--------------------------------------------------------
	    # convert off-axis histogram angles from arcmin to pixels
	    #--------------------------------------------------------
	    for ( ii = 0; ii < LEPC1_OFFAR; ii = ii + 1 ) {
		BN_OAHAN(sbn, ii) = abs(
		  Memr[ offar + ii * (LEPC1_RSPBINS + 1)] / 60.0 / 
							QP_INPXX(shead))
	    }

	#-------------------
	# Default Instrument
	#-------------------
	default:

	    #----------------------
	    # get binning parameter
	    #----------------------
	    call clgstr("binning", macro, SZ_FNAME)
	    BN_BOFF(sbn) = lookup(sim, macro, type)

	    #-----------------------
	    # get instrument details
	    #-----------------------
	    BN_INDICES(sbn) = clgeti("channels")

	    call clgstr("inst_syserr", Memc[defsystem], SZ_LINE)

	    BN_RADIUS(sbn) = clgetr("radius")

	    #----------------------------------------------------------
	    # if they need an off-axis histogram they can provide it in
	    # the parameter filer.
	    #----------------------------------------------------------
	    BN_NOAH(sbn) = clgeti("noah")

	    if ( BN_NOAH(sbn) > N_OAHBINS ) {
		call errori(1, "The maximum # of offaxis histogram bins is: ",
				N_OAHBINS)
	    }

	    #--------------------------------------------------
	    # if there are off-axis angles set up the histogram
	    #--------------------------------------------------
	    if ( BN_NOAH(sbn) > 0 ) {
		if ( QP_INPXX(shead) == 0 )
		    QP_INPXX(shead) = clgetr("instpxx")
		oahele = clgeti("oahelements")
		ii = 0
		while ( ii < BN_NOAH(sbn) - 1 ) {
		    call sprintf(Memc[tname], SZ_LINE, "oah%d")
		     call pargi( ( ii/oahele ) + 1 )
		    call clscan(Memc[tname])
		    for ( jj = 0 ; ii + 1 <= BN_NOAH(sbn)
				&& jj < oahele ; jj = jj + 1 ) {
			call gargr(BN_OAHAN(sbn, ii))
			ii = ii + 1
		    }
		}
	    }

	    #------------------------------------
	    # correct the units of off-axis angle
	    #------------------------------------
	    do ii = 0, BN_NOAH(sbn) - 1 {
		BN_OAHAN(sbn, ii) = abs(BN_OAHAN(sbn, ii) / QP_INPXX(shead))
	    }

	#------------------------------------
	# END the instrument switch statement
	#------------------------------------
	}

	# If there is an OffAxis Histogram set up the binning offsets
	#

	if ( BN_NOAH(sbn) != 0 ) {
		call clgstr("detx", Memc[detx], SZ_FNAME)
		call clgstr("dety", Memc[dety], SZ_FNAME)
		if ( QP_XDOPTI(shead) == 0 ) 
			QP_XDOPTI(shead) = clgetr("xdopti")
		BN_XREF(sbn) = QP_XDOPTI(shead)
		if ( QP_YDOPTI(shead) == 0 )
			QP_YDOPTI(shead) = clgetr("ydopti")
		BN_YREF(sbn) = QP_YDOPTI(shead)
		BN_XOFF(sbn) = lookup(sim, Memc[detx],  type)
		BN_YOFF(sbn) = lookup(sim, Memc[dety],  type)
	}

	BN_INDICES(bbn) = BN_INDICES (sbn)		# these must match!

	# get systematic error
	call clgstr("syserr", systemstr, SZ_LINE)
	call calloc(system, BN_INDICES(sbn), TY_REAL)
	call calc_system(systemstr, Memc[defsystem], Memr[system], BN_INDICES(sbn))

	#---------------
	# free the stack
	#---------------
	call sfree(sp)

end


int procedure lookup(qp, macro, type)

pointer	qp
char	macro[ARB]
int	type
#--

int	ev_lookup()
int	offset

begin
	if( ev_lookup(qp, macro, type, offset) == YES ) {
	    if( type != TY_SHORT )
		call errstr(1, "qpoe parameters must be TY_SHORT (for now)",
				macro)
	} else
	   call errstr(1, "can't find qpoe parameter", macro)
	
	return offset
end


#  calc_SYSTEM - get systematic error
#
procedure calc_system(systemstr, defsystem, system, nbins)

char	systemstr[ARB]				# i: systematic error string
char	defsystem[ARB]				# i: default systematic error
real	system[ARB]				# o: output systematic error
int	nbins					# i: number of channels

int 	nvals					# l: number of values
int	nchar					# l: return form ctod
int	ip					# l: index pointer
int	i					# l: loop counter
double	dval					# l: temp double
int	ctod()					# l: convert char to double
bool	streq()					# i: string compare

begin
	# if the systematic error string is null, use the default string
	if( streq("", systemstr) )
	    call strcpy(defsystem, systemstr, SZ_LINE)
	# pick out the systematic error values from the string	
	nvals = 1
	ip = 1
	while( TRUE ){
	    # get the next value (as a double)
	    nchar = ctod(systemstr, ip, dval)
	    # break on end of string
	    if( nchar ==0 ) break
	    # make sure we have not overflowed
	    if( nvals > nbins )
		call error(1, "too many systematic error values specified")
	    # stuff value into the array (as a real)
	    system[nvals] = dval
	    # inc to next value
	    nvals = nvals + 1
	    # skip past commas and spaces
	    while((IS_WHITE(systemstr[ip])) || (systemstr[ip] == ','))
		ip = ip+1
	}
	# if we have no values, just exit
	if( nvals ==1 )
	    return
	# if we don't have all values, copy last value over and over again
	for(i=nvals; i<=nbins; i=i+1)
	    system[i] = system[i-1]		
end
