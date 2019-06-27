# ONIRCOMBINE: 08APR94 KMM
# NIRCOMBINE: 06APR94 KMM
# NIRCOMBINE produce IMCOMBINED IR image of heavily overlapped region
# NIRCOMBINE: 13OCT92 KMM
# NIRCOMBINE: incorporates Valdes' new IMCOMBINE 
# NIRCOMBINE: incorporates frame_num list to combine subset of image database
# NIRCOMBINE: 09JUN93 KMM
# NIRCOMBINE: incoporates imstack to get around 102 image limit
# NIRCOMBINE: 16FEB94 KMM
# NIRCOMBINE: fix so that all input images to imstack have the same dimension
#  02MAR94 KMM  shift internal files to avoid internal use of "type" command
#  06APR94 KMM replace "type" with "concatenate" or "copy"
#  08APR94 KMM freeze system for old imcombine

procedure onircombine (match_name,infofile)

string match_name   {prompt="name of resultant composite image"}
file   infofile     {prompt="file produced by XYGET|XYLAP|XYADOPT"}

string frame_nums   {"",
                   prompt="Include only selected frame numbers in MOSAIC|@list"}
file   outfile      {"", prompt="Output information file name"}
# trim values applied to final image
string trimlimits   {"[2:2,2:2]",
                      prompt="added trim limits for input subrasters"}
bool   register     {yes,prompt="Maintain input image origin and size"}
string common       {"median",enum="none|adopt|mean|median|mode",
              prompt="Pre-combine common offset: |none|adopt|mean|median|mode|"}
string comb_opt     {"median", enum="average|median",
                       prompt="Type of combine operation: |average|median|"}
string reject_opt   {"none", prompt="Type of pixel rejection operation",
                    enum="none|minmax|ccdclip|crreject|sigclip|avsigclip|pclip"}
real   lthreshold   {-200.,prompt="Rejection floor for imcombine and stats"}
real   hthreshold   {65000.,prompt="Rejection ceiling for imcombine and stats"}
real   blank        {-1000.,prompt="Value if there are no pixels"}
bool   setpix       {no,prompt="Run SETPIX on data?"}
string maskimage    {"badmask", prompt="bad pixel image mask"}
real   svalue       {-1.0e8, prompt="Setpix value (<< lthreshold)"}
bool   fixpix       {no,prompt="Run FIXPIX on data?"}
string fixfile      {"badpix", prompt="badpix file in FIXPIX format"}

#bool   project      {no,prompt="Project highest dimension of input images?"}
bool   make_stack   {no,prompt="Imstack images prior to imcombine?"}
bool   save_images  {no,prompt="Save images which were IMCOMBINED via imstack?"}
bool   do_combine   {yes,prompt="IMCOMBINE (else IRMATCH) into final image?"}
bool   verbose      {yes, prompt="Verbose output?"}
bool   format       {yes, prompt="Format output table"}

bool   size         {no, prompt="Compute image size?"}
string interp_shift {"linear",enum="nearest|linear|poly3|poly5|spline3",
              prompt="IMSHIFT interpolant (nearest,linear,poly3,poly5,spline3)"}
string bound_shift  {"nearest",enum="constant|nearest|reflect|wrap",
                      prompt="IMSHIFT boundary (constant,nearest,reflect,wrap)"}
real   const_shift  {0.0,prompt="IMSHIFT Constant for boundary extension"}
real   gxshift      {0.0, prompt="global xshift for final image"}
real   gyshift      {0.0, prompt="global yshift for final image"}
string goverlap     {"", prompt="Global overlap section (overrides all else)"}
string gsize        {"", prompt="Global image size (overrides all else)"}
string weight       {"none",prompt="Image weights"}
bool   mclip        {no, prompt="Use median, not mean, in clip algorithms"}
real   pclip        {-0.5, prompt="pclip: Percentile clipping parameter"}
int    nlow         {1, prompt="minmax: Number of low pixels to reject"}
int    nhigh        {1, prompt="minmax: Number of high pixels to reject"}
real   lsigma       {3., prompt="Lower sigma clipping factor"}
real   hsigma       {3., prompt="Upper sigma clipping factor"}
real   sigscale     {0.1,
                     prompt="Tolerance for sigma clipping scaling correction"}
