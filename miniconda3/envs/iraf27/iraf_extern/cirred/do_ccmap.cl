procedure do_ccmap (p1, p2)

int    p1         	{prompt="beginning image index"}
int    p2         	{prompt="ending image index"}
string pre	  	{prompt="input image prefix"}
string suf=""     	{prompt="input image suffix, do not include .imh or .fits"}
int    exten=3		{prompt="file extension sequence, 3 or 4 digits"}

begin
	int i
	string s1, cfile

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

          if (access ( s1//suf//".imh") || access ( s1//suf//".fits")) {
	     ccmap (s1//suf//".ccin",s1//suf//".db",images=s1//suf,update+)
	  } else {print (s1//suf//", file does not exist")}

	}

end
