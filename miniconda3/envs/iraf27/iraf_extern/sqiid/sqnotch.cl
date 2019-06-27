# SQNOTCH: 05OCT93 KMM
# SQTEST: 16MAR93 KMM
# SQPROC: 06APR92 KMM
# SQNOTCH -- process SQIID raw image data, using subset of frames within
#    selected list distance (notch) of each frame Rto produce a SKY frame

procedure sqnotch (input, output, flatimage, blankimage)

string input      {prompt="Input raw images"}
string output     {prompt="Output image descriptor: @list||.ext||%in%out%"}
string flatimage  {prompt="Input flat field image name"}
string blankimage {prompt='Input blank field image name: "compute"==compute'}

bool   fixpix     {no,prompt="Run FIXPIX on data?"}
string badpix     {"badpix", prompt="badpix file in FIXPIX format"}
bool   setpix     {no,prompt="Run SETPIX on data?"}
string maskimage  {"badmask", prompt="untransposed bad pixel image mask"}
real   blank      {0.0,prompt="Value if there are no pixels"}
bool   orient     {yes,prompt="Orient image with N up and E left"}

bool   verbose    {yes,prompt="Verbose output?"}
file   logfile    {"STDOUT",prompt="logfile name"}

int    include    {0, prompt="Number of included images in blankimage subset"}
int    first_proc {1, prompt="List number of first image to be processed"}
int    last_proc  {1000, prompt="List number of last image to be processed"}
string darkimage  {"null",prompt='Input dark_count image ("null"==noaction)'}
string norm_opt   {"zero", enum="zero|scale|none",
                       prompt="Type of combine operation: |zero|scale|none|"}
string norm_stat  {"median",enum="none|mean|median|mode",
                    prompt="Pre-combine common offset: |none|mean|median|mode|"}
string comb_opt   {"median", enum="average|median",
                       prompt="Type of combine operation: |average|median|"}
