#$Header: /home/pros/xray/xspectral/source/RCS/dsdisp.x,v 11.0 1997/11/06 16:42:00 prosb Exp $
#$Log: dsdisp.x,v $
#Revision 11.0  1997/11/06 16:42:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:18  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:41  prosb
#General Release 2.3.1
#
#Revision 7.3  94/05/18  17:57:12  dennis
#Removed display of "point source" (boolean) parameter; it's no longer 
#used.
#
#Revision 7.2  94/04/09  00:47:20  dennis
#Changed screen display of off-axis angle, from always being the 
#off-axis angle of the center of the region, to being that except for 
#ROSAT instruments, for which it is mean off-axis angle of counted events.
#
#Revision 7.1  94/03/29  11:28:30  dennis
#Added EINSTEIN_MPC case.
#
#Revision 7.0  93/12/27  18:54:49  prosb
#General Release 2.3
#
#Revision 6.3  93/12/08  02:28:05  dennis
#"net" and "neterr" restored (instead of "counts" and "stat_err").
#
#Revision 6.2  93/12/04  00:17:47  dennis
#Changed screen display to match new column headings in _obs.tab file.
#
#Revision 6.1  93/10/22  16:21:33  dennis
#Added SRG_HEPC1, SRG_LEPC1 cases, for DSRI.
#
#Revision 6.0  93/05/24  16:49:27  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/01  11:11:20  prosb
#jso - finished pretty output for qpspec.
#
#Revision 3.2  92/03/25  11:24:40  orszak
#jso - no change for first installation of new qpspec
#
#Revision 3.1  91/09/22  19:05:32  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:01  prosb
#General Release 1.1
#
#Revision 2.2  91/07/12  15:47:12  prosb
#jso - made spectral.h a systemwide.  addded sub_instrument, and corrected
#sequence number
#
#Revision 2.1  91/04/19  11:41:11  mo
#MC	4/19/91		Added display for the PSPC filter parameter
#			so it gets displayed with the rest of the DS stuff.
#
#Revision 2.0  91/03/06  23:02:21  pros
#General Release 1.0
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#

include <mach.h>

include <spectral.h>

#-------------------------------------------------------------------------
#
# ds_disp - display data set information
#
#-------------------------------------------------------------------------

procedure ds_disp(ds, display)

pointer	ds					# i: pointer to sdf record
int	display					# i: display level

begin

	if ( display == 0 )
	    return

	call printf("\n")

	#-------------------------------------------------------------
	# we have to check for these as the ds routines don't fill 'em
	#-------------------------------------------------------------
	if ( DS_FILENAME(ds) !=0 ) {
	    call printf("ds:\t\t\t%-d\n")
	    call pargi(DS_REFNUM(ds))

	    call printf("file:\t\t\t%-s\n")
	    call pargstr(Memc[DS_FILENAME(ds)])

	    call printf("scale:\t\t\t%-.2f\n")
	    call pargr(DS_SCALE(ds))
	}

	call printf("mission:\t\t%-d\n")
	call pargi(DS_MISSION(ds))

	call printf("seqno:\t\t\t%-s\n")
	call pargstr(DS_SEQNO(ds))

	if ( DS_INSTRUMENT(ds) == EINSTEIN_IPC ) {
	    call printf("instrument:\t\tEINSTEIN_IPC\n")
	}
	else if ( DS_INSTRUMENT(ds) == EINSTEIN_HRI ) {
	    call printf("instrument:\t\tEINSTEIN_HRI\n")
	}
	else if ( DS_INSTRUMENT(ds) == EINSTEIN_MPC ) {
	    call printf("instrument:\t\tEINSTEIN_MPC\n")
	}
	else if ( DS_INSTRUMENT(ds) == ROSAT_HRI ) {
	    call printf("instrument:\t\tROSAT_HRI\n")
	}
	else if ( DS_INSTRUMENT(ds) == ROSAT_PSPC ) {
	    call printf("instrument:\t\tROSAT_PSPC\n")
	}
	# DSRI entries, ALLAN 93/07/12
	else if ( DS_INSTRUMENT(ds) == SRG_HEPC1 ) {
	    call printf("instrument:\t\tSRG_HEPC1\n")
	}
	else if ( DS_INSTRUMENT(ds) == SRG_LEPC1 ) {
	    call printf("instrument:\t\tSRG_LEPC1\n")
	}
	else {
	    call printf("instrument:\t\t%-d\n")
	    call pargi(DS_INSTRUMENT(ds))
	}

	call printf("sub-instrument:\t\t%-d\n")
	call pargi(DS_SUB_INSTRUMENT(ds))

	call printf("no. pha channels:\t%-d\n")
	call pargi(DS_NPHAS(ds))

	if ( DS_INSTRUMENT(ds) == ROSAT_HRI || 
	     DS_INSTRUMENT(ds) == ROSAT_PSPC  ) {
	    call printf("mean off-axis angle\n")
	    call printf("   of events (arcmin):\t%-.2f\n")
	    call pargr(DS_MEAN_EVENT_OFFAXIS_ANGLE(ds))
	}
	else {
	    call printf("off-axis angle of center\n")
	    call printf("   of region (arcmin):\t%-.2f\n")
	    call pargr(DS_REGION_OFFAXIS_ANGLE(ds))
	}

	call printf("radius (arcmin):\t%-.2f\n")
	call pargr(DS_SOURCE_RADIUS(ds))

