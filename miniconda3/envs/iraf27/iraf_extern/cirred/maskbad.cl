procedure maskbad ( image1 , image2 )

#
# make a bad pixel mask from uniformly illuminated images. For example, from
# lights on and lights off dome flats. For mask1, good pixels=0, badpixels=1. 
# For mask2, good pixels=1, badpixels=0.
#

#
# Revision History
# Original 25 may 99. RDB. 
#
# Improve interactive queries. 18 apr 2000. RDB
# Add response correction prior to histogram, remove twod fit. RDB. 20 12 2002.
# Remove trim. RDB. 20 12 2002.
# 28 april, 2004. RDB. Change fit to use "imsurfit," a 2D fit.
# 28 april, 2004. RDB. Add option to fit surface for just the illuminated frame.
#

string image1	{prompt="image 1 used for bad pixel mask construction"}
string image2   {prompt="image 2 used for bad pixel mask construction"}
string mask1="mask1" {prompt="output mask image"}
string mask2="mask2" {prompt="output mask image"}
real   xo=15 {prompt="xorder of image surface fit for case of fit=yes"}
real   yo=15 {prompt="yorder of image surface fit for case of fit=yes"}
bool   fitdark=no {prompt="normalize dark images before computing histogram? <y|n>"}
bool   fitillum=no {prompt="normalize iilum images before computing histogram? <y|n>"}
bool   zero=no  {prompt="Set pixels with 0.0 ADU to good?"}

begin

  bool blast
  real u1, u2, l1, l2, norm,same

  clearim ("x1")
  clearim ("x2")
  clearim ("x3")
  clearim ("x4")
  clearim (mask1)
  clearim ("mask2")
#
# avoid calling a pixel with 0.0 ADU bad
#
  if (zero) { imar ( image1, '+' , 0.0001 , image1) }
#
# Normalize the image by a smooth fit to the data.
#
  if (fitdark == yes) {
    print "Normalizing dark images with imsurfit"
    images
    imsurfit (image1 , "x1" , xorder=xo , yorder=yo , type_out="response" )
    imstat (image1 , format=no , fields = "mean" ) | scan norm
    imar ("x1" , "*" , norm , "x1")
  } else{ 
    imcopy (input=image1, output="x1")
  }
 
  blast=yes
  imhist ("x1")
  zoom: print  ("zoom in on histogram? [y] <y|n>")
  scan (blast)

  if (blast) {
    u1=INDEF
    l1=INDEF
    print  ("histogram limits? lower, upper")
    scan  (u1,l1)
    imhist ("x1", z1=u1, z2=l1) 
    goto zoom}
  print  ("good pixel limits for "//image1//" z1, z2")
  limit:
  u1=INDEF
  l1=INDEF
  scan   (u1, l1)
  if (u1==INDEF) {print "please enter pixel limits" ; goto limit}
  
  imreplace (images="x1" , value=0.0000 , lower=l1, upper=INDEF)
  imreplace (images="x1" , value=0.0000 , upper=u1, lower=INDEF)

  imarith ("x1" ,"/",  "x1",  "x2" , divzero=0.)

  clearim ("x3")
  clearim ("x4")

  same = 0
  if (image1 == image2) {
     imcopy ("x2" , "x4", ver-)
     same = 1
     goto skip
  }

#
# avoid calling a pixel with 0.0 ADU bad
#
  if (zero) {imar ( image2, '+' , 0.0001 , image2)}

  if (fitillum == yes) {
    print "Normalizing illuminated images with imsurfit"
    images
    imsurfit (image2 , "x3" , xorder=xo , yorder=yo , type_out="response" )
    imstat (image2 , format=no , fields = "mean" ) | scan norm
    imar ("x3" , "*" , norm , "x3")
  } else{
    imcopy (input=image2, output="x3")
  }
 
  blast=yes
  imhist ("x3")
  zoom2: print  ("zoom in on histogram? [y] <y|n>")
  scan (blast)
 
  if (blast) {
    u2=INDEF
    l2=INDEF
    print  ("histogram limits? lower, upper")
    scan  (u2,l2)
    imhist ("x3", z1=u2, z2=l2)
    goto zoom2}

  print  ("good pixel limits for "//image2//" z1, z2")
  limit2: 
  u2=INDEF
  l2=INDEF
  scan   (u2, l2)
  if(u2==INDEF) {print "please enter pixel limits" ; goto limit2}
   
  imreplace (images="x3" , value=0.0000 , lower=l2, upper=INDEF) 
  imreplace (images="x3" , value=0.0000 , upper=u2, lower=INDEF)

  imarith ("x3" ,"/", "x3", "x4" , divzero=0.)

#
# Make final mask
#
  skip:

  imarith ("x2", "*", "x4" ,mask1)

  imar (mask1 ,"-", 1.0, mask1)
  imar (mask1 ,"*", -1.0,mask1)

  imar (mask1 , "-" , 1 , mask2)
  imar (mask2 , "*" , -1 , mask2)

  blast=yes
  print('display mask? [y] <y|n>')
  scan (blast)
  if(blast) {displ (mask1, 1, z2=2, z1=0, zsc-); imexam}

  hedit (mask1, add+, show-, verify-, fields="FIXBAD1", value=u1//" "//l1)
  if (same!=1) {
     hedit (mask1, add+, show-, verify-, fields="FIXBAD2", value=u2//" "//l2)
  }

  blast=yes
  print ('delete working images? [y] <y|n> ')
  scan  (blast)
  if (blast) {
      clearim ("x1")
      clearim ("x2")
      clearim ("x3")
      clearim ("x4")
  }

end
