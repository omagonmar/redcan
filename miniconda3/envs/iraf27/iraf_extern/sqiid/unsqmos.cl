# UNSQMOS: 20FEB92 KMM
# UNSQMOS - produce individual images from irmosaic and complete database:

procedure sqmos (mos_name)

string mos_name     {prompt="Input mosaic image from SQMOS|IRMOSAIC"}
string mos_info     {"default",prompt="database file from SQMOS|IRMOSAIC"}
bool   oldname      {no, prompt="Restore old image name from mos_info?"}
#string outfile      {"default",prompt="Output images"}

#string trim_section {"[*,*]",
#                      prompt="Input image section written to output image"}

struct	*list1,*l_list
 
begin

    file    l_log, dbinfo
    int     nx, ny, i, nin,stat,pos1b,pos1e,nim,ixs,iys,
            ncols,nrows,ncolsout,nrowsout,nxoverlap,nyoverlap,nsubrasters,
            nxlotrim,nxhitrim,nylotrim,nyhitrim
    string  in, out, mosout, img, junk, inmos, dbmos, mosbase,
            uniq, sjunk,src,mos,soffset,mospos,sname,smedian,
            mos_section,mos_corner,mos_order,mos_oval

   uniq    = mktemp ("_Tunq")
   dbinfo  = mktemp ("tmp$sqm")
   l_log   = mktemp ("tmp$sqm")

# Get positional parameters

   inmos    = mos_name
   dbmos    = mos_info

   if (dbmos == "" || dbmos == " " || substr(dbmos,1,3) == "def")
      dbmos = mos_name//".dbmos"
      
   if (!access(inmos) && !access(inmos//".imh")) {
      print ("Mosaic ",inmos, " not found!")
      goto skip
   }
   if (!access(dbmos)) {
      print ("Mosaic database ",dbmos, " not found!")
      goto skip
   }
   l_list = l_log

   match("\#",dbmos,meta+,stop+,print-) |
      match("nullimage",meta+,stop+,print-,> dbinfo)
   i = strlen (inmos)
   if (substr (inmos, i-3, i) == ".imh")
      mosbase = substr (inmos, 1, i-4)
   else
      mosbase = inmos
 
   list1 = dbinfo
   for (nim = 1; fscan(list1,mospos,src,mos,smedian,soffset) != EOF; nim += 1) { 
      if (oldname) {	# restore old name from database sans section-notation
   # Strip off embedded ".imh"
          pos1e = strlen(src)
          pos1b = stridx("[",src)-1
          if (pos1b > 0) {
             i = pos1b
             if (substr(src,i-3,i) == ".imh")
                sname = substr(src,1,i-4)
             else
                sname = substr(src,1,i)
          } else {
             i = pos1e
             if (substr(src,i-3,i) == ".imh")
                sname = substr(src,1,i-4)
             else
                sname = substr(src,1,i)
          }  
       } else {		# generate name from mosaic base // pathid
          pos1e = strlen(mospos)
          pos1b = stridx("_",mospos)
          sname = mosbase//substr(mospos,pos1b,pos1e)
       }
          imcopy (mos,sname,verbose+)
   }

 
skip:

list1 = ""; l_list = ""
delete (l_log//","//dbinfo, ver-, >& "dev$null")

end
