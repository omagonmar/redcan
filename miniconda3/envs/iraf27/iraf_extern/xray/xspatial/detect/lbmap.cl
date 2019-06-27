# $Header: /home/pros/xray/xspatial/detect/RCS/lbmap.cl,v 11.0 1997/11/06 16:32:41 prosb Exp $
# $Log: lbmap.cl,v $
# Revision 11.0  1997/11/06 16:32:41  prosb
# General Release 2.5
#
# Revision 9.1  1997/02/28 21:27:50  prosb
# JCC(2/28/97) - add the package name to imcalc.
#
#Revision 9.0  1995/11/16  18:50:18  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:11:42  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/15  15:51:33  janet
#jd - updated to reflect soft/hard/broad limit updates.
#
#Revision 7.0  93/12/27  18:35:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:13:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:33:36  prosb
#General Release 2.1
#
#Revision 1.1  92/10/07  11:14:49  janet
#Initial revision
#
#
# Module:       lbmap.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      generates a local bkgd map and variance map
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version -- Oct 92
#               {n} <who> -- <does what> -- <when>
# ------------------------------------------------------------------------------
#	LBMAP generates a local bkgd map and variance map
# ------------------------------------------------------------------------------
#
#       The steps are:
#		a.  The Image is convolved using a 3x3 cell size
#       	b.  The Image is convolved using a 5x5 cell size
#		c.  A background map is computed using the bmap eq below
#       	d.  A variance map is computed using the vmap eq below
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
#   imcalc eq with alpha, beta - bmap and vmap are computed only for interest
#
#   bmap.imc:
#   bmap = (alpha * cell5 - beta * cell3) / (2.77777 * alpha - beta)
#
#   vmap.imc:
#   vmap = (alpha**2*cell5+beta*cell3*(beta-2*alpha))/(2.77777*alpha-beta)**2
#
# ------------------------------------------------------------------------------
procedure lbmap(image,outimg)

 file	image   { prompt="Input xray image (output of cellmap)", mode="a"}
 file	outimg  { prompt="Output bkmap image [root_bkd.imh]", mode="a"}
 real   alpha   { 0.0, prompt="alpha ", mode="h"}
 real   beta    { 0.0, prompt="beta ", mode="h"}
 bool   clobber { no, prompt="OK to overwrite existing output file?",mode="h"}

begin
 
    bool    	clob

    file	img
    file        simg
    file	bimg
    file	vimg

    real        a
    real        b

    string      bcalc
    string      cbkg
    string      csrc
    string	cmin
    string	cmax
    string  	instrum
    string  	mission
    string      csize
    string      vcalc
    string      buf

#   The following are referenced in the imcalc equations
#
    string 	cell3   = 'cell3'
    string 	cell5   = 'cell5'
    string	bmap 	= 'bmap'
    string	vmap 	= 'vmap'

#   check if convolve and imcalc tasks are defined
#
    if( !deftask("images") )
       error(1, "Requires images to be loaded!")
    if( !deftask("ximages") )
       error(1, "Requires ximages to be loaded!")

#   Get i/o file params
#
	img	= image
	simg    = outimg
        clob    = clobber

#   Check if we can overwrite file if it exists
#

#   Only make the bmap and vmap if user chose to ... no longer used
#   in snrmap calculation
       _rtname (simg, "", "_bkd.imh")
       bimg = s1
       if ( access(bimg) ) {
          if ( clob ) {
             imdel (bimg)
          } else {
             error (1, "Clobber = NO & Output BMAP file exists!")
          }
       }

       _rtname (simg, "", "_var.imh")
       vimg = s1
       if ( access(vimg) ) {
          if ( clob ) {
             imdel (vimg)
          } else {
             error (1, "Clobber = NO & Output VMAP file exists!")
          }
      }   

