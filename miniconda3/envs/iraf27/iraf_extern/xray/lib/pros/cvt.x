#$Header: /home/pros/xray/lib/pros/RCS/cvt.x,v 11.0 1997/11/06 16:20:18 prosb Exp $
#$Log: cvt.x,v $
#Revision 11.0  1997/11/06 16:20:18  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:19  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:33  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:56  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:44:03  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:15:00  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:47:11  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:48:54  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:06:41  pros
#General Release 1.0
#
#
#  CVT.X -- routines to convert from our "specially known machines" data types
#  the current favorites are:
#	VAX, DG
#

include <qpoe.h>

#
#
# CVTI2 -- convert an integer*2
#
short procedure cvti2(ibuf, type)

short	ibuf[1]			# i: input short value
int	type			# i: conversion type

short	val			# l: return value
short	vaxi2(), dgi2()		# l: conversion routines

begin
	switch(type){
	case NO_CONVERT:
	    call amovs(ibuf, val, 1)
	case CONVERT_DG:
	    val = dgi2(ibuf)
	case CONVERT_VAX:
	    val = vaxi2(ibuf)
	default:
	    call errori("unknown conversion", type)
	}
	return(val)
end

#
#
# CVTI4 -- convert an integer*4
#
int procedure cvti4(ibuf, type)

short	ibuf[1]			# i: input int value
int	type			# i: conversion type
int	val			# l: return value
int	vaxi4(), dgi4()		# l: conversion routines

begin
	switch(type){
	case NO_CONVERT:
	    call amovi(ibuf, val, 1)
	case CONVERT_DG:
	    val = dgi4(ibuf)
	case CONVERT_VAX:
	    val = vaxi4(ibuf)
	default:
	    call errori("unknown conversion", type)
	}
	return(val)
end

#
#
# CVTR4 -- convert a real*4
#
real procedure cvtr4(ibuf, type)

short	ibuf[1]			# i: input real value
int	type			# i: conversion type
real	val			# l: return value
real	vaxr4(), dgr4()		# l: conversion routines

begin
	switch(type){
	case NO_CONVERT:
	    call amovr(ibuf, val, 1)
	case CONVERT_DG:
	    val = dgr4(ibuf)
	case CONVERT_VAX:
	    val = vaxr4(ibuf)
	default:
	    call errori("unknown conversion", type)
	}
	return(val)
end

#
#
# CVTR8 -- convert a real*8
#
double procedure cvtr8(ibuf, type)

short	ibuf[1]			# i: input double value
int	type			# i: conversion type
double	val			# l: return value
double	vaxr8(), dgr8()		# l: conversion routines

begin
	switch(type){
	case NO_CONVERT:
	    call amovd(ibuf, val, 1)
	case CONVERT_DG:
	    val = dgr8(ibuf)
	case CONVERT_VAX:
	    val = vaxr8(ibuf)
	default:
	    call errori("unknown conversion", type)
	}
	return(val)
end

#
# CVTI6 -- convert I*6 to a R*8
#
double procedure cvti6(ibuf, type)

short	ibuf[1]			# i: input double value
int	type			# i: conversion type
double	val			# l: return value
double	i6r8(), vaxi6(), dgi6()	# l: conversion routines

begin
	switch(type){
	case NO_CONVERT:
	    val = i6r8(ibuf)
	case CONVERT_DG:
	    val = dgi6(ibuf)
	case CONVERT_VAX:
	    val = vaxi6(ibuf)
	default:
	    call errori("unknown conversion", type)
	}
	return(val)
end



