# $Header: /home/pros/xray/xplot/RCS/tvimcontour.cl,v 11.0 1997/11/06 16:38:44 prosb Exp $
# $Log: tvimcontour.cl,v $
# Revision 11.0  1997/11/06 16:38:44  prosb
# General Release 2.5
#
# Revision 9.1  1997/04/24 18:01:02  prosb
# JCC (4/24/97) - add 6 new parameters for IRAF2.11/display :
#                    bpmask,bpdisplay,bpcolors,overlay,ocolors,zmask
#               - rename nsample_line to nsample and change the default
#                 from 512 to 1000
#
#Revision 9.0  1995/11/16  19:08:22  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:17  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/15  11:53:38  janet
#jd - added color B.
#
#Revision 7.0  93/12/27  18:47:39  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:06  prosb
#General Release 2.2
#
#Revision 5.1  93/05/10  15:50:20  janet
#jd - changed gridpars to wlpars pset.
#
#Revision 5.0  92/10/29  22:34:17  prosb
#General Release 2.1
#
#Revision 4.0  92/05/03  23:31:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.5  92/05/03  23:29:22  prosb
#Pre 2.0 Release checkin.
#
#Revision 3.4  92/03/23  16:52:51  janet
#changed nsample_lines from default of 5 to 512.
#
#Revision 3.3  92/01/15  12:55:35  janet
#added wcspars pset to tv.  Also added zrange to param list.
#
#Revision 3.2  92/01/15  10:35:59  janet
#*** empty log message ***
#
#Revision 3.1  91/08/16  11:03:20  mo
#Fix RCS comment character
#
#;;; Revision 3.0  91/08/02  01:23:28  prosb
#;;; General Release 1.1
#;;; 
# -----------------------------------------------------------------------
# Module:	tvimcontour.cl
# Description:  Tvimcontour runs display and imcontour and writes output
#               to the image display device.  This version in xplot calls
#               the imcontour task that plots the sky using the wcs  
# -----------------------------------------------------------------------
procedure tvimcontour(image,map_type,units,clevel)
#
#  Parameters for the Imcontour task
#
# -- Imcontour Params -
 string image    {"",prompt="IRAF image filename",mode="a"}
 string map_type {"sky",min="sky|pixel", prompt="Grid type", mode="a"}
 string units  {"peak",min="pixel|peak|sigma", prompt="Contour Units",mode="a"}
 string clevel {"log 5 100 5", prompt="Contour Levels",mode="a"}
 string gcolor {"r",min="r|y|b|g|w|B", prompt="Contour Graphics Overlay Color - r|y|b|g|w",mode="h"}
 string error_image {"",prompt="IRAF error image filename", mode="a"}
 pset wlpars {prompt="World coordinate system labeling parameter",mode="h"}
 int  display     {2,min=0,max=5,prompt="Display level",mode="h"}
 bool dotitle     {yes, prompt="Label Plot with a Title?",mode="h"}
 bool dolegend    {yes, prompt="Label Plot with a Legend?",mode="h"}
 string src_list  {"none",prompt="SRC Position List",mode="h"}
 string racol     {"ra",prompt="RA table Column Name",mode="h"}
 string deccol    {"dec",prompt="DEC table Column Name",mode="h"}
 string isystem   {"", prompt="Input Coordinate System", mode="h"}
 string src_mark  {"+#",prompt="SRC Marker - char|#|char#",mode="h"}
 string pixgrid   {"full",prompt="Pixel Map Grid Lines- FULL|TICS|NONE",mode="h"}
 string pixlabels {"in",min="in|none",prompt="Pixel Map Grid Labels - IN|NONE",mode="h"}
 int    pixel_lines  {10, prompt="Number of Pixel Map Lines",mode="h"}
#
# -- Wlpars Params --
 bool labout {no, prompt="Draw wcs labels outside axes?", mode="h"}
#
# -- Display Params --
 bool zrange {yes, prompt="display full image intensity range", mode="h"}
 real z1 {0.0, prompt="minimum greylevel to be displayed", mode="h"}
 real z2 {30.0, prompt="maximum greylevel to be displayed", mode="h"}
 string ztrans {"linear",prompt= "greylevel transformation (linear|log|none)", mode="h"} 
 string mode       {"ql", prompt="", mode="h"}

begin
 
    string  clev	# Contour levels 
    string  color       # drawing color
    string  cunits      # Contour level units - pixel | peak | sigma
    string  eimg	# Error Image filename
    string  img		# Image filename
    string  mtype 	# Contour level units
    string  sdevice
    string  gdevice

#  Check if display & imcontour task are defined
    if ( !deftask("display") )
       error(1, "Requires images/tv to be loaded for display task!")
    if ( !deftask("imcontour") )
       error(1, "Requires xray/xplot to be loaded for imcontour task!")

    img = image
    mtype = map_type
    cunits = units
    clev = clevel
    color = gcolor

#  Set the image graph device based on the color chosen
    if ( color == "y" ) {
       sdevice="imdy"
       gdevice="imdy"
    } else if ( color == "r" ) {
       sdevice="imdr"
       gdevice="imdr"
    } else if ( color == "b" ) {
       sdevice="imdb"
       gdevice="imdb"
    } else if ( color == "g" ) {
       sdevice="imdg"
       gdevice="imdg"
    } else if ( color == "w" ) {
       sdevice="imdw"
       gdevice="imdw"
    } else if ( color == "B" ) {
       sdevice="imdB"
       gdevice="imdB"
    } else {
       sdevice="imd"
       gdevice="imd"
    } 


#  Get error image filename if sigma chosen for contour units.
    if ( (cunits == "sigma") || (cunits == "SIGMA") ) {
       eimg = error_image
    } else {
       eimg = ""
    }

# Display the image in the Image Windo
#
    display (img, 1, 
       bpmask="BPM", bpdisplay="none", bpcolors="red", overlay="",
       ocolors="green", 
       erase=yes, border_erase=no, select_frame=yes, 
       repeat=no, fill=yes, zscale=no, contrast=0.25, zrange=zrange, 
       zmask="", 
       nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., 
       xmag=1., ymag=1., order=0, z1=z1, z2=z2, ztrans=ztrans, 
       lutfile="")

    #display (img, 1, erase=yes, border_erase=no, select_frame=yes, 
      #repeat=no, fill=yes, zscale=no, contrast=0.25, zrange=zrange, 
      #nsample_line=512, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., 
      #xmag=1., ymag=1., order=0, z1=z1, z2=z2, ztrans=ztrans, 
      #lutfile="")
#
# Overlay the contours in the Image Windo
#
    imcontour (img, mtype, cunits, clev, eimg, display=display,  
             scale=0.0, xy_scale_rat=1.0, dotitle=dotitle, dolegend=dolegend, 
             perim=no, src_list=src_list, racol=racol, deccol=deccol, 
             isystem=isystem, src_mark=src_mark, 
             pixgrid=pixgrid, pixlabels=pixlabels, pixel_lines=pixel_lines, 
             graph_device=gdevice, scale_device=sdevice, 
             gclose=yes, cursor="", labout=labout)
#             interactive=no, dolabel=dolabel, labout=no, 
#             major_grid=major_grid, minor_grid=minor_grid) 
   
end
