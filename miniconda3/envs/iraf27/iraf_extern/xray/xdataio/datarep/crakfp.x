#$Header: /home/pros/xray/xdataio/datarep/RCS/crakfp.x,v 11.0 1997/11/06 16:33:51 prosb Exp $
#$Log: crakfp.x,v $
#Revision 11.0  1997/11/06 16:33:51  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:26  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:07  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:41  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:59:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:09  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:35:33  pros
#General Release 1.0
#
# crakfp.x
#
# decompose a floating point number


procedure crakfp(tbuf, sign, exponent, mantissa, chunks, signbit, minexp, maxexp)
short	tbuf[ARB]
int	sign
int	exponent
double	mantissa
int	chunks
int	signbit
int	minexp
int	maxexp
#--

int	i, j
double	itemp

int	and()

int	mask[16]
data	mask/1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768/

begin
	if ( and(int(tbuf[1]), mask[signbit]) !=0 )
	    sign = -1
	else
	    sign = 1

	itemp = 1
	for ( i = minexp; i <= maxexp; i = i + 1 ) {
	    if ( and(int(tbuf[1]), mask[i]) !=0 )
		exponent = exponent + itemp
	    itemp = itemp * 2
	}

	itemp = -1
	for ( i = minexp - 1; i >= 1; i = i - 1 ) {
	    if ( and(int(tbuf[1]), mask[i]) !=0 )
		mantissa = mantissa + 2.0d0 ** itemp
	    itemp = itemp - 1
	}

	for ( j = 2; j < chunks + 2; j = j + 1 ) {
	    for ( i = 16; i >= 1; i = i - 1 ) {
		if ( and(int(tbuf[j]), mask[i]) !=0 )
			mantissa = mantissa + 2.0d0 ** itemp
	 	itemp = itemp - 1
	    }
	}
end
