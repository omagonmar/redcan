#$Header: /home/pros/xray/xspectral/source/RCS/telescope.x,v 11.0 1997/11/06 16:43:23 prosb Exp $
#$Log: telescope.x,v $
#Revision 11.0  1997/11/06 16:43:23  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:14  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:35:11  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/09  00:49:56  dennis
#Changed DS_OFFAXIS_ANGLE to DS_REGION_OFFAXIS_ANGLE, to match
#updated <spectral.h>.
#
#Revision 7.0  93/12/27  18:58:02  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:53:01  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:32  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:18:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:07:25  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:12  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:46:33  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:07:44  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#   telescope.x   ---   routines to apply the telescope response
# revision dmw Oct 1988 --- to make intermediate spectra logarithmic

include  <spectral.h>

#  parameters used

define	AREA_TABLES	"area_data"
define	MIN_DOUBLE	1.e-35

# Procedure:	telescope_response
# Purpose:	Fold the photon spectrum through the telescope response.
procedure  telescope_response( parameters, incident, mirrored, nbins )

pointer parameters		# i: parameter data structure
double	incident[nbins]		# i: spectrally distributed photons from model
double	mirrored[nbins]		# o: photons adjusted for effective mirror area
int	nbins			# i: number of photon spectrum bins

real	angle
real	elower,  ehigher
real	effective_area
int	dataset
int	i

double	bin_energy()
real	calc_effective_area()

begin
	dataset = FP_CURDATASET(parameters)
	angle = DS_REGION_OFFAXIS_ANGLE(FP_OBSERSTACK( parameters, dataset ))
	ehigher = bin_energy(-0.5)
	do i = 1, nbins
	{
	    elower  = ehigher
	    ehigher = bin_energy( real(i-1) + 0.5 )
	    effective_area = calc_effective_area( elower, ehigher, angle )
# begin revision dmw Oct 1988
#		mirrored[i] = effective_area * incident[i]
            if( effective_area <= MIN_DOUBLE )
		mirrored[i] = incident[i] - 35.d0
	    else	 
       		mirrored[i] = double(alog10(effective_area))+ incident[i]
# end revision dmw
	}
end
# 

# Procedure:	calc_effective_area
# Purpose:	Determine the effective area given energy limits.
real procedure calc_effective_area( elower, ehigher, angle )

real	elower		# i: bin lower energy bound
real	ehigher		# i: bin upper energy bound
real	angle		# i: off axis angle

real	effective_area
real	l_energy, u_energy
real	l_area, u_area
real    old_angle
real	energy[AREA_TABLE_LENGTH]
real	area[AREA_TABLE_LENGTH]
int	base
int     entries
bool    tables_read

real	finterp()
int	read_area_tables()

# everything in SPP is save'd, so this is not necessary (and no good on vax)
# static  entries, old_angle, energy, area
data    tables_read /false/

begin
	if( (!tables_read) || (angle != old_angle) )
	{
	    entries = read_area_tables( angle, energy, area )
	    tables_read = true
	    old_angle = angle
	}
	effective_area = 0.0
	if( entries > 0 )
	{
	    base = 1
	    while( (energy[base] < elower) && (base < entries) )
		base = base + 1
	    l_energy = elower
	    l_area = finterp( area[base-1], l_energy, energy[base-1] )
	    repeat
	    {
		if( energy[base] > ehigher )
		{
		    u_energy = ehigher
		    u_area = finterp( area[base-1], u_energy, energy[base-1])
	   	} else {
		    u_energy = energy[base]
		    u_area = area[base]
		}
		effective_area = effective_area +
		  (0.5 * (l_area + u_area) * (u_energy - l_energy))
		l_energy = u_energy
		l_area = u_area
		base = base + 1
	    } until( (u_energy >= ehigher) || (base > entries) )
	}
	return effective_area / ( ehigher - elower )
end
# 

# Procedure:	read_area_tables
# Purpose:	Read in the area tables.
int  procedure  read_area_tables( angle, energy, area )

pointer	sp					# stack pointer
pointer datafile				# data file name

real   fraction,  angle,  energy[ARB],  area[ARB]
real   table[AREA_TABLE_LENGTH*(AREA_TABLE_ANGLES+1)]

int    entries,  fd,  stat,  open(),  read()
int    offset,  index,  i
bool   access()

begin
	call smark (sp)
	call salloc ( datafile, SZ_FNAME, TY_CHAR)

	call clgstr ( AREA_TABLES, Memc[datafile], SZ_FNAME)
	if( access(Memc[datafile],0,0) )
	{
	    fd = open( Memc[datafile], READ_ONLY, BINARY_FILE )
	    stat = read( fd, table,
	      AREA_TABLE_LENGTH * (AREA_TABLE_ANGLES + 1) * SZ_REAL )
	    call close( fd )
	} else  {
	    call printf( " Could not access file: %s \n" )
	    call pargstr( Memc[datafile] )
	}

	index = angle/AREA_TABLE_STEP
	fraction = angle/AREA_TABLE_STEP - index
	if( (index < 0) || (index > (AREA_TABLE_ANGLES-2)) )
	    call eprintf( "Area table pointer out of range.\n" )

	do i = 1, AREA_TABLE_LENGTH
	{
	    offset = (i-1)*(AREA_TABLE_ANGLES+1) + 1
	    energy[i] = table[offset]
	    area[i] = (1.-fraction)*table[offset+index+1] +
		      fraction *table[offset+index+2]
	}

	entries = AREA_TABLE_LENGTH
	call sfree (sp)
	return (entries)
end
# 

# Procedure:	finterp
# Purpose:	Perform a linear interpolation.
real procedure finterp( first, val, second )

real	val, first[ARB], second[ARB]
real	fraction

begin
	fraction = (val - second[1])/(second[2] - second[1])
	return( first[1] + (fraction * (first[2] - first[1])) )
end
