# $Header: /home/pros/xray/xspatial/detect/RCS/lmatchsrc.cl,v 11.0 1997/11/06 16:32:43 prosb Exp $
# $Log: lmatchsrc.cl,v $
# Revision 11.0  1997/11/06 16:32:43  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:21  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:11:49  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:09  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:13:28  prosb
#General Release 2.2
#
#Revision 1.1  93/05/13  11:44:14  janet
#Initial revision
#
# -----------------------------------------------------------------------------
# lmatchsrc - Input a list of _pos.tab files, merge them into 1 file,
#             sort the file in y,x ascending order, and perform a position
#             match.  We compute the distance between 2 pixel positions and
#             say they match if there distance is within our tolerance.
# -----------------------------------------------------------------------------
procedure lmatchsrc (qpoe, itablst, otabroot)

 file qpoe    { prompt="Reference Qpoe file name", mode="a" }
 file itablst { prompt="List of detect tables to match [_pos.tab]", mode="a"}
 file otabroot { prompt="Root name for Match Source table", mode="a" }
 real err_factor{3.0, prompt="Error factor", mode="h"}
 bool overide {no, prompt="Overide use of error from input file?",mode="h"}
 int  display {2, prompt="Display level", mode="h"}
 bool clobber {no, prompt="OK to overwrite existing output file?",mode="h"}

begin

   bool clob
   int  disp

   file iqp
   file itab
   file rname
   file unqname
   file mchname

   iqp   = qpoe
   if ( !access(iqp) ) {
	error (1, "Can't find Qpoe file")
   }

   itab  = itablst
   unqname = otabroot
   mchname = unqname

   # clobber the existing output file if the param is set to yes
   disp = display
   clob  = clobber

   # the unique file is output from tmerge, so we do the clobber check here
   _rtname (iqp, unqname, "_unq.tab")
   unqname = s1

   if ( access(unqname) ) {
      if ( clob ) {
	 del (unqname)
      } else {
	 error (1, "Clobber = NO & Unique table exists!")
      }
   }

   _rtname (iqp, mchname, "_mch.tab")
   mchname = s1

   if ( disp >= 2 ) {
      print ("\n... Merging the list of input tables")
   }
   # merge a list of _pos.tab files
   tmerge (intable=itab, outtable=unqname, option="append", 
           allcols=yes, tbltype="default", allrows=100, extracol=0)

   if ( disp >= 2 ) {
      print ("\n... Sorting the list in y,x order")
   }
   # sort them in y,x order
   tsort (table=unqname, columns="y,x", ascend=yes, casesens=yes)

   if ( disp >= 2 ) {
      print ("\n... Matching the detections into Sources")
   }
   # compute the distance between each source & match sources within tolerance
   _ms(qpoe=iqp, src_list=unqname, matchlist=mchname, err_factor=err_factor, 
       overide=overide, display=display, clobber=clob)

   if ( disp >= 1 ) {
      print ("Writing to Match Reference table: " // unqname )
   }

end

