#$Header: /home/pros/xray/lib/pros/RCS/fnames.x,v 11.0 1997/11/06 16:20:28 prosb Exp $
#$Log: fnames.x,v $
#Revision 11.0  1997/11/06 16:20:28  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:39  prosb
#General Release 2.4
#
#Revision 8.1  1994/07/18  12:35:41  janet
#jd - added ext_obi & ext_eph.
#
#Revision 8.0  94/06/27  13:46:04  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/23  13:30:08  prosb
#Added three extensions.
#
#Revision 7.0  93/12/27  18:09:33  prosb
#General Release 2.3
#
#Revision 6.6  93/12/22  17:13:46  mo
#MC	update some RDF extensions
#
#Revision 6.5  93/11/03  11:14:21  mo
#MC	11/2/93		Add 'mdl' extension for IMMODEL
#
#Revision 6.4  93/10/20  16:54:10  mo
#MC 10/20/93		Aadd routine, ck_comma, to rplace commas with blanks
#
#Revision 6.3  93/09/02  18:10:06  dennis
#Changed EXT_OAH and EXT_BOA to EXT_SOH and EXT_BOH, respectively, 
#to show their parallelism.
#
#Revision 6.2  93/08/23  19:11:38  dennis
#Changed extension for fit's chi-square table file from EXT_CHI to EXT_CSQ,
#to avoid naming collision with period's EXT_CHI file.
#Also created new extensions EXT_OAH, EXT_BOA, EXT_BAL in preparation for
#xspectral's use of RDF.
#
#Revision 6.1  93/07/02  14:11:28  mo
#MC	7/2/93		Correct the data type of 'ck_ival'
#
#Revision 6.0  93/05/24  15:44:42  prosb
#General Release 2.2
#
#Revision 5.2  93/05/19  17:01:48  mo
#MC/Jd	5/20/93		Add filename extenstions for MATCH and CALC_BARY.
#
#
#Revision 5.1  93/05/07  15:39:14  janet
#added ext_var, ks-test output file root.
#
#Revision 5.0  92/10/29  21:16:44  prosb
#General Release 2.1
#
#Revision 4.4  92/10/08  09:18:50  mo
#MC	10/8/92		Changed the TBTACC to ACCESS since TBTACC now
#			requires a valid table and we need to delete
#			any file with the specified name.
#
#Revision 4.3  92/08/27  14:03:19  mo
#MC	8/27/92		Remove extraneous ip=1 line from ck_ival
#
#Revision 4.2  92/08/27  11:22:04  mo
#MC	8/27/92		Add 2 new routines, ck_dval and ck_ival
#			Also restore support for filenames beginning with
#			digits.
#
#Revision 4.1  92/08/10  16:30:14  mo
#MC	8/10/92		Add auto-removal of leading white space in filenames
#			and cause leading digits to be a fatal error in
#			filenames.
#
#Revision 4.0  92/06/26  14:32:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/06/17  10:44:34  mo
#MC	6/16/92		update indexing to use ii and not i
#
#Revision 3.2  92/02/28  16:35:55  prosb
#jso - put in an updated abbrev that will deal with nulls better
#
#Revision 3.1  92/02/13  10:10:15  janet
#added extensions for detect (POS,SNR) and isoreg (ISO).
#
#Revision 3.0  91/08/02  01:00:43  wendy
#General
#
#Revision 2.0  91/03/07  00:06:57  pros
#General Release 1.0
#
#
# FNAMES.X -- routines to deal with related files
#

include <ctype.h>
include <ext.h>

define	FNAME_FATAL	1
define	IS_DIGDOT	(($1>='0'&&$1<='9')||$1=='.')

#
# ROOTNAME -- get a file name, possibly using the root of another file
#		if using the root (or it no extension is given), use
#		the specified extension
#
procedure rootname(root, fname, ext, len)

char	root[ARB]			# i: image name
char	fname[ARB]			# o: output name
char	ext[ARB]			# i: extension
int	len				# i: length of output name

