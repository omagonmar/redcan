#$Header: /home/pros/xray/xinstall/RCS/rp_fits2pros.cl,v 11.0 1997/11/06 16:41:04 prosb Exp $
#$Log: rp_fits2pros.cl,v $
#Revision 11.0  1997/11/06 16:41:04  prosb
#General Release 2.5
#
#Revision 9.1  1997/10/03 21:33:34  prosb
#no change
#
#Revision 9.0  1995/11/16 19:27:25  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:27:24  prosb
#General Release 2.3.1
#
#Revision 7.2  94/06/27  13:32:21  janet
#jd - fixed typo ... errmst1 changed to errmsg1
#
#Revision 7.1  94/06/17  18:46:58  wendy
#Pre-Release check-in.
#
#Revision 7.0  93/12/27  18:52:29  prosb
#General Release 2.3
#
#Revision 6.3  93/12/22  18:20:37  mo
#MC	12/22/93	Update for RDF
#
#Revision 6.2  93/07/26  18:26:10  dennis
#Updated fits2qp calling sequences for RDF.
#
#Revision 6.1  93/07/09  18:29:19  orszak
#jso - added line for the eph file not to have a * going into strfits.
#      the star does not work on the DECStation and VMS.
#
#Revision 6.0  93/05/24  16:45:57  prosb
#General Release 2.2
#
#Revision 5.1  93/05/21  22:22:30  mo
#MC	5/2/093	Update to delete tem*.imh and not *.hhh
#
#Revision 5.0  92/10/29  22:42:00  prosb
#General Release 2.1
#
#Revision 4.2  92/10/16  14:27:47  mo
#MC	10/16/92		Update the FITS2QP calling sequence
#
#Revision 4.1  92/06/16  16:57:55  mo
#MC/JMORAN	6/16/92		Add the ORB file to the test data conversoin
#
#Revision 4.0  92/04/27  15:25:24  prosb
#General Release 2.0:  April 1992
#
#Revision 1.4  92/04/26  19:35:54  prosb
#MC	fix yes in quotes
#
#Revision 1.3  92/04/26  19:03:15  mo
#MC	4/26/92		Fix _mex.pl generation
#
#Revision 1.2  92/04/26  17:33:28  prosb
#MC	Update for new TABLES 1.2 arguments
#
#Revision 1.1  92/04/24  09:18:05  jmoran
#Initial revision
#

#--------------- OLD COMMENTS ----------------------------------------------
#MC	8/1/91		Move fits2qp to end in case of errors
#
#MC	7/24/91		Change back to run from xrayroot$rosfits and
#			put output in xdata$.  Only problem with
#			fit2qp where the copy must be done explicitly
#
#MC	7/24/91		Update to use autonaming - therefore
#			output files now have rp suffix
#			and macro must be run in xdata$
#
#MC	7/22/91		Fix type in trename
#
#MC	7/22/91		Force the spectral output tables to have the CA
#			prefix.  ( Note the src numbers must be 4 and 7 )
#----------------------------------------------------------------------------

procedure rp_fits2pros()

begin


# xray...
if ( defpac ("xray") )
        print "xray found"
else
        error (1, "Requires xray to be loaded!")

# xdataio ...
if ( defpac ("xdataio") )
        print "xdataio found"
else
        error (1, "Requires xdataio to be loaded!")

# stsdas or tables...
if ( defpac ("tables") )
        print "tables found"
else
        error (1, "Requires tables to be loaded!")

copy("xrayroot$rosfits/README","README.rosat")

_rdfarc2pros("xrayroot$rosfits/rp110590n00","pspc",no,
             qp_psize=512, qp_blen=1024)

print("*******************************************************")
print("")
print("  The last 2 warning messages above on the screen	")
print("		saying missing files				")
print("			rp110590n00_prt.fits			")
print("		   and  rp110590n00_his.fits			")
print("		are	COMPLETELY NORMAL			")
print("	(These files were too big and unuseful to burden you with)")
print("")
print("*******************************************************")
end
