#$Header: /home/pros/xray/xspectral/source/RCS/bin_energy.x,v 11.0 1997/11/06 16:41:50 prosb Exp $
#$Log: bin_energy.x,v $
#Revision 11.0  1997/11/06 16:41:50  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:00  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:19  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:41:41  mo
#MC	7/2/93		Enclose all defined constants in parens (RS6000 port)
#
#Revision 6.0  93/05/24  16:48:54  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:30  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:18  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:16  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:53  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:01:42  pros
#General Release 1.0
#
#   bin_energy.x  ---  returns correspondence bin number and energy
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright

define  ENERGY_BASE   -1.5               #  keV
define  ENERGY_STEP   0.02               #  keV

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    This procedure returns the bin number for the supplied energy (in keV).

int  procedure  energy_bin( energy )

real	energy

real	en_bin
int	bin_num

begin

	en_bin = ( (log10(energy) - (ENERGY_BASE) )/ENERGY_STEP ) + 0.5
	bin_num = int(en_bin)

	return (bin_num)

end



#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    This procedure returns the energy for the supplied bin number.

double  procedure  bin_energy( bin )

real	bin

double	energy

begin

	energy = 10.0**((ENERGY_BASE) + double(bin)*ENERGY_STEP)

	return (energy)

end


#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    This procedure returns the bin number for the supplied energy (in keV).

int  procedure  energy_low( energy )

real	energy

real	en_bin
int	bin_num

begin

	en_bin = (log10(energy) - (ENERGY_BASE))/ENERGY_STEP
	bin_num = int(en_bin)

	return (bin_num)

end
