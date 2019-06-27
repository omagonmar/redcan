# LOCATE 30JAN94 KMM
# LOCATE 15JAN91 KMM
# LOCATE locate images with respect to a reference image

procedure locate (images,ref_image)

string images       {prompt="List of images to compare"}
string ref_image    {prompt="Reference image"}

string coords       {"", prompt="Input initial coordinate file"}
string in_shifts    {"", prompt="Initial shift file between ref and images"}
string interp_type  {"linear", prompt="Interpolator to be used by imshift"}
real   bigbox       {11., prompt="Size of coarse search box"}
real   boxsize      { 7., prompt="Size of final centering box"}
real   background   {INDEF,
                     prompt="Absolute reference level for marginal centroid"}
real   lower        {INDEF, prompt="Lower threshold for the data"}
real   upper        {INDEF, prompt="Upper threshold for the data"}
int    niterate     {3,
                    prompt="Maximum number of centering iterations to perform"}
real   tolerance    {0.,
                  prompt="Tolerance for convergence of the centering algorithm"}
bool   getoffset    {yes, prompt="Do you want to get frame offsets?", mode="q"}
bool   display_ref  {yes,prompt="[re]display referenced image?"}
bool   zscale       {yes, prompt="DISPLAY using zscale?"}
real   z1           {0.0, prompt="minimum greylevel to be displayed"}
real   z2           {1000.0, prompt="maximum greylevel to be displayed"}
string outfile      {"", prompt="Output information file"}
bool   verbose      {no, prompt="Verbose reporting"}

struct  *list1,*list2,*l_list
imcur   *starco

