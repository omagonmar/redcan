#$Header: /home/pros/xray/lib/pros/RCS/dg.x,v 11.0 1997/11/06 16:20:20 prosb Exp $
#$Log: dg.x,v $
#Revision 11.0  1997/11/06 16:20:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:22  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:38  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:44:11  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:20  prosb
#General Release 2.1
#
#Revision 4.2  92/06/18  12:58:34  mo
#MC	6/18/92		Convert input arguments of movbit to regular int
#			before calling
#
#Revision 4.1  92/05/26  17:57:57  prosb
#MC	5/26/92		Fix i6r8 routine to correctly unpack unsigned
#			integers ( remove ABS(x) which improperly
#			introduces 2's complement ) and correct to
#			NOT modify the input arguments
#
#Revision 4.0  92/04/27  13:47:15  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:48:55  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:06:43  pros
#General Release 1.0
#
# Module:       dg.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      convert from Data General data format to host format
# External:     dgi2,dgi4,dgr4,dgr8,dgi6
# Local:        dgpieces,i6r8
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   initial version <when>    
#               {1}  mc  -- Fix the dgi6 routine for VAXES  -- 1/91
#               {n} <who> -- <does what> -- <when>
#
#

#
# The floating point format for Data General is as follows
# (assuming bits are numbered 1-32 and 1-64 for single and double
# precision, with bit 1 the least significant bit (rightmost):
#
#  R4 bits		R8 bits			description
#  32			64			sign
#  25-31		57-63			7 bit exponent
#  1-24			1-56			mantissa
#
# and R4 = sign * (16 ** (exponent-64) ) * mantissa
#
# and R4 = sign * (16 ** (exponent-64) ) * mantissa
#

include <mach.h>

# parameterize some info about how we convert reals and doubles
define CHUNKSIZE 16			# data type of input - bits per chunk
define SIGNBIT CHUNKSIZE		# most sig bit of chunk #1 is sign
define MAXEXPBIT (SIGNBIT-1)		# exponent comes after sign
define MINEXPBIT (MAXEXPBIT-6)		# 7-bit exponent
define MAXFRACBIT (MINEXPBIT-1)		# then starts the fraction

#
#
# DGI2 -- convert a DG integer*2
#
short procedure dgi2(ibuf)

short ibuf[1]			# i: input short value
short obuf[1]			# l: converted value

begin
	if( BYTE_SWAP2 == YES ){
		call bswap2(ibuf, 1, obuf, 1, 2)
		return(obuf[1])
	}
	else
		return(ibuf[1])
end

#
# DGI4 -- convert a DG integer*4
#
long procedure dgi4(ibuf)

long ibuf[1]			# i: input long value
long obuf[1]			# l: converted value

begin
	if( BYTE_SWAP4 == YES ){
		call bswap4(ibuf, 1, obuf, 1, 4)
		return(obuf[1])
	}
	else
		return(ibuf[1])
end

#
# DGPIECES -- get pieces of a dg real, both r4 and r8
#
procedure dgpieces(tbuf, sign, exponent, mantissa, chunks)

short	tbuf[ARB]		# i: byte-swapped input
int	sign			# o: DG sign
int	exponent		# o: DG exponent
double	mantissa		# o: DG mantissa
int	chunks			# i: number of chunks (words) in faction
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
	# get the exponent. Convert from "excess 64" notation
	exponent = -64
	itemp = 1
	for(i=MINEXPBIT; i<=MAXEXPBIT; i=i+1){
	    if( and(int(tbuf[1]), mask[i]) !=0 )
		exponent = exponent + itemp
	    itemp = itemp * 2
	}
	# calculate the fraction. Each successive bit contributes 1/2**n, n>=1
	mantissa = 0.0d0
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
# DGR4 -- convert a DG real*4
#
real procedure dgr4(ibuf)

short	ibuf[2]			# i: input value
short	tbuf[2]			# l: byte-swapped input
int	chunks			# l: number of chunks (words) in faction
real	rval			# l: converted real value
int	sign			# l: DG sign
int	exponent		# l: DG exponent
double	mantissa		# l: DG mantissa

