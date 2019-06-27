# $Header: /home/pros/xray/xtiming/RCS/ksplot.cl,v 11.0 1997/11/06 16:45:56 prosb Exp $
# $Log: ksplot.cl,v $
# Revision 11.0  1997/11/06 16:45:56  prosb
# General Release 2.5
#
#Revision 9.0  95/11/16  19:32:28  prosb
#General Release 2.4
#
#Revision 8.2  1995/06/09  14:04:10  prosb
#JCC - Updated with new IGI parameters.
#
#Revision 8.0  1994/06/27  17:37:25  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:04:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:54:46  prosb
#General Release 2.2
#
#Revision 1.1  93/05/13  13:52:27  janet
#Initial revision
#
#
# Module:       ksplot.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      ks-test plot macro
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version -- Mar 93
#               {n} <who> -- <does what> -- <when>
# ----------------------------------------------------------------------------
# ksplot - plot the ks-test results using igi
# ----------------------------------------------------------------------------
procedure ksplot (fileroot)

  file fileroot { prompt="Root name for input file(s) [root,_var,_ig1,_ig2.cmd]", mode="a"}
  bool bands    { no, prompt="Plot cdf bands?", mode="h"}
  int  display  { 1, prompt="Display level",mode="h"}


begin

  bool dobands
  bool clobber

  file bndcmds		 # confidence band overlay igi command file
  file kscmds            # ks-test igi command file
  file rname		 # input file rootname 
  file pltname           # output plot table file
  file varname           # output plot table file

  string buf		 # init command buffer 

  rname = fileroot
  dobands = bands

  _rtname (rname, varname, "_var.tab")
  varname = s1

  pltname = "ksp.tmp"
  if ( access ("ksp.tmp") ) {
     delete ("ksp.tmp")
  }
  clobber=yes
  _kspltab (varname, pltname, display=display, clobber=clobber)

  # There are 2 igi command files output from vartst.  
  # (1) <root>_ig1.cmd has the full set of plot commands for the 
  #     Integral and Max diff plot.  
  _rtname (rname, kscmds, "_ig1.cmd")
  kscmds = s1

  buf = "data " // pltname  

#JCC (1/4/96) - The plot is scaled and labelled incorrect when running
#ksplot.cl for more than ONE time. Each time users needs to log out IRAF, 
#then log back in to get a right plot. The solution is to modify 
#append from "yes" to "no" for the first igi.

  igi (initcmd=buf, device="stdgraph", metacode="", append=no, 
       debug=no, cursor="", Version="24Jan94", < kscmds)

  # (2) <root>_ig2.cmd has the overlay plot commands for the 
  #     Confidence bands.  The overlay is optional.
  if ( dobands ) {

     _rtname (rname, bndcmds, "_ig2.cmd")
     bndcmds = s1

     igi (initcmd=buf, device="stdgraph", metacode="", append=yes, 
          debug=no, cursor="", Version="24Jan94", < bndcmds)
  }

  delete ("ksp.tmp")

end
