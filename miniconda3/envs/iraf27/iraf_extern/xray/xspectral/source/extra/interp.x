#$Header: /home/pros/xray/xspectral/source/extra/RCS/interp.x,v 11.0 1997/11/06 16:41:39 prosb Exp $
#$Log: interp.x,v $
#Revision 11.0  1997/11/06 16:41:39  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:28  prosb
#General Release 2.4
#
Revision 8.0  1994/06/27  17:35:31  prosb
General Release 2.3.1

Revision 7.0  93/12/27  18:53:46  prosb
General Release 2.3

Revision 6.0  93/05/24  16:53:17  prosb
General Release 2.2

Revision 5.0  92/10/29  22:43:01  prosb
General Release 2.1

Revision 3.0  91/08/02  01:59:28  prosb
General Release 1.1

#Revision 2.0  91/03/06  23:04:00  pros
#General Release 1.0
#

# Module:	hri_coma.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Get coma and scattering survival factors using table file
# Procedures:	hri_coma_scatter(), get_hri_coma
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989  You may do anything you like with this file except
#		remove this copyright.
# Modified:	{0} Mike VanHilst	initial version		  August 1989
#		{n} <who> -- <does what> -- <when>

define HRI_COMA_TABLE "ein_hri_coma"
	    
# Procedure:	hri_coma_scatter
# Returns:	Affect of scattering and coma for energy and off-axis-angle
double procedure h_coma_scatter( energy, angle )

double	energy		# i: energy in question
real	angle		# i: off axis angle in minutes

real	angle_frac	# l: contribution of lower bound angle
real	energy_frac	# l: contribution of lower bound energy
real	fac_u, fac_l	# l: linearly interpolated values from table rows
real	result		# l/o: bi-linearly interpolated value from table
int	angle_index	# l: index of lower bound angle
int	energy_index	# l: index of lower bound energy

int	cols		# c/i: number of angles in table
int	rows		# c/i: number of energies in table
pointer	angles		# c/i: angle of each row
pointer	energies	# c/i: energy of each column
pointer	coma_table	# c/i: table of scattering survival by angle & energy
common /coma/ rows, cols, angles, energies, coma_table

real	interp()


begin
	call interp_index (Memr[angles], rows, angle, angle_index, angle_frac)
	call interp_index (Memr[energies], cols, real(energy),
			   energy_index, energy_frac)
	row = (energy_index - 1) * cols
	fac_l = interp (Memr[coma_table + row + energy_index - 1],
			Memr[coma_table + row + energy_index],
			angle_frac);
	row = energy_index * cols
	fac_u = interp (Memr[coma_table + row + energy_index - 1],
			Memr[coma_table + row + energy_index],
			angle_frac);
	result = interp (fac_l, fac_u, energy_frac)
call printf("angl %d, engl %d, fac_l %.3f, fac_u %.2f  ")
call pargi(angle_l)
call pargi(energy_l)
call pargr(fac_l)
call pargr(fac_u)
	return( double(result) )
end


# Procedure:	get_hri_coma
# Purpose:	read table of scattering and coma survival within 18" circle
# Format:	line 1: 2 ints (no commas)	- cols (angle) rows (energy)
#		line 2: col size array		- angle of each col 
#		line 3: row size array		- energy of each row
#		line n: col size row of factor table	- 1-rows
procedure get_hri_coma ( hri_instrument )

int	hri_instrument

pointer	table_name	# l: string space for name of eff_area file
pointer	sp		# l: stack pointer
int	fd		# l: effective area file handle
int	i, j

int	cols		# c/o: number of angles in table
int	rows		# c/o: number of energies in table
pointer	angles		# c/o: angle of each row
pointer	energies	# c/o: energy of each column
pointer	coma_table	# c/o: table of scattering survival by angle & energy
common /coma/ rows, cols, angles, energies, coma_table

int	open(), fscan(), nscan()

begin
	if( hri_instrument > 3 )
	    call error(0, "only hri's 2 and 3 are known")
	call smark (sp)
	call salloc(table_name, SZ_PATHNAME, TY_CHAR)
	call clgstr(HRI_COMA_TABLE, Memc[table_name], SZ_PATHNAME)
	# open the file (just die if there is a problem)
	fd = open(Memc[table_name], READ_ONLY, TEXT_FILE)
	call sfree(sp)
	# get the table dimensions (row 1 of file)
	if( fscanf(fd) != EOF )
	{
	    call gargi(cols)
	    call gargi(rows)
	    if( (nscan() < 2) || (cols <= 0) || (rows <= 0) )
		call coma_error()
	} else
	    call coma_error()
	# allocate the table buffers
	call salloc(energies, cols, TY_REAL)
	call salloc(angles, rows, TY_REAL)
	call salloc(coma_table, rows * cols, TY_REAL)
	# get the table angles (row 2 of file)
	if( fscanf(fd) != EOF )
	{
	    do i = 1, cols
		gargr(Memr[energies + (i - 1)])
	    if( nscan() < cols )
		call coma_error()
	} else
	    call coma_end()
	# get the table energies (row 3 of file)
	if( fscanf(fd) != EOF )
	{
	    do i = 1, rows
		gargr(Memr[angles + (i - 1)])
	    if( nscan() < rows )
		call coma_error()
	} else
	    call coma_end()
	# get the table (remaining rows of file)
	do j = 1, rows
	{
	    if( fscan(fd) != EOF )
	    {
		row = (j-1) * cols
		do i = 1, cols
		    call gargr(Memr[coma_table + row + (i-1))
		if( nscan() < cols )
		    call coma_error()
	    } else
		call coma_end()
	}
	call close (fd)
end

procedure coma_error ( )
begin
	call error(0, "parse failure - HRI scatter+coma table")
end

procedure coma_end ( )
begin
	call error(0, "premature end - HRI effective area table")
end

# Procedure:	interp_index
# Purpose:	get index and fraction to interpolate between values in table
# Note:		negative fraction or fraction > 1 given for values not between
procedure interp_index ( ref, refcnt, val, lower_index, lower_frac )

real	ref[ARB]	# i: reference points for basing interpolation
int	refcnt		# i: number of reference points in array
real	val		# i: value on which to base interpolation
int	lower_index	# o: index of lower bounding reference
real	lower_frac	# o: fraction from upper bound toward lower bound

begin
	# find bracketing indices (or end which is exceeded)
if( val > 0.1 ) {
call printf("val %.2f ")
call pargr(val)
}
	lower_index = refcnt - 1
	while( (lower_index > 1) && (ref[lower_index] > val) )
	    lower_index = lower_index - 1
	# determine relative distance along line from upper to lower
	lower_frac = (ref[lower_index + 1] - val) / 
		     (ref[lower_index + 1] - ref[lower_index])
end

# Procedure:	interp
# Purpose:	given two fraction, interpolate between two values
# Note:		negative fraction or fraction > 1 work for values not between
real procedure interp ( lower_val, upper_val, lower_frac )

real	lower_val
real	upper_val
real	lower_frac


begin
	return( (lower_frac * lower_val) + ((1.0 - lower_frac) * upper_val) )
end
