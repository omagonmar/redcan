# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/bepos.h,v 11.0 1997/11/06 16:31:51 prosb Exp $
# $Log: bepos.h,v $
# Revision 11.0  1997/11/06 16:31:51  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:29  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:13:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:08  prosb
#General Release 2.1
#
#Revision 1.2  92/09/25  10:36:41  janet
#*** empty log message ***
#
#Revision 1.1  92/09/25  10:33:57  janet
#Initial revision
#
#
# Module:       bepos.h
# Project:      PROS -- ROSAT RSDC
# Purpose:      useful parameters for bepos task     
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD	initial version 9/92
#               {n} <who> -- <does what> -- <when>

define  x                       1               # x pos arr pointer
define  y                       2               # y pos arr pointer

define pos_x                    1               # code indicating pos x
define neg_x                    2               # code indicating neg x
define pos_y                    3               # code indicating pos y
define neg_y                    4               # code indicating neg y

define c                        1               # array ptr to c statistic
define s                        2               # array ptr to src cnts
define cell_eff_factor          1.6

define noerror                  0
define oob                      1               # out of bnds array ptr
define nc                       2               # no counts array ptr
define rl                       3               # refine limit array ptr
define pc                       4               # position confidence
define st                       5               # snr thresh

define pix_per_elem             1
define pix_incr                 1.0             # pixel increment; zoom of poe
define recs_per_src             11