char	tdir[SZ_PATHNAME]		# l: temp directory
char	tfname[SZ_FNAME]		# l: temp name
char	text[SZ_FNAME]			# l: temp extension
int	tf				# l: number of chars in filename
int	td				# l: number of chars in directory
int	te				# l: number of chars in extension
int	index				# l: temp index for stridx
# imparse arguments
char	cluster[SZ_FNAME]		# l: cluster
char	ksection[SZ_FNAME]		# l: ksection
char	section[SZ_FNAME]		# l: section
int	cl_index			# l: default =0
int	cl_size				# l: default =0
bool	streq()				# l: string compare
int	ii				# l: index counter
int	stridx()			# l: index into string
int	abbrev()			# l: check for abbrev
int	fnldir()			# l: get directory
int	fnroot()			# l: get root file
int	fnextn()			# l: get extension

begin
	# allow the fname to default to the root name
	# Strip out leading white space and check for leading 'digits'
	ii=1
	while( IS_WHITE(root[ii]) ){
		ii=ii+1
	}
	call strcpy(root[ii],root,SZ_PATHNAME)
	ii=1
	while( IS_WHITE(fname[ii]) ){
		ii=ii+1
	}
	call strcpy(fname[ii],fname,SZ_PATHNAME)
	if( streq(fname, "") ){
	    # just return if rootname is null
	    if( streq(root, "") )
		return
	    # copy the root name
	    call strcpy(root, fname, len)
	    # remove the bracket notation, if necessary
	    index = stridx("[", fname)
	    if( index !=0 )
		fname[index] = EOS
	    # and change extension
	    call chngextname(fname, ext, len)
	}
	# check for "NONE"
	else{
	    # make a copy
	    call strcpy(fname, tfname, SZ_FNAME)
	    # convert to upper case
	    call strupr(tfname)
	    # if "NONE", return
	    if( abbrev("NONE", tfname) >0 ){
		call strcpy("NONE", fname, len)
		return
	    }
	    # the input might be a file or just a directory prefix
	    else{
		# if just ".", use root file name, but with new extension
		# and without section and ksection info from root
		if( streq(".", fname) ){
		    call strcpy("./", tdir, SZ_PATHNAME)
		    call imparse (root, cluster, SZ_FNAME, ksection, SZ_FNAME,
				  section, SZ_FNAME, cl_index, cl_size)
		    tf = fnroot(cluster, tfname, SZ_PATHNAME)
		    call chngextname(tfname, ext, SZ_PATHNAME)
		}
		# if just "..", use root file name, but with new extension
		# and without section and ksection info from root
		else if( streq("..", fname) ){
		    call strcpy("../", tdir, SZ_PATHNAME)
		    call imparse (root, cluster, SZ_FNAME, ksection, SZ_FNAME,
				  section, SZ_FNAME, cl_index, cl_size)
		    tf = fnroot(cluster, tfname, SZ_PATHNAME)
		    call chngextname(tfname, ext, SZ_PATHNAME)
		}
		# use fname file name if there is one, else use root file name
		else{
		    call imparse (fname, cluster, SZ_FNAME, ksection, SZ_FNAME,
				  section, SZ_FNAME, cl_index, cl_size)
		    # take directory from fname
		    td = fnldir(cluster, tdir, SZ_PATHNAME)
		    # take root from fname
		    tf = fnroot(cluster, tfname, SZ_PATHNAME)
		    # if there was no root
		    if( tf ==0 ){
			# take root from root, but with new extension
			# and without section and ksection info from root
			call imparse (root, cluster, SZ_FNAME,
					ksection, SZ_FNAME,
				  	section, SZ_FNAME, cl_index, cl_size)
			tf = fnroot(cluster, tfname, SZ_PATHNAME)
			call chngextname(tfname, ext, SZ_PATHNAME)
		    }
		    else{
			# otherwise add fname's extension
			te = fnextn(cluster, text, SZ_FNAME)
			if( te !=0 ){
			    call strcat(".", tfname, SZ_PATHNAME)
			    call strcat(text, tfname, SZ_PATHNAME)
			}
			else
			    call addextname(tfname, ext, len)
			# add fname's section and ksection info
			call strcat(ksection, tfname, SZ_PATHNAME)
			call strcat(section, tfname, SZ_PATHNAME)
		    }
		}
		# create the file name from dir and file
		call strcpy(tdir, fname, len)
#       		if( IS_DIGIT(fname[1]) ){
#	            call errstr(FNAME_FATAL,"Leading digits illegal in filenames",fname)
#	        }
		call strcat(tfname, fname, len)
	    }
	}
