#$Header: /home/pros/RCS/obsparse.yy,v 9.0 1995/11/16 19:30:38 prosb Rel $
#$Log: obsparse.yy,v $
#Revision 9.0  1995/11/16  19:30:38  prosb
#General Release 2.4
#
#Revision 8.1  1995/08/08  14:28:32  prosb
#jcc - ci for pros2.4.
#
#Revision 8.0  94/06/27  17:33:55  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:03  prosb
#General Release 2.3
#
#Revision 6.3  93/10/22  16:05:22  dennis
#Added SRG_HEPC1, SRG_LEPC1 cases, for DSRI.
#
#Revision 6.2  93/09/25  02:15:32  dennis
#Changed to accommodate the new file formats (RDF).
#
#Revision 6.1  93/09/03  20:57:23  dennis
#Added subinstrument parameter to call to inst_ctoi().
#
#Revision 6.0  93/05/24  16:51:51  prosb
#General Release 2.2
#
#Revision 5.1  93/04/30  22:16:26  dennis
#Changed lexical analyzer and grammar to allow file names to begin with 
#digits.
#
#Revision 5.0  92/10/29  22:45:40  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:00  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:58:49  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:29:17  prosb
#jso - made spectral.h system wide
#       and corrected ext.h
#
#Revision 2.0  91/03/06  23:06:11  pros
#General Release 1.0
#
#
#	OBSPARSE.YY - xyacc grammer for observation data sets
#

%{
include <error.h>
include <ctype.h>
include <lexnum.h>
include <finfo.h>
include <ext.h>
include <spectral.h>

include	"obsparse.h"

%L
include	"obsparse.com"
%}

%token		MULTIPLIER DATA INCL RANGE UNKNOWN
%token		YYEOF
%token		SEMICOLON NEWLINE

%%

command	:	# Empty
	|	eost {
			return (OK)
		    }
	|	data eost {
			return (OK)
		    }
	|	incl eost {
			return (OK)
		    }
	|	YYEOF {
			return (EOF)
		    }
	;

data	:	DATA {
			# New observation set, all channels, no scale)
			call obs_dataset(VALC($1), "", 0.0, $$)
		    }
	|	DATA RANGE {
			# New observation set, all channels, scale)
			call obs_dataset(VALC($1), VALC($2), 0.0, $$)
		    }
	|	DATA MULTIPLIER {
			# New observation set, all channels, scale)
			call obs_dataset(VALC($1), "", VALR($2), $$)
		    }
	|	DATA RANGE MULTIPLIER {
			# New observation set, all channels, scale)
			call obs_dataset(VALC($1), VALC($2), VALR($3), $$)
		    }
	;


incl	:	INCL {
			# include file
			call obs_inc($1, $$)
		    }
	;

eost	:	NEWLINE
	|	SEMICOLON
	;

%%

#
# OBS_PARSE -- parse an observation data set string
#
int procedure obs_parse(s, fp, debug)

char	s[ARB]			# i: observation data set string
pointer	fp			# o: frame pointer
int	debug			# i: debug flag

int	tdebug			# l: temp debug flag for yyparse
int	status			# l: return from yyparse
pointer sp			# l: stack pointer

int	open()			# l: open a file
int	yyparse()		# l: parser
extern	obs_lex()		# l: lexical analyzer

include "obsparse.com"

begin
	# mark the stack
	call smark(sp)

	# save the frame pointer
	obs_fp = fp

	# set the yyparse debug flag
	if( debug >= 10 )
	    tdebug = 1
	else
	    tdebug = 0

	# allocate a string buffer for file names
	call salloc(obs_sbuf, SZ_SBUF, TY_CHAR)

	# start with new line
	obs_lptr = 0

	# create a spool file for the command string
	obs_fd = open("spool1", READ_WRITE, SPOOL_FILE)
	# write the s buffer to the file
	call fprintf(obs_fd, "%s\n")
	call pargstr(s)
	# rewind the spool file
	call seek(obs_fd, BOF)
	# set it up as first in fd list
	obs_fdlev = 1
	obs_fds[obs_fdlev] = obs_fd

	# compile and execute region specifications
	repeat {
	    # reset current string pointer back to beginning
	    obs_nextch = obs_sbuf
	    # parse next obs file
	    status = yyparse (obs_fd, tdebug, obs_lex)
	} until( status != OK )

	# free up the allocated space
	call sfree(sp)

	# check final status
	if( status == EOF ){
	    return(YES)
	}
	else{
	    return(NO)
	}
