# $Header: /home/pros/xray/xtiming/timcor/apply_bary/RCS/apply_bary.com,v 11.0 1997/11/06 16:45:34 prosb Exp $
# $Log: apply_bary.com,v $
# Revision 11.0  1997/11/06 16:45:34  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:35:59  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:44:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:05:07  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:00:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:07:12  prosb
#General Release 2.1
#
#Revision 4.1  92/10/15  16:19:55  jmoran
#JMORAN fixed code to adjust for new GTI library code
#
#Revision 4.0  92/04/27  15:39:49  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/13  16:07:04  jmoran
#JMORAN changed char strings to pointers
#
#Revision 1.1  92/03/26  13:26:52  prosb
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
double  a
double  b
double  alpha
double  delta
double  orb_real[2]
double  corr_real[2]
long    row
int	toffset
int     ngti
long    orb_int[2]
long    corr_int[2]
long    orb_offset
long    corr_offset
long	nrows
pointer cp[4]
pointer tp
pointer blist
pointer elist
pointer qp_out
pointer	tbl_r1
pointer	tbl_r2
pointer	tbl_i1
pointer	tbl_i2
pointer	tbl_fname
pointer s2u_fname
common/barcor/a, b, alpha, delta, orb_real, corr_real,
	      row, toffset, ngti, orb_int, corr_int, orb_offset, 
	      corr_offset, nrows, cp, tp, blist, elist, qp_out, 
	      tbl_r1, tbl_r2, tbl_i1, tbl_i2, tbl_fname, s2u_fname
