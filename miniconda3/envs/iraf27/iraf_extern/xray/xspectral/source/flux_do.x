#$Header: /home/pros/xray/xspectral/source/RCS/flux_do.x,v 11.0 1997/11/06 16:42:07 prosb Exp $
#$Log: flux_do.x,v $
#Revision 11.0  1997/11/06 16:42:07  prosb
#General Release 2.5
#
#Revision 9.4  1997/03/27 22:07:36  prosb
#JCC(3/27/97) - Updated the error message.
#
#Revision 9.3  1997/03/11  22:38:36  prosb
#JCC(3/11/97) - Update to check the range of input energy ;
#             - Exchange the declaration of HIEN & LOEN.
#
#Revision 9.0  1995/11/16  19:29:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:13  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:00  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:11  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:30  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:48  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:12  prosb
#General Release 1.1
#
#Revision 2.2  91/07/19  14:34:42  orszak
#jso - changes to improve output of xflux
#
#Revision 2.1  91/07/12  16:08:49  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:03:02  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# flux_do.x
#
# Compute the flux 

include <math.h>

include <spectral.h>
include "flux.h"
include "intermed.h"


procedure flux_do(data, outfile, energy1, energy2, nenergies)

pointer	data
char	outfile[ARB]
real	energy1[nenergies]
real	energy2[nenergies]
int	nenergies
#--

pointer	otb
pointer ocp

double	flux[10]
define FLUX	flux[1]			# Flux array offsets
define UNAB	flux[2]
define LUMI	flux[3]
define LOEN	flux[4]                 #JCC
define HIEN	flux[5]                 #JCC
define DKPC	flux[6]
define DZ	flux[7]
define HZER	flux[8]
define QZER	flux[9]

char	abs[3]

int	nrows
int	i

bool	tbtacc(), streq()
double	areaof_model()


begin
	otb = 0
	ocp = 0

	if ( !tbtacc(outfile) ) {		# make a new table if none
		nrows = 0
		call new_flux(outfile, otb, ocp)
	} else
		call opn_flux(outfile, otb, ocp, nrows) 


	call flux_params(HZER, QZER, DKPC, DZ)

	call printf("\nOutput file: %s\n")
	call pargstr(outfile)
	call flush(STDOUT)

	call unlog_array(Memd[  INCIDENT_PTR(data)],
			 Memd[  INCIDENT_PTR(data)], SPECTRAL_BINS)
	call unlog_array(Memd[REDSHIFTED_PTR(data)],
			 Memd[REDSHIFTED_PTR(data)], SPECTRAL_BINS)
	call unlog_array(Memd[   EMITTED_PTR(data)],
			 Memd[   EMITTED_PTR(data)], SPECTRAL_BINS)

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
	call printf("\tflux (ergs/cm**2/s)\n")
	call printf("\tluminosity (10**34 ergs/s)\n")
	call printf("\tenergy (keV)\n")
	call printf("\tH_0 (km/s/Mpc)\n")

	call printf("\nCompute flux %sfor energy %s")
	 if ( DKPC != INDEFD )	call pargstr("and luminosity ")
	 else			call pargstr("")
	 if ( nenergies == 1 )	call pargstr("range :\n\n")
	 else			call pargstr("ranges :\n\n")

call printf("    flux    unab_fl      Lumi    lo_energy  hi_energy    D_kpc    z    H_0   q_0\n")
call printf("    ----    -------      ----    ---------  ---------    -----   ---   ---   ---\n\n")

	for ( i = 1; i <= nenergies; i = i + 1 ) {	# Compute flux data

                #JCC - exchange the declaration of LOEN & HIEN
		LOEN = energy1[i]          #JCC
		HIEN = energy2[i]          #JCC

#####################  begin  ############
#JCC - print out the 1st & the last rows of lo-energy in *_int.tab
                #call printf("Memd[ LENERGY_PTR(data)] = %f\n ")
                #call pargd(  Memd[ LENERGY_PTR(data)])
                #call printf("Memd[ LENERGY_PTR(data)+SPECTRAL_BINS-1] = %f\n")
                #call pargd(  Memd[ LENERGY_PTR(data)+SPECTRAL_BINS-1] )

#JCC - print out the 1st & the last rows of hi-energy in *_int.tab
                #call printf("Memd[ HENERGY_PTR(data)] = %f\n ")
                #call pargd(  Memd[ HENERGY_PTR(data)])
                #call printf("Memd[ HENERGY_PTR(data)+SPECTRAL_BINS-1] = %f\n")
                #call pargd(  Memd[ HENERGY_PTR(data)+SPECTRAL_BINS-1] )

#JCC(3/11/97) - Updated to check the range of two input energy. 
#               If it is out of boundaries, then give the warning message 
#               and stop the processing.
#
                if (( LOEN <= Memd[LENERGY_PTR(data)] ) ||
                    ( LOEN >= Memd[LENERGY_PTR(data)+SPECTRAL_BINS-1] ) ||
                    ( HIEN <= Memd[HENERGY_PTR(data)] ) ||
                    ( HIEN >= Memd[HENERGY_PTR(data)+SPECTRAL_BINS-1] ))
                {  call eprintf("\n\n The requested output energy should be ranged between %8.4f and %8.4f Kev\n\n   ")
                   call pargd(  Memd[ LENERGY_PTR(data)])
                   call pargd(  Memd[ HENERGY_PTR(data)+SPECTRAL_BINS-1] ) 
                   call error(1,"   requested output energy out of range !")
                }
#####################  end  ##############
 
		FLUX = areaof_model(Memd[  INCIDENT_PTR(data)],
			energy1[i], energy2[i]) *
			Kev2Erg
		UNAB = areaof_model(Memd[REDSHIFTED_PTR(data)],
			energy1[i], energy2[i]) *
			Kev2Erg

		if ( DKPC != INDEFD )
		 LUMI = areaof_model(Memd[   EMITTED_PTR(data)],
			energy1[i], energy2[i]) *
			1.0d8 * 4 * PI * ( DKPC * Kpc2cm21 )**2 * Kev2Erg
		else
		 LUMI = INDEFD

		# Write out the flux[] to the table in one gulp
		#
		call tbrptd(otb, Memi[ocp + 0], flux,            9, nrows + i)
		call tbrptt(otb, Memi[ocp + 9], abs,   3,        1, nrows + i)
		call tbrptt(otb, Memi[ocp +10], INT_BEST(HEADER_PTR(data)),
				MODWIDTH, 1, nrows + i)

call printf(" %9.3e %9.3e %9.3e     %5.2f      %5.2f   %9.3e %5.2f %5.1f %5.2f\n")
		 call pargd(FLUX)
		 call pargd(UNAB)
		 call pargd(LUMI)
		 call pargd(LOEN)    #JCC
		 call pargd(HIEN)    #JCC
		 call pargd(DKPC)
		 call pargd(DZ)
		 call pargd(HZER)
		 call pargd(QZER)

	}

	call tbtclo(otb)
end

