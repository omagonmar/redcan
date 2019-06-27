# $Header: /home/pros/xray/xproto/evalvg/RCS/evalvg.h,v 11.0 1997/11/06 16:38:57 prosb Exp $
# $Log: evalvg.h,v $
# Revision 11.0  1997/11/06 16:38:57  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:42  prosb
# General Release 2.4
#
#Revision 1.1  1994/07/20  11:33:54  chen
#Initial revision
#
# ------------------------------------------------------------------------
# Module:       evalvg.h
# Project:      PROS -- ROSAT RSDC
# Description:  Set up constants that are used for evalvg task 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Judy Chen  initial version January 1994
# ------------------------------------------------------------------------
define   X               1               # x-coordinate
define   Y               2               # y-coordinate
define   Z               3               # z-coordinate

define   NCOLS           15              # dimension of table column
define   START           1               # START time
define   STOP            2               # STOP time

define   HR_DAY          24.d0           #number of hours per day
define   SEC_HR          3600.d0         #number of seconds per hour
define   HOUR_PER_DAY    24
define   MIN_PER_HOUR    60
define   SEC_PER_MIN     60
define   SEC_PER_HOUR    (SEC_PER_MIN * MIN_PER_HOUR)
define   SECONDS_PER_DAY (SEC_PER_HOUR * HOUR_PER_DAY)

define   CLOBBER         "clobber"       #clobber the old file
define   DISPLAY         "display"       #display level (0-5)

# variables that defined in HOPR and used to calculate angles
define   SYS_REF_YEAR    1990            # space-craft clock year
define   SYS_REF_DAY     152             # space-craft clock day
define   JD_REF_DAY      1               #ref.day for JD is Jan 1, 1900 at noon
define   JD_REF_YEAR     0               #ref.year for JD is 1900
define   COLINEAR_SQUARE 4.0             # a geometry number
define   DAY_CENTURY     36525.d0        #number of days in a century
define   JD_1900         2415020.d0      #julian day 12 noon,jan 1.1900
define   PRECSS_CORR    0.0929d0        #correction for earth precession
define   VE_ANGLE       23925.836d0     #angle of vernal equinox
define   VE_CENTURY     8640184.542d0   #hrs v.e moves per century
