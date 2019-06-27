# SQDARK: 01DEC92 KMM
# SQDARK -- Create IR dark frames.
# SQDARK: 01DEC92 incorporates Valdes' IRAF2.10EXPORT version 2 IMCOMBINE
# SQDARK: 07MAY92 KMM

procedure sqdark (input, output)

string input      {prompt="Input raw dark images"}
string output     {prompt="Output IMCOMBINED dark image"}

string common     {"none",enum="none|mean|median|mode",
                    prompt="Pre-combine common offset: |none|median|mode|"}
string statsec    {"[50:200,50:200]",
                    prompt="Image section for calculating statistics"}
string reject_opt {"minmax", prompt="Type of rejection operation",
                    enum="none|minmax|pclip"}
string comb_opt   {"average", enum="average|median",
                      prompt="Type of combine operation: |average|median|"}
real   lthreshold {INDEF,prompt="Lower threshold for exclusion in statistics"}
real   hthreshold {INDEF,prompt="Upper threshold for exclusion in statistics"}
real   blank      {0.0,prompt="Value of output pixel when all are rejected"}
string expname    {"", prompt="Image header exposure time keyword"}
int    nlow       {1, prompt="minmax: Number of low pixels to reject"}
int    nhigh      {1, prompt="minmax: Number of high pixels to reject"}
int    nkeep      {0, prompt="Min to keep (pos) or max to reject (neg)"}
real   lsigma     {3., prompt="Lower sigma clipping factor"}
real   hsigma     {3., prompt="Upper sigma clipping factor"}
real   pclip      {-0.5, prompt="pclip: Percentile clipping parameter"}
   
file   logfile    {"STDOUT", prompt="Log file name"}
bool   stat_calc  {yes,prompt="Calculate statistics?"}
bool   verbose    {yes,prompt="Verbose output?"}

struct  *list1, *list2, *list3, *l_list

begin

   int    i, nin, nout, stat, pos1b, pos1e, n_opt, c_opt, nim, maxnim
   real   rnorm, rmedian, rmode,
          ddelta, avenorm, avemedian, avemode, stddev, number,
          stddev_median,stddev_mode
   string in, in1, in2, dark, out, outfull, uniq, scale, sbuff, sjunk, color,
          img, sname, smedian, smode, combopt, first, vcheck, rject
   file   rootfile,imfile,subfile,secfile,tmp1,medianfile,modefile,l_log,
          colorlist
   bool   choff, update
   struct line = ""

# Assign positional parameters to local variables

   in          = input
   out         = output
   l_log       = mktemp ("tmp$sqd")
   rootfile    = mktemp ("tmp$sqd")
   colorlist   = mktemp ("tmp$sqd")
   imfile      = mktemp ("tmp$sqd")
   subfile     = mktemp ("tmp$sqd")
   secfile     = mktemp ("tmp$sqd")
   medianfile  = mktemp ("tmp$sqd")
   modefile    = mktemp ("tmp$sqd")
   tmp1        = mktemp ("tmp$sqd")

   reject  = reject_opt

# check IRAF version
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
   } else {
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
      stat = fscan(l_list,color)
      if (strlen (color) != strlen (in2)) {
         print ("colorlist ",in2," has colors not in jhklJHKL1234")
         goto skip
      }
      nin = strlen(color)
      for (i = 1; i <= nin; i += 1) {
         sjunk = substr(color,i,i)
         print (sjunk, >> colorlist)
         sjunk = out//substr(sjunk,i,i)
         if (access(sjunk//".imh")) {	# check for output collision
            print ("Output image",sjunk, " already exists!")
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
         if (verbose) type (tmp1)
      } else {
         copy (rootfile, tmp1)
         outfull = out
      }
      list1 = tmp1  
      for (nin = 0; fscan (list1,img) !=EOF; nin += 1) {
# Strip off trailing ".imh"
         i = strlen(img)
         if (substr(img,i-3,i) == ".imh") img = substr(img,1,i-4)
         print (img,>> imfile)
         print (img//statsec,>> secfile)
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
      delete (tmp1,ver-,>& "dev$null")
      time(> tmp1); list1 = tmp1; stat = fscan(list1,line)
      list1 = ""; delete (tmp1, ver-, >& "dev$null")

# Print date and id line
      print (line," SQDARK("//combopt//"): ",outfull ,>> logfile)
      print (line," SQDARK("//combopt//"): ",outfull)

# Determine image statistics within image subsection for producing flats

      if (stat_calc) {
         imstatistics("@"//secfile,fields="npix,midpt,mode,stddev,min,max",
            lower=lthreshold,upper=hthreshold,binwidth=0.001,format-,> tmp1)

         imstatistics(" ",fields="image,npix,midpt,mode,stddev,min,max",
            lower=lthreshold,upper=hthreshold,binwidth=0.001,format+,>> logfile)
         join(imfile,tmp1,out="STDOUT",delim=" ",miss="Missing",
            maxchar= 161, shortest-,verbose+,>> logfile)
         list1 = tmp1
         for (i = 1; fscan(list1,sjunk,smedian, smode) != EOF; i += 1) {
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
         print("dev_median=",stddev_median," dev_mode=",stddev_mode,
           >> logfile)
      } else {
         type (imfile, >> logfile)
      }

# Log process prior to imcombine
      print(combopt," filtering unnormalized images",>> logfile)

      if (!update) {
         print ("Performing IMCOMBINE: combine= ",combopt," output= ",outfull)
         print ("Performing IMCOMBINE: combine= ",combopt," output= ",outfull,
            >> logfile)
         imcombine("@"//imfile,outfull,sigma="",logfile=logfile,
            option=combopt,outtype="real",expname="",exposure-,scale-,offset-,
            weight-,modesec="",lowreject=lsigma,highreject=hsigma,blank=blank)
       } else {
         print ("Performing IMCOMBINE: reject= ",reject," combine= ",
            combopt," output= ", outfull)
         print ("Performing IMCOMBINE: reject= ",reject," combine= ",
            combopt," output= ", outfull,>> logfile)
         imcombine("@"//imfile,outfull,plfile="",sigma="",logfile=logfile,
            combine=combopt,reject=reject,project-,outtype="real",
            offsets="none",masktype="none",maskvalue=0,blank=blank,
            scale="none",zero=common,weight="none",statsec=statsec,
            lthreshold=lthreshold,hthreshold=hthreshold,grow=0,
            nlow=nlow,nhigh=nhigh,nkeep=nkeep,pclip=pclip,
            lsigma=lsigma,hsigma=hsigma)
      }
      hedit (outfull,"title",outfull,add-,delete-,verify-,show-,update+)
      list1 = ""; list2 = ""; l_list = ""
      delete  (l_log,verify-,>& "dev$null")
      delete  (imfile//","//subfile//","//secfile//","//tmp1,ver-,>& "dev$null")
      delete  (medianfile//","//modefile,verify-,>& "dev$null")
   }

# Finish up
skip:
   list1 = ""; list2 = ""; list3 = ""; l_list = ""
   delete  (l_log//","//colorlist,ver-,>& "dev$null")
   delete  (imfile//","//subfile//","//secfile//","//tmp1,ver-,>& "dev$null")
   delete  (medianfile//","//modefile//","//rootfile,verify-,>& "dev$null")

end
