#$Header: /home/pros/xray/xdataio/RCS/_errmsg.cl,v 11.0 1997/11/06 16:33:50 prosb Exp $
#$Log: _errmsg.cl,v $
#Revision 11.0  1997/11/06 16:33:50  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:56:25  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:42:09  prosb
#General Release 2.3
#
#Revision 1.1  93/12/15  12:01:14  mo
#Initial revision
#
# Module:       rdffits2pros.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert ROSAT files into PROS format
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC  initial version 10/93
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
procedure errmsg(filename)
# ======================================================================
  string filename		  {prompt="filename"}
begin
    string msg = ""

           msg = "          Missing file "//filename//" -- skipping"
           print("----------------------------------------------------"
           print ( msg )
           print("----------------------------------------------------"
end

