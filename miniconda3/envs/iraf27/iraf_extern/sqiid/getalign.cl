## GETALIGN: 18FEB92 KMM 07MAY92 KMM
## GETALIGN Determine shifts between source images and IRALIGN/IRMATCH images

procedure getalign (image_nums, complist, refinfo)

   string image_nums   {prompt="Selected image numbers along IRMOSAIC path"}
   string complist     {prompt="List of images to compare: im1,im2,im3,..."}
   string refinfo      {prompt="Info file from reference LINK||MKMATCH"}
 
   string match_im     {"", prompt="Name of MATCHED image: null implies skip"}
   string coord_in     {"", prompt="Input initial coordinate file"}
   string in_shifts    {"", prompt="Initial shift file between ref and images"}
   bool	  disp_all     {yes, prompt="Display all (<=4) frames?"}
   bool	  verbose      {no, prompt="Verbose output?"}
#   string prefix       {"rg", prompt="Prefix for shifted images"}
   real   cboxbig      {20., prompt="Size of coarse search box"}
   real   cboxsmall    { 5., prompt="Size of small search box"}
#   bool   qshift       { no, prompt="Shift imames?"}
#   bool   qtrim        { no, prompt="Trim imames?"}
   bool   getoffset  {no,
                         prompt="Do you want to get frame offsets?", mode="q"}
   string outfile      {"", prompt="Output information file"}
   struct  *list1,*list2,*list3,*list4,*l_list
    imcur  *starco

   begin

      int    i,stat,nim,ncomp,ndisp,lo,hi,pos1e, wcs,
             nxhisrc, nxlosrc, nyhisrc, nylosrc,
             nxhimos, nxlomos, nyhimos, nylomos,
             nxhimat, nxlomat, nyhimat, nylomat,
             nxmat0, nymat0, nxmos0, nymos0, nxref0, nyref0, nlines
      real   xin, yin, xref, yref, xs, ys
      string l_comp,out,nim_name,uniq,slist,sjunk,soffset,sname,key,vcheck,
             src,srcsub,mos,mossub,matsub,comsub,first,mos_name,inshifts,
             i_match,ref,refsub,pathtag,nimtag,reftag,slog,image_nims
      string im_id[4]
      file   info,db,coords,cofile,shifts,l_log,refimg,alignlog,nimlist,
             imidfile,compfile,tmp1,tmp2,matinfo,dbinfo,task
      bool   getcoords, matref, printit,gotoffset
      struct command = ""
      struct line = ""

      image_nims  = image_nums
      l_comp      = complist
      info        = refinfo
      gotoffset   = no

      uniq        = mktemp ("_Tgsh")
      tmp1        = uniq // ".tm1"
      tmp2        = uniq // ".tm2"
      dbinfo      = uniq // ".dbi"
      matinfo     = uniq // ".mat"
      nimlist     = uniq // ".nim"
      alignlog    = uniq // ".ali"
      l_log       = uniq // ".log"
      imidfile    = uniq // ".imi"
      compfile    = uniq // ".com"
      cofile      = uniq // ".cof"
      coords      = uniq // ".coo"
      refimg      = uniq // ".ref"
      task        = uniq // ".tsk"
      shifts      = refimg // ".shifts"
      slog = "STDOUT,"//alignlog

      sjunk = cl.version		# get CL version
      stat = fscan(sjunk,vcheck)
      if (stridx("Vv",version) <=0 )	# first word isn't version!
         stat = fscan(sjunk,vcheck,vcheck)

      if (coord_in == "" || coord_in == " " || coord_in == "null")
        getcoords = yes
      else {
        getcoords = no
        match ("SUM_COARSE",coord_in,meta-,stop-,print-,> coords)
      }

   # Determine match image
      i_match     = match_im
      if (i_match == "" || i_match == " " || i_match == "null") i_match = "null"
      if (i_match == "null")
         matref = no
      else
         matref = yes

      l_list = l_log
      match ("^\#DB ",info,meta+,stop-,print-, > dbinfo)
      match ("^MAT",info,meta+,stop-,print-, > matinfo)
      count (matinfo,>> l_log); stat = fscan(l_list, nlines)

   # Expand the range of images to include

      print (image_nims, ",") | translit ("", "^-,0-9", del+) |
         translit ("", "-", "!", del-) | tokens (new-) |
         translit ("", "\n,", " \n", del-, > tmp1)
      list1 = tmp1
      while (fscan (list1, lo, key, hi, sjunk) != EOF) {
         if (nscan() == 0)
	    next
         else if (nscan() == 1 && lo >= 1)
	    print (lo, >> tmp2)
         else if (nscan() == 3) {
	    lo = min (max (lo, 1), nlines); hi = min (max (hi, 1), nlines)
	    for (i = lo; i <= hi; i += 1)
	        print (i, >> tmp2)
         }
      }
      list1 = ""; delete (tmp1, ver-, >& "dev$null")
      sort (tmp2, col=0, ign+, num+, rev-) | unique (> nimlist)
      delete (tmp2, ver-, >& "dev$null")

   # Extract values from infofile
      match ("mosaic",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, mos_name)

   # establish ID of output info file
      if (outfile == "" || outfile == " " || outfile == "default") {
         if (i_match == "null")
            out = mos_name//".comp"
         else {
            pos1e = stridx(".",i_match)-1
            if (pos1e > 1) 
               out = substr(i_match,1,pos1e)//".comp"
            else
               out = i_match//".comp"
         }
      } else
         out = outfile
      if (out != "STDOUT" && access(out))
         print ("Note: appending to existing output_file ",out)
      print ("Output_file= ",out)

   # work through image list
      list4 = nimlist
      while(fscan(list4,nim) != EOF) {
         delete(l_log,verify-,>& "dev$null")
         l_list = l_log
   # terminate if nim exceeds available information
         if (nlines < nim) {
            print ("Image number=",nim," outside range=",nlines)
            goto skip
         }
   # create image path tag and image id
         pathtag = "_000" + nim
         nim_name = mos_name//pathtag
         print("Processing ",nim_name," ...")

   # scan down to desired entry
   #      print ("MAT_"//pathpos," ",src," ",nxlosrc,nxhisrc,nylosrc,nyhisrc,
   #         nxmat0,nymat0,xs,ys,soffset >> info)
         list1 = matinfo
         for (i = 1; i <= nim; i += 1) {
            stat = fscan(list1,sjunk,mos,nxlosrc,nxhisrc,nylosrc,nyhisrc,
              nxmat0,nymat0,xs,ys,soffset)
         }
         list1 = ""
   # extract and decode appropriate mosaic section
         mossub = substr(mos,stridx("[",mos),stridx("]",mos))
         mos    = substr(mos,1,stridx("[",mos)-1)
         print (mossub) | translit ("", "[:,]", "    ", >> l_log)
         stat = (fscan(l_list,nxlomos,nxhimos,nylomos,nyhimos))

   # determine appropriate image subsections
         nxlomat = nxmat0 + nxlosrc
         nxhimat = nxmat0 + nxhisrc
         nylomat = nymat0 + nylosrc
         nyhimat = nymat0 + nyhisrc
         nxmos0  = nxlomos - 1
         nymos0  = nylomos - 1
         nxlomos = nxmos0 + nxlosrc
         nxhimos = nxmos0 + nxhisrc
         nylomos = nymos0 + nylosrc
         nyhimos = nymos0 + nyhisrc
         matsub = "["//nxlomat//":"//nxhimat//","//nylomat//":"//nyhimat //"]"
         comsub = "["//nxlomos//":"//nxhimos//","//nylomos//":"//nyhimos //"]"

   # expand comparison image list, pre-pending reference image to list
         print (refimg,> compfile)
         if (matref) {
            srcsub = i_match//matsub
            src    = "_T"//i_match//pathtag
            print (srcsub,>> imidfile); print (srcsub,>> imidfile)
            print (src,>> compfile)
            imcopy (srcsub,src,verbose-)
         }
         files (l_comp,sort-,>> tmp1)
         list1 = tmp1
         for (i = 1; fscan(list1,sname) != EOF; i += 1) {
            srcsub = sname//comsub
            src    = "_T"//sname//pathtag
            if (i==1 && !matref) print (srcsub,>> imidfile)
            print (srcsub,>> imidfile)
            print (src,>> compfile)
            imcopy (srcsub,src,verbose-)
         }
         delete(tmp1,verify-,>& "dev$null")
         count (compfile, >> l_log); stat = fscan(l_list, ncomp)
         ndisp = ncomp-1
         list1 = imidfile
   # get ID of first displayed image into reference image
         stat = fscan(list1,first); stat = fscan(list1,first)
         imcopy (first, refimg, verbose-)
         refsub = substr(first,stridx("[",first),stridx("]",first))
         ref    = substr(first,1,stridx("[",first)-1)
         reftag = ref//pathtag
#      nimtag  = nim_name // " -> " // ref
         nimtag  = nim_name

         list1 = compfile
    # skip duplicated reference image
         stat  = fscan(list1,src)
         src = substr(src,stridx("T",src)+1,strlen(src))
         slist = src 
         if (matref) {
            nxref0 = nxmat0
            nyref0 = nymat0
         } else {
            nxref0 = nxmos0
            nyref0 = nymos0
         }
         for (nim = 1; nim <= ndisp; nim += 1) {
            stat = fscan(list1,src)
            if (nim <=4) im_id[nim] = src
            src = substr(src,stridx("T",src)+1,strlen(src))
            slist=slist//","//src
         }

         if (getcoords) {
            delete (task, verify-,>& "dev$null")
            if (disp_all) {
   # Display up to 4 frames so that can verify objects are on all frames
               for (i = 1; i <=  min(ndisp,4); i += 1)
                  print ("display "//im_id[i]//" "//i//" fi-",>> task)
            } else
                  print ("display "//im_id[1]//" "//1//" fi-",>> task)
            type (task) | cl
            frame (1)

            print ("Allowed keystrokes: |f(find)|spacebar(find&use)|q(quit)|")
            while (fscan(starco,xin,yin,wcs,command) != EOF) {
               if (substr(command,1,1) == "\\")
                  key = substr(command,2,4)
               else
                  key = substr(command,1,1)
               if (key == "f")
                  print ("Star_coordinates= ",xin,yin)
   # 040 == spacebar
               else if (key == "040") {
   # Improve center
                  imcntr (refimg, xin, yin,>> l_log)
                  stat = fscan (l_list, line)
                  print ("Star_coordinates= ",xin,yin," ;imcntr= ",line,>> tmp1)
                  print ("Star_coordinates= ",xin,yin," ;imcntr= ",line)
               } else if (key == "q")
                  break
               else {
                  print ("Unknown keystroke: ",key," allowed = |f|spacebar|q|")
                  beep
               }
            }
            print ("Submitted star_coordinates:"); type (tmp1)
  # Get individual frame offsets if outside range of coarse pass
            if (disp_all && getoffset) {
               delete (tmp2, ver-, >& "dev$null")
               frame (1)
               print ("Select star for reference frame 1")
               while (fscan(starco,xin,yin,wcs,command) != EOF) {
                  if (substr(command,1,1) == "\\")
                     key = substr(command,2,4)
                  else
                     key = substr(command,1,1)
                  if (key == "f")
                     print ("Ref_coordinates= ",xin,yin)
   # 040 == spacebar
                  else if (key == "040") {
                     print ("Submitted ref_coordinates= ",xin,yin)
                     xref = xin
                     yref = yin
                     print ("0 0",>> tmp2)
                     gotoffset = yes
                     break
                  } else if (key == "q") {
                     gotoffset = no
                     break
                  }
               }
               if (matref); print ("0 0",>> tmp2)
               print("Allowed keystrokes: |f(find)|spacebar(find&use)|q(skip)|")
               for (i = 2; i <= min(ndisp,nim); i += 1) { 
                  frame (i)
                  print ("Select star for frame ",i)
                  while (fscan(starco,xin,yin,wcs,command) != EOF) {
                     if (substr(command,1,1) == "\\")
                        key = substr(command,2,4)
                     else
                        key = substr(command,1,1)
                     if (key == "f") {
                        print ("Star_coordinates= ",xin,yin)
                        xin = xref - xin
                        yin = yref - yin
                        print ("Offset for frame ",i,xin,yin)
   # 040 == spacebar
                     } else if (key == "040") {
                        print ("Selected star_coordinates= ",xin,yin)
                        xin = xref - xin
                        yin = yref - yin
                        print ("Submitted offset for frame ",i,xin,yin)
                        print (xin,yin,>> tmp2)
                        break
                     } else if (key == "q") {
                        print ("0 0",>> tmp2)
                        break
                     } else {
                        print("Unknown key: ",key," allowed = |f|spacebar|q|")
                        beep
                     }
                  }
               }
               print ("Submitted frame offsets:"); type (tmp2)
            } else if (disp_all) {
               gotoffset = no
            }
            list1 = tmp1
  # Format (Star_coordinates= xin yin ;imcntr= imageid x: xcenter y: ycenter)
            while(fscan(list1,sjunk,xin,yin,sjunk,sjunk,sjunk,xin,sjunk,
               yin) != EOF) {
               xref = xin + nxref0
               yref = yin + nyref0
               print (xin, yin, xref, yref, nxref0, nyref0, >> cofile )
            }
         } else {
   # Scan coord list for appropriate stuff
            sname = substr(nim_name,stridx("_",nim_name),strlen(nim_name))
            match (sname,coords,meta-,stop-,print-, > tmp1)
            list1 = tmp1
            while (fscan(list1, sjunk, sjunk, xin, yin) != EOF) {
               xref = xin + nxref0
               yref = yin + nyref0
               print (xin, yin, xref, yref, nxref0, nyref0, >> cofile )
            }
         }

   # Locate objects in REF and other frames

         delete(task,verify-,>& "dev$null")
         if (vcheck < "2.9D") {
#         imalign (refimg,"@"//compfile,cofile,shifts="",
#            logfiles=slog, cboxbig=cboxbig,cboxsmall=cboxsmall,
#            plotfile="",finecenter+,shiftimages-,trimimages-)
# prefix=prefix,interp_type="spline3",boundary="constant",constant=0.,
            print("imalign "//refimg//" @"//compfile//" "//cofile//"\\",>> task)
            if (in_shifts == "" || in_shifts == " " || in_shifts == "null") {
               if (!gotoffset) {
                  print(' shifts="" logfiles='//slog//"\\",>> task)
               } else {
                  print(" shifts="//tmp2," logfiles="//slog//"\\",>> task)
               }
            } else {
               print(" shifts="//inshifts," logfiles="//slog//"\\",>> task)
            }
            print(" cboxbig="//cboxbig, " cboxsmall="//cboxsmall//"\\",>> task)
            print (' plotfile="" finecenter+ shiftimages- trimimages-',>> task)
         } else {
#         imalign (""@"//compfile,cofile,refimg,shifts="",
#            bigbox=cboxbig,boxsize=cboxsmall,
#            background=INDEF,lower=INDEF,upper=INDEF,niterations=3,tolerance=0,
#            negative-,shiftimages-,trimimages-,>> slog)
# prefix=prefix,interp_type="spline3",boundary="constant",constant=0.,
            print("imalign @"//compfile//" "//cofile//" "//refimg//"\\",>> task)
            if (in_shifts == "" || in_shifts == " " || in_shifts == "null") {
               if (!gotoffset) {
                  print(' shifts="" '//"\\",>> task)
               } else {
                  print(" shifts="//tmp2//"\\",>> task)
               }
            } else {
               print(" shifts="//inshifts//"\\",>> task)
            }
            print(" big="//cboxbig, " box="//cboxsmall//"\\",>> task)
            print(" back=INDEF lo=INDEF up=INDEF"//"\\",>> task)
            print(" niter=3 tol= 0"//"\\",>> task)
            print (" shiftim- trim- neg- verb+ >>"//alignlog,>> task)
         }
         type (task) | cl

         if (vcheck < "2.9") {
            if (verbose)
   # Log imalign output
                type(alignlog,>> out)
            else {
   # Log imalign output between "Average shifts..." to "Trim to be applied..."
               list1 = alignlog
               printit = no
               while (fscan(list1,line) != EOF) {
                  if (printit)
                     print(reftag//": ",line,>> out)
                     stat = fscan(line,sjunk)
                     if (sjunk == "Trim") {
                        printit = no
                     }
                  else {
                     stat = fscan(line,sjunk)
                     if (sjunk == "Average") {
                        printit = yes
                        print(reftag//": ",line,>> out)
                     }
                  }
               }
            }
         } else {
   # Extract shifts
            list1 = alignlog
            while (fscan(list1,line) != EOF) {
               print(reftag//": ",line,>> out)
               if (stridx("!",line) > 0) break
            }
            while (fscan(list1,line) != EOF) {
               print(reftag//": ",line,>> out)
               if (stridx("[",line) > 0)
                  break
               else {
                  stat = fscan(line,src,xs,sjunk,ys)
                  print (xs,ys,>> shifts)
               }
            }
         }
         print ("SUM_MATSUB: ",i_match//matsub," ",reftag," ",
            ref//refsub,>> out)
         print ("SUM_IMAGES: ",slist,>> out)
         list1 = cofile
         while (fscan(list1,xin,yin) != EOF) {
            print ("SUM_COARSE: ",reftag," ",xin,yin,>> out)
         }
         list1 = cofile
         while (fscan(list1,xin,yin,line) != EOF) {
            print ("SUM_COFILE: ",reftag," ",xin,yin,line,>> out)
         }
         list1 = shifts
         list2 = compfile
         list3 = imidfile
         for (i=1; ((fscan(list1,line) !=EOF) && (fscan(list2,src) !=EOF) &&
            (fscan(list3,srcsub) !=EOF)); i += 1) {
            src = substr(src,stridx("T",src)+1,strlen(src))
            print ("SUM_SHIFTS: ",line," ",src," ",srcsub,>> out)
         }
         list1="";list2="";list3=""
         if (access(compfile)) imdelete("@"//compfile,verify-)
         delete(compfile,verify-,>& "dev$null")
         delete(cofile,verify-,>& "dev$null")
         delete(imidfile,verify-,>& "dev$null")
         delete(alignlog,verify-,>& "dev$null")
         delete(shifts,verify-,>& "dev$null")
         delete(tmp1,verify-,>& "dev$null")
         delete(tmp2,verify-,>& "dev$null")
         
      }

   skip:

   # Finish up
      if (access(compfile)) imdelete("@"//compfile,verify-)
      imdelete (uniq//"*.imh", verify=no)
      delete (uniq//"*", verify=no)

   end
