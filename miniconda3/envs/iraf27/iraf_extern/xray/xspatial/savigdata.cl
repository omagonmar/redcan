#$Header: /home/pros/xray/xspatial/RCS/savigdata.cl,v 11.0 1997/11/06 16:33:27 prosb Exp $
#$Log: savigdata.cl,v $
#Revision 11.0  1997/11/06 16:33:27  prosb
#General Release 2.5
#
#Revision 9.1  1997/02/28 21:17:37  prosb
#JCC(2/28/97) - add the package name to imcalc.
#
#Revision 9.0  1995/11/16  18:35:45  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:55:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:10:04  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:30:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:33:51  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:26:41  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:11:07  pros
#General Release 1.0
#
procedure vigdata(image,vignimage,errimage,errvignimage,vigncorr,back_frac)
    string	image  { prompt="Input image file" , mode="a"}
    string	vignimage { prompt="Output vignetted image file",mode="a"}
    string	errimage  { prompt="Input error image file" , mode="a"}
    string	errvignimage { prompt="Output vignetted error file",mode="a"}
    string	vigncorr   { prompt="Vignetting corrections mask" , mode="a"}
    string	back_frac   { prompt="fraction of image which is non-vign bkgd (x.xx format) ",mode="a"}
    bool	clobber { no, prompt="OK to overwrite existing output file?",mode="h"}
    
begin
    bool	doerr	# flag for doing error array calculation
    string	buf 	# temp buffer for imcalc command string
    string	img	# temp buffer for input image file name
    string	vimg	# temp buffer for output vignetted image file name
    string	vcorr
    string	bfrac   # temp storage for non-vignetted background fraction
    string      eimg    # temp buffer for input error file name
    string	evimg   # temp buffer for ouput error file name

# make sure imcalc is already defined, as packages can't be loaded in scripts!
	if( !deftask("imcalc") )
	    error(1, "Requires imcalc to be loaded!")

# This reassignment will force the correct order for parameter prompting
	img=image
	vimg=vignimage
	vcorr=vigncorr
	bfrac=back_frac
	clob = clobber
	eimg = errimage
	_rtname(img,eimg,"_err.imh")
	eimg = s1
	doerr = yes
	evimg = ""
	if( eimg == "NONE" )
		doerr = no
	else
		evimg = errvignimage

	_rtname(img,vcorr,"_vig.pl")
	vcorr = s1
	_rtname(vimg,evimg,"_err.imh")
	evimg = s1

#  IMCALC requires the leading zero in the decimal fraction - make sure its there ( 0.xx )
	if( stridx(bfrac,".")==1 )
	    bfrac="0"//bfrac
	if( strlen(vimg ) == 1 && stridx(vimg,".") == 1 )
	    error(1," . is not a valid output filename - explicit name required")
	if( strlen(vimg) == 0 )
	    error(1," NULL is not a valid output filename - explicit name required")
# Check for existing output file ( name may have been input with or without
#	the -.imh extension
#	if( (access(vimg) || access(vimg//".imh")) && !clob)
#	    error(1,"Output file already exists" )
#	else
#	{
	    print("Creating vignetted image - " // vimg )
	    buf="\""//vimg//"\""//"="//bfrac//"*"//"\""//img//"\""//"+(1.0-"//bfrac//")*0.01*"//"\""//vcorr//"\""//"*"//"\""//img//"\""
	    print("")
	    print("Applying vignetting to image")
            print(buf)
	    if( access("vigndata.tmp"))
		delete("vigndata.tmp")
# command buffer must be written to temp file or it may get truncated - honest!
	    print(buf , > "vigndata.tmp")
	    ximages.imcalc("vigndata.tmp",clobber=clob,zero=0.,debug=0)
#           hedit(vimg,"vignetting","true",add=yes,delete=no,verify=no,show=yes,update=yes)
	    xhadd(vimg,type="vignetting",task="imcalc",history=buf)
#	}

# Check for existing output error file ( name may have been input with or without
#	the -.imh extension
#	if( (access(evimg) || access(evimg//".imh")) && !clob)
#	    error(1,"Output error file already exists" )
#	else{
	  if( doerr ){
	    print("Creating vignetted error image - " // evimg )
	    buf="\""//evimg//"\""//"="//bfrac//"*"//"\""//eimg//"\""//"+(1.0-"//bfrac//")*0.01*"//"\""//vcorr//"\""//"*"//"\""//eimg//"\""
	    print("")
	    print("Applying vignetting to error image")
            print(buf)
	    if( access("vigndata.tmp"))
		delete("vigndata.tmp")
# command buffer must be written to temp file or it may get truncated - honest!
	    print(buf , > "vigndata.tmp")
	    ximages.imcalc("vigndata.tmp",clobber=clob,zero=0.,debug=0)
#           hedit(vimg,"vignetting","true",add=yes,delete=no,verify=no,show=yes,update=yes)
	    xhadd(evimg,type="vignetting",task="imcalc",history=buf)
	  }
#	}
end

