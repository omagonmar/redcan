#$Header: /home/pros/xray/xinstall/RCS/calr_qp2fits.cl,v 11.0 1997/11/06 16:40:57 prosb Exp $
#$Log: calr_qp2fits.cl,v $
#Revision 11.0  1997/11/06 16:40:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:27:10  prosb
#General Release 2.4
#
#Revision 8.3  1995/08/28  14:49:42  prosb
#JCC - Add rparlac_00b.qp back to the script for pros2.4.
#
#Revision 8.2  1995/05/04  15:27:01  prosb
#JCC - comment out the nonexist file "rparlac_00b"
#
#Revision 8.1  1995/05/04  14:16:44  prosb
#JCC - Update with latest TABLES 1.3.3 parameter (STWFITS)
#
#Revision 8.0  94/06/27  17:26:49  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:52:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:45:33  prosb
#General Release 2.2
#
#Revision 5.2  93/05/21  22:23:28  mo
#MC	5/21/93		Update with STWFITS calling sequence 1.2.3
#
#Revision 5.1  93/05/21  20:47:39  mo
#MC	5/21/93		update with Kristin's latest filenames and files
#
#Revision 5.0  92/10/29  22:41:45  prosb
#General Release 2.1
#
#Revision 4.1  92/10/25  17:58:32  mo
#MC	add the PSPC data files
#
#Revision 4.0  92/04/27  15:24:56  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/24  14:12:45  jmoran
#*** empty log message ***
#
#Revision 1.1  92/04/24  09:17:37  jmoran
#Initial revision

#####################################################################
#  In-house procedure to generate FITS versions of CAL files for
#    external release
#
#####################################################################
procedure calr_qp2fits()

begin
	if ( defpac ("xray") )
           print "xray found"
	else
           error (1, "Requires xray to be loaded!")

	if ( defpac ("xdataio") )
           print "xdataio found"
	else
           error (1, "Requires xdataio to be loaded!")

	set in_rcal2 = "/pros/xray/caldata/rosat/"
	print ("Setting in_rcal2 to: " )
	show in_rcal2

	qp2fits("in_rcal2$rharlac_02.qp", "out_rcal$rharlac_02.fits",
           clobber=yes, display=1)

	qp2fits("in_rcal2$rharlac_03.qp", "out_rcal$rharlac_03.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rharlac_06.qp", "out_rcal$rharlac_06.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rharlac_08.qp", "out_rcal$rharlac_08.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rharlac_10.qp", "out_rcal$rharlac_10.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rharlac_11.qp", "out_rcal$rharlac_11.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rharlac_12.qp", "out_rcal$rharlac_12.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rharlac_14.qp", "out_rcal$rharlac_14.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rharlac_16.qp", "out_rcal$rharlac_16.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rharlac_18.qp", "out_rcal$rharlac_18.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_02.qp", "out_rcal$rhhz43_02.fits",
           clobber=yes, display=1)

#        qp2fits("in_rcal2$rhhz43_03.qp", "out_rcal$rhhz43_03.fits",
#           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_04.qp", "out_rcal$rhhz43_04.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_06.qp", "out_rcal$rhhz43_06.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_08.qp", "out_rcal$rhhz43_08.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_10.qp", "out_rcal$rhhz43_10.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_11.qp", "out_rcal$rhhz43_11.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_12.qp", "out_rcal$rhhz43_12.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_15.qp", "out_rcal$rhhz43_15.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_16.qp", "out_rcal$rhhz43_16.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhhz43_18.qp", "out_rcal$rhhz43_18.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_03.qp", "out_rcal$rhlmcx1_03.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_04.qp", "out_rcal$rhlmcx1_04.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_06.qp", "out_rcal$rhlmcx1_06.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_08.qp", "out_rcal$rhlmcx1_08.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_09.qp", "out_rcal$rhlmcx1_09.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_11.qp", "out_rcal$rhlmcx1_11.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_14.qp", "out_rcal$rhlmcx1_14.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_15.qp", "out_rcal$rhlmcx1_15.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_16.qp", "out_rcal$rhlmcx1_16.fits",
           clobber=yes, display=1)

        qp2fits("in_rcal2$rhlmcx1_19.qp", "out_rcal$rhlmcx1_19.fits",
           clobber=yes, display=1)

	qp2fits("in_rcal2$rparlac_00.qp", "out_rcal$rparlac_00.fits",
	   clobber=yes, display=1 )

        qp2fits("in_rcal2$rparlac_00b.qp", "out_rcal$rparlac_00b.fits",
           clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_11.qp", "out_rcal$rparlac_11.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_12.qp", "out_rcal$rparlac_12.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_13.qp", "out_rcal$rparlac_13.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_15.qp", "out_rcal$rparlac_15.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_16.qp", "out_rcal$rparlac_16.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_17.qp", "out_rcal$rparlac_17.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_18.qp", "out_rcal$rparlac_18.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_19.qp", "out_rcal$rparlac_19.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_41.qp", "out_rcal$rparlac_41.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_41b.qp", "out_rcal$rparlac_41b.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_43.qp", "out_rcal$rparlac_43.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_44.qp", "out_rcal$rparlac_44.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_48.qp", "out_rcal$rparlac_48.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_49.qp", "out_rcal$rparlac_49.fits",
	   clobber=yes, display=1 )

	qp2fits("in_rcal2$rparlac_49b.qp", "out_rcal$rparlac_49b.fits",
	   clobber=yes, display=1 )

	stwfits ("in_rcal2$gainmap_pha_al.imh", "out_rcal$gainmap_pha_al.fits",
	newtape=no, bscale=1., bzero=0., long_header=no, short_header=yes,
	format_file="default", log_file="none", bitpix=0, blocking_fac=1, 
	extensions=no, binary_table=no, gftoxdim=no, ieee=yes, scale=yes, 
        autoscale=yes,dadsfile="null", dadsclas="null", dadsdate="null")

	stwfits ("in_rcal2$gainmap_pha_cu.imh", "out_rcal$gainmap_pha_cu.fits",
	newtape=no, bscale=1., bzero=0., long_header=no, short_header=yes,
	format_file="default", log_file="none", bitpix=0, blocking_fac=1, 
	extensions=no, binary_table=no, gftoxdim=no, ieee=yes, scale=yes, 
        autoscale=yes,dadsfile="null", dadsclas="null", dadsdate="null")

	stwfits ("in_rcal2$gainmap_pha_c.imh", "out_rcal$gainmap_pha_c.fits",
	newtape=no, bscale=1., bzero=0., long_header=no, short_header=yes,
	format_file="default", log_file="none", bitpix=0, blocking_fac=1, 
	extensions=no, binary_table=no, gftoxdim=no, ieee=yes, scale=yes, 
        autoscale=yes,dadsfile="null", dadsclas="null", dadsdate="null")

end
