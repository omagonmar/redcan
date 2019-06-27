#$Header: /home/pros/xray/xspectral/source/RCS/models.x,v 11.0 1997/11/06 16:42:04 prosb Exp $
#$Log: models.x,v $
#Revision 11.0  1997/11/06 16:42:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:15  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:23  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:08  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:04  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:10  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/08  16:55:59  prosb
#jso - was off by one channel in the single line model; it now looks correct.
#
#Revision 3.3  92/03/25  16:34:56  orszak
#jso - we have a new single line model calculation.  it is based on a 
#      gaussian intragration routine from fabrizio fiore, and was checked
#      by larry david
#
#Revision 3.2  91/09/22  19:06:33  wendy
#Added
#
#Revision 3.1  91/08/23  14:25:56  prosb
#jso - set up so that the MAX_EXP would depend on iraf defines.
#
#Revision 3.0  91/08/02  01:58:34  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  18:26:32  prosb
#jso - miust have missed this one.
#      made spectral.h system wide
#
#Revision 2.0  91/03/06  23:05:15  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#   models.x  ---  computes and sums all the spectral models

include <spectral.h>
include <math.h>
include <mach.h>

define	HELIUM_TO_HYDROGEN	"helium_to_hydrogen"

# D.M.W. - revision (9/15/88)
# Changed procedure sum_comp( nmodel, model, sum, bins )
# to procedure sum_comp( nmodel, model, sum, bins ,alpha1)
# Changed call of comp_norm( nmodel, model )
# to call of comp_norm( nmodel, model ,alpha1)
#  See notes in normalization.x
# revision dmw Oct 1988
#   construct models to be log of flux densities
#   make all model calculations more properly double precision

#
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    sum all the component emission spectra

procedure sum_comp( nmodel, model, sum, bins ,alpha1)

int	nmodel,  bins,   model_type,   abundance,   percent
double	sum[ARB]
real	normalization
real    alpha1
real	energy_temp
real	width

pointer model

real	comp_norm()

begin
    energy_temp   = MODEL_PAR_VAL(model,MODEL_TEMP)
    model_type    = MODEL_TYPE(model)

    normalization = comp_norm( nmodel, model, alpha1)
    MODEL_PAR_VAL(model,MODEL_NORM) = normalization

    switch ( model_type )  {

    case POWER_LAW:
	    call power_law_emission( sum, bins, energy_temp, normalization)

    case BLACK_BODY:
	    call black_body_emission( sum, bins, energy_temp, normalization)

    case EXP_PLUS_GAUNT:
	    call exp_gaunt_emission( sum, bins, energy_temp, normalization)

    case EXPONENTIAL:
	    call exponential_emission( sum, bins, energy_temp, normalization)

    case RAYMOND:
	    abundance = MODEL_ABUNDANCE(model)
	    percent   = MODEL_PERCENTAGE(model)
	    call raymond_emission( sum, bins, energy_temp, abundance, percent,
				   normalization)

    case SINGLE_LINE:
	    width = MODEL_PAR_VAL(model,MODEL_WIDTH)
	    call single_line_emission(sum, bins, normalization, energy_temp,
					 width)
	}
end
# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    compute a power law spectrum

procedure power_law_emission( sum, bins, energy_index, norm )

int	bins
int	i
double	sum[ARB]
real	energy_index
real	norm
double	bin_energy()

begin
	do i= 1, bins {
# begin revision dmw Oct 1988
#	    sum[i] = norm * bin_energy(real(i-1))**(-energy_index)
	    sum[i] = double(alog10(norm))
	    sum[i] = sum[i] - double(energy_index) * dlog10(bin_energy(real(i-1)))
            }
# end revision dmw 
end





#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    compute a black body spectrum

procedure black_body_emission( sum, bins, temperature, norm )

int	bins
int	i
double	sum[ARB]
real	temperature
real	norm
double	energy
double   u                                  # energy/temperature
double	bin_energy()

begin
	do i= 1, bins  {
	 energy = bin_energy(real(i-1))
# begin revision dmw Oct 1988
#	 sum[i] = norm * (energy**3.0) /(dexp(energy/temperature)-1.0)
	 u=energy/temperature
         if (u <= 10.0){
   	   sum[i] = double(alog10(norm))+3.0d0*dlog10(energy)
   	   sum[i] = sum[i]-dlog10(dexp(energy/temperature)-1.0d0)
          }
         else
   	   sum[i] = double(alog10(norm))+3.0d0*dlog10(energy)- u/dlog(10.0d0)
# end revision dmw
	    }
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    compute an exponential with Gaunt factor spectrum

procedure exp_gaunt_emission( sum, bins, temperature, norm )

int	bins
int	i
double	sum[ARB]
real	temperature
real	norm
real	gaunt
real	HEB
real    ensngl            # single precision version of energy
double	energy

real	clgetr()
double	bin_energy()

