procedure shift_comb (p1, p2, pic)

##########################################################################
# shift_conb.cl
# usage: shift_comb im1 im2 outimage 
#
# Shift and combine a set of images using stsdas.analysis.fourier
# package crosscor to determine the shift. use imshift to make
# a fractional pix shift and imcombine to make the interger pixel shift.
# Uses routines in STSDAS, noao.digiphot.
##########################################################################
#
# 25 may 99. RDB.
# 02 may 00. RDB. Add width (tapwidth) to taper.
# 02 may 00. RDB. Add padding in crrosscor option. Use do_pad=yes if offsets
# are big (~1/2 array).
# 26 Apr 04. RDB. Improve masktype/value for imcombine. 
# 05 Jul 05. RDB. Now clearim old mask file (".pl") 
# 2007 February 27. RDB> Add Gemini wrappers.
##########################################################################

int    p1	 	{prompt="beginning image index"}
int    p2	 	{prompt="ending image index"}
string pre=""	 	{prompt="prefix of input images"}
string suf=""	 	{prompt="suffix of input images"}
string pic	 	{prompt="output image"}
bool   gemini=no 	{prompt="Gemini MEF images? [no] <yes|no>"}
string size="[*,*]"	{prompt="output image size, format=[x1:x2,y1:y2]"}
string image_tem 	{prompt="cc template image"}
string xc_sect="[*,*]"	{prompt="sub image section to use for xcor"}
bool   find=no	 	{prompt="find the cc peak automatically? <yes|no>"}
real   fwhm=3	 	{prompt="fwhm of cc peak, used to find cc peak"}
real   sig=1	 	{prompt="find peaks in power spectrum greater than sig*thresh"}
real   thresh=0.5 	{prompt="find peaks in power spectrum greater than sig*thresh"}
int    tapwidth=10  	{prompt="width (%) to taper in pre-processing taper task"}
bool   do_pad=no 	{prompt="allow image padding in crosscor? <yes|no>"}
bool   save=no 	 	{prompt="save the power spectrum image? <yes|no>"}
string combo="average" 	{prompt="type of combination in imcombine, e.g. median"}
string zshift="none" 	{prompt="type of image flux shift in imcombine, or none"}
string scl="none" 	{prompt="type of image flux scaling in imcombine, or none"}
string rejmet="none" 	{prompt="rejection method for imcombine, or none"}
int    nhi=0   		{prompt="number of hi values to reject with minmax reject"}
int    nlo=0   		{prompt="number of lo values to reject with minmax reject"}
int    shi=3   		{prompt="high sigma value to use with sigclip reject"}
int    slo=3   		{prompt="low sigma value to use with sigclip reject"}
string sect="overlap" 	{prompt="imstat sect in imcomb for scl, sect"}
string pixmask="none" 	{prompt="pixel mask type in imcombine, none, goodval, badval, etc"}
real   mval=1.0       	{prompt="pixel value for pixmask"}
string terp="none" 	{prompt="interp type for fractional pixel shift"}
struct *normal   	{prompt="internal script structure"}

