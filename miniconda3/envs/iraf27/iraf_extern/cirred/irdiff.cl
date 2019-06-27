procedure irdiff (p1, p2)

int    p1         {prompt="beginning image index"}
int    p2         {prompt="ending image index"}
string pic="junk9999"	  {prompt="output image"}
string pre	  {prompt="input image prefix"}
int    exten=4    {prompt="file name extension has 3 or 4 digits? [4] <3|4>"}
bool   stats=no   {prompt="compute image statistics from difference image?"}
real   gain=9.2   {prompt="e-/adu, used in noise calculation"}
string imsec="100:900,100:900" {prompt="image section used in imstat"}

begin
	string s1,s2
	real noise
	clearim ( pic )

	  if ( p1< 10 ) {
	    if (exten==3) s1 = pre//"00"//p1
	    if (exten==4) s1 = pre//"000"//p1
	  }else if ( p1< 100 ) {
	    if (exten==3) s1 = pre//"0"//p1
	    if (exten==4) s1 = pre//"00"//p1
	  }else if ( p1< 1000) {
	    if (exten==3) s1 = pre//p1
	    if (exten==4) s1 = pre//"0"//p1
	  } else {
	    s1 = pre//p1
	  }

	  if ( p2< 10 ) {
            if (exten==3) s2 = pre//"00"//p2
            if (exten==4) s2 = pre//"000"//p2
          }else if ( p2< 100 ) {
            if (exten==3) s2 = pre//"0"//p2
            if (exten==4) s2 = pre//"00"//p2
          }else if ( p2< 1000) {
            if (exten==3) s2 = pre//p2
            if (exten==4) s2 = pre//"0"//p2
          } else {
            s2 = pre//p2
          }

	imar (s1 , "-" , s2 , pic)
	if (stats) {
		imstat (pic//"["//imsec//"]" , fields="mean,stddev,midpt")
		imstat(pic//"["//imsec//"]",fields="stddev",format=no) |scan noise
		print, 'RN = ',noise/sqrt(2)*gain
	}
	display (pic , 2 )
	imexam (pic)

end
