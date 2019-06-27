#$Header: /home/pros/xray/lib/regions/RCS/rgftype.x,v 11.0 1997/11/06 16:19:14 prosb Exp $
#$Log: rgftype.x,v $
#Revision 11.0  1997/11/06 16:19:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:31  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:40  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:55  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:48  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:16  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:20:56  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:27  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:40  pros
#General Release 1.0
#
include <finfo.h>

#
# rg_ftype -- is the descriptor a plio file or a region file?
#	returns:
#		0 if neither a plio or a region file
#		1 if region file
#		2 if plio file
#	if no extension is given, and both types exist, choose the newest!
#
int procedure rg_ftype(region, plname, len)

char	region[ARB]			# i: region descriptor
char	plname[ARB]			# o: output plio name
int	len				# i: size of plname
int	junk				# l: junk return from fnextn
int	got				# l: got a pl file
int	flag				# l: file access flag
long    plstruct[LEN_FINFO]		# l: finfo return
long    regstruct[LEN_FINFO]		# l: finfo return
pointer	fullname			# l: full name
pointer	extn				# l: extension
pointer	sp				# l: satck pointer
int	access()			# l: file existence
int	fnextn()			# l: get file extension
int	finfo()				# l: file info
bool	streq()				# l: string compare

begin
	# allocate space
	call smark(sp)
	call salloc (fullname, SZ_PATHNAME, TY_CHAR)
	call salloc (extn, SZ_FNAME, TY_CHAR)

	# seed the output name
	call strcpy(region, plname, len)

	# look at the extensions - these are the easy cases!
        call strcpy (region, Memc[fullname], SZ_PATHNAME)
        junk = fnextn (region, Memc[extn], SZ_FNAME)
	# it is a region extension
        if (streq (Memc[extn], "reg"))
	    got = 1
	# is it a plio extension?
        else if (streq (Memc[extn], "pl"))
	    got = 2
	# neither obvious extension is on the file
	# check if the file exists as is, and assume its a region if so
	else if( access(region, 0, 0) == YES )
	    got = 1
	# we have to add the extensions and check for existence
	else{
		# init file access flag
		flag = 0
		# see if a ".reg" file exists
	        call strcpy (region, Memc[fullname], SZ_PATHNAME)
	        call strcat (".reg", Memc[fullname], SZ_PATHNAME)
		# check for existence of a region file
		if( access(Memc[fullname], 0, 0) == YES ){
		    flag = 1
		    junk = finfo(Memc[fullname], regstruct)
		}
		# see if a ".pl" file exists
	        call strcpy (region, Memc[fullname], SZ_PATHNAME)
	        call strcat (".pl", Memc[fullname], SZ_PATHNAME)
		# check for existence of a pl file
		if( access(Memc[fullname], 0, 0) == YES ){
		    flag = flag + 2
		    junk = finfo(Memc[fullname], plstruct)
		}
		# flag ==0 => neither a region of a pl file
		if( flag ==0 ){
		    call strcpy ("", plname, len)
		    got = 0
		}
		else if( flag ==1 ){
		    call strcat (".reg", plname, len)
		    got = 1
		}
		# flag ==2 => only a plio file
		else if( flag ==2 ){
		    call strcat (".pl", plname, len)
		    got = 2
		}
		# both files exist - use the newer file from finfo information
		else if( flag ==3 ){
		    if( FI_MTIME(regstruct) > FI_MTIME(plstruct) ){
			call strcat (".reg", plname, len)
			got = 1
		    }
		    else{
			call strcat (".pl", plname, len)
			got = 2
		    }
		}
		else
		    call error(1, "impossible value in rg_ftype")
	}
	# free up space
	call sfree(sp)
	# return the news
	return(got)
end

