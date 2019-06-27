#$Header: /home/pros/xray/xspectral/source/RCS/debug_print.x,v 11.0 1997/11/06 16:41:57 prosb Exp $
#$Log: debug_print.x,v $
#Revision 11.0  1997/11/06 16:41:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:38  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:20  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:46  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:47  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:29  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:59  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:39:07  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:02:14  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
include  <spectral.h>


#

procedure  prt_dspectrum( spectrum, nbins )

double	spectrum[ARB]
int	nbins
int	bin

begin
	do bin = 1, nbins  {
	    if( mod(bin,12) == 1 )
		call printf ( "\n" )
	    call printf ( " %8.3e" )
	    call pargd ( spectrum[bin] )  # should correspond to above
	    }
end

#

procedure  prt_rspectrum( spectrum, nbins )

real	spectrum[ARB]
int	nbins
int	bin

begin
	do bin = 1, nbins  {
	    if( mod(bin,12) == 1 )
		call printf ( "\n" )
	    call printf ( " %8.3e" )
	    call pargr ( spectrum[bin] )  # should correspond to above
	    }
end

#

procedure  print_grid ( fp, x, y, v, h, chisq )

pointer fp                              # data structure for parameters
pointer x                               # data structure for X axis
pointer y                               # data structure for Y axis
pointer	model				# data structure for model
int	v,  h				# grid indices
real	chisq				# 

begin
	call printf ( " grid point: %d %d \n" )
	    call pargi(h)
	    call pargi(v)
	model = FP_MODELSTACK( fp, GS_MODEL(x))
	call printf ( "       First parameter value = %11.4e \n" )
	    call pargr( MODEL_PAR_VAL( model, GS_PARAM(x)))
	model = FP_MODELSTACK( fp, GS_MODEL(y))
	call printf ( "      Second parameter value = %11.4e \n" )
	    call pargr( MODEL_PAR_VAL( model, GS_PARAM(y)))
	call printf ( "      Chi-square = %0.3f \n" )
	    call pargr(chisq)
end
