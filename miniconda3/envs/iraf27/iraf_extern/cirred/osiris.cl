procedure osiris (p1, p2)
 
#
#  basic data reduction for OSIRIS, IRS, CIRIM data.
#

#
#  There are options for dark subtraction, flat fielding, normalization
#  by the exposure time, correction for linearity, and bad-pixel fixing.
#

#
#  instrum=OSIRIS, CIRIM, IRS, or ISPI. Pick CIRIM for a generic case.
#

#
# 25 may 99. RDB. 
# 27 aug 99. RDB. Add option to use both dark frame and "on frame" bias.
# 13 jan 00. RDB. Add OSIRIS irlincor coeffs. New detector (dec 1999).
# 20 jan 00. RDB. Add instrument keyword check.
# 19 mar 00. RDB. Add linearity correction by linfits.f.
# 30 mar 00. RDB. Add new irlincor coeffs.
# 18 apr 00. RDB. Add generic image trim option (previous was for OSIRIS only).
# 19 apr 00. RDB. Fix projection of 3rd dimension image combination. 
# 26 may 00. RDB. Fix case of compressed fits files so no recompression is done.
# 26 may 00. RDB. Load ctio package automatically for irlincor if lin=yes.
# 26 may 00. RDB. Set gzip as a foreign task for users who don't do this in
# 		  their login.cl file.
# 29 aug 00. RDB. Update image headers for bias image.
# 23 jan 01. RDB. Add 3 or 4 digit extension.
# 28 apr 02. RDB. Add extraction of %&*!# MEF for NIRI. Kludge 32 bit to -32.
# 01 dec 02. RDB. Add mkheader to MEF case to copy header info from the 
#		  [0] extension and pixel+header from [1] to the new file.
# 26 April 04. RDB. Add ISPI. Add BPM to header for use in combining images
#		  with bad pixel mask rejection. 		
# 06 July 05. RDB. Add irlincor coeffs for ISPI.
# 16 Sept 05. RDB. Options for flipping image in x-y (usefule for setting up
#                  images for WCS.
# 20 Sept 05. RDB. Add EPOCH keyword for initial WCS.
# 01 Octo 05. RDB. Add Gain, RN, and Gain_eff keywords. Add weight mask creation for swarp.
# 10 April06. RDB. Fix bug with integer pixels for images by always starting with "imar tempa / 1.0 tempa".
#

int p1          {prompt="beginning fits file index"}
int p2          {prompt="ending fits file index"}
string instrum="ISPI"{prompt="instrument? ISPI, OSIRIS, etc"}
string pre="r"  {prompt="prefix of the input fits files"}
string pre1="r" {prompt="prefix of the output fits files"}
string suf=""   {prompt="suffix for input files, DO NOT include '.fits, .imh'"}
int    exten=4  {prompt="file name extension has 3 or 4 digits? [4] <3|4>"}
string mask=""  {prompt="mask image for bad pixel fixing"}
string mask2="mask2" {prompt="mask used to make swarp weight file"}
bool   mkswarp="no" {prompt="make an swarp weight file from the dome flat and mask2? <yes|no>"}
string interp="xy"{prompt="interpolation for bad pixel fix, x, xy, zero"}
string div="no" {prompt="divide by a flat? <yes|no|header>"}
string dome=""  {prompt="flatfield image name (directory if div=header)"}
string bias="no"{prompt="subtract a dark frame? <no|file>"}
string dark=""  {prompt="dark image name"}
string bias2="no"{prompt="subtract an on frame bias? <no|irs|osiris>"}
string bsec=""  {prompt="image section used to for IRS bias, e.g [x1:x2,*]"}
bool   trim=yes {prompt="Trim images to illuminated area? <yes|no>"}
string trimim="[176:804,256:833]" {prompt="IM mode trim section"}
bool   mef=no  {prompt="MEF files? <yes|no>"}
bool   itime=yes {prompt="divide by EXPOSURE time? <yes|no>"}
bool   mcoadds=no{prompt="multiply by the no. of coadds? <yes|no>"}
bool   dcoadds=no{prompt="divide by the no. of coadds? <yes|no>"}
bool   lin=no   {prompt="linearize the data? <yes|no>"}
#bool   osirlin=no   {prompt="linearize OSIRIS data with linfits.f? <yes|no>"}
bool   project=no{prompt="average frames in 3-d image cube? <yes|no>"}
bool   flipx=no {prompt="flip image in x? <yes|no>"}
bool   flipy=no {prompt="flip image in y (choose yes for ISPI)? <yes|no>"}
real   gain=4.25 {prompt="Detector gain electrons/ADU)"}
real   rn=20     {prompt="Detector read noise (electrons)"}

