#!/usr/bin/python
#
##
##	REDUCEMI.PY:   		From MIREDUCE of iraf.gemini.midir using Python
##
##	Purpose: 		Combination of MIR images from T-Recs and CANARICAM
##	Inputs: 		List of images 
##	Outputs:		rmi_'Input'
##
##	Example: 		./mireduce.py S20040131S0105.fits S20040201S0109.fits
##	Version 1.0: 		01/12/2011
##
##	Future Improvements:	- Remove automatically wrong exposures.

#
# Import libraries
#


regist='N'
scl='N'
import time
time1 = time.asctime()
print 'REDUCEMI COMMENT:  Log opened at '+time1

import sys
import sgmllib
import pickle
import pyfits
from pylab import *
from pyraf import *
from numarray import *
import os

iraf.images()
iraf.immatch()
iraf.nmisc()

a = sys.argv[1:]
N='No'
Y='Yes'

for l in a:
	obj=str(l)
	myfile=pyfits.open(obj)
	myfile.info()
	num = (myfile[0].header["NNODSETS"])*2 + 1
	nm = (myfile[0].header["NNODSETS"])*2 
	NAXIS1 = myfile[1].header["NAXIS1"]
	NAXIS2 = myfile[1].header["NAXIS2"]
	NSAVS = (myfile[0].header["NSAVSETS"]) + 1	
	try:
		os.remove('rmi_'+obj)
	except os.error:
		pass
	try:
		os.mkdir('Products')
	except os.error:
		pass

	tmp_list = "tmpcb_1.fits"
	tmpsh_list = "tmpcbsh_1.fits"
	for i in range(1,num) :
		nod = myfile[i].header["NOD"]
		print 'REDUCEMI COMMENT: Intializing test of accuracy for saveset:    ### '+str(i)+'(Nod '+nod+')'
		# cambiar lista al numero que tenga
		listaA = listaB = listaC = listaD = listaE = ""
		for j in range(1,NSAVS):
			try:
				os.remove('rmi_'+str(i)+'_s'+str(j)+obj)
				os.remove('rmi_r'+str(i)+'_s'+str(j)+obj)
			except os.error:
				pass
			if j == 1:			
				listaA += obj+'['+str(i)+'][*,*,1,'+str(j)+']'
				listaB += obj+'['+str(i)+'][*,*,2,'+str(j)+']'
				listaC += 'rmi_'+str(i)+'_s'+str(j)+obj
				listaD += 'rmi_r'+str(i)+'_s'+str(j)+obj
			else:
				listaA += ','+obj+'['+str(i)+'][*,*,1,'+str(j)+']'
				listaB += ','+obj+'['+str(i)+'][*,*,2,'+str(j)+']'
				listaC += ','+'rmi_'+str(i)+'_s'+str(j)+obj
				listaD += ','+'rmi_r'+str(i)+'_s'+str(j)+obj
		iraf.imarith(listaA, "-", listaB,listaC)
		if scl == 'Y':
			stats=iraf.imstat(listaC,fields='midpt',format=0,Stdout=1)
			for j in range(0,NSAVS-1):
				if j == 0:			
					listaE += str(0.-float(stats[j]))
				else:
					listaE += ','+str(0.-float(stats[j]))
			iraf.imarith(listaC,"+",listaE,listaD)
		else:
			iraf.imcopy(listaC,listaD)	
		try:
			os.remove('tmpcb.fits')
		except os.error:
			pass
		try:
			os.remove('tmpcb_'+str(i)+'.fits')
		except os.error:
			pass
		for j in range(1,NSAVS):
			try:
				os.remove('rmi_'+str(i)+'_s'+str(j)+obj)
			except os.error:
				pass
		iraf.imcombine(listaD,'tmpcb.fits',headers="",bpmasks="",rejmasks="",
		nrejmasks="",expmasks="",sigmas="",logfile="STDOUT",
		combine="average",reject="none",project="no",outtype="double",
		outlimits="", weight="none", offsets="none", scale="none")
		for j in range(1,NSAVS):
			try:
				os.remove('rmi_r'+str(i)+'_s'+str(j)+obj)
			except os.error:
				pass
		if nod == 'A': iraf.imarith('tmpcb.fits','*','1.','tmpcb_'+str(i)+'.fits')
		if nod == 'B': iraf.imarith('tmpcb.fits','*','-1.','tmpcb_'+str(i)+'.fits')
		if i > 1: tmp_list=tmp_list+',tmpcb_'+str(i)+'.fits' 							
		if i > 1: tmpsh_list=tmpsh_list+',tmpcbsh_'+str(i)+'.fits'
	if regist == 'Y':
		try:
			os.remove('shifts_'+obj+'.dat')
		except os.error:
			pass
		# Iteration to shift images
		if nm > 10: nm = 10
		print 'REDUCEMI COMMENT:  Shifting images:  #'+str(nm*2)
		for m in range(1,nm*2 + 1) :
			try:
				os.remove('shifts_'+str(m)+'.dat')
			except os.error:
				pass
			print 'REDUCEMI COMMENT:  Shifting image iteration: 	'+str(m)
			lista_regions="[*,*]"
			iraf.immatch.xregister(tmp_list,"tmpcb_1.fits",lista_regions,
			output=tmpsh_list,interactive="No",verbose="No",shift="tmpcbsh.dat",
			coords="",xlag="0",ylag="0",dxlag="0.01",dylag="0.01")		
			for j in range(1,num) : os.rename('tmpcbsh_'+str(j)+'.fits','tmpcb_'+str(j)+'.fits')
			os.rename('tmpcbsh.dat','Products/shifts_'+str(m)+'.dat')
	try:
		os.remove('tmpcb.fits')
	except os.error:
		pass
	# Final combination of the shifted (or not shifted) images
	iraf.imcombine(tmp_list,"tmpcb.fits",headers="",bpmasks="",rejmasks="",
	nrejmasks="",expmasks="",sigmas="",logfile="STDOUT",
	combine="average",reject="none",project="no",outtype="double",
	outlimits="", weight="none", offsets="none", scale="none")
	os.rename('tmpcb.fits','rmi_'+obj)
	# Updating the header
	EXTNAME="SCI"
	SAVESETS=myfile[0].header["SAVESETS"]
	WCSAXES=2
	CTYPE1=myfile[0].header["CTYPE1"]
	CRPIX1=myfile[0].header["CRPIX1"]
	CRVAL1=myfile[0].header["CRVAL1"]
	CTYPE2=myfile[0].header["CTYPE2"]
	CRPIX2=myfile[0].header["CRPIX2"]
	CRVAL2=myfile[0].header["CRVAL2"]
	CD1_1=myfile[0].header["CD1_1"]
	CD1_2=myfile[0].header["CD1_2"]
	CD2_1=myfile[0].header["CD2_1"]
	CD2_2=myfile[0].header["CD2_2"]
	RADECSYS=myfile[0].header["RADECSYS"]
	print "Upgrading Header..."
	iraf.hedit(image='rmi_'+obj,fields="EXTNAME",value=EXTNAME,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="SAVESETS",value=SAVESETS,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="WCSAXES",value=WCSAXES,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CTYPE1",value=CTYPE1,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CRPIX1",value=CRPIX1,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CRVAL1",value=CRVAL1,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CTYPE2",value=CTYPE2,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CRPIX2",value=CRPIX2,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CRVAL2",value=CRVAL2,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CD1_1",value=CD1_1,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CD1_2",value=CD1_2,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CD2_1",value=CD2_1,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="CD2_2",value=CD2_2,add="Yes",update="Yes",show="Yes",verify="No")
	iraf.hedit(image='rmi_'+obj,fields="RADECSYS",value=RADECSYS,add="Yes",update="Yes",show="Yes",verify="No")
	for j in range(1,num) : 
		os.rename('tmpcb_'+str(j)+'.fits','Products/rmi'+str(j)+'_'+obj)
		myfile=pyfits.open('Products/rmi'+str(j)+'_'+obj)
		nod = myfile[0].header["NOD"]
		print 'REDUCEMI COMMENT:  Final combined image for NOD '+nod+' ('+str(j)+') : 	rmi'+str(j)+'_'+obj
	print 'REDUCEMI COMMENT:    '
	print 'REDUCEMI COMMENT:  Subproducts at: 		 Products/.'
	print 'REDUCEMI COMMENT:    '
	print 'REDUCEMI COMMENT:  Final combined image: 	rmi_'+obj
	print 'REDUCEMI COMMENT:    '
	print 'REDUCEMI COMMENT:  Exit status: SUCCESS'
time2 = time.asctime()
print 'REDUCEMI COMMENT:  Log closed at '+time2
