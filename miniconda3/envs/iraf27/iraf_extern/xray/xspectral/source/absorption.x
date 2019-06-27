#$Header: /home/pros/xray/xspectral/source/RCS/absorption.x,v 11.0 1997/11/06 16:42:17 prosb Exp $
#$Log: absorption.x,v $
#Revision 11.0  1997/11/06 16:42:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:28:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:29:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:48:29  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:15  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:12:48  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  18:25:06  wendy
#added copyright
#
#Revision 3.0  91/08/02  01:57:45  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:27:50  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:01:18  pros
#General Release 1.0
#
#  absorption.x  ---  contains routines for performing spectral absorptions
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# revision dmw Oct 1988 -- to make corrections logarithmic
include  <spectral.h>


#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  apply an absorber to a spectrum

procedure  apply_absorption( abs_code, col_density, orig_spectrum, abs_spectrum, bins )

int	bins,  i,  lasti
int	abs_code
real	col_density
double	orig_spectrum[ARB],  abs_spectrum[ARB]
double	absorption,  fetch_absorption()
double	energy,  bin_energy()

begin
	lasti = 1
	call amovd ( orig_spectrum, abs_spectrum, bins )
	do i = 1, bins  {
	    energy = bin_energy(real(i-1))
	    if( energy < 100.0 )  {
		absorption = fetch_absorption( abs_code, col_density, energy, lasti)
# begin revision dmw Oct 1988
#    note that "abosrption" returned by 'fetch_absorption' is already logarithmic
#		abs_spectrum[i] = absorption*orig_spectrum[i]
		abs_spectrum[i] = absorption + orig_spectrum[i]
		}
	    }
end



#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  read in entire absorption data table into memory

procedure  absorption_tables( abs_code, table )

pointer	sp				# stack pointer
pointer datafile			# name of absorption data file
int	abs_code
int	fd,  stat,  open(),  read()
real	table[ARB]

begin
	call smark (sp)
	call salloc ( datafile, SZ_FNAME, TY_CHAR)

	if( abs_code == BROWN_GOULD )
	    call clgstr ( "b_and_g_absorption_file", Memc[datafile], SZ_FNAME)
	else
	    call clgstr ( "m_and_m_absorption_file", Memc[datafile], SZ_FNAME)
	fd = open( Memc[datafile], READ_ONLY, BINARY_FILE )
	stat = read( fd, table, SZ_REAL*ABSORP_TABLE_LENGTH*LEN_AB )

	call close( fd )
	call sfree (sp)
end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  compute absorption for a given column density and energy

double  procedure  fetch_absorption( abs_code, col_density, energy, lasti )

int	abs_code
real    col_density
double	absorption,  energy,  factor
int     i,  lasti

real    absorption_table[LEN_AB,ABSORP_TABLE_LENGTH]
# everything in SPP is saved, so the following is not necessary
# static  absorption_table

int     tables_read
data    tables_read/-1/

begin
	if( tables_read != abs_code )  {
		call absorption_tables( abs_code, absorption_table )
		tables_read = abs_code
	}
	i = lasti
	while( (energy >= absorption_table[AB_UPPER_ENERGY,i]) && (i < (ABSORP_TABLE_LENGTH)) )
		i = i+1
	lasti = i
	if( abs_code == MORRISON_MCCAMMON )  {
	    absorption = (( absorption_table[AB_COEF0,i] /energy +
	    	 	    absorption_table[AB_COEF1,i])/energy +
			    absorption_table[AB_COEF2,i])/energy
# begin revision dmw Oct 1988
#	    factor = 1.e-24
	    factor = 1.d-24
# end revision dmw
	    }
	else
	if( abs_code == BROWN_GOULD )  {
	    absorption = absorption_table[AB_COEF0,i] *
			 (absorption_table[AB_COEF1,i]/energy) ** absorption_table[AB_COEF2,i]
# begin revision dmw Oct 1988
#	    factor = 1.e-21
	    factor = 1.d-21
# end revision dmw
	    }
	else  {
	    absorption = 0.0
	    factor = 0.0
	    }
# begin revision dmw Oct 1988
#   return log10 of absorption
#	absorption = dexp( -absorption * col_density * factor )
	absorption =  -(absorption * double(col_density) * factor)/dlog(10.0d0)
# end revision dmw
	return (absorption)
end
