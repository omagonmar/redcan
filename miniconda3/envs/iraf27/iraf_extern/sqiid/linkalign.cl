# LINKALIGN: 07MAY92 KMM
## LINKALIGN determines origins for mosaic frames using output of GETLAPS

procedure linkalign (target,refer,align)

   string target      {prompt="Target info file from SQMOS|LINK|MKMATCH"}
   string refer       {prompt="Reference info file from LINK||MKMATCH"}
   string align       {prompt="Reference info file from GETALIGN"}
   bool   newmat      {yes, prompt="New/alter #MAT file?"}

   int    nxrsub      {INDEF,prompt="index of x reference subraster"}
   int    nyrsub      {INDEF,prompt="index of y reference subraster"}
   string trimlimits  {"[0:0,0:0]",prompt="trim limits on the input subrasters"}
   bool	  verbose     {no,prompt="verbose output?"}
   file   outfile     {"", prompt="Output information file name"}
   struct  *list1,*list2,*list3,*l_list

   begin

      int    i,nim,maxnim,stat,njunk,pos,pos1b,pos1e,nlines,
             inxmin,inxmax,inymin,inymax,outxmin,outxmax,outymin,outymax,
             ncols,nrows,nxsub,nysub,nxoverlap,nyoverlap,nsubrasters,
             mos_xsize,mos_ysize,mos_xrsub,mos_yrsub,
             nxlotrim,nxhitrim,nylotrim,nyhitrim,nxhi,nxlo,nyhi,nylo,
             nxhisrc,nxlosrc,nyhisrc,nylosrc,nxhiobj,nxloobj,nyhiobj,nyloobj,
             nxhiref,nxloref,nyhiref,nyloref,
             nxmat0,nymat0,nxhimat,nxlomat,nyhimat,nylomat,
             nxmat0ref,nymat0ref,nxmat0obj,nymat0obj,
             ixs,iys,slen,slen1max,slen2max,slen3max,
             ixhiobj[100], ixloobj[100], iyhiobj[100], iyloobj[100]
      real   mos_offset,mat_offset,net_offset,rjunk,xshift,yshift,
             fxs,fys,xs,ys,xoff,yoff,fxsref,fysref,fxsobj,fysobj,
             xmat0ref[100], ymat0ref[100], xmat0obj[100], ymat0obj[100]
     string  out,match,in_name,uniq,imname,slist,sjunk,soffset,vcheck,
             mos_name,mos_section,mos_corner,mos_order,mos_oval,
             src,srcsub,mos,mossub,mat,matsub,ref,refsub,obj,objsub,link,
             sformat,tarinfo,refinfo,aligninfo,
             obj_name[100],smoffset[100],matpos[100]
      file   info,dbinfo,mosinfo,newinfo,lnkinfo,lnkref,
             tarmat,refmat,dbtar,dbref,dbalign,tmp1,tmp2,tmp3,l_log,task
      struct line=""

      tarinfo     = target
      refinfo     = refer 
      aligninfo   = align 
      uniq        = mktemp ("_Tllp")
      dbinfo      = uniq // ".dbi"
      dbref       = uniq // ".dbr"
      dbtar       = uniq // ".dbt"
      dbalign     = uniq // ".dba"
      newinfo     = uniq // ".new"
      refmat      = uniq // ".rma"
      tarmat      = uniq // ".tma"
      mosinfo     = uniq // ".mos"
      lnkref      = uniq // ".lrf"
      lnkinfo     = uniq // ".lnk"
      tmp1        = uniq // ".tm1"
      tmp2        = uniq // ".tm2"
      tmp3        = uniq // ".tm3"
      task        = uniq // ".tsk"
      l_log       = uniq // ".log"

   # establish ID of output info file
      if (outfile == "" || outfile == " " || outfile == "default") {
         pos1e = stridx(".",tarinfo)-1
         if (pos1e > 1)
            out = substr(tarinfo,1,pos1e)//".align"
         else
            out = tarinfo//".align"
      } else
         out = outfile
      if (out != "STDOUT" && access(out)) {
         print ("Output_file ",out, " already exists!")
         goto skip
      } else
         print ("Output_file= ",out)

      sjunk = cl.version		# get CL version
      stat = fscan(sjunk,vcheck)
      if (stridx("Vv",vcheck) <=0 )	# first word isn't version!
         stat = fscan(sjunk,vcheck,vcheck)

      l_list = l_log
   # Extract values from infofile
      match ("^\#DB",tarinfo,meta+,stop-,print-, > dbtar)
      match ("^\#DB",refinfo,meta+,stop-,print-, > dbref)
      match ("^MOS",tarinfo,meta+,stop-,print-, > mosinfo)
      match ("trimsection",dbtar,meta-,stop-,print-, >> l_log)
      if (fscan(l_list, sjunk, sjunk, mos_section) == EOF) {
         l_list = l_log
         match ("section",dbtar,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, mos_section)
      }
      match ("ncols",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, ncols)
      match ("nrows",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, nrows)
      match ("nxsub",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, nxsub)
      match ("nysub",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, nysub)
      match ("nxoverlap",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, nxoverlap)
      match ("nyoverlap",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, nyoverlap)
      match ("corner",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, mos_corner)
      match ("order",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, mos_order)
      match ("nsubrasters",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, nsubrasters)
      match ("mosaic",dbtar,meta-,stop-,print-, >> l_log)
      stat = fscan(l_list, sjunk, sjunk, mos_name)
   # Expand default section
      if (mos_section == "[*,*]")
        mos_section = "[1:"//ncols//",1:"//nrows//"]"
      else {
        print("WARNING: mos_section != [*,*]; CAN NOT PROCESS further!")
        goto skip
      }

   # Note: format for IRMOSAIC database neither appends mos_section
   #   nor transfers section from @list to image id
