#$Header: /home/pros/xray/xspectral/source/RCS/intermed.x,v 11.0 1997/11/06 16:42:23 prosb Exp $
#$Log: intermed.x,v $
#Revision 11.0  1997/11/06 16:42:23  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:55  prosb
#General Release 2.3
#
#Revision 6.1  93/12/21  01:44:15  dennis
#Made int_puthead() put the name of the response matrix file in the header 
#of the _int.tab file.
#
#Revision 6.0  93/05/24  16:50:44  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:45  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:15  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:26  prosb
#General Release 1.1
#
#Revision 2.2  91/07/19  14:41:38  orszak
#jso - corrected spelling error
#
#Revision 2.1  91/07/12  16:15:59  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:03:57  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  INTERMED.X -- routines that deal with the intermediate model spectra
#

include <tbset.h>
include <spectral.h>
include "intermed.h"

# define max number of table columns for the observed data set
define  MAX_CP 4

# define table column offsets
define	EMITTED_CP	0
define	INTRINS_CP	1
define	REDSHIFTED_CP	2
define	INCIDENT_CP	3

# define table column names
define  ENERGY_COL	"energy"
define  HENERGY_COL	"hi_energy"
define  LENERGY_COL	"lo_energy"
define	EMITTED_COL	"emitted"
define	INTRINS_COL	"intrinsic"
define	REDSHIFTED_COL	"redshifted"
define	INCIDENT_COL	"incident"

# the energy column is handles specially
define  LO_ENERGY_COL	"lo_energy"
define  HI_ENERGY_COL	"hi_energy"
define  ENERGY_COL	"energy"

#
# INT_OUTPUT -- output intermediate spectra
#
procedure int_output(tname, fp, best)

char	tname[ARB]			# i: table name
pointer	fp				# i: frame pointer
char	best[ARB]			# i: model string

int	tp				# l: table pointer
int	cp				# l: column pointers

begin
	# create the table and define columns
	call int_create(tname, fp, tp, cp)
	# write header
	call int_puthead(fp, tp, best)
	# write columns
	call int_put(fp, tp, cp)
	# close table
	call tbtclo(tp)
	# free up column space
	call mfree(cp, TY_POINTER)
end

#
# INT_CREATE -- create an intermediate spectra file
#
procedure  int_create(tname, fp, tp, cp)

pointer	tname			# i: table name
pointer	fp			# i: frame pointer
pointer tp			# i: table pointer
pointer	cp			# o: column pointers

char	name[SZ_LINE]		# l: temp column names
int	i			# l: loop counter
int	n			# l: number of models
int	tbtopn()		# l: open a table

begin
	# open a new table file
	tp = tbtopn(tname, NEW_FILE, 0)

	# get the number of models in this frame
	n = FP_MODEL_COUNT(fp)

	# allocate space for the component and total columns
	# (if n=1, we get an extra, but what of that!)
	call calloc(cp, (n+1)*MAX_CP+3, TY_POINTER)

	# create the energy columns
	call tbcdef(tp, Memi[cp+(n+1)*MAX_CP+0],  LO_ENERGY_COL,
				"", "%9.3f", TY_REAL, 1, 1)
	call tbcdef(tp, Memi[cp+(n+1)*MAX_CP+1],  HI_ENERGY_COL,
				"", "%9.3f", TY_REAL, 1, 1)
	call tbcdef(tp, Memi[cp+(n+1)*MAX_CP+2],  ENERGY_COL,
				"", "%9.3f", TY_REAL, 1, 1)

	# create the total spectra columns
	call tbcdef(tp, Memi[cp+EMITTED_CP],  EMITTED_COL,
				"", "%9.3f", TY_REAL, 1, 1)
	call tbcdef(tp, Memi[cp+INTRINS_CP],  INTRINS_COL,
				"", "%9.3f", TY_REAL, 1, 1)
	call tbcdef(tp, Memi[cp+REDSHIFTED_CP], REDSHIFTED_COL,
				"","%9.3f", TY_REAL, 1, 1)
	call tbcdef(tp, Memi[cp+INCIDENT_CP], INCIDENT_COL,
				"", "%9.3f", TY_REAL, 1, 1)

	# if there is more than one model, we have to make component columns
	if( n >1 ){
	    do i=1, n{
		call sprintf(name, SZ_LINE, "%s_%d")
		call pargstr(EMITTED_COL)
		call pargi(i)
		call tbcdef(tp, Memi[cp+(i*MAX_CP+EMITTED_CP)],  name,
				"", "%9.3f", TY_REAL, 1, 1)
		call sprintf(name, SZ_LINE, "%s_%d")
		call pargstr(INTRINS_COL)
		call pargi(i)
		call tbcdef(tp, Memi[cp+(i*MAX_CP+INTRINS_CP)],  name,
				"", "%9.3f", TY_REAL, 1, 1)
		call sprintf(name, SZ_LINE, "%s_%d")
		call pargstr(REDSHIFTED_COL)
		call pargi(i)
		call tbcdef(tp, Memi[cp+(i*MAX_CP+REDSHIFTED_CP)],  name,
				"", "%9.3f", TY_REAL, 1, 1)
		call sprintf(name, SZ_LINE, "%s_%d")
		call pargstr(INCIDENT_COL)
		call pargi(i)
		call tbcdef(tp, Memi[cp+(i*MAX_CP+INCIDENT_CP)],  name,
				"", "%9.3f", TY_REAL, 1, 1)
	    }
	}

	# create the table
	call tbtcre(tp)
