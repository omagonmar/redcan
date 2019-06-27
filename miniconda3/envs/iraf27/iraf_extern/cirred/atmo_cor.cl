procedure atmo_cor (input, standard)

string input	 {prompt="Input spectrum"}
string standard	 {prompt="Standard spectrum"}
real   shift=0	 {prompt="Pixel shift applied to standard"}
string terp="lin"{prompt="Interpolation type for shifting, see imshift"}
bool   xcor=yes	 {prompt="Crosscor input vs standard? yes|no"}
bool   div=yes	 {prompt="Divide by standard spectrum? <y|n>"}
bool   fxint=yes {prompt="Find shift interactively? <y|n>"}
string stdsamp="p250-900" {prompt="sample xcor region for standard"}
string objsamp="p250-900" {prompt="sample xcor region for obj"}
bool   xd=no	 {prompt="Is the spectrum cross-dispersed? yes/no"}
int    norder=2	 {prompt="Orders in XD spec (neg if order dec w/ap number)"}
int    i0=3	 {prompt="Order of 1st spectrum in XD"}
int    xcorap    {prompt="Aperture number for XD xcor"}
string range="*" {prompt="range of pixels to extract from each XD aperture"}
bool   wave=no	 {prompt="Add wpc and w0 wavelength soln to header? <y|n>"}
real   w0	 {prompt="Wavelength of pixel 1"}
real   wpc	 {prompt="Dispersion of order 1, e.g. micron/pixel, can be <0"}
bool   text=no	 {prompt="Make text file spectrum? <y|n>"}

begin 

	real wp,w1
	string dummy

        if(access(standard//".fits") || access(standard//".imh")) {
        } else {
          print ("Standard star spectrum, "//standard//" does not exist")
          bye
        }

        if (access(input//".fits") || access(input//".imh")) {
        } else {
          print ("Object star spectrum, "//input//" does not exist")
          bye
        }
        
	clearim ("s1")
	clearim (input//"n")
	clearim (input//"n.dat")

	if(xcor) {
	  rv
	  clearim ("fxout.txt")

          if (xd) {
            fxcor (input, standard, output="fxout", verbose="stxtonly", 
                 width=7, wincenter=0, continuum="both", apodize=0.2, 
                 osamp=objsamp, rsample=stdsamp, interac=fxint,apert=xcorap)
          } else {
            fxcor (input, standard, output="fxout", verbose="stxtonly",
                 width=7, wincenter=0, continuum="both", apodize=0.2,
                 osamp=objsamp, rsample=stdsamp, interac=fxint)
          }

          fields ("fxout.txt" , fields="") | scan (dummy, dummy,
                     dummy, dummy, dummy, shift)
	}
	
        if (div==yes) {
	  imshift (standard, "s1", shift, 0, interp=terp)
	  imar    (input, "/", "s1", input//"n")
	  hedit (input//"n", add+, ver-, show-, field="ATMO_COR", 
	       value="divided by "//standard//" which was shifted by "//shift)
        } else {
	  imshift (standard, "s1", shift, 0, interp=terp)
	  imar    (input, "*", "s1", input//"n")
	  hedit (input//"n", add+, ver-, show-, field="ATMO_COR", 
	       value="multiplied by "//standard//" which was shifted by "//shift)
        }


	clearim ("s1")
	  if (xd==yes) {
	    if (norder < 0) {
	      for (i=1 ; i <= -norder ; i += 1) {
                clearim ("xdspec")
                imcopy (input//"n["//range//","//i//"]" , "xdspec", ver-)
	        w1=w0 *(i0)/(i0-i+1)
	        wp=wpc*(i0)/(i0-i+1)
                if (wave) {
                  hedit ("xdspec",add+,ver-, show-, field="w0"//i,value=w1)
                  hedit ("xdspec",add+,ver-, show-, field="wpc"//i,value=wp)
                  hedit (input//"n",add+,ver-, show-, field="w0"//i,value=w1)
                  hedit (input//"n",add+,ver-, show-, field="wpc"//i,value=wp)
                }

                if (text==yes) {
                  ctio
                  lambda ("xdspec",start="w0"//i,delt="wpc"//i ,
                          >> input//"n.dat")
                  vi ("+d +d +/image +d +d +:wq ", input//"n.dat")
	        }
              }

	    } else {
	      for (i=1 ; i <= norder ; i += 1) {
                clearim ("xdspec")
                imcopy (input//"n[*,"//i//"]" , "xdspec", ver-)
                w1=w0 *(i0)/(i0+i-1)
                wp=wpc*(i0)/(i0+i-1)
                if (wave) {
                  hedit ("xdspec",add+,ver-, show-, field="w0"//i,value=w1)
                  hedit ("xdspec",add+,ver-, show-, field="wpc"//i,value=wp)
                  hedit (input//"n",add+,ver-, show-, field="w0"//i,value=w1)
                  hedit (input//"n",add+,ver-, show-, field="wpc"//i,value=wp)
                }

                if (text==yes) {
                  ctio
                  lambda ("xdspec",start="w0"//i, delt="wpc"//i, 
                          >> input//"n.dat"
                  vi ("+d +d +/image +d +d +:wq ", input//"n.dat")
                }
              }
	    }
            clearim ("xdspec")
	  } else {

            if (wave) {
              hedit (input//"n",add+,ver-, show-, field="w0",value=w0)
              hedit (input//"n",add+,ver-, show-, field="wpc",value=wpc) 
            }

	    if (text==yes) {
	      ctio
	      lambda (input//"n", >> input//"n.dat") 
              vi ("+d +d +:wq ", input//"n.dat")
	    }
	  }
        if (text) {
          sort (input//"n.dat" , column=1, >> "xdspec" )
          mv   ("xdspec" , input//"n.dat")
        }
        oned
        splot (input//"n")
	clearim ("fxout.txt")
end
