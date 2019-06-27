#$Header: /home/pros/xray/xinstall/RCS/calr_fits2qp.cl,v 11.0 1997/11/06 16:40:56 prosb Exp $
#$Log: calr_fits2qp.cl,v $
#Revision 11.0  1997/11/06 16:40:56  prosb
#General Release 2.5
#
#Revision 9.1  1997/10/03 21:34:37  prosb
#JCC(10/97) - Add force to strfits.
#
#Revision 9.0  1995/11/16 19:27:08  prosb
#General Release 2.4
#
#Revision 8.5  1995/10/17  15:44:19  prosb
#jcc - ci for pros2.4
#
#Revision 8.4  1995/08/28  14:49:02  prosb
#JCC - Add rparlac_00b.fits back to the script for pros2.4.
#
#Revision 8.3  1995/06/19  19:44:02  prosb
#JCC - Comment out rparlac_00b.fits.
#    - Delete the old imh files if there is any, before calling strfits.
#
#Revision 8.2  1995/05/04  18:43:45  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (strfits)
#
#Revision 8.1  1994/10/05  14:24:22  dvs
#Added new fits2qp params.
#
#Revision 8.0  94/06/27  17:26:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:52:08  prosb
#General Release 2.3
#
#Revision 6.1  93/07/26  18:25:06  dennis
#Updated fits2qp calling sequences for RDF.
#
#Revision 6.0  93/05/24  16:45:30  prosb
#General Release 2.2
#
#Revision 5.3  93/05/21  22:24:03  mo
#MC	5/21/93		Update with Kristin's latest filenmes
#
#Revision 5.2  93/05/21  20:46:58  mo
#MC	5/21/93		Update with Kristins's latest filenames and files
#
#Revision 5.1  93/04/01  20:17:36  prosb
#Corrected pspc file names.
#
#Revision 5.0  92/10/29  22:41:42  prosb
#General Release 2.1
#
#Revision 4.1  92/10/23  16:57:51  mo
#add PSPC data
#
#Revision 4.0  92/04/27  15:24:51  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/24  14:59:24  jmoran
#JMORAN added copy statement
#
#Revision 1.1  92/04/24  09:17:28  jmoran
#Initial revision
#

#------------------------------------------------------------------------
# User MUST define the variable "in_rhcal" And in in_rpcal AND be IN 
# the output directory  where the QPOE files are to be written
#------------------------------------------------------------------------
procedure calr_fits2qp()

begin

if ( defpac ("xray") )
   print "xray found"
else
   error (1, "Requires xray to be loaded!")

if ( defpac ("xdataio") )
   print "xdataio found"
else
   error (1, "Requires xdataio to be loaded!")

fits2qp("in_rhcal$rharlac_02.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rharlac_03.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rharlac_06.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rharlac_08.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rharlac_10.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rharlac_11.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rharlac_12.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rharlac_14.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rharlac_16.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rharlac_18.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rhhz43_02.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

#fits2qp("in_rhcal$rhhz43_03.fits", "dummy.qp", mpe_ascii_fits=no,
#   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
#   display=1, fits_cards="xdataio$fits.cards",
#   qpoe_cards="xdataio$qpoe.cards", ext_cards="xdataio$ext.cards",
#   wcs_cards="xdataio$wcs.cards", 
#   old_events="EVENTS", std_events="STDEVT", 
#   rej_events="REJEVT", which_events="old", 
#   oldgti_name="GTI", allgti_name="ALLGTI", 
#   stdgti_name="STDGTI", which_gti="old", 
#   scale=yes, key_x="x", key_y="y",
#   qp_internals=no, qp_pagesize=2048,
#   qp_bucketlen=4096, qp_blockfact=1, qp_mkindex=yes, qp_key="",
#   qp_debug=0)


fits2qp("in_rhcal$rhhz43_04.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhhz43_06.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhhz43_08.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhhz43_10.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rhhz43_11.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhhz43_12.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhhz43_15.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhhz43_16.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhhz43_18.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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



fits2qp("in_rhcal$rhlmcx1_03.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhlmcx1_04.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhlmcx1_06.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhlmcx1_08.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rhcal$rhlmcx1_09.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhlmcx1_11.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhlmcx1_14.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhlmcx1_15.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhlmcx1_16.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


fits2qp("in_rhcal$rhlmcx1_19.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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


if( access("gainmap_pha_al.imh") )
   imdelete ("gainmap_pha_al.imh", yes, verify=no, default_acti=yes)

if( access("gainmap_pha_cu.imh") )
   imdelete ("gainmap_pha_cu.imh", yes, verify=no, default_acti=yes)

if( access("gainmap_pha_c.imh") )
   imdelete ("gainmap_pha_c.imh", yes, verify=no, default_acti=yes)

strfits ("in_rhcal$gainmap_pha_al.fits",
    " ", "dummy_img.imh", template="none", long_header=no, short_header=yes,
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=yes, 
    offset=0, force=yes)

strfits ("in_rhcal$gainmap_pha_cu.fits",
    " ", "dummy_img.imh", template="none", long_header=no, short_header=yes,
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=yes, 
    offset=0, force=yes)

strfits ("in_rhcal$gainmap_pha_c.fits",
    " ", "dummy_img.imh", template="none", long_header=no, short_header=yes,
    datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=yes, 
    offset=0, force=yes)

## copy ("in_rhcal$rhcal.lst", ".")
## copy ("in_rpcal$rpcal.lst", ".")

fits2qp("in_rpcal$rparlac_00.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_00b.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_15.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_44.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_16.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_18.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_49.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_41.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_12.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_11.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_41b.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_49b.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_19.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_17.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_48.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_43.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

fits2qp("in_rpcal$rparlac_13.fits", "dummy.qp", mpe_ascii_fits=no,
   naxes=0, axlen1=0, axlen2=0, clobber=yes, oldqpoename=yes, 
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

end
