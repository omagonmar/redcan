	#### TELESCOPE SETTINGS
	TELESCOP = obs[0].header["TELESCOP"]
	INSTRUME = obs[0].header["INSTRUME"]
#	print line+":  Observations made with "+TELESCOP +" Using:"+ INSTRUME
	
	#### OBJECT SETTINGS	
	OBJECT = obs[0].header["OBJECT"]
	OBSTYPE = obs[0].header["OBSTYPE"]
#	OBSMODE = obs[0].header["OBSMODE"]
	OBSCLASS = obs[0].header["OBSCLASS"]
	OBSERVAT = obs[0].header["OBSERVAT"]
	RA = obs[0].header["RA"]
	DEC = obs[0].header["DEC"]
	PA = obs[0].header["PA"]
	PARALLAX = obs[0].header["PARALLAX"]

	#### INSTRUMENT SETTINGS
	FILTER1 = obs[0].header["FILTER1"]
	FILTER2 = obs[0].header["FILTER2"]
	GRATING = obs[0].header["GRATING"]
	CHPTHROW = obs[0].header["CHPTHROW"]
#	CHPCOADD = obs[0].header["CHPCOADD"]
#	FRMCOADD = obs[0].header["FRMCOADD"]
#	NCHOPS = obs[0].header["NCHOPS"]
#	NNODS = obs[0].header["NNODS"]
#	NSAVSETS = obs[0].header["NSAVSETS"]

	#### CONDITIONS
	AIRMASS = obs[0].header["AIRMASS"]
	LT = obs[0].header["LT"]
	UT = obs[0].header["UT"]
	DATE = obs[0].header["DATE"]
	DATEOBS = obs[0].header["DATE-OBS"]
	TIMEOBS = obs[0].header["TIME-OBS"]
	FRAME = obs[0].header["FRAME"]

	#### COORDINATES SETTING	
	NAXIS = obs[0].header["NAXIS"]
#	CD11 = obs[0].header["CD1_1"]
#	CD12 = obs[0].header["CD1_2"]
#	CD21 = obs[0].header["CD2_1"]
#	CD22 = obs[0].header["CD2_2"]
#	CRPIX1 = obs[0].header["CRPIX1"]
#	CRPIX2 = obs[0].header["CRPIX2"]
#	CRVAL1 = obs[0].header["CRVAL1"]
#	CRVAL2 = obs[0].header["CRVAL2"]
#	CTYPE1 = obs[0].header["CTYPE1"]
#	CTYPE2 = obs[0].header["CTYPE2"]
	OBJECT="".join(OBJECT.split(" "))
	FILTER1="".join(FILTER1.split(" "))
	FILTER2="".join(FILTER2.split(" "))
	GRATING="".join(GRATING.split(" "))
