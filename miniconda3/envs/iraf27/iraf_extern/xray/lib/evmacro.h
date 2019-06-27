#$Header: /home/pros/xray/lib/RCS/evmacro.h,v 11.0 1997/11/06 16:25:02 prosb Exp $
#$Log: evmacro.h,v $
#Revision 11.0  1997/11/06 16:25:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:24  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:42:56  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/17  18:43:23  wendy
#Pre-Release check-in.
#
#Revision 7.0  93/12/27  18:21:56  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:36:39  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:49  prosb
#General Release 2.1
#
#Revision 1.2  92/07/08  10:17:18  jmoran
#JMORAN	moved some defines from eventdef.x to here
#
#Revision 1.1  92/07/07  14:35:28  jmoran
#Initial revision
#
define		SZ_TYPEDEF	1024

# define the recognized pros event record structures
# (the value of the define is the number of shorts in the record)
define  PROS_PEEWEE     "{s:x,s:y}"
define  PROS_SMALL      "{s:x,s:y,s:pha,s:pi}"
define  PROS_MEDIUM     "{s:x,s:y,s:pha,s:pi,d:time}"
define  PROS_LARGE      "{s:x,s:y,s:pha,s:pi,d:time,s:detx,s:dety}"
define  PROS_FULL       "{s:x,s:y,s:pha,s:pi,d:time,s:rawx,s:rawy,s:detx,s:dety,s:status}"
define  PROS_REGION     "{s:x,s:y,s:pha,s:pi,d:time,s:detx,s:dety,s:region}"
# Einstein SLEW survey aliases
define  PROS_SLEW       "{i:hutnum,i:status,d:time,s:ypos,s:zpos,s:pha,s:pi,s:x,s:y,r:ra,r:dec}"

# ASTRO-D aliases
define  PROS_FAINT      "{i:frame,s:x,s:y,s:pha0,s:pha1,s:pha2,s:pha3,s:pha4,s:pha5,s:pha6,s:pha7,s:pha8,s:dx,s:dy}"
define  PROS_BRIGHT     "{i:frame,s:x,s:y,s:pha,s:pi,s:grade,s:dx,s:dy}"

# define name of PROS event definition parameter
define PED      "XS-EVENT"
