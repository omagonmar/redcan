# $Header: /home/pros/xray/xtiming/timcor/calc_bary/RCS/ephem.com,v 11.0 1997/11/06 16:45:39 prosb Exp $
# $Log: ephem.com,v $
# Revision 11.0  1997/11/06 16:45:39  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:36:08  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:44:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:05:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:01:00  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:07:24  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:40:16  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/03/26  13:28:09  prosb
#Initial revision
#
#
# Module:       < file name >
# Project:      PROS -- ROSAT RSDC
# Purpose:      < opt, brief description of whole family, if many routines>
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>
#               {n} <who> -- <does what> -- <when>
#
double  earth[3,4,NDAYCH]       # earth position and its first three
                                # derivatives for each day
double  sun[3,NDAYCH]           # sun positions for each day in memory
double  tdbtdt[NDAYCH]          # relativistic time correction (tdb-tdt)
double  tdbdot[NDAYCH]          # rate of change of tdbtdt
double  tdtut[NDAYCH]           # time difference tdt-utc
long 	jd0                     # beginning jd of ephemeris file
long    jd1                     # ending jd of ephemeris file
long    jdch0                   # first jd of ephemeris in memory
long    jdch1                   # last  jd of ephemeris in memory
pointer ear_cp[3]
pointer eard1_cp[3]
pointer eard2_cp[3]
pointer eard3_cp[3]
pointer sun_cp[3]
pointer tdbtdt_cp

common /ephem_com/earth, sun, tdbtdt, tdbdot, tdtut,
	      jd0, jd1, jdch0, jdch1, ear_cp, eard1_cp, eard2_cp,
	      eard3_cp, sun_cp, tdbtdt_cp
