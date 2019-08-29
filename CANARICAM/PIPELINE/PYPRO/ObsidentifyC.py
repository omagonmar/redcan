#!/usr/bin/python
#

#####   Obsidentify
##
##      Purpose: Identification of observation type and reading of header.
##
##      Date: Monday 20th of February 2011
##
##	Inputs:
##		Infile: 	ASCII file with a list of all the observations
##		Verbos:	Verbosity level: 
##					1. Nothing on the screen or text file.
##					2. Only text file.
##					3. All on the screen.
##					4. Text file and screen.

#
# Import libraries
#

import sys
import os

#import pyfits
import astropy.io.fits as pyfits

##
#### Inputs:
##

infile = sys.argv[1:2]
infilen = sys.argv[2:3]
phase = sys.argv[3:4]
obsclassSel = sys.argv[4:5]
infile = infile[0]
infilen = infilen[0]
phase = phase[0]
obsclassSel = obsclassSel[0]

file = open(infile,'r')

fileout1 = open('PRODUCTS/ID1'+infilen+'.lst','w')
fileout2 = open('PRODUCTS/ID2'+infilen+'.lst','w')
fileout3 = open('PRODUCTS/ID3'+infilen+'.lst','w')
fileout4 = open('PRODUCTS/ID4'+infilen+'.lst','w')
i = 1
if phase == 0:
	print "#N\tFILE\t\tOBSERVAT\tINSTR\tTIMEOBS\t\tDATEOBS\t\tSTARTTIME\tOBJECT\tOBSTYPE\tOBSCLASS"
for line in file:
	line = line[0:19]
	obs=pyfits.open(line)


	#### Keywords for the telescope (aditional information)
	OBSERVAT = obs[0].header["OBSERVAT"]
	INSTRUME = obs[0].header["INSTRUME"]
	
	#### Keywords to order the list of files	
	TIMEOBS = obs[0].header["UTSTART"]       
	DATEOBS = obs[0].header["DATE"]
	STARTTIME = float(TIMEOBS[0:2])*60.*60. + float(TIMEOBS[3:5])*60. +float(TIMEOBS[6:10])
	STARTDATE = float(DATEOBS[0:4])*12.*30. + float(DATEOBS[5:7])*30. +float(DATEOBS[8:11])
	START = (STARTDATE*24.*60.*60.)+STARTTIME
	fileout2.write(line + "\t" + TIMEOBS + "\t" + DATEOBS + "\t" + str(START) +"\n")
	
	CHANGEPOINT = float(2014.)*12.*30. + float(9.)*30. +float(4.)


	#### Keywords to determine the type of the observation	
	OBJECT = obs[0].header["OBJECT"]
	OBSTYPE = obs[0].header["CAMMODE"]
	if obsclassSel == "NONE":
		OBSCLASS = "science"
	else:
		OBSCLASS = obs[0].header["OBSCLASS"]
	FILTER1 = obs[0].header["FILTER1"]
	FILTER2 = obs[0].header["FILTER2"]
	GRATING = obs[0].header["GRATING"]
	SLIT = obs[0].header["SLIT"]
	SECTOR = obs[0].header["SECTOR"]
	if STARTDATE >= CHANGEPOINT: 
		RA = obs[0].header["RADEG"]
		DEC = obs[0].header["DECDEG"]
		print "Warning: OBSERVATION DONE AFTER 04-09-2014. Positions keywords changed to RADEG,DECDEG (instead RA,DEC)"
	else:
		RA = obs[0].header["RA"]
		DEC = obs[0].header["DEC"]
	
	#### Removing spaces
	OBJECT="".join(OBJECT.split(" "))
	OBSTYPE="".join(OBSTYPE.split(" "))
	OBSCLASS="".join(OBSCLASS.split(" "))
	FILTER1="".join(FILTER1.split(" "))
	FILTER2="".join(FILTER2.split(" "))
	GRATING="".join(GRATING.split(" "))
	SLIT="".join(SLIT.split(" "))
	SECTOR="".join(SECTOR.split(" "))
	fileout1.write(line + "\t" + OBJECT + "\t"+ OBSTYPE + "\t"+ OBSCLASS + "\t"+ FILTER1  + "\t"+ FILTER2 + "\t"+ GRATING + "\t"+ SLIT + "\t"+ str(RA) + "\t"+ str(DEC) + "\t"+ str(SECTOR)+"\n")
	
	#### Keywords to compute on-source time
	CHPCOADD = obs[0].header["CHPCOADD"]
	FRMCOADD = obs[0].header["FRMCOADD"]
	FRMTIME = obs[0].header["FRMTIME"]
	OBJTIME = obs[0].header["OBJTIME"]
	NSAVSETS = obs[0].header["NSAVSETS"]
	NNODS = obs[0].header["NNODS"]
	NNODSETS =  obs[0].header["NNODSETS"]
	EXPOSURE = CHPCOADD * FRMTIME * FRMCOADD * 0.001 
	fileout3.write(line  + "\t" + str(FRMTIME)  + "\t" + str(FRMCOADD)  + "\t" + str(CHPCOADD) + "\t" + str(NSAVSETS) + "\t" + str(NNODS)+ "\t" + str(NNODSETS)  + "\t" + str(EXPOSURE) + "\t" + str(OBJTIME)+"\n")
	
	#### Keywords for the stacking
	NNODSETS = obs[0].header["NNODSETS"]
	fileout4.write(line  + "\t" + str(NNODS)  + "\t" + str(NNODSETS)  + "\t" + str(NSAVSETS) +"\n")

	RA = obs[0].header["RA"]
	DEC = obs[0].header["DEC"]
	
#	format = ['%03d', '%10s', '%10s']
#	data = [1, 10, 100]
#	print [fmt % d for fmt,d in zip(format,data)]
	if phase == 0:
		print str(i) + "\t" + line + "\t" + OBSERVAT + "\t" + INSTRUME + "\t" + TIMEOBS + "\t" + DATEOBS + "\t" + str(START) + "\t" + OBJECT + "\t" + OBSTYPE + "\t" + OBSCLASS
	i += 1
file.close()
fileout1.close()
fileout2.close()
fileout3.close()
fileout4.close()

