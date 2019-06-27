# $Header: /home/pros/xray/xplot/RCS/_gproj.cl,v 11.0 1997/11/06 16:37:59 prosb Exp $
# $Log: _gproj.cl,v $
# Revision 11.0  1997/11/06 16:37:59  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:04:31  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:47:22  prosb
#General Release 2.3
#
#Revision 6.1  93/12/17  08:51:18  janet
#jd - updated to match change in sgraph.
#
#Revision 6.0  93/05/24  16:39:46  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:34:07  prosb
#General Release 2.1
#
#Revision 1.1  92/10/19  14:16:56  janet
#Initial revision
#
#
# -----------------------------------------------------------------------
# Module:       gproj.cl
# Description:  calculates and plots x and y projectsions
# -----------------------------------------------------------------------
procedure gproj(image)
#
#  Parameters for Gproj task
#
# -- xdisplay Params -
 string image  {prompt="IRAF image filename",mode="a"}
 string gcolor {"r",min="r|y|b|g|w", prompt="Contour Graphics Overlay Color - r| y|b|g|w",mode="h"}
 string axes   {"b",min="x|y|b",prompt="axes to project -  x|y|b )",mode="h"}
 real   yscale {0.5,min=0.0,max=1.0, prompt="Fraction of display for plot",mode= "h"}
 bool   xlog   { no,min=no,max=yes,prompt="use log not linear xscale",mode="h"}
 bool   ylog   { no,min=no,max=yes,prompt="use log not linear yscale",mode="h"}
 int    xdim   {0, prompt="x-dimension of IMAGE window",mode="h"}
 int    ydim   {0, prompt="y-dimension of IMAGE window",mode="h"}

begin

    string  color       # drawing color
    string  img         # Image filename
    string  gdevice
    string  gfile
    string  outtab
    string  reg
    string  tempname
    real scale
    bool clob
    int ixdim
    int iydim

#  Check if improj & sgraph task are defined
    if ( !deftask("sgraph") )
       error(1, "Requires tables to be loaded for sgraph task!")
    if ( !deftask("improj") )
       error(1, "Requires xspatial to be loaded for improj task!")

    img = image
    color = gcolor
    reg = "field"
    scale = yscale
    clob = yes

#  Set the image graph device based on the color chosen
    if ( color == "y" ) {
       gdevice="imdy"
    } else if ( color == "r" ) {
       gdevice="imdr"
    } else if ( color == "b" ) {
       gdevice="imdb"
    } else if ( color == "g" ) {
       gdevice="imdg"
    } else if ( color == "w" ) {
       gdevice="imdw"
    } else {
       gdevice="imd"
    }

#
#  Calculate the x and y projections
#
    if( access("improj.tab") ){
        if( !clob )
           error(1,"Output file already exists" )
        else
           delete("improj.tab")
    }
    _rtname(img,"improj.tab","_prj.tab")
    outtab = s1
    tempname = "foo"
    _clobname(outtab,tempname,clob)
    tempname = s1
    improj(img,reg,tempname,xdim,ydim,clobber=clob,display=0)
#    pltpar.transpose=no
#    print("temp: " // tempname )
#    print("out: " // outtab)
    _fnlname(tempname,outtab)

    gfile = outtab // " counts_x"
#    print ("tab1: " // gfile)
#    print ("scale: ",scale)
    if( axes == "x" || axes == "b" ){
    sgraph (gfile,errcolumn="none",device=gdevice,append=no, stack=no,
            wl=0., wr=0., wb=0., wt=0., xflip=no, yflip=no, 
            transpose=no, pointmode=no, marker="box", szmarker=0.005, 
            erraxis=0, errtype="bartck", pattern="solid", 
            crvstyle="straight", logx=no, logy=xlog, rejectlog=yes, box=no, 
            ticklabels=no, grid=yes, xlabel=" ", ylabel=" ", 
            title="imtitle", sysid=no, lintran=no, p1=0., p2=0., q1=0., 
            q2=1., left=0., right=1., bottom=0., top=scale, 
            majrx=5, minrx=5, majry=5, minry=5, round=no,margin=0.,fill=no)
    }
    gfile = outtab // " counts_y"
#    print ("tab2: " // gfile)
#    print ("scale: ",scale)
    if( axes == "y" || axes == "b" ){
    sgraph (gfile, errcolumn="none", device=gdevice, append=no, stack=no,
            wl=0., wr=0., wb=0., wt=0., xflip=no, yflip=no,  
            transpose=yes, pointmode=no, marker="box", szmarker=0.005, 
            erraxis=0, errtype="bartck", pattern="solid", 
            crvstyle="straight", logx=ylog, logy=no, rejectlog=yes, box=no, 
            ticklabels=no, grid=yes,xlabel=" ", ylabel=" ", title="imtitle", 
            sysid=no, lintran=no, p1=0., p2=0., q1=0., q2=1., left=0.,
            right=scale, bottom=0., top=1., majrx=5, minrx=5, majry=5, 
            minry=5, round=no, margin=0., fill=no)  
    }
    delete ("improj.tab")
end

