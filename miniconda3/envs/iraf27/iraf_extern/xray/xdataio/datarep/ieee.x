#$Header: /home/pros/xray/xdataio/datarep/RCS/ieee.x,v 11.0 1997/11/06 16:34:00 prosb Exp $
#$Log: ieee.x,v $
#Revision 11.0  1997/11/06 16:34:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:46  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:38:00  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:41  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:08  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:38  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:19  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:36:12  pros
#General Release 1.0
#
# ieee.x
#
# ieee specific conversions
#


include	<mach.h>


short procedure ieeei2(in)

short	in
#--

short	obuf

begin
	if( BYTE_SWAP2 == YES )	call bswap2(in, 1, obuf, 1, 2)
        else			obuf = in

        return obuf
end


short procedure ieeei4(in)

short	in
#--

short	obuf

begin
	if( BYTE_SWAP4 == YES )	call bswap4(in, 1, obuf, 1, 4)
        else			obuf = in

        return obuf
end


real procedure ieeer4(in)

real	in
#--

real	ibuf
double	value

int	sign
int	exponent
double	mantissa

begin
#	if ( IEEE_USED  == YES ) return	in
	if ( IEEE_SWAP4 == YES ) call bswap2(in, 1, ibuf, 1, 4)
	else			 call bytmov(in, 1, ibuf, 1, 4)

	exponent = -127;
	mantissa = 0.0d0
	call crakfp(ibuf, sign, exponent, mantissa, 1, 16, 8, 15)

	# switch
	       if ( mantissa == 0 && exponent == 0 ) value = 0
	  else if ( exponent < -(log(MAX_REAL)/log(2.0)) ) {
		call printf("warning: exponent too small for host\n")
		value = 0
	} else if ( exponent == -1023 ) {			# subnormal
		exponent = -1022;		    
		value = sign * (2.0d0 ** exponent) * mantissa
	} else if ( exponent > log(MAX_REAL)/log(2.0) ) {
		call printf("warning: exponent too large for host\n")
		value = MAX_DOUBLE
	} else						# Normalized
		value = sign * (2.0d0 ** exponent) * ( mantissa + 1 )

	return value
end


double procedure ieeer8(in)

double	in
#--

double	ibuf
double	value

int	sign
int	exponent
double	mantissa

begin
#	if ( IEEE_USED  == YES ) return in
	if ( IEEE_SWAP8 == YES ) call bswap2(in, 1, ibuf, 1, 8)
	else			 call bytmov(in, 1, ibuf, 1, 8)

	exponent = -1023
	mantissa = 0.0d0
	call crakfp(ibuf, sign, exponent, mantissa, 3, 16, 4, 15)

	# switch
	       if ( mantissa == 0 && exponent == 0 ) value = 0
	  else if ( exponent < -(log(MAX_DOUBLE)/log(2.0)) ) {
		call printf("warning: exponent too small for host\n")
		value = 0
	} else if ( exponent == -1023 ) {			# subnormal
		exponent = -1022;		    
		value = sign * (2.0d0 ** exponent) * mantissa
	} else if ( exponent > log(MAX_DOUBLE)/log(2.0) ) {
		call printf("warning: exponent too large for host\n")
		value = MAX_DOUBLE
	} else						# Normalized
		value = sign * (2.0d0 ** exponent) * ( mantissa + 1 )

	return value
end
