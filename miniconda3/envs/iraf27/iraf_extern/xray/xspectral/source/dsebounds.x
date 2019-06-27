#$Header: /home/pros/xray/xspectral/source/RCS/dsebounds.x,v 11.0 1997/11/06 16:42:01 prosb Exp $
#$Log: dsebounds.x,v $
#Revision 11.0  1997/11/06 16:42:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:45  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/17  10:29:25  mo
#MC	5/17/94		Made non-supported instrument just a warning - not			
#			a fatal error
#
#Revision 7.0  93/12/27  18:54:52  prosb
#General Release 2.3
#
#Revision 6.1  93/10/22  16:52:44  dennis
#Added SRG_HEPC1, SRG_LEPC1 cases, for DSRI.
#
#Revision 6.0  93/05/24  16:49:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:53  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/05  13:33:22  orszak
#jso - add rosat hri energies.
#
#Revision 3.1  91/09/22  19:05:34  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:02  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:52:17  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:02:24  pros
#General Release 1.0
#
#
#  DS_ENERGY_BOUNDS - caclulate energy bounds and place them in ds struct
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
include <spectral.h>

procedure  ds_energy_bounds (ds)

pointer	 ds				# i: data set pointer

int      nphas				# l: number of phas bins
int	 nbounds			# l: number of energy bounds
pointer	 energies			# l: lo/hi energy bounds array
pointer	 sp				# l: stack pointer

begin
	# mark the stack
	call smark(sp)
	# get number of bins
	nphas = DS_NPHAS(ds)
	# number of bounds is one more
	nbounds = nphas + 1
	# allocate space for the low energy bounds array
	if( DS_LO_ENERGY(ds) == NULL )
	    call calloc(DS_LO_ENERGY(ds), nphas, TY_REAL)
	# allocate space for the hi energy bounds array
	if( DS_HI_ENERGY(ds) == NULL )
	    call calloc(DS_HI_ENERGY(ds), nphas, TY_REAL)
	# allocate an array for all energy bounds
	# must be 1 more than nphas (for last upper bound)
	call salloc(energies, nbounds, TY_REAL)	
	# and clear all energy array
	call aclrr (Memr[energies], nbounds)

	# for the known instruments ...
	switch ( DS_INSTRUMENT(ds) ) {
	case EINSTEIN_HRI:
	    call hri_energy (Memr[energies], nbounds)
	case EINSTEIN_IPC:
	    call ipc_energy (ds, Memr[energies], nbounds)
	case EINSTEIN_MPC:
	    call mpc_energy (Memr[energies], nbounds)
	case ROSAT_HRI:
	    call rhri_energy(Memr[energies], nbounds)
	case ROSAT_PSPC:
	    call pspc_energy(Memr[energies], nbounds)
	# DSRI entries to support hepc/lepc
	case SRG_HEPC1:
	    call hepc1_energy(Memr[energies], nbounds)
	case SRG_LEPC1:
	    call lepc1_energy(Memr[energies], nbounds)
	default:
	    call aclrr(Memr[energies], nphas)
	    call aclrr(Memr[energies+1], nphas)
	    call eprintf("WARNING: Energy bounds not available - zeroing")
	}

	# now move the energy bounds into the lo and hi arrays
	call amovr(Memr[energies], Memr[DS_LO_ENERGY(ds)], nphas)
	call amovr(Memr[energies+1], Memr[DS_HI_ENERGY(ds)], nphas)

	# free up stack space
	call sfree(sp)
end
