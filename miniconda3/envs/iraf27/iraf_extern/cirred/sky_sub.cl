procedure sky_sub (p1, p2)

##########################################################################################
# sky_sub.cl
# procedure to make and subtract sky frames.
# usage: sky_sub im1 im2 sky=skyfile 
# 2007 February 27. RDB. Add gemini wrappers.
#
##########################################################################################

int p1             		{prompt= "beginning image index"}
int p2             		{prompt= "ending image index"}
string skyim="sky" 		{prompt= "sky image name"}
string pre         		{prompt= "input image prefix"}
string suf=""         		{prompt= "input image suffix, DO NOT include '.fits', '.imh'"}
bool   gemini=no   		{prompt= "Gemini MEF images? [no] <yes|no>"}
int    exten=4     		{prompt="file name extension has 3 or 4 digits? [4] <3|4>"}
string imscale_typ="none" 	{prompt= "image scale for sky sub: imstat fields or none"}
string imsect="[*,*]"     	{prompt= "section used for imscale_typ"}
string skscale_typ="none" 	{prompt= "type scaling in making sky: imcomb scale or none"}
string sksect="[*,*]" 		{prompt= "section used for skscale_typ"}
string make_sky="yes" 		{prompt= "make sky? yes/no or abba. no=use prev sky image"}
string reject="none"  		{prompt= "type of rejection in imcombine for sky image"}
int nhi=0             		{prompt= "number of hi values or sigma for rejection"}
int nlo=0             		{prompt= "number of lo values or sigma for rejection"}
bool   subtract=yes   		{prompt= "sky sub images? yes/no. no=make sky only"}
string addback="no"   		{prompt= "add back a smooth backgrnd? (no|const|spec)"}
string backsec="[*,*]"		{prompt= "image section to determine smooth background"}
bool   clean=no       		{prompt= "clean? (yes|no). yes=imdel pre*suf images"}

