#$Header: /home/pros/xray/lib/pros/RCS/vax.x,v 11.0 1997/11/06 16:21:17 prosb Exp $
#$Log: vax.x,v $
#Revision 11.0  1997/11/06 16:21:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:35  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:42  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:09  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:54:41  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:48  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:50:33  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:02:23  wendy
#General
#
#Revision 2.0  91/03/07  00:07:44  pros
#General Release 1.0
#
#
# VAX.X  -- convert from Digital Vax data format to host format
#
# Coppied from Dg.x 
# Changes for Vax are
#  1. Bit definitions for float sub-fields
#  2. Excess 129 instead of 64
#  3. Hidden normalization bit in mantissia (initialize to 1.0d0 not 0.0d0)
#
#  John : Feb 90
#
# The floating point format for Digital Vax is as follows
# (assuming bits are numbered 1-32 and 1-64 for single and double
# precision, with bit 1 the least significant bit (rightmost):
#
#  R4 bits		R8 bits			description
#  32			64			sign
#  24-31		56-63			8 bit exponent
#  1-23			1-55			mantissa
#
# and R4 = sign * (2 ** (exponent-127) ) * mantissa
#
# and R8 = sign * (2 ** (exponent-127) ) * mantissa
#

include <mach.h>

# parameterize some info about how we convert reals and doubles

define CHUNKSIZE 16			# data type of input - bits per chunk
define SIGNBIT CHUNKSIZE		# most sig bit of chunk #1 is sign

define MAXEXPBIT (SIGNBIT-1)		# exponent comes after sign
define MINEXPBIT (MAXEXPBIT-7)		# 8-bit exponent
define MAXFRACBIT (MINEXPBIT-1)		# then starts the fraction

#
#
# VAXI2 -- convert a VAX integer*2
#
short procedure vaxi2(ibuf)

short ibuf[1]			# i: input short value
short obuf[1]			# l: converted value

begin
	if( BYTE_SWAP2 != YES ){
		call bswap2(ibuf, 1, obuf, 1, 2)
		return(obuf[1])
	}
	else
		return(ibuf[1])
end

#
# VAXI4 -- convert a VAX integer*4
#
long procedure vaxi4(ibuf)

long ibuf[1]			# i: input long value
long obuf[1]			# l: converted value

begin
	if( BYTE_SWAP4 != YES ){
		call bswap4(ibuf, 1, obuf, 1, 4)
		return(obuf[1])
	}
	else
		return(ibuf[1])
end

#
# VAXPIECES -- get pieces of a dg real, both r4 and r8
#
procedure vaxpieces(tbuf, sign, exponent, mantissa, chunks)

short	tbuf[ARB]		# i: byte-swapped input
int	sign			# o: VAX sign
int	exponent		# o: VAX exponent
double	mantissa		# o: VAX mantissa
int	chunks			# i: number of chunks (words) in faction
#--

int	i, j			# l: loop counters
int	itemp			# l: temp
int	mask[16]		# l: masks for bit tests
data	mask/1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768/

begin
	# get the sign
	if( and(int(tbuf[1]), mask[SIGNBIT]) !=0 )
	    sign = -1
	else
	    sign = 1
	# get the exponent. Convert from "excess 128" notation
	exponent = -129
	itemp = 1
	for(i=MINEXPBIT; i<=MAXEXPBIT; i=i+1){
	    if( and(int(tbuf[1]), mask[i]) !=0 )
		exponent = exponent + itemp
	    itemp = itemp * 2
	}
	# calculate the fraction. Each successive bit contributes 1/2**n, n>=1
	mantissa = 1.0d0
	itemp = -1
	# first process the remaining bits in word 1
	for(i=MAXFRACBIT; i>=1; i=i-1){
	    if( and(int(tbuf[1]), mask[i]) !=0 )
		mantissa = mantissa + 2.0d0 ** itemp
	    itemp = itemp - 1
	}
	# then process the remaining words
	for(j=2; j<chunks+2; j=j+1){
	    for(i=CHUNKSIZE; i>=1; i=i-1){
		if( and(int(tbuf[j]), mask[i]) !=0 )
			mantissa = mantissa + 2.0d0 ** itemp
	 	itemp = itemp - 1
	    }
	}
end

#
# VAXR4 -- convert a VAX real*4
#
real procedure vaxr4(ibuf)

short	ibuf[2]			# i: input value
short	tbuf[2]			# l: byte-swapped input
int	chunks			# l: number of chunks (words) in faction
real	rval			# l: converted real value
int	sign			# l: VAX sign
int	exponent		# l: VAX exponent
double	mantissa		# l: VAX mantissa

begin
	# set size of chunks we process
	chunks = 1
	# see if we have to swap bytes
	if( BYTE_SWAP2 != YES )
		call bswap2(ibuf, 1, tbuf, 1, (chunks+1)*2)
	else
		call amovs(ibuf, tbuf, chunks+1)
	# quick check for 0
	if( tbuf[1] == 0 )
		return(0.0)
	call vaxpieces(tbuf, sign, exponent, mantissa, chunks)
	# build the number
	# make sure exponent is not too high
	if( exponent >= log(MAX_REAL)/log(2.0) ){
		call printf("warning: exponent too large on VAXR4\n")
		rval = MAX_REAL
	}
	else if( exponent <= -log(MAX_REAL)/log(2.0) ){
		call printf("warning: exponent too small on VAXR4\n")
		rval = MAX_REAL
	}
	else{
	    # build the number
	    rval = sign * (2.0d0 ** exponent) * mantissa
	}
	return(rval)
end

#
# VAXR8 -- convert a VAX real*8
#
double procedure vaxr8(ibuf)

short	ibuf[4]			# i: input value
short	tbuf[4]			# l: byte-swapped input
int	chunks			# l: number of chunks (words) in faction
double	dval			# l: converted double value
int	sign			# l: DG sign
int	exponent		# l: DG exponent
double	mantissa		# l: DG mantissa

begin
	# set size of chunks we process
	chunks = 3
	# see if we have to swap bytes
	if( BYTE_SWAP2 != YES )
		call bswap2(ibuf, 1, tbuf, 1, (chunks+1)*2)
	else
		call amovs(ibuf, tbuf, chunks+1)
	# quick check for 0
	if( tbuf[1] == 0 )
		return(0.0)
	call vaxpieces(tbuf, sign, exponent, mantissa, chunks)
	# make sure exponent is not too high
	if( exponent >= log(MAX_DOUBLE)/log(2.0d0) ){
		call printf("warning: exponent too large on VAXR8\n")
		dval = MAX_DOUBLE
	}
	if( exponent <= -log(MAX_DOUBLE)/log(2.0d0) ){
		call printf("warning: exponent too small on VAXR8\n")
		dval = 1/MAX_DOUBLE
	}
	else{
	    # build the number
	    dval = sign * (2.0d0 ** exponent) * mantissa
	}
	return(dval)
end

#
# VAXI6 -- convert I*6 to a R*8 (and from VAX to host representation)
#
double procedure vaxi6(ibuf)

short	ibuf[3]				# i: buf containing VAX I*6
short	tbuf[3]				# l: buf containing host I*6
double	i6r8()				# l: convert I*6 to R*8

begin
	# put bytes in correct order
	if( BYTE_SWAP4 == NO ){
	    call bswap2(ibuf, 1, tbuf, 5, 2)
	    call bswap2(ibuf, 3, tbuf, 3, 2)
	    call bswap2(ibuf, 5, tbuf, 1, 2)
	}
	else{
	    call amovs(ibuf, tbuf, 3)
	}
	return(i6r8(tbuf))
end