end

#
# CLOBBERNAME - see if file exists and if it can be clobbered
#		make a temp name if necessary
#
procedure clobbername(name, temp, clobber, len)

char	name[ARB]			# i: original name
char	temp[ARB]			# o: new (temp) name
bool	clobber				# i: clobber existing file
int	len				# i: length of output name

char	root[SZ_LINE]			# l: temp root for mktemp
int	ftype				# l: type of file
int	fexist				# l: flag that file exists
int	index				# l: index for "."
int	access()			# l: file existence routines:
int	imaccess()			# l: image file existence
int	qpaccess()			# l: qpoe file existence
#int	tbtacc()			# l: table file existence
int	fnldir()			# l: get logical directory
int	strldx()			# l: last index into string
int	fn_getexttype()			# l: get file type

begin
	# get file type, based on extension
	ftype = fn_getexttype(name)
	# see if file exists
	switch( ftype ){
	case TY_IM:
	    fexist = imaccess(name, 0)
	case TY_QPOE:
	    fexist = qpaccess(name, 0)
	case TY_TAB:
	    fexist = access(name, 0, 0)
#	    fexist = tbtacc(name)
	case TY_PL:
	    fexist = access(name, 0, 0)
	default:
	    fexist = access(name, 0, 0)
	}
	if( fexist == YES ){
	    # if so, can it be clobbered
	    if( clobber ){
		# see if there is a pathname on the input name
		index = fnldir(name, root, SZ_LINE)
		# if not, use current directory
		if( index ==0 )
		    call strcpy("./", root, SZ_LINE)
		# cat the filename part onto the root
		call strcat("temp", root, SZ_LINE)
		# make a temp in the imdir directory or specified path
		call tempname(root, temp, len)
		# add the simple extension - good enough for the temp
		index = strldx(".", name)
		# check to make sure its not part of a directory path
		if( (index !=0) && (IS_ALNUM(name[index+1])) )
		    call addextname(temp, name[index], len)
	    }
	    # oops!
	    else
        	call errstr(1, "can't clobber existing file", name)
	}
	# if no existing file, make the temp name same as the original
	else
	    call strcpy(name, temp, len)
end

#
# FINALNAME -- rename temp file to output file, if necessary
#
procedure finalname(temp, name)

char	temp				# i: temp name
char	name[ARB]			# o: final name

int	ftype				# l: type of file
bool	strne()				# l: string compare
int	fn_getexttype()			# l: get file type

begin
	# rename the file, if necessary
	if( strne(name, temp) ){
	    # get file type, based on extension
	    ftype = fn_getexttype(name)
	    # do the right thing
	    switch(ftype){
	    case TY_IM:
		iferr( call imdelete(name) )
		    goto 98
		iferr( call imrename(temp, name) )
		    goto 99
	    case TY_QPOE:
		iferr( call qpdelete(name) )
		    goto 98
		iferr( call qprename(temp, name) )
		    goto 99
	    case TY_TAB:
		iferr( call tbtdel(name) )
		    goto 98
		iferr( call tbtren(temp, name) )
		    goto 99
	    case TY_PL:
		iferr( call delete(name) )
		    goto 98
		iferr( call rename(temp, name) )
		    goto 99
	    default:
		iferr( call delete(name) )
		    goto 98
		iferr( call rename(temp, name) )
		    goto 99
	    }
	}
	# everything is okey smokey
	return

	# can't delete old file
98	call printf("can't delete old file; new file stored in %s\n")
	call pargstr(temp)
	return

	# can't rename new file
99	call printf("can't rename new file from %s\n")
	call pargstr(temp)
	return
end

#
# CHNGEXTNAME -- change the extension of a name
#
procedure chngextname(name, ext, len)

