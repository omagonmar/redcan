# JCC(9/97)- scripts to do "fits, images or qpoe" conversions for asc data.
#
# convert image to fits for asc using stwfits
#
stwfits ("xspatialdata$asc_hrc.imh",
"asc_hrc.fits", yes, long_header=no, short_header=yes, format_file="default",
log_file="none", bitpix=0, blocking_fac=1, extensions=no, binary_table=no,
gftoxdim=yes, ieee=yes, scale=yes, autoscale=yes, bscale=1., bzero=0.,
dadsfile="null", dadsclas="null", dadsdate="null")
#
# convert fits to image for asc using strfits
#
strfits ("asc_hrc.fits",
" ", "asc_hrc", template="none", long_header=no, short_header=yes,
datatype="default", blank=0., scale=yes, xdimtogf=no, oldirafname=no,
offset=0, force=yes )
#
# convert fits to qpoe for asc using fits2qp
#
fits2qp ("xspatialdata$acis.fits", "acis.qp", naxes=2, axlen1=1024,
axlen2=1024,mpe_ascii_fi=no, clobber=yes, oldqpoename=no, display=1, 
fits_cards="xdataio$fits.cards", qpoe_cards="xdataio$qpoexrcf.cards", 
ext_cards="xdataio$ext.cards", wcs_cards="xdataio$wcsxrcf.cards", 
old_events="EVENTS", std_events="STDEVT", rej_events="REJEVT", 
which_events="old", oldgti_name="GTI", allgti_name="ALLGTI", 
stdgti_name="STDGTI", which_gti="old", scale=yes, key_x="chipx",
key_y="chipy",qp_internals=yes,qp_pagesize=16384,qp_bucketlen=32767,
qp_blockfact=1, qp_mkindex=no, qp_key="", qp_debug=0)
#
# convert fits to qpoe for asc using fits2qp
#
fits2qp ("xspatialdata$hrc.fits", "hrc.qp", naxes=2, axlen1=64, axlen2=64, 
mpe_ascii_fi=no, clobber=yes, oldqpoename=no, display=1, 
fits_cards="xdataio$fits.cards", qpoe_cards="xdataio$qpoexrcf.cards", 
ext_cards="xdataio$ext.cards", wcs_cards="xdataio$wcsxrcf.cards", 
old_events="EVENTS", std_events="STDEVT", rej_events="REJEVT", 
which_events="old", oldgti_name="GTI", allgti_name="ALLGTI", 
stdgti_name="STDGTI", which_gti="old", scale=yes, key_x="crsu",
key_y="crsv",qp_internals=yes,qp_pagesize=16384,qp_bucketlen=32767,
qp_blockfact=1, qp_mkindex=no, qp_key="", qp_debug=0)
