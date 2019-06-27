# XYSTD   -- make files (one per image) of X and Y coordinates
# by pointing to stars on display.

procedure starid (images)

string	images			{prompt="image or @list of images"}

int	frame	= 1		{prompt="Frame for displaying images"}
string  idtag   = "co_"         {prompt="ID tag?",mode="q"}
bool    zscale  = yes           {prompt="Autoscale display?"}
real    z1      = -100          {prompt="Display z1?"}
real    z2      = 1000          {prompt="Display z2?"}
bool    center  = yes           {prompt="Centroid cursor position?"}
bool	verbose	= yes		{prompt="Print info on the STDOUT, too?"}

struct	*imlist,*l_list,*xylist

begin
	string	code = "q"
	string	l_images, outlist, img, imgfile, xyout, sjunk, wcs
	real	x, y, xc, yc
        file    l_log, xyfile
	int	junk, n, stat

	l_images = images
        l_log    = mktemp("tmp$xys")
        xyfile   = mktemp("tmp$xys")
        imgfile  = mktemp("tmp$xys")
        sections (l_images, option="fullname",> imgfile)

        n = strlen(images)
        if (substr(images,n-3,n) == ".imh")
           outlist = substr(images,1,n-4)
        else
           outlist = images
        if (substr(outlist,1,1) == "@")
           outlist = substr(outlist,2,strlen(outlist))
        outlist = "co_"//outlist

	if (verbose) {
	    print ("\nThe task displays the images:")
            type (imgfile)
	    print("Center the in the image using the flashing `target' cursor.")
            print("Press the  <spacebar>  to record each position or")
            print("press <ctrl-z> to move on to the next image.")
	    print ("Zooming each image is permitted.\n")
        }

        imlist = imgfile
        while (fscan(imlist, img) != EOF) {
           n = strlen(img)
           if (substr(img,n-3,n) == ".imh")
              xyout = substr(img,1,n-4)//".xy"
           else
              xyout = img//".xy"
           print (xyout, >> outlist)
	   if (verbose) print ("Displaying ", img, ":")
           if (zscale)
	      display (img, frame, zs+)
           else
	      display (img, frame, z1=z1,z2=z2, zs-)
	   if (verbose) print ("Center the object, press <spacebar>:")

           rimcursor (img,wcs="logical",cursor="",> xyfile)
           xylist = xyfile
           l_list = l_log
	   while (fscan(xylist,x,y,wcs,code) != EOF) {
                 if (center) {
                    imcntr(img,x,y) | translit ("",":"," ",coll-,>> l_log)
                    stat = fscan(l_list,sjunk,sjunk,xc,sjunk,yc)
                    if (verbose) print(xc,yc," ",img)
                    print(xc,yc," ",img,>> xyout)
                 } else
                    print(x,y," ",img,>> xyout)
	   }
	   xylist = ""; delete (xyfile, ver-, >& "dev$null")
	   l_list = ""; delete (l_log, ver-, >& "dev$null")
        }

	xylist = ""; delete (xyfile, ver-, >& "dev$null")
	l_list = ""; delete (l_log, ver-, >& "dev$null")
	imlist = ""; delete (imgfile, ver-, >& "dev$null")

end
