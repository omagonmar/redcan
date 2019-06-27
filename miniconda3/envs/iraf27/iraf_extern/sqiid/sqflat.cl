# SQFLAT: 01DEC92 KMM
# SQFLAT -- Create IR flat from data frames.
# SQFLAT: 01DEC92 incorporates Valdes' IRAF2.10EXPORT version 2 IMCOMBINE
# SQFLAT: 19MAY92 KMM

procedure sqflat (input, output, darkimage)

string input      {prompt="Input raw sky images"}
string output     {prompt="Output normalized flat_field image"}
string darkimage  {prompt='Input dark_count image ("null"==noaction)'}

string ref_flat   {"",prompt="Reference normalized flat_field images"}
string common     {"none",enum="none|mean|median|mode",
                    prompt="Pre-combine common offset: |none|median|mode|"}
string prenorm    {"median",enum="none|median|mode",
                    prompt="Pre-combine frame divisor: |none|median|mode|"}
string imscale    {"none",enum="none|median|mode",
                    prompt="imcombine scale option: |none|median|mode|"}
string statsec    {"[50:200,50:200]",
                    prompt="Image section for calculating statistics"}
string comb_opt   {"median", enum="average|median",
                       prompt="Type of combine operation: |average|median|"}
string reject_opt {"none", prompt="Type of pixel rejection operation",
                    enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip"}
bool   mclip      {no, prompt="Use median, not mean, in clip algorithms"}
real   pclip      {-0.5, prompt="pclip: Percentile clipping parameter"}
real   lthreshold {INDEF,prompt="Lower threshold for exclusion in statistics"}
real   hthreshold {INDEF,prompt="Upper threshold for exclusion in statistics"}
real   lo_reset   {0.1,prompt="Lower limit for exclusion in output"}
real   hi_reset   {2.0,prompt="Upper limit for exclusion in output"}
real   blank      {0.1,prompt="Value if there are no pixels"}
string weight     {"none",prompt="Image weights"}

string expname    {"", prompt="Image header exposure time keyword"}
int    nlow       {1, prompt="minmax: Number of low pixels to reject"}
int    nhigh      {1, prompt="minmax: Number of high pixels to reject"}
int    nkeep        {0, prompt="Min to keep (pos) or max to reject (neg)"}
real   lsigma     {3., prompt="Lower sigma clipping factor"}
real   hsigma     {3., prompt="Upper sigma clipping factor"}
string rdnoise    {"0.", prompt="ccdclip: CCD readout noise (electrons)"}
string gain       {"1.", prompt="ccdclip: CCD gain (electrons/DN)"}
string snoise       {"0.", prompt="ccdclip: Sensitivity noise (fraction)"}
real   sigscale   {0.1,
                     prompt="Tolerance for sigma clipping scaling correction"}
int    grow       {0, prompt="Radius (pixels) for 1D neighbor rejection"}
   
file   logfile    {"STDOUT", prompt="Log file name"}
bool   verbose    {yes,prompt="Verbose output?"}

struct  *list1, *list2, *l_list

begin

   int    i, nin, nout, stat, pos1b, pos1e, n_opt, r_opt, c_opt, nim, maxnim
   real   rnorm, rmedian, rmode,
          ddelta, avenorm, avemedian, avemode, stddev, number,
          stddev_median,stddev_mode
   string in, in1, in2, dark, darkfull, out, outfull, uniq, sbuff, sjunk,
          color, scolor, img, sname, sdarksub, smedian, smode, first, vcheck,
          combopt, reject, scale, pre_norm, im_scale
   file   imfile,subfile,secfile,tmp1,tmp2,medianfile,modefile,
          colorlist, tmpimg,refimg,l_log
   bool   choff,update
   struct line = ""

# Assign positional parameters to local variables

   in         = input
   out        = output
   if (substr(out,strlen(out)-3,strlen(out)) == ".imh")
      out = substr(out,1,strlen(out)-4)
   dark       = darkimage
   if (substr(dark,strlen(dark)-3,strlen(dark)) == ".imh")
      dark = substr(dark,1,strlen(dark)-4)
   uniq        = mktemp ("_Tsqf")
   l_log       = mktemp ("tmp$sqf")
   imfile      = mktemp ("tmp$sqf")
   subfile     = mktemp ("tmp$sqf")
   secfile     = mktemp ("tmp$sqf")
   medianfile  = mktemp ("tmp$sqf")
   modefile    = mktemp ("tmp$sqf")
   tmp1        = mktemp ("tmp$sqf")
   tmp2        = mktemp ("tmp$sqf")
   colorlist   = mktemp ("tmp$sqf")
   tmpimg      = uniq // ".img"
   refimg      = uniq // ".rim"

   reject  = reject_opt
   im_scale = imscale
   pre_norm = prenorm
   if (pre_norm == "none")   n_opt = 0
   if (pre_norm == "median") n_opt = 2
   if (pre_norm == "mode")   n_opt = 3
   if (im_scale == "none")   r_opt = 0
   if (im_scale == "median") r_opt = 2
   if (im_scale == "mode")   r_opt = 3
# check IRAF version
   sjunk = cl.version			# get CL version
   stat = fscan(sjunk,vcheck)
   if (stridx("Vv",vcheck) <=0 )	# first word isn't version!
      stat = fscan(sjunk,vcheck,vcheck)

   if (verbose) print ("IRAF version: ",vcheck)
   if (substr(vcheck,1,4) > "V2.1") {	# old IMCOMBINE ( <= 2.9 )
      update = no
      if (reject == "minmax") {
         combopt = "minmax"
      } else
         combopt = comb_opt
   } else {				# new IMCOMBINE ( >= 2.10 )
      update = yes
      combopt = comb_opt
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
      stat = fscan(l_list,scolor)
      if (strlen (scolor) != strlen (in2)) {
         print ("colorlist ",in2," has colors not in jhklJHKL1234")
         goto skip
      }
      choff = yes
      nin = strlen(scolor)
      for (i = 1; i <= nin; i += 1) {
         color = substr(scolor,i,i)
         print (color, >> colorlist)
         outfull = out//color
         if (access(outfull//".imh")) {	# check for output collision
            print ("Output image ",sjunk, " already exists!")
            goto skip
         }
         sjunk = dark//color
         if (dark != "null" && !access(sjunk//".imh")) { # check for dark
            print ("Blank image ",sjunk, " does not exist!")
            goto skip
         }
      }
   } else {					# no color indirection
      choff = no
      print ("jhkl", >> colorlist)
      if (access(out) || access(out//".imh")) {	# check for output collision
         print ("Output image",out, " already exists!")
         goto skip
      }
      if (substr(dark,strlen(dark)-3,strlen(dark)) == ".imh")
         sjunk=  substr(dark,1,strlen(dark)-4)
      else
         sjunk = dark
      if ((dark != "null") && (!access(sjunk//".imh"))) {
         print ("Blank image ",dark, " does not exist!")
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

# Expand input file name list removing the ".imh" extensions
   sections (in1, option="root") | match ("\#",meta+,stop+,print-,> tmp1)
   if (choff) {	 			# Apply channel offset
      print ("Applying color offset: ",color)
      colorlist ("@"//tmp1,color,>> tmp2)
      delete (tmp1, ver-, >& "dev$null")
      type (tmp2,> tmp1)
      delete (tmp2, ver-, >& "dev$null")
      outfull = out//color
      if (dark != "null")
         darkfull = dark//color
      else
         darkfull = dark
   } else {
      outfull = out
      darkfull = dark
   }
# Generate temporary data list for dark subtracted frames
#   option="root" truncates lines beyond ".imh"
   list1 = tmp1  
   for (nin = 0; fscan (list1,img) !=EOF; nin += 1) {
# Strip off trailing ".imh"
      i = strlen(img)
      if (substr(img,i-3,i) == ".imh") img = substr(img,1,i-4)
      print (img,>> imfile)
      sname = uniq//"_"//nin
      print (sname,>> subfile)
      print (sname//statsec,>> secfile)
   } 
   nout = nin
# handle exceptions when comb_opt is inappropriate for #images
   if (! update) {
      if (nout <= 2 && combopt == "median" ) 
         combopt = "average"
      else if (nout <= 2 && combopt == "minmax" ) 
         combopt = "average"
      else
         combopt = combopt
   }
   list1 = ""; delete (tmp1, ver-, >& "dev$null")

# send 2 newlines if appending to existing logfile
   if (access(logfile)) print("\n",>> logfile)
# Get date
   time(> tmp1); list1 = tmp1; stat = fscan(list1,line)
   list1 = ""; delete (tmp1, ver-, >& "dev$null")
# Print date and id line
   print (line," SQFLAT: ",outfull ,>> logfile)
   print (line," SQFLAT: ",outfull)
   print ("SUBTRACTED DARK= ",darkfull,>> logfile)

   if (darkfull == "null")
      imcopy("@"//imfile,"@"//subfile,verbose-)
   else			 # Subtract the dark image from the raw input images.
      imarith("@"//imfile,"-",darkfull,"@"//subfile,pix="",calc="",hparams="")

# Get ref_flat images
   sections (ref_flat,opt="root") | match ("\#",meta+,stop+,print-,> tmp1)
   list1 = tmp1  
   for (i = nout; fscan (list1,img) !=EOF; i += 1) {
      print (img,>> imfile)
      sname = uniq//"_"//i
      print (sname,>> subfile)
      print (sname//statsec,>> secfile)
      imcopy(img,sname,verbose-)
      nout += 1
   } 
   list1 = ""; delete (tmp1, ver-, >& "dev$null")
   if (nout != nin) {
      if (comb_opt == "median" && mod(nout,2) == 0) {
         print (img,>> imfile)
         sname = uniq//"_"//nout
         print (sname,>> subfile)
         print (sname//statsec,>> secfile)
         imcopy(img,sname,verbose-)
         nout += 1
      }
   }

# Determine image statistics within image subsection for producing flats

   print ("imagelist: ",nout,"images",>> logfile)
   if (pre_norm != "none") {
      imstatistics("@"//secfile,fields="npix,midpt,mode,stddev,min,max",
         lower=lthreshold,upper=hthreshold,binwidth=0.001,format-,> tmp1)
      if (verbose) {
         imstatistics(" ",fields="image,npix,midpt,mode,stddev,min,max",
         lower=lthreshold,upper=hthreshold,binwidth=0.001,format+,>> logfile)
         join(imfile,tmp1,out="STDOUT",delim=" ",miss="Missing",
               maxchar= 161, shortest-,verbose+,>> logfile)
      } else {
         type (imfile, >> logfile)
      }
      list2 = subfile
      list1 = tmp1
      for (i = 1; ((fscan(list1,sjunk,smedian, smode) != EOF) &&
         (fscan(list2,sname) != EOF)); i += 1) {
         sbuff = sname//" "//smedian//" "//smode
         print(sbuff,>> tmp2)
# Exclude any reference flats
         if (i <= nin) {
            print(smedian,>> medianfile)
            print(smode,>> modefile)
         }
      }
      list2 = ""; list1 = ""; delete (tmp1, ver-, >& "dev$null")

# compute average mean, median, and mode
      average("new_sample",< medianfile,>> tmp1)
      average("new_sample",< modefile,>> tmp1)
      list1 = tmp1
      stat = fscan(list1,avemedian,stddev_median,number)
      stat = fscan(list1,avemode,stddev_mode,number)
      stddev_median = 0.0001*real(nint(10000.0*stddev_median))
      stddev_mode   = 0.0001*real(nint(10000.0*stddev_mode))
      print("ave_median=",avemedian," ave_mode=",avemode,>> logfile)
      print("dev_median=",stddev_median," dev_mode=",stddev_mode,>> logfile)
      list1 = ""; delete (tmp1, ver-, >& "dev$null")
# Select normalization and normalize
      list1  = tmp2
      while(fscan(list1,sname,rmedian,rmode) != EOF) {
         switch(n_opt) {
           case 0:
              rnorm = 1.0
           case 2:
              rnorm = rmedian
           case 3:
              rnorm = rmode
         }
         imarith (sname,"/",rnorm,sname,pixtype="",calctype="",hparams="")
      }
      list1 = ""; delete (tmp2, ver-, >& "dev$null")
   }

# Log process prior to imcombine
   if (!update) {
      print(combopt," filtering images divided by their ",pre_norm,
        " within ",statsec,>> logfile)
      print(combopt," filtering images divided by their ",pre_norm,
        " within ",statsec)
      if (common != "none") {
         print("WARNING: unable to offset to common ",common,
            " prior to IMCOMBINE!")
      }
   } else {
      if (common != "none") {
         print(combopt," filtering images offset to a common ",
            common," divided by their ",prenorm," and scaled by their ",
            im_scale, " within ",statsec,>> logfile)
         print(combopt," filtering images offset to a common ",
            common," divided by their ",prenorm," and scaled by their ",
            im_scale, " within ",statsec)
      } else {
         print(combopt," filtering images divided by their ",prenorm,
            " and scaled by their ",im_scale, " within ",statsec,>> logfile)
         print(combopt," filtering images divided by their ",prenorm,
            " and scaled by their ",im_scale, " within ",statsec)
      }
   }
# Generate flat shape
   if (!update) {
      print ("Performing IMCOMBINE: combine= ",combopt," output= ",outfull)
      print ("Performing IMCOMBINE: combine= ",combopt," output= ",outfull,
         >> logfile)
      imcombine("@"//subfile,outfull,sigma="",logfile=logfile,
         option=combopt,outtype="real",expname="",exposure-,scale-,offset-,
         weight-,modesec="",lowreject=lsigma,highreject=hsigma,blank=blank)

   } else {
      print ("Performing IMCOMBINE: reject= ",reject," combine= ",
         combopt," output= ", outfull)
      print ("Performing IMCOMBINE: reject= ",reject," combine= ",
         combopt," output= ", outfull,>> logfile)
      imcombine("@"//subfile,outfull,plfile="",sigma="",logfile=logfile,
         combine=combopt,reject=reject,project-,outtype="real",
         offsets="none",masktype="none",maskvalue=0,blank=blank,
         scale=im_scale,zero=common,weight=weight,statsec=statsec,
         expname=expname,lthreshold=lthreshold,hthreshold=hthreshold,
         nlow=nlow,nhigh=nhigh,nkeep=nkeep,mclip=mclip,lsigma=lsigma,
         hsigma=hsigma,expname=expname,rdnoise=rdnoise,gain=gain,
         sigscale=sigscale,snoise=snoise,pclip=pclip,grow=grow)
   }

   if (im_scale != "none") {
# Renormalize with the norm of selected section.  Neccessary when imcombined
#    with imscale != "none"
#         bscale (outfull,bzero=0.0,bscale=scale,section=statsec,step=1,
#            logfile="STDOUT", noact-) 
   # Print out statistics and normalization option selected
      imstatistics (outfull//statsec,
         fields="image,npix,midpt,mode,stddev,min,max",
         lower=lthreshold,upper=hthreshold,binwidth=0.001,format-,> tmp1)
   # Print out statistics and normalization option selected
      if(verbose) type (tmp1,>> logfile)

      list1 = tmp1
      stat = fscan(list1,sname,sjunk,rmedian,rmode)
      switch (r_opt) {
         case 0:
            rnorm = 1.0
         case 2:
            rnorm = rmedian
         case 3:
            rnorm = rmode
      }
      list1 = ""; delete (tmp1, ver-, >& "dev$null")
      print("Output normalized by: ",imscale//"= ", rnorm,>> logfile)
      imarith(outfull,"/",rnorm,outfull,pixtype="",calctype="",hparams="")
   }

# Clip to within range
   if (verbose) print("Clipping output outside: ",lo_reset," to ",hi_reset)
   print("Clipping output outside: ",lo_reset," to ",hi_reset,>> logfile)
   if (lo_reset != INDEF)
      imreplace(outfull,lo_reset,lower=INDEF,upper=lo_reset)
   if (hi_reset != INDEF)
      imreplace(outfull,hi_reset,lower=hi_reset,upper=INDEF)

   hedit (outfull,"title",outfull,add-,delete-,verify-,show-,update+)

# Finish up
skip:

   imdelete(uniq//"*.imh",verify-)
   delete  (l_log//","//colorlist//","//uniq//"*",verify-,>& "dev$null")
   delete  (imfile//","//subfile//","//secfile//","//tmp1,ver-,>& "dev$null")
   delete  (medianfile//","//modefile//","//tmp2,verify-,>& "dev$null")

end
