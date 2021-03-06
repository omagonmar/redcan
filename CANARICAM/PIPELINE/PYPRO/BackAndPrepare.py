#!/usr/bin/env python
#
##
##	BackAndPrepare.py:   		Stacking of individual datasets
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
iraf.images()
iraf.immatch()
#iraf.nmisc()
iraf.gemini()
dirmidir = sys.argv[1:2]
dirmidir = dirmidir[0]
iraf.reset(midir = dirmidir)
iraf.task(midir = dirmidir + 'midir.cl')
iraf.midir()
#
##
#### Removing bad chops-nods and preparing data
##
#
infile = sys.argv[2:3]
infile = infile[0]
sigm = sys.argv[3:4]
sigm = sigm[0]
file = open(infile,'r')
lines = file.readlines()
for line in lines:
	line = line.replace('\n','')
	aux = line.split('\t')
	fileName = str(aux[0])
	iraf.tbackground(inimages=fileName,outpref='b_',sh_change="yes",sigma=sigm,verbose="yes",bsetfil='BadChopsNods.lst',writeps="no")
