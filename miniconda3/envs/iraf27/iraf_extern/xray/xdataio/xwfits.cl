# $Header: /home/pros/xray/xdataio/RCS/xwfits.cl,v 11.0 1997/11/06 16:37:50 prosb Exp $
# $Log: xwfits.cl,v $
# Revision 11.0  1997/11/06 16:37:50  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:57:24  prosb
# General Release 2.4
#
#Revision 8.1  1995/05/04  14:05:46  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (STWFITS)
#
#Revision 8.0  94/06/27  15:18:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:44:23  prosb
#General Release 2.3
#
#Revision 6.1  93/12/15  12:02:06  mo
#MC	12/15/93		Update with latest TABLES parameter
#
#Revision 6.0  93/05/24  16:23:03  prosb
#General Release 2.2
#
#Revision 1.1  93/05/21  18:41:34  mo
#Initial revision
#
#
# Module:       XWFITS
# Project:      PROS -- ROSAT RSDC
# Purpose:      Utility to run TABLES/STWFITS for XRAY data
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
 
procedure xwfits(infile,fitsfile)

 string infile   {prompt="input filename",mode="a"}
 string fitsfile {prompt="output fits filename",mode="a"}
 bool   bin      {yes,prompt="Binary FITS tables?",mode="a"}
 bool   newtape  {no,prompt="Blank tape?",mode="h"}
 real	bscale   {1.0,prompt="FITS bscale value",mode="h"}
 real	bzero    {0.0,prompt="FITS bzero value",mode="h"}
 bool   mkimg    {yes,prompt="Create a FITS image?",mode="h"}
 bool	long     {no,prompt="Print FITS header cards?",mode="h"}
 bool	short    {yes,prompt="Print short header?",mode="h"}
 string fileform {"default",prompt="format filename",mode="h"}
 string log      {"none",prompt="log filename",mode="h"}
 int    bit      {0,prompt="IRAF data type",mode="h"}
 int    bl       {1,min=1,max=10,prompt="FITS tape blocking factor",mode="h"}
 bool   ext      {no,prompt="Allow tables in the same file?",mode="h"}
#bool   prec     {yes,prompt="Full binary precision?",mode="h"}
 bool   st       {yes, prompt="Special ST multigroup format?",mode="h"}
 bool   ieee     {yes, prompt="convert to IEEE standard?",mode="h"}
#bool   fmin     {no, prompt="Force image min/max to be recomputed?",mode="h"}
 bool   scale    {yes, prompt="Scale image data?",mode="h"}
 bool   auto     {yes, prompt="Auto-scale image data?",mode="h"}


begin

##j stwfits (infile, fitsfile, newtape, bscale, bzero, long_header=long, 
##j short_header=short, format_file=fileform, log_file=log, bitpix=bit, 
##j blocking_fac=bl, extensions=ext, def_tab_prec=prec, binary_table=bin, 
##j gftoxdim=st, ieee=ieee, force_minmax=fmin, scale=scale, autoscale=auto)

stwfits (infile, fitsfile, newtape=newtape, bscale=bscale, bzero=bzero, 
long_header=long, short_header=short, format_file=fileform, log_file=log, 
bitpix=bit, blocking_fac=bl, extensions=ext, binary_table=bin, 
gftoxdim=st, ieee=ieee, scale=scale, autoscale=auto,
dadsfile="null", dadsclas="null", dadsdate="null")

end
