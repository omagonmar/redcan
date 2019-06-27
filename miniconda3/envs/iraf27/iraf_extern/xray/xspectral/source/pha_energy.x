#$Header: /home/pros/xray/xspectral/source/RCS/pha_energy.x,v 11.0 1997/11/06 16:43:01 prosb Exp $
#$Log: pha_energy.x,v $
#Revision 11.0  1997/11/06 16:43:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:41  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:09  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:59  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:45  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:09  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:49  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:52  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:32:20  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:06:23  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
include  <spectral.h>

#
#  PHA_ENERGY   ---   return the energies at the PHA boundaries
#		the bounds are stored in the ds struct,
#		having been calculated by calc_ebounds
#
procedure  pha_energy (ds, energies, nbins)

pointer	 ds				# i: data set pointer
real     energies[ARB]			# o: energy bounds
int      nbins				# i: number of bins

begin
	# move energy bounds from input data (or 0.0)
	call amovr(Memr[DS_LO_ENERGY(ds)], energies, nbins-1)
	# final value is the last of the hi energy bounds
	energies[nbins] = Memr[DS_HI_ENERGY(ds)+(nbins-2)]
end