begin
	# set size of chunks we process
	chunks = 1
	# see if we have to swap bytes
	if( BYTE_SWAP2 == YES )
		call bswap2(ibuf, 1, tbuf, 1, (chunks+1)*2)
	else
		call amovs(ibuf, tbuf, chunks+1)
	# quick check for 0
	if( tbuf[1] == 0 )
		return(0.0)
	call dgpieces(tbuf, sign, exponent, mantissa, chunks)
	# build the number
	# make sure exponent is not too high
	if( exponent >= log(MAX_REAL)/log(16.0) ){
		call printf("warning: exponent too large on DGR4\n")
		rval = MAX_REAL
	}
	# make sure exponent is not too high
	else if( exponent <= -log(MAX_REAL)/log(16.0) ){
		call printf("warning: exponent too small on DGR4\n")
		rval = 1/MAX_REAL
	}
	else{
	    # build the number
	    rval = sign * (16.0d0 ** exponent) * mantissa
	}
	return(rval)
end

#
# DGR8 -- convert a DG real*8
#
double procedure dgr8(ibuf)

short	ibuf[2]			# i: input value
short	tbuf[2]			# l: byte-swapped input
int	chunks			# l: number of chunks (words) in faction
double	dval			# l: converted double value
int	sign			# l: DG sign
int	exponent		# l: DG exponent
double	mantissa		# l: DG mantissa

begin
	# set size of chunks we process
	chunks = 3
	# see if we have to swap bytes
	if( BYTE_SWAP2 == YES )
		call bswap2(ibuf, 1, tbuf, 1, (chunks+1)*2)
	else
		call amovs(ibuf, tbuf, chunks+1)
	# quick check for 0
	if( tbuf[1] == 0 )
		return(0.0)
	call dgpieces(tbuf, sign, exponent, mantissa, chunks)
	# make sure exponent is not too high
	if( exponent >= log(MAX_DOUBLE)/log(16.0d0) ){
		call printf("warning: exponent too large on DGR8\n")
		dval = MAX_DOUBLE
	}
	else if( exponent <= -log(MAX_DOUBLE)/log(16.0d0) ){
		call printf("warning: exponent too small on DGR8\n")
		dval = 1/MAX_DOUBLE
	}
	else{
	    # build the number
	    dval = sign * (16.0d0 ** exponent) * mantissa
	}
	return(dval)
end

#
# DGI6 -- convert I*6 to a R*8 (and from DG to host representation)
#
double procedure dgi6(ibuf)

short	ibuf[3]				# i: buf containing DG I*6
short	tbuf[3]				# l: buf containing host I*6
double	i6r8()				# l: convert I*6 to R*8

begin
	# put bytes in correct order
	if( BYTE_SWAP2 == YES ){
	    call bswap2(ibuf, 1, tbuf, 1, 2)
	    call bswap2(ibuf, 3, tbuf, 3, 2)
	    call bswap2(ibuf, 5, tbuf, 5, 2)
	}
	else{
	    call amovs(ibuf, tbuf, 3)
	}
	return(i6r8(tbuf))
end

#
# I6R8 -- convert I*6 to a R*8
#
double procedure i6r8(tbuf)

short	tbuf[3]				# i: buf containing host I*6
# This must be int to use bitmov, but only the low order two bytes are used
int	cbuf				# l: temp buffer
int	ibuf
double	res				# l: resulting double

begin
	# calculate double value
	# we grab each short in turn - there must be a better way!
	# (unsigned shorts would help ...)
	res = double(tbuf[1]) * 2.0**32
	if( tbuf[2] <0 ){
	    res = res + 2.0**31
#	    tbuf[2] = abs(tbuf[2])
#           strip off high order ( sign ) bit
	    cbuf=0
	    ibuf = tbuf[2]
	    call bitmov(ibuf,1,cbuf,1,15)
	}
	else
	    cbuf = tbuf[2]
#	res = res + double(tbuf[2]) * 2.0**16
	res = res + double(cbuf) * 2.0**16
	if( tbuf[3] <0 ){
	    res = res + 2.0**15
#	    tbuf[3] = abs(tbuf[3])
#           strip off high order ( sign ) bit
	    cbuf = 0
	    ibuf = tbuf[3]
	    call bitmov(ibuf,1,cbuf,1,15)
	}
	else
	    cbuf = tbuf[3]
#	res = res + double(tbuf[3])
	res = res + double(cbuf)
	return(res)
end