begin

{
        int naxis
        real norm, norm2
        string dummy, dimage, image, filt, smode
#
# need artdata below.
#
	artdata
#
# check for a valid instrument name 
#
	if (instrum == "cirim") {intrum="CIRIM"}
	if (instrum == "irs") {intrum="IRS"}
	if (instrum == "ispi") {intrum="ISPI"}
	if (instrum == "osiris") {intrum="OSIRIS"}

	if (instrum != "CIRIM" && instrum != "OSIRIS" && instrum != "IRS" &&
		instrum!="ISPI") {
	  print "Please enter a valid intrument name, CIRIM, IRS, or OSIRIS"
	  print "Choose CIRIM for a generic case."
	  goto finished
	}
#
# find image type (fits, or imh)
#
        show imtype | scan image

        if(image=="imh") print "imh extension in use"
        if(image=="fits") print "fits extension in use"

	task gzip = $foreign
#
# reduce each image given in list on command line. Fits files are of 
# the form pre//000//suf.
#

	for ( i = p1 ; i <= p2; i += 1) {
	  if ( i < 10 ) {
            s2 = pre//"00"//i//suf
            if (exten==4) s2 = pre//"000"//i//suf
            s1 = pre1//"00"//i
            if (exten==4) s1 = pre1//"000"//i
	  }else if ( i < 100 ) {
            s2 = pre//"0"//i//suf
            if (exten==4) s2 = pre//"00"//i//suf
	    s1 = pre1//"0"//i
	    if (exten==4) s1 = pre1//"00"//i
          }else if ( i < 1000) {
            s2 = pre//i//suf
            if (exten==4) s2 = pre//"0"//i//suf
            s1 = pre1//i
	    if (exten==4) s1 = pre1//"0"//i
	  }else {
	    s2 = pre//i//suf
	    s1 = pre1//i
	  }
#
# if file exists, proceed with reduction, first clearing images
# from a prior reduction, if they exist.
#
          clearim("tempa")
          clearim("tempb")

          if (access(s2//".fits.Z")) { 
             uncompress ("-c", s2//".fits", > "tempa.fits") 
#
# read fits into iraf format if ext = imh
#
             if(image=="imh") rfits ("tempa.fits",iraf_fil="tempa.imh", file_lis="")
             imar ("tempa" , "/" , 1.0 , "tempa")

	  } else if (access(s2//".fits.gz")) {

	     gzip ('-d -c' , s2//".fits", > "tempa.fits")
             if(image=="imh") rfits ("tempa.fits",iraf_fil="tempa.imh", file_lis="")
             imar ("tempa" , "/" , 1.0 , "tempa")

	  } else if (access(s2//".imh")) {

            imcopy (s2 , "tempa" , v-)
            imar ("tempa" , "/" , 1.0 , "tempa")

          } else if (access(s2//".fits")) {

            if(image=="imh") { 
              rfits (fits_fil=s2//".fits",iraf_fil="tempa", file_lis="")
              imar ("tempa" , "/" , 1.0 , "tempa")
	    }

            if(image=="fits") { 
               if (mef) {
                  imcopy (s2//"[1]", "tempa", v-)
                  imcopy (s2//"[0]", "tempb", v-)
	          mkheader ("tempa" , "tempb", append+)
   	          imar ("tempa" , "/" , 1.0 , "tempa")
                    
	    } else {
	         imcopy (s2, "tempa", v-)
		 imar ("tempa" , "/" , 1.0 , "tempa")
            }
          }

          clearim(s1//"n")
          clearim(s1//"n.fits")
 
	  } else { 
            goto notfound 
	  }
#
# Start reduction.
#
          print ' '
	  print 'Processing image '//s2
#
# If the images are a data cube, average the frames
#
          hsel ("tempa" , "NAXIS" , "yes" ) | scan naxis
          if (naxis==3 && project==yes) {
            print "Combining image stack"
            imcomb ("tempa" , "tempb" , comb="average" , project=yes)
            imdel ( "tempa" )
            imrename ( "tempb" , "tempa" )
          }
#
# if desired, subtract dark frame and/or bias determined from non-illuminated
# pixels on the frame. 
#
          if (( bias == "file" ) || ( bias == "yes" )) {

            imarith("tempa" , "-", dark,  "tempa") 
            dummy= "bias subtracted with image "//dark
            print (dummy)
            hedit ("tempa", fields="BIAS", verify-, show-, update+ ,
                    add+, value=dummy)

          } 
#
# On frame case, IRS. Useful if bias is changing on a short timescale.
#

	  if ( bias2 == "irs" ) {

	    imstat ("tempa"//bsec, format=no, fields="midpt") | scan norm
            imarith("tempa" , "-", norm, "tempa")       
	    dummy= "image "//s2//" bias subtracted by "//norm//" counts"
	    print (dummy)
	    hedit ("tempa", fields="IRSBIAS", verify-, show-, update+ ,
                    add+, value=dummy)

	  } else if ( bias2 == "osiris") {
#
# Old OSIRIS images, 1024 format, before Jan 2000.
# fit a line (order=2) to the sample region. Make the sample region small
# to avoid any scattered light.
#
	    background ("tempa", "tempa", function="legendre", 
			sample="5:25,999:1019", naverage=1,low_rej=2,
			high_rej=2, order=2, inter=no, axis=1)
	    dummy="image "//s2//" bias subtracted using OSIRIS overscan region"
            print (dummy)
            hedit ("tempa", fields="OS_BIAS", verify-, show-, update+ ,
                    add+, value=dummy)
	    dummy="overscan=5:25,999:1019, nave=1, low=2,high=2, ord=2, ax=1"
            hedit ("tempa", fields="OS_SCAN", verify-, show-, update+ ,
                    add+, value=dummy)
	  }
#
# Trim images to the illuminated portion of the array.
#
          if (trim) {
            imcopy ("tempa"//trimim, "tempa", ver-)
            dummy="image "//s2//" trimmed to "//trimim
            print (dummy)
            hedit ("tempa", fields="IM_TRIM", verify-, show-, update+ ,
                    add+, value=dummy)
	  }

#
# if desired, make linearity correction.
#
          if (lin == yes) {
            ctio
            if (instrum =="CIRIM") {
               irlincor (input="tempa", output="tempa", coeff1=0.99893,
                         coeff2=0.0288, coeff3=0.0233) 
               print(s1//' CORRECTED WITH CIRIM LINEARITY COEFFS')
               dummy="CORRECTED WITH CIRIM LINEARITY COEFFS"
               hedit ("tempa", fields="LINCOR", verify-, show-, update+ ,
                add+, value=dummy)
               dummy="coeffs = 0.99893, 0.0288, 0.0233" 
               hedit ("tempa", fields="LINCOR2", verify-, show-, update+ ,
                add+, value=dummy)

            }  else if (instrum =="IRS") { 
               irlincor (input="tempa", output="tempa", coeff1=1.0009,
                         coeff2=0.0441, coeff3=1.416)  
               dummy="CORRECTED WITH IRS LINEARITY COEFFS"
               hedit ("tempa", fields="LINCOR", verify-, show-, update+ ,
                add+, value=dummy)
               dummy="coeffs = 1.0009, 0.0441, 1.416"
               hedit ("tempa", fields="LINCOR2", verify-, show-, update+ ,
                add+, value=dummy)
               print(s1//' CORRECTED WITH IRS LINEARITY COEFFS')

	    }  else if (instrum =="OSIRIS"){

#               if (osirlin == yes) {
#                 linfits ("tempa.fits" , "tempb.fits") 
#                 imdel ("tempa")
#                 imrename ( "tempb" , "tempa" )
#               } else {
	         irlincor (input="tempa", output="tempa", coeff1=1.00108,
                           coeff2=-3.3284e-2, coeff3=0.166216, 
                           coeff4=-6.84406e-2)
#               }
               print(s1//' CORRECTED WITH OSIRIS LINEARITY COEFFS')
               dummy="CORRECTED WITH OSIRIS LINEARITY COEFFS"
               hedit ("tempa", fields="LINCOR", verify-, show-, update+ ,
                add+, value=dummy)
               dummy="coeffs = 1.00108, -3.3284e-2, 0.166216, -6.84406e-2"
               hedit ("tempa", fields="LINCOR2", verify-, show-, update+ ,
                add+, value=dummy)

	    }  else if (instrum =="ISPI") {
               hselect("tempa","COADDS,NCOADDS","yes") | scan norm
	       if (norm==0.0) {norm = 1.0}
               imar ("tempa" , "/" , norm , "tempa")		
               irlincor (input="tempa", output="tempa", 
			 coeff1=0.99518, coeff2=0.052710843,
                         coeff3=-0.035185486, coeff4=0.052296438)
               dummy="CORRECTED WITH ISPI LINEARITY COEFFS"
               hedit ("tempa", fields="LINCOR", verify-, show-, update+ ,
                add+, value=dummy)
               dummy="coeffs = 0.99518, 0.052710843, -0.035185486, 0.052296438"
               hedit ("tempa", fields="LINCOR2", verify-, show-, update+ ,
                add+, value=dummy)
               print(s1//' CORRECTED WITH ISPI LINEARITY COEFFS')
               imar ("tempa" , "*" , norm , "tempa")		

            }  else {
                 print(s1//' NOT CORRECTED WITH LINEARITY COEFFS')
                 print('NO LINEARITY COEFFS AVAILABLE FOR '//instrum) 
            }
          } else {
	    print(s1//' NOT CORRECTED WITH LINEARITY COEFFS')
	  }
#
# normalize by exposure time. Add more key words as necessary for new 
# instruments.
#
        if (itime == yes) {
          if (mef) {
	    hselect("tempa"//"[0]","EXPTIME,INTTIME,INT_S","yes") | scan norm
          } else {
            hselect( "tempa" , "EXPTIME,INTTIME,INT_S" , "yes") | scan norm
	  }
          if (norm == 0) {
            print "No Exp Time Key Word found. Image not divided by exptime"
          } else {
            imarith("tempa" , "/", norm, "tempa")
            dummy="image divided by "//norm//" sec"
            print (dummy)
	    hedit ("tempa", fields="NORMAL", verify-, show-, update+ ,
                add+, value=dummy)
          }
        }
#
#  multiply by coadds (useful for dophot)
#
        if (mcoadds == yes) {
          if (mef) {
            hselect("tempa"//"[0]","COADDS,NCOADDS","yes") | scan norm
          } else {
            hselect( "tempa" , "COADDS,NCOADDS" , "yes") | scan norm
          }
          if (norm == 0) {
	    print "No COADD Key Word found. Image not multiplied by coadds"
          } else {
            imarith("tempa" , "*", norm, "tempa")
            dummy="image multiplied by "//norm//" coadds"
            print (dummy)
	    hedit ("tempa", fields="NORMAL1", verify-, show-, update+ ,
                 add+, value=dummy)
          }
       }
#
#  divide by coadds
#
        if (dcoadds == yes) {
          if (mef) {
            hselect("tempa"//"[0]","COADDS,NCOADDS","yes") | scan norm
          } else {
            hselect( "tempa" , "COADDS,NCOADDS" , "yes") | scan norm
          }
          if (norm == 0) {
            print "No COADD Key Word found. Image not divided by coadds"
          } else {
            imarith("tempa" , "/", norm, "tempa")
            dummy="image divided by "//norm//" coadds"
            print (dummy)
            hedit ("tempa", fields="NORMAL2", verify-, show-, update+ ,
                 add+, value=dummy)
          }
       }
#
# Fix bad pixels. The mask has badpix=1 and good=0. maskbad.cl will produce
# an appropriate mask.  For fixfits, the image names must include ".fits"
#
	if (image=="fits") {

	  if (access (mask//".fits")) mask = mask//".fits"

	  if (access (mask)) {
            if (interp == "x")  { 
              print("fixing bad pixels, INTERP=X")
              fixfits (mask, "tempa.fits", s1//"n.fits", 0)
        
            } else if (interp == "xy") {
              print("fixing bad pixels, INTERP=XY")
              fixfits (mask, "tempa.fits", s1//"n.fits", 1)

            } else {
              print("No bad pixels fixed")
              imrename ("tempa", s1//"n") 
            }
	    hedit(s1//"n.fits" , add+ , fields="BPM" , value=mask , verify- , 
		  show-, update+)
          } else {  
            print("Warning, NOT fixing bad pixels")
            imrename ("tempa", s1//"n") 
	  }
        } else { 

	  if (access (mask//".imh")) mask = mask//".imh"

	  if (access (mask)) {

            if (interp == "x")  {
              print("fixing bad pixels, INTERP=X")
              fixbad (mask, "tempa", s1//"n", 0)

            } else if (interp == "xy") {
              print("fixing bad pixels, INTERP=XY")
              fixbad (mask, "tempa", s1//"n", 1)

            } else {
              print("No bad pixels fixed")
              imrename ("tempa", s1//"n")
            }
	    hedit(s1//"n" , add+ , fields="BPM" , value=mask , verify- ,
                  show-, update+)
          } else {
            print("Warning, NOT fixing bad pixels")
            imrename ("tempa", s1//"n")
	  }
	}
#
# divide by a flat if desired
#
        if ( div == "yes" ) {

	  if (access(dome) || access (dome//".fits")) {
            print("Dividing by flat = "//dome)
	    print " "
            imarith(s1//"n" , "/", dome,  s1//"n")
	    hedit (s1//"n", fields="DOMEF", verify-, show-, update+ ,
                add+, value=dome)
	    dimage=dome
	  } else { 
	    print ("Flat image, "//dome//", does not exist")
          }
        } else if (div=="header") {

	  if (instrum == "OSIRIS") {
	    hsel (s1//"n", expr=yes, fields="FILTERID") | scan filt
	  } else if (instrum == "ISPI") {
	    hsel (s1//"n", expr=yes, fields="FILTNAME") | scan filt
	  } else {
	    hsel (s1//"n", expr=yes, fields="FILTER") | scan filt
	  }

	  dimage=dome//"d"//filt//"f"
	  print "dome flat image is "//dimage

	  if (access(dimage//".fits") || access(dimage//".imh")) {
            print("Dividing by flat = "//dimage)
	    print " "
            imarith(s1//"n" , "/", dimage,  s1//"n")
            hedit (s1//"n", fields="DOMEF", verify-, show-, update+ ,
                add+, value=dimage)
          } else {
	    print ("Flat Image,"//dimage//", does not exist")
	  }
	}

#
# flip images in x and/or y
#
	if (flipx) {
		print("Flipping image in X")
		imcopy (s1//"n"//"[-*,*]" , s1//"n" , ver-)
	}

	if (flipy) {
		print("Flipping image in Y")
		imcopy (s1//"n"//"[*,-*]" , s1//"n" , ver-)
	}
#
# Add keyword EPOCH for wcs tools
#
	hsel (s1//"n", expr=yes, fields="EQUINOX") | scan dummy

	if (dummy !="") {
	   hedit (s1//"n", fields="EPOCH", verify-, show-, update+ , add+, 
                  value=dummy)
        } else {
	   hedit (s1//"n", fields="EPOCH", verify-, show-, update+ , add+,
	         value="'2000.0 '")
	} 
#
# Add GAIN and RN keywords
#
	hedit  (s1//"n",fields="GAIN",verify-,show-,update+,add+, value=gain)
	hedit  (s1//"n",fields="READNOI",verify-,show-,update+,add+, value=rn)
	hselect(s1//"n", "COADDS,NCOADDS" , "yes") | scan norm

	if (norm==0) {norm = 1.0}

#
# This is for ISPI or some other non-specific imager. ISPI images are summed over coadds, not averaged.
#
	if (dcoadds == yes) {
	   hedit (s1//"n",fields="GAIN_EFF",verify-,show-,update+,add+, value=gain*norm)
	   hedit (s1//"n",fields="READ_EFF",verify-,show-,update+,add+, value=rn*sqrt(norm))
	}
#
# OSIRIS, CIRIM, and IRS are averaged over coadds when the image is taken, so we adjust the gain here automatically. If coadds=1, then the eff gain is the same.
#
	if (instrum == "OSIRIS" || instrum == "IRS" || instrum == "CIRIM") {
           hedit (s1//"n",fields="GAIN_EFF",verify-,show-,update+,add+, value=gain*norm) 
	   hedit (s1//"n",fields="READ_EFF",verify-,show-,update+,add+, value=rn*sqrt(norm))
        }
#
# If we normalized by the itime, then account for this in the eff gain on the resultant image. For ISPI, it is assumed that dcoadds=yes if normalizing by the itime (or ncoadds=1).
#
	if (itime == yes) {
	  hselect(s1//"n" ,"EXPTIME,INTTIME,INT_S","yes") | scan norm2
	  hedit (s1//"n",fields="GAIN_EFF",verify-,show-,update+,add+, value=gain*norm*norm2)
	}

#
# post process cleaning 
#
        clearim ("tempa")
        clearim ("tempb")

        goto nextimage 

        notfound: print ("file "//s2//" does not exist") 
        nextimage: 
#
# end of the image for loop
#
      }
#
# Make weight image for swarp
#
      if (mkswarp == yes) {
	clearim (dimage//"weight")
        if (access(dimage//".fits") || access(dimage//".imh")) {
           if (access(mask2//".fits")) {
              imarith (mask2 , "*" , dimage , dimage//"weight" )
              if (flipy) {imcopy(dimage//"weight"//"[*,-*]", dimage//"weight" , ver-)}
              if (flipx) {imcopy(dimage//"weight"//"[-*,*]", dimage//"weight" , ver-)}
           } else {
              print ("mask2"//" does not exist, no weight image produced")
           }
        } else {
            print ("no dome image exists to make swarp weight image")
        } 
      }
finished:
}
end