begin
	int i,j,n,n1,n2
        real norm,xfac,refx,refy
        string s1,mask

	clearim ( pic )
	clearim ("tempb")
	clearim ("tempc")
        clearim ( "tempe" )
        clearim ( "tempb.coo" )
 
        clearim ( "plist" )
        clearim ( "plist1" )
        clearim ( "shift_list" )
 
        clearim ( "calc_off.in" )
        clearim ( "calc_off.ot" )
        clearim ( "calc_off.ot1" )
        clearim ( "calc_off.ot2" )

	if (pixmask != "none") {
           if (gemini) {
             hsel (image_tem//"[1]" , "BPM" , yes) | scan mask 
	     clearim (mask//".pl")
           } else {
             hsel (image_tem , "BPM" , yes) | scan mask 
	     clearim (mask//".pl")
           }
	}

        stsdas
        analysis
        fourier

	print ""
	print "starting cross correlation"
	print ""

        if(image_tem=="") {
          print("no cc template specified")
          bye 
	}

        clearim(image_tem//"tap")

        if (gemini==yes) {
          taperedge (image_tem//"[sci]"//xc_sect, image_tem//"tap" , width=tapwidth//" %", func = "cosbell")
        } else {
          taperedge (image_tem//xc_sect, image_tem//"tap" , width=tapwidth//" %", func = "cosbell")
        }

	hsel (image_tem//"tap" , "NAXIS1" , yes ) | scan n1 
	hsel (image_tem//"tap" , "NAXIS2" , yes ) | scan n2 

	refx = n1/2. + 1
	refy = n2/2. + 1

        if (do_pad==yes) {
          refx=n1+1
          refy=n2+1
        }

	for ( i = p1 ; i <= p2 ; i += 1) {

	  if ( i < 10 ) {
		s1 = pre//"00"//i
	  } else if ( i < 100 ) {
		s1 = pre//"0"//i
	  } else {
		s1 = pre//i
	  }

          if (access(s1//suf//".imh") || access(s1//suf//".fits")) {
          print ( s1//suf , >> "plist" ) 
       
          clearim (s1//suf//"_shft")
          clearim ("tempb")
          clearim ("tempb.coo")

          if ( image_tem == s1//suf ) { 
            print(refx,refy, >> "shift_list")
          } else {

            clearim (s1//suf//"tap")
            if (gemini==yes) {
              taperedge (s1//suf//"[sci]"//xc_sect, s1//suf//"tap", width="10 %", func = "cosbell")
            } else {
              taperedge (s1//suf//xc_sect, s1//suf//"tap", width="10 %", func = "cosbell")
            }
 	    print (" ")
 	    print ("beginning xcor of image "//i)
 	    print (" ")

            crosscor ( image_tem//"tap", s1//suf//"tap", "tempb" , pad=do_pad , verbose-)
            print ("done xcor'ing image "//i)
            print (" ")

            imstat("tempb" , field = "max" , format = no) | scan norm

            if (find==yes) {

	      imar ("tempb" , "/", norm, "tempb")
              daofind ("tempb", sigma=sig, threshold = thresh, emission = yes,
                      fwhmpsf=fwhm , output="tempb.coo", verify- )

            } else {

   	      display ("tempb", 1, zsc-,zr+)
#	      if (i==p1) {
                print ""
                print "     This is phot. Place the cursor on the CCF peak"
                print "     and hit the space bar. Then hit q to finish."
	        print ""
                print "     Selecting q before the space bar will interrupt"
                print "     the task."
                print ""
#              }
 	      phot ("tempb", output="tempb.coo", cbox=10,
		       annulus=10, dannulus=5, aper=10, radplot+)
	    }

            clearim ("sort_file")
            clearim ("sort_file1")

            txdump ("tempb.coo", fields = "xcen,ycen,mag[1]",expr="yes", headers=no ,>> "sort_file")

            normal = "sort_file"

            if ( fscan ( normal, xfac ) == EOF ) {
              print("no X-Cor peak found for "//s1//suf)
              bye 
	    }

            sort ("sort_file" , numeric_sort = yes , reverse_sort = yes , column = 3 , > "sort_file1" ) 
            tail ("sort_file1", nlines=1 , >> "shift_list")
	  }
 
	} else {print (s1//suf//", file does not exist")}

	}

	if ( access ( "plist"))  {
          cp ("shift_list", "calc_off.in")
          calc_off			   
          !sed '1,$s/.*/&_shft/' plist > tempe 

	  if (terp != "none") {

	    print("SHIFTING IMAGES WITH "//terp//" INTERPOLATION")
	    imshift ("@plist", "@tempe", shifts_file="calc_off.ot1", interp_type=terp)

            cp ("calc_off.ot", pic//"_off")
            !sed '1,$s/.*/&_shft/' plist > plist1

            if (gemini==yes) {
               gemcombine("@plist1",output=pic,combine=combo,reject=rejmet, scale=scl, offsets="calc_off.ot2", statsec=sect, zero=zshift, masktype=pixmask, maskvalue=mval, nhigh=nhi, nlow=nlo, lsigma=slo, hsigma=shi)
            } else {
               imcombine("@plist1",output=pic,comb=combo,reject=rejmet, scale=scl, offset="calc_off.ot2", statsec=sect, zero=zshift, masktype=pixmask, maskvalue=mval, nhigh=nhi, nlow=nlo, lsigma=slo, hsigma=shi)
            }

	  } else {

	    print("NO FRACTIONAL PIXEL SHIFTS MADE") 
	  
            cp ("calc_off.ot2", pic//"_off")
            if (gemini==yes) {
               gemcombine("@plist",output=pic,combine=combo,reject=rejmet, scale=scl, offsets="calc_off.ot2", statsec=sect, zero=zshift, masktype=pixmask, maskvalue=mval, nhigh=nhi, nlow=nlo, lsigma=slo, hsigma=shi)
            } else {
               imcombine("@plist",output=pic,comb=combo,reject=rejmet, scale=scl, offset="calc_off.ot2", statsec=sect, zero=zshift, masktype=pixmask, maskvalue=mval, nhigh=nhi, nlow=nlo, lsigma=slo, hsigma=shi)
            }
	  }

          if (gemini) {
	     hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC0", value="SHIFTED+COMBINED Image, Images="//p1//"-"//p2)
             hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC1", value="SHIFTED+COMBINED Image, Interpolation="//terp)
             hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC2", value="SHIFTED+COMBINED Image, Imcombine="//comb)
             hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC3", value="SHIFTED+COMBINED Image, Imcombine zero="//zshift)
             hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC4", value="SHIFTED+COMBINED Image, Imcombine scale="//scl)
             hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC5", value="SHIFTED+COMBINED Image, Imcombine statsec="//sect)
             hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC6", value="SHIFTED+COMBINED Image, Imcombine masktyp="//pixmask)
             hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC7", value="SHIFTED+COMBINED Image, xc_sect="//xc_sect)
             if (rejmet=="sigclip") {
               hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC8", value="SHIFTED+COMBINED Image, rejection= sigclip")
               hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC9", value="SHIFTED+COMBINED Image, lsigma="//slo)
               hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC10", value="SHIFTED+COMBINED Image, hsigma="//shi)
             } else if (rejmet=="minmax") {
               hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC8", value="SHIFTED+COMBINED Image, rejection= minmax")
               hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC9", value="SHIFTED+COMBINED Image, nlow="//nlo)
               hedit (pic//"[sci]", add+, ver-, show-, field="SHIFTC10", value="SHIFTED+COMBINED Image, nhigh="//nhi)
             }
          } else {
             hedit (pic, add+, ver-, show-, field="SHIFTC0", value="SHIFTED+COMBINED Image, Images="//p1//"-"//p2)
             hedit (pic, add+, ver-, show-, field="SHIFTC1", value="SHIFTED+COMBINED Image, Interpolation="//terp)
             hedit (pic, add+, ver-, show-, field="SHIFTC2", value="SHIFTED+COMBINED Image, Imcombine="//comb)
             hedit (pic, add+, ver-, show-, field="SHIFTC3", value="SHIFTED+COMBINED Image, Imcombine zero="//zshift)
             hedit (pic, add+, ver-, show-, field="SHIFTC4", value="SHIFTED+COMBINED Image, Imcombine scale="//scl)
             hedit (pic, add+, ver-, show-, field="SHIFTC5", value="SHIFTED+COMBINED Image, Imcombine statsec="//sect)
             hedit (pic, add+, ver-, show-, field="SHIFTC6", value="SHIFTED+COMBINED Image, Imcombine masktyp="//pixmask)
             hedit (pic, add+, ver-, show-, field="SHIFTC7", value="SHIFTED+COMBINED Image, xc_sect="//xc_sect)
             if (rejmet=="sigclip") {
               hedit (pic, add+, ver-, show-, field="SHIFTC8", value="SHIFTED+COMBINED Image, rejection= sigclip")
               hedit (pic, add+, ver-, show-, field="SHIFTC9", value="SHIFTED+COMBINED Image, lsigma="//slo)
               hedit (pic, add+, ver-, show-, field="SHIFTC10", value="SHIFTED+COMBINED Image, hsigma="//shi)
             } else if (rejmet=="minmax") {
               hedit (pic, add+, ver-, show-, field="SHIFTC8", value="SHIFTED+COMBINED Image, rejection= minmax")
               hedit (pic, add+, ver-, show-, field="SHIFTC9", value="SHIFTED+COMBINED Image, nlow="//nlo)
               hedit (pic, add+, ver-, show-, field="SHIFTC10", value="SHIFTED+COMBINED Image, nhigh="//nhi)
             }
          }

          if (size !="[*,*]") {
             if (gemini) {
                imcopy (pic//"[sci]"//size , pic//"[sci,overwrite]", verbose-)
             } else {
                imcopy (pic//size , "tempc", verbose-)
                imdel (pic)
                imrename ("tempc" , pic)
             }
          }

          imdel "*shft.imh"
          imdel "*shft.fits"
          imdel "*tap.imh"
          imdel "*tap.fits"

	  if (save!=yes)
          clearim ( "tempb" )
          clearim ( "tempc" )
          clearim ( "tempe" )
          clearim ( "tempb.coo" )

          clearim ( "plist" )
          clearim ( "plist1" )
          clearim ( "sort_file" )
          clearim ( "sort_file1" )
          clearim ( "shift_list" )

          clearim ( "calc_off.in" )
          clearim ( "calc_off.ot" )
          clearim ( "calc_off.ot1" )
          clearim ( "calc_off.ot2" )

        } else { 
          print("ERROR: no images to combine") 
        }
end
