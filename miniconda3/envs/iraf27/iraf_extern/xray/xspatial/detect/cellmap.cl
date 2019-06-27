# $Header: /home/pros/xray/xspatial/detect/RCS/cellmap.cl,v 11.0 1997/11/06 16:32:34 prosb Exp $
# $Log: cellmap.cl,v $
# Revision 11.0  1997/11/06 16:32:34  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:10  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:11:25  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:34:48  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  12:59:10  janet
#jd - header name lookup updates for RDF
#
# -----------------------------------------------------------------------------
#  CELLMAP copies a qpoe file into an image to create a file with a 
#  specified cellsize.  Each image pixel represents 1/3 of a detect cell,
#  thus knowing the arcsecs/pixel and the cellsize (in arcsecs) the proper
#  block factor is chosen for the file copied into an image.
# -----------------------------------------------------------------------------
#
procedure cellmap(qpoe,image)

 file   qpoe        {prompt="Input xray Qpoe", mode="a"}
 file   image       {prompt="Output xray image ", mode="a"}
 int    rh_cellsize {prompt="ROSAT HRI Cellsize in arcsecs - 6|9|12|24|36|48",mode="a"}
 int    rp_cellsize {prompt="ROSAT PSPC Cellsize in arcsecs - 30 [h/b]| 45 [s]| 60 [s/h/b]| 120 [s/h/b]",mode="a"}
 int    eh_cellsize {prompt="Einstein HRI Cellsize in arcsecs - 6|9|12|24|48",mode="a"}
 int    ei_cellsize {prompt="Einstein IPC Cellsize in arcsecs - 144 [h/b]| 240 [s]",mode="a"}
 int    cellsize    {prompt="Detect Cellsize in arcsecs",mode="a"}
 string eband       {"broad",prompt="Energy Band",mode="a", min="soft|hard|broad"}
 bool   query       {yes, prompt="param query?", mode="h"}
 bool   clobber     {no, prompt="OK to overwrite exisiting output file?", mode="h"}

begin
 
    bool    	clob
    int         cmin
    int         cmax
    int     	csize
    int         nchans
    file	img
    file	qp
    file    	name
    file    	bname
    string      band
    string  	instrum
    string  	mission	

#   check if imcalc tasks are defined
#
    if ( !deftask("ximages") ) {
       error(1, "Requires ximages to be loaded  !")
    }
    if ( !deftask("images") ) {
       error(1, "Requires images to be loaded !")
    }

#   Get i/o file params
#
    qp   = qpoe 
    img  = image
    clob = clobber

#   Check if we can overwrite file if it exists
#
    _rtname (qp, img, ".imh")
    img = s1
    if (access(img)) {
       if ( clob ) {
          imdel (img)
       } else {
          error (1, "Clobber = NO & Output IMAGE file exists !")
       }
    }

#   Retrieve Telescope and Instrument identifier from input header.  
#   --- We know about ROSAT HRI, PSPC and EINSTEIN HRI, IPC.      
#
#    upqpoerdf (qp, display=0)

    imgets (image=qp, param="telescope")
    mission = imgets.value

    imgets (image=qp, param="instrument")
    instrum = imgets.value

    if ( instrum == "PSPCB" || instrum == "PSPCC" ) {
	instrum = "PSPC"
    } else if ( instrum == "IPC-1" ) {
	instrum = "IPC"
    }

    if ( query ) {

       if ( mission == "ROSAT" && instrum == "HRI" ) { 
          csize = rh_cellsize
       } else if ( mission == "ROSAT" && instrum == "PSPC" ) {
          csize = rp_cellsize
          band = eband
       } else if ( mission == "EINSTEIN" && instrum == "IPC" ) {
          csize = ei_cellsize
          band = eband
       } else if ( mission == "EINSTEIN" && instrum == "HRI" ) {
          csize = eh_cellsize
       } else {
          error (1, "Unknown Mission/Instrument")
       }
    } else {
       csize = cellsize
       band = eband
    }
#
#   Input Detect cellsize based on Mission and Instrument
#   - Based on the cell size, block the input qpoe and copy
#     the data into an image where each image pixel represents
#     1/3 of a detect cell.
 
