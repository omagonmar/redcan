#$Header: /home/pros/xray/xspectral/source/RCS/raymond.x,v 11.0 1997/11/06 16:43:15 prosb Exp $
#$Log: raymond.x,v $
#Revision 11.0  1997/11/06 16:43:15  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:59  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:40  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:36  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:30  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:08  prosb
#General Release 2.1
#
#Revision 4.3  92/10/07  11:45:32  prosb
#jso - added a parameter call to define the directory which contains
#      the raymond files.
#
#Revision 4.2  92/09/18  09:23:23  prosb
#jso - i corrected an error on the high temp warning and i added a low temp
#      warning.
#
#Revision 4.1  92/07/09  11:20:29  prosb
#jso - print an error and prevent fitting for temperatures above those
#      in the raymond table.
#
#Revision 4.0  92/04/27  18:17:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:07:09  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:04  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:41:51  prosb
#jso - made spectral.h system wide and commented out baad fix
#
#Revision 2.0  91/03/06  23:07:11  pros
#General Release 1.0
#
#  raymond.x  ---  returns a Raymond thermal spectrum for a given temperature
# Revision dmw Nov 1988 - so that all is OK for energies higher than
#   those of precomputed tables.
# Revision mvh Apr 1990 - switched table interpolation fractions
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#

include	<mach.h>

include	<spectral.h>


define	MAX_CHARS	8


# This is defined incorrectly in spectral.h, but I'm too lazy
# to remake the entire spectral package in order to change it!
# define    LEN_RT_TABLE (SPECTRAL_BINS+1)
# seems someone was so lazy - jso

procedure  raymond( kT, abundance, percent, spectrum, bins )

int	abundance		# abundance type
int	percent			# percentage for abundance
int	bins,  i		# number of bins  and  index
int	table_index
int	max_index
int	status			# read status code

long	fposition		# file position

real	kT
real	kTmax
real	kTmin
real	temperature
real	start_temp		# starting temperature for Raymond tables
real	temp_inc		# temperature increment for Raymond tables
real	fract1			# fractions
real	fract2
real	spectrum[ARB]

int	fd			# file descriptor

pointer	sp			# stack pointer
pointer	filename		# file with abundance data
pointer	header			# Raymond table header
pointer lo_table		# Raymond table for next lower temperature
pointer hi_table		# Raymond table for next higher temperature

int	open(),  read()
bool	access()

begin
	call smark (sp)
	call salloc ( filename, SZ_FNAME,      TY_CHAR)
	call salloc ( header,   LEN_RT_HEADER, TY_STRUCT)
	call salloc ( lo_table, LEN_RT_TABLE,  TY_REAL)
	call salloc ( hi_table, LEN_RT_TABLE,  TY_REAL)

	call raytab_filename ( abundance, percent, Memc[filename])

	if( access(Memc[filename],0,0) )  {
	    fd = open( Memc[filename], READ_ONLY, BINARY_FILE)
	    status = read( fd, Memi[header], LEN_RT_HEADER*SZ_INT/SZ_CHAR)
 	    start_temp  = RT_START_TEMP(header)
	    temp_inc    = RT_TEMP_INC(header)

	    if ( kT >= EPSILONR ) {
		temperature = log10( kT*ERGS_PER_KEV/BOLTZMANNS_CONSTANT )
	    }
	    else {
		kTmin = BOLTZMANNS_CONSTANT/ERGS_PER_KEV*(10**start_temp)
		call errorr(1, "Minimum temperature (keV) for this abundance is", kTmin)
	    }

	    table_index = (temperature - start_temp)/temp_inc
	    max_index   = RT_NO_TEMPS(header)

	    if ( table_index >= (max_index-1) ) {
		temperature = start_temp + (max_index -1)*temp_inc
		kTmax = BOLTZMANNS_CONSTANT/ERGS_PER_KEV*(10**temperature)
		call errorr(1, "Maximum temperature (keV) for this abundance is", kTmax)
	    }

	    if ( table_index < 0 ) {
		kTmin = BOLTZMANNS_CONSTANT/ERGS_PER_KEV*(10**start_temp)
		call errorr(1, "Minimum temperature (keV) for this abundance is", kTmin)
            }

	    fposition   = (LEN_RT_HEADER*SZ_INT/SZ_CHAR)
            fposition   = fposition +
			  table_index*LEN_RT_TABLE*SZ_REAL/SZ_CHAR + 1
	    call seek( fd, fposition)

	    status = read( fd, Memr[lo_table], LEN_RT_TABLE*SZ_REAL/SZ_CHAR)
	    status = read( fd, Memr[hi_table], LEN_RT_TABLE*SZ_REAL/SZ_CHAR)

	    fract1 = (temperature-(start_temp+table_index*temp_inc))/temp_inc
	    fract2 = 1.0 - fract1
	    do i=1,bins{
		spectrum[i] = fract2*Memr[lo_table+i] + fract1*Memr[hi_table+i]
                if(spectrum[i] <= 1.e-35){
                     spectrum[i]=1.e-35
                }
            }
	    call close (fd)
	}
	else {
            call printf( " Could not access file: %s \n" )
            call pargstr( Memc[filename] )
	}
	call sfree (sp)
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  raytab_filename ( abundance, percent, filename)

int	abundance			# abundance type
int	percent				# percentage for abundance
char	filename[ARB]			# created filename
char	atype[MAX_CHARS]		# abundance name
char	directory[SZ_PATHNAME]		# path to raymond files

begin

	#get the path from a hidden parameter
	call clgstr("raymond_directory", directory, SZ_PATHNAME)

	switch ( abundance )  {
	case COSMIC_ABUNDANCE:
			call strcpy ( "cosmic", atype, MAX_CHARS)
	case MEYER_ABUNDANCE:
			call strcpy ( "meyer", atype, MAX_CHARS)
	default:
			call strcpy ( "what", atype, MAX_CHARS)
	}
	call sprintf( filename, SZ_FNAME, "%sraytab.%s%03d" )
	    call pargstr( directory )
	    call pargstr( atype )
	    call pargi( percent )
end
