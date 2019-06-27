# Header$
# Log$
#
# ---------------------------------------------------------------------
#
# Module:       setvar.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      determine the frame counts for small number regime.
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- Jan 1993 -- initial version
#               {#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------

include <ext.h>
include <imhdr.h>
include <fset.h>

define  x  1
define  y  2

procedure setvar (icnts, ocnts)
	

real    icnts			# i: counts in 1 image element
real    ocnts			# o: return counts

real    conf[0:40]		# l: confidence values for 1 - 40 counts

int     i			# l: loop counter

data (conf(i),i=0,7)   / 3.39,  5.29,  6.95,  8.51,  9.99, 11.43, 12.83, 14.20/
data (conf(i),i=8,15)  /15.55, 16.88, 18.19, 19.48, 20.77, 22.04, 23.31, 24.56/
data (conf(i),i=16,23) /25.81, 27.05, 28.28, 29.51, 30.73, 31.95, 33.16, 34.36/
data (conf(i),i=24,31) /35.57, 36.36, 37.96, 39.15, 40.34, 41.52, 42.70, 43.88/
data (conf(i),i=32,39) /45.05, 46.23, 47.40, 48.56, 49.73, 50.89, 52.05, 53.21/
data  conf(40)         /54.37/

begin


#  test for elements with low counts, and replace with confidence values
#  for counts with low statistics

	if ( icnts <= 40.0 ) {
           ocnts = conf[nint(icnts)]
        } else {
	   ocnts = icnts
	}

end
