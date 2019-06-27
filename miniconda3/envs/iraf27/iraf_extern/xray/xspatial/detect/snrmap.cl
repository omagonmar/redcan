# ------------------------------------------------------------------------------
#	SNRMAP generates an image of net counts signal-to-noise 
#       values at detect sub-cell resolution from an input image 
#       of raw counts at the same resolution.  
# ------------------------------------------------------------------------------
#
#       The steps are:
#		a.  The Image is convolved using a 3x3 cell size
#       	b.  The Image is convolved using a 5x5 cell size
#               c.  A frame image (cell5-cell3) is computed
#		d.  The frame image elements with low stats are replaced
#		    with confidence errors for those values.
#       	c.  An snr map is computed using the snrmap eq below 
#
#	cell3.cnv:
#	1. 1. 1.;
#	1. 1. 1.;
#	1. 1. 1.;
#
#	cell5.cnv:
#	1. 1. 1. 1. 1.;
#	1. 1. 1. 1. 1.;
#	1. 1. 1. 1. 1.;
#	1. 1. 1. 1. 1.;
#	1. 1. 1. 1. 1.;
#
# ------------------------------------------------------------------------------
#   frame.imh:
#   frame = (cell5-cell3)
#   
#   snrmap.imc:
#   snrmap = (1.7777*cell3-frame)/((1.7777**2*cell3+oframe)**0.5)
#
#   old equation:
#   snrmap = (2.7777*cell3-cell5)/(((1.7777**2-1)*cell3+cell5)**0.5)
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
procedure snrmap(image,snrimg)

 file	image   { prompt="Input xray image ", mode="a"}
 file	snrimg  { prompt="Output snrmap image [root_snr.imh]", mode="a"}
 bool   clobber { no, prompt="OK to overwrite existing output file?",mode="h"}

begin
 
    bool    	clob

    file	img
    file	simg

    string      cbkg
    string      csrc
    string  	instrum
    string  	mission
    string      fcalc
    string      scalc

#   The following are referenced in the imcalc equations
#
    string 	cell3  = 'cell3'
    string 	cell5  = 'cell5'
    string	frame  = 'frame'
    string	oframe = 'oframe'
    string	snrmap = 'snrmap'

#   Check if convolve and imcalc tasks are defined
#
    if( !deftask("images") )
       error(1, "Requires images to be loaded!")
    if( !deftask("ximages") )
       error(1, "Requires ximages to be loaded!")

#   Get i/o file params
#
	img	= image
	simg    = snrimg
        clob    = clobber

#   Check if we can overwrite file if it exists
#
    _rtname (img, simg, "_snr.imh")
    simg = s1
    if ( access(simg) ) {
       if ( clob ) {
          imdel (simg)
       } else {
          error (1, "Clobber = NO & Output SNRMAP file exists!")
       }
    }

#   Assign Convolve templates for a 3x3 pixel source area & a 5x5 
#   background area
#
    csrc = "1. 1. 1.; 1. 1. 1.; 1. 1. 1.;"
    cbkg = "1. 1. 1. 1. 1.; 1. 1. 1. 1. 1.; 1. 1. 1. 1. 1.; 1. 1. 1. 1. 1.; 1. 1. 1. 1. 1.;"


#   The frame image is the difference of the 5x5 and 3x3 images
     fcalc="frame=cell5-cell3"

#   Assign the equation for the snrmap calculation

     scalc="snrmap=(1.7777*cell3-frame)/((1.7777**2*cell3+oframe)**0.5)"

#   ---- Here is where we start doing the work ----
#   ---------------------------------------------------------------

#   Sliding detect cell sums are simple convolutions
#
    print "\nConvolving 3x3 cells\n"
    convolve (input=img,output=cell3,kernel=csrc)

    print "Convolving 5x5 cells \n"
    convolve (input=img,output=cell5,kernel=cbkg)
 
#   Compute the frame image and replace low counts
#
    ximages.imcalc(input=fcalc, clobber=yes)
    _fixvar(in_image=frame, out_image=oframe, clobber=yes)

#   Compute a SNR map
#
    print "Calculating Snrmap with equation:\n"
    print (scalc)

    ximages.imcalc(input=scalc, clobber=yes)

#   ---------------------------------------------------------------
#   rename temp. image file referenced in .imc file to desired
#   output, remove temp convolve templates, and we're done.
#
    imrename(oldnames=snrmap,newnames=simg)
    print "\nWriting Snrmap Image:"
    print (simg)

    if (access(cell3//".imh"))  imdel(images=cell3)
    if (access(cell5//".imh"))  imdel(images=cell5)
    if (access(frame//".imh"))  imdel(images=frame)
    if (access(oframe//".imh")) imdel(images=oframe)

end
