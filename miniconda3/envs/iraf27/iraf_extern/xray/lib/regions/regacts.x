#$Header: /home/pros/xray/lib/regions/RCS/regacts.x,v 11.0 1997/11/06 16:19:00 prosb Exp $
#$Log: regacts.x,v $
#Revision 11.0  1997/11/06 16:19:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:08  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:29:48  mo
#MC	7/2/93		Fix check on 'rg_ckcount' to correctly evaluate integer
#			rather than boolean
#
#Revision 6.0  93/05/24  15:37:48  prosb
#General Release 2.2
#
#Revision 5.2  93/05/05  00:35:11  dennis
#In rg_region() and rg_endexpr(), corrected handling of shape (FIELD) 
#with no arguments.
#
#Revision 5.1  93/04/26  23:58:11  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:13:37  prosb
#General Release 2.1
#
#Revision 4.3  92/09/29  20:57:41  dennis
#New routine rg_refspec(), to read filespec arg for REFFILE, LOGICAL
#Corrected text in calls to error()
#Corrected comments
#
#Revision 4.2  92/09/02  03:07:24  dennis
#Changed strcat() calls extending Memc[rg_name] to reflect new buffer size 
#of SZ_REGOUTPUTLINE.  Corrected other buffer sizes to SZ_PATHNAME or 
#SZ_2PATHNAMESPLUS.  Removed extra "+1" in string buffer allocation.
#
#Revision 4.1  92/07/13  21:34:17  dennis
#In rg_region(), in several calls to rg_ansize(), change "rot" argument
#from 0 to 0.0, to match parameter type.
#
#Revision 4.0  92/04/27  17:19:38  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:31:47  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:14:25  pros
#General Release 1.0
#
#
#	REGACTS.X - parser setup routines; 
#	            routines called from rg_lex(); 
#	            "action routines", called from the "code fragments" 
#	            	in the xyacc grammar
#

include <error.h>
include <ctype.h>

include	"ytab.h"
include <regparse.h>

include <math.h>
include <qpoe.h>
include <precess.h>

#---------------------------------------------------------------------------
#	SETUP FUNCTIONS
#---------------------------------------------------------------------------

#
# RG_DEFKEYWORDS -- set up the keyword lookup table, defining the keywords'
#                   names, codes, types, and allowed numbers of arguments
#
procedure rg_defkeywords()

include	"regparse.com"

begin
	rg_installed = 0

# Add keyword type parameter to distinguish shapes from coordinate commands
#
	# install region names, with min and max args
	call rg_install("ANNULUS", 	 ANNULUS, 	REGION,		4, -1)
	call rg_install("BOX", 		 BOX, 		REGION,		4, 5)
	call rg_install("CIRCLE", 	 CIRCLE, 	REGION,		3, 3)
	call rg_install("ELLIPSE", 	 ELLIPSE, 	REGION,		5, 5)
	call rg_install("FIELD", 	 FIELD, 	REGION,		0, 0)
	call rg_install("PIE", 		 PIE, 		REGION,		4, -1)
	call rg_install("POINT", 	 POINT, 	REGION,		2, -1)
	call rg_install("POLYGON", 	 POLYGON, 	REGION,		6, -1)
	call rg_install("ROTBOX", 	 ROTBOX, 	REGION,		5, 5)

# Coordinate system commands.	John : Oct 89
#
	call rg_install("EQUATORIAL", 	 NONE, 	EQUATO,		0, 1)
	call rg_install("ECLIPTIC", 	 ECL, 	COORDS,		0, 1)
	call rg_install("GALACTIC", 	 GAL, 	COORDS,		0, 0)
	call rg_install("SUPERGALACTIC", SGL, 	COORDS,		0, 0)
#	call rg_install("EQUINOX", 	 NONE,	COORDS,		1, 1)

# Pixel system commands.	John : July 90
#
	call rg_install("PHYSICAL", 	 PHYS,	PIXSYS,		0, 0)
	call rg_install("LOGICAL", 	 LOGI,	PIXSYS,		0, 1)

# CONTOUR command.		Dennis, September 1992
	call rg_install("CONTOUR",	 CONTOUR, 	CLEVELS,	0, -1)

# Coordinate system from reference file.	Dennis, September 1992
	call rg_install("REFFILE", 	 REFFILE, 	REFFIL, 	1, 1)

end

#
# RG_INSTALL -- install a keyword into the lookup table
#
procedure rg_install(name, code, type, minargs, maxargs)

char name[ARB]				# i: keyword string
int code				# i: keyword code
int type				# i: keyword type (token)
int minargs				# i: min number of args for keyword
int maxargs				# i: max number of args for keyword

int len					# l: len of name
int strlen()				# l: string length

include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	# inc number of saved names
	rg_installed = rg_installed + 1
	# check for full name table
	if( rg_installed > MAX_RGKEYWORDS ){
	    call error(EA_FATAL, "region name and keyword table full")
	    return
	}
	# get length of name string
	len = strlen(name)
	# allocate a space for it
	call salloc(rg_names[rg_installed], len, TY_CHAR)
	# copy in the name
	call strcpy(name, Memc[rg_names[rg_installed]], len)
	# make it upper case
	call strupr(Memc[rg_names[rg_installed]])
	# and the keyword code and type (token)
	rg_codes[rg_installed] = code
	rg_ktype[rg_installed] = type
	# and the allowed numbers of args
	rg_minargs[rg_installed] = minargs
	rg_maxargs[rg_installed] = maxargs
end

#
# RG_RESET - reset parser and, if compiling, virtual CPU 
#            to process next command
#
procedure rg_reset(shortstrs)

pointer	shortstrs		# i: buffer for sequence of short strings 
				#    from rg_lbuf[], including multi region 
				#    dummy variables, keyword names or abbrevs,
				#    file names
include "regparse.com"

