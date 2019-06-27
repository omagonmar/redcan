# XYLAP 06APR94 KMM
# XYLAP 15APR92 KMM
# XYLAP produce database for matched image from mosaiced image
#       06APR94 KMM replace "type" with "concatenate"
## sqiid calls: getcenters linklaps xytrace transmat
procedure xylap (mosimage,basisfile)

string mosimage    {prompt="MOSAIC image name"}
string basisfile   {prompt="File produced by CENTER||IRMATCH"}
string linkfile    {"default",prompt="File with selected XY linkage paths"}
string mos_info    {"default",prompt="Images info file from IRMOSAIC|SQMOS"}

int    nx_sub      {INDEF,
                        prompt="Number of input images along x direction"}
int    ny_sub      {INDEF,
                        prompt="Number of input images along y direction"}
int    nxrsub      {INDEF,prompt="index of x reference subraster"}
int    nyrsub      {INDEF,prompt="index of y reference subraster"}
bool   guess       {no, prompt="Replace null links with average values?"}
bool   new_origin  {yes, prompt="Move origin to lower left corner?"}
# trim values applied to final image
string trimlimits  {"[0:0,0:0]",prompt="trim limits on the input subrasters"}

bool   verbose     {yes, prompt="Verbose output during LINKLAPS?"}
string outfile     {"",prompt="Output file name"}

bool   tran        {no, prompt="Request GEOTRAN mosimage before IMCOMBINE?"}
string db_tran     {"", prompt="name of database file output by GEOMAP"}
string geom_tran   {"linear", prompt="GEOTRAN transformation geometry"}
bool   max_tran    {yes, prompt="Offset GEOTRAN to save  maximum image?"}
string interp_tran {"linear", prompt="GEOTRAN interpolant"}
string bound_tran  {"nearest", prompt="GEOTRAN boundary"}
real   const_tran  {0.0, prompt="GEOTRAN constant boundary extension value"}
bool   flux_tran   {yes, prompt="Conserve flux upon GEOTRAN?"}
string interp_shift {"linear",enum="nearest|linear|poly3|poly5|spline3",
              prompt="IMSHIFT interpolant (nearest,linear,poly3,poly5,spline3)"}
string logfile     {"STDOUT",prompt="Logfile name"}

struct  *l_list,*list1,*list2

   begin

      int    pos1e,pos1b,nim,nimref,stat,i,
             ncols,nrows,nxsub,nysub,nxoverlap,nyoverlap,nsubrasters,
             nxlotrim,nxhitrim,nylotrim,nyhitrim,
             nxhisrc,nxlosrc,nyhisrc,nylosrc,
             nxhimos,nxlomos,nyhimos,nylomos,
             nxmat0,nymat0,nxhimat,nxlomat,nyhimat,nylomat,
             ixs,iys,slen,slenmax,gridx,gridy
      real   xs,ys,fxs,fys,xoff,yoff
      string uniq,out,outbase,dbmos,basis,lap,cmd,sformat,soffset,img,links,
             sjunk,mos,mat,refmat,trim,src,mos_corner,mos_order,mos_name,baseid
      file   info,ctrinfo,lapinfo,dbinfo,mosinfo,matinfo,tmp1,tmp2,task,l_log
      bool   found

      img         = mosimage
      basis       = basisfile
      dbmos       = mos_info
      links       = linkfile
      uniq        = mktemp ("_Txyl")
      lapinfo     = uniq // ".lap"
      ctrinfo     = uniq // ".ctr"
      task        = uniq // ".tsk"
      dbinfo      = uniq // ".dbi"
      mosinfo     = uniq // ".mos"
      matinfo     = uniq // ".mat"
      tmp1        = uniq // ".tm1"
      tmp2        = uniq // ".tm2"
      l_log       = uniq // ".log"

   # check whether input stuff exists
      if (dbmos == "" || dbmos == " " || substr(dbmos,1,3) == "def")
         dbmos = "default"
      if (links == "" || links == " " || substr(links,1,3) == "def")
         links = "default"
      i = strlen(img)
      if (substr(img,i-3,i) == ".imh") img = substr(img,1,i-4)
      mos_name   = img
      if (dbmos == "default") dbmos = mos_name//".dbmos"
      baseid = "MOS_000"
      if (! access(dbmos)) {
         print ("Information file ",dbmos," not found!")
         goto skip
      } else if (tran && !access(db_tran)) {
         print ("GEOTRAN database file db_tran ",db_tran," not found!")
         goto skip
      } else if (!access(basis)) {
         print ("Basis file ",basis," does not exist!")
         goto skip
      }

   # establish ID of output info file
      if (outfile == "" || outfile == " " || outfile == "default") {
         outbase = mos_name
         out = mos_name//".xylap"
      } else {
         outbase = outfile
         out = outfile
      }
      if (out != "STDOUT" && access(out)) {
         print ("Output_file ",out, " already exists!")
         goto skip
      } else
         print ("Output_file= ",out)

