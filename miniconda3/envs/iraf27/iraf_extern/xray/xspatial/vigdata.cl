#$Header: /home/pros/xray/xspatial/RCS/vigdata.cl,v 11.0 1997/11/06 16:33:37 prosb Exp $
#$Log: vigdata.cl,v $
#Revision 11.0  1997/11/06 16:33:37  prosb
#General Release 2.5
#
#Revision 9.1  1997/02/28 21:20:30  prosb
#JCC(2/28/97) - add the package name to imcalc.
#
#Revision 9.0  1995/11/16  18:37:07  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:55:53  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/04  14:33:26  mo
#MC	2/1/94		Remove the 'non-auto' parameters from the
#			procedure definition (IRAF 2.10.3 complained)
#
#Revision 7.0  93/12/27  18:31:06  prosb
#General Release 2.3
#
#Revision 6.2  93/10/18  20:38:39  dennis
#Gave back_frac a default value ("0.00"), to keep it from sending a bad 
#string to imcalc.
#
#Revision 6.1  93/10/16  01:20:59  dennis
#Changed errimage and errvignimage from auto to hidden.
#
#Revision 6.0  93/05/24  16:10:10  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:30:32  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:33:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/27  11:07:30  mo
#MC	8/27/91		Make sure 'clob' is a defined variable - sometimes
#			the script will balk - but not always
#
#Revision 3.0  91/08/02  01:26:42  prosb
#General Release 1.1
#
#Revision 2.1  91/04/12  15:36:44  mo
#MC	4/12/91		Added default extensions for the input vignetting
#			mask, as well as the output vignetting file.
#			This is a source of possible conflict since the
#			mask has extension _vig.pl and the output file
#			has extension _vig.imh.  pl and imh are almost
#			identical and can be used interchangeably.  Hopefully
#			convention will keep this separate.  For instance,
#			users will be more comfortable with -.imh files.
#
#Revision 2.0  91/03/06  23:11:19  pros
#General Release 1.0
#
#procedure vigdata(image,vignimage,errimage,errvignimage,vigncorr,back_frac)
procedure vigdata(image,vignimage,vigncorr,back_frac)
    string	image  { prompt="Input image file" , mode="a"}
    string	vignimage { prompt="Output vignetted image file [root_vig.imh]",mode="a"}
    string	errimage  { prompt="Input error image file [root_err.imh]" , mode="h"}
    string	errvignimage { prompt="Output vignetted error file",mode="h"}
    string	vigncorr   { prompt="Vignetting corrections mask [root_vig.pl]" , mode="a"}
    string	back_frac   { "0.00", prompt="fraction of image which is non-vign bkgd (x.xx format) ",mode="a"}
    bool	clobber { no, prompt="OK to overwrite existing output file?",mode="h"}
    
begin
    bool	doerr	# flag for doing error array calculation
    bool	clob	# flag for deleting existing file
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
	_rtname(img,vimg,"_vig.imh")
	vimg = s1
#	print( "output file" // vimg)
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
	    buf="\""//evimg//"\""//"="//bfrac//"**2"//"*"//"\""//eimg//"\""//"+((1.0-"//bfrac//")*0.01*"//"\""//vcorr//"\""//")**2"//"*"//"\""//eimg//"\""
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