begin
    HEB = clgetr( HELIUM_TO_HYDROGEN )
    do i= 1, bins  {
	energy = bin_energy(real(i-1))
        ensngl=energy
	call cgaunt( gaunt, ensngl, temperature, HEB )
# begin revision dmw Oct 1988
#	sum[i] = norm * gaunt * dexp(-energy/temperature)
	sum[i] = double(alog10(norm) + alog10( gaunt)) - (energy/temperature)/dlog(10.d0)
# end revision dmw

	}
end





#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    compute an exponential spectrum

procedure exponential_emission( sum, bins, temperature, norm )

int	bins
int	i
double	sum[ARB]
real	temperature
real	norm
double	energy
double	bin_energy()

begin
	do i= 1, bins  {
		energy = bin_energy(real(i-1))
# begin revision dmw Oct 1988
#		sum[i] = norm * dexp(-energy/temperature)
 	        sum[i] = double(alog10(norm)) - (energy/temperature)/dlog(10.d0)
# end revision dmw
		}
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    compute a Raymond thermal spectrum

procedure raymond_emission( sum, bins, temperature, abundance, percent, norm )

int	bins
int	i
int	abundance
int	percent
double	sum[ARB]
real	temperature
real	norm
real	raymond_spectrum[SPECTRAL_BINS]
real    lower_energy
real	upper_energy
double	factor
double	bin_energy()

begin
	call raymond( temperature, abundance, percent, raymond_spectrum, bins)
	factor = norm 
	upper_energy = bin_energy( -0.5 )
	do i= 1, bins  {
		lower_energy = upper_energy
		upper_energy = bin_energy( real(i-1)+0.5 )
# begin revision dmw Oct 1988
#		sum[i] = factor * raymond_spectrum[i] / (upper_energy-lower_energy)
		sum[i] = double(alog10(raymond_spectrum[i]) -
			 alog10(upper_energy-lower_energy))
		sum[i] = sum[i] + dlog10(factor)
# end revision dmw
	}
end

#----------------------------------------------------------------
#
#	Compute a monochromatic line spectrum
#
#----------------------------------------------------------------

procedure single_line_emission( sum, bins, normalization, energy, width)

double	sum[ARB]			# total flux

int	bins				# number of instrument bins

real	normalization
real	energy				# center of gaussian
real	width				# full width half max?

double	sigma
double	dnorm
double	delta1				# energy segment of line in bin
double	delta2				# energy segment of line in bin

int	ii
int	jj

double	bin_energy()			# energy of this bin
double	gauint()			# calculate integral of gaussian
extern	logerror()
#double	logerror()  # Examples exist with both extern X() & double X() decls.

begin

	sigma = 0.0
	sigma = width / ( 2.0 * sqrt(2.0 * LN_2))

	dnorm = normalization / ( sigma * sqrt(TWOPI))

	do ii = 1, bins {

	    jj = ii - 1

	    #-----------------------------------------------------------
	    # We have the enrgy centers, but need the energy boundaries
	    # so we calculate the geometric mean.  Geometric because the
	    # energy are incremented in a log scale.
	    #-----------------------------------------------------------
	    delta1 = ( sqrt( bin_energy(real(jj-1)) * bin_energy(real(jj)) ) -
			energy ) / sigma
	    delta2 = ( sqrt( bin_energy(real(jj)) * bin_energy(real(jj+1)) ) -
			energy ) / sigma

	    #--------------------------------------------------------
	    # now calculate the sum, not yet in log, using Fabrizio's
	    # routine.  Larry checked the routine.
	    #--------------------------------------------------------
	    sum[ii] = dnorm * ( gauint(delta2) - gauint(delta1) )
	}

	call alogd(sum, sum, bins, logerror)

end

#-----------------------------------------------------------------
#
#	Compute the integral of the gaussian
#	courtesy of Fabrizio Fiore
#
#-----------------------------------------------------------------

double procedure gauint(xx)

double	xx

double	a1, a2, a3, a4, a5, a6
double	x
double	temp

data	a1, a2, a3, a4, a5, a6 /7.05230784d-2, 9.2705272d-3,
		2.765672d-4, 4.22820123d-2, 1.520143d-4, 4.30638d-5/

begin

	gauint = -0.5d0

	if ( xx >= -10.0d0 ) {
	    gauint = 0.5d0
	}
	if ( xx <= 10.0d0 ) {
	    x = abs(xx)
	    temp = 1.0d0 + a1*x + a2*x*x + a3*x*x*x + a4*x*x*x*x + 
		a5*x*x*x*x*x + a6*x*x*x*x*x*x
	    temp = temp**16
	    gauint = (1.0d0 - 1.0d0/temp)*0.5d0
	    if ( xx < 0.0d0 ) {
		gauint = -gauint
	    }
	}

	return (gauint)

end

# UR: Moved this to a separate file to stop the fortran compiler complaining
# that there are conflicting definitions (one being "extern"). I *think* this
# is a valid way to work around the compilation error, though I wouldn't like
# to bet my house on it. At least it gets the executable compiled with a load
# of other stuff in it - JT.
#
# define MAX_EXPD double(MAX_EXPONENTD)
# define BAD_EXPD (-MAX_EXPD-1.0D0)
#
# double procedure logerror(value)
# double value
# #--

# begin
# 	return BAD_EXPD
# end