begin

      int    i,stat,nim,nin,lo,hi,ncomp,pos1b,pos1e,wcs,gridx,gridy,maxnim,
             nxmos0, nymos0, nxmat0, nymat0, nxref0, nyref0, nxoff0, nyoff0
      int    nxlo, nxhi, nylo, nyhi, nxlonew, nxhinew, nylonew, nyhinew
      real   xin, yin, xref, yref, xs, ys, fxs,fys,
             xshift,yshift,xlo,xhi,ylo,yhi
      string l_images,l_coords,out,uniq,sjunk,slog,sname,key,
             ishifts,refid,img,refimg,reftag,imtag,refsub,tmpimg,
             imname,trimsec,vigsec,serr
      file   cofile,l_log,alignlog,inshifts,
             compfile,tmp1,tmp2
      bool   getcoords,gotoffset,shifts_found,trim_found
      struct command = ""
      struct line = ""

      l_images    = images
      refimg      = ref_image
      l_coords    = coords
      tmp1        = mktemp ("tmp$gcm")
      tmp2        = mktemp ("tmp$gcm")
      compfile    = mktemp ("tmp$gcm")
      inshifts    = mktemp ("tmp$gcm")
      alignlog    = mktemp ("tmp$gcm")
      l_log       = mktemp ("tmp$gcm")
      cofile      = mktemp ("tmp$gcm")
      gotoffset   = no
      reftag      = refimg//"_ref"
      out         = outfile

      l_list = l_log
 
      sections (l_images, option="full",>> compfile)
      list1 = compfile
      stat  = fscan(list1,img)
      if (display_ref) {
         if (zscale) 	# DISPLAY using zscale+
            print ("display "//img//" 1 zscale+ zr- fi-" ) | cl
         else {
         print ("display "//img//" 1 zs- zr- z1="//z1//" z2="//z2//" fi-" ) | cl
         }
      }
      if (l_coords == "" || l_coords == "null" || l_coords == " ") {
         frame (1)
         print ("Mark target objects in reference frame:")
         print ("Allowed keystrokes: |f(find)|spacebar(find&use)|q(quit)|")
         while (fscan(starco,xin,yin,wcs,command) != EOF) {
            if (substr(command,1,1) == "\\")
               key = substr(command,2,4)
            else
               key = substr(command,1,1)
            if (key == "f")
               print ("Star_coordinates= ",xin,yin)
            else if (key == "040") {			# 040 == spacebar
               imcntr (refimg, xin, yin,>> l_log)	# Improve center
               stat = fscan (l_list, line)
               print ("Star_coordinates= ",xin,yin," ;imcntr= ",line)
  # Format (Star_coordinates= xin yin ;imcntr= imageid x: xcenter y: ycenter)
               stat = fscan(line,sjunk,sjunk,xin,sjunk,yin)
               print (xin,yin,>> cofile)
            } else if (key == "q")
               break
            else {
               print("Unknown keystroke: ",key," allowed = |f|spacebar|q|")
               beep
            }
         }
      } else {
         match ("^SUM_COFILE",l_coords,meta+,stop-,print-,>> tmp1)
         count (tmp1,>> l_log); stat = fscan(l_log,i)
         if (i > 0) {
           list2 = tmp1    
  # Format ("SUM_COFILE: ",xin,yin," ",reftag," ",line)
            while (fscan(list2,sjunk,xin,yin) != EOF) {
               print (xin,yin,>> cofile)
            }
         } else {
           list2 = l_coords
            while (fscan(list2,xin,yin) != EOF) {
               print (xin,yin,>> cofile)
            }
         }
      }
      if (verbose) print ("Submitted star_coordinates:"); type (cofile)
      delete(l_log,ver-,>& "dev$null"); l_list = l_log	# Reset l_log

  # Get individual frame offsets if outside range of coarse pass

      if (in_shifts == "" || in_shifts == " " || in_shifts == "null") {
         if (getoffset) {
            frame (1)
            delete (tmp2, ver-, >& "dev$null")
            print ("Select star for reference frame 1")
            while (fscan(starco,xref,yref,wcs,command) != EOF) {
               if (substr(command,1,1) == "\\")
                  key = substr(command,2,4)
               else
                  key = substr(command,1,1)
               if (key == "f")
                  print ("Ref_coordinates= ",xref,yref)
               else if (key == "040") {			# 040 == spacebar
                  imcntr (refimg, xref, yref,>> l_log)	# Improve center
                  stat = fscan(l_list,sjunk,sjunk,xref,sjunk,yref)
                  print ("Submitted ref_coordinates= ",xref,yref)
                  print ("0 0",>> inshifts)
                  gotoffset = yes
                  break
               } else if (key == "q") {
                  gotoffset = no
                  break
               }
            }
            print("Allowed keystrokes: |f(find)|spacebar(find&use)|q(skip)|")
            for (i = 1; fscan(list1,img) != EOF ; i += 1) { 
               if (zscale) 	# DISPLAY using zscale+
                  print ("display "//img//" 2 zscale+ zr- fi-" ) | cl
               else
          print ("display "//img//" 2 zs- zr- z1="//z1//" z2="//z2//" fi-") | cl
               frame (2)
               print ("Select star for image#",i," in frame 2")
               while (fscan(starco,xin,yin,wcs,command) != EOF) {
                  if (substr(command,1,1) == "\\")
                     key = substr(command,2,4)
                  else
                     key = substr(command,1,1)
                  if (key == "f") {
                     imcntr (img, xin, yin,>> l_log)	# Improve center
                     stat = fscan(l_list,sjunk,sjunk,xin,sjunk,yin)
                     print ("Star_coordinates= ",xin,yin)
                     xin = xref - xin; yin = yref - yin
                     print ("Offset for frame ",i,xin,yin)
                  } else if (key == "040") {		# 040 == spacebar
                     print ("Selected star_coordinates= ",xin,yin)
                     xin = xref - xin; yin = yref - yin
                     print ("Submitted offset for frame ",i,xin,yin)
                     print (xin,yin,>> inshifts)
                     break
                  } else if (key == "q") {
                     print ("0 0",>> inshifts)
                     break
                  } else {
                     print("Unknown key: ",key," allowed = |f|spacebar|q|")
                     beep
                  }
               }
            }
            if (verbose) print ("Submitted frame offsets:"); type (inshifts)
            if (gotoffset)
               ishifts = inshifts	# newly aquired offset file
            else
               ishifts = ""		# null offset file

         } else
            ishifts = ""		# null offset file

      } else
          ishifts=in_shifts	# prior offset file

      print ("IMCENTROID:")
      imcentroid (l_images, cofile, reference=refimg, shifts=ishifts,
	    boxsize=boxsize, bigbox=bigbox, negative-,
	    background=background, lower=lower, upper=upper,
	    niterate=niterate, tolerance=tolerance, verbose+,>& alignlog)
      if (verbose) type(alignlog,>> out)		 # Log imalign output
   #Extract shifts
      list1 = alignlog
      while (fscan (list1, line) != EOF) {
         if (stridx ("!", line) != 0) {
	    shifts_found = yes
	    break
	  }
      }
      if (shifts_found)
         while (fscan (list1, sname, xshift,sjunk,yshift,sjunk,nim,serr) == 7)
            print ("SUM_SHIFTS: ",xshift,yshift," ",sname," ",nim,serr,>> out)
      else
         error (1, "No shifts were calculated.")

   # read and correct the trim section
      trim_found = no
      while (fscan (list1, line) != EOF) {
         if (stridx("[",line) <= 0)
            next
            
         stat = fscan (line, nxlo, nxhi, nylo, nyhi)
	 vigsec = "["//nxlo //":"// nxhi //","// nylo //":"// nyhi//"]"
   # correct for boundary extension "contamination"
	 if (interp_type == "poly3")
		{ nxlo += 1; nxhi -= 1; nylo += 1; nyhi -= 1 }
	 else if (interp_type == "poly5" || interp_type == "spline3")
		{ nxlo += 2; nxhi -= 2; nylo += 2; nyhi -= 2 }

	 if (1 <= nxlo && nxlo <= nxhi && 1 <= nylo && nylo <= nyhi) {
	    trimsec = "["//nxlo //":"// nxhi //","// nylo //":"// nyhi//"]"
            print("OVERLAP: ",vigsec," ",trimsec," ",reftag,>> out)

	 } else
	    print ("Images not trimmed!  No overlap region.")

         trim_found = yes
         break

      }
      if (!trim_found)
	 print ("Images not trimmed!  Problem with the trim section.")
      list1 = cofile
      while (fscan(list1,xin,yin,line) != EOF) {	# Report search coords
         print ("SUM_COFILE: ",xin,yin," ",reftag," ",line,>> out)
      }
      if (ishifts != "") {				# Report any offsets
         list1 = ishifts
         while (fscan(list1,xin,yin) != EOF) {
            print ("SUM_OFFSET: ",xin,yin," ",reftag,>> out)
         }
      }

   # Finish up
skip:

      list1=""; list2=""; l_list=""
      delete (tmp1//","//tmp2,ver-, >& "dev$null")
      delete (alignlog//","//inshifts, ver-,>& "dev$null")
      delete (cofile//","//compfile//","//l_log, ver-,>& "dev$null")

end
