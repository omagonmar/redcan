#$Header: /home/pros/xray/xspatial/imfft/RCS/fftvops.x,v 11.0 1997/11/06 16:33:12 prosb Exp $
#$Log: fftvops.x,v $
#Revision 11.0  1997/11/06 16:33:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:57  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:41  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:10  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:43:53  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:01  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:15:50  pros
#General Release 1.0
#
#
# Module:       FFTVOPS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Fourier vector operations
# External:     areal(), acabs(), aaimag(), aatan()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M.VanHilst  initial version 	28 November 1988
#               {n} <who> -- <does what> -- <when>
#

include <math.h>


#################################################################
#
# areal
#
# array transfer of the real component of complex to a real
#
# Input: array of complex values
# Input: real array to receive the real values
# Input: size of both arrays
#
#################################################################

procedure areal ( in, out, cnt )

complex	in[ARB]		# i: array containing complex values
real	out[ARB]	# i: array to recieve imaginary component
int	cnt		# i: length of array
int	i		# l: loop counter
begin
	do i = 1, cnt {
	    out[i] = real(in[i])
	}
end

#################################################################
#
# aaimag
#
# array transfer of the imaginary component of complex to a real
#
# Input: array of complex values
# Input: real array to receive the imaginary values
# Input: size of both arrays
#
#################################################################

procedure aaimag ( in, out, cnt )

complex	in[ARB]		# i: array containing complex values
real	out[ARB]	# i: array to recieve imaginary component
int	cnt		# i: length of array
int	i		# l: loop counter
begin
	do i = 1, cnt {
	    out[i] = aimag(in[i])
	}
end

#################################################################
#
# acabs
#
# array transfer the moduli of complex data to a real array
#
# Input: array of complex values
# Input: real array to receive the moduli (sqrt(r**2 + i**2))
# Input: size of both arrays
#
#################################################################

procedure acabs ( in, out, cnt )

complex	in[ARB]		# i: array containing complex values
real	out[ARB]	# i: array to recieve moduli of complex array
int	cnt		# i: length of array
int	i		# l: loop counter
begin
	do i = 1, cnt {
	    out[i] = cabs(in[i])
	}
end

#################################################################
#
# aatan
#
# array transfer of the phase of complex data to a real array
#
# Input: array of complex values
# Input: real array to receive the phase (atan(i/r)
# Input: size of both arrays
#
#################################################################

procedure aatan ( in, out, cnt )
complex	in[ARB]		# i: array containing complex values
real	out[ARB]	# i: array to recieve moduli of complex array
int	cnt		# i: length of array
int	i		# l: loop counter
begin
	do i = 1, cnt {
	    # check for and handle cases where tan is undefined
	    if( aimag(in[i]) == 0.0 ) {
		if( real(in[i]) >= 0.0 )
		    out[i] = 0.0
		else
		    out[i] = PI
	    } else if( real(in[i]) == 0.0 ) {
		if( aimag(in[i]) >= 0.0 )
		    out[i] = PI / 2.0
		else
		    out[i] = -PI / 2.0
	    } else
		out[i] = atan(double(aimag(in[i])/real(in[i])))
	}
end

