# XYADOPT: 15JUN92 KMM
# XYADOPT determine shifts between source images
# XYADOPT  15JUN92 add all_images so one can over-ride nsubraster in mosaic
#                  database to set number of images to adopt from frame_nums

procedure xyadopt (images, frame_nums, basis_info)

string images       {prompt="IRMOSAIC image name | @list of images to compare"}
string frame_nums   {"*|1",prompt="Selected image numbers within IRMOSAIC"}
string basis_info   {prompt="Lap_basis info file from GETCOMBINE|IRCOMBINE"}

string mos_info     {"default",prompt="Images info file from IRMOSAIC|MKMOS"}
# trim values applied to final image
string  trimlimits  {"[0:0,0:0]",prompt="trim limits on the input subrasters"}
bool   answer       {yes, prompt="Do you want to continue?", mode="q"}
string outfile      {"", prompt="Output information file"}
bool   tran         {no, prompt="Request GEOTRAN images before IMCOMBINE?"}
string db_tran      {"", prompt="name of database file output by GEOMAP"}
# string co_tran      {"", prompt="name of coordinate file input to GEOTRAN"}
string geom_tran    {"linear", prompt="GEOTRAN transformation geometry"}
bool   max_tran     {yes, prompt="Offset GEOTRAN to save  maximum image?"}
string interp_tran  {"linear", prompt="GEOTRAN interpolant"}
string bound_tran   {"nearest", prompt="GEOTRAN boundary"}
real   const_tran   {0.0, prompt="GEOTRAN constant boundary extension value"}
bool   all_frames   {no, prompt="Use entire frame_nums range (else nsubraters)"}
bool   flux_tran    {yes, prompt="Conserve flux upon GEOTRAN?"}
bool   verbose      {no, prompt="Verbose reporting"}

struct  *list1,*list2,*list3,*l_list

