include <error.h>
include <ctype.h>
include <lexnum.h>
include <finfo.h>
include <ext.h>
include <spectral.h>

include	"obsparse.h"

define	MULTIPLIER		257
define	DATA		258
define	INCL		259
define	RANGE		260
define	UNKNOWN		261
define	YYEOF		262
define	SEMICOLON		263
define	NEWLINE		264
define	yyclearin	yychar = -1
define	yyerrok		yyerrflag = 0
define	YYMOVE		call amovi (Memi[$1], Memi[$2], YYOPLEN)
define	YYERRCODE	256

# line 106 "obsparse.yy"


#
# OBS_PARSE -- parse an observation data set string
#
int procedure obs_parse(s, fp, debug)

char	s[ARB]			# i: observation data set string
pointer	fp			# o: frame pointer
int	debug			# i: debug flag

int	tdebug			# l: temp debug flag for obs_yyparse
int	status			# l: return from obs_yyparse
pointer sp			# l: stack pointer

int	open()			# l: open a file
int	obs_yyparse()		# l: parser
extern	obs_lex()		# l: lexical analyzer

include "obsparse.com"

begin
	# mark the stack
	call smark(sp)

	# save the frame pointer
	obs_fp = fp

	# set the obs_yyparse debug flag
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
	    status = obs_yyparse (obs_fd, tdebug, obs_lex)
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

define	YYNPROD		13
define	YYLAST		16
# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

# Parser for yacc output, translated to the IRAF SPP language.  The contents
# of this file form the bulk of the source of the parser produced by Yacc.
# Yacc recognizes several macros in the yaccpar input source and replaces
# them as follows:
#	A	user suppled "global" definitions and declarations
# 	B	parser tables
# 	C	user supplied actions (reductions)
# The remainder of the yaccpar code is not changed.

define	yystack_	10		# statement labels for gotos
define	yynewstate_	20
define	yydefault_	30
define	yyerrlab_	40
define	yyabort_	50

define	YYFLAG		(-1000)		# defs used in user actions
define	YYERROR		goto yyerrlab_
define	YYACCEPT	return (OK)
define	YYABORT		return (ERR)


# YYPARSE -- Parse the input stream, returning OK if the source is
# syntactically acceptable (i.e., if compilation is successful),
# otherwise ERR.  The parameters YYMAXDEPTH and YYOPLEN must be
# supplied by the caller in the %{ ... %} section of the Yacc source.
# The token value stack is a dynamically allocated array of operand
# structures, with the length and makeup of the operand structure being
# application dependent.

int procedure obs_yyparse (fd, yydebug, yylex)

int	fd			# stream to be parsed
bool	yydebug			# print debugging information?
int	yylex()			# user-supplied lexical input function
extern	yylex()

short	yys[YYMAXDEPTH]		# parser stack -- stacks tokens
pointer	yyv			# pointer to token value stack
pointer	yyval			# value returned by action
pointer	yylval			# value of token
int	yyps			# token stack pointer
pointer	yypv			# value stack pointer
int	yychar			# current input token number
int	yyerrflag		# error recovery flag
int	yynerrs			# number of errors

short	yyj, yym		# internal variables
pointer	yysp, yypvt
short	yystate, yyn
int	yyxi, i
errchk	salloc, yylex


