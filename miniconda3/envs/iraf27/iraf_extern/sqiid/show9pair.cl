# SHOW9PAIR:  05OCT93 KMM
# SHOW9:  01JAN93 KMM
# SHOW9 - display 3x3 grid of (sky-subtracted) sqiid frames
#  1  2
#  4  3
#  5  6
#  8  7
#  9 10
# 12 11
# 13 14
# 16 15
# 17 18
# Assumes imt800 for proper operation

procedure show9pair  (first_image, frame, path_pos) 

string  first_image   {"",prompt="First image in sequentially numbered images"}
int     frame         {prompt="Display frame #"}
string  path_pos      {prompt="Path position in grid (1-9)?"}
bool    pair_subtract {yes, prompt="Pairwise subtract 1-2,4-3,5-6,8-7,..."}
bool    orient        {no, prompt="Orient N up and E left?"}
bool    zscale        {yes, prompt="automatic zcale on each frame?"}
string  ztrans        {"linear", prompt="intensity transform: log|linear|none"}
real    z1            {0.0, prompt="minimum intensity"}
real    z2            {1000.0, prompt="maximum intensity"}

struct	*l_list
 
begin

   file    l_log, simg, nimlist
   int     i, nim, maxnim, stat, npos
   real    x,y,x1,x2,x3,y1,y2,y3
   bool    erase
   string  first, img, uniq, pathpos, obj, sky

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
      print "Inverted: SQIID/COB North is up and East is left"
   } else {
      y1 = 0.18
      y2 = 0.50
      y3 = 0.82
      print "As is: SQIID/COB North is down and East is left"
   }
   l_list = nimlist

   for (i=1; (fscan(l_list, npos) != EOF); i += 1) {
      switch (npos) {
         case 1: {
            x = x2 ; y = y2
            erase = yes
            img = first
            obj = first
            sky = obj + 1
         }
         case 2: {
            x = x2; y = y1
            erase = no
            img = first + 1
            obj = first + 3
            sky = first + 2
         }
         case 3: {
            x = x1; y = y1
            erase = no
            img = first + 2
            obj = first + 4
            sky = first + 5
         }
         case 4: {
            x = x1; y = y2
            erase = no
            img = first + 3
            obj = first + 7
            sky = first + 6
         }
         case 5: {
            x = x1; y = y3
            erase = no
            img = first + 4
            obj = first + 8
            sky = first + 9
         }
         case 6: {
            x = x2; y = y3
            erase = no
            img = first + 5
            obj = first + 11
            sky = first + 10
         }
         case 7: {
            x = x3; y = y3
            erase = no
            img = first + 6
            obj = first + 12
            sky = first + 13
         }
         case 8: {
            x = x3; y = y2
            erase = no
            img = first + 7
            obj = first + 15
            sky = first + 14
         }
         case 9: {
            x = x3; y = y1
            erase = no
            img = first + 8
            obj = first + 16
            sky = first + 17
         }
      }
      if ((! access(obj)) && (! access(obj//".imh"))) {
         print ("Object image: ",obj," not found!")
         next
      } else if ((! access(sky)) && (! access(sky//".imh"))) {
         print ("Sky image: ",sky," not found!")
         next
      }
      imarith (obj,"-",sky,simg,pix="real",calc="real",hpar="")
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
