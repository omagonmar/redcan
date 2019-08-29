#!/usr/bin/env python
#
##
##	Flatfield.py:   	Stacking of flats
##
##	Inputs: 		List of files generated by the identification
##	Outputs:		rmi_'Input'
##
##	Version 1.0: 		22/02/2011
##

#
# Import libraries
#

import sys
from pyraf import *

#import pyfits
import astropy.io.fits as pyfits
import numpy
from pyfits import getdata, getheader
iraf.images(_doprint=0)
iraf.immatch(_doprint=0)
#iraf.nmisc()

iraf.gemini(_doprint=0)
dirmidir = sys.argv[1:2]
dirmidir = dirmidir[0]
iraf.reset(midir = dirmidir)
iraf.task(midir = dirmidir + "midir.cl")
iraf.midir()


#
##
#### Creating FLATS
##
#
infile = sys.argv[2:3]
infile = infile[0]
back_check = sys.argv[3:4]
back_check = back_check[0]
file = open(infile,'r')
lines = file.readlines()
for line in lines:
	line = line.replace('\n','')
	aux = line.split('\t')
	fileName = str(aux[0])
	fileName = fileName.replace(' ','')
	iraf.tprepare(inimages='b_'+fileName,outpref='t',stackop="stack",combine="average", fl_check='no')
	iraf.mistack(inimages='tb_'+fileName,outpref='a', combine="average",framety="ref", verbose="yes")
