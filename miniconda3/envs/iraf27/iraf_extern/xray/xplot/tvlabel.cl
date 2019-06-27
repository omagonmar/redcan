# $Header: /home/pros/xray/xplot/RCS/tvlabel.cl,v 11.0 1997/11/06 16:38:38 prosb Exp $
# $Log: tvlabel.cl,v $
# Revision 11.0  1997/11/06 16:38:38  prosb
# General Release 2.5
#
# Revision 9.1  1997/04/24 18:32:25  prosb
# JCC (4/24/97) - add 6 new parameters for IRAF2.11/display :
#                    bpmask,bpdisplay,bpcolors,overlay,ocolors,zmask
#               - rename nsample_line to nsample
#
#Revision 9.0  1995/11/16  19:08:23  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:20  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:47:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:09  prosb
#General Release 2.2
#
#Revision 5.1  93/05/10  14:14:30  janet
#updated comments, removed imcontour references.
#
#Revision 5.0  92/10/29  22:34:20  prosb
#General Release 2.1
#
#Revision 4.2  92/09/15  17:10:04  mo
#MC	9/15/92		Add the 'getdevdim' call to make this task device
#			independent.
#
#Revision 4.1  92/05/26  14:35:31  mo
#MC	5/26/92		Fix type ( stsdas package was checked and not lists )
#
#Revision 4.0  92/04/27  15:10:02  prosb
#General Release 2.0:  April 1992
#
#Revision 1.6  92/04/13  15:03:34  mo
#MC	4/13/92		Fix the exit message ( from 'q' to cntl-d )
#
#Revision 1.5  92/04/06  17:40:29  mo
#MC	4/6/92		UPdated TVLABEL to call new RIMCURSOR task for
#			hh:mm:ss readout instead of STSDAS/WCSLAB
#
#Revision 1.4  92/04/03  10:16:32  mo
#MC	4/3/92		Updated for correct RIMCURSOR, still trying to get
#			correct 'fill' option
#
#Revision 1.3  92/02/26  16:04:39  mo
#MC	Feb 20, 1992	Update to use 1.2 STSDAS parameter list
#
#Revision 1.2  92/02/19  16:18:54  mo
#MC	2/92		Make the FILL parameter dynamic depending on 
#			input image size
#
#Revision 1.1  92/02/05  11:22:38  mo
#Initial revision
#
# -----------------------------------------------------------------------
# Module:	tvlabel.cl
# Description:  Display an image  with  a  cursor  readback  in  hh:mm:ss
#               dd:mm:ss
# -----------------------------------------------------------------------
procedure tvlabel(image)
#
#  Parameters for the Imcontour task
#
# -- Tvlabel Params -
 string image    {prompt="IRAF image filename",mode="a"}
 string wcs      {"world",prompt="output coordinate system",mode="h"}
 string xwxform  {"%.4H",prompt="Format for x axis readout",mode="h"}
 string xwyform  {"%.4h",prompt="Format for y axis readout",mode="h"}
#
# -- Display Params --
 real z1 {0.0, prompt="minimum greylevel to be displayed", mode="h"}
 real z2 {30.0, prompt="maximum greylevel to be displayed", mode="h"}
 string ztrans {"linear",prompt= "greylevel transformation (linear|log|none)", mode="h"} 
 bool zrange {yes, prompt="display full image intensity range", mode="h"}
 string mode {"ql", prompt="", mode="h"}

begin
 
    string  img		# Image filename
    string  sdevice
    string  gdevice
    int xdim
    int ydim
    int gx
    int gy
    bool tvfill
#    real top
#    real bottom
#    real left
#    real right

#  Check if display & stplot task are defined
    if ( !deftask("display") )
       error(1, "Requires tv/display package to be loaded for display task!")
    if ( !deftask("lists") )
       error(1, "Requires lists to be loaded for rimcursor task!")

#	print("***************************************************************")
#	print("*                                                             *")
#	print("*      W A R N I N G !!!  W A R N I N G !!!                   *")
#	print("*                                                             *")
#	print("*     input files containingg SECTIONS (e.g. [256:512,512:768]*")
#        print("*            will ALWAYS produce                              *")
#	print("*           WRONG ANSWERS !!!!!                               *")
#	print("*	( you must IMCOPY first )                            *")
#	print("*                                                             *")
#	print("***************************************************************")

    img = image

#  Set the image graph device based on the color chosen

# Display the image in the Image Windo
#
# jcc- initialize gx,gy to 1000 which is the
#      default of nsample in display/iraf2.11
        gx = 1000      
        gy = 1000      

	imgets(img,"i_naxis1")
	xdim = int( imgets.value)
	imgets(img,"i_naxis2")
	ydim = int( imgets.value)
	_getdevdim("stdimage")
	gx = x
	gy = y
	if( xdim <= gx || ydim <= gy )
		tvfill = yes
	else
		tvfill = no

    display (img, 1,
       bpmask="BPM", bpdisplay="none", bpcolors="red", overlay="",
       ocolors="green",
       erase=yes, border_erase=no, select_frame=yes,
       repeat=no, fill=tvfill, zscale=no, contrast=0.25, zrange=zrange,
       zmask="",
       nsample=gy, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1.,
       xmag=8., ymag=8., order=0, z1=z1, z2=z2, ztrans=ztrans,
       lutfile="")

    #display (img, 1, erase=yes, border_erase=no, select_frame=yes, 
       #repeat=no, fill=tvfill, zscale=no, contrast=0.25, zrange=zrange, 
       #nsample_line=gy, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., 
       #xmag=.8, ymag=.8, order=0, z1=z1, z2=z2, ztrans=ztrans, 
       #lutfile="")
#
# Call rimcursor for readback from the Image Windo
#
	print ("After the blinking image cursor appears --- ")
	print("Move cursor to object and type 'd' for hh:mm:ss, dd:mm:ss")
	print("     ( Type <cntl-d> (in image window) to quit ) ")


	_imgimage(img)
	img = s1
#	print(img)
	rimcursor(img,wcs="world",wxformat="%.4H", wyformat="%.4h", cursor="")
end