#	orih064.imh	mosorihs.imh[1029:1284,1:256]	INDEF	

      print (mos_section) | translit ("", "[:,]", "    ", >> l_log)
      stat = (fscan(l_list,nxlosrc,nxhisrc,nylosrc,nyhisrc))
      print (trimlimits) | translit ("", "[:,]", "    ", >> l_log)
      stat = (fscan(l_list,nxlotrim,nxhitrim,nylotrim,nyhitrim))
      mos_xsize = ncols - nxoverlap
      mos_ysize = nrows - nyoverlap
#      if (nxrsub == INDEF)
#         mos_xrsub = int((nxsub+1)/2)
#      else
#         mos_xrsub = nxrsub
#      if (nyrsub == INDEF)
#         mos_yrsub = int((nysub+1)/2)
#      else
#         mos_yrsub = nyrsub
#      print("#DBL    nxrsub          ", mos_xrsub, >> dbinfo)
#      print("#DBL    nyrsub          ", mos_yrsub, >> dbinfo)
   # log parameters to database file
   # Get date and print date
      time(> tmp1); list1 = tmp1; stat = fscan(list1,line)
      list1 = ""; delete (tmp1, ver-, >& "dev$null")
      print("#DBA ",line," LINKALIGN:",>> dbtar)
      print("#DBA    target_info     ",tarinfo ,>> dbtar)
      print("#DBA    reference_info  ",refinfo ,>> dbtar)
      print("#DBA    alignment_info  ",aligninfo ,>> dbtar)
      print("#DBA    new_mat         ",newmat,>> dbtar)

      match ("^MAT",refinfo,meta+,stop-,print-, > refmat)
      if (!newmat)
         match ("^MAT",tarinfo,meta+,stop-,print-, > tarmat)
      else {
         nxmat0 = 0
         nymat0 = 0
         fxs = 0.0
         fys = 0.0
         soffset = "0.0"
         list1 = mosinfo
         while (fscan(list1,in_name,src,mos,sjunk,soffset) != EOF) {
   # Pick off _pos from MOS_pos and rename MAT_pos
            imname = "MAT"//substr(in_name,stridx("_",in_name),strlen(in_name))
            print (imname," ",mos," ",nxlosrc,nxhisrc,nylosrc,nyhisrc,
               nxmat0,nymat0,fxs,fys," ",soffset,>> tarmat)
         }
      }

      for (nim = 1; nim <= 100; nim += 1) {
         xmat0ref[nim] = 0.0 
         ymat0ref[nim] = 0.0 
         xmat0obj[nim] = 0.0 
         ymat0obj[nim] = 0.0 
         ixhiobj[nim] = 0
         ixloobj[nim] = 0
         iyhiobj[nim] = 0
         iyloobj[nim] = 0
         obj_name[nim] = ""
         smoffset[nim] = ""
      }
      inxmin = 0     
      inymin = 0      
      inxmax = 32000
      inymax = 32000
      outxmin = 32000
      outymin = 32000
      outxmax = 0
      outymax = 0
   # Extract relative alignment information
      match ("^SUM_SHIFTS",aligninfo,meta+,stop-,print-) | match (mos_name,
         meta+,stop-,print-,> dbalign)
      match ("^SUM_MATSUB",aligninfo,meta+,stop-,print-,> lnkref)
      list1 = refmat
      list2 = tarmat
