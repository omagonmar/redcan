# $Header: /home/pros/xray/xspatial/eintools/source/RCS/asp.h,v 11.0 1997/11/06 16:31:29 prosb Exp $
# $Log: asp.h,v $
# Revision 11.0  1997/11/06 16:31:29  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:34  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:11:24  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
# This header stores the ASP and TIME data structures used by EINTOOLS.
#
#  ASP: stores a particular aspect for the Einstein instrument:
#
#       ASP_ROLL  -- the nominal roll for the instrument
#       ASP_ASPX  -- aspect x offset
#       ASP_ASPY  -- aspect y offset
#       ASP_ASPR  -- aspect roll offset
#
# These aspects are valid for a certain set of times.  Hence we have
# a TIME data structure:
#
#       TM_START  -- starting time 
#       TM_STOP   -- stopping time
#
#
# The definitions "ASP" and "TM" are used to access particular records
# within the data structures.  I.e., if p_asp is a pointer to aspect
# records, then ASP(p_asp,5) is a pointer to the fifth aspect record.
#--------------------------------------------------------------------------

define SZ_ASP         4

define ASP            (($1)+(($2-1)*SZ_ASP))
define ASP_ROLL       Memd[$1]
define ASP_ASPX       Memd[($1)+1]
define ASP_ASPY       Memd[($1)+2]
define ASP_ASPR       Memd[($1)+3]



define SZ_TIME        2

define TM             (($1)+(($2-1)*SZ_TIME))
define TM_START       Memd[$1]
define TM_STOP        Memd[($1)+1]


