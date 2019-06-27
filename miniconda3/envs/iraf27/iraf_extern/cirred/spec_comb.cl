procedure spec_comb ( p1, p2, pic)

int p1               {prompt="initial index"}
int p2               {prompt="initial index"}
string pic           {prompt="output spectrum name"}
string pre           {prompt="input spectra prefix"}
string suf           {prompt="input spectra suffix, e.g., suf.imh"}
int    exten=4	     {prompt="Digits in image extension (usually 3 or 4)"}
bool   norm=yes      {prompt="normalize spectra before comb, <y|n>"}
string sec           {prompt="input spectra normalization section, e.g. x1:x2"}
bool   cross=no      {prompt="x cor spectra and make pixel shifts? <y|n>"}
string obj_samp="p200-900" {prompt="object sample range for xcor"}
string ref_samp="p200-900" {prompt="reference sample range for xcor"}
bool   fxint=yes     {prompt="interactive cross correlation analysis? <y|n>"}
bool   wt=no         {prompt="weight spectra when combining? <y|n>"}
string comb="average"{prompt="type of imcombine to use"} 
string rejmet="none" {prompt="type of imcombine rejection to use"} 
real   smax=10       {prompt="Max value in combined spectrum, imcomb hthresh"}
real   smin=0        {prompt="Min value in combined spectrum, imcomb lthresh"}
bool   blast=yes     {prompt="imdel the renormalized input spectra? <y|n>"}

begin
	int i
	real shift
	string s1,dummy,tmpl

	clearim ("plist")
	clearim ("weight")
	clearim ( pic )
	clearim ( pic//"sig" )

	if (cross) rv
  
          if ( p1 < 10 ) {
                tmpl = pre//"00"//p1//suf   
		if (exten == 4) tmpl = pre//"000"//p1//suf
          } else if ( p1 < 100 ) {
                tmpl = pre//"0"//p1//suf   
		if (exten == 4) tmpl = pre//"00"//p1//suf
          } else if ( p1 < 1000 ) {
                tmpl = pre//"0"//p1//suf   
                if (exten == 4) tmpl = pre//"0"//p1//suf
          } else {
                tmpl = pre//p1//suf
                if (exten == 4) tmpl = pre//p1//suf
          }

          for ( i = p1 ; i <= p2 ; i += 1) {
          if ( i < 10 ) {
            s1 = pre//"00"//i
            if (exten == 4) s1=pre//"000"//i
          }else if ( i < 100 ) {
            s1 = pre//"0"//i
            if (exten == 4) s1=pre//"00"//i
          } else if (i < 1000) {
            s1 = pre//i
            if (exten == 4) s1=pre//"0"//i
          } else {
            s1 = pre//i
          }

          if ( access ( s1//suf//".imh") || access ( s1//suf//".fits")) {
            if (norm){ 
              normalize (s1//suf , sec) 
	      print ( s1//suf//"nor", >> "plist" )
	    } else {
	      imcopy (s1//suf , s1//suf//"tmp", ver-)
	      print ( s1//suf//"tmp" , >> "plist" )
            }

            if (wt) {
              imstat (s1//suf//"["//sec//"]" , fields="midpt", 
                      upper=INDEF, lower=INDEF, for-, >>"weight")
            }
	    
	    if (cross) {

	      clearim ("fxout.txt")

	      fxcor (s1//suf , tmpl, output="fxout", verbose="stxtonly", 
		     width=7, wincenter=0, continuum="both", apodize=0.2, 
		     osamp=obj_samp, rsample=ref_samp, interac=fxint)

	      fields ("fxout.txt" , fields="") | scan (dummy, dummy,
		     dummy, dummy, dummy, shift)

	      if (norm) {
		imshift (s1//suf//"nor", s1//suf//"nor", -shift, 0)
	      } else {
	        imshift (s1//suf//"tmp", s1//suf//"tmp", -shift, 0)
	      }
	    }
	    
          } else {
            print (s1//suf//".imh or fits does not exist"
          }

        }

	if ( access ( "plist")) {

          if ( wt == yes ) {
            imcombine("@"//"plist",output=pic,comb=comb,weight="@weight",
	        reject=rejmet, lthresh=smin, hthresh=smax)
            mv ("weight", pic//"wt")
            hedit (pic, add+, fields="SPCOMB_WT", ver-, 
                  value="Spectrum Weighted by values in file "//pic//"wt")
          } else { 
            imcombine("@"//"plist", output=pic, comb=comb, reject=rejmet, 
                      lthresh=smin, hthresh=smax) 
	  }

          hedit (pic, add+, fields="SPCOMB", ver-, 
                 value="combined spectrum: "//pre//p1//suf//" - "//pre//p2//suf)

          oned
          splot (pic)
#
# clean up
#
          if(blast) imdel ("@plist")
	  clearim ("plist")
	  clearim ("weight")
	  clearim ("fxout.txt")
	}
end