#         if (vcheck < "2.9D") {
      for (nim = 1; ((fscan(list1,sjunk,ref,nxloref,nxhiref,nyloref,nyhiref,
         nxmat0ref,nymat0ref,fxsref,fysref) != EOF) &&
         (fscan(list2,imname,obj,nxloobj,nxhiobj,nyloobj,nyhiobj,
         nxmat0obj,nymat0obj,fxsobj,fysobj,soffset) != EOF)); nim += 1) {
         xmat0ref[nim] = nxmat0ref + fxsref
         ymat0ref[nim] = nymat0ref + fysref
         xmat0obj[nim] = nxmat0obj + fxsobj
         ymat0obj[nim] = nymat0obj + fysobj
         ixloobj[nim] = nxloobj
         ixhiobj[nim] = nxhiobj
         iyloobj[nim] = nyloobj
         iyhiobj[nim] = nyhiobj
         obj_name[nim] = obj
         smoffset[nim]  = soffset
         matpos[nim]   = imname
      }
      list1= ""; list2 = ""
      maxnim = nim-1
      slen1max = 0
      slen2max = 0
      slen3max = 0
      list1 = dbalign
      list2 = lnkref
    # update wherever new alignment information is available
      for (i = 1; ((fscan(list1,sjunk,xshift,yshift,obj,objsub) != EOF) &&
         (fscan(list2,sjunk,sjunk,sjunk,ref) != EOF)); i += 1) {
         nim = int(substr(obj,stridx("_",obj)+1,strlen(obj)))
         xmat0obj[nim] = xmat0ref[nim] + xshift
         ymat0obj[nim] = ymat0ref[nim] + yshift
         link          = objsub
         slen = strlen(ref); if (slen > slen2max) slen2max = slen
         slen = strlen(link); if (slen > slen3max) slen3max = slen
   # Pick off _pos from MAT_pos and rename #LNK_pos
         sjunk = matpos[nim]
         imname = "LNK"//substr(sjunk,stridx("_",sjunk),strlen(sjunk))
         print (imname," ",link," ",ref," ",xshift,yshift,>> lnkinfo)
      }
      for (nim=1; nim <= maxnim; nim +=1) {
         obj     = obj_name[nim]
         soffset = smoffset[nim]
   # Put in additional global trims
         nxloobj = ixloobj[nim] + nxlotrim
         nxhiobj = ixhiobj[nim] - nxhitrim
         nyloobj = iyloobj[nim] + nylotrim
         nyhiobj = iyhiobj[nim] - nyhitrim
         xs = xmat0obj[nim]
         ys = ymat0obj[nim]
         ixs = nint(xs)
         iys = nint(ys)  
         fxs = xs - ixs
         fys = ys - iys
         fxs = 0.01*real(nint(100.0*fxs))
         fys = 0.01*real(nint(100.0*fys))
   # Recode MAT table
         nxmat0 = ixs
         nymat0 = iys
    # find largest source field
         slen = strlen(obj); if (slen > slen1max) slen1max = slen
         print (matpos[nim]," ",obj," ",nxloobj,nxhiobj,nyloobj,nyhiobj,
            nxmat0,nymat0,fxs,fys,soffset,>> newinfo)
         outxmin = min(outxmin,nxloobj+nxmat0)
         outymin = min(outymin,nyloobj+nymat0)
         outxmax = max(outxmax,nxhiobj+nxmat0)
         outymax = max(outymax,nyhiobj+nymat0)
         inxmin = max(inxmin,nxloobj+nxmat0)
         inymin = max(inymin,nyloobj+nymat0)
         inxmax = min(inxmax,nxhiobj+nxmat0)
         inymax = min(inymax,nyhiobj+nymat0)
      }
      mat = "["//outxmin//":"//outxmax//","//outymin//":"//outymax//"]"
      src = "["//inxmin//":"//inxmax//","//inymin//":"//inymax//"]"
      print("#DBL    outside_sect    ",mat, >> dbtar)
      print("#DBL    inside_sect     ",src, >> dbtar)

      type (dbtar,> out)
      type (mosinfo,>> out)
   # fancy formatter 
      sformat = '{printf("%s %'//-slen3max//'s %'//-slen2max//
         's %5.2f %5.2f\\n"'//',$1,$2,$3,$4,$5)}'
      print(sformat, > task)
      print("!awk -f ",task," ",lnkinfo," >> ",out) | cl
      delete(task,verify-,>& "dev$null")
      sformat = '{printf("%s %'//-slen1max//
         's %3d %3d %3d %3d %4d %4d %5.2f %5.2f %s\\n"'//
         ',$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)}'
      print(sformat, > task)
      print("!awk -f ",task," ",newinfo," >> ",out) | cl

   skip :

   # Finish up
      delete (uniq//"*", verify=no)

   end
