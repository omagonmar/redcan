#$Header: /home/pros/xray/ximages/RCS/imcompress.cl,v 11.0 1997/11/06 16:28:19 prosb Exp $
#$Log: imcompress.cl,v $
#Revision 11.0  1997/11/06 16:28:19  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:41:49  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:25:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:03:28  prosb
#General Release 2.2
#
#Revision 5.1  93/04/29  17:20:40  mo
#MC	4/29/93		Make ERROR parameters hidden and defaulted to NONE
#
#Revision 5.0  92/10/29  21:25:51  prosb
#General Release 2.1
#
#Revision 4.1  92/10/23  09:42:00  mo
#MC	10/24/92	Replace our imcompress with IRAF blkavg
#
#Revision 2.1  91/07/24  20:46:23  mo
#MC	7/24/91		Update the imcompress task to use IMAGES/BLKAVG
#			to get the correct MWCS
#
#Revision 2.0  91/03/06  23:48:47  pros
#General Release 1.0
#
procedure compress(image,outimage,cfactor)
    string	image    {prompt="Input Image name",mode="a"}
    string	outimage { prompt="Output Image name",mode="a"}
    int		cfactor  { min=1, prompt="Compress Factor",mode="a"}
    string	error    { "NONE",prompt="Input Error Image name",mode="h"}
    string	outerror { "NONE",prompt="Output Error Image name",mode="h"}
    bool	clobber  { no, prompt="Delete existing output file?",mode="h"}

    begin

	bool    doerr
	bool    clob
       	string	buf
       	string	img
       	string	name
       	string	oimg
       	string	err
       	string	oerr
       	int     cmprs	

	doerr = yes
       	img =   image
  	oimg =  outimage
	cmprs = cfactor
	err =   error
	clob = clobber

#   make sure packages are loaded
        if ( !deftask ("blkavg") )
          error (1, "Requires images to be loaded!")

#  Build default output filenames

	_rtname(img,oimg,".imh")
	oimg = s1

	_rtname(img,err,"_err.imh")
        err = s1
	if ( err == "NONE" ) {
	      doerr = no
	} else {
	      oerr = outerror
	}
	;

	if( access(oimg) && !clob )
	    error(1,"Output file already exissts!!" )
	else  if (access(oimg) && clob )
	    delete(oimg)

	buf = "Compressing Image "// img //" by factor of "// cmprs
	print( buf )
	blkavg (img, oimg , cmprs, cmprs, cmprs, cmprs, cmprs, cmprs, cmprs, 
	        option = "sum")

	if ( doerr ) {
	    buf = "Compressing Error "// err //" by factor of "// cmprs
	    print( buf )
	    if( access(oerr) && !clob )
	        error(1,"Output file already exists!!" )
	    else  if (access(oerr) && clob )
	        delete(oerr)

	blkavg (err, oerr, cmprs, cmprs, cmprs, cmprs, cmprs, cmprs, cmprs, 
	        option = "sum")
	}
	;
end
