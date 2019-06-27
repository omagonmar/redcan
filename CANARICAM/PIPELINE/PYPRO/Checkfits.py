#!/usr/bin/env python
#
##
##	Checkfits.py:   		Checking the extension of the fits with TCHECKSTRUCTURE
import sys

dirmidir = sys.argv[1:2]
dirmidir = dirmidir[0]
fileName = sys.argv[2:3]
fileName = fileName[0]

#
# Import libraries
#

from pyraf import *
#import pyfits
import numpy
#from pyfits import getdata, getheader
iraf.gemini(_doprint=0)
iraf.reset(midir = dirmidir)
iraf.task(midir = dirmidir + 'midir.cl')
iraf.gnirs(_doprint=0)
iraf.midir()


iraf.tcheckstructure(image=fileName)
