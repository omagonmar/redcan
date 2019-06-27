#$Header: /home/pros/xray/xinstall/RCS/rh_fits2pros.cl,v 11.0 1997/11/06 16:41:04 prosb Exp $
#$Log: rh_fits2pros.cl,v $
#Revision 11.0  1997/11/06 16:41:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:27:23  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:27:19  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/17  18:47:05  wendy
#Pre-Release check-in.
#
#Revision 7.0  93/12/27  18:52:27  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  18:20:50  mo
#MC	12/22/93	Update for RDF
#
#Revision 6.1  93/07/26  18:25:52  dennis
#Updated fits2qp calling sequences for RDF.
#
#Revision 6.0  93/05/24  16:45:52  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:41:58  prosb
#General Release 2.1
#
#Revision 4.2  92/10/16  14:27:29  mo
#MC	10/16/92		Update the FITS2QP script
#
#Revision 4.1  92/06/16  16:57:09  mo
#MC/JMORAN	6/16/92		Add the ORB conversion for the test data
#
#Revision 4.0  92/04/27  15:25:20  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/26  17:33:09  prosb
#MC	Update for new TABLES 1.2 arguments
#
#Revision 1.1  92/04/24  09:18:01  jmoran
#Initial revision
#

#--------------- OLD COMMENTS ------------------------------------------
#MC	8/1/91		Move fits2qp to end in case of errors
#
#MC	7/24/91		Change to use autonameing.  Therefore files
#			will all have rh suffix.  Only problem
#			fits2qp where copy must be done afterwards.
#------------------------------------------------------------------------

procedure rh_fits2pros()

begin

string temp_str
string eph_root = "tempbary_so"
string orb_lst  = "tempbary_orb.lst"

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


# qp_psize and blen are set small as a workaround to a fits2qp
# bug on the vax, these numbers are ok for this data set but 
# causes problems with the data is really large.

_rdfarc2pros("xrayroot$rosfits/rh110267n00","hri",no,
             qp_psize=512, qp_blen=1024)


print("*******************************************************")
print("")
print("  The last 2 warning messages above on the screen        ")
print("         saying missing files                            ")
print("                 rh110267n00_prt.fits                    ")
print("            and  rh110267n00_his.fits                    ")
print("         are     COMPLETELY NORMAL                       ")
print(" (These files were too big and unuseful to burden you with)")
print("")
print("*******************************************************")
end