int    grow         {0, prompt="Radius (pixels) for 1D neighbor rejection"}
string expname      {"", prompt="Image header exposure time keyword"}
string rdnoise      {"0.", prompt="ccdclip: CCD readout noise (electrons)"}
string gain         {"1.", prompt="ccdclip: CCD gain (electrons/DN)"}
bool   answer       {yes, prompt="Do you want to continue?", mode="q"}
bool   compute_size {yes, 
                       prompt="Do you want to [re]compute image size?",mode="q"}

struct  *list1, *list2, *l_list

begin

   int    i,stat,nim,maxnim,slen,slenmax,njunk,pos1b,pos1e,ncolsout,nrowsout,
          nxoff0,nyoff0,im_xoffset,im_yoffset,c_opt,maxsizex,maxsizey,
          ncols, nrows, nxhiref, nxloref, nyhiref, nyloref,
          nxhi, nxlo, nyhi, nylo, nxhisrc, nxlosrc, nyhisrc, nylosrc,
          nxlotrim,nxhitrim,nylotrim,nyhitrim,
          nxlolap,nxhilap,nylolap,nyhilap,
          nxhimat,nxlomat,nyhimat,nylomat,
          nxlonew,nxhinew,nylonew,nyhinew,
          nxmat0, nymat0, nxmos0, nymos0, ixs, iys, ndim, max_nim
   real   zoff, rjunk, xin, yin, xmat, ymat, fxs, fys,
          xs, ys, xoff, yoff, g_xshift, g_yshift, xmax, xmin, ymax, ymin,
          xofftran,yofftran,gtxmax, gtxmin, gtymax, gtymin,
          oxmax,oxmin,oymax,oymin,xoffset,yoffset,
          xlo, xhi, ylo, yhi, xshift, yshift, reject_value
   real   roff, delta, rmedian, rmode, avestat, avemean, avemode, avemedian,
          rmean, stddev_mean,stddev_median,stddev_mode
   bool   do_tran, tran, max_tran, prior_tran,fluxtran,found,new_origin,update,
          project
   string uniq,imname,tmpname,matchname,slist,sjunk,soffset,encsub,sopt,
          src,srcsub,mos,mossub,mat,matsub,ref,refsub,stasub,lapsec,outsec,
          vigsec,sformat,traninfo,sxrot,syrot,sxmag,symag,sxshift,syshift,
          dbtran,cotran,consttran,geomtran,interptran,boundtran,
          zero, vcheck, reject, combopt, statsec, dbpath,image_nims
   file   info,out,dbinfo,l_log,tmp1,tmp2,im1,im2,statlist,statfile,comblist,
          tmpimg,maskimg,valuimg,do1info,do2info,matinfo,newinfo,task,misc,
          comblog,im_offsets,ncomblist,nimlist,stacklist,combinfo
   struct line = ""

   matchname   = match_name
   info        = infofile
   g_xshift    = gxshift
   g_yshift    = gyshift
   uniq        = mktemp ("_Ticb")
   task        = uniq // ".tsk"
   newinfo     = uniq // ".mat"
   l_log       = mktemp("tmp$icb")
   dbinfo      = mktemp("tmp$icb")
   matinfo     = mktemp("tmp$icb")
   comblist    = mktemp("tmp$icb")
   ncomblist   = mktemp("tmp$icb")
   nimlist     = mktemp("tmp$icb")
   statlist    = mktemp("tmp$icb")
   stacklist   = mktemp("tmp$icb")
   statfile    = mktemp("tmp$icb")
   do1info     = mktemp("tmp$icb")
   do2info     = mktemp("tmp$icb")
   tmp1        = mktemp("tmp$icb")
   tmp2        = mktemp("tmp$icb")
   combinfo    = mktemp("tmp$icb")
   misc        = mktemp("tmp$icb")
   im_offsets  = mktemp("tmp$icb")
   comblog     = mktemp("tmp$icb")
   maskimg     = uniq // ".mim"
   valuimg     = uniq // ".vim"
   im1         = uniq // ".im1"
   im2         = uniq // ".im2"
   tmpimg      = uniq // ".tim"

   reject  = reject_opt

# check IRAF version
   sjunk = cl.version			# get CL version
   stat = fscan(sjunk,vcheck)
   if (stridx("Vv",vcheck) <=0 )	# first word isn't version!
      stat = fscan(sjunk,vcheck,vcheck)

   if (verbose) print ("IRAF version: ",vcheck)
   if (substr(vcheck,1,4) > "V2.1") {
      update = no
      print ("Note: older IRAF ",vcheck)
      if (reject == "minmax") {
         combopt = "minmax"
      } else
         combopt = comb_opt
   } else {
      update = yes
      print ("Note: newer IRAF ",vcheck," not supported.  Use nircombine...")
      goto err
   }

