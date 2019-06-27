#$Header: /home/pros/xray/xdataio/RCS/_errmsg2.cl,v 11.0 1997/11/06 16:35:51 prosb Exp $
#$Log: _errmsg2.cl,v $
#Revision 11.0  1997/11/06 16:35:51  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:56:29  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:42:14  prosb
#General Release 2.3
#
#Revision 1.2  93/12/21  11:01:44  janet
#jd - changed procedure name from errmsg1 to errmsg2.
#
#Revision 1.1  93/12/20  17:34:27  mo
#Initial revision
#
#Revision 1.1  93/12/15  12:01:14  mo
#Initial revision
#
# Module:       errmsg2.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      Convert ROSAT files into PROS format
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC  initial version 10/93
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
procedure errmsg2(filename)
# ======================================================================
  string filename		  {prompt="filename"}
begin
    string msg = ""

        print("Clobber set to 'no' and "//filename//" exists")
end

