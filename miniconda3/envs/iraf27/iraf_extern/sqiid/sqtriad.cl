# SQTRIAD: 24JUN93 KMM
# SQ9PAIR: 26APR93 KMM
# SQTEST: 16MAR93 KMM
# SQPROC: 06APR92 KMM
# SQPROC -- process SQIID raw image data 
# ON OFF ON ON OFF ON ...
#  1  2
#  3  2
#  4  5
#  6  5
#  7  8
#  9  8
# etc

procedure sqtriad (input, output, flatimage)

string input      {prompt="Input raw images"}
string output     {prompt="Output image descriptor: @list||.ext||%in%out%"}
string flatimage  {prompt="Input flat field image name"}

bool   fixpix     {no,prompt="Run FIXPIX on data?"}
string badpix     {"badpix", prompt="badpix file in FIXPIX format"}
bool   setpix     {no,prompt="Run SETPIX on data?"}
string maskimage  {"badmask", prompt="untransposed bad pixel image mask"}
real   blank      {0.0,prompt="Value if there are no pixels"}
bool   orient     {yes,prompt="Orient image with N up and E left"}

string norm_stat  {"none",enum="none|mean|median",
                    prompt="Match sky to object via: |none|mean|median|"}
string statsec    {"[50:200,50:200]",
                    prompt="Image section for calculating statistics"}
real   lthreshold {INDEF,prompt="Lower threshold for exclusion in statistics"}
real   hthreshold {INDEF,prompt="Upper threshold for exclusion in statistics"}

bool   verbose    {yes,prompt="Verbose output?"}
file   logfile    {"STDOUT",prompt="logfile name"}


struct  *inlist,*outlist,*imglist,*l_list

begin

   int    nin, irootlen, orootlen, stat, pos1b, pos1e, pos2b, pos2e,
          nxlotrim,nxhitrim,nylotrim,nyhitrim, ncols, nrows,
          img_num, obj_num, sky_num, ilist
   real   rnorm, rmean, rmedian, rmode, objmedian, objmean, skymedian, skymean
   string in,in1,in2,out,iroot,oroot,uniq,img,sname,sout,sbuff,sjunk,
          smean, smedian, smode, front, srcsub, color, sini, sinobj, sinsky,
          combopt, zeroopt, scaleopt, normstat, reject, souti, soutobj, soutsky
   file   blankimg,  nflat, infile, outfile, im1, im2, im3, tmp1, tmp2, tmp3,
          l_log, task, maskimg, valuimg, colorlist
   bool   found, choff, alt_state
   struct line = ""

# Assign positional parameters to local variables
   in          = input
   out         = output
   nflat       = flatimage
   normstat = norm_stat

   uniq        = mktemp ("_Tsqp")
   infile      = mktemp ("tmp$sqp")
   outfile     = mktemp ("tmp$sqp")
   tmp1        = mktemp ("tmp$sqp")
   tmp2        = mktemp ("tmp$sqp")
   tmp3        = mktemp ("tmp$sqp")
   l_log       = mktemp ("tmp$sqp")
   colorlist   = mktemp ("tmp$sqp")
   im1         = uniq // ".im1"
   im2         = uniq // ".im2"
   im3         = uniq // ".im3"
   maskimg     = uniq // ".msk"
   valuimg     = uniq // ".val"

   l_list = l_log
# check whether input stuff exists
   if ((nflat != "null") && 
      (substr(nflat,strlen(nflat)-3,strlen(nflat)) != ".imh"))
      nflat = nflat//".imh"
   if (nflat != "null" && !access(nflat)) {
      print ("Flatfield image ",nflat, " does not exist!")
      goto skip
   } else if ((stridx("@%.",out) != 1) && (stridx(",",out) <= 1)) {
# Verify format of output descriptor
      print ("Improper output descriptor format: ",out)
      print ("  Use @list or comma delimited list for fully named output")
      print ("  Use .extension for appending extension to input list")
      print ("  Use %inroot%outroot% to substitute string within input list")
      goto skip
   } else if (fixpix && !access(badpix)) {
      print ("FIXPIX file ",badpix," does not exist!")
      goto skip
   } else if (setpix && !access(maskimage)) {
      print ("SETPIX mask_image ",maskimage, " does not exist!")
      goto skip
   }

