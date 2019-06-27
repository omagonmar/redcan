#$Header: /home/pros/xray/xspectral/source/RCS/hri_fold.x,v 11.0 1997/11/06 16:42:21 prosb Exp $
#$Log: hri_fold.x,v $
#Revision 11.0  1997/11/06 16:42:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:06  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/09  00:49:05  dennis
#Changed DS_OFFAXIS_ANGLE to DS_REGION_OFFAXIS_ANGLE, to match
#updated <spectral.h>.
#
#Revision 7.0  93/12/27  18:55:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:38  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:40  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/16  10:25:36  orszak
#jso - corrected folding routine which was not multipling by the bin width.
#
#Revision 3.2  92/03/11  12:34:34  prosb
#jso - changed the energy range to the spec values given by frh and lpd.
#
#Revision 3.1  91/09/22  19:06:13  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:25  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:15:27  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:03:50  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#

# Module:	hri_fold.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Fold spectrum through the hri response
# Procedure:	hri_fold()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989  You may do anything you like with this file except
#		remove this copyright.
# Modified:	{0} Mike VanHilst	initial version		    July 1989
#		{n} <who> -- <does what> -- <when>

include	<mach.h>	# define EPSILON
include	<spectral.h>

define HRI_AREA_TABLE "ein_hri_area"
define SCATTER_CIRCLE "ein_hri_radius"
define AREA_BINS 128
define HRI_MIN_ENERGY 0.1d0
define HRI_MAX_ENERGY 4.5d0

# Procedure:	hri_fold()
# Purpose:	Determine a hypothetical hri response to the given input
procedure hri_fold( parameters, photon_spectrum, nbins )

pointer parameters		# i: parameter data structure
double	photon_spectrum[ARB]	# i: spectrally distributed photons from model
int	nbins			# i: number of model photon_spectrum bins

double  energy			# l: energy of current photon_spectrum bin
double  width			# l: width of current photon_spectrum bin
double	energy_l		# l: lower energy bound of hri pha bin
double	energy_u		# l: upper energy bound of hri pha bin
double	count			# l: cummulative contributions to hri count
double	scat_coma		# l: effect of scattering and coma
double	eff_area		# l: effect of effective area
real	angle			# l: off axis angle in arc minutes
real	source_radius		# l: assumes hri size (0.3 minutes)
real	circle_radius		# l/i: radius assumed for scatter correction
pointer counts			# l/o: corresponding counts detected by hri
pointer	efar_area		# l: ptr for real array of effective areas
pointer efar_energy		# l: corresponding energies
pointer	sp			# l: stack pointer
int	bin			# l: loop counter of bins
int	area_bin		# l: most recent bin in efar tables
int	dataset			# l: current dataset
int	hri_instrument		# l: hri_instrument
int	do_scatter		# l: flag to include scatter and coma adjust

double  bin_energy()
double	hri_effective_area()
double	hri_coma_scatter()
real	clgetr()

data	hri_instrument / 3 /