end

#
# OBS_LEX -- Lexical input routine.  Return next token from the input stream
#
int procedure obs_lex (fd, yylval)

int	fd			# i: input file channel
pointer	yylval			# o: output value for parser stack

int	token			# l: token type
int	type			# l: type of token - returned by function
double	dval			# l: numeric value of string
pointer	s			# l: pointer to input table or include name
pointer	t			# l: pointer to full table or include name

int	obs_ftype()		# l: check whether s is an include file name
int	getline()		# l: get a line
int	gctod()			# l: ASCII to decimal
int	strlen()		# l: string length

include "obsparse.com"

begin
	# Fetch a nonempty input line, or advance to start of next token
	# if within a line.  Newline is a token.
	while( obs_lptr == 0) {
	    # read next line
	    if (getline (fd, obs_lbuf) == EOF) {
		# on end of file, check for a pushed file
		if( obs_fdlev == 1 ){
		  return (YYEOF)
		}
		# and pop it, if necessary
		else
		  call obs_popfd()
	    } else{
		# skip white space
		while (IS_WHITE (obs_lbuf[obs_lptr]))
			obs_lptr = obs_lptr + 1
		# skip blank lines and lines beginning with "#"
		if( (strlen(obs_lbuf) >1) && (obs_lbuf[1] != '#') ){
		    # point the lptr to the first character
		    obs_lptr = 1
		}
	    }
	}

	# skip white space
	while (IS_WHITE (obs_lbuf[obs_lptr]))
		obs_lptr = obs_lptr + 1

	# consider the next character as a potential token
	token = obs_lbuf[obs_lptr]
	obs_lptr = obs_lptr+1

	# seed the parser stack value - this might be overwritten
	VALI(yylval) = token

	# process the token
	switch (token) {
	 
	case ';':
	    type = SEMICOLON

	case '\n':
	    type = NEWLINE
	    obs_lptr = 0

	case '#':
	    # skip to end of statement
	    while( (obs_lbuf[obs_lptr] != ';' ) &&
		   (obs_lbuf[obs_lptr] != '\n') &&
		   (obs_lbuf[obs_lptr] != EOS ) )
		obs_lptr = obs_lptr + 1
	    # get correct type for terminator
	    switch(obs_lbuf[obs_lptr]){
	    case ';':
		obs_lptr = obs_lptr + 1
		type = SEMICOLON
	    case '\n':
		obs_lptr = 0
		type = NEWLINE
	    case EOS:
		obs_lptr = 0
		type = NEWLINE
	    }

	case '*':
	    type = MULTIPLIER
	    if (gctod (obs_lbuf, obs_lptr, dval) == 0)
		call error(1, "non-numeric multiplier")
	    VALR(yylval) = dval

	case ']':
	    call error(1, "unmatched ']' on range specification")

	case '[':
	    type = RANGE
	    # return value is a string
	    LBUF(yylval) = obs_nextch
	    # grab everything up to ']' (or EOS, which is a syntax error)
	    # don't grab either bracket, though
	    while( (obs_lbuf[obs_lptr] != EOS) &&
		   (obs_lbuf[obs_lptr] != ';') &&
		   (obs_lbuf[obs_lptr] != '\n') &&
		   (obs_lbuf[obs_lptr] != ']') ){
		    # add the char to the string
		    Memc[obs_nextch] = obs_lbuf[obs_lptr]
		    # and bump the pointers
		    obs_nextch = obs_nextch + 1
		    obs_lptr = obs_lptr+1
	    }
	    # finish up the string
	    Memc[obs_nextch] = EOS
	    # bump the "next available" pointer
	    obs_nextch = obs_nextch + 1
	    # make sure we have valid syntax
	    if( obs_lbuf[obs_lptr] != ']' ){
		call error(1, "missing ']' on range specification")
	    }
	    # bump past ']'
	    else
		obs_lptr = obs_lptr+1

	# identifier
	default:
	    # start grabbing chars into the string buffer
	    s = obs_nextch
	    Memc[obs_nextch] = token
	    obs_nextch = obs_nextch + 1

	    # get identifier
	    while( IS_ALNUM(obs_lbuf[obs_lptr]) ||
			   (obs_lbuf[obs_lptr] == '.') ||
			   (obs_lbuf[obs_lptr] == '_') ||
			   (obs_lbuf[obs_lptr] == '/') ||
			   (obs_lbuf[obs_lptr] == '$') ){
		    # add the char to the string
		    Memc[obs_nextch] = obs_lbuf[obs_lptr]
		    # and bump the pointers
		    obs_nextch = obs_nextch + 1
		    obs_lptr=obs_lptr+1
	    }
	    # finish up the string
	    Memc[obs_nextch] = EOS
	    # bump the "next available" pointer
	    obs_nextch = obs_nextch + 1

	    # check for file and determine the type (obs or include)
	    if( obs_ftype(Memc[s], t, type) != UNKNOWN )
		LBUF(yylval) = t
	    # it's an unknown keyword
	    else
		call errstr(1, "file does not exist", Memc[s])
	}

	# return what we found
	return(type)
