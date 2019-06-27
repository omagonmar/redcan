
		try:
			os.remove('onsource.fits')
		except os.error:
			pass
		try:
			os.remove('offsource.fits')
		except os.error:
			pass
		try:
			os.remove('resta.fits')
		except os.error:
			pass
		iraf.imcombine(listaA,'onsource.fits',headers="",bpmasks="",rejmasks="",
			nrejmasks="",expmasks="",sigmas="",logfile="STDOUT",
			combine="average",reject="none",project="no",outtype="double",
			outlimits="", weight="none", offsets="none", scale="none")
		iraf.imcombine(listaB,'offsource.fits',headers="",bpmasks="",rejmasks="",
			nrejmasks="",expmasks="",sigmas="",logfile="STDOUT",
			combine="average",reject="none",project="no",outtype="double",
			outlimits="", weight="none", offsets="none", scale="none")
		iraf.imarith('onsource.fits', "-", 'offsource.fits',"resta.fits")
		try:
			os.remove('rmi_ons'+str(i)+fileName)
		except os.error:
			pass
		try:
			os.remove('rmi_offs'+str(i)+fileName)
		except os.error:
			pass
		try:
			os.remove('rmi_diff'+str(i)+fileName)
		except os.error:
			pass
		if NOD == 'A': 
			iraf.imarith('onsource.fits',"*","1.",'rmi_ons'+str(i)+fileName)
			iraf.imarith('offsource.fits',"*","1.",'rmi_offs'+str(i)+fileName)
			iraf.imarith('resta.fits',"*","1.",'rmi_diff'+str(i)+fileName)
		else: 
			iraf.imarith('onsource.fits',"*","1.",'rmi_ons'+str(i)+fileName)
			iraf.imarith('offsource.fits',"*","1.",'rmi_offs'+str(i)+fileName)
			iraf.imarith('resta.fits',"*","-1.",'rmi_diff'+str(i)+fileName)
	try:
		os.remove('kk1.fits')
	except os.error:
		pass
	try:
		os.remove('kk2.fits')
	except os.error:
		pass
	try:
		os.remove('kk3.fits')
	except os.error:
		pass
	iraf.imcombine('rmi_ons*fits','kk1.fits',headers="",bpmasks="",rejmasks="",
		nrejmasks="",expmasks="",sigmas="",logfile="STDOUT",
		combine="average",reject="none",project="no",outtype="double",
		outlimits="", weight="none", offsets="none", scale="none")
	iraf.imcombine('rmi_offs*fits','kk2.fits',headers="",bpmasks="",rejmasks="",
		nrejmasks="",expmasks="",sigmas="",logfile="STDOUT",
		combine="average",reject="none",project="no",outtype="double",
		outlimits="", weight="none", offsets="none", scale="none")
	iraf.imcombine('rmi_diff*fits','kk3.fits',headers="",bpmasks="",rejmasks="",
		nrejmasks="",expmasks="",sigmas="",logfile="STDOUT",
		combine="average",reject="none",project="no",outtype="double",
		outlimits="", weight="none", offsets="none", scale="none")

	for i in range(1,NNODSETS*NNODS +1) :
		os.remove('rmi_ons'+str(i)+fileName)
		os.remove('rmi_offs'+str(i)+fileName)
		os.remove('rmi_diff'+str(i)+fileName)

	onsource=getdata('kk1.fits')
	offsource=getdata('kk2.fits')
	resta= getdata('kk3.fits')
	final = numpy.arange(3*320*240).reshape(3,240,320)
	final[0]=onsource
	final[1]=offsource
	final[2]=resta