# strip off trailing ".imh"
   i = strlen(matchname)
   if (substr(matchname,i-3,i) == ".imh")
      matchname = substr(mathname,1,i-4)

   if (! access(info)) { 		# Exit if can't find info
      print ("Cannot access info_file: ",info)
      goto err
   }
# establish ID of output info file
   if (outfile == "" || outfile == " " || outfile == "default")
      out = matchname//".src"
   else
      out = outfile
   if (out != "STDOUT" && access(out)) {
      print("Will overwrite output_file ",out,"!")
      if (!answer) goto err
   } else
      print ("Output_file= ",out)

   if (access(matchname//".imh")) {
         print("Image ",matchname," already exists!")
         goto err
   }

   if (setpix) {
      sjunk = maskimage
      i = strlen(sjunk)
      if (substr(sjunk,i-3,i) == ".imh") sjunk = substr(sjunk,1,i-4)
      if (! access(sjunk//".imh")) {		# Exit if can't find mask
         print ("Cannot access maskimage ",sjunk)
         goto err
      }
   }

   if (svalue >= lthreshold) {
      reject_value = lthreshold - 1.0
      print ("Resetting reject_value from ",svalue," to ",reject_value)
   } else
      reject_value = svalue


   c_opt = 0				# Establish common offset statistic
   if (common == "adopt" || common == "none" || common == "") {
      zero="none"
      if (common == "none")   c_opt = 0
      if (common == "adopt")  c_opt = 1
   } else {
      zero = common
      if (common == "mean")   c_opt = 2
      if (common == "median") c_opt = 3
      if (common == "mode")   c_opt = 4
   }

   print("#NOTE: ",common," statistics for data within ",
      lthreshold," to ",hthreshold)

   if (setpix) {
      imcopy (maskimage, maskimg, verbose-) 
# Sets bad pix to -1 and good to zero within the mask
      imarith (maskimg, "-", "1.0", valuimg,pix="real",calc="real",hpar="")
      imarith (valuimg, "*",reject_value,valuimg,pix="real",calc="real",hpar="")
      print ("#SETPIX to ",reject_value," using ", maskimage," mask")
   }

   l_list = l_log
   print (trimlimits) | translit ("", "[:,]", "    ", >> l_log)
   stat = (fscan(l_list,nxlotrim,nxhitrim,nylotrim,nyhitrim))

# Transfer appropriate information from reference to output file
   match ("^\#DB",info,meta+,stop-,print-, > dbinfo)

# Expand the range of images and extract COMlines from database
   if (frame_nums != "" && frame_nums != " " && frame_nums != "all") {
      match ("^COM_",info,meta+,stop-,print-, > tmp1)
      print("Selecting image subset: ",frame_nums)
      print (frame_nums) | translit ("", "|", " ", >> l_log)
      stat = fscan(l_list,image_nims)
      expandnim(image_nims,ref_nim=0,max_nim=512,>> nimlist)
      list1 = nimlist
      for (i = 0; fscan(list1,nim) != EOF; i += 1) {
         sjunk = "COM_000" + nim
         match ("^"//sjunk,tmp1,meta+,stop-,print-,>> matinfo)
         list2 = matinfo
         for (slen = 0; fscan(list2,imname) != EOF; slen += 1) {
            pos1b = stridx("_",imname)+1
            stat = int(substr(imname,pos1b,strlen(imname)))
            if (stat == nim) {
               found = yes
               break
            }
            found = no
         }
         if (!found) {
            print("Image path position missing for ",sjunk)
            next
         }
      }
      delete (tmp1, ver-, >& "dev$null")
      list1 = ""; list2 = ""
   } else
      match ("^COM_",info,meta+,stop-,print-, > matinfo)

# count number of images, excluding reference images
   count(matinfo,>> l_log); stat = fscan(l_list,maxnim)
   match ("^COM_000",matinfo,meta+,stop-,print-, >> tmp1)
   count(tmp1,>> l_log); stat = fscan(l_list,i)
   maxnim -= i
   if ((! make_stack) && (maxnim > 102)) {
      print ("Number of images: ",maxnim," exceeds 102 limit.  Use make_stack+")
      goto err
   }
   delete (tmp1, ver-, >& "dev$null")
# make list of temporary images
   for (nim = 1; nim <= maxnim; nim += 1) {
      tmpname = uniq//"_000" + nim
      print (tmpname//".imh", >> comblist)
   }  
   print ("#NOTE: will combine ",maxnim," images...")

# handle exceptions when comb_opt is inappropriate for #images
   if (! update) {
      if (maxnim <= 2 && combopt == "median" ) 
         combopt = "average"
      else if (maxnim <= 2 && combopt == "minmax" ) 
         combopt = "average"
      else
         combopt = combopt
   }

# Size of output image
   list1 = tmp1; delete (tmp1, ver-, >& "dev$null")
   match ("out_sec",dbinfo,meta-,stop-,print-) |		# MIG order
      sort (col=1,ignore+,numeric-,reverse+, > tmp1)
   if (fscan(list1, sjunk, sjunk, outsec) != 3) {
      outsec = ""; ncolsout = 256; nrowsout = 256
#         outsec = "[1:256,1:256]"; ncolsout = 256; nrowsout = 256
   } else { 
      print (outsec) | translit ("", "[:,]", "    ", >> l_log)
      stat = (fscan(l_list,nxlosrc,nxhisrc,nylosrc,nyhisrc))
      ncolsout = nxhisrc - nxlosrc + 1
      nrowsout = nyhisrc - nylosrc + 1
   }
   list1=""; delete (tmp1, ver-, >& "dev$null")
   print ("#NOTE: prior_outsec: ",outsec)

# Get GEOTRAN info
   match ("do_tran",dbinfo,meta-,stop-,print-, >> l_log)
   stat = fscan(l_list, sjunk, sjunk, do_tran)
   if (do_tran) {		# Fetch GEOTRAN info from database file
      print ("Note: images will be GEOTRANed prior to IMSHIFT and COMBINE")
      match ("db_tran",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, dbtran)
      if (!access(dbtran)) {
         print ("GEOTRAN database file db_tran ",dbtran," not found!")
         goto err
      }
      match ("begin",dbtran,meta-,stop-,print-,>> l_log)
      stat = fscan(l_list, sjunk, cotran)
      if (!access(cotran)) {
         print ("GEOTRAN database coord file co_tran ",cotran," not found!")
         goto err
      }
      match ("geom_tran",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, geomtran)
      match ("interp_tran",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, interptran)
      match ("bound_tran",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, boundtran)
      match ("const_tran",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, consttran)
      if (real(consttran) > reject_value)
         print ("Note: overriding const_tran with ",reject_value)
      match ("fluxconserve",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, fluxtran)
      match ("xoffset_tran",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, xofftran)
      match ("yoffset_tran",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, yofftran)
      match ("max_tran",dbinfo,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, max_tran)
   }

   time(> tmp1); list1 = tmp1; stat = fscan(list1,line)
   list1 = ""; delete (tmp1, ver-, >& "dev$null")
# Log parameters 
   print("#DBI ",line," IRCOMBINE:",>> dbinfo)
   print("#DBI    info_file       ",info,>> dbinfo)
   print("#DBI    global_xshift   ",g_xshift ,>> dbinfo)
   print("#DBI    global_yshift   ",g_yshift ,>> dbinfo)
   print("#DBI    global_overlap  ",goverlap,>> dbinfo)
   print("#DBI    global_size     ",gsize,>> dbinfo)
   print("#DBI    more_trimlimits ",trimlimits,>> dbinfo)
   print("#DBI    common_opt      ",common,>> dbinfo)
   print("#DBI    lthreshold      ",lthreshold,>> dbinfo)
   print("#DBI    hthreshold      ",hthreshold,>> dbinfo)
   print("#DBI    fixpix          ",fixpix,>> dbinfo)
   print("#DBI    fixfile         ",fixfile,>> dbinfo)
   print("#DBI    setpix          ",setpix,>> dbinfo)
   print("#DBI    set_mask        ",maskimage,>> dbinfo)
   print("#DBI    set_value       ",reject_value,>> dbinfo)
   print("#DBI    interp_shift    ",interp_shift,>> dbinfo)
   print("#DBI    bound_shift     ",bound_shift,>> dbinfo)
   print("#DBI    const_shift     ",const_shift,>> dbinfo)
   print("#DBI    imcomb_floor    ",lthreshold,>> dbinfo)
   print("#DBI    imcomb_ceiling  ",hthreshold,>> dbinfo)
   print("#DBI    imcomb_blank    ",blank,>> dbinfo)
   if (do_tran) {
      print("#Note: Images GEOTRANed prior to IMSHIFT and COMBINE",>> dbinfo)
      if (real(consttran) > reject_value)
         print ("#Note: overriding const_tran with ",reject_value,>> dbinfo)
   }

   l_list = ""; delete (l_log, ver-, >& "dev$null"); l_list = l_log
# Put in global shifts
   xoffset = g_xshift; yoffset = g_yshift

   if (outsec == "" || size) {
      if (compute_size || outsec == "")
# Determine corners of minimum rectangle enclosing region
         new_origin = yes
      else
         new_origin = no
   } else
      new_origin = no
   if (new_origin) print ("Will optimize origin.")

# Compute minimum rectangle enclosing region and overlap region
   closure (matinfo,xoffset,yoffset,trimlimits=trimlimits,
      interp_shift=interp_shift,origin=new_origin,
      verbose+,format+,>> do1info)
   match ("^COM",do1info,meta+,stop-,print-, > newinfo)
   if (verbose) type (newinfo)
   match ("^ENCLOSED_SIZE",do1info,meta+,stop-,print-,>> l_log)
   stat = fscan(l_list,sjunk,encsub)
   print (encsub) | translit ("", "[:,]", "    ", >> l_log)
   stat = (fscan(l_list,nxlomat,nxhimat,nylomat,nyhimat))
   match ("^UNAPPLIED_OFFSET",do1info,meta+,stop-,print-,>> l_log)
   stat = fscan(l_list,sjunk,xoffset,yoffset)
   match ("^OVERLAP",do1info,meta+,stop-,print-,>> l_log)
   stat = fscan(l_list,sjunk,lapsec,vigsec)
   print (lapsec) | translit ("", "[:,]", "    ", >> l_log)
   stat = (fscan(l_list,nxlolap,nxhilap,nylolap,nyhilap))
   if (lapsec == "[0:0,0:0]") lapsec = ""

   if (new_origin) {
# Establishes origin at (0,0)
      ncolsout = nxhimat - nxlomat + 1
      nrowsout = nyhimat - nylomat + 1
# Override minimum rectangle
      outsec  = "[1:"// ncolsout //",1:"// nrowsout //"]"
   } else {	# null unapplied offsets since we don't want to apply them
      xoffset = 0
      yoffset = 0
   }

   if (gsize != "") {			# Report image composite size
      print ("#Note: computed composite image size: ", outsec)
      print ("#Note: adopted composite image size: ", gsize)
      print ("#Note: computed composite image size: ", outsec,>> dbinfo)
      outsec = gsize
      print ("#Note: adopted composite image size: ", outsec,>> dbinfo)
   } else {
      print ("#Note: computed composite image size: ", outsec)
   }

   if (goverlap != "") {
      print ("#Note: computed composite overlap region: ", lapsec)
      print ("#Note: adopted composite overlap region: ", goverlap)
      print ("#Note: computed composite overlap region: ", lapsec,>> dbinfo)
      lapsec = goverlap
      print ("#Note: adopted composite overlap region: ", lapsec,>> dbinfo)
   } else {
      print ("Computed composite overlap region: ", lapsec)
      if (lapsec == "" && c_opt > 1) { 
         print ("Null overlap: can't compute statistics")
         goto err
      }
   }

#NOTE: this needs fixing up
   if (zero != "none")
      statsec="overlap"
   else
      statsec=""
###########################

   print("#DBI    overlap_sec     ",lapsec,>> dbinfo)
   print("#DBI    out_sec         ",outsec,>> dbinfo)
        
# Mark offsets as absolute or relative
   if (register)
      print ("# Absolute",>> im_offsets)
   else
      print ("# Relative",>> im_offsets)

   maxsizex = 0; maxsizey = 0
   slenmax = 0; list1 = newinfo; list2 = comblist
# Loop through frames: fixpix|setpix|geotran|imshift|zoffset
   while (fscan(list1,imname,src,nxlosrc,nxhisrc,nylosrc,nyhisrc,
      nxmat0,nymat0,fxs,fys,soffset) != EOF) {
      pos1b = stridx("_",imname)+1
      if (pos1b < 2) {
         print("Image path position (COM_pos) missing at ",imname)
         goto err
      } else
         nim = int(substr(imname,pos1b,strlen(imname)))

      if (nim == 0 ) {	 			# SKIP COM_000 REF IMAGE
         print("#NOTE: skipping COM_000 ",src)
         next
      }

      if (soffset == "INDEF") soffset = "0.0"
      zoff = real (soffset)
      slenmax = max(slenmax,strlen(src))
      srcsub = "["//nxlosrc//":"//nxhisrc//","//nylosrc//":"//nyhisrc//"]"
      nxlomat = nxmat0 + nxlosrc ; nxhimat = nxmat0 + nxhisrc
      nylomat = nymat0 + nylosrc ; nyhimat = nymat0 + nyhisrc

      if (setpix) {					# SETPIX
         imarith (src,"*",maskimg,im1,pix="real",calc="real",hpar="")
         if (reject_value != 0.0)
           imarith (im1,"-",valuimg,im1,pix="real",calc="real",hpar="")
      } else
         imcopy(src,im1,verbose-)

      if (fixpix) fixpix(im1, badpix, verbose-) 	# FIXPIX

      if (do_tran) {
         print (src) | translit ("", "[:,]", "    ", >> l_log)
         stat = fscan(l_list,sjunk,nxlonew,nxhinew,nylonew,nyhinew)
         ncols = nxhinew - nxlonew + 1
         nrows = nyhinew - nylonew + 1
         gtxmin = 1 + xofftran; gtxmax = gtxmin + ncols
         gtymin = 1 + yofftran; gtymax = gtymin + nrows
         geotran(im1,im2,dbtran,cotran,geometry=geomtran,
            xin=INDEF,yin=INDEF,xshift=INDEF,yshift=INDEF,
            xout=INDEF,yout=INDEF,xmag=INDEF,ymag=INDEF,
            xrot=INDEF,yrot=INDEF,xmin=gtxmin,xmax=gtxmax,
            ymin=gtymin,ymax=gtymax,xscale=1.,yscale=1.,
            ncols=INDEF,nlines=INDEF,xsample=1.,ysample=1.,
            interpolant=interptran,boundary=boundtran,
            constant=reject_value,flux=fluxtran,nxblock=256,nyblock=256)
         imdelete(im1,verify-,>& "dev$null")
         imrename(im2,im1,verbose-)
      }

      stat = fscan(list2,tmpname)
      imshift(im1,tmpname,fxs,fys,shifts_file="",interp_type=interp_shift,
         boundary_type=bound_shift,constant=const_shift)	# IMSHIFT
      imdelete(im1,verify-,>& "dev$null")

      if (common == "adopt") 					# OFFSET
         imarith (tmpname,"+",zoff,tmpname,pixtype="",calctype="",hparams="")

# Redetermine the source and destination sections
      nxlomat += xoffset; nxhimat += xoffset
      nylomat += yoffset; nyhimat += yoffset
      nxmat0  += xoffset; nymat0  += yoffset
      matsub = "["//nxlomat//":"//nxhimat//","//nylomat//":"//nyhimat//"]"
# Test for out-of-range and fix as needed
      if ((nxlomat < 1) || (nylomat < 1) || (nxhimat > ncolsout) ||
         (nyhimat > nrowsout)) {
         print ("#NOTE: ",src," destination ",matsub," out of range!")
         print ("#NOTE: ",src," destination ",matsub," out of range!",
            >> dbinfo)
         nxlosrc += max(0, (1 - nxlomat)); nxlomat = max(1,nxlomat)
         nylosrc += max(0, (1 - nylomat)); nylomat = max(1,nylomat)
         nxhisrc -= max(0, (nxhimat - ncolsout))
         nxhimat = min(ncolsout,nxhimat)
         nyhisrc -= max(0, (nyhimat - nrowsout))
         nyhimat = min(nrowsout,nyhimat)
      }
      matsub = "["//nxlomat//":"//nxhimat//","//nylomat//":"//nyhimat//"]"
      srcsub = "["//nxlosrc//":"//nxhisrc//","//nylosrc//":"//nyhisrc//"]"
      nxlo = nxlolap - nxlomat + nxlosrc
      nxhi = nxhilap - nxhimat + nxhisrc
      nylo = nylolap - nylomat + nylosrc
      nyhi = nyhilap - nyhimat + nyhisrc
 # Determine overlap section within imshifted source image
      stasub = "["//nxlo//":"//nxhi//","//nylo//":"//nyhi//"]"
      print (tmpname//stasub,>> statlist)
      print (tmpname," ",srcsub," ",zoff," ",matsub," ",stasub,>> do2info)
      if (verbose) {
         print (tmpname," ",srcsub," ",zoff," ",matsub," ",stasub)
      }
      if (((nxhisrc-nxlosrc) != (nxhimat-nxlomat)) ||
          ((nyhisrc-nylosrc) != (nyhimat-nylomat))) {
         print (tmpname," dimension mismatch!")
         print (tmpname," dimension mismatch!", >> dbinfo)
         beep
      }
      maxsizex = max((nxhisrc-nxlosrc+1),maxsizex)
      maxsizey = max((nyhisrc-nylosrc+1),maxsizey)
   }

   if (c_opt <= 1) goto afterstat

# Determine image statistics within overlap section for calculating offsets
      delete (tmp1, ver-, >& "dev$null")
# Get header
      imstatistics("",
         fields="image,mean,midpt,mode,stddev,npix,min,max",
         lower=lthreshold,upper=hthreshold,binwidth=0.001,format+,> statfile)
      imstatistics("@"//statlist,
         fields="image,mean,midpt,mode,stddev,npix,min,max",
         lower=lthreshold,upper=hthreshold,binwidth=0.001,format-,>> statfile)
 # compute average median and mode
      fields(statfile,2,line="2-",pr-,quit-) | average("new_sample",>> tmp1)
      fields(statfile,3,line="2-",pr-,quit-) | average("new_sample",>> tmp1)
      fields(statfile,4,line="2-",pr-,quit-) | average("new_sample",>> tmp1)
      fields(statfile,"2-4",line="2-",pr-,quit-,>> tmp1)

      list1 = tmp1
      stat = fscan(list1,avemean,stddev_mean,njunk)
      stddev_mean   = 0.0001*real(nint(10000.0*stddev_mean))
      stat = fscan(list1,avemedian,stddev_median,njunk)
      stddev_median = 0.0001*real(nint(10000.0*stddev_median))
      stat = fscan(list1,avemode,stddev_mode,njunk)
      stddev_mode   = 0.0001*real(nint(10000.0*stddev_mode))
      if (verbose) {
         type (statfile)
         print("ave_mean=",avemean," ave_median=",avemedian,
               " ave_mode=",avemode)
         print("dev_mean=",stddev_mean," dev_median=",stddev_median,
               " dev_mode=",stddev_mode)
      }
      concatenate (statfile,misc,append+)
      print("ave_mean=",avemean," ave_median=",avemedian,
         " ave_mode=",avemode,>> misc)
      print("dev_mean=",stddev_mean," dev_median=",stddev_median,
         " dev_mode=",stddev_mode,>> misc)

      list1 = ""; delete (tmp1, ver-, >& "dev$null")
      list2 = statfile
      stat = fscan (list2,sjunk)			#SKIP HEADER

afterstat:

      mkpattern (tmpimg,output="",pattern="constant",v1=reject_value,v2=0.,
         title="",pixtype="real",ndim=2,ncols=ncolsout,nlines=nrowsout)
      list1 = do2info
# Loop through frames, imshift and setup for imstatistics
      for (i = 1; fscan(list1,src,srcsub,zoff,matsub) != EOF ; i += 1) {
         if (c_opt >= 2)  stat = fscan(list2,sjunk,rmean,rmedian,rmode) 
         switch(c_opt) {
           case 0:
              delta = 0.0
           case 1:
              delta = zoff
           case 2:
              delta = avemean - rmean
           case 3:
              delta = avemedian - rmedian
           case 4:
              delta = avemode - rmode
         }
         print (delta,>> tmp1)		 # extract zoff to tmp1
         if (common != "adopt")	# if common == adopt, subtraction done earlier
            imarith (src,"+",delta,src,pixtype="",calctype="",hparams="")
         if (do_combine) {
            imcopy(tmpimg,im1,verbose-)
            imcopy(src//srcsub,im1//matsub,verbose+)
            imdelete(src,verify-,>& "dev$null")
            imrename(im1,src,verbose-)
         } else {
            imcopy(src//srcsub,tmpimg//matsub,verbose+)
         }
      }

   if (do_combine) {
      if (! update) {
         print ("Performing old IMCOMBINE: combine= ","threshold",
            " output= ",matchname)
         print ("#Performing old IMCOMBINE: combine= ","threshold",
            " output= ",matchname,>> out)
         type(comblist)
         imcombine("@"//comblist,matchname,sigma="",logfile=comblog,
            option="threshold",outtype="",expname="",scale-,offset-,weight-,
            modesec=lapsec,lowreject=lthreshold,highreject=hthreshold,
            blank=blank)
      }
   } else {
      print ("Performing OVERLAY:")
      imdelete(tmpimg,verify-,>& "dev$null")
      mkpattern (tmpimg,output="",pattern="constant",v1=reject_value,v2=0.,
         title="",pixtype="real",ndim=2,ncols=ncolsout,nlines=nrowsout,
         header=tmpimg)
      list1 = do2info
      for (i = 1; fscan(list1,src,srcsub,zoff,matsub) != EOF ; i += 1) {
            imcopy(src//srcsub,tmpimg//matsub,verbose+)
      }
      imrename(tmpimg,matchname,verbose-)
   }

# output information
   delete (out, ver-,>& "dev$null") # delete prior version (we said OK above)
   copy (dbinfo,out,verbose-)
# update intensity offset data
   delete(tmp2//","//matinfo//","//dbinfo,verify-,>& "dev$null")
# Skip reference frame
   match ("^COM_000",newinfo,meta+,stop-,print-,> dbinfo)
   match ("^COM_000",newinfo,meta+,stop+,print-,> matinfo)
   delete (newinfo,verify-,>& "dev$null")
   copy (dbinfo,newinfo,verbose+)

   if (c_opt <= 1) {
      fields(matinfo,"1-11",lines="1-",print-,quit-,>> newinfo)
      # tmp1 will already contain zoff
   } else {
      fields(matinfo,"1-10",lines="1-",print-,quit-,>> tmp2)
      join(tmp2,tmp1,out="STDOUT",missing="Missing",delim=" ",
          maxchars=161,shortest-,verbose+,>> newinfo)
   }
   if (format) {					# fancy formatter 
      sformat = '{printf("%-7s %'//-slenmax//
         's %3d %3d %3d %3d %4d %4d %5.2f %5.2f %8.2f'
      if ((slenmax + 57) == 80)			# dodge 80 char no lf
         sformat = sformat //'  |\\n"'
      else
         sformat = sformat //' |\\n"'
      sformat = sformat // ',$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)}'
      print(sformat, > task)
      print("!awk -f "//task//" "//newinfo//" >> "//out) | cl
   } else
      concatenate (newinfo,out,append+)

   if (do_combine) {
      concatenate (comblog,out,append+)
      if (make_stack) {
         delete (newinfo//","//tmp2//","//task,verify-,>& "dev$null")
         list1 = combinfo
         for (i = 1; fscan(list1,imname,src,mat,mos,ref,sjunk) != EOF; i += 1) {
             tmpname = "STA_000" + i
             nim = nscan ()
             switch (nim) {
                case 3:			# imname[nn] xoff yoff
                   print (tmpname," ",imname," ",src," ",mat,>> tmp2) 
                case 4:			# imname[ nn] xoff yoff
                   print (tmpname," ",imname//src," ",mat," ",mos,>> tmp2) 
                case 5:			# imname[nn] median adjust xoff yoff
                   print (tmpname," ",imname," ",mos," ",ref,>> tmp2) 
                case 6:			# imname[ nn] median adjust xoff yoff
                   print (tmpname," ",imname//src," ",ref," ",sjunk,>> tmp2) 
             }
         }
         join(tmp2,tmp1,out="STDOUT",missing="Missing",delim=" ",
            maxchars=161,shortest-,verbose+,>> newinfo)
         if (format) {					# fancy formatter 
            sformat = '{printf("%-7s %s %3d %3d %8.2f\\n",$1,$2,$3,$4,$5)}'
            print(sformat, > task)
            print("!awk -f "//task//" "//newinfo//" >> "//out) | cl
         } else
            concatenate (newinfo,out,append+)
      }
   }
   if (verbose)    concatenate (do2info,out,append+)
   
# Finish up

err:  list1 = ""; list2 = ""; l_list = ""
   imdelete(tmpimg//","//maskimg,verify-,>& "dev$null")
   imdelete(valuimg//","//im1//","//im2, verify-,>& "dev$null")
   if (access(comblist) && ! save_images)
      imdelete("@"//comblist,verify-,>& "dev$null")
   delete (comblist//","//tmp1//","//tmp2//","//nimlist,ver-,>& "dev$null")
   delete (combinfo//","//do1info//","//do2info,ver-,>& "dev$null")
   delete (l_log//","//ncomblist//","//comblog,ver-,>& "dev$null")
   delete (misc//","//dbinfo//","//matinfo,ver-,>& "dev$null")
   delete (stacklist//","//statlist//","//statfile,ver-,>& "dev$null")
   delete (im_offsets//","//uniq//"*",ver-,>& "dev$null")
   
end