# is it an IRMOSIAC or an SQMOS file?
      l_list = l_log
      match ("^MOS",dbmos,meta+,stop-,print-, > tmp1)
      count (tmp1, >> l_log)
      stat = fscan(l_list, nim)
      if (nim > 0)  		# it's an SQMOS file
         lap = "center"
      else
         lap = "irmatch"
      l_list =""; delete(l_log//","//tmp1,ver-,>& "dev$null")

      if (lap == "center") {

## GETCENTERS -- Procedure to compute the shifts for each subraster.
#  procedure getcenters(infofile,ctrfile)
#  string infofile    {prompt="Information file produced by MKMOS"}
#  string ctrfile     {prompt="Output file produced by CENTER"}
#  string  outfile    {"", prompt="Output information filename"}

         print ("GETCENTERS:")
         cmd = "getcenters "//dbmos//" "//basis//" out="//ctrinfo
         if (nx_sub == INDEF)
            cmd = cmd//" nx_sub=INDEF"
         else
            cmd = cmd//" nx_sub="//nx_sub
         if (ny_sub == INDEF)
            cmd = cmd//" ny_sub=INDEF"
         else
            cmd = cmd//" ny_sub="//ny_sub
         print (cmd, >> logfile)
         print (cmd) | cl

         if (links == "default") {	# Use preset linkages

## LINKLAPS determines origins for mosaic frames using output of GETCENTERS
##    and via row and column pathways
#  procedure linklaps (infofile)
#  string infofile    {prompt="Information file produced by GETLAPS"}
#  int    nx_sub      {INDEF,prompt="Number of input images along x direction"}
#  int    ny_sub      {INDEF,prompt="Number of input images along y direction"}
#  int    nxrsub      {INDEF,prompt="index of x reference subraster"}
#  int    nyrsub      {INDEF,prompt="index of y reference subraster"}
#  string trimlimits  {"[0:0,0:0]",prompt="trim limits on the input subrasters"}
#  bool	  verbose     {no,prompt="verbose output?"}
#  bool	  passmisc    {yes,prompt="pass thru misc output from GETLAPS?"}
#  file   outfile     {"", prompt="Output information file name"}

            print ("LINKLAPS:")
            cmd = "linklaps  "//ctrinfo//" out="//lapinfo//
               " verbose="//verbose//" pass+ trimlimits="//trimlimits//
               " guess="//guess
            if (nx_sub == INDEF)
               cmd = cmd//" nx_sub=INDEF"
            else
               cmd = cmd//" nx_sub="//nx_sub
            if (ny_sub == INDEF)
               cmd = cmd//" ny_sub=INDEF"
            else
               cmd = cmd//" ny_sub="//ny_sub
            if (nxrsub == INDEF)
               cmd = cmd//" nxrsub=INDEF"
            else
               cmd = cmd//" nxrsub="//nxrsub
            if (nyrsub == INDEF)
               cmd = cmd//" nyrsub=INDEF"
            else
               cmd = cmd//" nyrsub="//nyrsub
            print (cmd,>> logfile)
            print (cmd) | cl

         } else {			# Use designated linkages

## XYTRACE determines origins for mosaic frames using output of GETCENTERS
##    and arbirary pathways
# procedure xytrace (infofile,pathways)
#  file   infofile    {prompt="File produced by GETCENTERS"}
#  string linkfile    {prompt="File with selected XY linkage paths"}
#  int    nx_sub      {INDEF,prompt="Number of input images along x direction"}
#  int    ny_sub      {INDEF,prompt="Number of input images along y direction"}
#  int    nxrsub      {INDEF,prompt="index of x reference subraster"}
#  int    nyrsub      {INDEF,prompt="index of y reference subraster"}
#  string trimlimits  {"[0:0,0:0]",prompt="trim limits on the input subrasters"}
#  bool   guess       {no,prompt="Guess missing links from average values?"}
#  bool	  verbose     {no,prompt="verbose output?"}
#  bool	  passmisc    {yes,prompt="pass thru misc output from GETLAPS?"}
#  file   outfile     {"", prompt="Output information file name"}
   
            print ("XYTRACE:")
            cmd = "xytrace  "//ctrinfo//" "//links//" out="//lapinfo//
               " verbose="//verbose//" pass+ trimlimits="//trimlimits//
               " guess="//guess
            if (nx_sub == INDEF)
               cmd = cmd//" nx_sub=INDEF"
            else
               cmd = cmd//" nx_sub="//nx_sub
            if (ny_sub == INDEF)
               cmd = cmd//" ny_sub=INDEF"
            else
               cmd = cmd//" ny_sub="//ny_sub
            if (nxrsub == INDEF)
               cmd = cmd//" nxrsub=INDEF"
            else
               cmd = cmd//" nxrsub="//nxrsub
            if (nyrsub == INDEF)
               cmd = cmd//" nyrsub=INDEF"
            else
               cmd = cmd//" nyrsub="//nyrsub
            print (cmd,>> logfile)
            print (cmd) | cl

         }

      } else if (lap == "irmatch") {

         print ("IRMATCH: basis_info= ",basis)
         l_list = l_log
   # Extract values from infofile
         match ("^\#DB",dbmos,meta+,stop-,print-, > dbinfo)
         match ("^MOS",dbmos,meta+,stop-,print-, > mosinfo)
   #      match ("trimsection",dbmos,meta-,stop-,print-, >> l_log)
   #      if (fscan(l_list, sjunk, sjunk, mos_section) == EOF) {
   #         l_list = l_log
   #         match ("section",dbmos,meta-,stop-,print-, >> l_log)
   #         stat = fscan(l_list, sjunk, sjunk, mos_section)
   #      }
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
         stat = fscan(l_list, sjunk, sjunk, mos_corner)
         match ("order",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, mos_order)
         match ("nsubrasters",dbinfo,meta-,stop-,print-, >> l_log)
         stat = fscan(l_list, sjunk, sjunk, nsubrasters)
         ixs = 0
         iys = 0
   # Generate file relating path position to grid position
#         print("mkpathtbl 1 "//nsubrasters//" "//nxsub//" "//nysub//
#            " "//mos_order//" "//mos_corner//" sort- >> "//tmp2) | cl
         mkpathtbl(1,nsubrasters,nxsub,nysub,mos_order,mos_corner,sort-,
            format-,> tmp2)
    # Find information on reference subraster
         list1 = basis; list2 = tmp2
         while((fscan(list1,mos,trim,xs,ys,mat,soffset) != EOF) &&
            (fscan(list2,nim,gridx,gridy) != EOF)) {
            if (xs == 0.0 && ys == 0.0) {
               nimref = nim
               nxrsub = gridx
               nyrsub = gridy
               break
            }
         }
         slenmax = 0
         list1 = basis; list2 = tmp1
         while((fscan(list1,mos,trim,xs,ys,mat,soffset) != EOF) &&
            (fscan(list2,nim,gridx,gridy) != EOF)) {
            print (mos) | translit ("", "[:,]", "    ", >> l_log)
            stat = (fscan(l_list,src,nxlomos,nxhimos,nylomos,nyhimos))
            print (trim) | translit ("", "[:,]", "    ", >> l_log)
            stat = (fscan(l_list,nxlotrim,nxhitrim,nylotrim,nyhitrim))
            print (mat) | translit ("", "[:,]", "    ", >> l_log)
            stat = (fscan(l_list,sjunk,nxlomat,nxhimat,nylomat,nyhimat))
            i = strlen(src)
            if (substr(src,i-3,i) == ".imh") src = substr(src,1,i-4)
            src = src//"["//nxlomos//":"//nxhimos//","//
               nylomos//":"//nyhimos//"]"
            mat = "MAT_000" + nim
            xs = nxlomos - 1.0 + xs + nxoverlap*(gridx-nxrsub)
            ys = nylomos - 1.0 + ys + nyoverlap*(gridy-nyrsub)
            nxmat0 = nint(xs)
            nymat0 = nint(ys)
            fxs = xs - nxmat0
            fys = ys - nymat0
            fxs = 0.01*real(nint(100.0*fxs))
            fys = 0.01*real(nint(100.0*fys))
            slen = strlen(src); if (slen > slenmax) slenmax = slen
            print (mat," ",src," ",nxlotrim,nxhitrim,nylotrim,nyhitrim,
               nxmat0,nymat0,fxs,fys,soffset,>> matinfo)
         }  
      }

   # Get date and print date
      delete (tmp1, ver-, >& "dev$null")
      time(> tmp1); list1 = tmp1; stat = fscan(list1,line)
      list1 = ""; delete (tmp1, ver-, >& "dev$null")
   # log parameters to database file
      print("#DBG ",line," GETMATCH:",>> lapinfo)
      print("#DBG    basis_info      ",basis,>> lapinfo)
      print("#DBG    lap_basis       ",lap,>> lapinfo)
      print("#DBG    trimlimits      ",trimlimits,>> lapinfo)
      if (lap == "irmatch") { # log parameters to database file
         print("#DBG    nxrsub          ",nxrsub,>> lapinfo)
         print("#DBG    nyrsub          ",nyrsub,>> lapinfo)
         print("#DBG    xoffset         ",xoff,>> lapinfo)
         print("#DBG    yoffset         ",yoff,>> lapinfo)
         concatenate (dbinfo//","//mosinfo,lapinfo,append+)
   # fancy formatter 
         delete(task,verify-,>& "dev$null")
         sformat = '{printf("%s %'//-slenmax//
            's %3d %3d %3d %3d %4d %4d %5.2f %5.2f %s\\n"'//
            ',$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)}'
         print(sformat, > task)
         print("!awk -f ",task," ",matinfo," >> ",lapinfo) | cl
      }

# translate database to new format:
      cmd = "transmat "//lapinfo//" "//out//" tran="//tran
      if (tran) {
         cmd = cmd//" db_tran="//db_tran//" geom_tr="//geom_tran//
            " max_tran="//max_tran//" interp_tr="//interp_tran//
            " bound="//bound_tran//" const="//const_tran//
            " flux="//flux_tran
      }
      cmd = cmd//" interp_sh="//interp_shift//" new="//new_origin
      print (cmd, >> logfile)
      print (cmd) | cl
      if (verbose) {		# capture comments and append to end
         match ("^\#DB",lapinfo,meta+,stop+,print-) |
            match ("^MOS",,meta+,stop+,print-) |
            match ("^COM",,meta+,stop+,print-,>> out)
      }

   # Finish up
      skip:
      delete (uniq//"*", verify=no)

   end
