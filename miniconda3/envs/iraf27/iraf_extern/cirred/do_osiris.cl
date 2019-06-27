procedure do_osiris (p1, p2)

int    p1        	{prompt="First spectrum index"}
int    p2        	{prompt="Last spectrum index"}
char   sname=""		{prompt="Spectrum output name"}
string pre="r."       	{prompt="raw image prefix (basename)"}
string pre1="r"       	{prompt="image output prefix (basename)"}
string suf1="n"       	{prompt="image suffix following initial osiris processing"}
int    exten=4		{prompt="Number of digits in filename extension"}
bool   do_flat=yes 	{prompt="Make and correct data with flat?"} 
char   flat=""		{prompt="Flat field image (do_flat=no)"}
int	j1=0		{prompt="First flat on image index"}
int	j2=0		{prompt="Last flat on image index"}
int	j3=0		{prompt="First flat off image index"}
int	j4=0		{prompt="Last flat off image index"}
bool   do_sky=yes    	{prompt="Sky subtract?"}
bool   do_extract=yes	{prompt="Extract spectra?"}
bool   do_wave=no	{prompt="Wavelength calibrate spectrum"}
char   waveimage=""	{prompt="Arc lamp image for wavelength calibration"}
bool   do_clean=no	{prompt="Delete temp files"}

begin

real norm
#
# this is the flat name. If it exists, it will be used by osiris.
#
if (access(flat) || access(flat//".fits") && !(do_flat)) {
	print("using existing flat image "//flat)
} else if (do_flat) {
	print("Will use flat name "//flat)
        flat="flat"//j1
}

if (do_flat) {
	clearim(flat)
        osiris (j1,j2,div="no",pre=pre,pre1=pre1)
        osiris (j3,j4,div="no",pre=pre,pre1=pre1)
	med (j1,j2,"tflaton",pre=pre1,suf=suf1,exten=exten)
        med (j3,j4,"tflatoff",pre=pre1,suf=suf1,exten=exten)
        if (access("tflaton.fits") && access("tflatoff.fits")) {
	   imar("tflaton","-","tflatoff",flat)
           imstat (flat, format=no, fields="midpt") | scan norm
           imarith(flat , "/", norm, flat)
        } else {
	   print("No flats made...exiting")
	   bye
	} 
}
#
# reduce the science data. see osiris param file for params to set.
#
print ("Begin science frame reductions")
if (access(flat) || access (flat//".fits")) {
	osiris (p1,p2,pre=pre,div="yes",dome=flat)
} else {
	osiris (p1,p2,pre=pre,div="no")
}
#
# sky subtraction. First option subracts a median sky frame from each image.
# the task will add an "s" to the end of each sky subtracted image.
#
if (do_sky) {
	sky_sub (p1,p2,pre=pre1,suf=suf1,make+,sub+)
} else {
	print ("No sky subtraction")
}
#
# extract spectra
#
if (do_extra) {
	print ("Begin extraction of spectra")
	extra (p1,p2,pre=pre1,suf="s")
# 	Combine spectra
	print ("Combine spectra")
	spec_comb (p1,p2,sname,pre=pre1,suf="s.ms")
	if (do_wave) {
		print ("Doing wavelength calibration")
		if (access(waveimage) || access(waveimage//".fits")) {
		   refspec (sname, reference=waveimage)
		   dispcor (sname, sname)
		} else {
	  	print ("Calibration image "//waveimage//" does not exist")
		}
	}	
#
# clean up
#
if (do_clean) {
	clearim("tflaton")
	clearim("tflatoff")
}
}
end