include	"obsparse.com"
short	yyexca[6]
data	(yyexca(i),i=  1,  6)	/  -1,   1,   0,  -1,  -2,   0/
short	yyact[16]
data	(yyact(i),i=  1,  8)	/   8,   9,   7,   6,   5,   7,   6,  13/
data	(yyact(i),i=  9, 16)	/  14,   2,  12,   4,   3,  10,  11,   1/
short	yypact[15]
data	(yypact(i),i=  1,  8)	/-258,-1000,-1000,-261,-261,-1000,-1000,-1000/
data	(yypact(i),i=  9, 15)	/-250,-1000,-1000,-1000,-249,-1000,-1000/
short	yypgo[5]
data	(yypgo(i),i=  1,  5)	/   0,  15,   9,  12,  11/
short	yyr1[13]
data	(yyr1(i),i=  1,  8)	/   0,   1,   1,   1,   1,   1,   3,   3/
data	(yyr1(i),i=  9, 13)	/   3,   3,   4,   2,   2/
short	yyr2[13]
data	(yyr2(i),i=  1,  8)	/   0,   0,   1,   2,   2,   1,   1,   2/
data	(yyr2(i),i=  9, 13)	/   2,   3,   1,   1,   1/
short	yychk[15]
data	(yychk(i),i=  1,  8)	/-1000,  -1,  -2,  -3,  -4, 262, 264, 263/
data	(yychk(i),i=  9, 15)	/ 258, 259,  -2,  -2, 260, 257, 257/
short	yydef[15]
data	(yydef(i),i=  1,  8)	/   1,  -2,   2,   0,   0,   5,  11,  12/
data	(yydef(i),i=  9, 15)	/   6,  10,   3,   4,   7,   8,   9/

begin
	call smark (yysp)
	call salloc (yyv, (YYMAXDEPTH+2) * YYOPLEN, TY_STRUCT)

	# Initialization.  The first element of the dynamically allocated
	# token value stack (yyv) is used for yyval, the second for yylval,
	# and the actual stack starts with the third element.

	yystate = 0
	yychar = -1
	yynerrs = 0
	yyerrflag = 0
	yyps = 0
	yyval = yyv
	yylval = yyv + YYOPLEN
	yypv = yylval

yystack_
	# SHIFT -- Put a state and value onto the stack.  The token and
	# value stacks are logically the same stack, implemented as two
	# separate arrays.

	if (yydebug) {
	    call printf ("state %d, char 0%o\n")
		call pargs (yystate)
		call pargi (yychar)
	}
	yyps = yyps + 1
	yypv = yypv + YYOPLEN
	if (yyps > YYMAXDEPTH) {
	    call sfree (yysp)
	    call eprintf ("yacc stack overflow\n")
	    return (ERR)
	}
	yys[yyps] = yystate
	YYMOVE (yyval, yypv)

yynewstate_
	# Process the new state.
	yyn = yypact[yystate+1]

	if (yyn <= YYFLAG)
	    goto yydefault_			# simple state

	# The variable "yychar" is the lookahead token.
	if (yychar < 0) {
	    yychar = yylex (fd, yylval)
	    if (yychar < 0)
		yychar = 0
	}
	yyn = yyn + yychar
	if (yyn < 0 || yyn >= YYLAST)
	    goto yydefault_

	yyn = yyact[yyn+1]
	if (yychk[yyn+1] == yychar) {		# valid shift
	    yychar = -1
	    YYMOVE (yylval, yyval)
	    yystate = yyn
	    if (yyerrflag > 0)
		yyerrflag = yyerrflag - 1
	    goto yystack_
	}

