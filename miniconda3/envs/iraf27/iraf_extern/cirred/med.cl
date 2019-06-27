procedure med (p1, p2, pic)

###############################################################################
# med.cl
# procedure to median combine a set of images with a common "prefix" or base
# name. 
# usage: med n1 n2 outfile
#
# 2007 Feb 26. RDB. Add gembcombine option (gemini+).
###############################################################################

int    p1         {prompt="beginning image index"}
int    p2         {prompt="ending image index"}
string pic	  {prompt="output image"}
string pre	  {prompt="input image prefix"}
string suf=""     {prompt="input image suffix, do not include .imh or .fits"}
bool   proj=no	  {prompt="combine elements of 3 dim (or higher) image? <y|n>"}
string scl="none" {prompt="pre-combine scaling of images"}
string zro="none" {prompt="pre-combine additive zero pt of images"}
string sect="[*,*]" {prompt="stat section for scl, zro"}
string rej_meth="none" {prompt="pixel rejection method, imcombine [none]"}
int    nlo=0      {prompt="number of low pixels to reject with minmaxi [0]"}
int    nhi=0	  {prompt="number of high pixels to reject with minmax [0]"}
real   hsig=3	  {prompt="high sigma for sigclip rejection [3]"}
real   lsig=3     {prompt="low  sigma for sigclip rejection [3]"}
int    exten=4    {prompt="file name extension has 3 or 4 digits? [4] <3|4>"}
bool   gemini=no  {prompt="Gemini MEF images? [no] <yes|no>"}
bool   vardq=no	  {prompt="propagate VAR, DQ in Gemini MEF images? [no] <yes|no>"}
bool   sigim=no   {prompt="create a sigma image? [no] <yes|no>"}

begin
	int i
	string s1
	clearim ("plist")
	clearim ( pic )
	clearim ( pic//"sig" )

	for ( i = p1 ; i <= p2 ; i += 1) {
	  if ( i < 10 ) {
	    if (exten==3) s1 = pre//"00"//i
	    if (exten==4) s1 = pre//"000"//i
	  }else if ( i < 100 ) {
	    if (exten==3) s1 = pre//"0"//i
	    if (exten==4) s1 = pre//"00"//i
	  }else if ( i < 1000) {
	    if (exten==3) s1 = pre//i
	    if (exten==4) s1 = pre//"0"//i
	  } else {
	    s1 = pre//i
	  }

          if ( access ( s1//suf//".imh") || access ( s1//suf//".fits")) 
             { print ( s1//suf, >> "plist" )
			   
	  } else {print (s1//suf//", file does not exist")}

	}

	if ( access ( "plist")) {
	   if (gemini) {
	     gemcombine ("@"//"plist",output=pic,comb="median",scale=scl,
             zero=zro,reject=rej_meth, statsec=sect,nlow=nlo,nhigh=nhi,
             hsigma=hsig,lsigma=lsig,fl_vardq=vardq)
	   } else {
	     if (sigim==yes) {
               imcombine("@"//"plist",output=pic,comb="median",scale=scl, 
               zero=zro,reject=rej_meth, statsec=sect,nlow=nlo,nhigh=nhi,
	       sigma=pic//"sig",hsigma=hsig,lsigma=lsig,project=proj)
             } else {
	       imcombine("@"//"plist",output=pic,comb="median",scale=scl,
               zero=zro,reject=rej_meth, statsec=sect,nlow=nlo,nhigh=nhi,
	       hsigma=hsig,lsigma=lsig,project=proj)
	     }
           }
        }

        clearim ("plist")
end
