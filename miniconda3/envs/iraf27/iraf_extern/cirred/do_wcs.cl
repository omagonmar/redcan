procedure do_wcs (p1, p2)

int    p1         	{prompt="beginning image index"}
int    p2         	{prompt="ending image index"}
string cat="tmc"	{prompt="Catalog for positions, default is local 2MASS database"}
string pre	  	{prompt="input image prefix"}
string suf=""     	{prompt="input image suffix, do not include .imh or .fits"}
string coordfile="" 	{prompt="pixel coords input file, default: use daofind"}
string pixscale="0.305" {prompt="pixel scale input"}
int    exten=3		{prompt="file extension sequence, 3 or 4 digits"}
int    nstar=150  	{prompt="number of stars to match in catalog for fit to WCS"}
int    order=6		{prompt="order of fit along each axis for WCS"}

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
	     if (coordfile=="") {
		clearim ("temp.dao")
		clearim (s1//suf//".dao")
		daofind (s1//suf, output="temp.dao", verify=no)
		sort ("temp.dao", column=3, rev-, num+, > s1//suf//".dao") 
 		cfile=s1//suf//".dao"
		clearim ("temp.dao")
	      } else {
		cfile=coordfile
	      }
	      print ""
	      print ""
	      print ("imwcs "//"-c " //cat//" -h "//nstar//" -n "//order//" -ed "//cfile//" -o  -p "//pixscale//" -v "//s1//suf//".fits"//" > "//s1//suf//".ccin")
	      print ""
	      print ""
	      clearim (s1//suf//".ccin")		
	      imwcs ("-c", cat, "-h", nstar, "-n",  order, "-ed", cfile , " -o -p", pixscale, "-v",  s1//suf//".fits" , > s1//suf//".ccin")
	  } else {print (s1//suf//", file does not exist")}

	}

end