end

#
# INT_PUTHEAD -- write intermediate params info into table
#
procedure  int_puthead(fp, tp, best)

pointer	fp			# i: frame pointer
pointer tp			# i: table pointer
char	best[ARB]		# i: best values model string

pointer	sp			# l: stack pointer
pointer	dtmat_fname		# l: response matrix file name

begin
	# mark the top of the stack
	call smark(sp)

	# identify the response matrix file
	call salloc(dtmat_fname, SZ_FNAME, TY_CHAR)
	call get_respfile(FP_OBSERSTACK(fp, 1), Memc[dtmat_fname])
	call tbhadt(tp, "respfile", Memc[dtmat_fname])

	# write the best fit model string
	call tbhadt(tp, "best", best)
	# write the absorption string
	switch(FP_ABSORPTION(fp)){
	 case MORRISON_MCCAMMON:
	    call tbhadt(tp, "abs", "morrison_maccammon")
	 case BROWN_GOULD:
	    call tbhadt(tp, "abs", "brown_gould")
	 default:
	    call tbhadt(tp, "abs", "unknown")
	}

	# write the number of component models
	call tbhadi(tp, "nmodels", FP_MODEL_COUNT(fp))
	# write out the final norm for now
	call tbhadr(tp, "norm", FP_NORM(fp))

	# write some useful comments
	call tbhadt(tp, "comment",
		"Explanation of columns:")
	call tbhadt(tp, "comment",
		"EMITTED - spectrum at the source")
	call tbhadt(tp, "comment",
		"INTRINSIC - emitted after applying intrinsic absorption")
	call tbhadt(tp, "comment",
		"REDSHIFTED - intrinsic after applying redshift")
	call tbhadt(tp, "comment",
		"INCIDENT - redshifted after applying galactic absorption")
	call tbhadt(tp, "comment",
		"LO_ENERGY, HI_ENERGY - energy bin boundaries in units of keV")
	call tbhadt(tp, "comment",
		"ENERGY - log10 of central bin energy")
	call tbhadt(tp, "comment",
		"All other columns are in units of log10(keV/cm**2/sec/keV)")

	# restore the stack pointer
	call sfree(sp)
end

#
# INT_PUT -- fill intermediate columns
#
procedure int_put(fp, tp, cp)

pointer	fp			# i: frame pointer
pointer tp			# i: table pointer
pointer	cp			# i: column pointers

int	i, j			# l: loop counters
int	n			# l: number of models
int	model			# l: model pointer
real	norm			# l: final norm to apply
double	bin_energy()		# l: energy of each bin

begin
	# get the number of models in this frame
	n = FP_MODEL_COUNT(fp)
	# get final norm to apply
	norm = alog10(FP_NORM(fp))

	# write the total spectra and energy
	do j=1, SPECTRAL_BINS{
		call tbrptr(tp, Memi[cp+(n+1)*MAX_CP+0],
		    real(bin_energy(real(j-0.5-1))), 1, j)
		call tbrptr(tp, Memi[cp+(n+1)*MAX_CP+1],
		    real(bin_energy(real(j+0.5-1))), 1, j)
		call tbrptr(tp, Memi[cp+(n+1)*MAX_CP+2],
		    alog10(real(bin_energy(real(j-1)))), 1, j)

		call tbrptr(tp, Memi[cp+EMITTED_CP],
		    real(Memd[FP_EMITTED(fp)+j-1])+norm, 1, j)
		call tbrptr(tp, Memi[cp+INTRINS_CP],
		    real(Memd[FP_INTRINS(fp)+j-1])+norm, 1, j)
		call tbrptr(tp, Memi[cp+REDSHIFTED_CP],
		    real(Memd[FP_REDSHIFTED(fp)+j-1])+norm, 1, j)
		call tbrptr(tp, Memi[cp+INCIDENT_CP],
		    real(Memd[FP_INCIDENT(fp)+j-1])+norm, 1, j)
	}

	# fill the predicted data column
	if( n >1 ){
	    do i=1, n{
		model = FP_MODELSTACK(fp, i)
		do j=1, SPECTRAL_BINS{
			call tbrptr(tp, Memi[cp+(i*MAX_CP+EMITTED_CP)],
			    real(Memd[MODEL_EMITTED(model)+j-1])+norm, 1, j)
			call tbrptr(tp, Memi[cp+(i*MAX_CP+INTRINS_CP)],
			    real(Memd[MODEL_INTRINS(model)+j-1])+norm, 1, j)
			call tbrptr(tp, Memi[cp+(i*MAX_CP+REDSHIFTED_CP)],
			    real(Memd[MODEL_REDSHIFTED(model)+j-1])+norm, 1, j)
			call tbrptr(tp, Memi[cp+(i*MAX_CP+INCIDENT_CP)],
			    real(Memd[MODEL_INCIDENT(model)+j-1])+norm, 1, j)
		}
	    }
	}
