# IRCOMBINE: 06APR94 KMM
# IRCOMBINE produce IMCOMBINED IR image of heavily overlapped region
# IRCOMBINE: 18FEB92 KMM 07MAY92
#       06APR94 KMM replace "type" with "concatenate" or "copy"
# valid only for IRAF2.9EXPORT
procedure ircombine (match_name,infofile)

string match_name   {prompt="name of resultant composite image"}
file   infofile     {prompt="file produced by XYGET|XYADOPT|XYLAP|GETCOMBINE"}

file   outfile      {"", prompt="Output information file name"}
real   gxshift      {0.0, prompt="global xshift for final image"}
real   gyshift      {0.0, prompt="global yshift for final image"}
string goverlap     {"", prompt="Global overlap section (overrides all else)"}
string gsize        {"", prompt="Global image size (overrides all else)"}
# trim values applied to final image
string trimlimits   {"[0:0,0:0]",
                      prompt="added trim limits for input subrasters"}
bool   setpix       {no,prompt="Run SETPIX on data?"}
string maskimage    {"badmask", prompt="bad pixel image mask"}
bool   fixpix       {no,prompt="Run FIXPIX on data?"}
string fixfile      {"badpix", prompt="badpix file in FIXPIX format"}
int    zref_nim     {0,
                  prompt="List number of intensity reference frame (0 == none"}
string common       {"median",enum="none|adopt|mean|median|mode",
              prompt="Pre-combine common offset: |none|adopt|mean|median|mode|"}
real   lowerlim     {INDEF,prompt="Lower limit for exclusion in IMSTATS"}
real   upperlim     {INDEF,prompt="Upper limit for exclusion in IMSTATS"}
string interp_shift {"linear",enum="nearest|linear|poly3|poly5|spline3",
              prompt="IMSHIFT interpolant (nearest,linear,poly3,poly5,spline3)"}
string bound_shift  {"nearest",enum="constant|nearest|reflect|wrap",
                      prompt="IMSHIFT boundary (constant,nearest,reflect,wrap)"}
real   const_shift  {0.0,prompt="IMSHIFT Constant for boundary extension"}
real   svalue       {-1.0e8, prompt="Setpix value (<< floor)"}
real   floor        {-200., prompt="Rejection floor for imcombine"}
real   ceiling      {40000., prompt="Rejection ceiling for imcombine"}
real   ovalue       {-1000., prompt="Rejected pixel value for new image?"}
bool   size         {no, prompt="Compute image size?"}
bool   answer       {yes, prompt="Do you want to continue?", mode="q"}
bool   compute_size {yes, 
                       prompt="Do you want to [re]compute image size?",mode="q"}
bool   save_images  {no,prompt="Save images which were IMCOMBINED?"}
bool   do_combine   {yes,prompt="IMCOMBINE (else IRMATCH) into final image?"}
bool   verbose      {yes, prompt="Verbose output?"}
bool   format       {yes, prompt="Format output table"}

struct  *list1, *list2, *l_list