#   Retrieve Telescope and Instrument identifier from input header.
#   --- We know about ROSAT HRI, PSPC and EINSTEIN HRI, IPC.
#
    imgets (image=img, param="telescope")
    mission = imgets.value
        
    imgets (image=img, param="instrument")
    instrum = imgets.value

    if ( instrum == "PSPCB" || instrum == "PSPCC" ) {
        instrum = "PSPC"
    } else if ( instrum == "IPC-1" ) {
        instrum = "IPC"
    }

    imgets (image=img, param="cellsize")
    csize = imgets.value

    # rdf names
    imgets (image=img, param="minpha")
    cmin = imgets.value

    imgets (image=img, param="maxpha")
    cmax = imgets.value

    # pre-rdf names
    if ( cmin == "0" && cmax == "0" ) {
       imgets (image=img, param="xs-minch")
       cmin = imgets.value

       imgets (image=img, param="xs-maxch")
       cmax = imgets.value
    }

    a = alpha
    b = beta

    if ( a == 0.0 || b == 0.0 ) {

#   Assign equations with Ldetect Algebra with appropriate alpha & beta 
#   based on the Mission and Instrument
#
       print ("")
       if ( mission == "ROSAT" && instrum == "HRI" ) {
          if ( csize == "9" ) {
             print "Assigning Alpha & Beta for ROSAT HRI, cellsize 9\" "     
             a = 0684.
             b = 0.954
          } else if ( csize == "12" ) {
             print "Assigning Alpha & Beta for ROSAT HRI, cellsize 12\" "     
             a = 0.867
             b = 0.995
          } else if ( csize == "24" ) {
             print "Assigning Alpha & Beta for ROSAT HRI, cellsize 24\" "     
             a = 0.783
             b = 0.983
          } else if ( csize == "36" ) {
             print "Assigning Alpha & Beta for ROSAT HRI, cellsize 36\" "     
             a = 0.751
             b = 0.975
          } else if ( csize == "48" ) {
             print "Assigning Alpha & Beta for ROSAT HRI, cellsize 48\" "     
             a = 0.753
             b = 0.976
          } else {
	     error (1, "alpha and beta not defined for specified cellsize")
          }

       } else if ( mission == "ROSAT" && instrum == "PSPC" ) {
          if ( csize == "30" ) {
             print "Assigning Alpha & Beta for ROSAT PSPC, cellsize 30\" "     
             a = 0.724
             b = 0.968
          } else if ( csize == "45" ) {
             print "Assigning Alpha & Beta for ROSAT PSPC, cellsize 45\" "     
             a = 0.755
             b = 0.976
          } else if ( csize == "60" ) {
             if ( ( cmin == "11" ) && ( cmax == "41" ) ) {
                print "Assigning Alpha & Beta for ROSAT PSPC soft band cellsize 60\""    
                a = 0.731
                b = 0.970
	     } else if ( ( cmin == "52" ) && ( cmax == "201" ) ) {
                print "Assigning Alpha & Beta for ROSAT PSPC hard band cellsize 60\""    
                a = 0.838
                b = 0.992
	     } else if ( ( cmin == "11" ) && ( cmax == "235" ) ) {
                print "Assigning Alpha & Beta for ROSAT PSPC broad band cellsize 60\""    
                a = 0.838
                b = 0.992
	     } else {

                buf = "pimin = " // cmin // ", pimax = " // cmax
                print (buf)
                print "Assigning DEFAULT Alpha & Beta for ROSAT PSPC broad band cellsize"
                a = 0.838
                b = 0.992
#	        error (1, "No alpha & beta defined for input image")
	     }

          } else if ( csize == "120" ) {
             if ( ( cmin == "11" ) && ( cmax == "41" ) ) {
                print "Assigning Alpha & Beta for ROSAT PSPC Soft band cellsize 120\""    
                a = 0.805
                b = 0.987
	     } else if ( ( cmin == "52" ) && ( cmax == "201" ) ) {
                print "Assigning Alpha & Beta for ROSAT PSPC Hard band cellsize 120\""    
                a = 0.831
                b = 0.991
	     } else if ( ( cmin == "11" ) && ( cmax == "235" ) ) {
                print "Assigning Alpha & Beta for ROSAT PSPC Broad band cellsize 120\""    
                a = 0.831
                b = 0.991

	     } else {
                buf = "pimin = " // cmin // ", pimax = " // cmax
                print (buf)
                print "Assigning Alpha & Beta for ROSAT PSPC Broad band cellsize 120\""    
                a = 0.831
                b = 0.991
#	        error (1, "No alpha & beta defined for input image")
	     }
	  } else {
             error (1,"alpha and beta not defined for specified cellsize")
	  }

       } else if ( mission == "EINSTEIN" && instrum == "IPC" ) {
          if ( csize == "144" ) {
             print "Assigning Alpha & Beta for Einstein IPC, cellsize 144\" "    
             a = 0.883
             b = 1.0
          } else if ( csize == "240" ) {
             print "Assigning Alpha & Beta for Einstein IPC, cellsize 240\" "    
             a = 0.883
             b = 1.0
          } else {
             error (1,"alpha and beta not defined for specified cellsize")
          }
       } else if ( mission == "EINSTEIN" && instrum == "HRI" ) {
          if ( csize == "12" ) {
             print "Assigning Alpha & Beta for Einstein HRI, cellsize 12\" "
             a = 0.623
             b = 0.745
          } else if ( csize == "24" ) {
             print "Assigning Alpha & Beta for Einstein IPC, cellsize 24\" "
             a = 0.774
             b = 0.853
          } else if ( csize == "48" ) {
             print "Assigning Alpha & Beta for Einstein HRI, cellsize 48\" "
             a = 0.882
             b = 0.956
          } else {
             error (1,"alpha and beta not defined for specified cellsize")
          }


       } else {
          error (1,"Unknown Instrument!!")
       }
    }