# check whether input stuff exists
   l_list = l_log
   print (in) | translit ("", "@:", "  ", >> l_log)
   stat = fscan(l_list,in1,in2)
   if (stat == 2) {			 	# color indirection requested
      choff = yes
      l_list = ""; delete (l_log,ver-,>& "dev$null")
      print (in2) | translit ("", "^jhklJHKL1234\n",del+,collapse+) |
         translit ("","JHKL1234","jhkljhkl",del-,collapse+, >> l_log)
      l_list = l_log
      stat = fscan(l_list,color)
      if (strlen (color) != strlen (in2)) {
         print ("colorlist ",in2," has colors not in jhklJHKL1234")
         goto skip
      }
      choff = yes
      nin = strlen(color)
      for (i = 1; i <= nin; i += 1) {
         sjunk = substr(color,i,i)
         print (sjunk, >> colorlist)
         sjunk = out//substr(sjunk,i,i)
         if (access(sjunk)) {			# check for output collision
            print ("Output image",sjunk, " already exists!")
            goto skip
         }
      }
   } else {					# no color indirection
      choff = no
      print ("jhkl", >> colorlist)
      if (access(out)) {			# check for output collision
         print ("Output image",out, " already exists!")
         goto skip
      }
   }

   if ((stridx("@",in) == 1) && (! access(in1))) {	# check input @file
      print ("Input file ",in1," does not exist!")
      goto skip
   }

   l_list = ""; delete (l_log,ver-,>& "dev$null")
   l_list = l_log
   print (in) | translit ("", ":", "  ", >> l_log)
   stat = fscan(l_list,in1,in2)
   sections (in1,option="nolist")
   if (sections.nimages == 0) {			# check input images
      print ("Input images in file ",in, " do not exist!")
      goto skip
   }