char	name[ARB]			# i: name with desired extension
char	ext[ARB]			# i: extension to change to
int	len				# i: length of output name

int	index				# l: temp index for fn_fullextname()
int	fn_fullextname()		# l: look for extension

begin
	# if no new extension is given, leave the old one alone
	if( ext[1] == EOS )
	    return
	# see if there is an old extension, but don't bother completing
	# a partial extension
	index = fn_fullextname(name, len, FALSE)
	# if so, strip it off
	if( index !=0 )
	    name[index] = EOS
	# and copy in the new extension
	call strcat(ext, name, len)
#   	if( IS_DIGIT(name[1]) ){
#	  call errstr(FNAME_FATAL,"Leading digits illegal in filenames",name)
#	}
end

#
# ADDEXTNAME -- add an extension to a name, if none exists
#		this will also complete a partial extension
#
procedure addextname(name, ext, len)

char	name[ARB]			# i/o: file name
char	ext[ARB]			# i: extension
int	len				# i: length of output

int	index				# l: temp index for full ext
int	fn_fullextname()		# l: look for extension
pointer	temp				# l: temp buffer
pointer	sp				# l: stack pointer
int	stridx()			# l: string index

begin
	# mark the stack
	call smark(sp)
	# allocate a temp buffer
	call salloc(temp, len, TY_CHAR)
	# flag no extension
	Memc[temp] = EOS
	# look for an extension, and complete it if necessary
	index = fn_fullextname(name, len, TRUE)
	# if there was no extension, add one
	# but make sure its put before a [...]
	if( index ==0 ){
	    # look for "["
	    index = stridx("[", name)
	    if( index !=0 ){
		# save the bracket
		call strcpy(name[index], Memc[temp], len)
		# remove the bracket
		name[index] = EOS
	    }
	    # concat the extension
	    call strcat(ext, name, len)
	    # restore the bracket, if necessary
	    if( Memc[temp] != EOS )
		call strcat(Memc[temp], name, len)
	}
	# free up space
#   	if( IS_DIGIT(name[1]) ){
#	  call errstr(FNAME_FATAL,"Leading digits illegal in filenames",name)
#	}
	call sfree(sp)
end

#
# FN_FULLEXTNAME -- check for an extension; complete partial one if necessary
#	return index of extension or 0
#
# NB: THERE MUST BE AN ENTRY HERE FOR EACH COMPOUND EXTENSION DEFINED IN EXT.H
#  
#
int procedure fn_fullextname(name, len, cflag)

char	name[ARB]			# i: file name
int	len				# i: length of output
int	cflag				# i: complete flag

int	dindex				# l: index for "."
int	uindex				# l: index for "_"
int	strldx()			# l: last index into string
bool	streq()				# l: string compare
bool	fn_fillext()			# l: look for abbrev extension

