# $Header: /home/pros/xray/xspatial/eintools/source/RCS/index.x,v 11.0 1997/11/06 16:31:33 prosb Exp $
# $Log: index.x,v $
# Revision 11.0  1997/11/06 16:31:33  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:45  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:13:23  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       index.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     a2b2c
# Local: 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
# An integer index is a mapping between two sets of data.  For
# instance, we may want to map aspect data (asp) with a set of start
# and stop times (times) with an index (times2asp).  (We want to 
# associate each set of times with an aspect value -- this is why
# it is times2asp instead of asp2times.)
#
# For example, we might have the following data:
#
#                  ASP 1st row:   ROLL=0.8 ASPX=1.0 ASPY=2.0 ASPR=0.01
#                  ASP 2nd row:   ROLL=0.8 ASPX=2.0 ASPY=0.0 ASPR=0.02
#
#                TIMES 1st row:   START=9080594.02  STOP=9080600.02
#                TIMES 2nd row:   START=9080605.88  STOP=9080799.98
#                TIMES 3rd row:   START=9081888.25  STOP=9084002.87
#
#                TIMES2ASP[1]=1
#                TIMES2ASP[2]=1
#                TIMES2ASP[3]=2
#
# Thus the first aspect would be valid for the times in the TIMES 
# structure's first and second rows, while the second aspect would be 
# valid for the time in the third row.   Note that the size of the
# TIMES2ASP array is the same as the number of elements in the TIMES
# structure (n_times).
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Procedure:    a2b2c
#
# Purpose:      To make the composition of two sets of indexes
#
# Input variables:
#               n_a		number of elements of type A
#		a2b		index mapping A into B
#		b2c		index mapping B into C
#
# Output variables:
#               a2c		index mapping A into C
#
# Description:  This routine will take two sets of integer indexes and
#		form their composition.  Thus, for instance, if you
#		have indexes TIMES2ASP and ASP2HUT, this routine will
#		create the index TIMES2HUT.
#
#		Since the array a2c is expected to be passed in, 
#		memory must already be set aside.  (Of course, it should
#		be set to be "n_a".)
#
#--------------------------------------------------------------------------


procedure a2b2c(n_a,a2b,b2c,a2c)
int 	n_a	  # i: number of elements of type A
int	a2b[n_a]  # i: index from A to B
int	b2c[ARB]  # i: index from B to C
int	a2c[n_a]  # o: index from A to C

int	i_a   # local variable: counter into A index
begin
	do i_a=1,n_a
	{
	    a2c[i_a]=b2c[a2b[i_a]]
	}
end
