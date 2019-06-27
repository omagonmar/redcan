# SQSKY: 10JUN94 KMM
# SQSKY -- Create IR flat from sky frames.
# SQSKY: 10JUN94 KMM - fix typos in parameter file
# SQSKY: 17DEC92 KMM - reorganizes parameters to better reflect IMCOMBINE
# SQSKY: 01DEC92 KMM - incorporates Valdes' IRAF2.10EXPORT version 2 IMCOMBINE
# SQSKY: 20NOV92 KMM - allow scaling of darksubtracted images prior to imcombine
# SQSKY: 21OCT92 KMM

procedure sqsky (input, output)

string input      {prompt="Input raw sky images"}
string output     {prompt="Output sky image"}

string darkimage  {"null",prompt='Input dark_count image ("null"==noaction)'}
string norm_opt   {"zero", enum="zero|scale|none",
                      prompt="Type of pre-combine operation: |zero|scale|none|"}
string norm_stat  {"median",enum="none|mean|median|mode",
                 prompt="Pre-combine common statistic: |none|mean|median|mode|"}
string comb_opt   {"median", enum="average|median",
                       prompt="Type of combine operation: |average|median|"}
string reject_opt {"none", prompt="Type of pixel rejection operation",
                    enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip"}
string statsec    {"[50:200,50:200]",
                    prompt="Image section for calculating statistics"}
bool   mclip      {no, prompt="Use median, not mean, in clip algorithms"}
real   pclip      {-0.5, prompt="pclip: Percentile clipping parameter"}
real   lthreshold {INDEF,prompt="Lower threshold for exclusion in statistics"}
real   hthreshold {INDEF,prompt="Upper threshold for exclusion in statistics"}
real   blank      {0.1,prompt="Value if there are no pixels"}
string weight     {"none",prompt="Image weights"}
string expname    {"", prompt="Image header exposure time keyword"}
int    nlow       {1, prompt="minmax: Number of low pixels to reject"}
int    nhigh      {1, prompt="minmax: Number of high pixels to reject"}
int    nkeep      {0, prompt="Min to keep (pos) or max to reject (neg)"}
real   lsigma     {3., prompt="Lower sigma clipping factor"}
real   hsigma     {3., prompt="Upper sigma clipping factor"}
string rdnoise    {"0.", prompt="ccdclip: CCD readout noise (electrons)"}
string gain       {"1.", prompt="ccdclip: CCD gain (electrons/DN)"}
string snoise     {"0.", prompt="ccdclip: Sensitivity noise (fraction)"}
real   sigscale   {0.1,
                     prompt="Tolerance for sigma clipping scaling correction"}
int    grow       {0, prompt="Radius (pixels) for 1D neighbor rejection"}
   
file   logfile    {"STDOUT", prompt="Log file name"}
bool   verbose    {yes,prompt="Verbose output?"}

struct  *list1, *list2, *list3, *l_list

begin

   int    i, nin, nout, stat, c_opt, nim, maxnim
   real   rnorm, rmedian, rmode,
          ddelta, avemean, avenorm, avemedian, avemode, stddev, number,
          stddev_mean, stddev_median,stddev_mode
   string in, in1, in2, dark, out, outfull, uniq,  sbuff, sjunk, color,
          img, sname, sdarksub, smean, smedian, smode, first, vcheck,
          combopt, reject, scale, darkfull, scolor,
          normstat, scaleopt, zeroopt
   file   imfile,subfile,secfile,tmp1,tmp2,meanfile,medianfile,modefile,
          colorlist, l_log,rootfile
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
   meanfile    = mktemp ("tmp$sqf")
   tmp1        = mktemp ("tmp$sqf")
   tmp2        = mktemp ("tmp$sqf")
   colorlist   = mktemp ("tmp$sqf")
   rootfile    = mktemp ("tmp$sqf")

# check IRAF version
   reject  = reject_opt
   sjunk = cl.version			# get CL version
   stat = fscan(sjunk,vcheck)
   if (stridx("Vv",vcheck) <=0 )	# first word isn't version!
      stat = fscan(sjunk,vcheck,vcheck)
   if (verbose) print ("IRAF version: ",vcheck)
   if (substr(vcheck,1,4) > "V2.1") {
      update = no
      if (reject == "minmax") {
         combopt = "minmax"
      } else
         combopt = comb_opt
      if (norm_opt == "scale") {
         print ("Norm_opt:scale only available in IRAF2.10 and later!")
         goto skip
      }
   } else {
      update = yes
      combopt = comb_opt
   }
   normstat = norm_stat
   if (norm_opt == "zero") {
      scaleopt  = "none"
      zeroopt   = normstat
   } else if (norm_opt == "scale") {
      scaleopt  = normstat
      normstat  = normstat
      zeroopt   = "none"
   } else {
      scaleopt  = "none"
      zeroopt   = "none"
      normstat  = "none"
   }

   if (norm_stat == "none")   c_opt = 0
   if (norm_stat == "mean")   c_opt = 1
   if (norm_stat == "median") c_opt = 2
   if (norm_stat == "mode")   c_opt = 3

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
         sjunk = out//color
         if (access(sjunk//".imh")) {		# check for output collision
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
         print ("Output image ",out, " already exists!")
         goto skip
      }
      if (substr(dark,strlen(dark)-3,strlen(dark)) == ".imh")
         sjunk= substr(dark,1,strlen(dark)-4)
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

   l_list = ""; delete (l_log,ver-,>& "dev$null"); l_list = l_log
   print (in) | translit ("", ":", "  ", >> l_log)
   stat = fscan(l_list,in1,in2)
   sections (in1,option="nolist")
   if (sections.nimages == 0) {			# check input images
      print ("Input images in file ",in, " do not exist!")
      goto skip
   }

   delete (tmp1, ver-, >& "dev$null")
   sections (in1, option="root") | match ("\#",meta+,stop+,print-,> rootfile)
   list3 = colorlist
   while (fscan(list3, color) != EOF) {
      if (choff) {	 			# Apply channel offset
         print ("Applying color offset: ",color)
         colorlist ("@"//rootfile,color,>> tmp1)
         i = strlen(out)
         if (substr(out,i-3,i) == ".imh") out = substr(out,1,i-4)
         outfull = out//color
         if (dark != "null")
            darkfull = dark//color
         else
            darkfull = dark
         if (verbose) type (tmp1)
      } else {
         copy (rootfile, tmp1)
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
      print (line," SQSKY: ",outfull,>> logfile) 	# Print date and id line
      print (line," SQSKY: ",outfull)
      print ("SUBTRACTED DARK= ",darkfull,>> logfile)

      if (darkfull == "null")
         imcopy("@"//imfile,"@"//subfile,verbose-)
      else		 # Subtract the dark image from the raw input images.
         imarith("@"//imfile,"-",darkfull,"@"//subfile,pix="",calc="",hparam="")

# Determine image statistics within image subsection for producing flats

      print ("imagelist: ",nout,"images",>> logfile)
      if (!update) {
         imstatistics("@"//secfile,fields="npix,mean,midpt,mode,stddev,min,max",
            lower=lthreshold,upper=hthreshold,binwidth=0.001,format-,> tmp1)
         if (verbose) {
            imstatistics(" ",fields="image,npix,mean,midpt,mode,stddev,min,max",
            lower=lthreshold,upper=hthreshold,binwidth=0.001,format+,>> logfile)
            join(imfile,tmp1,out="STDOUT",delim=" ",miss="Missing",
               maxchar= 161, shortest-,verbose+,>> logfile)
         } else {
            type (imfile, >> logfile)
         }
         list2 = subfile
         list1 = tmp1
         for (i = 1; ((fscan(list1,sjunk,smean, smedian, smode) != EOF) &&
            (fscan(list2,sname) != EOF)); i += 1) {
            sbuff = sname//" "//smean//" "//smedian//" "//smode
            print(sbuff,>> tmp2)
# Exclude any reference flats
            if (i <= nin) {
               print(smean,>> meanfile)
               print(smedian,>> medianfile)
               print(smode,>> modefile)
            }
         }
         list2 = ""; list1 = ""; delete (tmp1, ver-, >& "dev$null")

# compute average mean, median, and mode
         average("new_sample",< meanfile,>> tmp1)
         average("new_sample",< medianfile,>> tmp1)
         average("new_sample",< modefile,>> tmp1)
         list1 = tmp1
         stat = fscan(list1,avemean,stddev_mean,number)
         stat = fscan(list1,avemedian,stddev_median,number)
         stat = fscan(list1,avemode,stddev_mode,number)
         stddev_mean   = 0.0001*real(nint(10000.0*stddev_mean))
         stddev_median = 0.0001*real(nint(10000.0*stddev_median))
         stddev_mode   = 0.0001*real(nint(10000.0*stddev_mode))
         print("ave_mean=",avemean,"a ve_median=",avemedian,
            " ave_mode=",avemode,>> logfile)
         print("dev_mean=",stddev_mean,"dev_median=",stddev_median,
            " dev_mode=",stddev_mode,>> logfile)
         list1 = ""; delete (tmp1, ver-, >& "dev$null")
         if (normstat != "none") {
            switch(c_opt) {
               case 0:
                  avenorm = 0.0
               case 1:
                  avenorm = avemean
               case 2:
                  avenorm = avemedian
               case 3:
                  avenorm = avemode
            }
         }
# Select normalization and normalize
         list1  = tmp2
         while(fscan(list1,sname,rmean,rmedian,rmode) != EOF) {
            if (normstat != "none") {
               switch(c_opt) {
                 case 0:
                    ddelta = 0.0
                 case 1:
                    ddelta = rmean - avenorm
                 case 2:
                    ddelta = rmedian - avenorm
                 case 3:
                    ddelta = rmode - avenorm
               }
            imarith (sname,"-",ddelta,sname,pixtype="",calctype="",hparams="")
            }
         }
         list1 = ""; delete (tmp2, ver-, >& "dev$null")

# Log process prior to imcombine
         if (normstat != "none") {
            print(combopt," filtering unnormalized images offset to a common ",
               normstat," of ",avenorm," within ",statsec,>> logfile)
         } else {
            print(combopt," filtering unnormalized images",>> logfile)
         }
      } else {
# Log process prior to imcombine
         if (normstat != "none") {
            print(combopt," filtering unnormalized images offset to a common ",
               normstat," within ",statsec,>> logfile)
         } else {
            print(combopt," filtering unnormalized images",>> logfile)
         }
      }
# Generate sky frame
      if (!update) {
         print ("Performing IMCOMBINE: combine= ",combopt,
            " norm_opt= ",norm_opt," output= ",outfull)
         print ("Performing IMCOMBINE: combine= ",combopt,
            " norm_opt= ",norm_opt," output= ",outfull,>> logfile)
         imcombine("@"//subfile,outfull,sigma="",logfile=logfile,
            option=combopt,outtype="real",expname="",exposure-,scale-,offset-,
            weight-,modesec="",lowreject=lsigma,highreject=hsigma,blank=blank)
      } else {
         print ("Performing IMCOMBINE: reject= ",reject," combine= ",
            combopt," norm_opt= ",norm_opt," output= ", outfull)
         print ("Performing IMCOMBINE: reject= ",reject," combine= ",
            combopt," norm_opt= ",norm_opt," output= ", outfull,>> logfile)
         imcombine("@"//subfile,outfull,plfile="",sigma="",logfile=logfile,
            combine=combopt,reject=reject,project-,outtype="real",
            offsets="none",masktype="none",maskvalue=0,blank=blank,
            scale=scaleopt,zero=zeroopt,weight=weight,statsec=statsec,
            expname=expname,lthreshold=lthreshold,hthreshold=hthreshold,
            nlow=nlow,nhigh=nhigh,nkeep=nkeep,mclip=mclip,lsigma=lsigma,
            hsigma=hsigma,expname=expname,rdnoise=rdnoise,gain=gain,
            sigscale=sigscale,snoise=snoise,pclip=pclip,grow=grow)
      }

      if (darkfull != "null")
         imarith(outfull,"+",darkfull,outfull,pixtype="",calctype="",hparams="")

      hedit (outfull,"title",outfull,add-,delete-,verify-,show-,update+)
      imdelete("@"//subfile,verify-)
      delete  (l_log,verify-,>& "dev$null")
      delete  (imfile//","//subfile//","//secfile//","//tmp1,ver-,>& "dev$null")
      delete  (medianfile//","//modefile//","//meanfile,verify-,>& "dev$null")
   }
   
# Finish up
skip:
   list1 = ""; list2 = ""; list3 = ""; l_list = ""
   imdelete(uniq//"*.imh",verify-)
   delete  (rootfile//","//uniq//"*",verify-,>& "dev$null")
   delete  (l_log//","//colorlist//","//tmp2,verify-,>& "dev$null")
   delete  (imfile//","//subfile//","//secfile//","//tmp1,ver-,>& "dev$null")
   delete  (medianfile//","//modefile//","//meanfile,verify-,>& "dev$null")

end
