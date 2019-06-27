#$Header: /home/pros/xray/ximages/RCS/imreplicate.cl,v 11.0 1997/11/06 16:28:22 prosb Exp $
#$Log: imreplicate.cl,v $
#Revision 11.0  1997/11/06 16:28:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:41:57  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:25:32  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:03:36  prosb
#General Release 2.2
#
#Revision 5.1  93/04/29  17:21:05  mo
#MC	4/29/93		Make ERROR parameters hidden and defaulted to NONE
#
#Revision 5.0  92/10/29  21:25:58  prosb
#General Release 2.1
#
#Revision 4.1  92/10/23  09:42:20  mo
#MC	10/24/92	Replace our imreplicate with IRAF blkrep
#
#Revision 2.1  91/07/24  20:47:01  mo
#MC	7/24/91		Update the imreplicate task to use IMAGES/BLKREP
#			to get the correct MWCS
#
#Revision 2.0  91/03/06  23:48:51  pros
#General Release 1.0
#
procedure replicate (image,outimage,rfactor)
    string	image    {prompt="Input Image name",mode="a"}
    string	outimage {prompt="Output Image name",mode="a"}
    int		rfactor  {min=1, prompt="Replication Factor",mode="a"}
    string	error    {"NONE",prompt="Input Error Image name",mode="h"}
    string	outerror {"NONE",prompt="Output Error Image name",mode="h"}
    bool	clobber  {no, prompt="Delete existing output file?",mode="h"}

    begin

    	bool    doerr
	bool	clob
    	string	buf
    	string	img
    	string	oimg
    	string	err
    	string	oerr
    	int     repl

	clob = clobber
	doerr = yes
        img =   image
	oimg =  outimage
	repl =  rfactor
	err =   error

#  make sure packages are loaded
        if ( !deftask ("blkrep") )
          error (1, "Requires images to be loaded!")

#  Build default output filenames
	_rtname(img, oimg, ".imh")
	oimg = s1

	_rtname(img, err, "_err.imh")
	err = s1
	if ( err == "NONE" ) {
	   doerr = no
	} else { 
	   oerr = outerror
	}
	;

	buf = "Replicating Image " // img // " by factor of " // repl
	print( buf )
	buf = "Writing to output file " // oimg
	print( buf )
        if( access(oimg) && !clob )
            error(1,"Output file already exissts!!" )
        else if (access(oimg) && clob )
            delete(oimg)
	blkrep (img, oimg, repl, repl, repl, repl, repl, repl, repl)

	if( doerr ) {
	    buf = "Replicating Error " // err // " by factor of " // repl
	    print( buf )
	    buf = "Writing to output file " // oerr
	    print( buf )
            if( access(oerr) && !clob )
                error(1,"Output file already exissts!!" )
            else if (access(oerr) && clob )
                delete(oeerr)
            blkrep (err, oerr, repl, repl, repl, repl, repl, repl, repl)
	}
	;
end