# Expand input file name list
#   option="root" truncates lines beyond ".imh" including section info
   sections (in1, option="root",> infile)
   if (choff) {	 			# Apply channel offset
      print ("Applying color offset: ",color)
      colorlist ("@"//infile,color,>> tmp2)
      delete (infile, ver-, >& "dev$null")
      type (tmp2,> infile)
      delete (tmp2, ver-, >& "dev$null")
   }

# Expand output image list
   if (stridx("@,",out) != 0) { 		# @-list
# Output descriptor is @-list or comma delimited list
      sections (out, option="root",> outfile)
   } else {					# namelist/substitution/append
      inlist = infile
      for (nin = 0; fscan (inlist,img) !=EOF; nin += 1) {
# Get past any directory info
         if (stridx("$/",img) != 0) {
            print (img) | translit ("", "$/", "  ", >> l_log)
            stat = fscan(l_list,img,img,img,img,img,img,img,img)
         }
         i = strlen(img)
         if (substr(img,i-3,i) == ".imh")	# Strip off trailing ".imh"
            img = substr(img,1,i-4)
# Output descriptor indicates append or substitution based on input list
         if (stridx("%",out) > 0) { 			# substitution
            print (out) | translit ("", "%", " ", >> l_log)
            stat = (fscan(l_list,iroot,oroot))
            if (stat == 1) oroot = ""
            irootlen = strlen(iroot)
            while (strlen(img) >= irootlen) {
               found = no
               pos2b = stridx(substr(iroot,1,1),img)	# match first char
               pos2e = pos2b + irootlen - 1 		# presumed match end
               pos1e = strlen(img)
               if ((pos2b > 0) && (substr(img,pos2b,pos2e) == iroot)) {
                  if ((pos2b-1) > 0) 
                     sjunk = substr(img,1,pos2b-1)
                  else
                     sjunk = ""
                  print(sjunk//oroot//
                     substr(img,min(pos2e+1,pos1e),pos1e), >> outfile)
                  found = yes
                  break
               } else if (pos2b > 0) {
                  img = substr(img,pos2b+1,pos1e)    # move past first match
               } else { 				# no match
                  found = no
                  break
               }
            }
            if (! found) { 				# no match
               print ("root ",iroot," not found in ",img)
               goto skip
            }
         } else					# name/append
            print(img//out,>> outfile)
      }
   }

   count(infile, >> l_log); count(outfile, >> l_log)
   stat = fscan(l_list,pos1b); stat = fscan(l_list,pos2b)
   if (pos1b != pos2b) {
      print ("Mismatch between input and output lists: ",pos1b,pos2b)
      join (tmp1,outfile)
      goto skip
   }
   nin = pos1b
   inlist = ""

   # Get size of final image
      inlist = infile; stat = fscan (inlist,sname)
      hedit(sname,"i_naxis1",".",>> l_log)
      stat = fscan(l_list, sjunk, sjunk, ncols)
      hedit(sname,"i_naxis2",".",>> l_log)
      stat = fscan(l_list, sjunk, sjunk, nrows)
      l_list = ""; delete (l_log,ver-,>& "dev$null")

   # send newline if appending to existing logfile
      if (access(logfile)) print("\n",>> logfile)
   # Get date
      time(> tmp1); inlist = tmp1; stat = fscan(inlist,line)
      inlist = ""; delete (tmp1, ver-, >& "dev$null")
   # Print date and id line
      print (line," SQPROC: ",>> logfile)
      print ("FLATFIELD= ",nflat,>> logfile)
      if (normstat != "none") {
         print ("Normalizing ",normstat," of sky frame to object frame."
      }

      print ("imagelist: ",nin,"images",>> logfile)
      join (infile,outfile,>> logfile)

      if (fixpix)  print ("FIXPIX according to ", badpix, " file",>> logfile)
      if (setpix) {
          print ("SETPIX to ",blank," using ", maskimage," mask",>> logfile)
          imcopy (maskimage, maskimg, verbose-) 
   # Sets bad pix to -1 and good to zero within the mask
          imarith (maskimg, "-", "1.0", valuimg)
          imarith (valuimg, "*", blank, valuimg)
      }
      if (orient) print("Orient SQIID: IMCOPY [*,-*] -> [*,*]",>> logfile)
      print("Statistics for data within ", lthreshold, " to ", hthreshold,
         >> logfile)
      imstatistics ("", fields="image,npix,mean,midpt,mode,stddev,min,max",
            lower=lthreshold,upper=hthreshold,binwidth=0.001,format+,>> logfile)
# Loop through data
      inlist=infile; outlist=outfile
      img_num = 1
      obj_num = 1
      alt_state = no
      stat = fscan (inlist,sinobj)
      stat = fscan (outlist,soutobj)
      while ((fscan (inlist,sini) != EOF) && (fscan(outlist,souti) != EOF)) {
         img_num += 1
         if (alt_state) { 
# Get raw_median value for header
            sinobj  = sini
            soutobj = souti
            obj_num = img_num
            alt_state = no
         } else {
# Get raw_median value for header
            sinsky  = sini
            sky_num = img_num
            alt_state = yes
         }
         sname = sinobj//statsec//","//sinsky//statsec
         imstatistics (sname,fields="midpt,mean",
            lower=lthreshold,upper=hthreshold,binwidth=0.001,format-,> tmp1)
# Subtract the blank image from the raw data images
         l_list = tmp1
         stat = fscan (l_list,objmedian,objmean)
         stat = fscan (l_list,skymedian,skymean)
         if (normstat == "none") {
            imarith (sinobj,"-",sinsky,im1,pix="r",calc="r",hparams="",verb-)
         } else {
            if (normstat == "mean") {
               rnorm = objmean / skymean
            } else if (normstat == "median") {
               rnorm = objmedian / skymedian
            }
            imarith (sinsky,"*",rnorm,im1,pix="r",calc="r",hparams="",verb-)
            imarith (sinobj ,"-",im1, im1,pix="r",calc="r",hparams="",verb-)
         }
         sname = sinobj
         sout  = soutobj
         print ("CALC: ", sinobj," [OBJ:",obj_num,"] - ",sinsky,
            " [SKY:",sky_num,"] = ",sout)
         l_list = ""; delete (tmp1, verify-)

   # Assume rest is uniform illumination and divide by flat
         if (nflat != "null")
            imarith (im1,"/",nflat,im1,pixtype="r",calctype="r",hpar="")
   # Bring to zero by subtracting selected norm within image subsection
         imstatistics (im1//statsec,
            fields="npix,mean,midpt,mode,stddev,min,max",
            lower=lthreshold, upper=hthreshold, binwidth=0.01, format-,>> tmp1)
         if(verbose) type (tmp1,>> logfile)

         l_list = tmp1 
         stat = fscan (l_list,sjunk,rmean,rmedian,rmode)
         l_list = ""; delete (tmp1, verify-)

   # FIXPIX
         if (fixpix) fixpix(im1, badpix, verbose-)

   # SETPIX
         if (setpix) {
            imarith (im1,"*",maskimg,im1,pix="real",calc="real",hpar="")
            if (blank != 0.0)
              imarith (im1,"-",valuimg,im1,pix="real",calc="real",hpar="")
         }

   # IMTRANSPOSE
         if (orient) imcopy(im1//"[*,-*]",im1)

         imcopy (im1, sout, verbose-,>> logfile)        
         hedit (sout,"title",sout,add-,delete-,verify-,show-,update+)
         hedit (sout,"raw_midpt",objmedian,add+,delete-,verify-,show-,update+)
         hedit (sout,"pro_midpt",rmedian,add+,delete-,verify-,show-,update+)
         imglist = ""; imdelete (im1//","//im3, verify-,>& "dev$null")
         
  # SETUP NEXT ITERATION
         if (!alt_state) {
            if ((fscan (inlist,sini) != EOF) && (fscan(outlist,souti) != EOF)) {
              img_num += 1
              sinobj  = sini
              soutobj = souti
              obj_num = img_num
            } else {
              break
            }
         }
      }

   skip:

   # Finish up
      inlist = ""; outlist = ""; imglist = ""; l_list = ""
      imdelete (im1//","//im2//","//im3,verify-,>& "dev$null")
      imdelete (maskimg//","//valuimg,verify-,>& "dev$null")
      delete (tmp1//","//tmp2//","//tmp3//","//l_log, verify-,>& "dev$null")
      delete (infile//","//outfile//","//colorlist, verify-,>& "dev$null")
   
end
