## GETCOO extract objects from frmae buffer and IMCNTR

procedure getcoo (coordlist)

   string coordlist  {prompt="List of files with X Y star coord"}
   string prefix     {"home$", prompt="Directory path to coordlist"}
   string logfile    {"STDOUT", prompt="Log file name"}
   bool   shift      {no,prompt="Calculate shift between first and rest"}

   struct  *inlist, *colist, *l_list, *list1, *list2

   begin

      int    stat, nin, njunk, slen, nobj, pos1b, pos1e
      real   x, y, xr, yr, xshift, yshift, xmean, ymean, xsdev, ysdev
      string coord,tag,in_name,uniq,imname,junk,sbuff,sname,sfile,
             syspath,sysname
      file   tmp1, tmp2, tmp3, refcoo, objcoo, l_log, xdiff, ydiff
      struct line = ""
      bool   found

      coord   = coordlist
      syspath = osfn (prefix) 
      uniq    = mktemp ("_Tgco")
      tmp1    = uniq // ".tm1"
      tmp2    = uniq // ".tm2"
      tmp3    = uniq // ".tm3"
      refcoo  = uniq // ".ref"
      objcoo  = uniq // ".obj"
      xdiff   = uniq // ".xdi"
      ydiff   = uniq // ".ydi"
      l_log   = uniq // ".llg"

      l_list = l_log
      files(coord, sort-,>> tmp1)
      inlist = tmp1
      nin = 0
      while (fscan(inlist, sfile) != EOF) {
         in_name = sfile
         slen    = strlen(sfile)
         sysname = syspath//sfile
         colist  = sysname 
   # Extract image name from frame buffer
         found = no
         while (fscan(colist, line) != EOF) {
            stat = fscan(line, junk, junk, sbuff, sname)
            if (in_name == substr(sbuff,1,slen)) {
               imname = sname
               tag    = line
               found  = yes
               break
            }
         }
         if (!found) {
            print ("Image id for ",sysname," not found.")
            goto err
         }
         nin += 1 
         colist = ""; delete(tmp3,verify-,>& "dev$null")
         match ("^\#", sysname, stop+,>> tmp3)
         count (tmp3, >> l_log)
         stat = fscan(l_list, nobj)
         print ("# ",tag)
         print ("# image= ",imname," number_of_objects= ", nobj)
         colist = tmp3
         while (fscan(colist, x, y) != EOF) {
            imcntr(imname, x, y, cboxsize=5,>> tmp2)
         }
         if (shift) {
            if (nin == 1) {
               translit(tmp2,":"," ",del-,col-) |
                  fields(,"3,5",lines="1-999",qu-,pr-, > refcoo)
               type (refcoo)
            } else {
               translit(tmp2,":"," ",del-,col-) |
                  fields(,"3,5",lines="1-999",qu-,pr-, > objcoo)
               type (objcoo)
               list1 = refcoo
               list2 = objcoo
               while((fscan(list1,xr,yr) !=EOF) && (fscan(list2,x,y) !=EOF)) {
                  xshift = x - xr
                  yshift = y - yr
                  print (xshift,>> xdiff)
                  print (yshift,>> ydiff)
               }
               average ("new_sample", < xdiff, >> l_log)
               stat = fscan (l_list, xmean, xsdev, njunk)
               xmean = 0.001*real(nint(1000.*xmean))
               average ("new_sample", < ydiff, >> l_log)
               stat = fscan (l_list, ymean, ysdev, njunk)
               ymean = 0.001*real(nint(1000.*ymean))
               if (njunk >= 2) {
                 xsdev = 0.001*real(nint(1000.*xsdev))
                 ysdev = 0.001*real(nint(1000.*ysdev))
               } else {
                 xsdev = 0.0
                 ysdev = 0.0
               }
               print ("Mean xshift = ",xmean, " +/- ",xsdev)
               print ("Mean yshift = ",ymean, " +/- ",ysdev)
               delete(objcoo,verify-,>& "dev$null")
               delete(xdiff,verify-,>& "dev$null")
               delete(ydiff,verify-,>& "dev$null")
            }
         } else {
            translit(tmp2,":"," ",del-,col-) |
               fields(,"3,5",lines="1-999",qu-,pr-)
         }
         print ("#####")
         colist = ""; delete(tmp3,verify-,>& "dev$null")
         delete(tmp2,verify-,>& "dev$null")
      }

      err:

   # Finish up
      delete (uniq//"*", verify-)

   end
