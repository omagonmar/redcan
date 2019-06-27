#$Header: /home/pros/xray/xinstall/RCS/cale_fits2qp.cl,v 11.0 1997/11/06 16:40:55 prosb Exp $
#$Log: cale_fits2qp.cl,v $
#Revision 11.0  1997/11/06 16:40:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:27:06  prosb
#General Release 2.4
#
#Revision 8.1  1994/10/05  14:24:13  dvs
#Added new fits2qp params.
#
#Revision 8.0  94/06/27  17:26:42  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:52:05  prosb
#General Release 2.3
#
#Revision 6.1  93/07/26  18:24:40  dennis
#Updated fits2qp calling sequences for RDF.
#
#Revision 6.0  93/05/24  16:45:27  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:41:40  prosb
#General Release 2.1
#
#Revision 4.1  92/10/23  16:57:34  mo
#MC	fix FITS2QP calling sequence
#
#Revision 4.0  92/04/27  15:24:47  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/24  14:59:03  jmoran
#JMORAN added copy statement
#
#Revision 1.1  92/04/24  09:17:12  jmoran
#Initial revision
#

#------------------------------------------------------------------------
# User MUST define the variable "in_ecal" AND be IN the output directory
# where the QPOE files are to be written
#------------------------------------------------------------------------
procedure cale_fits2qp()

begin

if ( defpac ("xray") )
   print "xray found"
else
   error (1, "Requires xray to be loaded!")

if ( defpac ("xdataio") )
   print "xdataio found"
else
   error (1, "Requires xdataio to be loaded!")


fits2qp("in_ecal$h1039l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y",
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)

fits2qp("in_ecal$h10651l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old", 
   scale=yes, key_x="x", key_y="y",
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)

fits2qp("in_ecal$h1071l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old", 
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)

fits2qp("in_ecal$h1alum.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old", 
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)

fits2qp("in_ecal$h1boron.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)

fits2qp("in_ecal$h1carb.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h1copp.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h1crom.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old", 
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h1iron.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h1silv.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h1zirc.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h4390l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h4532l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h4996l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h648l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h649l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h6564l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h657l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h711l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$h936l.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$ipc_ag.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$ipc_al.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$ipc_al_hv6.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)


fits2qp("in_ecal$ipc_c.fits", ".", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=no, 
   display=1, fits_cards="xdataio$fits.cards",
   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
   wcs_cards="xdataio$wcs.cards", 
   old_events="EVENTS", std_events="STDEVT", 
   rej_events="REJEVT", which_events="old", 
   oldgti_name="GTI", allgti_name="ALLGTI", 
   stdgti_name="STDGTI", which_gti="old",
   scale=yes, key_x="x", key_y="y", 
   qp_internals=no, qp_pagesize=2048,
   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
   qp_debug=0)

copy ("in_ecal$README.HRI", ".")

end
