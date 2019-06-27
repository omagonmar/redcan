#$Header: /home/pros/xray/xspectral/source/RCS/redshift.x,v 11.0 1997/11/06 16:43:17 prosb Exp $
#$Log: redshift.x,v $
#Revision 11.0  1997/11/06 16:43:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:03  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:49  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:45  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:39  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:15  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:18:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/07  16:10:14  prosb
#jso - moved constant out of arguement call so that it would not be changed.
#
#Revision 3.1  91/09/22  19:07:15  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:07  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:43:31  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:07:22  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#   redshift.x  ---  contains red-shifting routine(s)
# revision dmw Oct 1988 - to make redshift correction logarithmic 

include  <spectral.h>


#---------------------------------------------------------------------------
#
#	apply a redshift to a spectrum
#
#---------------------------------------------------------------------------

procedure apply_redshift(redshift, orig_spectrum, shifted_spectrum, elements )

int	elements
int	i
int	new_bin
int	old_bin

real	redshift
real	redfactor
real	new_energy

double	orig_spectrum[ARB]
double	shifted_spectrum[ARB]
double	redflog

int	energy_bin()
int	within_bin_limits()

double	bin_energy()
double	spect_interp()

begin

	if ( redshift != 0.0 ) {
	    redfactor = 1.0 + redshift
	    call aclrd ( shifted_spectrum, elements )
	    for ( i=0; i<elements; i=i+1 ) {
		new_energy = redfactor * bin_energy(real(i))
		old_bin = energy_bin(new_energy)
		new_bin = within_bin_limits(old_bin, (elements-1))
		if ( new_energy < bin_energy(real(new_bin)) ) {
		    new_bin = new_bin - 1
		}
		shifted_spectrum[i+1] = spect_interp(orig_spectrum,
							new_bin, new_energy)
	    }
	    redflog = double(alog10(redfactor))
	    call aaddkd( shifted_spectrum, redflog, shifted_spectrum, elements)
	}
	else {
	    call amovd ( orig_spectrum, shifted_spectrum, elements )
	}

end

#----------------------------------------------------------------------
#
#	return the interpolated value from the given spectrum
#
#----------------------------------------------------------------------

double procedure spect_interp( spectrum, new_bin, new_energy)

int	new_bin
int	i1
int	i2

real	new_energy

double	spectrum[ARB]
double	e1
double	e2
double	result

double	bin_energy()

begin

	i1 = new_bin + 1
	i2 = new_bin + 2
	e1 = bin_energy(real(new_bin))
	e2 = bin_energy(real(new_bin+1))
	result = spectrum[i2] +
			(new_energy-e2)/(e1-e2)*(spectrum[i1]-spectrum[i2])

	return (result)

end

#---------------------------------------------------------------------------
#
#	test whether a spectral bin number is legitimate
#
#---------------------------------------------------------------------------

int procedure within_bin_limits(bin, elements )

int	bin
int	elements

begin

	if ( bin >= elements ) {
	    bin = elements - 1
	}

	return (bin)

end
