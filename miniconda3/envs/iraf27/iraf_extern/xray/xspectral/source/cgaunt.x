#$Header: /home/pros/xray/xspectral/source/RCS/cgaunt.x,v 11.0 1997/11/06 16:41:51 prosb Exp $
#$Log: cgaunt.x,v $
#Revision 11.0  1997/11/06 16:41:51  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:48:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:33  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:18  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:54  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:01:45  pros
#General Release 1.0
#
#
#	cgaunt.x   ---   Routine to compute the gaunt factor
#
# revision dmw Oct 1988 --- to normalize the calculation of g
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright

procedure  cgaunt ( g, EkeV, TkeV, HEB )

real	g		# gaunt factor returned
real	EkeV		# photon energy in keV
real	TkeV		# Bremsstrahlung temperature in keV
real	HEB		# Helium to Hydrogen abundance

real	g1
real	g2

real	gaunt()

begin

# JBR : Jan 90
#	g = gaunt(EkeV,TkeV,1.0) + 4.0*HEB*gaunt(EkeV,TkeV,2.0)

	g1 = gaunt(EkeV,TkeV,1.0) 
	g2 = gaunt(EkeV,TkeV,2.0)

	g =  (	g1 / ( 1.0 + 2.0 * HEB )) +
	     ( 4.0 * HEB / ( 1.0 + 2.0 * HEB )) * g2


end




