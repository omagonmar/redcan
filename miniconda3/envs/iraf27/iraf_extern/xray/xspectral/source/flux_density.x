#$Header: /home/pros/xray/xspectral/source/RCS/flux_density.x,v 11.0 1997/11/06 16:43:08 prosb Exp $
#$Log: flux_density.x,v $
#Revision 11.0  1997/11/06 16:43:08  prosb
#General Release 2.5
#
#Revision 1.1  1997/03/27 22:05:39  prosb
#Initial revision
#
#Revision 9.0  1995/11/16  19:29:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:28  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:20  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:09  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:18  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:43  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:54  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:16  prosb
#General Release 1.1
#
#Revision 2.2  91/07/19  14:39:20  orszak
#jso - changes to improve the output of xflux
#
#Revision 2.1  91/07/12  16:09:51  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:03:13  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# flux_density.x
#
# Compute the flux_density 

include <spectral.h>
include "flux.h"
include "intermed.h"

procedure flux_density(data, outfile, energy, nenergies)

pointer	data
char	outfile[ARB]
real	energy[nenergies]
int	nenergies
#--

pointer	otb
pointer ocp

double	flxd[10]
define FLXD	flxd[1]			# Flxd array offsets
define UNAB	flxd[2]
define LUMD	flxd[3]
define ENGY	flxd[4]
define DKPC	flxd[5]
define DZ	flxd[6]
define HZER	flxd[7]
define QZER	flxd[8]

char	abs[3]

int	nrows
int	i

bool	tbtacc(), streq()
double	intplog_model()


begin
	otb = 0
	ocp = 0

	if ( !tbtacc(outfile) ) {		# make a new table if none
		nrows = 0
		call new_flxd(outfile, otb, ocp)
	} else
		call opn_flxd(outfile, otb, ocp, nrows) 


	call flux_params(HZER, QZER, DKPC, DZ)

	call printf("\nOutput file: %s\n")
	call pargstr(outfile)

	call printf("Model: %s\n")
	 call pargstr(INT_BEST(HEADER_PTR(data)))

	       if ( streq(INT_ABS(HEADER_PTR(data)), "morrison_maccammon") ) {
		call strcpy("MM", abs, 3)
		call printf("Absorption type: Morrison & Maccammon\n")
	} else if ( streq(INT_ABS(HEADER_PTR(data)), "brown_gould") ) {
		call strcpy("BG", abs, 3)
		call printf("Absorption type: Brown & Gould\n")
	} else {
		call strcpy("UN", abs, 3)
		call printf("Absorption type: Unknown\n")
	}

	call printf("Units:\n")
	call printf("\tflux density (microJy = 10**-29 ergs/cm**2/s/Hz)\n")
	call printf("\tluminosity density (10**34 ergs/s/Hz)\n")
	call printf("\tenergy (keV)\n")
	call printf("\tH_0 (km/s/Mpc)\n")

	call printf("\nCompute flux density %sfor energy%s")
	 if ( DKPC != INDEFD )	call pargstr("and luminosity density ")
	 else			call pargstr("")
	 if ( nenergies == 1 )	call pargstr(" :\n\n")
	 else			call pargstr("s :\n\n")

	call printf("    flxd    unabs_f      Ld       energy    D_kpc    z    H_0   q_0\n")
	call printf("    ----    -------      --       ------    -----   ---   ---   ---\n\n")

	for ( i = 1; i <= nenergies; i = i + 1 ) {	# Compute flxd data

		ENGY = energy[i]

#####################  begin  ############
#JCC(3/27/97) - Updated to check the range of the input energy.

                if (( ENGY <= Memd[LENERGY_PTR(data)] ) ||
                    ( ENGY >= Memd[HENERGY_PTR(data)+SPECTRAL_BINS-1] ))
                {  call eprintf("\n\n The requested output energy should be ranged between %8.4f and %8.4f Kev\n\n   ")
                   call pargd(  Memd[ LENERGY_PTR(data)])
                   call pargd(  Memd[ HENERGY_PTR(data)+SPECTRAL_BINS-1] )
                   call error(1,"   requested output energy out of range !")
                }
#####################  end  ##############

		FLXD = 10**(
			intplog_model(Memd[  INCIDENT_PTR(data)], 
					log10(energy[i])))*
			1000 * Kev2Erg9 / Kev2Hz17
		UNAB = 10**(
			intplog_model(Memd[REDSHIFTED_PTR(data)],
					log10(energy[i])))*
			1000 * Kev2Erg9 / Kev2Hz17
		if ( DKPC != INDEFD ) 
		 LUMD = 10**(
			intplog_model(Memd[   EMITTED_PTR(data)],
					log10(energy[i])))*
			1.0d8 * 4 * PI * ( DKPC * Kpc2cm21 )**2 * 
			Kev2Erg / Kev2Hz
		else
		 LUMD = INDEFD

		# Write out the flxd[] to the table in one gulp
		#
		call tbrptd(otb, Memi[ocp + 0], flxd,            8, nrows + i)
		call tbrptt(otb, Memi[ocp + 8], abs,   3,        1, nrows + i)
		call tbrptt(otb, Memi[ocp + 9], INT_BEST(HEADER_PTR(data)),
				MODWIDTH, 1, nrows + i)

		call printf(" %9.3e %9.3e %9.3e    %5.2f  %9.3e %5.2f %5.1f %5.2f\n")
		 call pargd(FLXD)
		 call pargd(UNAB)
		 call pargd(LUMD)
		 call pargd(ENGY)
		 call pargd(DKPC)
		 call pargd(DZ)
		 call pargd(HZER)
		 call pargd(QZER)
	}

	call tbtclo(otb)
end