begin
	# look for two parts of extension
	uindex = strldx("_", name)
	dindex = strldx(".", name)
	# make sure its not part of a directory path
	if( dindex !=0 )
	    if( !IS_ALNUM(name[dindex+1]) )
		dindex = 0
	# check for no extension
	if( (uindex ==0) && (dindex ==0) )
	    return(0)
	# check for simple index: with no "_"
	else if( uindex==0 )
	    return(dindex)
	# check for partial extension: with no "."
	# we may have to complete this!
	else if( dindex ==0 ){
	    # check each compound extension
	    if( fn_fillext(name[uindex], EXT_BKGD, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_ERROR, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_MDL, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_SMOOTH, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_SNR, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_EXPOSURE, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_ISO, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_VIGNETTING, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_BAR, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_BTI, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_STI, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_BAL, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_BKFAC, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_BOH, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_CAT, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_CHI, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_CNTS, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_COR, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_CSQ, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_EPH, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_EPHEM, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_FFT, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_FLD, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_FTP, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_GRD, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_IMDISP, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_INT, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_LTC, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_MCH, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_OBS, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_POS, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_PRD, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_PROJ, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_PWR, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_QPDISP, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_REG, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_RUF, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_SOH, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_SOURCE, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_UNQ, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_UTC, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_VAR, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_ANG, len, cflag) )
	        return(uindex)
	    else if( fn_fillext(name[uindex], EXT_OBI, len, cflag) )
	        return(uindex)
	    else
	    # the "_" was not part of a compound extension
	        return(0)
	}
	# check for full compound extension: with both "_" and "."
	else{
		# check each compound extension
		if( streq(name[uindex], EXT_BKGD) )
		    return(uindex)
		else if( streq(name[uindex], EXT_ERROR) )
		    return(uindex)
		else if( streq(name[uindex], EXT_MDL) )
		    return(uindex)
		else if( streq(name[uindex], EXT_SMOOTH) )
		    return(uindex)
		else if( streq(name[uindex], EXT_SNR) )
		    return(uindex)
		else if( streq(name[uindex], EXT_EXPOSURE) )
		    return(uindex)
		else if( streq(name[uindex], EXT_ISO) )
		    return(uindex)
		else if( streq(name[uindex], EXT_VIGNETTING) )
		    return(uindex)
		else if( streq(name[uindex], EXT_BAR) )
		    return(uindex)
		else if( streq(name[uindex], EXT_BTI) )
		    return(uindex)
		else if( streq(name[uindex], EXT_STI) )
		    return(uindex)
		else if( streq(name[uindex], EXT_BAL) )
		    return(uindex)
		else if( streq(name[uindex], EXT_BKFAC) )
		    return(uindex)
		else if( streq(name[uindex], EXT_BOH) )
		    return(uindex)
		else if( streq(name[uindex], EXT_CAT) )
		    return(uindex)
		else if( streq(name[uindex], EXT_CHI) )
		    return(uindex)
		else if( streq(name[uindex], EXT_CNTS) )
		    return(uindex)
		else if( streq(name[uindex], EXT_COR) )
		    return(uindex)
		else if( streq(name[uindex], EXT_CSQ) )
		    return(uindex)
		else if( streq(name[uindex], EXT_EPH) )
		    return(uindex)
		else if( streq(name[uindex], EXT_EPHEM) )
		    return(uindex)
		else if( streq(name[uindex], EXT_FFT) )
		    return(uindex)
		else if( streq(name[uindex], EXT_FLD) )
		    return(uindex)
		else if( streq(name[uindex], EXT_FTP) )
		    return(uindex)
		else if( streq(name[uindex], EXT_GRD) )
		    return(uindex)
		else if( streq(name[uindex], EXT_IMDISP) )
		    return(uindex)
		else if( streq(name[uindex], EXT_INT) )
		    return(uindex)
		else if( streq(name[uindex], EXT_LTC) )
		    return(uindex)
		else if( streq(name[uindex], EXT_MCH) )
		    return(uindex)
		else if( streq(name[uindex], EXT_OBS) )
		    return(uindex)
		else if( streq(name[uindex], EXT_POS) )
		    return(uindex)
		else if( streq(name[uindex], EXT_PRD) )
		    return(uindex)
		else if( streq(name[uindex], EXT_PROJ) )
		    return(uindex)
		else if( streq(name[uindex], EXT_PWR) )
		    return(uindex)
		else if( streq(name[uindex], EXT_QPDISP) )
		    return(uindex)
		else if( streq(name[uindex], EXT_REG) )
		    return(uindex)
		else if( streq(name[uindex], EXT_RUF) )
		    return(uindex)
		else if( streq(name[uindex], EXT_SOH) )
		    return(uindex)
		else if( streq(name[uindex], EXT_SOURCE) )
		    return(uindex)
		else if( streq(name[uindex], EXT_UNQ) )
		    return(uindex)
		else if( streq(name[uindex], EXT_UTC) )
		    return(uindex)
		else if( streq(name[uindex], EXT_VAR) )
		    return(uindex)
		else if( streq(name[uindex], EXT_ANG) )
		    return(uindex)
		else if( streq(name[uindex], EXT_OBI) )
		    return(uindex)
		else
		# we have a normal occurrance of "_" and a simple extension
		    return(dindex)
	}
end