yydefault_
	# Default state action.

	yyn = yydef[yystate+1]
	if (yyn == -2) {
	    if (yychar < 0) {
		yychar = yylex (fd, yylval)
		if (yychar < 0)
		    yychar = 0
	    }

	    # Look through exception table.
	    yyxi = 1
	    while ((yyexca[yyxi] != (-1)) || (yyexca[yyxi+1] != yystate))
		yyxi = yyxi + 2
	    for (yyxi=yyxi+2;  yyexca[yyxi] >= 0;  yyxi=yyxi+2) {
		if (yyexca[yyxi] == yychar)
		    break
	    }

	    yyn = yyexca[yyxi+1]
	    if (yyn < 0) {
		call sfree (yysp)
		return (OK)			# ACCEPT -- all done
	    }
	}


	# SYNTAX ERROR -- resume parsing if possible.

	if (yyn == 0) {
	    switch (yyerrflag) {
	    case 0, 1, 2:
		if (yyerrflag == 0) {		# brand new error
		    call eprintf ("syntax error\n")
yyerrlab_
		    yynerrs = yynerrs + 1
		    # fall through...
		}

	    # case 1:
	    # case 2: incompletely recovered error ... try again
		yyerrflag = 3

		# Find a state where "error" is a legal shift action.
		while (yyps >= 1) {
		    yyn = yypact[yys[yyps]+1] + YYERRCODE
		    if ((yyn >= 0) && (yyn < YYLAST) &&
			(yychk[yyact[yyn+1]+1] == YYERRCODE)) {
			    # Simulate a shift of "error".
			    yystate = yyact[yyn+1]
			    goto yystack_
		    }
		    yyn = yypact[yys[yyps]+1]

		    # The current yyps has no shift on "error", pop stack.
		    if (yydebug) {
			call printf ("error recovery pops state %d, ")
			    call pargs (yys[yyps])
			call printf ("uncovers %d\n")
			    call pargs (yys[yyps-1])
		    }
		    yyps = yyps - 1
		    yypv = yypv - YYOPLEN
		}

		# ABORT -- There is no state on the stack with an error shift.
yyabort_
		call sfree (yysp)
		return (ERR)


	    case 3: # No shift yet; clobber input char.

		if (yydebug) {
		    call printf ("error recovery discards char %d\n")
			call pargi (yychar)
		}

		if (yychar == 0)
		    goto yyabort_		# don't discard EOF, quit
		yychar = -1
		goto yynewstate_		# try again in the same state
	    }
	}


	# REDUCE -- Reduction by production yyn.

	if (yydebug) {
	    call printf ("reduce %d\n")
		call pargs (yyn)
	}
	yyps  = yyps - yyr2[yyn+1]
	yypvt = yypv
	yypv  = yypv - yyr2[yyn+1] * YYOPLEN
	YYMOVE (yypv + YYOPLEN, yyval)
	yym   = yyn

	# Consult goto table to find next state.
	yyn = yyr1[yyn+1]
	yyj = yypgo[yyn+1] + yys[yyps] + 1
	if (yyj >= YYLAST)
	    yystate = yyact[yypgo[yyn+1]+1]
	else {
	    yystate = yyact[yyj+1]
	    if (yychk[yystate+1] != -yyn)
		yystate = yyact[yypgo[yyn+1]+1]
	}

	# Perform action associated with the grammar rule, if any.
	switch (yym) {
	    
case 2:
# line 63 "obsparse.yy"
{
			return (OK)
		    }
case 3:
# line 66 "obsparse.yy"
{
			return (OK)
		    }
case 4:
# line 69 "obsparse.yy"
{
			return (OK)
		    }
case 5:
# line 72 "obsparse.yy"
{
			return (EOF)
		    }
case 6:
# line 77 "obsparse.yy"
{
			# New observation set, all channels, no scale)
			call obs_dataset(VALC(yypvt), "", 0.0, yyval)
		    }
case 7:
# line 81 "obsparse.yy"
{
			# New observation set, all channels, scale)
			call obs_dataset(VALC(yypvt-YYOPLEN), VALC(yypvt), 0.0, yyval)
		    }
case 8:
# line 85 "obsparse.yy"
{
			# New observation set, all channels, scale)
			call obs_dataset(VALC(yypvt-YYOPLEN), "", VALR(yypvt), yyval)
		    }
case 9:
# line 89 "obsparse.yy"
{
			# New observation set, all channels, scale)
			call obs_dataset(VALC(yypvt-2*YYOPLEN), VALC(yypvt-YYOPLEN), VALR(yypvt), yyval)
		    }
case 10:
# line 96 "obsparse.yy"
{
			# include file
			call obs_inc(yypvt, yyval)
		    }	}

	goto yystack_				# stack new state and value
end
