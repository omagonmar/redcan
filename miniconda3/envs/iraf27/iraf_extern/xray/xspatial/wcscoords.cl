# $Header: /home/pros/xray/xspatial/RCS/wcscoords.cl,v 11.0 1997/11/06 16:33:39 prosb Exp $
# $Log: wcscoords.cl,v $
# Revision 11.0  1997/11/06 16:33:39  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:37:10  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  14:55:58  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:11  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:10:16  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  09:34:50  mo
#MC	5/20/93		Fix error on 1 of the transformations
#
#Revision 5.0  92/10/29  21:30:36  prosb
#General Release 2.1
#
#Revision 1.1  92/10/23  09:45:40  mo
#Initial revision
#
#
# Module:       wcscoord
# Project:      PROS -- ROSAT RSDC
# Purpose:      Use IRAF WCS to convert between coordinate systems.
# External:     < routines which can be called by applications>
# Description:  This script uses the PROS task SKYPIX to convert between
#		all the combinations of 'physical,logical,world and tv'
#		IRAF coordinates
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC	initial version September 1992
#               {n} <who> -- <does what> -- <when>
#

procedure wcscoords(image,convtype)

file	image	{prompt="IRAF reference image",mode="a"}
int	convtype{min=0,max=12,prompt="code for conversion type",mode="a"}
int	display {3,prompt="display level",mode="h"}
file	infile {"STDIN",prompt="input coordinate list",mode="a"}
file	ofile {"STDOUT",prompt="output coordinate list",mode="h"}
bool	clobber {no,prompt="OK to delete existing file?",mode="h"}

begin
    file img
    file img1
    file img2
    int  type
    file ifil
    file ofil
    bool clob
    int disp
    int endflag = 0

    img = image
    print("  Menu for coordinate conversion " )
    print("  1 = world   -> physical ")
    print("  2 = world   -> tv       ")
    print("  3 = world   -> logical  ")
    print("  4 = physical-> logical  ")
    print("  5 = physical-> world    ")
    print("  6 = physical-> tv       ")
    print("  7 = tv      -> physical ")
    print("  8 = tv      -> world    ")
    print("  9 = tv      -> logical  ")
    print("  10= logical -> physical ")
    print("  11= logical -> world    ")
    print("  12= logical -> tv       ")

    type = convtype
    ifil = infile
    ofil = ofile
    clob = clobber
    disp = display

    if( type == 1 )
    {
	_imgclust(img)
	img1 = img
        skypix ("image", img1, ifil, ofile=ofil, iformat="hours", 
		oformat="hours", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if(type == 2)
    {
        _imgimage(img)
        img1 = s1
#       print(img1)
	skypix ("image", img1, ifil, ofile=ofil, iformat="hours", 
		oformat="hours", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if(type == 3)
    {
        skypix ("image", img, ifil, ofile=ofil, iformat="hours", 
		oformat="hours", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 4)
    {
	_imgclust(img)
	img1 = s1
        skypix (img1, img, ifil, ofile=ofil, iformat="pixels", 
		oformat="pixels", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 5)
    {
	_imgclust(img)
	img1 = s1
        skypix (img1, "image", ifil, ofile=ofil, iformat="pixels", 
		oformat="hours", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 6)
    {
	_imgclust(img)
	img1 = s1
	_imgimage(img)
	img2 = s1
        skypix (img1, img2, ifil, ofile=ofil, iformat="pixels", 
		oformat="pixels", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 7)
    {
	_imgclust(img)
	img1 = s1
	_imgimage(img)
	img2 = s1
        skypix (img2, img1, ifil, ofile=ofil, iformat="pixels", 
		oformat="pixels", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 8)
    {
	_imgimage(img)
	img1 = s1
        skypix (img1, "image", ifil, ofile=ofil, iformat="pixels", 
		oformat="hours", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 9)
    {
	_imgimage(img)
	img1 = s1
        skypix (img1, img, ifil, ofile=ofil, iformat="pixels", 
		oformat="pixels", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 10)
    {
	_imgclust(img)
	img1 = s1
        skypix (img, img1, ifil, ofile=ofil, iformat="pixels", 
		oformat="pixels", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 11)
    {
        skypix (img, "image", ifil, ofile=ofil, iformat="pixels", 
		oformat="hours", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 12)
    {
	_imgimage(img)
	img1 = s1
        skypix (img, img1, ifil, ofile=ofil, iformat="pixels", 
		oformat="pixels", clobber=clob, display=disp, 
		istring="NONE", ostring="NONE")
    }
    else if( type == 0)
    {
	endflag = 1
    }
    else
    {
	error("invalid code")
    }
end
