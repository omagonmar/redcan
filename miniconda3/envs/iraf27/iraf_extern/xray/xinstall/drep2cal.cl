#$Header: /home/pros/xray/xinstall/RCS/drep2cal.cl,v 11.0 1997/11/06 16:40:58 prosb Exp $
#$Log: drep2cal.cl,v $
#Revision 11.0  1997/11/06 16:40:58  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:27:12  prosb
#General Release 2.4
#
#Revision 8.2  1995/10/17  15:45:00  prosb
#jcc - remove hri_qegeom.imh. get it from fits2ephem.cl.
#
#Revision 8.1  1995/09/07  17:13:17  prosb
#JCC - Add more data to copy.
#
#Revision 8.0  1994/06/27  17:26:54  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/15  16:08:26  janet
#jd - added 'if access' around ascii file copies.
#
#Revision 7.0  93/12/27  18:52:14  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  18:19:42  mo
#no changes
#
#Revision 6.0  93/05/24  16:45:36  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:41:47  prosb
#General Release 2.1
#
#Revision 4.1  92/10/20  14:01:38  mo
#MC	10/20/92	Correct not.yet.available file to have no '.'s
#
#Revision 4.0  92/04/27  15:24:59  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/26  18:58:14  mo
#no changes
#
#Revision 1.1  92/04/24  09:17:41  jmoran
#Initial revision
#

procedure	drep2cal()


	struct	*list	{mode="h"}
begin


	# Spectral calibration datarep parameters
	#
	##

	file	speclist = "./spectral.list"
	file	specdata = "xspectraldata$/"
	file	specieee = "./"
	file	spectmpl = "./"

	string	fname	= ""
	string	in	= ""
	string	out	= ""
	string	template= ""


	# xray...
	if ( defpac ("xray") )
		print ("xray found")
	else
		error (1, "Requires xray to be loaded!")

	# xdataio...
	if ( defpac ("xdataio") )
		print ("xdataio found")
	else
		error (1, "Requires xdataio to be loaded!")

	print "------- Datarep spectral calibration files ----------------"

	list = speclist
	while ( fscan(list, fname, template) != EOF ) {
		in	= specieee + fname
		out	= specdata + fname
		template= spectmpl + template

		if ( access(in) ) {
	 	   if ( !access(out) ) {
		      print(in, " --> ", out)
		      datarep(in, out, template, "ieee", oformat="host")
	           }
		}
	}
	print ""

# This is a simple ASCII file - let's just copy it in
        in = "spatial_prf_sigmas"
	out = "xspectraldata$spatial_prf_sigmas"
        if ( access (in) )  
           if (!access (out) )
	      copy( in , out)

        in = "hriarea.3.txt"
	out = "xspectraldata$hriarea.3.txt"
        if ( access (in) )  
           if (!access (out) )
	      copy( in , out)

	in = "hriarea.2.txt"
	out = "xspectraldata$hriarea.2.txt"
        if ( access (in) )  
           if (!access (out) )
	      copy( in , out)

	in = "hricoma.txt"
	out = "xspectraldata$hricoma.txt"
	if ( access (in) )
           if (!access (out) )
              copy( in , out)

	in = "not_yet_available"
	out = "xspectraldata$not_yet_available"
	if ( access (in) )
           if (!access (out) )
              copy( in , out)

# JCC - Add more files to copy 
        in = "ccr.cd"
        out = "xspatialdata$ccr.cd"
        if ( access (in) )
           if (!access (out) )
              copy( in , out)

        in = "qpoe.cd"
        out = "xspatialdata$qpoe.cd"
        if ( access (in) )
           if (!access (out) )
              copy( in , out)

        in = "srclst.cd"
        out = "xspatialdata$srclst.cd"
        if ( access (in) )
           if (!access (out) )
              copy( in , out)

        in = "prfeq.lis"
        out = "xspatialdata$prfeq.lis"
        if ( access (in) )
           if (!access (out) )
              copy( in , out)

        in = "prfcoeffs.tab"
        out = "xspatialdata$prfcoeffs.tab"
        if ( access (in) )
           if (!access (out) )
              copy( in , out)

#        in = "hri_qegeom.imh"
#        out = "xspatialdata$hri_qegeom.imh"
#        if ( access (in) )
#           if (!access (out) )
#              imcopy( in , out, verbose=no)

end