end


procedure int_get(tp, ip)

pointer tp
pointer	ip
#--

int	nbins
pointer flag
pointer cp

int	tbpsta()
pointer sp

begin

	call smark(sp)
	call salloc(flag, nbins, TY_INT)

	call calloc(ip, SZ_INTERMED, TY_POINTER)

	call int_gethead(tp, ip)

	nbins = tbpsta(tp, TBL_NROWS)
	call calloc(    ENERGY_PTR(ip), nbins, TY_DOUBLE)
	call calloc(   HENERGY_PTR(ip), nbins, TY_DOUBLE)
	call calloc(   LENERGY_PTR(ip), nbins, TY_DOUBLE)
	call calloc(   EMITTED_PTR(ip), nbins, TY_DOUBLE)
	call calloc(REDSHIFTED_PTR(ip), nbins, TY_DOUBLE)
	call calloc(   INTRINS_PTR(ip), nbins, TY_DOUBLE)
	call calloc(  INCIDENT_PTR(ip), nbins, TY_DOUBLE)
	
	# read in the columns
	
        call tbcfnd(tp,    ENERGY_COL, cp, 1)
	if ( cp == NULL ) call error(1, "energy column missing from input file")
        call tbcgtd(tp, cp, Memd[  ENERGY_PTR(ip)], Memi[flag], 1, nbins)

        call tbcfnd(tp,   HENERGY_COL, cp, 1)
	if ( cp == NULL ) call error(1, "hi_energy column missing from input file")
        call tbcgtd(tp, cp, Memd[ HENERGY_PTR(ip)], Memi[flag], 1, nbins)

        call tbcfnd(tp,   LENERGY_COL, cp, 1)
	if ( cp == NULL ) call error(1, "lo_energy column missing from input file")
        call tbcgtd(tp, cp, Memd[ LENERGY_PTR(ip)], Memi[flag], 1, nbins)

        call tbcfnd(tp,   EMITTED_COL, cp, 1)
	if ( cp == NULL ) call error(1, "emitted column missing from input file")
        call tbcgtd(tp, cp, Memd[  EMITTED_PTR(ip)], Memi[flag], 1, nbins)

        call tbcfnd(tp,   INTRINS_COL, cp, 1)
	if ( cp == NULL ) call error(1, "intrinsic column missing from input file")
        call tbcgtd(tp, cp, Memd[  INTRINS_PTR(ip)], Memi[flag], 1, nbins)

        call tbcfnd(tp,REDSHIFTED_COL, cp, 1)
	if ( cp == NULL ) call error(1, "redshifted column missing from input file")
        call tbcgtd(tp, cp, Memd[REDSHIFTED_PTR(ip)], Memi[flag], 1, nbins)

        call tbcfnd(tp,  INCIDENT_COL, cp, 1)
	if ( cp == NULL ) call error(1, "incident column missing from input file")
        call tbcgtd(tp, cp, Memd[ INCIDENT_PTR(ip)], Memi[flag], 1, nbins)

	call sfree(sp)
end


procedure int_raze(ip)

pointer	ip
#--

begin
	call mfree(    ENERGY_PTR(ip), TY_DOUBLE)
	call mfree(   HENERGY_PTR(ip), TY_DOUBLE)
	call mfree(   LENERGY_PTR(ip), TY_DOUBLE)
	call mfree(   EMITTED_PTR(ip), TY_DOUBLE)
	call mfree(REDSHIFTED_PTR(ip), TY_DOUBLE)
	call mfree(   INTRINS_PTR(ip), TY_DOUBLE)
	call mfree(  INCIDENT_PTR(ip), TY_DOUBLE)

	call mfree(    HEADER_PTR(ip), TY_CHAR)

	call mfree(ip, TY_POINTER)
end


procedure int_gethead(tp, ip)

pointer	tp
pointer ip
#--

begin
	call calloc(HEADER_PTR(ip), SZ_INTHEAD, TY_CHAR)

	call tbhgtt(tp, "BEST", INT_BEST(HEADER_PTR(ip)), SZ_LINE)
	call tbhgtt(tp, "ABS" , INT_ABS (HEADER_PTR(ip)), SZ_LINE)
end
	