#   Assign Convolve templates for a 3x3 pixel source area & a 5x5 
#   background area
#
    csrc = "1. 1. 1.; 1. 1. 1.; 1. 1. 1.;"
    cbkg = "1. 1. 1. 1. 1.; 1. 1. 1. 1. 1.; 1. 1. 1. 1. 1.; 1. 1. 1. 1. 1.; 1. 1. 1. 1. 1.;"

#   ---- Here is where we start doing the work ----
#   ---------------------------------------------------------------

#   Sliding detect cell sums are simple convolutions
#

    print "\nConvolving 3x3 cells\n"
    convolve (input=img,output=cell3,kernel=csrc)

    print "Convolving 5x5 cells \n"
    convolve (input=img,output=cell5,kernel=cbkg)
 
#   Substitute alpha and beta into bkmap, varmap equations

    bcalc="bmap=("//a//"*cell5-"//b//"*cell3)/(2.77777*"//a//"-"//b//")" 

    vcalc= "vmap=("//a//"**2*cell5+"//b//"*cell3*("//b//"-2*"//a//"))/(2.77777*"//a//"-"//b//")**2"

    if (access(vmap//".imh"))   imdel(images=vmap)
    if (access(bmap//".imh"))   imdel(images=bmap)

    print ("Calculating a background map with equation:")
    print (bcalc)
    print ("")
    print ("Calculating a variance map with equation:")
    print (vcalc)
    print ("")

    ximages.imcalc(input=bcalc, clobber=yes)
    ximages.imcalc(input=vcalc, clobber=yes)

    imrename(oldnames=bmap,newnames=bimg)
    print "\nWriting Background Map:"
    print (bimg)

    imrename(oldnames=vmap,newnames=vimg)
    print "\nWriting Variance Map:"
    print (vimg)

    if (access(cell3//".imh"))  imdel(images=cell3)
    if (access(cell5//".imh"))  imdel(images=cell5)

end