begin
	if (rg_compiling) {
	    # reset the "multiple slices" control structure
	    M_INST(rg_slices) = 0
	    M_ITER(rg_slices) = 1
	    # reset the "multiple annuli" control structure
	    M_INST(rg_annuli) = 0
	    M_ITER(rg_annuli) = 1
	    # clear the virtual CPU program
	    call amovki(0, rg_metacode, LEN_INST*MAX_INST)
	    # point the compiler to the first metacode instruction slot
	    rg_nextinst = 1
	    # anticipate immediate execution (i.e., an INCLUDE region)
	    rg_inclreg = YES
	}
	# set scratch string buffer pointer back to beginning
	rg_nextshortstr = shortstrs
end

#---------------------------------------------------------------------------
#	FUNCTIONS CALLED IN LEXICAL ANALYSIS (FROM RG_LEX())
#---------------------------------------------------------------------------

#
# RG_LOOKUP -- look for a given string in the keyword lookup table; 
#              if succeed, return YES and index into the table; else NO.
#              (Succeeds on first match or abbreviated match; doesn't 
#              require exact match or check for multiple matches.)
#
int procedure rg_lookup(s, kwi)

char	s[ARB]		# i: string to look up
int	kwi		# o: index of keyword in lookup table

char	t[SZ_LINE]	# l: string to match against
int	abbrev()	# l: match string routine

include "regparse.com"

begin
	# copy the string sought into buffer t[]
	call strcpy(s, t, SZ_LINE)
	# put it in upper case (table entries are all caps)
	call strupr(t)

	for (kwi = 1;  kwi <= rg_installed;  kwi = kwi + 1)
	    if (abbrev(Memc[rg_names[kwi]], t) > 0)
		return(YES)
	return(NO)
end

#
# RG_REFSPEC -- buffer potential reference image file spec; 
#               if it looks OK, return length in characters, else 0
#

define	START		0
define	NORMAL		1
define	BRACKET_OPEN	2
define	DONE		3
define	ERROR		-3

int procedure rg_refspec(inbuf, outbuf)

char	inbuf[ARB]		# i: buffer containing string with file spec
char	outbuf[ARB]		# o: buffer containing only file spec

int	state			# l: image file spec scan state
int	clos_bracket_count	# l: # ']'s in image file spec so far
int	buf_i			# l: index into inbuf[] and outbuf[]

begin
	state = START
	clos_bracket_count = 0
	buf_i = 1

	repeat {
	    switch (inbuf[buf_i]) {
		case '[':
		    if (state != START && state != BRACKET_OPEN &&
						clos_bracket_count < 2) {
			state = BRACKET_OPEN
		    } else {
			state = ERROR
		    }
		case ']':
		    if (state == BRACKET_OPEN) {
			clos_bracket_count = clos_bracket_count + 1
			state = NORMAL
		    } else {
			state = ERROR
		    }
		case ' ', '\t':
		    if (state == START) {
			state = ERROR
		    } else if (state != BRACKET_OPEN) {
			state = DONE
		    }
		case '\n', ';':
		    if (state == START || state == BRACKET_OPEN) {
			state = ERROR
		    } else {
			state = DONE
		    }
		default:
		    if (state == START) {
			state = NORMAL
		    } else if (clos_bracket_count >= 2) {
			state = DONE
		    }
	    }
	    if (state != ERROR && state != DONE) {
		if (buf_i <= SZ_PATHNAME) {
		    outbuf[buf_i] = inbuf[buf_i]
		    buf_i = buf_i + 1
		} else {
		    state = ERROR
		}
	    }
	} until (state == ERROR || state == DONE)

	if (state == ERROR) {
	    return (0)
	}

	outbuf[buf_i] = EOS

	return (buf_i - 1)
end

#
# RG_ISFILE -- determine if a string is the name of an existing file
#

int procedure rg_isfile(s)

char s[ARB]			# i: string

char t[SZ_PATHNAME]		# l: string + extension
bool got			# l: access flag
bool access()			# l: check for file existence

include "regparse.com"

begin
	# first check the string as is
	got = access(s, 0, 0)
	if( got )
	    return(YES)
	else{
	    # then add an extension and try again
	    call strcpy(s, t, SZ_PATHNAME)
	    call strcat(REGEXT, t, SZ_PATHNAME)
	    got = access(t, 0, 0)
	    if( got )
		return(YES)
	    else
		return(NO)
	}
end

#
# RG_ISN -- determine if we have "n=<num>" syntax
#

int procedure rg_isn(s, lbuf)

char s[ARB]			# i: string
char lbuf[ARB]			# i: line buffer

int  lptr			# l: line buffer pointer
int strlen()			# l: string length

include "regparse.com"

begin
	# we are looking for "<alpha>="
	if( (strlen(s) ==1) && (IS_ALPHA(s[1])) ){
	    # skip white space
	    lptr = 1
	    # skip over white space
	    while(IS_WHITE (lbuf[lptr]))
		lptr = lptr + 1
	    # must have an "=" sign
	    if(lbuf[lptr] == '=')
		return(YES)
	    else
		return(NO)
	}
	else
	    return(NO)
end

#
# RG_ADDPAREN -- put a paren into the expanded descriptor line buffer
#
procedure rg_addparen(par)

char	par[ARB]			# l: paren string
int	len				# l: length of string so far
int	strlen()			# l: string length
bool	streq()				# l: string compare
include "regparse.com"

