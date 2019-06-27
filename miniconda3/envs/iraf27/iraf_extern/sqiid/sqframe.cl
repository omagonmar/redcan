# SQFRAME: 14SEP90 KMM
# SQFRAME - produce standard irmosaic

procedure sqframe (first_image, output)

string  first_image  {prompt="First image in sequentially numbered images"}
string  output       {prompt="Output image"}

int     nxsub        {2, prompt="Number of subrasters in x"}
int     nysub        {2, prompt="Number of subrasters in y"}
string  trim_section {"[*,*]",
                       prompt="Input image section written to output image"}
string	corner       {"ll", prompt="Starting corner for the mosaic"}
string  direction    {"row", prompt="Starting direction for the mosaic"}
bool	raster       {no, prompt="Raster scan?"}
bool    median       {no, prompt="Compute the median of each subraster?"}
string  sec_median   {"[*,*]",
                       prompt="Input image section used to compute median"}
bool    subtract     {no, prompt="Substract median from each subraster?"}
real	oval	     {10000., prompt="Mosaic border pixel values"}
bool    imtrans      {no,prompt="Perform imtranspose trans_sec -> [*,*]"}
file    logfile      {"STDOUT", prompt="Log file name"}
file    infofile     {"", prompt="Output information file name"}
bool    save_dbmos   {no, prompt="Save the IRMOSAIC database file?"}

struct	*list1,*l_list
 
