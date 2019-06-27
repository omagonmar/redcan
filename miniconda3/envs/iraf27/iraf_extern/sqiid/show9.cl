# SHOW9:  05OCT93 KMM
# SHOW9 - display 3x3 grid of (sky-subtracted) sqiid frames
# Assumes imt800 for proper operation

procedure show9  (first_image, frame, path_pos) 

string  first_image  {"",prompt="First image in sequentially numbered images"}
int     frame        {prompt="Display frame #"}
string  path_pos     {prompt="Path position in grid (1-9)?"}
bool    dithered     {yes, prompt="Dithered image pairs?"}
string  sky          {"null", prompt="sky frame"}
bool    orient       {no, prompt="Orient N up and E left?"}
bool    zscale       {yes, prompt="automatic zcale on each frame?"}
string  ztrans       {"linear", prompt="intensity transform: log|linear|none"}
real    z1           {0.0, prompt="minimum intensity"}
real    z2           {1000.0, prompt="maximum intensity"}

struct	*l_list
 
begin

   file    l_log, simg, nimlist
   int     i, nim, maxnim, stat, npos
   real    x,y,x1,x2,x3,y1,y2,y3
   bool    erase
   string  first, img, uniq, pathpos

   uniq    = mktemp ("_Tsh9")
   simg    = uniq // ".img"
   l_log   = mktemp ("tmp$sh9")
   nimlist = mktemp ("tmp$sh9")

# Get positional parameters
   first   = first_image
   nim     = frame
   pathpos = path_pos

   expandnim (pathpos,ref_nim=-1,max_nim=9,>> nimlist)
   count (nimlist,>> l_log)
   l_list = l_log
   stat = fscan(l_list, maxnim)
   if (maxnim < 1 || maxnim > 9) {
      print ("Wrong number of images:",maxnim)
      goto skip
   }

   x1 = 0.18
   x2 = 0.50
   x3 = 0.82
   if (orient) {
      y1 = 0.82
      y2 = 0.50
      y3 = 0.18
   } else {
      y1 = 0.18
      y2 = 0.50
      y3 = 0.82
   }
   l_list = nimlist
   for (i=1; (fscan(l_list, npos) != EOF); i += 1) {
      if (dithered)
         img = first + (2 * (npos - 1))
      else
         img = first + (npos - 1)
      if ((! access(img)) && (! access(img//".imh"))) next
      switch (npos) {
         case 1: {
            x = x1; y = y1
            erase = yes
         }
         case 2: {
            x = x2; y = y1
            erase = no
         }
         case 3: {
            x = x3; y = y1
            erase = no
         }
         case 4: {
            x = x1; y = y2
            erase = no
         }
         case 5: {
            x = x2; y = y2
            erase = no
         }
         case 6: {
            x = x3; y = y2
            erase = no
         }
         case 7: {
            x = x1; y = y3
            erase = no
         }
         case 8: {
            x = x2; y = y3
            erase = no
         }
         case 9: {
            x = x3; y = y3
            erase = no
         }
      }

      if (sky == "" || sky == " " || sky == "null") 
         imcopy (img, simg, verbose-) 
      else {
         if ((! access(sky)) && (! access(sky//".imh")))
            print ("Sky image: ",sky," not found!")
         else
           imarith (img,"-",sky,simg,pix="real",calc="real",hpar="")
      }
      if (orient)
         imcopy (simg//"[*,-*]", simg, verbose-)
      if (zscale) {
         display(simg,nim,xc=x,yc=y,erase=erase,zs+,zr-,fill-,ztrans=ztrans)
      } else {
         display(simg,nim,xc=x,yc=y,erase=erase,zs-,zr-,fill-,ztrans=ztrans,
           z1=z1,z2=z2)
      }
      imdelete (simg,verify-,>& "dev$null")
   }
skip:

   delete (l_log//","//nimlist,ver-,>& "dev$null")
   imdelete (simg,verify-,>& "dev$null")

end