begin
	int i,j
	string a1,b1,b2,a2,s1,image
        real norm, back
	clearim (skyim//"n")

	show imtype | scan image

        if (make_sky == "yes") {

  	  clearim (skyim)

	  if (reject=="minmax") {   
            med (p1, p2, skyim, suf=suf, pre=pre, sect=sksect, scl=skscale_typ,
		rej_met=reject,nhi=nhi,nlo=nlo, ext=exten, gemini=gemini)
	  } else if (reject=="sigclip") {
	    med (p1, p2, skyim, suf=suf, pre=pre, sect=sksect, scl=skscale_typ,
                rej_met=reject,hsig=nhi,lsig=nlo, ext=exten, gemini=gemini)
	  } else {
	    med (p1, p2, skyim, suf=suf, pre=pre, sect=sksect, scl=skscale_typ,
                rej_met=reject,  ext=exten, gemini=gemini)
	  } 

	  if (access(skyim//"."//image)) {
	     print("Making Sky frame from images"//p1//" to "//p2)
	  } else {
	     print("Could not make sky frame...exiting")
             bye
	  }

	  if (gemini==yes) {
            hedit (skyim//"[sci]",add+,verify-,show-,field="SK_SCALE", value=skscale_typ)
            hedit (skyim//"[sci]",add+,verify-,show-,field="SK_SECT", value=sksect)
            hedit (skyim//"[sci]",add+,verify-,show-,field="REJ_MET", value=reject)
          } else {
            hedit (skyim,add+,verify-,show-,field="SK_SCALE", value=skscale_typ)
            hedit (skyim,add+,verify-,show-,field="SK_SECT", value=sksect)
            hedit (skyim,add+,verify-,show-,field="REJ_MET", value=reject)
          }

	  if (reject=="minmax") {
	    hedit (skyim,add+,verify-,show-,field="MINMX_HI",value=nhi)
	    hedit (skyim,add+,verify-,show-,field="MINMX_LO",value=nlo)
	  } else if (reject=="sigclip") {
	    hedit (skyim,add+,verify-,show-,field="HISIG",value=nhi)
            hedit (skyim,add+,verify-,show-,field="LOSIG",value=nlo)
	  }
	  
	  if (addback=="spec" && subtract==yes) {

	     clearim("background")
	     clearim(skyim//"2")
	     imsurfit (skyim//backsec, xorder=1, yorder=3, output="background")
	     imar (skyim, "-", skyim, skyim//"2")
	     imcopy ("background", skyim//"2"//backsec) 

          } else if (addback=="const" && subtract==yes) {

            imstat (skyim//backsec, fields="mode", format=no) | scan back

          }
 

	} else if (make_sky == "abba") {

	  print("SKY SUBTRACTING ABBA IMAGES: A1-B1, A2-B2")

	  if (addback=="spec") {
             clearim("background")
             clearim("tsky")
             med (p1, p2, "tsky", suf=suf, pre=pre, sect=sksect, 
	          rej_met="none", scl=skscale_typ,  ext=exten)
             imsurfit ("tsky"//backsec, xorder=1, yorder=3, output="background")
             imar ("tsky", "-", "tsky", "tsky")
             imcopy ("background", "tsky"//backsec) 
          }

          for ( i = p1 ; i <= p2 ; i += 4) {

            if ( i < 10 ) {
                  a1 = pre//"00"//i
		  if (exten==4) a1 = pre//"000"//i
	    } else if ( i < 100 ) {
                  a1 = pre//"0"//i
                  if (exten==4) a1 = pre//"00"//i
	    } else if (i < 1000 ) {
                  a1 = pre//i
                  if (exten==4) a1 = pre//"0"//i
            } else {
		  a1 = pre//i
	    }
            if ( i+1 < 10 ) {
                  b1 = pre//"00"//i+1
	          if (exten==4) b1 = pre//"000"//i+1
            } else if ( i+1 < 100 ) {
                  b1 = pre//"0"//i+1
		  if (exten==4) b1 = pre//"00"//i+1
            } else if (i < 1000 ) {
                  b1 = pre//i+1
		  if (exten==4) b1 = pre//"0"//i+1
	    } else {
		  b1 = pre//i+1
            }
            if ( i+2 < 10 ) {
                  b2 = pre//"00"//i+2
		  if (exten==4) b2 = pre//"000"//i+2
            } else if ( i+2 < 100 ) {
                  b2 = pre//"0"//i+2
                  if (exten==4) b2 = pre//"00"//i+2
            } else if (i < 1000 ){
                  b2 = pre//i+2
                  if (exten==4) b2 = pre//"0"//i+2
            } else {
		  b2 = pre//i+2
	    }
            if ( i+3 < 10 ) {
                  a2 = pre//"00"//i+3
                  if (exten==4) a2 = pre//"000"//i+2
            } else if ( i+3 < 100 ) {
                  a2 = pre//"0"//i+3
                  if (exten==4) a2 = pre//"00"//i+2
            } else if ( i < 1000 ){
                  a2 = pre//i+3
                  if (exten==4) a2 = pre//"0"//i+2
            } else {
	  	  a2 = pre//i+3
	    }

            if (access(a1//suf//".imh") || access(a1//suf//".fits") &&
		access(b1//suf//".imh") || access(b1//suf//".fits")) { 
                clearim(a1//"s") 
                clearim(b1//"s") 
                imar (a1//suf , "-" , b1//suf , a1//"s" )
                imar (b1//suf , "-" , a1//suf , b1//"s" ) 
		if (addback=="spec") {
                   imar (a1//"s", "+", "tsky", a1//"s")
                   imar (b1//"s", "+", "tsky", b1//"s")
                }
	    } else { print("can\'t find all ab images for "//a1//suf) 
            }
            if (access(b2//suf//".imh") || access(b2//suf//".fits") &&
                access(a2//suf//".imh") || access(a2//suf//".fits")) {
                clearim(b2//"s") 
                clearim(a2//"s") 
		imar (a2//suf , "-" , b2//suf , a2//"s" )
		imar (b2//suf , "-" , a2//suf , b2//"s" )
		if (addback=="spec") {
	           imar (a2//"s", "+", "tsky", a2//"s")
	           imar (b2//"s", "+", "tsky", b2//"s")
                }
	    } else { print("can\'t find all ba images for "//a2//suf) 
	    }
          }
#
# done with process for abba
#
 	  bye

        } else {
          print("USING PREVIOUS SKY IMAGE = "//skyim)
        }

	if (addback=="spec" && subtract==yes) {
#
# spectroscopic case
#
           clearim("background")
           clearim(skyim//"2")
           imsurfit (skyim//backsec, xorder=1, yorder=3, output="background")
           imar (skyim, "-", skyim, skyim//"2")
           imcopy ("background", skyim//"2"//backsec) 

	} else if (addback=="const") {

	   imstat (skyim//backsec, fields=mode, format=no) | scan back

        }

        if (subtract == no) {
          print("NO IMAGES SKY SUBTRACTED")
          bye 
          
        } else {

          print("SKY SUBTRACTING IMAGES")}

          imstat (skyim//backsec, fields="mode", format=no) | scan back

          j=0
#
# case of scaling images to sky, may not be good choice if images are
# not dark subtracted.
#

          if (imscale_typ != "none") {
           
            if (imscale_typ == "median") {imscale_typ = "midpt"}

            imstat(skyim//imsect,fields=imscale_typ, format=no) | scan norm

            imarith(skyim ,"/", norm, skyim//"n")

            clearim (skyim//"_stat")

            for ( i = p1 ; i <= p2 ; i += 1) {

               j=j+1

		if ( i < 10 ) {
                    s1 = pre//"00"//i
                    if (exten == 4) s1 = pre//"000"//i
                } else if ( i < 100 ) {
                    s1 = pre//"0"//i
                    if (exten == 4) s1 = pre//"00"//i
                } else if ( i < 1000 ) {
                    s1 = pre//i
                    if (exten == 4) s1 = pre//"0"//i
                } else {
		  s1 = pre//i
		}

               if (access(s1//suf//".imh") || access(s1//suf//".fits")) { 

	           clearim (s1//"s")

	           clearim ("temp_sky")

                   imstat(s1//suf//imsect,fields=imscale_typ,format-) |scan norm
                   imarith(skyim//"n" ,"*", norm, "temp_sky")
                   imarith(s1//suf,"-","temp_sky",s1//"s")

                   hedit (s1//"s",add+,verify-,show-,field="IMSCALE",
		          value=imscale_typ)
		   hedit (s1//"s",add+,verify-,show-,field="IMSECT",
                          value=imsect)
                   hedit (s1//"s",add+,verify-,show-,field="SKYIMAGE",
		          value=skyim)

		   if (addback=="spec") {
                      imar (s1//"s", "+", skyim//"2", s1//"s")
		   } else if (addback=="const") {
		      imar (s1//"s", "+", back , s1//"s")
                   }

                   if (clean) clearim (s1//suf)
                   if (j==1) imstat (s1//"s", > skyim//"_stat")
                   if (j>1)  imstat (s1//"s", format=no, >> skyim//"_stat")

                   clearim("temp_sky")                  
      
               } else {print (s1//suf//", file does not exist")}
	     }
#
# case of subtraction with no image scaling to sky image
#
           } else { 
            
              clearim (skyim//"_stat")

              for ( i = p1 ; i <= p2 ; i += 1) {

                j=j+1
                if ( i < 10 ) {
                    s1 = pre//"00"//i
                    if (exten == 4) s1 = pre//"000"//i
	        } else if ( i < 100 ) {
                    s1 = pre//"0"//i
		    if (exten == 4) s1 = pre//"00"//i
	        } else if ( i < 1000 ){
                    s1 = pre//i
		    if (exten == 4) s1 = pre//"0"//i
	        } else {
		    s1 = pre//i
                }

                if (access(s1//suf//".imh") || access(s1//suf//".fits"))  {
		  if (gemini==yes) {
                    clearim ("s"//s1)
                    print "Using GEMARITH to subtract MEF files"
                    gemarith(s1//suf,"-",skyim,"s"//s1)
                    hedit ("s"//s1//"[sci]",add+,verify-,show-,field="IMSCALE", value=imscale_typ)
 	            hedit ("s"//s1//"[sci]",add+,verify-,show-,field="IMSECT", value=imsect)
                    hedit ("s"//s1//"[sci]",add+,verify-,show-,field="SKYIMAGE", value=skyim)
                  } else {
                    clearim (s1//"s")
                    imarith(s1//suf,"-",skyim,s1//"s")
                    hedit (s1//"s",add+,verify-,show-,field="IMSCALE", value=imscale_typ)
		    hedit (s1//"s",add+,verify-,show-,field="IMSECT", value=imsect)
                    hedit (s1//"s",add+,verify-,show-,field="SKYIMAGE", value=skyim)
                  }

		  if (addback=="spec") {
		    imar (s1//"s", "+", skyim//"2", s1//"s")
                  } else if (addback=="const") {
                     imar (s1//"s", "+", back , s1//"s")
                  }

                  if (clean) {clearim (s1//suf)}
                  if (j==1) {imstat (s1//"s", > skyim//"_stat")}
                  if (j>1) {imstat (s1//"s", format=no, >> skyim//"_stat")}

	        } else {print (s1//suf//", file does not exist")}
	      }
	   }

	clearim ("temp_sky")
	clearim (skyim//"n")
	clearim ("background")
        clearim (skyim//"2")
        clearim ("tsky")
        clearim ("tsky2")
end