begin

      int    i,stat,nim,nin,lo,hi,ncomp,pos1b,pos1e,wcs,gridx,gridy,maxnim,
             ncols, nrows, nxsub, nysub, nxoverlap, nyoverlap, nsubrasters,
             mos_xsize, mos_ysize,slen,slenmax,ixs,iys,ref_nim,refnim,
             nxhisrc,nxlosrc,nyhisrc,nylosrc,nxhimat,nxlomat,nyhimat,nylomat,
             nxhiref,nxloref,nyhiref,nyloref,nxhimos,nxlomos,nyhimos,nylomos,
             nxhilap, nxlolap, nyhilap, nylolap, ncolsout, nrowsout,
             nxhitrim, nxlotrim, nyhitrim, nylotrim,
             nxmos0, nymos0, nxmat0, nymat0, nxref0, nyref0, nxoff0, nyoff0
      int    nxlo, nxhi, nylo, nyhi, nxlonew, nxhinew, nylonew, nyhinew
      real   xin, yin, xref, yref, xs, ys, fxs,fys,xmin,xmax,ymin,ymax,
             xoffset,yoffset,xofftran,yofftran,xshift,yshift,xlo,xhi,ylo,yhi,
             xoff,yoff
      string l_comp,out,nim_name,uniq,sjunk,soffset,sname,vcheck,sformat,
             lap,src,srcsub,mos,mossub,mat,matsub,mos_name,ishifts,lapsec,refid,
             img,ref,refsub,nimtag,reftag,image_nims,corner,order,tmpimg,reflap,
             serr,vigsec,encsub,outsec,comsub,dbmos,imname,ref_name,baseid,
             base_ref,sxrot,syrot,sxmag,symag,sxshift,syshift,
             dbtran,cotran,const,geomtran,interp,bound,flux,
             ref_id,imagenums
      file   info,l_log,refimg,nimlist,
             compfile,imtagfile,tmp1,tmp2,tmp3,pathinfo,dbinfo,imlist,
             traninfo,matinfo,cominfo
      bool   mosaic,found,new_origin,prior_tran,do_tran,maxtran
      struct command = ""
      struct line = ""

      lap       = "adopt"
      l_comp    = images
      imagenums = frame_nums
      info      = basis_info

      uniq        = mktemp ("_Tgcm")
      tmpimg      = uniq//"_000"
      tmp1        = mktemp ("tmp$gcm")
      tmp2        = mktemp ("tmp$gcm")
      tmp3        = mktemp ("tmp$gcm")
      dbinfo      = mktemp ("tmp$gcm")
      traninfo    = mktemp ("tmp$gcm")
      matinfo     = mktemp ("tmp$gcm")
      cominfo     = mktemp ("tmp$gcm")
      pathinfo    = mktemp ("tmp$gcm")
      imtagfile   = mktemp ("tmp$gcm")
      compfile    = mktemp ("tmp$gcm")
      nimlist     = mktemp ("tmp$gcm")
      imlist      = mktemp ("tmp$gcm")
      l_log       = mktemp ("tmp$gcm")
      refimg      = mktemp ("tmp$gcm")
      l_list = l_log

      sjunk = cl.version		# get CL version
      stat = fscan(sjunk,vcheck)
      if (stridx("Vv",vcheck) <=0 )	# first word isn't version!
         stat = fscan(sjunk,vcheck,vcheck)

      ref_id = "1"
      print (imagenums) | translit ("", "|", " ", >> l_log)
      stat = fscan(l_list,image_nims,ref_id)
      if (nscan() < 2) {
         print("Warning: no reference id ( right side of | ) found!")
         goto skip
      }
      dbmos      = mos_info
      if (dbmos == "" || dbmos == " " || substr(dbmos,1,3) == "def")
         dbmos = "default"
      img        = l_comp
      i = strlen(img)
      if (substr(img,i-3,i) == ".imh") img = substr(img,1,i-4)
      if (substr(img,1,1) == "@") {		# It's an @list of images
         img = substr(img,2,strlen(img))
         mos_name   = img
         mosaic = no
         baseid = "COM_000"
   # Expand input file name list; option="root" truncates lines beyond ".imh"
         sections (l_comp,option="root") |
            match("\#",meta+,stop+,print-,> imlist)
         print("Image is an @list: dbmos= ",dbmos," using ",image_nims,
            " with baseid = ",baseid)
      } else {			  		# It's a mosaic image
         mosaic = yes
         mos_name   = img
         if (dbmos == "default") dbmos = mos_name//".dbmos"
         baseid = "COM_000"
         print("Image is a MOSAIC: dbmos= ",dbmos," using ",image_nims,
            " with baseid = ",baseid)
      }
      print ("ADOPT: basis_info= ",info)
      print ("Reference image ID = ",ref_id)
      if (tran) print ("Requesting GEOTRAN via database ",db_tran)
 
      if ((dbmos != "default") && (! access(dbmos))) {
         print ("Information file ",dbmos," not found!")
         goto skip
      } else if (!access(info)) {
         print ("Reference information file ",info," not found!")
         goto skip
      } else if (tran && !access(db_tran)) {
         print ("GEOTRAN database file db_tran ",db_tran," not found!")
         goto skip
      }
         
   # establish ID of output info file
      if (outfile == "" || outfile == " " || outfile == "default") {
         out = mos_name//".xycom"
      } else
         out = outfile
      if (out != "STDOUT" && access(out)) {
         print("Will append to output_file ",out,"!")
         if (!answer) goto skip
         print ("Note: appending to existing output_file ",out)
      } else
         print ("Output_file= ",out)

   # establish whether ref_id is a list number or a name
      if (stridx("0123456789",ref_id) == 1) {		# It's a list number
         ref_nim = int (substr(ref_id,1,strlen(ref_id)))
      } else {						# It's an image name
         ref_nim = 0
         ref_name = ref_id
      }
   # locate ref_id
      list1 = ""; delete (tmp1,verify-,>& "dev$null")
      imname = baseid + ref_nim
      fields (info,"1-2",lines="1-",quit-,print-) |
         match ("^"//imname,meta+,stop-,print-,> tmp1)
      list1 = tmp1; stat = fscan (list1,sjunk,ref_name)
      if (nscan() != 2 ) {
         print ("Warning: reference name for ref_id =",ref_id," ",imname,
            " not found!")
         goto skip
      }

      if (mosaic) {
         match ("^\#DB",dbmos,meta+,stop-,print-) |
            match ("^\#DB[GIT]",meta+,stop+,print-) |		# omit prior
            match ("do_tran",meta+,stop+,print-) |		# omit do_tran
            match ("out_sec",meta-,stop+,print-, > dbinfo)	# omit out_sec
         match ("^\#DBT",dbmos,meta+,stop-,print-, > traninfo)
   # Ascertain whether dbmosfile is from IRMOSAIC or MKMOS
         count (dbinfo, >> l_log); stat = fscan(l_list, i)
         if (i <= 0) {	 # It's a IRMOSAIC file, make MKMOS equivalent output
            list1 = ""; delete (tmp1,verify-,>& "dev$null")
            list1 = dbinfo 
            while (fscan(list1, sjunk, line) != EOF) {
               print("#DB ",line, >> tmp1)
               stat = fscan(line, sjunk)
               if (sjunk == "nsubrasters") break
            }
            list1 = ""; delete (dbinfo,verify-,>& "dev$null")
            copy (tmp1, dbinfo, ver-)
            delete (tmp1,verify-,>& "dev$null")
         }
   # Indicate GEOTRAN status of input images
         l_list = ""; delete (l_log,verify-,>& "dev$null")
         l_list = l_log
         match ("mos_transform",traninfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, prior_tran)
   # Extract mosaic parameters from dbinfofile
         match ("ncols",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, ncols)
         match ("nrows",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, nrows)
         match ("nxsub",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, nxsub)
         match ("nysub",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, nysub)
         match ("nxoverlap",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, nxoverlap)
         match ("nyoverlap",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, nyoverlap)
         match ("corner",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, corner)
         match ("order",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, order)
         match ("nsubrasters",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, nsubrasters)
         ncomp = nsubrasters

         list1 = ""; delete (tmp1, ver-, >& "dev$null")
      } else {
         count (imlist, >> l_log); stat = fscan(l_list, ncomp)
         prior_tran = no
      }

   # Size of output image
      list1 = tmp1; delete (tmp1, ver-, >& "dev$null")
      match ("out_sec",info,meta-,stop-,print-) |		# MIG order
         sort (col=1,ignore+,numeric-,reverse+, > tmp1)
      if (fscan(list1, sjunk, sjunk, outsec) != 3) {
         outsec = "[1:256,1:256]"; ncolsout = 256; nrowsout = 256
      } else { 
         print (outsec) | translit ("", "[:,]", "    ", >> l_log)
         stat = (fscan(l_list,nxlosrc,nxhisrc,nylosrc,nyhisrc))
         ncolsout = nxhisrc - nxlosrc + 1
         nrowsout = nyhisrc - nylosrc + 1
      }
      delete (tmp1, ver-, >& "dev$null")
      print ("Outsec: ",outsec)

   # Expand the range of images
     
      if (all_frames)
        maxnim = 10000
      else
        maxnim = ncomp

      expandnim(image_nims,ref_nim=ref_nim,max_nim=maxnim,>> nimlist)

      mos = ref_name
      ref_name = mos_name//substr(mos,stridx("[",mos),strlen(mos))
      list1 = ""; delete (tmp1,verify-,>& "dev$null")
      match ("^"//baseid,info,meta+,stop-,print-,> tmp1)
      list1 = tmp1; stat = fscan (list1,sjunk,mos)
      if (nscan() != 2 ) {
         print ("Warning: basis reference name for = ",baseid," not found!")
         goto skip
      } else {
         base_ref = mos_name//substr(mos,stridx("[",mos),strlen(mos))
         if (base_ref != ref_name) {
            print ("Warning: current reference ",ref_name,
               " differs from basis reference ",base_ref)
            refnim = ref_nim
#            if (!answer) goto skip		# Bail out if not intended
         } else {
           refnim = 0
         }
      }
      list1 = ""; delete (tmp1,verify-,>& "dev$null")
      delete (l_log,ver-,>& "dev$null"); l_list = l_log	# Reset l_log
      match ("^COM",info,meta+,stop-,print-, > matinfo)	# Get prior info
      count(matinfo,>> l_log); stat = fscan(l_list,maxnim)	# count images
      list1 = nimlist # Note: ref_id is prepended to this ordered unique list
      for (nin = 0; fscan (list1,nim) != EOF; nin += 1) {
         list2 = matinfo
         while (fscan (list2,imname,mos) != EOF) {
            stat = int(substr(imname,stridx("_",imname)+1,strlen(imname)))
            if (stat == nim) {
               mossub = substr(mos,stridx("[",mos),strlen(mos))
               found = yes
               break
            }
            found = no
         }
         if (!found) {
            nimtag = "COM_000" + nim
            print("Image path position missing for ",nimtag)
            next
         }
         if (nin == 0) nim = refnim
         nimtag = mos_name//"_000" + nim
         mos = mos_name//mossub
         if (nin == 0) {
            refid  = mos   
            reftag = nimtag
         }
         print (nimtag," ",mos," ",nim," 0 0 ",>> imtagfile)
      }

      xofftran = 0; yofftran = 0
      nxlotrim = 0; nxhitrim = 0; nylotrim = 0; nyhitrim = 0
      soffset = "0.0" 					# Null z offets
      print (trimlimits) | translit ("", "[:,]", "    ", >> l_log)
      stat = (fscan(l_list,nxlotrim,nxhitrim,nylotrim,nyhitrim))

      if (mosaic) {
   # Generate appropriate mosaic subsections 
         nxlosrc = 1; nxhisrc = ncols; nylosrc = 1; nyhisrc = nrows
         nxloref = 1; nxhiref = ncols; nyloref = 1; nyhiref = nrows
         mos_xsize = ncols - nxoverlap
         mos_ysize = nrows - nyoverlap
         nxref0 = 0; nyref0 = 0
      } else {
         list1 = ""; delete (tmp1//","//tmp2//","//tmp3,ver-, >& "dev$null")
   # Locate reference image and to list
         list1 = imlist
         if (ref_nim != 0) {
            for (nim = 1; fscan (list1,img) !=EOF; nim += 1) {
               if (nim == ref_nim) {
                  print (img, > tmp2)
                  break
               }
            }
         } else
           print (ref_name, > tmp2)
         concatenate(imlist,tmp2,append+)
   # Get image dimensions
         imhead("@"//tmp2,long-,user-,>> tmp3)
         list1 = ""; delete (tmp1, ver-, >& "dev$null")
         list1 = tmp3  
         for (nin = 0; fscan (list1,img) !=EOF; nin += 1) {
   # Strip off trailing ".imh"
            pos1b = stridx("[",img); pos1e = stridx("]",img)
            mossub = substr(img,pos1b,pos1e)
            img = substr(img,1,pos1b-1)
            i = strlen(img)
            nimtag = "IMG"//"_000" + nin
            if (substr(img,i-3,i) == ".imh") img = substr(img,1,i-4)
            if (nim == 0) {
               refimg = img
               reftag = nimtag
            }
            print (img,>> compfile)
            print (nimtag," ",img//mossub," ",nin," 0 0",>> imtagfile)
         } 
         ncomp = nin
         list1 = ""; delete (tmp1//","//tmp2//","//tmp3,ver-, >& "dev$null")
#FIX SO THAT any prior GEOTRAN info is available for use
         prior_tran = no
         print("#DBT    mos_transform   ","no",>> traninfo)
      }
      if (tran) {
   # Check dbmos for GEOTRAN info.  If available and it was used, use it,
   #    else use db_tran
         match ("mos_transform",traninfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, prior_tran)
         if (prior_tran) {
            do_tran = no
            match ("db_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, dbtran)
            match ("begin",dbtran,meta-,stop-,print-,>> l_log)
            stat = fscan(l_list, sjunk, cotran)
            match ("geom_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, geomtran)
            match ("interp_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, interp)
            match ("bound_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, bound)
            match ("const_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, const)
            match ("fluxconserve",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, flux)
            match ("max_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, maxtran)
            match ("xshift_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, sxshift)
            match ("yshift_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, syshift)
            match ("xoffset_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, xofftran)
            match ("yoffset_tran",traninfo,meta-,stop-,print-, >> l_log)
            stat = fscan(l_list, sjunk, sjunk, yofftran)
         } else {
            do_tran = yes
            dbtran = db_tran
            geomtran = geom_tran
            bound = bound_tran
            interp = interp_tran
            const = const_tran
            flux  = flux_tran
            maxtran = max_tran
   # Fetch info from GEOMAP database file for this data
            match ("begin",dbtran,meta-,stop-,print-,>> l_log)
            stat = fscan(l_list, sjunk, cotran)
            match ("xmag",dbtran,meta-,stop-,print-, >> l_log)		#OMIT?
            stat = fscan(l_list, sjunk, sxmag)				#OMIT?
            match ("ymag",dbtran,meta-,stop-,print-, >> l_log)		#OMIT?
            stat = fscan(l_list, sjunk, symag)				#OMIT?
            match ("xrot",dbtran,meta-,stop-,print-, >> l_log)		#OMIT?
            stat = fscan(l_list, sjunk, sxrot)				#OMIT?
            match ("yrot",dbtran,meta-,stop-,print-, >> l_log)		#OMIT?
            stat = fscan(l_list, sjunk, syrot)				#OMIT?
            match ("xshift",dbtran,meta-,stop-,print-, >> l_log)	#OMIT?
            stat = fscan(l_list, sjunk, sxshift)			#OMIT?
            match ("yshift",dbtran,meta-,stop-,print-, >> l_log)	#OMIT?
            stat = fscan(l_list, sjunk, syshift)			#OMIT?
   # Determine offsets for this data
            if (maxtran) {
               xofftran = -int(sxshift)
               yofftran = -int(syshift)
            } else {
               xofftran = 0.0; yofftran = 0.0
            }
   # Create new traninfo
            delete (traninfo, ver-, >& "dev$null")
            print("#DBT    mos_transform   ","no",>> traninfo)
            print("#DBT    db_tran         ",dbtran,>> traninfo)
            print("#DBT    geom_tran       ",geomtran,>> traninfo)
            print("#DBT    xshift_tran     ",sxshift,>> traninfo)	#OMIT?
            print("#DBT    yshift_tran     ",syshift,>> traninfo)	#OMIT?
            print("#DBT    xmag_tran       ",sxmag,>> traninfo)		#OMIT?
            print("#DBT    ymag_tran       ",symag,>> traninfo)		#OMIT?
            print("#DBT    xrot_tran       ",sxrot,>> traninfo)		#OMIT?
            print("#DBT    yrot_tran       ",syrot,>> traninfo)		#OMIT?
            print("#DBT    interp_tran     ",interp,>> traninfo)
            print("#DBT    bound_tran      ",bound,>> traninfo)
            print("#DBT    const_tran      ",const,>> traninfo)
            print("#DBT    fluxconserve    ",flux,>> traninfo)
            print("#DBT    max_tran        ",max_tran,>> traninfo)
            print("#DBT    xoffset_tran    ",xofftran,>> traninfo)
            print("#DBT    yoffset_tran    ",yofftran,>> traninfo)
         }
      } else {
         xofftran  = 0.0; yofftran  = 0.0
         sxrot = "INDEF"; syrot = "INDEF"
         sxmag = "INDEF"; symag = "INDEF"
         sxshift = "0.0"; syshift = "0.0"
         do_tran = no
         maxtran = no
         dbtran = ""; cotran = ""
         geomtran = ""; bound = ""; interp = ""; const = ""; flux  = ""
      }

      time(> tmp1); list1 = tmp1; stat = fscan(list1,line)
      list1 = ""; delete (tmp1, ver-, >& "dev$null")
   # log parameters to database file
      print("#DBG ",line," GETCOMBINE: ",lap,>> dbinfo)
      print("#DBG    lap_basis       ",lap,>> dbinfo)
      print("#DBG    basis_info      ",info,>> dbinfo)
      print("#DBG    mos_info        ",dbmos,>> dbinfo)
      print("#DBG    image_nims      ",image_nims,>> dbinfo)
      print("#DBG    ref_image       ",refid,>> dbinfo)
      print("#DBG    ref_nim         ",ref_nim,>> dbinfo)
      print("#DBG    do_tran         ",do_tran,>> dbinfo)

      slenmax = 0
      soffset = " 0.0"
      delete (l_log,ver-,>& "dev$null"); l_list = l_log		# Reset l_log
      list1 = imtagfile
   # print ("COM_"//pathpos," ",src," ",nxlosrc,nxhisrc,nylosrc,nyhisrc,
   #    nxmat0,nymat0,xs,ys,soffset)
      for (i = 0; fscan(list1,nimtag,src,nim) != EOF; i += 1) {
         list2 = matinfo
   # search for corresponding entry
         for (nin = 0; fscan(list2,imname,mat,nxlomat,nxhimat,nylomat,nyhimat,
            nxmat0,nymat0,xs,ys) != EOF; nin += 1) {
            pos1b = stridx("_",imname)+1
            stat = int(substr(imname,pos1b,strlen(imname)))
            if (stat == nim) {
               found = yes
               break
            }
            found = no
         }
         if (!found) {
            print("Image path position missing for ",nimtag)
            next
         }
   # Override any pre-existing SRC information
         if (!mosaic)  {
            print (src) | translit ("", "[:,]", "    ", >> l_log)
            stat = (fscan(l_list,sjunk,nxlosrc,nxhisrc,nylosrc,nyhisrc))
         } else {
            nxlosrc = 1; nxhisrc = ncols; nylosrc = 1; nyhisrc = nrows
         }
         if (nin == 0) imname = baseid
         print (imname," ",src," ",nxlosrc,nxhisrc,nylosrc,nyhisrc,
            nxmat0,nymat0,xs,ys,soffset,>> tmp2)
     }

      l_list = ""; delete (l_log, ver-, >& "dev$null"); l_list = l_log

      new_origin = no

      if (new_origin) print ("Will [re]optimize origin.")

   # Compute minimum rectangle enclosing region and overlap region
      closure (tmp2,xofftran,yofftran,trimlimits=trimlimits,
         interp_shift=interp_tran,origin=new_origin,verbose+,format+,> tmp3)
      type (tmp3)
      match ("^COM",tmp3,meta+,stop-,print-, > cominfo)
      match ("^ENCLOSED_SIZE",tmp3,meta+,stop-,print-,>> l_log)
      stat = fscan(l_list,sjunk,encsub)
      print (encsub) | translit ("", "[:,]", "    ", >> l_log)
      stat = (fscan(l_list,nxlomat,nxhimat,nylomat,nyhimat))
      match ("^UNAPPLIED_OFFSET",tmp3,meta+,stop-,print-,>> l_log)
      stat = fscan(l_list,sjunk,xoffset,yoffset)
      match ("^OVERLAP",tmp3,meta+,stop-,print-,>> l_log)
      stat = fscan(l_list,sjunk,lapsec,vigsec)
      print (lapsec) | translit ("", "[:,]", "    ", >> l_log)
      stat = (fscan(l_list,nxlolap,nxhilap,nylolap,nyhilap))
      if (lapsec == "[0:0,0:0]") lapsec = ""
      if ((lapsec == "") || (nxhilap <= nxlolap) || (nyhilap <= nylolap)) {
         print ("#WARNING! overlap section: ",lapsec," is unphysical!") 
         print ("#WARNING! overlap section: ",lapsec," is unphysical!",>> out) 
      } else {
         print ("#NOTE: overlap section: ",lapsec) 
         print ("#NOTE: overlap section: ",lapsec,>> out) 
      }
      if (new_origin) {
   # Establishes origin at (0,0)
         ncolsout = nxhimat - nxlomat + 1
         nrowsout = nyhimat - nylomat + 1
   # Override minimum rectangle
         outsec  = "[1:"// ncolsout //",1:"// nrowsout //"]"
      } else {	# null out unapplied offsets since we don't want to apply them
         xoffset = 0
         yoffset = 0
      }

      print("#DBG    trimlimits      ",trimlimits,>> dbinfo)
      print("#DBG    xoffsettran     ",xofftran,>> dbinfo)
      print("#DBG    yoffsettran     ",yofftran,>> dbinfo)
      print("#DBG    out_sec         ",outsec,>> dbinfo)
   # Report minimum offsets required, but not applied to COM info
      type (dbinfo,>> out)
      type (traninfo,>> out)
      type (cominfo,>> out)
         
   # Finish up
skip:

      list1=""; list2=""; list3=""; l_list=""
      if (mosaic && access(compfile)) imdelete("@"//compfile,ver-,>& "dev$null")
      if (mosaic) imdelete (refimg, ver-,>& "dev$null")
      delete (tmp1//","//tmp2//","//tmp3//","//dbinfo,ver-, >& "dev$null")
      delete (pathinfo//","//imtagfile//","//cominfo, ver-,>& "dev$null")
      delete (nimlist//","//compfile//","//l_log, ver-,>& "dev$null")
      delete (traninfo//","//matinfo, ver-,>& "dev$null")
      delete (imlist//","//uniq//"*", ver-,>& "dev$null")

end