begin

      int    i,stat,nim,maxnim,slen,slenmax,njunk,pos1b,pos1e,pos2b,pos2e,
             nxoff0,nyoff0,minxoffset,minyoffset,c_opt,stat_zrefnim,
             ncols, nrows, nxhiref, nxloref, nyhiref, nyloref,
             nxhi, nxlo, nyhi, nylo, nxhisrc, nxlosrc, nyhisrc, nylosrc,
             nxlotrim,nxhitrim,nylotrim,nyhitrim,
             nxlolap,nxhilap,nylolap,nyhilap,
             nxhimat,nxlomat,nyhimat,nylomat,
             nxlonew,nxhinew,nylonew,nyhinew,
             nxmat0, nymat0, nxmos0, nymos0, ixs, iys, ncolsout,nrowsout
      real   zoff, rjunk, xin, yin, xmat, ymat, fxs, fys,
             xs, ys, xoff, yoff, g_xshift, g_yshift, xmax, xmin, ymax, ymin,
             xofftran,yofftran,gtxmax, gtxmin, gtymax, gtymin,
             oxmax,oxmin,oymax,oymin,xoffset,yoffset,
             xlo, xhi, ylo, yhi, xshift, yshift, reject_value
      real   roff, delta, rmedian, rmode, avestat, avemean, avemode, avemedian,
             rmean, stddev_mean,stddev_median,stddev_mode
      bool   firsttime, do_tran, tran, max_tran, prior_tran, fluxtran,
             new_origin, found_zref
      string uniq,imname,tmpname,matchname,slist,sjunk,soffset,encsub,sopt,
             src,srcsub,mos,mossub,mat,matsub,ref,refsub,stasub,lapsec,outsec,
             vigsec,sformat,traninfo,sxrot,syrot,sxmag,symag,sxshift,syshift,
             dbtran,cotran,consttran,geomtran,interptran,boundtran,vcheck
      file   info,out,dbinfo,l_log,tmp1,tmp2,im1,im2,statlist,statfile,comblist,
             tmpimg,maskimg,valuimg,do1info,do2info,matinfo,newinfo,task,misc
      struct line = ""

      matchname   = match_name
      info        = infofile
      g_xshift    = gxshift
      g_yshift    = gyshift
      uniq        = mktemp ("_Ticb")
      task        = uniq // ".tsk"
      newinfo     = uniq // ".mat"
      dbinfo      = mktemp("tmp$icb")
      matinfo     = mktemp("tmp$icb")
      comblist    = mktemp("tmp$icb")
      statlist    = mktemp("tmp$icb")
      statfile    = mktemp("tmp$icb")
      do1info     = mktemp("tmp$icb")
      do2info     = mktemp("tmp$icb")
      tmp1        = mktemp("tmp$icb")
      tmp2        = mktemp("tmp$icb")
      misc        = mktemp("tmp$icb")
      l_log       = mktemp("tmp$icb")
      maskimg     = uniq // ".mim"
      valuimg     = uniq // ".vim"
      im1         = uniq // ".im1"
      im2         = uniq // ".im2"
      tmpimg      = uniq // ".tim"

      sjunk = cl.version		# get CL version
      stat = fscan(sjunk,vcheck)
      if (stridx("Vv",vcheck) <=0 )	# first word isn't version!
         stat = fscan(sjunk,vcheck,vcheck)

   # strip off trailing ".imh"
      i = strlen(matchname)
      if (substr(matchname,i-3,i) == ".imh")
         matchname = substr(mathname,1,i-4)

      if (! access(info)) { 		# Exit if can't find info
         print ("Cannot access info_file: ",info)
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

      if (svalue >= floor) {
         reject_value = floor - 1.0
         print ("Resetting reject_value from ",svalue," to ",reject_value)
      } else
         reject_value = svalue
      if (access(matchname//".imh")) {
            print("Image ",matchname," already exists!")
            goto err
      }

      c_opt = 0				# Establish common offset statistic
      if (common == "none")   c_opt = 0
      if (common == "adopt")  c_opt = 1
      if (common == "mean")   c_opt = 2
      if (common == "median") c_opt = 3
      if (common == "mode")   c_opt = 4
      print("#NOTE: ",common," statistics for data within ",
         lowerlim," to ",upperlim)

      if (setpix) {
         imcopy (maskimage, maskimg, verbose-) 
   # Sets bad pix to -1 and good to zero within the mask
         imarith (maskimg, "-", "1.0", valuimg,pix="real",calc="real",hpar="")
         imarith (valuimg,"*",reject_value,valuimg,pix="real",calc="real",
             hpar="")
         print ("#SETPIX to ",reject_value," using ", maskimage," mask")
      }

      l_list = l_log
      print (trimlimits) | translit ("", "[:,]", "    ", >> l_log)
      stat = (fscan(l_list,nxlotrim,nxhitrim,nylotrim,nyhitrim))

   # Transfer appropriate information from reference to output file
      match ("^\#DB",info,meta+,stop-,print-, > dbinfo)
      match ("^COM",info,meta+,stop-,print-, > matinfo)
   # count number of images, excluding reference images
      count(matinfo,>> l_log); stat = fscan(l_list,maxnim)
      match ("^COM_000",matinfo,meta+,stop-,print-, > tmp1)
      count(tmp1,>> l_log); stat = fscan(l_list,i)
      maxnim -= i
      delete (tmp1, ver-, >& "dev$null")
   # make list of temporary images
      for (nim = 1; nim <= maxnim; nim += 1) {
         tmpname = uniq//"_000" + nim
         print (tmpname//".imh", >> comblist)
      }  
      print ("#NOTE: will combine ",maxnim," images...")

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
      print("#DBI    lowerlim        ",lowerlim,>> dbinfo)
      print("#DBI    upperlim        ",upperlim,>> dbinfo)
      print("#DBI    fixpix          ",fixpix,>> dbinfo)
      print("#DBI    fixfile         ",fixfile,>> dbinfo)
      print("#DBI    setpix          ",setpix,>> dbinfo)
      print("#DBI    set_mask        ",maskimage,>> dbinfo)
      print("#DBI    set_value       ",reject_value,>> dbinfo)
      print("#DBI    interp_shift    ",interp_shift,>> dbinfo)
      print("#DBI    bound_shift     ",bound_shift,>> dbinfo)
      print("#DBI    const_shift     ",const_shift,>> dbinfo)
      print("#DBI    imcomb_floor    ",floor,>> dbinfo)
      print("#DBI    imcomb_ceiling  ",ceiling,>> dbinfo)
      print("#DBI    imcomb_oval     ",ovalue,>> dbinfo)
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
      print("#DBI    overlap_sec     ",lapsec,>> dbinfo)
      print("#DBI    out_sec         ",outsec,>> dbinfo)
        
      slenmax = 0; stat_zrefnim = 0; njunk = 0
      list1 = newinfo 
      list2 = comblist
   # Loop through frames, imshift and setup for imstatistics
#      for (i = 1; fscan(list1,imname,src,nxlosrc,nxhisrc,nylosrc,nyhisrc,
#         nxmat0,nymat0,fxs,fys,soffset) != EOF; i += 1) {
      while (fscan(list1,imname,src,nxlosrc,nxhisrc,nylosrc,nyhisrc,
         nxmat0,nymat0,fxs,fys,soffset) != EOF) {
         pos1b = stridx("_",imname)+1
         if (pos1b < 2) {
            print("Image path position (MAT_pos) missing at ",imname)
            goto err
         } else
            nim = int(substr(imname,pos1b,strlen(imname)))

         if (nim == 0 ) {	 			# SKIP COM_000 REF IMAGE
            print("#NOTE: skipping COM_000 ",src)
            njunk = -1
            next
         }

         if (nim == zref_nim) stat_zrefnim = i + njunk	# MARK ZREF_NIM in STAT

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

   # Redetermine the source and destination sections
         nxlomat += xoffset; nxhimat += xoffset
         nylomat += yoffset; nyhimat += yoffset
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
      }

      if (c_opt <= 1) goto afterstat

   # Determine image statistics within overlap section for calculating offsets
      delete (tmp1, ver-, >& "dev$null")
   # Get header
      imstatistics("",
         fields="image,mean,midpt,mode,stddev,npix,min,max",
         lower=lowerlim,upper=upperlim,binwidth=0.001,format+,> statfile)
      imstatistics("@"//statlist,
         fields="image,mean,midpt,mode,stddev,npix,min,max",
         lower=lowerlim,upper=upperlim,binwidth=0.001,format-,>> statfile)
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


      if (stat_zrefnim > 0) { #Get values for selected intensity reference frame
         found_zref = no
         for (i = 1; fscan(list1,avemean,avemedian,avemode) != EOF; i += 1) {
             if (i == stat_zrefnim) {
                print ("Intensities for reference frame= ",
                   avemean,avemedian,avemode)
                print ("Intensities for reference frame= ",
                   avemean,avemedian,avemode,>> misc)
                found_zref = yes
                break
             }
         }
         if (! found_zref) {
            print ("Intensities for reference frame not found!")
            goto err
         }
      }
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
         print (delta,>> tmp1)
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
         imcombine("@"//comblist,matchname,sigma="",logfile=do2info,
            option="threshold",outtype="",expname="",scale-,offset-,weight-,
            modesec=lapsec,lowreject=floor,highreject=ceiling,blank=ovalue)
      } else {
         imrename(tmpimg,matchname,verbose-)
      }

   # output information
      delete (out, ver-,>& "dev$null") # delete prior version (we said OK above)
      copy (dbinfo,out,verbose-)
   # update intenisty offset data
      delete(tmp2//","//matinfo//","//dbinfo,verify-,>& "dev$null")
   # Skip reference frame
      match ("^COM_000",newinfo,meta+,stop-,print-,> dbinfo)
      match ("^COM_000",newinfo,meta+,stop+,print-,> matinfo)
      delete(newinfo,verify-,>& "dev$null")
      copy (dbinfo,newinfo,verbose-)

      fields(matinfo,"1-10",lines="1-",print-,quit-,>> tmp2)
      join(tmp2,tmp1,out="STDOUT",missing="Missing",delim=" ",
          maxchars=161,shortest-,verbose+,>> newinfo)
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
      if (verbose) concatenate (do2info,out,append+)
      if (stat_zrefnim > 0) concatenate (misc,out,append+)
   
   # Finish up

err:  list1 = ""; list2 = ""; l_list = ""
      imdelete(tmpimg//","//maskimg,verify-,>& "dev$null")
      imdelete(valuimg//","//im1//","//im2, verify-,>& "dev$null")
      if (access(comblist) && ! save_images)
         imdelete("@"//comblist,verify-,>& "dev$null")
      delete (l_log//","//statfile//","//statlist,ver-,>& "dev$null")
      delete (do1info//","//do2info,ver-,>& "dev$null")
      delete (misc//","//dbinfo//","//matinfo,ver-,>& "dev$null")
      delete (comblist//","//tmp1//","//tmp2,ver-,>& "dev$null")
      delete (uniq//"*",ver-,>& "dev$null")
   
   end
#         match ("^\#DB",dbmos,meta+,stop-,print-) |
#            match ("^\#DB[GIT]",meta+,stop+,print-) |		# omit prior
#            match ("do_tran",meta+,stop+,print-) |		# omit do_tran
#            match ("out_sec",meta-,stop+,print-, > dbinfo)	# omit out_sec