string reject_opt {"none", prompt="Type of pixel rejection operation",
                    enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip"}
string statsec    {"[50:200,50:200]",
                    prompt="Image section for calculating statistics"}
real   lthreshold {INDEF,prompt="Lower threshold for exclusion in statistics"}
real   hthreshold {INDEF,prompt="Upper threshold for exclusion in statistics"}
bool   mclip      {no, prompt="Use median, not mean, in clip algorithms"}
real   pclip      {-0.5, prompt="pclip: Percentile clipping parameter"}
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
   

struct  *inlist,*outlist,*imglist,*l_list

begin

   int    nin, irootlen, orootlen, stat, pos1b, pos1e, pos2b, pos2e,
          nxlotrim,nxhitrim,nylotrim,nyhitrim, ncols, nrows,
          img_num, first_in, last_in, ilist
   real   rnorm, rmean, rmedian, rmode, fract, rawmedian
   string in,in1,in2,out,iroot,oroot,uniq,img,sname,sout,sbuff,sjunk,
          smean, smedian, smode, front, srcsub, color,
          combopt, zeroopt, scaleopt, normstat, reject
   file   blankimg,  nflat, infile, outfile, im1, im2, im3, tmp1, tmp2, tmp3,
          l_log, task, maskimg, valuimg, colorlist
   bool   found, choff
   struct line = ""

# Assign positional parameters to local variables
   in          = input
   out         = output
   nflat       = flatimage
   blankimg    = blankimage

   combopt = comb_opt
   normstat = norm_stat
   reject = reject_opt
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

   uniq        = mktemp ("_Tsqp")
   infile      = mktemp ("tmp$sqn")
   outfile     = mktemp ("tmp$sqn")
   tmp1        = mktemp ("tmp$sqn")
   tmp2        = mktemp ("tmp$sqn")
   tmp3        = mktemp ("tmp$sqn")
   l_log       = mktemp ("tmp$sqn")
   colorlist   = mktemp ("tmp$sqn")
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
   if (((blankimg != "null") && (blankimg != "compute")) &&
      (substr(blankimg,strlen(blankimg)-3,strlen(blankimg)) != ".imh")) {
      blankimg = blankimg//".imh"
      if (!access(blankimg)) {
         print ("Blank image ",blankimg, " does not exist!")
         goto skip
      }
   }
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

#      print (trimlimits) | translit ("", "[:,*]", "     ", >> l_log)
#      stat = (fscan(l_list,nxlotrim,nxhitrim,nylotrim,nyhitrim))
#      if (stat != 4) {
#         nxlotrim = 0; nxhitrim = 0
#         nylotrim = 0; nyhitrim = 0
#      }
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
      print ("SUBTRACTED BLANK= ",blankimg,>> logfile)
      print ("FLATFIELD= ",nflat,>> logfile)
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
      if ((blankimg != "null") && (blankimg != "compute")) {
         imstatistics (blankimg//statsec,
            fields="image,npix,mean,midpt,mode,stddev,min,max",
            lower=lthreshold,upper=hthreshold,binwidth=0.001,format-,>> logfile)
      }
# Loop through data
      img_num = 0
      inlist = infile; outlist = outfile
      copy (infile, tmp2)
      while ((fscan (inlist,sname) != EOF) && (fscan(outlist,sout) != EOF)) {

         img_num += 1
         if (img_num < first_proc) next  # skip until appropriate list number
         if (img_num > last_proc  || img_num > nin) break # terminate
# Get raw_median value for header
         imstatistics (sname//statsec,fields="midpt,mean",
            lower=lthreshold,upper=hthreshold,binwidth=0.001,format-,> tmp1)
         l_list = tmp1; stat = fscan (l_list,rawmedian)
         l_list = ""; delete (tmp1, verify-)

# Subtract the blank image from the raw data images.
# NEW
         if (blankimg == "compute") {
#            first_in = img_num - int((include/2) + 1)
            first_in = img_num - int((include/2))
            last_in  = int((include + 1)/2) + img_num
            if (first_in < 1) {
               last_in += (1 - first_in)
               first_in = 1
            } else if (last_in > nin) {
               first_in -= (last_in - nin)
               last_in = nin
            }
            print (blankimage," ",img_num,first_in,last_in)
            imglist = tmp2
            for (ilist = 1; fscan(imglist,img) != EOF; ilist += 1) {
               if (ilist > last_in) break
               if ((ilist >= first_in) && (ilist != img_num)) {
	           print(img,>> tmp3)
               }
            }
            imcombine("@"//tmp3,im3,plfile="",sigma="",logfile=logfile,
               combine=combopt,reject=reject,project-,outtype="real",
               offsets="none",masktype="none",maskvalue=0,blank=blank,
               scale=scaleopt,zero=zeroopt,weight=weight,statsec=statsec,
               expname=expname,lthreshold=lthreshold,hthreshold=hthreshold,
               nlow=nlow,nhigh=nhigh,nkeep=nkeep,mclip=mclip,lsigma=lsigma,
               hsigma=hsigma,expname=expname,rdnoise=rdnoise,gain=gain,
               sigscale=sigscale,snoise=snoise,pclip=pclip,grow=grow)
            imarith (sname,"-",im3,im1,pixtype="r",calctype="r",hparams="")
            delete (tmp3,verify-); imdelete (im3,verify-,>& "dev$null")
         } else if (blankimg == "null") {
            imarith (sname,"-",0.0,im1,pixtype="r",calctype="r",hparams="")
         } else {
            imarith (sname,"-",blankimg,im1,pixtype="r",calctype="r",hparams="")
         }

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
         hedit (sout,"raw_midpt",rawmedian,add+,delete-,verify-,show-,update+)
         hedit (sout,"pro_midpt",rmedian,add+,delete-,verify-,show-,update+)
         imglist = ""; imdelete (im1//","//im3, verify-,>& "dev$null")
         
      }

   skip:

   # Finish up
      inlist = ""; outlist = ""; imglist = ""; l_list = ""
      imdelete (im1//","//im2//","//im3,verify-,>& "dev$null")
      imdelete (maskimg//","//valuimg,verify-,>& "dev$null")
      delete (tmp1//","//tmp2//","//tmp3//","//l_log, verify-,>& "dev$null")
      delete (infile//","//outfile//","//colorlist, verify-,>& "dev$null")
   
end
