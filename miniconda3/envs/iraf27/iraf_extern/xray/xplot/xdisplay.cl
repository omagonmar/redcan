#$Header: /home/pros/xray/xplot/RCS/xdisplay.cl,v 11.0 1997/11/06 16:38:46 prosb Exp $
#$Log: xdisplay.cl,v $
#Revision 11.0  1997/11/06 16:38:46  prosb
#General Release 2.5
#
#Revision 9.2  1997/04/24 15:55:46  prosb
#JCC (4/24/97) - add 6 new parameters for IRAF2.11/display :
#                   bpmask,bpdisplay,bpcolors,overlay,ocolors,zmask
#              - rename nsample_line to nsample and change the default
#                from 512 to 1000
#
#Revision 9.0  1995/11/16  19:08:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:47:48  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:17  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:34:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:10:14  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/03/23  16:47:19  janet
#changed nsample_lines default from 5 to 512.  Better sample for xray data.
#
#Revision 1.1  92/03/23  16:40:02  janet
#Initial revision
#
#Revision 3.1  91/08/16  11:04:56  mo
#Set the correct RCS comment character
#
#;;; Revision 3.0  91/08/02  01:22:38  prosb
#;;; General Release 1.1
#;;; 
# -----------------------------------------------------------------------
# Module:	xdisplay.cl
# Description:  Display an Image to an the image device setting parameter
#               defaults for zrange, zscale, z1 and z2 to values suitable 
#               for xray data 
# -----------------------------------------------------------------------
procedure xdisplay(image)
#
#  Parameters for the Xdisplay task
#
 string image {"", prompt="image to be displayed", mode="a"}
 int  frame   {1, prompt="frame to be written into", mode="h"}
 bool erase   {yes, prompt="erase frame", mode="h"}
 bool border_erase {no, prompt="erase unfilled area of window", mode="h"}
 bool select_frame {yes,prompt="display frame being loaded", mode="h"}
 bool fill   {no,prompt="scale image to fit display window", mode="h"}
 bool zscale {no,prompt="display range of greylevels near median", mode="h"}
 real contrast {0.25,prompt="contrast adjustment for zscale algorithm",mode="h"}
 bool zrange  {yes,prompt="display full image intensity range", mode="h"}
#int  nsample_line {512,prompt="number of sample lines", mode="h"}
 int  nsample {1000,prompt="number of sample pixels", mode="h"}
 real xcenter {0.5,prompt="display window horizontal center", mode="h"}
 real ycenter {0.5,prompt="display window vertical center", mode="h"}
 real xsize {1.,prompt="display window horizontal size", mode="h"}
 real ysize {1.,prompt="display window vertical size", mode="h"}
 real xmag  {1.,prompt="display window horizontal magnification", mode="h"}
 real ymag  {1.,prompt="display window vertical magnification", mode="h"}
 int order {0,prompt="spatial interpolator order (0=replicate,1=line)",mode="h"}
 real   z1 {0.0, prompt="minimum greylevel to be displayed", mode="h"}
 real   z2 {30.0, prompt="maximum greylevel to be displayed", mode="h"}
 string ztrans {"linear", prompt="greylevel transformation (linear|log|none)", mode="h"}
 string zmask {"", prompt="sample mask", mode="h"}
 string lutfile {"",prompt="file containing user defined look up table",mode="h" }
 string bpmask {"BPM", prompt="bad pixel mask", mode="h"}
 string bpdisplay {"none",prompt="bad pixel display(none|overlay|interpolate)", mode="h"}
 string bpcolors {"red", prompt="bad pixel colors", mode="h"}
 string overlay {"", prompt="overlay mask", mode="h"}
 string ocolors  {"green", prompt="overlay colors", mode="h"}
 string mode {"ql",mode="h"}

#
begin
 
    string img		# image file name
 
#  Check if display task is defined
#
    if ( !deftask("display") )
       error(1, "Requires images/tv to be loaded for display task!")

    img = image

# Display the image in the Image Windo
#
    display (img, frame=frame, erase=erase, border_erase=border_erase, 
             bpmask=bpmask, bpdisplay=bpdisplay, bpcolors=bpcolors, 
             overlay=overlay, ocolors=ocolors, 
             select_frame=select_frame, repeat=no, fill=fill, 
             zscale=zscale, contrast=contrast, zrange=zrange, 
             zmask=zmask, 
             nsample=nsample, xcenter=xcenter, ycenter=ycenter, 
             xsize=xsize, ysize=ysize, xmag=xmag, ymag=ymag, order=order, 
             z1=z1, z2=z2, ztrans=ztrans, lutfile=lutfil)
   
#   display (img, frame=frame, erase=erase, border_erase=border_erase, 
#            select_frame=select_frame, repeat=no, fill=fill, 
#            zscale=zscale, contrast=contrast, zrange=zrange, 
#            nsample_line=nsample_line, xcenter=xcenter, ycenter=ycenter, 
#            xsize=xsize, ysize=ysize, xmag=xmag, ymag=ymag, order=order, 
#            z1=z1, z2=z2, ztrans=ztrans, lutfile=lutfil)
   
end