end

#
# OBS_INC -- process a new include file by pushing the old fd
#		 and opening the new file
#
procedure obs_inc(a, yyval)

pointer a			# i: input parser register
pointer yyval			# o: parser output value

include "obsparse.com"

begin
	# push the fd
	call obs_pushfd(VALC(a))
	# return value to parser
	VALI(yyval) = VALI(a)
end

#
# OBS_PUSHFD --	open a file and make the new fd current
#		push the previous fd on the stack
#
procedure obs_pushfd(fname)

char fname[ARB]			# i: file name to open

int open()			# l: open a file

include "obsparse.com"

begin
	# inc the number of fd's we have nested
	obs_fdlev = obs_fdlev + 1

	# check for overflow
	if( obs_fdlev >= MAX_NESTS ){
	    call printf("include file stack overflow - skipping file %s\n")
	    call pargstr(fname)
	    return
	}

	# open the new file
	obs_fds[obs_fdlev] = open(fname, READ_ONLY, TEXT_FILE)
	# and make it the current fd (for next read)
	obs_fd = obs_fds[obs_fdlev]
end

#
# OBS_POPFD --	close a file
#		pop the previous fd on the stack, if there is one
#
procedure obs_popfd()

include "obsparse.com"

begin
	# close the current file
	call close(obs_fd)
	# dec the number of fd's we have nested
	obs_fdlev = obs_fdlev - 1
	# level <= 0 - underflow
	if( obs_fdlev <= 0 ){
	    call printf("internal error: include file stack underflow")
	    return
	}
	# level > 0 - restore previous fd
	else
	    obs_fd = obs_fds[obs_fdlev]
end

#
# OBS_FTYPE -- is the string a table file or an include file?
#	returns:
#		0 if neither a table or an include file
#		1 if table file
#		2 if include file
#	if no extension is given, and both types exist, choose the newest!
#	also returns the full name in oname (which is allocated from obs_nextch)
#
int procedure obs_ftype(iname, oname, type)

char	iname[ARB]			# i: input string
pointer	oname				# o: output name
int	type				# o: type of file

int	len				# l: length of oname
int	junk				# l: junk return from fnextn
int	flag				# l: file access flag
long    tstruct[LEN_FINFO]		# l: table finfo return
long    t2struct[LEN_FINFO]		# l: table finfo return
long    istruct[LEN_FINFO]		# l: include finfo return
pointer	fullname			# l: full name
pointer	extn				# l: extension
pointer	sp				# l: satck pointer

int	access()			# l: file existence
int	fnextn()			# l: get file extension
int	finfo()				# l: file info
int	strlen()			# l: string length
bool	streq()				# l: string compare

include "obsparse.com"