#  FN_FILLEXT -- see if a name is a part of a compound  extension
#		 and complete the extension if necessary
#
bool procedure fn_fillext(name, ext, len, cflag)

char	name[ARB]			# i: file name
char	ext[ARB]			# i: extension
int	len				# i: length of output
int	cflag				# i: complete flag

int	nchar				# l: next char after match
char	temp[SZ_FNAME]			# l: local pattern match string
int	strmatch()			# l: general string match

begin
	# anchor the extension to the beginning, make sure a "." comes after
	call sprintf(temp, SZ_FNAME, "^%s.")
	call pargstr(name)
	# see if the pattern matches
	nchar = strmatch(ext, temp)
	if( nchar ==0 )
	    return(FALSE)
	else{
	    # complete extension starting at ".", if necessary
	    if( cflag == YES )
		call strcat(ext[nchar-1], name, len)
	    return(TRUE)
	}
end

#
#  FN_GETEXTTYPE -- get the file type of a file, based on the extension
#	we only check the simple extension types, since we assume it
#	has already been added by a call to rootname
#
# NB: THERE MUST BE AN ENTRY HERE FOR EACH SIMPLE EXTENSION DEFINED IN EXT.H
#  
int procedure fn_getexttype(name)

char	name[ARB]			# i: file name
char	ext[SZ_FNAME]			# l: extension
int	index				# index where "." is found
bool	streq()				# l: string compare
int	strldx()			# l: last index into string

begin
	    # look for an extension
	    index = strldx(".", name)
	    if( (index !=0) && (IS_ALNUM(name[index+1])) )
		call strcpy(name[index], ext, SZ_FNAME)
	    else
		# no extension defaults to .imh type
		return(TY_IM)
	    # convert extension to lower case
	    call strlwr(ext)
	    # see if we match a known simple extension
	    if( streq( ext, EXT_IMG ) )
		return(TY_IM)
	    else if( streq( ext, EXT_PL ) )
		return(TY_PL)
	    else if( streq( ext, EXT_QPOE ) )
		return(TY_QPOE)
	    else if( streq( ext, EXT_STIMG ) )
		return(TY_IM)
	    else if( streq( ext, EXT_TABLE ) )
		return(TY_TAB)
	    else
		return(TY_DEF)
end

#
# ABBREV -- look for a pattern match of a string from the beginning
# of another string, i.e., is one string an abbrev of another?
#
# NB: returns the first string that matches
#

int procedure abbrev(s, t)

char	s[ARB]			# i: mother string in which we are
char	t[ARB]			# i: trying to match this string

int	ii			# l: string offset

int	strlen()

begin

	# if both the strings are nulls we return an exact match
	if ( strlen(s) == 0 && strlen(t) == 0 ) {
	    return (2)
	}

	ii = 1
	# look for an (abbreviated) match
	# we go through at least once so that t=NULL will not
	# be a match
	while ( t[ii] != EOS || ii == 1 ) {
	    if ( s[ii] != t[ii] ) {
		return(0)
	    }
	    ii = ii+1
	}
	# check for exact match
	if ( s[ii] == EOS ) {
	    return(2)
	}
	# otherwise its an abbreviation
	else {
	    return(1)
	}

end

# this is taken from oif.h and is the default if imdir is not defined
define	HDR		"HDR$"		# stands for header directory

#
#  TEMPNAME -- make a temporary name
#	we take into account possible directory pathname on the root
#	if there is none, we add the imdir name
#
procedure tempname(root, temp, len)

char	root[ARB]			# i: root for temp name
char	temp[ARB]			# o: new (temp) name
int	len				# i: length of output name

char	temp1[SZ_FNAME]			# l: temp name
int	index				# l: temp index for strldx
int	envgets()			# l: get environment string
int	fnldir()			# l: get directory from vfn

begin
	# see if there is a pathname on the root
	index = fnldir(root, temp, len)
	if( index !=0 )
	    ;
	else if(envgets ("imdir", temp, len) <= 0)
	    # otherwise use a default
	    call strcpy (HDR, temp, len)
	# make a temp file name
	call mktemp(root[index+1], temp1, len)
	# cat the fname to the directory
	call strcat(temp1, temp, len)
