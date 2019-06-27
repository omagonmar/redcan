#$Header: /home/pros/xray/lib/RCS/slset.h,v 11.0 1997/11/06 16:25:39 prosb Exp $
#$Log: slset.h,v $
#Revision 11.0  1997/11/06 16:25:39  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:45  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:33  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:22:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:37:25  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:23:24  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:07:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  91/08/02  11:13:15  mo
#ADD comment character for RCS
#
#Revision 3.2  91/08/02  09:28:28  mo
#*** empty log message ***
#
# * Revision 3.1  91/08/02  09:27:47  mo
# * ADd comment character
# * 
# * Revision 3.0  91/08/02  00:46:54  prosb
# * General Release 1.1
# * 
#Revision 2.0  91/03/07  00:18:44  pros
#General Release 1.0
#
#
# Module:	slset.h
# Project:	PROS -- ROSAT RSDC
# Purpose:	Define a handle for scan list array images
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

# scan list header record
define SL_LEN	3		# length of record to allocate (ints)
define SL_WDTH	Memi[$1]	# width of scan list image
define SL_HGHT	Memi[$1+1]	# height of scan list image
define SL_SCAN	Memi[$1+2]	# Memi pointer of scan list array
define SL_DATA	Memi[$1+3]	# This is the start of the scan list array