begin
	# allocate space
	call smark(sp)
	call salloc (fullname, SZ_PATHNAME, TY_CHAR)
	call salloc (extn, SZ_FNAME, TY_CHAR)

	# allocate space from common for name + possible extension
	len = strlen(iname) + strlen(EXT_OBS) + 1
	# set oname to next available buffer space
	oname = obs_nextch
	# seed the output name
	call strcpy(iname, Memc[oname], len)
	# bump next available buffer space (include null)
	obs_nextch = obs_nextch + len

	# look at the extensions - these are the easy cases!
        call strcpy (iname, Memc[fullname], SZ_PATHNAME)
        junk = fnextn (iname, Memc[extn], SZ_FNAME)
	# is it a table file?
        if (streq (Memc[extn], "tab"))
	    type = DATA
	# is it an "inc" include file?
        else if (streq (Memc[extn], "inc"))
	    type = INCL
	# neither obvious extension is on the file
	# check if the file exists as is, and assume its an include if so
	else if( access(iname, 0, 0) == YES )
	    type = INCL
	# we have to add the extensions and check for existence
	else{
		# init file access flag
		flag = 0
		# see if a ".tab" file exists
	        call strcpy (iname, Memc[fullname], SZ_PATHNAME)
	        call strcat (".tab", Memc[fullname], SZ_PATHNAME)
		# check for existence of a table file
		if( access(Memc[fullname], 0, 0) == YES ){
		    flag = 1
		    junk = finfo(Memc[fullname], tstruct)
		}
		# see if a ".inc" file exists
	        call strcpy (iname, Memc[fullname], SZ_PATHNAME)
	        call strcat (".inc", Memc[fullname], SZ_PATHNAME)
		# check for existence of an include file
		if( access(Memc[fullname], 0, 0) == YES ){
		    flag = flag + 2
		    junk = finfo(Memc[fullname], istruct)
		}
		# see if a "_obs.tab" file exists
	        call strcpy (iname, Memc[fullname], SZ_PATHNAME)
	        call strcat (EXT_OBS, Memc[fullname], SZ_PATHNAME)
		# check for existence of a table file
		if( access(Memc[fullname], 0, 0) == YES ){
		    flag = flag + 4
		    junk = finfo(Memc[fullname], t2struct)
		}
	        switch(flag){
		# flag ==0 => neither a table or an include
		case 0:
		    type = UNKNOWN
		# flag ==1 => only a table file
		case 1:
		    call obs_addext(".tab", Memc[oname], len)
		    type = DATA
		# flag ==2 => only a plio file
		case 2:
		    call obs_addext(".inc", Memc[oname], len)
		    type = INCL
		# both files exist - use the newer file from finfo information
		case 3:
		    if( FI_MTIME(tstruct) > FI_MTIME(istruct) ){
			call obs_addext (".tab", Memc[oname], len)
			type = DATA
		    }
		    else{
			call obs_addext (".inc", Memc[oname], len)
			type = INCL
		    }
		# flag ==4 => only a table file
		case 4:
		    call obs_addext (EXT_OBS, Memc[oname], len)
		    type = DATA
		# flag ==5 => a table file or a compound table extension
		case 5:
		    if( FI_MTIME(t2struct) > FI_MTIME(tstruct) ){
			call obs_addext (EXT_OBS, Memc[oname], len)
			type = DATA
		    }
		    else{
			call obs_addext (".tab", Memc[oname], len)
			type = DATA
		    }
		# flag ==6 => table or include
		case 6:
		    if( FI_MTIME(t2struct) > FI_MTIME(istruct) ){
			call obs_addext (EXT_OBS, Memc[oname], len)
			type = DATA
		    }
		    else{
			call obs_addext (".inc", Memc[oname], len)
			type = INCL
		    }
		# flag ==7 => table or include or compound
		case 7:
		    if( FI_MTIME(tstruct) > FI_MTIME(istruct) ){
			if( FI_MTIME(tstruct) > FI_MTIME(t2struct) ){
			    call obs_addext (".tab", Memc[oname], len)
			    type = DATA
			}
			else{
			    call obs_addext (EXT_OBS, Memc[oname], len)
			    type = DATA
			}
		    }
		    else{
			if( FI_MTIME(istruct) > FI_MTIME(t2struct) ){
			    call obs_addext (".inc", Memc[oname], len)
			    type = INCL
			}
			else{
			    call obs_addext (EXT_OBS, Memc[oname], len)
			    type = DATA
			}
		    }
		default:
		    call error(1, "impossible value in obs_ftype")
	    }
	}
	# free up space
	call sfree(sp)
	# return the type
	return(type)
end

#
# OBS_ADDEXT -- add an extension and update the internal buf pointer
#
procedure obs_addext(ext, file, len)

char	ext[ARB]			# i: extension to add
char	file[ARB]			# i/o: file name
int	len				# i: max length of string
int	strlen()			# l: string length
include "obsparse.com"

begin
	# add the string
	call strcat(ext, file, len)
	# and update the internal buffer pointer
	obs_nextch = obs_nextch + strlen(ext)
end

#
# OBS_DATASET - add a data set to the frame
#	this is the only interesting routine of the lot!
#
procedure obs_dataset(fname, range, scale, a)