begin
	if (RGPARSE_OPT(EXPDESC, rg_parsing) == NULL)
	    return

	# get rid of last space (if any) before a close paren
	if( streq(")", par) ){
	    len = strlen(EXPDESCLBUF(rg_parsing))
	    if( Memc[EXPDESCLPTR(rg_parsing)+len-1] == ' ')
		Memc[EXPDESCLPTR(rg_parsing)+len-1] = EOS
	}
	# add the paren		### [add check that it's a paren]
	call strcat(par, EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
end

#
# RG_ADDOP -- append a boolean operator string to expanded descriptor 
#             line buffer
#
procedure rg_addop(s)

char	s[ARB]			# i: op string to add
int	len			# l: string length
int	strlen()		# l: get string length
bool	strne()			# l: string compare

include "regparse.com"

begin
	if (RGPARSE_OPT(EXPDESC, rg_parsing) == NULL)
	    return

	# null out last comma (if any) before binary op
	if( strne(s, "!" ) ){
	    call rg_nullcomma()
	}
	# make sure there is a space at end
	len = strlen(EXPDESCLBUF(rg_parsing))
	if( Memc[EXPDESCLPTR(rg_parsing)+len-1] != ' ')
	    call strcat(" ", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
	# add the operator
	call strcat(s, EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
	# follow a binary op with a space
	if( strne(s, "!" ) ){
	    call strcat(" ", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
	}
end

#---------------------------------------------------------------------------
#	FUNCTIONS CALLED FROM RG_YYPARSE() (I.E., FROM XYACC GRAMMAR)
#---------------------------------------------------------------------------

#
# RG_NEWREGFILE -- reducing REGFIL token to "regfil" symbol, open the new 
#                  region descriptor file, make it the current one, and push 
#                  its handle onto the stack
#
procedure rg_newregfile(a)

pointer a			# i: pointer to the semantic value structure 
				#    associated with the REGFIL token

include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	call rg_pushfd(O_FNBUF(a))

	# (It is not necessary to return anything in yyval)
end

#
# RG_PUSHFD --	open a new region descriptor file, make it the current one, 
#               and push its handle onto the stack
#
procedure rg_pushfd(fname)

char fname[ARB]			# i: file name to open

char tname[SZ_PATHNAME]		# l: in case we add the extension
int open()			# l: open a file

char	ebuf[SZ_2PATHNAMESPLUS]

include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	# inc the number of fd's we have nested
	rg_fdlev = rg_fdlev + 1

	# check for overflow
	if( rg_fdlev >= MAX_NESTS ){
	    call error(EA_FATAL, 
			"nested region descriptor file stack overflow")
	    return
	}

	# convert to lower case
#	call strlwr(fname)
	# open the new file
	iferr( rg_fds[rg_fdlev] = open(fname, READ_ONLY, TEXT_FILE) ){
	    call strcpy(fname, tname, SZ_PATHNAME)
	    call strcat(REGEXT, tname, SZ_PATHNAME)

	    iferr( rg_fds[rg_fdlev] = open(tname, READ_ONLY, TEXT_FILE) ){
		call sprintf(ebuf, SZ_2PATHNAMESPLUS,
			"can't find region file %s or %s")
		call pargstr(fname)
		call pargstr(tname)
		call error(1, ebuf)
	    }
	}
	# and make it the current fd (for next read)
	rg_fd = rg_fds[rg_fdlev]
end

#
# RG_POPFD -- close the current region descriptor file, pop its handle from 
#             the stack, and make the one now on top of the stack (the one 
#             that called the one now closing) current again
#
procedure rg_popfd()

include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	# close the current file
	call close(rg_fd)
	# dec the number of fd's we have nested
	rg_fdlev = rg_fdlev - 1
	# level <= 0 - underflow
	if( rg_fdlev <= 0 ){
	    call error(EA_FATAL, 
			"nested region descriptor file stack underflow")
	    return
	}
	# level > 0 - restore previous fd
	else
	    rg_fd = rg_fds[rg_fdlev]
end

#
# RG_SETCOORD --
#
procedure rg_setcoord(x)
int x					# i: set coordinate system to x

include "regparse.com"
include "rgwcs.com"

begin
	if ( ! rg_coording )
	    return

	if ( rg_imsystem == NONE ) 
	 call error(1, "Attempt to set coordinates without image reference")

	rg_system = x
end

#
# RG_SETEQUIX --
#
procedure rg_setequix(x)
real x

include "regparse.com"
include "rgwcs.com"

begin
	if ( ! rg_coording )
	    return

	if ( rg_imsystem == NONE ) 
	 call error(1, "Attempt to set coordinates without image reference")

	rg_equix = x
end

#
# RG_SETPIXSYS --
#
procedure rg_setpixsys(a)
pointer	a		# i: ptr to PIXSYS token's semantic value structure

int	pixcode		# l: this PIXSYS token's keyword code: PHYS or LOGI

include "regparse.com"
include "rgwcs.com"

begin
	if ( ! rg_coording )
	    return

	pixcode = rg_codes[O_VALI(a)]

	if (pixcode != PHYS && rg_imsystem == NONE)
	    call error(EA_FATAL, 
			"Can't interpret logical pixels without target image")

	rg_pixsys = pixcode

	if (rg_pixsys == LOGI && O_FNPTR(a) != NULL) {
	    call rg_reffil(a)
	}
end

#
# RG_REFFIL -- Get coordinate system from a reference file
#
procedure rg_reffil(a)

pointer	a	# i: ptr to PIXSYS or REFFIL token's semantic value structure

pointer	sp		# l: stack pointer
pointer	img_fname	# l: image file spec (no section) buffer
			#   (This can be local unless we add a check that 
			#    a new spec is a change from the preceding one)
pointer	refim		# l: reference file pointer

pointer	immap()		#  : open image file
pointer	mw_openim()	#  : open mwcs descriptor on image file
pointer	mw_sctran()	#  : set up coordinate transformation structure
errchk	immap, mw_openim, mw_sctran	# interrupt and pass errors back up

include "regparse.com"
include "rgwcs.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	if ( ! rg_coording )
	    return

	# if there's no file spec, return
	if( O_FNPTR(a) == NULL ) return

	if (rg_ref_active) {
	    # (Unless we add a check that this is a new spec,)
	    # free structs related to previous .reg-specified reference file
	    call mw_close(rg_refimw)
	}

	call smark (sp)
	call salloc (img_fname, SZ_PATHNAME, TY_CHAR)

	# O_FNBUF(a) is file spec string

	# Strip off image section info, if any
	call imgimage(O_FNBUF(a), Memc[img_fname], SZ_PATHNAME)

	# Develop image file name [Is this necessary?]
	call rootname ("", Memc[img_fname],"", SZ_PATHNAME)

	### (Check that this is the right file, else error.)

	# Open image file
	refim = immap (Memc[img_fname], READ_ONLY, 0)

	# Open MWCS descriptor on image
	rg_refimw = mw_openim(refim)

	# Set up coordinate transformation
	rg_refctpix = mw_sctran(rg_refimw, "logical", "physical", 0)

	rg_ref_active = true

	call imunmap(refim)
	call sfree(sp)
end

#
# RG_STARTARGLIST -- reducing first NUMERAL token following a shape keyword 
#                    to "arglist" symbol, buffer this first argument's 
#                    value and type in rg_args[1] and rg_types[1]; or, 
#                    reducing "REGION" (with no args) to "reg" symbol, 
#                    reset rg_nargs.
#
procedure rg_startarglist(a, type)

pointer a		# i: NUMERAL token value structure
int type		# i: type of argument: TY_REAL, TY_PIX, 
			#    TY_HMS, TY_DEG, TY_MIN, TY_SEC, TY_RAD

include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	if( ! rg_compiling )
	    return

	if( a != NULL ){
	    # start the arg list with the NUMERAL token's value and type
	    rg_nargs = 1
	    rg_args[1] = O_VALR(a)
	    rg_types[1] = type
	}
	else
	    # no args for this shape
	    rg_nargs = 0

	# (No need to put anything in yyval structure)
end

#
# RG_ADDARG -- reducing "arglist opcomma opnl [ID '='] NUMERAL" sequence 
#              to "arglist" symbol, buffer the new argument's value and 
#              type as new last elements of rg_args[] and rg_types[]
#
procedure rg_addarg(a, type)

pointer a		# i: new arg's NUMERAL token value structure
int type		# i: type of argument: as for rg_startarglist(), but 
			#    may also be TY_INC (for accelerator count)

include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	if( ! rg_compiling )
	    return

	# add 1 to number of args
	rg_nargs = rg_nargs + 1
	# check against max
	if( rg_nargs > MAX_ARGS ){
	    call error(EA_FATAL, "too many arguments for shape")
	    return
	}
	# extend the arg list with the new NUMERAL token's value and type
	rg_args[rg_nargs] = O_VALR(a)
	rg_types[rg_nargs] = type

	# (No need to put anything in yyval structure)
end

#
# RG_REGION -- reducing "REGION ['('] arglist [')']" sequence to "reg" symbol:
#			check for valid argument count;
#			convert arguments to logical pixels [and degrees];
#			expand accelerators into 4-arg sets;
#			move processed args to dynamically-allocated array 
#				(freeing rg_args[], rg_types[] for next shape);
#			point reg structure to the processed arg list;
#                       assign reg structure pointer as "reg" symbol's 
#                       	semantic value.
#
procedure rg_region(kwi, yyval)

int	kwi		# i: index into keyword table, for this shape name
pointer	yyval		# i: pointer to semantic value struct for "reg" symbol
			# o: O_REG(yyval): pointer to reg structure 
			#    containing the spec of the simple region(s)
			# o: R_CODE(O_REG(yyval)): shape name code
			# o: R_ARGC(O_REG(yyval)): number of args
			# o: R_ARGV(O_REG(yyval)): ptr to processed arg list
			# o: R_TYPE(O_REG(yyval)): TY_REGION | 
			#				TY_SLICES | TY_ANNULI

int	i, j		# l: counters
int	n		# l: multiple region count (from 'n=<num>')
int	type		# l: type of reg (R_TYPE(O_REG(yyval))): TY_REGION, 
			#    TY_SLICES, or TY_ANNULI
int	nargs		# l: initially, number of args in region spec; 
			#    after expansion of accelerators, total number of 
			#    args for all regions defined in spec
int	code		# l: shape name code
real	args[MAX_ARGS]	# l: array in which to buffer list of all args (after 
			#    expansion of accelerators), converted to 
			#    logical pixels (or degrees, for pie angles)
real	inc		# l: inc between args on expansion of 'n=<num>'
pointer	argv		# l: pointer to dynamic array into which args[] array 
			#    is finally copied
real	inner, outer	# l: annuli/pie slice temporaries
pointer	reg		# i: pointer to reg structure (see above, under yyval, 
			#    for descriptions of the fields)

int 	rg_ckcount()	# l: check argument counts


include "regparse.com"

# Argument packaging rewritten John : Oct 89
#
begin
	if( rg_eflag == YES ) return	# if we had an error earlier, cop-out

	if( ! rg_compiling )  {
	    O_REG(yyval) = NULL
	    return
	}

	code = rg_codes[kwi]			# shape name code
	nargs = rg_nargs			# get number of args

	type = TY_REGION			# We will output a region 
						# unless overridden later 

	if ( rg_ckcount(nargs, kwi)>0 ) return	# Preliminary arg count check.

	# The argumentation of each region type must be explicitly handled
	#
	switch ( code ) {
	case FIELD :					# No arguments !

	case BOX, CIRCLE, ELLIPSE, ROTBOX : 
	    call rg_coords(rg_args[1], rg_types[1], rg_args[2], rg_types[2],
		           args[1], args[2])

	    switch ( nargs ) {
	    case 3:				# This must be a Circle
		call rg_ansize(rg_args[3], rg_types[3], 0.0, TY_DEG, args[3])
		if ( args[3] <= 0.0 )
		    call error(EA_FATAL, "Circle cannot have radius <= 0")

	    case 4:				# This is a Box
		call rg_ansize(rg_args[3], rg_types[3], 0.0, TY_DEG, args[3])
		call rg_ansize(rg_args[4], rg_types[4], 0.0, TY_DEG, args[4])
		if ( args[3] <= 0.0 || args[4] <= 0.0 )
		    call error(EA_FATAL, "Box may not have side of size <= 0")

	    case 5:				# This is an Ellipse or RotBox
		if ( code == BOX )    code = ROTBOX

		call rg_ansize(rg_args[3], rg_types[3], 
			       rg_args[5], rg_types[5], args[3])
		call rg_ansize(rg_args[4], rg_types[4], 
			       rg_args[5], rg_types[5], args[4])

		if ( args[3] <= 0.0 || args[4] <= 0.0 )
		    call error(EA_FATAL, "Box or ellipse may not have dimension of size <= 0")

		call rg_xtodeg(rg_args[5], rg_types[5], args[5])
	    }
	case ANNULUS, PIE :
	    # Do the first 4 arguments, these must be A(x, y, inner, outer)
	    #
	    call rg_coords(rg_args[1], rg_types[1], rg_args[2], rg_types[2],
		      	   args[1], args[2])

	    # Pie takes angle, Annulus takes pixel radius
	    #
	    if ( code == PIE ) { 
		call rg_xtodeg(rg_args[3], rg_types[3], args[3])
		call rg_xtodeg(rg_args[4], rg_types[4], args[4])
	    } else {
		call rg_ansize(rg_args[3], rg_types[3], 0.0, TY_DEG, args[3])
		call rg_ansize(rg_args[4], rg_types[4], 0.0, TY_DEG, args[4])
	    }

	    if ( nargs > 4 ) { 
		# Accelerator (multi) of some kind.
		# Expand into complete 4-argument sets.
	    	#
	    	if ( code == PIE ) type = TY_SLICES
		else		   type = TY_ANNULI

		i = 5
	        for ( j = 5; j <= nargs; j = j + 1 ) {

		    if ( rg_types[j] == TY_INC ) {	# "n = #" accelerator

		        # make sure we progress counter-clockwise
		        #
		        if ( ( code == PIE ) && ( args[i-1] < args[i-2] ) )
			    args[i-1] = args[i-1] + 360.0

		        # calculate the inc between args
		        #
		        inner = args[i-2]
		        inc = ( args[i-1] - args[i-2] ) / rg_args[j]

		        # that last slice or annulus wasn't really one, it 
			# was the vertex or center and the limits of a 
			# contiguous set of slices or annuli; so back up over 
			# it to start writing the members of the set
		        #
			i = i - 4
		        for ( n = int(rg_args[j]); n > 0; n = n - 1 ) {
			    if ( rg_ckcount(i + 3, kwi)>0 ) return # check count

			    outer = inner + inc

			    # roll pie slices over at 360 degrees
			    #
			    if ( ( code == PIE ) && ( outer > 360.0 ) )
			        outer = outer - 360.0

			    args[i]   = args[1]		# copy centers
			    args[i+1] = args[2]
			    args[i+2] = inner 		# Inner-Outer radii
			    args[i+3] = inner + inc

			    inner = inner + inc
			    i = i + 4
		        }
		    } else {	# Not "n = #", but new ending angle or radius
		        if ( rg_ckcount(i + 3, kwi)>0 ) return	# check count

		        args[i]   = args[1]			# copy centers
		        args[i+1] = args[2]
			args[i+2] = args[i-1]			# inner

		        # Pie takes angle, Annulus takes pixel radius
		        #
	    	        if ( code == PIE )
			    call rg_xtodeg(rg_args[j], rg_types[j], args[i+3])
		        else
			    call rg_ansize(rg_args[j], rg_types[j], 
				           0.0, TY_DEG, args[i+3])
 
		        i = i + 4			# Created 4 arguments
		    }
	        }
	        nargs = i - 1
	    }

	case POINT, POLYGON :
	    # Convert a paired list of coordinates
	    #
	    for ( j = 1; j <= nargs; j = j + 2 ) {
		if ( j == nargs ) {
		    call error(EA_FATAL, "Coordinates of points not paired")
		    return;
	    	}

		call rg_coords(rg_args[j], rg_types[j], 
			       rg_args[j+1], rg_types[j+1], args[j], args[j+1])
	    }
	}

	call rg_salloc_reg(reg)		# allocate reg structure
	R_CODE(reg) = code
	R_ARGC(reg) = nargs
	if (nargs > 0) {
	    call salloc(argv, nargs, TY_REAL)		# Get & Copy the argv
	    call amovr(args, Memr[argv], nargs)
	    R_ARGV(reg) = argv
	} else 
	    R_ARGV(reg) = NULL
	R_TYPE(reg) = type

	O_REG(yyval) = reg	# return pointer to reg structure in 
				#  "reg" symbol's semantic value structure
end

#
# RG_CKCOUNT -- check arg count for region
#
int procedure rg_ckcount(nargs, kwi)

int	nargs		# i: number of arguments
int	kwi		# i: index into keyword table, for the shape

int	minargs		# l: minimun number of allowed arguments
int	maxargs		# l: maximum number of allowed arguments
char	ebuf[SZ_LINE]	# l: error message buffer

include "regparse.com"

begin

	minargs = rg_minargs[kwi]
	maxargs = rg_maxargs[kwi]
	if( maxargs == -1 )
	    maxargs = MAX_ARGS
	if( ( nargs < minargs ) || ( nargs > maxargs ) ){
	    call sprintf(ebuf, SZ_LINE,
		"argument count (%d) out of range (%d,%d) for type %s")
	    call pargi(nargs)
	    call pargi(minargs)
	    call pargi(maxargs)
	    call pargstr(Memc[rg_names[kwi]])
	    call error(1, ebuf)
	    return( 1 )
	}

	return 0
end

#
# RG_COORDS -- Take Sky coordinates and return pixels
#
procedure rg_coords(value1, type1, value2, type2, xpix, ypix)

real	value1		# i: value on axis 1
int	type1		# i: unit type of axis 1
real	value2		# i: value on axis 2
int	type2		# i: unit type of axis 2
real	xpix		# o: x axis image position
real	ypix 		# o: y axis image position
#--
#

real	v1rdeg		# l: value on axis 1, in degrees (or pixels)
real	v2rdeg		# l: value on axis 2, in degrees (or pixels)

double	v1		# l: value on axis 1, in degrees (or pixels)
double	v2		# l: value on axis 2, in degrees (or pixels)

double	v1ph		# l: value on axis 1, in physical pixels
double	v2ph		# l: value on axis 2, in physical pixels

double	v1prec		# l: value on axis 1, precessed to match image
double	v2prec		# l: value on axis 2, precessed to match image

double	v1mw		# l: value on axis 1, MWCS-transformed
double	v2mw		# l: value on axis 2, MWCS-transformed

int	sw_type

include "regparse.com"
include "rgwcs.com"

begin
	sw_type = rg_system

	if ( type1 == TY_HMS ) type2 = TY_DEG			# HMS DMS

	call rg_xtodeg(value1, type1, v1rdeg)	# Get degrees or keep pixels
	call rg_xtodeg(value2, type2, v2rdeg)
 
	v1 = v1rdeg				# Cast up
	v2 = v2rdeg

	if ( ( type1 == TY_REAL ) || ( type1 == TY_PIX ) &&	# Pixels
	     ( type2 == TY_REAL ) || ( type2 == TY_PIX )   )

		switch ( rg_pixsys ) {
		 case PHYS:
			call mw_c2trand(rg_ctpix, v1, v2, v1mw, v2mw)
		 default:
			if (rg_ref_active) {
			    call mw_c2trand (rg_refctpix, v1, v2, v1ph, v2ph)
			    call mw_c2trand (rg_ctpix, v1ph, v2ph, v1mw, v2mw)
			} else {
			    v1mw = v1
			    v2mw = v2
			}
		}
	else {							# Degrees
		if ( rg_imsystem == NONE ) 
	 	 call error(1, "Attempt to convert coordinates without image reference")

		# Precess the input into the same Sky system as the image
		#
		call precess(v1, v2, rg_system,   rg_equix,   rg_epoch,
			     v1prec, v2prec, rg_imsystem, rg_imequix, 
			     rg_imepoch, 0) 

		# Get pixels from MWCS
		#
		call mw_c2trand(rg_ctwcs, v1prec, v2prec, v1mw, v2mw)
	}

	xpix = v1mw
	ypix = v2mw
end

#
# RG_ANSIZE -- take a Sky angle (extent) and return pixels
#
procedure rg_ansize(angle, atype, rot, rottype, pixels)

real angle		# i: Sky angle (extent) to convert
int  atype		# i: unit type in angle
real rot		# i: possible rotation in image system
int  rottype		# i: unit type of rotation spec
real pixels		# o: size of angle in image pixels

real p_pixels		# l: size of angle in physical pixels
real angledeg		# l: sky angle in degrees (or pixels)
real rotdeg		# l: rotation (in image system) in degrees
real rotrad		# l: rotation (in image system) in radians

real mw_c1tranr()

include "rgwcs.com"
include "regparse.com"

begin

	if ( ( atype == TY_REAL ) || ( atype == TY_PIX ) )	# Pixels
		switch ( rg_pixsys ) {
		 case PHYS:
			pixels = abs(mw_c1tranr(rg_ctpix, angle) - 
			             mw_c1tranr(rg_ctpix, 0.   )   )
		 default:
			if (rg_ref_active) {
			    p_pixels = mw_c1tranr(rg_refctpix, angle) - 
			               mw_c1tranr(rg_refctpix, 0.   )
			    pixels   = abs(mw_c1tranr(rg_ctpix, p_pixels) -
			                   mw_c1tranr(rg_ctpix, 0.      )   )
			} else {
			    pixels = angle
			}
		}
	else {							# Angular units
		call rg_xtodeg(angle, atype, angledeg)
		call rg_xtodeg(rot, rottype, rotdeg)

		rotrad   = DEGTORAD(rotdeg)
		pixels = sqrt((cos(rotrad) * angledeg / QP_CDELT1(rg_imh))**2 +
		              (sin(rotrad) * angledeg / QP_CDELT2(rg_imh))**2 )
	}
end



define MINTODEG		( ($1) /   60 )
define SECTODEG		( ($1) / ( 60  * 60 ) )
define HRSTODEG		( ($1) * ( 360 / 24 ) )

#
# RG_XTODEG  -- Convert an angle of the spec'ed type to Degrees
#
# Types :
#	TY_DEG	- Degrees
#	TY_MIN	- Minutes
#	TY_SEC  - Seconds
#	TY_HMS	- Hours
#	TY_RAD	- Radians
#
# All other types are rejected
#
procedure rg_xtodeg(angle, atype, degrees)

real angle
int  atype
real degrees

begin

	switch ( atype ) {
	case TY_DEG, TY_REAL, TY_PIX :
		degrees = angle
	case TY_MIN :
		degrees = MINTODEG(angle)
	case TY_SEC :
		degrees = SECTODEG(angle)
	case TY_HMS :
		degrees = HRSTODEG(angle)
	case TY_RAD :
		degrees = RADTODEG(angle)
	default:
		call error(1, "Bad type in rg_xtodeg")	
	}
end

#
# RG_SALLOC_REG -- allocate new reg structure on stack
#
procedure rg_salloc_reg(reg)

pointer reg			# o: pointer to new reg structure

begin
	call salloc(reg, LEN_REG, TY_STRUCT)
end

#
# RG_NEWOP -- reducing "reg" symbol to "expr" symbol, set up virtual CPU 
#             instruction to create a new temp mask containing the region 
#             defined in the reg structure; if it's a multiple region, 
#             also set up the rg_annuli or rg_slices control structure
#
procedure rg_newop(a)

pointer	a		# i: pointer to reg structure, containing spec of a 
			#    simple region or multi
include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	if( ! rg_compiling )
	    return

	# see if we have a multiple region here
	switch(R_TYPE(a)){
	case TY_ANNULI:
	    # set up multiple regions for annulus
	    if( M_INST(rg_annuli) ==0 ){
		# there are 4 arguments for each annulus
		M_INC(rg_annuli) = 4
		# giving this many iterations (separate plio indexes)
		M_ITER(rg_annuli) = R_ARGC(a)/M_INC(rg_annuli)
		# reset arg count
		R_ARGC(a) = M_INC(rg_annuli)                               
		# save base of argv
		M_BASE(rg_annuli) = R_ARGV(a)		
		# and instruction whose argv pointer gets varied
		M_INST(rg_annuli) = rg_nextinst
	    }
	    else{
		call error(1, "only 1 multiple annulus per expression allowed")
		return
	    }
	case TY_SLICES:
	    # set up multiple pie slices
	    if( M_INST(rg_slices) ==0 ){
		# there are 4 arguments for each slice
		M_INC(rg_slices) = 4
		# giving this many iterations (separate plio indexes)
		M_ITER(rg_slices) = R_ARGC(a)/M_INC(rg_slices)
		# reset arg count
		R_ARGC(a) = M_INC(rg_slices)
		# save base of argv
		M_BASE(rg_slices) = R_ARGV(a)		
		# and instruction whose argv pointer gets varied
		M_INST(rg_slices) = rg_nextinst
	    }
	    else{
		call error(1, "only 1 multiple slice per expression allowed")
		return
	    }
	case TY_REGION:
	    ;
	default:
	    call error(1, "unknown region/multi type")
	    return
	}
	# set up virtual CPU instruction to create new temp mask for reg
	call rg_compile1(OP_NEW, a)

	# It is not necessary to send any value back to yyval; no semantic 
	# value of an expr need be passed on the parser stack; it's all in 
	# the temp mask stack structure at run time.
end

#
# RG_UNOP -- reducing "'!' expr" sequence to "expr" symbol, set up virtual CPU 
#            instruction to invert the temp mask's pixels
#
procedure rg_unop ()

include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	if( ! rg_compiling )
	    return

	# set up virtual CPU instruction to invert mask pixels
	call rg_compile0(OP_UNSET)

	# It is not necessary to send any value back to yyval; no semantic 
	# value of an expr need be passed on the parser stack; it's all in 
	# the temp mask stack structure at run time.
end

#
# RG_BINOP -- reducing "expr <'&' | '|' | '^'> opnl expr" sequence to "expr" 
#             symbol, set up virtual CPU instruction to combine (using the 
#             boolean op) the two temp masks into a resultant temp mask
#
procedure rg_binop (op)

int op			# i: OP_AND ('&'), OP_OR ('|'), or OP_XOR ('^')
include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	if( ! rg_compiling )
	    return

	# set up virtual CPU instruction to combine the 2 temp masks 
	#	using the specified op
	call rg_compile1(OP_MERGE, op)

	# It is not necessary to send any value back to yyval; no semantic 
	# value of an expr need be passed on the parser stack; it's all in 
	# the temp mask stack structure at run time.
end

#
# RG_EXCLINCL -- reducing "iflag expr" sequence to "flgexpr" symbol:
#                if iflag is '-', reset rg_inclreg, to defer execution of the 
#                virtual CPU program, as expr is an EXCLUDE region
#
procedure rg_exclincl(incl)

int	incl		# i: include flag (EXCLUDE or INCLUDE)

include "regparse.com"

begin
	if( rg_eflag == YES ) return	# if we had an error earlier, return

	if( ! rg_compiling )
	    return

	if( incl == EXCLUDE )
	    rg_inclreg = NO		# reset immediate execution flag
end

#
# RG_ENDEXPR -- reducing "[flg]expr eost" sequence to "command" symbol, set up 
#               virtual CPU instructions to flush the temp mask to the 
#               cumulative mask and end that pass of virtual CPU execution; 
#               if OBJLIST selected, save all the virtual CPU control info 
#               for this command in a new object structure
#
procedure rg_endexpr()

pointer	obj				# l: pointer to new object structure, 
					#     filled with this command's info 
					#     and appended to object list
int	ninsts				# l: number of instructions in program
int	vpc				# l: virtual CPU program counter
pointer	tempreg				# l: reg struct on stack, being copied
pointer	keptreg				# l: kept copy of reg struct
int	argc				# l: arg count in reg struct

pointer	rg_alloc_obj()			#  : alloc & init a new object struct

include "regparse.com"

begin
	# if we had an error earlier, just return
	if( rg_eflag == YES ) return

	if (rg_compiling) {
	    # set up virtual CPU instructions to flush temp mask to 
	    # cumulative mask and end that pass through the program
	    if( rg_nextinst != 1 ){
		call rg_compile0(OP_FLUSH)
		call rg_compile0(OP_RTN)
	    }
	}

	if (RGPARSE_OPT(OBJLIST, rg_parsing) != NULL) {
	    # create a new object structure, appended to the list of objects
	    obj = rg_alloc_obj(rg_parsing)

	    # include region or exclude region?
	    V_INCL(obj)           = rg_inclreg

	    # multi region control structures
	    M_ITER(V_SLICES(obj)) = M_ITER(rg_slices)
	    M_INST(V_SLICES(obj)) = M_INST(rg_slices)
	    M_BASE(V_SLICES(obj)) = M_BASE(rg_slices)
	    M_INC(V_SLICES(obj))  = M_INC(rg_slices)
	    M_ITER(V_ANNULI(obj)) = M_ITER(rg_annuli)
	    M_INST(V_ANNULI(obj)) = M_INST(rg_annuli)
	    M_BASE(V_ANNULI(obj)) = M_BASE(rg_annuli)
	    M_INC(V_ANNULI(obj))  = M_INC(rg_annuli)

	    # the virtual CPU program
	    ninsts = rg_nextinst - 1
	    V_NINSTS(obj)         = ninsts
	    call malloc(V_METAPTR(obj), ninsts*LEN_INST*SZ_INT, TY_INT)

	    # save each instruction and any associated data
	    for (vpc = 1;  vpc <= ninsts;  vpc = vpc + 1) {

		# the instruction
		V_INST(vpc, obj) = INST(vpc)

		# if it has a reg structure attached ...
		if (INST(vpc) == OP_NEW) {

		    # ... allocate space for it and fill it
		    call malloc(keptreg, LEN_REG, TY_STRUCT)
		    tempreg = ARG1(vpc)
		    R_CODE(keptreg) = R_CODE(tempreg)
		    argc = R_ARGC(tempreg)
		    R_ARGC(keptreg) = argc

		    # if it has an arg list ...
		    if (argc > 0) {
			# ... allocate space for it and copy in the args
			call malloc(R_ARGV(keptreg), argc, TY_REAL)
			call amovr(Memr[R_ARGV(tempreg)], 
					Memr[R_ARGV(keptreg)], argc)
		    } else
			R_ARGV(keptreg) = NULL

		    R_TYPE(keptreg) = R_TYPE(tempreg)
		    V_ARG1(vpc, obj) = keptreg
		} else
		    V_ARG1(vpc, obj) = ARG1(vpc)
	    }
	}

	if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
	    # save the expression in the region string
	    call rg_saveexpr()

	# It is not necessary to send any value back to yyval, as 
	# "command" is the start symbol
end

#
# RG_SAVEEXPR - append the command string in the expanded descriptor 
#               line buffer to the list of command strings in 
#               EXPDESCBUF(rg_parsing)
#
procedure rg_saveexpr()

int strlen()			# l: string length
include "regparse.com"

begin
	if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL) {
	    if( strlen(EXPDESCLBUF(rg_parsing)) != 0 ){
		call rg_nullcomma()
		# end the command
		call strcat("\n", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
		# append the command to the command list
		call rg_summaryadd (EXPDESCLBUF(rg_parsing), 
					EXPDESCPTR(rg_parsing))
		# reset expanded descriptor line buffer to receive the 
		#  next command
		call strcpy("", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
	    }
	}
end

#
# RG_NULLCOMMA - null out last comma in expanded descriptor line buffer
#
procedure rg_nullcomma()

int index			# i: index into string
int strldx()			# l: string index
include "regparse.com"

begin
	if (RGPARSE_OPT(EXPDESC, rg_parsing) == NULL)
	    return

	# change final comma to a space
	index = strldx(",", EXPDESCLBUF(rg_parsing))
	if( index !=0 )
	    Memc[(EXPDESCLPTR(rg_parsing)+index-1)] = ' '
end

#---------------------------------------------------------------------------
#	DEBUGGING FUNCTIONS
#---------------------------------------------------------------------------

#
# RGDISP -- this is a debugging procedure for dbx
#
int procedure rgdisp()
include "regparse.com"
begin
	call printf("lbuf=%s; lptr=%d\n")
	call pargstr(rg_lbuf)
	call pargi(rg_lptr)
#	call printf("sbuf=%s; sbuf=%d; nextch=%d\n")
#	call pargstr(Memc[rg_sbuf])
#	call pargi(rg_sbuf)
#	call pargi(rg_nextshortstr)
	call printf("fd=%d; fdlev=%d\n")
	call pargi(rg_fd)
	call pargi(rg_fdlev)
	if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL) {
	    call printf("cur cmd=%s; all cmds=%s\n")
	    call pargstr(EXPDESCLBUF(rg_parsing))
	    call pargstr(EXPDESCBUF(rg_parsing))
	}
	return(1)
end

#---------------------------------------------------------------------------
#	UNUSED FUNCTIONS
#---------------------------------------------------------------------------

# Note:  rg_lookup() now uses abbrev() instead of rg_abbrev()
#
# RG_ABBREV -- look for a pattern match of a string from the beginning
# of another string, i.e., is one string an abbrev of another?
# NB: returns the first string that matches
#
int procedure rg_abbrev(s, t)

char s[ARB]				# i: reference keyword in table
char t[ARB]				# i: instance of keyword or abbrev

int i					# l: string offset

begin
	if (t[1] == EOS)
	    return(0)		# empty string has no match
	i = 1
	# look for an (abbreviated) match
	while( t[i] != EOS ){
	    if( s[i] != t[i] )
		return(0)
	    i = i+1
	}
	# check for exact match
	if( s[i] == EOS )
	    return(2)
	# otherwise its an abbreviation
	else
	    return(1)
end

#
# RG_GNAME -- get the name of a region from the code number
#
procedure rg_gname(code, name)

int code				# i: region code
pointer name				# o: region name

int i					# l: loop counter

include "regparse.com"

begin
	# loop through region codes, looking for a match
	for(i=1; i<=rg_installed; i=i+1){
	    if( code == rg_codes[i] ){
		name = rg_names[i]
		return
	    }
	}
	call salloc(name, 10, TY_CHAR)
	call strcpy("UNKNOWN", Memc[name], 10)
end

#
# RG_GOP -- get the name of an op
#
procedure rg_gop(code, op)

int code				# i: op code
pointer op				# o: op symbol (string)

int i					# l: loop counter

include "regparse.com"

begin
	i = 2
	call salloc(op, i, TY_CHAR)
	if( code == OP_NOT )
		call strcpy("!", Memc[op], i)
	else if( code == OP_AND )
		call strcpy("&", Memc[op], i)
	else if( code == OP_OR )
		call strcpy("|", Memc[op], i)
	else if( code == OP_XOR )
		call strcpy("^", Memc[op], i)
	else
		call strcpy("UNKNOWN", Memc[op], i)
end