begin
	call smark (sp)
	count = 0.0d0
	dataset = FP_CURDATASET(parameters)
	source_radius = DS_SOURCE_RADIUS(FP_OBSERSTACK(parameters, dataset))
	angle = DS_REGION_OFFAXIS_ANGLE(FP_OBSERSTACK(parameters, dataset))
        counts = DS_PRED_DATA(FP_OBSERSTACK(parameters, dataset))
	energy_l =
	    double(Memr[DS_LO_ENERGY(FP_OBSERSTACK(parameters, dataset))])
	energy_u =
	    double(Memr[DS_HI_ENERGY(FP_OBSERSTACK(parameters, dataset))])
	# check for erroneous off-axis angle
	if( angle > 10.0 )
	    # no counts outside of instrument area
	    return
	# adjust the energy limits to within those of the HRIAREA table
	if( energy_l < 0.0d0 )
	    energy_l = 0.0d0
	if( energy_u > HRI_MAX_ENERGY )
	    energy_u = HRI_MAX_ENERGY
	if( (energy_u - energy_l) < EPSILOND )
	{
	    energy_l = 0.0d0
	    energy_u = HRI_MAX_ENERGY
	}

	call salloc (efar_area, AREA_BINS, TY_REAL)
	call salloc (efar_energy, AREA_BINS, TY_REAL)
	call get_hri_efar (Memr[efar_energy], Memr[efar_area], hri_instrument)
	circle_radius = clgetr(SCATTER_CIRCLE)
	if( (source_radius - circle_radius) < EPSILONR )
	{
	    do_scatter = YES
	    call get_hri_coma (hri_instrument)
	} else
	    do_scatter = NO

	#------------------------------------------------------------------
	# initialize the area bin.  hri_effective_area will correct this to
	# the proper area bin for working energy.
	#------------------------------------------------------------------
	area_bin = 1

	#-------------------------------------------------------------
	# For each of the model bins we will calculate the counts from
	# the effective area over that bin.
	#-------------------------------------------------------------
	do bin = 1, nbins {

	    #----------------------------------
	    # get energy for this bin and width
	    #----------------------------------
	    energy = bin_energy( real(bin-1) )
	    width  = bin_energy( real(bin) ) - energy

	    #--------------------------------------------------------------
	    # If the energy is with the detector response find contribution
	    #--------------------------------------------------------------
	    if ( (energy >= energy_l) && (energy <= energy_u) ) {

		#---------------------------------------
		# get the effective area for this energy
		#---------------------------------------
		eff_area = hri_effective_area(energy, Memr[efar_energy],
						Memr[efar_area], area_bin)

		#---------------------------------------------------
		# Apply the coma scattering correction if nesseccary
		#---------------------------------------------------
		if ( do_scatter == YES ) {
		    scat_coma = hri_coma_scatter(energy, angle)
		    eff_area = eff_area * scat_coma
		}

		#--------------------------------------------------
		# Fold the effective area and energy width into the
		# incident counts
		#--------------------------------------------------
		count = count +
			( (10.0d0**photon_spectrum[bin]) * eff_area * width )
	    } # end if within energy
	} # end do over nbins

	#----------------------------------
	# Put the counts into the ds header
	#----------------------------------
	Memr[counts] = real(count)

	call sfree(sp)

end

# Procedure:	get_hri_efar
# Purpose:	read effective areas and their energies from disk file
procedure get_hri_efar ( energy, area, hri_instrument )

real	energy[AREA_BINS]
real	area[AREA_BINS]
int	hri_instrument

pointer	table_name		# l: string space for name of eff_area file
pointer	sp			# l: stack pointer
int	fd			# l: effective area file handle
int	i

int	open(), fscan(), nscan()

begin
	call smark (sp)
	call salloc(table_name, SZ_PATHNAME, TY_CHAR)
	call clgstr(HRI_AREA_TABLE, Memc[table_name], SZ_PATHNAME)
	# open the file (just die if there is a problem)
	fd = open(Memc[table_name], READ_ONLY, TEXT_FILE)
	do i = 1, AREA_BINS
	{
	    if( fscan(fd) != EOF )
	    {
		call gargr(energy[i])
		call gargr(area[i])
		if( nscan() < 2 )
		    call error(0, "parse failure - HRI effective area table")
	    }
	    else
		call error(0, "premature end - HRI effective area table")
	}
	call close (fd)
	call sfree(sp)
end
    
#
double procedure hri_effective_area ( energy, energies, areas, area_bin )

double	energy			# i: energy in question
real	energies[AREA_BINS]
real	areas[AREA_BINS]
int	area_bin		# i/o: upper bound bin in energies and areas

double	area		# l/o: computed effective area
real	lower_edge	# l: energy at lower bounding area_bin
real	fraction	# l: contribution of upper bound to interpolated val

begin
	# move to area_bin with energy just above given energy
	while( (area_bin < AREA_BINS) && (energy > energies[area_bin]) )
	    area_bin = area_bin + 1
	if( (area_bin > 1) && (area_bin < AREA_BINS) )
	{
	    lower_edge = energies[area_bin - 1]
	    if( (energies[area_bin] - lower_edge) < EPSILONR )
		call errori(1, "internal error: area_bin goofed up", area_bin)
	    fraction = ((energy - lower_edge) /
			(energies[area_bin] - lower_edge))
	    area = double((fraction * areas[area_bin]) +
			  ((1.0 - fraction) * areas[area_bin - 1]))
	}
	else
	    area = 0.0d0
	return( area )
end

# Procedure:	hri_energy
# Purpose:	Give the lower and upper energy bounds of the hri pha bin
procedure hri_energy ( energies, nbounds )
real	energies[ARB]	# i: energy bounds
int	nbounds		# i: assumed to be 2 (for 1 bin + 1 upper bound)
begin
	energies[1] = real(HRI_MIN_ENERGY)
	energies[2] = real(HRI_MAX_ENERGY)
end
