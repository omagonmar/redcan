# $Header: /home/pros/xray/xspatial/eintools/source/RCS/array.h,v 11.0 1997/11/06 16:31:28 prosb Exp $
# $Log: array.h,v $
# Revision 11.0  1997/11/06 16:31:28  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:33  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:11:13  prosb
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
# Useful definitions for dealing with generic arrays.
#
# For instance, if you have a pointer to an array of doubles,
# you can assign the n-th element with:
#
#           ARRELE_D(p_array,n) = value
#
#--------------------------------------------------------------------------

define ARRELE_B       Memb[($1)+($2)-1]
define ARRELE_C       Memc[($1)+($2)-1]
define ARRELE_S       Mems[($1)+($2)-1]
define ARRELE_I       Memi[($1)+($2)-1]
define ARRELE_L       Meml[($1)+($2)-1]
define ARRELE_R       Memr[($1)+($2)-1]
define ARRELE_D       Memd[($1)+($2)-1]
define ARRELE_X       Memx[($1)+($2)-1]

