#$Header: /home/pros/xray/xspectral/source/RCS/cnvphotspect.x,v 11.0 1997/11/06 16:41:52 prosb Exp $
#$Log: cnvphotspect.x,v $
#Revision 11.0  1997/11/06 16:41:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:05  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:04  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:37  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:22  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:55  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:01:54  pros
#General Release 1.0
#
#   cnvphotspect.x   ---   convert an energy spectrum to a photon spectrum
# revision dmw Oct 1988 --- to make intermediate spectra logarithmic
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright




#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----


procedure cnv_phot_spect ( spectrum,  bins )

int	bins,  i
double	spectrum[ARB]

double  bin_energy()

begin
	do i = 1, bins{
# begin revision dmw Oct 1988
#	    spectrum[i] = spectrum[i] / bin_energy(real(i-1))
	    spectrum[i] = spectrum[i] - dlog10(bin_energy(real(i-1)))
            }
# end revision dmw 
end