end

#
# OUTNAME -- get an output file name, possibly using the root of another file
#		if using the root (or it no extension is given), use
#		the specified extension
# this is just like rootname, except that we always change the extension
# (unless the name is "NONE")
#
procedure outname(root, fname, ext, len)

char	root[ARB]			# i: image name
char	fname[ARB]			# o: output name
char	ext[ARB]			# i: extension
int	len				# i: length of output name
bool	strne()				# l: string compare

begin
	# complete the fname from the root, if necessary
	call rootname(root, fname, ext, len)
	# change the extension, if necessary
	if( strne("NONE", fname) )
	    call chngextname(fname, ext, len)
end


#
# CK_NONE -- Check that the string ( filename ) specifies none
#		in any abbreviaion or any combination of upper,lower case.
#
bool procedure ck_none(name)
char	name[ARB]		# i: pointer to input/output string

pointer	sp			# l:	stack pointer
pointer	tname			# l:    pointer to temporary name
bool	none			# o:    does string match NONE?

int	abbrev()

begin
    # check for "NONE"
    call smark(sp)
    # make a copy
    call salloc( tname, SZ_PATHNAME, TY_CHAR)
    call strcpy( name, Memc[tname], SZ_PATHNAME)
    # convert to upper case
    call strupr(Memc[tname])
    # if "NONE", return
    if( abbrev("NONE", Memc[tname]) >0 ){
	call strcpy("NONE", name, SZ_PATHNAME)
        none=TRUE
    }
    else
	none=FALSE
    call sfree(sp)
    return(none)
end

#
# CK_EMPTY -- Check that the string ( filename ) specifies an 
#		empty string, where blanks will be accepted as well
#
bool procedure ck_empty(name)
char	name[ARB]		# i/o: pointer to input/output string

bool	empty			# o:    does string match empty?
bool	streq()

begin
    # check for empty
    if( streq(name,"") || streq(name," ") || streq(name,"  ") ){
	call strcpy("", name, SZ_PATHNAME)
        empty=TRUE
    }
    else
	empty=FALSE
    return(empty)
end

#
#  Routine to check for a double precision value or filename
#	Returns   FALSE if a filename
#		  TRUE if a floating value

bool procedure ck_dval(strval,ip,value)
char	strval[ARB]		# i: input string - with filename or float value
int	ip			# i/o: current index in string
bool	flval			# o:    does string contain float?
double	value			# o:  converted value

int	nchar			# l:  pointer to last digit
int	lip			# l: local pointer to end of value string
int	ctod()

begin
        nchar = ctod(strval, ip, value)
        #  Note that "." will be recognised by ctod as a number, but we
        #    know it's a filename - so explicitly check for a digit and not
        #    a decimal point (This means that values CANNOT start with a decimal
        #    point
	lip = max(1,ip-1)
	if( nchar > 0 ){
	    if( nchar > 1 && IS_DIGDOT(strval[lip]) )
                flval = TRUE
	    else if( nchar == 1 && IS_DIGIT(strval[lip]) )
	        flval = TRUE
	    else
		flval = FALSE
	}
	else
	    flval = FALSE
        return(flval)
end

bool procedure ck_ival(strval,ip,value)
char	strval[ARB]		# i/o: input string - with filename or int value
int	ip			# i/o: curent index in string
bool	intval			# o:    does string contain integer?
int	value			# o: value converted

int	nchar			# l: number of characters converted
int	lip			# l: local pointer to end of value string
int	ctoi()

begin
    # check for empty
	nchar = ctoi(strval,ip,value)
	lip = max(1,ip-1)
	if( nchar >0 && lip >1 && IS_DIGIT(strval[lip]) )
	{
	    intval = TRUE
	}
	else
	{
	    intval = FALSE
	}

        return(intval)
end

procedure ck_comma(str,len)
char	str[ARB]		# i/o: input string - commas replace with " "
int	len			# i: length of string
int	ip			# l: curent index in string


begin
    # check for comma
	do ip = 1,len
	{
	    if( str[ip] == ',' )
		str[ip] = ' '
	}
end