begin
       file    tmpimg, tmptmp, tmptran, info, dbmos, l_log, dbinfo
       int     i, nin,stat,pos1b,pos1e,nim, ncols,nrows,nxoverlap,nyoverlap,
               nsubrasters
       string  first, in, inmos, out, mosout, img, trimg, junk, transec,
               uniq, sjunk,src,mos,soffset,mospos,sname,smedian,
               mos_name,mos_section,mos_corner,mos_order,mos_oval
       bool    old_irmosaic

       uniq    = mktemp ("_Tsqm")
       tmpimg  = mktemp ("tmp$sqm")
       tmptran = mktemp ("tmp$sqm")
       dbmos   = mktemp ("tmp$sqm")
       tmptmp  = mktemp ("tmp$sqm")
       dbinfo  = mktemp ("tmp$sqm")
       l_log   = mktemp ("tmp$sqm")

    # Get positional parameters
       first  = first_image
       mosout = output
       mos_name = mosout

    # establish ID of output info file
       if (infofile == "" || infofile == " " || infofile == "default")
          info = mosout//".dbmos"
       else
          info = infofile
       if (info != "STDOUT" && access(info)) {
          print ("Output_file ",info, " already exists!")
          goto skip
       } else
          print ("Output_file= ",info)
 
    # Expand input file name list removing the ".imh" extensions.
       i = strlen(first)
       if (substr(first,i-3,i) == ".imh") first = substr(first,1,i-4)
      
       nsubrasters = nxsub * nysub
       for (nim=1; nim <= nsubrasters; nim += 1) {
          img = first + (nim-1)
   # IMTRANSPOSE
#        hedit (sout,"title",sout,add-,delete-,verify-,show-,update+)
          if (imtrans) {
             trimg = img//"_tr"
             print (trimg,>> tmptran)
# imtranspose [*,-*] rotate 90 counter-clockwise
# imtranspose [-*,*] rotate 90 clockwise
# imcopy      [-*,-*] rotate 180
# imcopy      [-*,*] flip about (vertical) y-axis
# imcopy      [*,-*] flip about (horizontal) x-axis
#        imcopy (img, trimg, verbose-,>> logfile)        
             imcopy(img//"[*,-*]",trimg,ver-)
          } else
             print (img//".imh",>> tmpimg)
       }
       if (imtrans) {
         inmos = "@"//tmptran
       } else {
         inmos = "@"//tmpimg
       }

       l_list = l_log

    # Establish which version of IRMOSAIC is loaded
      
       lparam ("irmosaic",> tmptmp)
       match ("trim_section",tmptmp,meta-,stop-,print-) | count(,>> l_log)
       stat = fscan(l_list,nim)
       if (nim == 0)
          old_irmosaic = yes
       else
          old_irmosaic = no
       delete (tmptmp, ver-, >& "dev$null")
       if (old_irmosaic) {
          irmosaic(inmos,mosout,dbmos,nxsub,nysub,section=trim_section,
             unobs="",corner=corner,direction=direction,raster=raster,
             median=median,subtract=subtract,nxover=0,nyover=0,
             nimcols=INDEF,nimrows=INDEF,oval=oval,opixtype="r",
             verbose+,>> logfile)
       } else {
          irmosaic(inmos,mosout,dbmos,nxsub,nysub,trim_sec=trim_section,
             null_input="",corner=corner,direction=direction,rast=raster,
             median_section=sec_median,subtract=subtract,
	     nxover=0,nyover=0,nimcols=INDEF,nimrows=INDEF,oval=oval,
	     opixtype="r",verbose+,>> logfile)
       }
       time (, >> logfile)
       print ("IRMOSAIC: done", >> logfile)

   # Fetch info from IRMOSAIC database file
   # Subterfuge to dodge INDEF
       delete (tmptmp,verify-,>& "dev$null")
       translit (dbmos,"I","i",delete-,collapse-, > dbinfo)
       delete (l_log, verify-,>& "dev$null"); l_list = l_log
       list1 = dbinfo
   # Pass IRMOSAIC database into MKMOS database
       for (nim = 0;fscan(list1,line) != EOF;nim += 1) {
          stat = fscan(line,sname,sjunk)
          if (sname == "section") {
             print ("#DB     trimsection     ",sjunk, >> info)
             print ("#DB     mediansection   ",sjunk, >> info)
          } else if (sname == "trim_section")
             print ("#DB     section         ",sjunk, >> info)
          else if (sname == "nsubrasters") {
             print ("#DB ", line, >> info)
             break
          } else
             print ("#DB ", line, >> info)
       }
 
       time(,>> l_log); stat = fscan(l_list,line)
       print("#DB  ",line," MKMOS:",>> info)
 
    # log parameters to database file
       print("#DB     mosaic          ",mosout,>> info)
       print("#DB     median_compute  ",median,>> info)
       print("#DB     median_subtract ",subtract,>> info)
       print("#DBT    imtranspose     ",imtrans,>> info)

    # Format for rest of IRMOSAIC database
    # Note: format for IRMOSAIC database neither appends mos_section
    #   nor transfers section from @list to image id
#	orih064[*,*]	mosorihs.imh[1029:1284,1:256]	INDEF INDEF
       for (nim = 1; fscan(list1,src,mos,smedian,soffset) != EOF; nim += 1) { 
   # Strip off embedded ".imh"
          pos1e = strlen(src)
          pos1b = stridx("[",src)-1
          if (pos1b > 0) {
             i = pos1b
             if (substr(src,i-3,i) == ".imh")
                src = substr(src,1,i-4)//substr(src,pos1b+1,pos1e)
          } else {
             i = pos1e
             if (substr(src,i-3,i) == ".imh") src = substr(src,1,i-4)
          }  
   # Strip off embedded ".imh"
          pos1e = strlen(mos)
          pos1b = stridx("[",mos)-1
          if (pos1b > 0) {
             i = pos1b
             if (substr(mos,i-3,i) == ".imh")
                mos = substr(mos,1,i-4)//substr(mos,pos1b+1,pos1e)
          } else {
             i = pos1e
             if (substr(mos,i-3,i) == ".imh") mos = substr(mos,1,i-4)
          }  
          if (old_irmosaic) {
             if (smedian == "iNDEF") {
                smedian = "0.0"
                soffset = smedian
             } else if (subtract)
                soffset = -real(smedian)
             else
                soffset = smedian
          } else {
             if (soffset == "iNDEF") soffset = "0.0"
             if (smedian == "iNDEF") smedian = "0.0"
          }
          mospos = "MOS_000" + nim
          print (mospos," ",src,"  ",mos,"  ",smedian," ",soffset,>> info)
       }

	# Clean up

   skip:

        if (access(tmptran)) {
           imdelete("@"//tmptran,verify-, >& "dev$null")
           delete(tmptran,verify-, >& "dev$null")
        }
	delete (tmpimg//","//tmptmp//","//l_log//","//dbinfo,ver-,>& "dev$null")
        if (!save_dbmos) delete (dbmos, ver-, >& "dev$null")
#        delete (uniq//"*",ver-,>& "dev$null")

end
