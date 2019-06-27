#$Header: /home/pros/xray/lib/RCS/scset.h,v 11.0 1997/11/06 16:25:39 prosb Exp $
#$Log: scset.h,v $
#Revision 11.0  1997/11/06 16:25:39  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:44  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:30  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:22:29  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:37:22  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:23:21  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:07:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  91/08/02  11:12:24  mo
#ADD comment character
#
#Revision 3.2  91/08/02  09:28:36  mo
#*** empty log message ***
#
# * Revision 3.1  91/08/02  09:27:57  mo
# * ADd comment character
# * 
# * Revision 3.0  91/08/02  00:46:54  prosb
# * General Release 1.1
# * 
#Revision 2.0  91/03/07  00:18:32  pros
#General Release 1.0
#
#
# Module:	scset.h
# Project:	PROS -- ROSAT RSDC
# Purpose:	Define a scan edge record for scan line link lists
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

# scan record: a link in a linked scan list (one for each line)
define SC_LEN	4		# length of record to allocate (ints)
define SC_NEXT	Memi[$1]	# pointer to next record
define SC_X	Memi[$1+1]	# x coordinate of scan edge mark
define SC_TYPE	Memi[$1+2]	# start (enter) or stop (exit) crossing of edge
define SC_VAL	Memi[$1+3]	# value associated with scan

# codes to identify type of edge crossing used in SC_TYPE field of scan record
define SCSTART	1		# type code to identify edge to enter scan
define SCSTOP	0		# type code to identify edge to exit scan
define SCTEMP	-1		# type code to identify new edge in polygon

define SCNULL	0		# null pointer (for SC_NEXT and scan pointers)

# codes used in sc_op routine to know which operation to use
define SCAD	7		# code to add new scan to existing scans
define SCOR	8		# code to or new scan with existing scans
define SCPN	9		# code to paint new scan over existing scans

# to assure that geometrically adjoining regions touch but don't overlap
# when edge is exactly on a pixel center it goes to right or upper region
define SC_INCL 1+int($1)	# first pixel counted when scanning low to high

define PI 3.14159265358979323846
define SMALL_NUMBER 1.0E-24
