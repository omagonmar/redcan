# ZTRACE: 07NOV90 KMM
# ZTRACE  trace association list back to its root

procedure ztrace (infofile,root_num)

file   infofile     {prompt="file produced by ZGET"}
string root_num     {prompt="root number"}

file   outfile      {"", prompt="Output information file name"}
bool   answer       {yes, prompt="Do you want to continue?", mode="q"}
bool   verbose      {yes, prompt="Verbose output?"}
bool   format       {yes, prompt="Format output table"}

struct  *list1, *list2, *list3, *l_list

begin

      int    i,stat,maxnim,undone,prior
      real   zoff, rjunk, roff, delta, refstat 
      bool   firsttime, found, found_zref
      string uniq,sjunk,soffset,sformat,root_id,nim,objnim,refnim,root,srcnim
      file   info,l_log,tmp1,tmp2,newinfo,dofile,donefile

      info        = infofile
      root        = "000" + int(root_num)
      dofile      = mktemp("tmp$ztr")
      donefile    = mktemp("tmp$ztr")
      tmp1        = mktemp("tmp$ztr")
      tmp2        = mktemp("tmp$ztr")
      l_log       = mktemp("tmp$ztr")


    # setup nim process file
      l_list = l_log
   # test for uniqueness of lines
      count(info,>> l_log)
      fields (info,1,lines="",quit-,print-) | sort ("",col=0,num-,rev-) |
         unique () | count(>> l_log)
      stat = fscan(l_list,maxnim)
      stat = fscan(l_list,i)
      if (i < maxnim) {
         i = maxnim - i
         print ("#WARNING: ",i," lines are not unique!")
         goto skip
      }

      root_id = "|"//root
    # cull out lines which are already at root level
      match (root_id,info,meta-,stop-,print-) |
         translit ("","|", " ",delete-,collapse-,> donefile)
      count(donefile,>> l_log); stat = fscan(l_list,i)
      undone = maxnim - i
      
      if (undone <= 0) {		# finished
         sort (donefile,col=0,num-,rev-)
         goto skip
      }

      match (root_id,info,meta-,stop+,print-) |
         translit ("", "|", " ",delete-,collapse-,> dofile)
      prior = 0
      while (undone > 0 && undone != prior) {
         prior = undone
         list1 = dofile
         while (fscan(list1,objnim,refnim,zoff) != EOF) {
            found = no
            list2 = donefile
            for (i = 1; fscan(list2,srcnim,nim,roff) != EOF; i +=1) {
                if (srcnim == refnim) {
                   found = yes
                   break
                }
            }
            if (found) {
               zoff += roff
               print (objnim," ",nim," ",zoff,>> donefile)
               undone -= 1
            } else {
               print (objnim," ",refnim," ",zoff,>> tmp1)
            }
         }
         delete (dofile,ver-, >& "dev$null")
         type (tmp1,>> dofile)
         delete (tmp1,ver-, >& "dev$null")
      }
      sort (donefile,col=0,num-,rev-)

   # Finish up
skip: list1 = ""; list2 = ""; l_list = ""
      delete (l_log//","//tmp1//","//tmp2,ver-,>& "dev$null")
      delete (donefile//","//dofile,ver-,>& "dev$null")
   
   end