#   -- Rosat HRI -- 0.5 arcsecs / pix - full image = 8192 pixels; 
#
    if ( mission == "ROSAT" && instrum == "HRI" ) { 
       if ( !( (csize == 6) || (csize == 9)  || (csize == 12) || 
               (csize == 24) || (csize == 36) ||(csize == 48) ) ) {
          error (1, "cell size in arc secs must be 6|9|12|24|36|48")
       } else {
          if ( csize == 6 ) {
             name=qp//"[bl=4][769:1280,769:1280]"
             bname=qp

          } else if ( csize == 9 ) {
             name=qp//"[bl=6][426:937,426:937]"
             bname=qp

          } else if ( csize == 12 ) {
             name=qp//"[bl=8][256:767,256:767]"
             bname=qp

          } else if ( csize == 24 ) {
     	     name=qp//"[bl=16]"
     	     bname=qp

          } else if ( csize == 36 ) {
     	     name=qp//"[bl=24]"
     	     bname=qp

          } else if ( csize == 48 ) {
     	     name=qp//"[bl=32]"
     	     bname=qp

          } else {
      	     error (1,"Wrong cell size specified !!")
          }
       }
#
#   -- Rosat PSPC -- 0.5 arcsecs / pix - full image = 15360 pixels
#   old -->   PI Bins - soft=7-40, hard=41-240, broad=7-240
#   new (in this code) -->   PI Bins - soft=11-41, hard=52-201, broad=11-235
    } else if ( mission == "ROSAT" && instrum == "PSPC" ) {
       if ( band == "soft" ) {
           cmin=11
           cmax=41
       } else if ( band == "hard" ) {
           cmin=52
           cmax=201
       } else if ( band == "broad" ) {
           cmin=11
           cmax=235
       } else {
	   error (1, "band must be soft | hard | broad")
       }
       if ( !( (csize == 30)  || (csize == 45) || (csize == 60) || 
               (csize == 120) ) ) {
          error (1, "cell size in arc secs must be 30|45|60|120")
       } else {
          if ( csize == 45 ) {
             if ( band == "soft" ) {
	        name=qp//"[bl=30,pi="//cmin//":"//cmax//"]"
	        bname=qp//"[pi="//cmin//":"//cmax//"]"
             } else {
      	        error (1,"45 arcsec cell supported for soft band only !!")
             }

          } else if ( csize == 30 ) {
             if ( (band == "hard") || (band == "broad") ) {
	        name=qp//"[bl=20,pi="//cmin//":"//cmax//"][128:639,128:639]"
	        bname=qp//"[pi="//cmin//":"//cmax//"]"
             } else {
      	        error (1,"30 arcsec cell supported for hard|broad !!")
	     }

          } else if ( csize == 60 ) {
             if ( (band == "soft") || (band == "hard") || (band == "broad") ) {
	        name=qp//"[bl=40,pi="//cmin//":"//cmax//"]"
	        bname=qp//"[pi="//cmin//":"//cmax//"]"
             } else {
      	        error (1,"60 arcsec band supported for soft|hard|broad !!")
	     }
       
          } else if ( csize == 120 ) {
             if ( (band == "soft") || (band == "hard") || (band == "broad") ) {
	        name=qp//"[bl=80,pi="//cmin//":"//cmax//"]"
	        bname=qp//"[pi="//cmin//":"//cmax//"]"
             } else {
      	        error (1,"120 arcsec band supported for soft|hard|broad !!")
	     }

          } else {
      	     error (1,"Wrong cell size specified !!")
          }
       }
#
#   -- Einstein IPC -- 8 arcsecs/pix - full image = 1024
#      PI Bins - soft=2-4, hard=5-10, broad=2-10
#      s = 30 pix = 240 as; h = 18 pix = 144 as; b = 18 pix = 144 as
    } else if ( mission == "EINSTEIN" && instrum == "IPC" ) {
       if ( band == "soft" ) {
           cmin=2
           cmax=4
       } else if ( band == "hard" ) {
           cmin=5
           cmax=10
       } else if ( band == "broad" ) {
           cmin=2
           cmax=10
       } else {
	   error (1, "band must be soft | hard | broad")
       }
       if ( !( (csize == 144) || (csize == 240) ) ) {
          error (1, "cell size in arc secs must be 144|240")
       } else {
          if ( csize == 144 ) {
             if ( ( band == "hard" ) || ( band == "broad" ) ) {
                name=qp//"[bl=6,pi="//cmin//":"//cmax//"]"
                bname=qp//"[pi="//cmin//":"//cmax//"]"
	     } else {
	        error (1, "144 arcsec cell defined for hard|broad bands !!")
             }

          } else if ( csize == 240 ) {
	     if ( band == "soft" ) {
                name=qp//"[bl=10,pi="//cmin//":"//cmax//"]"
                bname=qp//"[pi="//cmin//":"//cmax//"]"
             } else {
	        error (1, "240 arcsec cell defined for soft bands !!")
	     }
          } else {
      	     error (1,"Wrong cell size specified !!")
          }
       }
#
#   -- Einstein HRI -- 0.5 arcsecs/pix - full image = 4096 ; 
    } else if ( mission == "EINSTEIN" && instrum == "HRI" ) {
       if ( !( (csize == 6) || (csize == 9 ) || (csize == 12) || 
               (csize == 24) || (csize == 48) ) ) {
          error (1, "cell size in arc secs must be 12|24|48")
       } else {
          if ( csize == 6) {
             name=qp//"[bl=4][256:767,256:767]"
             bname=qp

          } else if ( csize == 9) {
             name=qp//"[bl=6]"
             bname=qp

          } else if ( csize == 12 ) {
             name=qp//"[bl=8]"
             bname=qp

          } else if ( csize == 24 ) {
     	     name=qp//"[bl=16]"
     	     bname=qp

          } else if ( csize == 48 ) {
     	     name=qp//"[bl=32]"
     	     bname=qp

          } else {
      	     error (1,"Wrong cell size specified !!")
          }
       }
#
#   -- Unknown --
    } else {
       error (1, "Unknown Mission/Instrument")
    }

    print(" ")
    imcopy (input=name, output=img)
    hedit (images=img, fields="cellsize", value=csize, add=yes,
           delete=no, verify=no, show=yes, mode="ql")

    if ( ( instrum == "IPC" ) || ( instrum == "PSPC" ) ) {
       nchans=cmax-cmin+1
       hedit (images=img, fields="phachans", value=nchans, add=no,
              delete=no, verify=no, show=no, mode="ql")
       hedit (images=img, fields="minpha", value=cmin, add=no,
              delete=no, verify=no, show=no, mode="ql")
       hedit (images=img, fields="maxpha", value=cmax, add=no,
              delete=no, verify=no, show=no, mode="ql")

       hedit (images=img, fields="xs-chans", value=nchans, add=no,
              delete=no, verify=no, show=no, mode="ql")
       hedit (images=img, fields="xs-minch", value=cmin, add=no,
              delete=no, verify=no, show=no, mode="ql")
       hedit (images=img, fields="maxch", value=cmax, add=no,
              delete=no, verify=no, show=no, mode="ql")
    }

    print (bname)
    s2 = bname

end