#	call printf("point source:\t\t%d\n")
#	call pargi(DS_POINT(ds))

	call printf("filter:\t\t\t%d\n")
	call pargi(DS_FILTER(ds))

	call printf("livetime (sec):\t\t%-.2f\n")
	call pargr(DS_LIVETIME(ds))

	if ( DS_SOURCENO(ds) !=0 ){
	    call printf("source:\t\t\t%-d\n")
	    call pargi(DS_SOURCENO(ds))
	}

	if ( (DS_X(ds) > EPSILON) || (DS_Y(ds) > EPSILON) ) {
	    call printf("x, y:\t\t\t%-.2f, %-.2f\n")
	    call pargr(DS_X(ds))
	    call pargr(DS_Y(ds))
	}

	if ( (DS_OLD_Y(ds) > EPSILON) || (DS_OLD_Z(ds) > EPSILON) ) {
	    call printf("old y, z:\t\t%-.2f, %-.2f\n")
	    call pargr(DS_OLD_Y(ds))
	    call pargr(DS_OLD_Z(ds))
	}

	if ( (DS_RA(ds) > EPSILON) || (DS_DEC(ds) > EPSILON) ) {
	    call printf("RA, DEC:\t\t%-.2f, %-.2f\n")
	    call pargr(DS_RA(ds))
	    call pargr(DS_DEC(ds))
	}

	if ( (DS_GLONG(ds) > EPSILON) || (DS_GLAT(ds) > EPSILON) ) {
	    call printf("GLONG, GLAT:\t\t%-.2f, %-.2f\n")
	    call pargr(DS_GLONG(ds))
	    call pargr(DS_GLAT(ds))
	}

	if ( DS_VIGNETTING(ds) > EPSILON ) {
	    call printf("vignetting:\t\t%-.2f\n")
	    call pargr(DS_VIGNETTING(ds))
	}

	if ( DS_LIVECORR(ds) > EPSILON ) {
	    call printf("livetime corr:\t\t%-.2f\n")
	    call pargr(DS_LIVECORR(ds))
	}

	if ( DS_INSTRUMENT(ds) == EINSTEIN_IPC ) {
	    call printf("arc fraction:\t\t%-.2f\n")
	    call pargr(DS_ARCFRAC(ds))
	}

	if ( DS_SAREA(ds) > EPSILON ) {
	    call printf("src area (sq. pix.):\t%-.2f\n")
	    call pargr(DS_SAREA(ds))
	}

	call printf("cts_tot (count):\t")
	call print_eighty(DS_SOURCE(ds), DS_NPHAS(ds))
	call printf("\n")

	if ( DS_BAREA(ds) > EPSILON ) {
	    call printf("bkgd area (sq. pix.):\t%-.2f\n")
	    call pargr(DS_BAREA(ds))
	}

	call printf("ccts_bkg (count):\t")
	call print_eighty(DS_BKGD(ds), DS_NPHAS(ds))
	call printf("\n")
	
	call printf("net (count):\t\t")
	call print_eighty(DS_OBS_DATA(ds), DS_NPHAS(ds))
	call printf("\n")

	call printf("neterr (count):\t\t")
	call print_eighty(DS_OBS_ERROR(ds), DS_NPHAS(ds))
	call printf("\n")

	#--------------------------------------------
	# display user-defined channels, if necessary
	#--------------------------------------------
	if ( DS_CHANNEL_FIT(ds) !=0 ) {
	    call ds_dispchan(Memi[DS_CHANNEL_FIT(ds)], DS_NPHAS(ds), display)
	}

	#--------------------------------
	# display bal histo, if necessary
	#--------------------------------
	if ( (DS_INSTRUMENT(ds) == EINSTEIN_IPC) &&
		(DS_BAL_HISTGRAM(ds) !=0) ) {
	    call ds_dispbal(DS_BAL_HISTGRAM(ds), display)
	}