char	fname[ARB]			# i: data set name
char	range[ARB]			# i: range of channels
real	scale				# i: scale factor applied to the ds
pointer	a				# o: return yacc value

pointer	qphead				# l: QPOE header struct from table
pointer	ds				# l: data set pointer
int	nfit				# l: number of channels to fit
char	trange[SZ_LINE]			# l: temp range string
bool	streq()				# l: string compare

include "obsparse.com"

begin
	# get the observed data set info from the table(s)
	call ds_get(fname, qphead, ds)
	# we have no interest in the QPOE header struct, so discard it
	call mfree(qphead, TY_STRUCT)
	# inc the number of data sets we have processed
	FP_DATASETS(obs_fp) = FP_DATASETS(obs_fp) + 1
	# save data set number as the reference number for this data set
	DS_REFNUM(ds) = FP_DATASETS(obs_fp)
	# save this data set in the frame
	FP_OBSERSTACK(obs_fp, FP_DATASETS(obs_fp)) = ds
	# save the scale factor
	DS_SCALE(ds) = scale
	# allocate space for the "channels to fit" flags
#	call calloc(DS_CHANNEL_FIT(ds), DS_NPHAS(ds), TY_INT)
	# if no range is specified, get the default range from parameter file
	if( streq("", range) )
	    call obs_def_range(Memc[DS_FILENAME(ds)], trange, SZ_LINE)
	else
	    call strcpy(range, trange, SZ_LINE)
	# edit the range to use "-" instead of ":"
	call obs_edit_range(trange)
	# get the number of channels to fit
	call get_bin_flags(trange, Memi[DS_CHANNEL_FIT(ds)], DS_NPHAS(ds),
		nfit)
	# add these channels to total
	FP_CHANNELS(obs_fp) = FP_CHANNELS(obs_fp) + nfit
end

#
#  OBS_EDIT_RANGE -- edit range spec to change ":" to "-"
#
procedure obs_edit_range(range)

char	range[ARB]			# i: range spec
int	i				# l: loop counter

begin
	for(i=1; range[i] != EOS; i=i+1){
	    if( range[i] == ':' )
		range[i] = '-'
	}
end

#
#  OBS_DEF_RANGE -- get default range for an instrument
#
procedure obs_def_range(table, range, len)

char	table[ARB]			# i: table name
char	range[ARB]			# o: range
int	len				# i: size of range string
int	inst				# l: instrument
int	subinst				# l: subinstrument
int	mission				# l: some should look at dstables.x!
char	cbuf[SZ_LINE]			# l: this is pretty lame!
pointer	tp				# l: table pointer
char	buf[SZ_LINE]			# l: temp string buffer

int	tbhgti()			# l: get int table param
int	ds_tbhgtt()			# l: get int table param
pointer	tbtopn()			# l: open table file

begin
	# open the table
        tp = tbtopn (table, READ_ONLY, 0)
	# this should be done better, since something similar is done
	# in dstables.x (no time now)
	# get mission from one of two sources
	if( ds_tbhgtt(tp, "TELESCOP", cbuf, SZ_LINE) == YES )
	    call mis_ctoi(cbuf, mission)
	else
	    mission = tbhgti(tp, "mission")
	# get instrument from one of two sources
	if( ds_tbhgtt(tp, "INSTRUME", cbuf, SZ_LINE) == YES ){
	    call inst_ctoi(cbuf, mission, inst, subinst)
	    # might have old instrument param with integer value
	    if( inst ==0 )
	        inst = tbhgti(tp, "instrument")
	}
	else
	    inst = tbhgti(tp, "instrument")
	# get the name of the channel parameter
	call sprintf(buf, SZ_LINE, "%s_channels")
	switch(inst){
	case EINSTEIN_HRI:
	    call pargstr("ein_hri")
	case EINSTEIN_IPC:
	    call pargstr("ein_ipc")
	case EINSTEIN_MPC:
	    call pargstr("ein_mpc")
	case ROSAT_HRI:
	    call pargstr("ros_hri")
	case ROSAT_PSPC:
	    call pargstr("ros_pspc")
	case SRG_HEPC1:
	    call pargstr("srg_hepc1")
	case SRG_LEPC1:
	    call pargstr("srg_lepc1")
	default:
	    call error(1, "unsupported spectral instrument")
	}
	# get default range
	call clgstr(buf, range, len)
	# close table file
	call tbtclo(tp)
end

