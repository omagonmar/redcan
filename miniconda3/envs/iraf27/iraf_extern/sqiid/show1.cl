# SHOW1: 11SEP92 KMM
# SHOW1 - display 1 (sky-subtracted) sqiid frames

procedure show1  (first_image, frame) 

string  first_image  {prompt="First image in sequentially numbered images"}
int     frame        {prompt="Display frame #"}
string  sky          {"null", prompt="sky frame"}
bool    orient       {no, prompt="Orient N up and E left?"}
bool    zscale       {yes, prompt="automatic zcale on each frame?"}
string  ztrans       {"linear", prompt="intensity transform: log|linear|none"}
real    z1           {0.0, prompt="minimum intensity"}
real    z2           {1000.0, prompt="maximum intensity"}

struct	*l_list
 
begin

   file    l_log, simg
   int     i, nim,stat
   real    x,y
   bool    erase
   string  first, img, uniq

   uniq   = mktemp ("_Tsh4")
   simg   = uniq // ".img"
   l_log  = mktemp ("tmp$sh4")

# Get positional parameters
   first  = first_image
   nim = frame

   if (sky == "" || sky == " " || sky == "null") 
      imcopy (first, simg, verbose-) 
   else {
      if ((! access(sky)) && (! access(sky//".imh")))
         print ("Sky image: ",sky," not found!")
      else
        imarith (first,"-",sky,simg,pix="real",calc="real",hpar="")
   }

   if (orient) imcopy(simg//"[*,-*]",simg)

   if (zscale) {
      display(simg,nim,erase+,zs+,zr-,fill-,ztrans=ztrans)
   } else {
      display(simg,nim,erase+,zs-,zr-,fill-,ztrans=ztrans,z1=z1,z2=z2)
   }
   imdelete (simg,verify-,>& "dev$null")
        
   delete (l_log,ver-,>& "dev$null")
   imdelete (simg,verify-,>& "dev$null")

end