end

#------------------------------------------------------------------------
#
# ds_dispchan - display channels for fit
#
#------------------------------------------------------------------------

procedure ds_dispchan(fit, nphas, display)

int	fit[ARB]				# i: fit array
int	nphas					# i: size of fit array
int	display					# i: display level

int	ii					# l: loop counter

begin

	if( display ==0 )
	    return

	call printf("chans for fit:\t")
	do ii = 1, nphas {
	    call printf("%0d")
	    call pargi(fit[ii])
	}
	call printf("\n")
end

#-----------------------------------------------------------------------
#
# ds_dispbal - display bal info
#
#-----------------------------------------------------------------------

procedure ds_dispbal(bh, display)

pointer	bh					# i: pointer to bal record
int	display					# i: display level

int	ii					# l: loop counter

begin

	if( display ==0 )
	    return

	call printf("BAL info:\n")

	call printf("BAL entries:\t\t%-d\n")
	call pargi(BH_ENTRIES(bh))

	call printf("BAL mean:\t\t%-.2f\n")
	call pargr(BH_MEAN_BAL(bh))

	call printf("BAL value, percent:")
	do ii = 1, BH_ENTRIES(bh) {
	    if ( ii != 1 ) {
		call printf("\t\t")
	    }
	    call printf("\t%-7.2f    %-7.2f\n")
	    call pargr(BH_BAL(bh,ii))
	    call pargr(BH_PERCENT(bh,ii))
	}
	call printf("\n")

end

#------------------------------------------------------------------------
#
#	PRINT_EIGHTY - print output in less then eighty columns per row
#
#------------------------------------------------------------------------

procedure print_eighty(counts, nphas)

int	nphas
pointer	counts

int	counter
int	ii

pointer	tname			# l: temp name holder

int	strlen()

begin

	#-------------------
	# initialize counter
	#-------------------
	counter = 0

	#-----------------
	# temp name holder
	#-----------------
	call salloc(tname, SZ_LINE, TY_CHAR)

	do ii = 1, nphas {

	    call sprintf(Memc[tname], SZ_LINE, "%-.2f ")
	     call pargr(Memr[counts+ii-1])

	    counter = counter + strlen(Memc[tname]) + 1
	    if ( counter > 55 ) {
		call printf("\n\t\t\t")
		counter = strlen(Memc[tname]) + 1
	    }
	    call printf("%s ")
	     call pargstr(Memc[tname])
	}

end
