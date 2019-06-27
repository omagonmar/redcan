#$Header: /home/pros/xray/xspatial/RCS/vigmodel.cl,v 11.0 1997/11/06 16:33:38 prosb Exp $
#$Log: vigmodel.cl,v $
#Revision 11.0  1997/11/06 16:33:38  prosb
#General Release 2.5
#
#Revision 9.1  1997/02/28 21:21:59  prosb
#JCC(2/28/97) - add the package name to imcalc.
#
#Revision 9.0  1995/11/16  18:37:08  prosb
#General Release 2.4
#
#Revision 8.1  1994/07/13  14:42:59  janet
#jd - when this task was updated to make errvignimage and errimage hidden,
#the procedure line wasn't updated to remove them...updated now.
#
#Revision 8.0  94/06/27  14:55:55  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:09  prosb
#General Release 2.3
#
#Revision 6.1  93/10/16  01:19:49  dennis
#Changed errimage and errvignimage from auto to hidden.
#
#Revision 6.0  93/05/24  16:10:13  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:30:34  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:34:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:26:43  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:11:21  pros
#General Release 1.0
#
#procedure vigmodel(image,errimage,vignimage,errvignimage,vigncorr)
procedure vigmodel(image,vignimage,vigncorr)
    string	image  { prompt="Input image file" , mode="a"}
    string	errimage  { prompt="Input error image file" , mode="h"}
    string	vignimage { prompt="Output vignetted image file",mode="a"}
    string	errvignimage { prompt="Output vignetted error file",mode="h"}
    string	vigncorr   { prompt="Vignetting corrections mask" , mode="a"}
    bool	clobber { no, prompt="OK to overwrite existing output file?",mode="h"}
begin
    bool 	doerr
    bool 	clob
    string	buf 	# temp buffer for imcalc command string
    string	img	# temp buffer for input image file name
    string	vimg	# temp buffer for output vignetted image file name
    string	vcorr   # temp buffer for vignetting correction file
    string	eimg    # temp buffer for input error file name
    string	evimg	# temp buffer for output error file name
        img=image
	vimg=vignimage
	vcorr = vigncorr
	clob = clobber
	eimg = errimage
	evimg = ""

	_rtname(img,eimg,"_err.imh")
	eimg = s1
	doerr = yes
	if( eimg == "NONE" )
		doerr = no
	else
		evimg = errvignimage

	_rtname(vimg,evimg,"_err.imh")
	evimg = s1

# make sure imcalc is already defined, as packages can't be loaded in scripts!
	if( !deftask("imcalc") )
	    error(1, "Requires imcalc to be loaded!")

	_rtname(img,vcorr,"_vig.pl")
	vcorr=s1

	if( strlen(vimg) == 1 && stridx(vimg,".") == 1 )
	     error(1," . is not a valid output file - explicit name required")
	if( strlen(vimg) == 0 )
	     error(1," NULL is not a valid output file - explicit name required")
# Check for existing output file ( may have been input with or without the .imh
#	extension )
#	if( (access(vimg) || access(vimg//".imh")) && !clob)
#	    error(1,"Output file already exists" )
#	else
# The filenames must be enclosed in quotes to allow use of paths - since
#    IMCALC can't parse the /'s
#	{
	    buf="\""//vimg//"\""//"="//"\""//img//"\""//" / ("//"\""//vcorr//"\""//" * 0.01)**2"
	    print("")
	    print("Applying vignetting correction to image")
            print(buf)
	    ximages.imcalc(buf,clobber=clob,zero=0.,debug=0)
#	    hedit(vimg,"vignetting","true",add=yes,delete=no,verify=no,show=yes,update=yes)
	    xhadd(vimg,type="vignetting",task="imcalc",history=buf)
#	}

# Check for existing output file ( may have been input with or without the .imh
#	extension )
#	if( (access(vimg) || access(vimg//".imh")) && !clob)
#	    error(1,"Output file already exists" )
#	else{
# The filenames must be enclosed in quotes to allow use of paths - since
#    IMCALC can't parse the /'s
	  if( doerr){
	    buf="\""//evimg//"\""//"="//"\""//eimg//"\""//" / ("//"\""//vcorr//"\""//" * 0.01)"
	    print("")
	    print("Applying vignetting correction to error image")
            print(buf)
	    ximages.imcalc(buf,clobber=clob,zero=0.,debug=0)
#	    hedit(vimg,"vignetting","true",add=yes,delete=no,verify=no,show=yes,update=yes)
	    xhadd(evimg,type="vignetting",task="imcalc",history=buf)
	  }
#	}
end
