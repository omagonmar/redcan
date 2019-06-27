#$Header: /home/pros/xray/ximages/qphedit/RCS/ximio.x,v 11.0 1997/11/06 16:28:41 prosb Exp $
#$Log: ximio.x,v $
#Revision 11.0  1997/11/06 16:28:41  prosb
#General Release 2.5
#
#Revision 9.2  1997/08/07 18:14:05  prosb
#JCC(8/7/97) - xqppstr: print out param and comment from qp_queryf.
#
#Revision 9.0  1995/11/16  18:34:51  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:27:05  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  17:09:13  mo
#MC	12/22/93	Update for qpx_addf call and for
#			proper use of BOOLEAN keywords
#			(match hedit behavior)
#
#Revision 6.1  93/12/03  13:04:41  mo
#MC	12/3/93		Fix BOOLEAN edit case (yes=T/no=F)
#
#Revision 6.0  93/05/24  16:07:50  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:27:20  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:30:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:41  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:28:00  pros
#General Release 1.0
#
#
# XIM routines - call the corresponding qpoe or imh routine
#
include <lexnum.h>
include	<evexpr.h>
include	<ctype.h>

#  ximmap -- open an image or qpoe file
int procedure ximmap (name, mode, len)
char	name[ARB]			# i: file name
int	mode				# i: open mode
int	len				# i: user area len for imh
int	qp_open(), immap()
include "qphedit.com"
begin
	if( isqpoe == YES )
	    return(qp_open (name, mode, 0))
	else
	    return(immap (name, mode, len))
end

#  ximunmap -- close an image or qpoe file
procedure ximunmap (im)
int	im				# i: image handle
include "qphedit.com"
begin
	if( isqpoe == YES )
	    call qp_close(im)
	else
	    call imunmap(im)
end

#  ximseti -- set a param value in a qpoe file
procedure ximseti (im, param, value)
int	im				# i: image handle
int	param				# i: param to set
int	value				# i: value
include "qphedit.com"
begin
	if( isqpoe == YES )
	    ;
	else
	    call imseti (im, param, value)
end

# ximaccf - check for existence of parameter
int procedure ximaccf (im, param)
int	im				# i: image handle
char	param[ARB]			# i: param
int	qp_accessf(), imaccf()
include "qphedit.com"
begin
	if( isqpoe == YES )
	    return(qp_accessf(im, param))
	else
	    return(imaccf (im, param))
end

# ximaddb -- add a boolean param
procedure ximaddb (im, param, bval)
int	im				# i: image handle
char	param[ARB]			# i: param
bool	bval				# i: bool value
int	qp_accessf()
include "qphedit.com"
begin
	if( isqpoe == YES ){
	    if( qpupdate == NO )
		return
	    if( qp_accessf(im, param) == NO )
		call qpx_addf(im, param, "b", 1, "", 0)
	    call qp_putb(im, param, bval)
	}
	else
	    call imaddb(im, param, bval)
end

# ximaddi -- add an integer param
procedure ximaddi (im, param, ival)
int	im				# i: image handle
char	param[ARB]			# i: param
int	ival				# i: int value
int	qp_accessf()
include "qphedit.com"
begin
	if( isqpoe == YES ){
	    if( qpupdate == NO )
		return
	    if( qp_accessf(im, param) == NO )
		call qpx_addf(im, param, "i", 1, "", 0)
	    call qp_puti(im, param, ival)
	}
	else
	    call imaddi(im, param, ival)
end

# ximaddr -- add a real param
procedure ximaddr (im, param, rval)
int	im				# i: image handle
char	param[ARB]			# i: param
real	rval				# i: real value
int	qp_accessf()
include "qphedit.com"
begin
	if( isqpoe == YES ){
	    if( qpupdate == NO )
		return
	    if( qp_accessf(im, param) == NO )
		call qpx_addf(im, param, "r", 1, "", 0)
	    call qp_putr(im, param, rval)
	}
	else
	    call imaddr(im, param, rval)
end

# ximastr -- add a string param
procedure ximastr (im, param, cval)
int	im				# i: image handle
char	param[ARB]			# i: param
char	cval[ARB]			# i: char array
int	nchars				# l: size of char param
int	strlen()
int	qp_accessf()
include "qphedit.com"
begin
	if( isqpoe == YES ){
	    if( qpupdate == NO )
		return
	    if( qp_accessf(im, param) == NO ){
	        nchars = max(strlen(cval), SZ_LINE)
		call qpx_addf (im, param, "c", nchars, "", 0)
	    }
	    call qp_pstr(im, param, cval)
	}
	else
	    call imastr(im, param, cval)
end

# ximgetb -- get a boolean param
bool procedure ximgetb (im, param)
int	im				# i: image handle
char	param[ARB]			# i: param
bool	qp_getb(), imgetb()
include "qphedit.com"
begin
	if( isqpoe == YES )
	    return(qp_getb(im, param))
	else
	    return(imgetb(im, param))
end

# ximgeti -- get an int param
int procedure ximgeti (im, param)
int	im				# i: image handle
char	param[ARB]			# i: param
int	qp_geti(), imgeti()
include "qphedit.com"
begin
	if( isqpoe == YES )
	    return(qp_geti(im, param))
	else
	    return(imgeti(im, param))
end

# ximgetr -- get a real param
real procedure ximgetr (im, param)
int	im				# i: image handle
char	param[ARB]			# i: param
real	qp_getr(), imgetr()
include "qphedit.com"
begin
	if( isqpoe == YES )
	    return(qp_getr(im, param))
	else
	    return(imgetr(im, param))
end

# ximgstr -- get a string param
procedure ximgstr (im, param, cval, maxchar)
int	im				# i: image handle
char	param[ARB]			# i: param
char	cval[ARB]			# o: char array
int	maxchar				# i: max char in array
include "qphedit.com"
begin
	if( isqpoe == YES ){
	    call xqpgstr(im, param, cval, maxchar)
	}
	else
	    call imgstr(im, param, cval, maxchar)
end

# xqpgstr -- get a param and turn it into a string
procedure xqpgstr(im, param, cval, maxchar)
int	im				# i: image handle
char	param[ARB]			# i: param
char	cval[ARB]			# o: char array
int	maxchar				# i: max char in array
int	type				# l: type of param
bool	bval, qp_getb()			# l: get bool param
int	ival, qp_geti()			# l: get int param
real	rval, qp_getr()			# l: get real param
double	dval, qp_getd()			# l: get double param
int	qp_gstr()			# l: get string param
int	ximgftype()			# l: get param type
include "qphedit.com"
begin
        type =  ximgftype (im, param)
	switch(type){
	case TY_BOOL:
	    bval = qp_getb(im, param)
	    if( bval )
		call strcpy("T", cval, maxchar)
	    else
		call strcpy("F", cval, maxchar)
	case TY_SHORT, TY_INT, TY_LONG:
	    ival = qp_geti(im, param)
	    call sprintf(cval, maxchar, "%d")
	    call pargi(ival)
	case TY_REAL:
	    rval = qp_getr(im, param)
	    call sprintf(cval, maxchar, "%.4f")
	    call pargr(rval)
	case TY_DOUBLE, TY_COMPLEX:
	    dval = qp_getd(im, param)
	    call sprintf(cval, maxchar, "%f")
	    call pargd(dval)
	default:
	    ival = qp_gstr(im, param, cval, maxchar)
	}
end

# ximpstr -- add a string param
procedure ximpstr (im, param, cval)
int	im				# i: image handle
char	param[ARB]			# i: param
char	cval[ARB]			# i: char array
include "qphedit.com"
begin
	if( isqpoe == YES ){
	    if( qpupdate == NO )
		return
	    call xqppstr(im, param, cval)
	}
	else
	    call impstr(im, param, cval)
end

# xqppstr -- convert a parameter in string format to correct type
# and put it to a qpoe file.  If old param has a different type,
# delete old and add new.
procedure xqppstr(im, param, cval)
int	im				# i: image handle
char	param[ARB]			# i: param
char	cval[ARB]			# o: char array

bool	bval				# l: temp bool value
int	ival				# l: temp int value
real	rval				# l: temp real value
double	dval				# l: temp double value
int	iptr				# l: dummy for conversion
int	oldtype				# l: old type of param
int	newtype				# l: new type of param
int	maxelem, flags			# l: from qp_queryf()
int	nchars				# l: size of char param
int	junk				# l: junk return
int	ip				# l: input pointer for lexnum
pointer	datatype, comment		# l: from qp_queryf()
pointer	o				# l: return from evexpr()
pointer	sp				# l: stack pointer
bool	streq()
int	ximgftype()
int	qp_queryf()
int	strlen()
int	evexpr(), locpr()
int	ctoi(), ctod()
int	lexnum()
extern	he_getop()
include "qphedit.com"
begin
	# get old data type
	oldtype = ximgftype(im, param)

## old qphedit
	# get new param type
	ip = 1
	# check for string
	if( lexnum(cval, ip, junk) == LEX_NONNUM )
	{
	    newtype = TY_CHAR
	    if( streq(cval,"yes") || streq(cval,"no") || streq(cval,"T") || streq(cval,"F") )
	        newtype = TY_BOOL
	}
	# get numeric type	
	else{
	    o = evexpr (cval, locpr (he_getop), 0)
	    newtype = O_TYPE(o)
	    call mfree (o, TY_STRUCT)
	}
# end old qphedit

#  From HEDIT
#        ip = 1
#        numeric = (lexnum (cval, ip, numlen) != LEX_NONNUM)
#        if (numeric)
#            numeric = (numlen == strlen (cval))
# 
#        if (numeric || cval[1] == '(')
#	{
#            o = evexpr (cval, locpr(he_getop), 0)
#	}
#        else {
#            call malloc (o, LEN_OPERAND, TY_STRUCT)
#            call xev_initop (o, strlen(cval), TY_CHAR)
#            call strcpy (cval, O_VALC(o), ARB)
#	    newtype = TY_CHAR
#        }
#
# End HEDIT	

	# we don't mix chars and non-char params
	if( (oldtype == TY_CHAR && newtype != TY_CHAR) ||
	    (oldtype != TY_CHAR && newtype == TY_CHAR) ){
#	    call printf("can't convert between char and non-char data types\n")
	    call printf("converting between char and non-char data types\n")
	    call flush(STDOUT)
	}

	# we don't mix bool and non-bool params
	if( (oldtype == TY_BOOL && newtype != TY_BOOL) ||
	    (oldtype != TY_BOOL && newtype == TY_BOOL) ){
#	    call printf("can't convert between bool and non-bool data types\n")
	    call printf("converting between bool and non-bool data types\n")
	    call flush(STDOUT)
	}

	# we don't mix complex and non-complex params
	if( (oldtype == TY_COMPLEX && newtype != TY_COMPLEX) ||
	    (oldtype != TY_COMPLEX && newtype == TY_COMPLEX) ){
#	    call printf("can't convert between complex and non-complex data types\n")
	    call printf("converting between complex and non-complex data types\n")
	    call flush(STDOUT)
	}

	# if we can get more precision by a change in type, do so
	if( ((oldtype == TY_SHORT) ||
	     (oldtype == TY_INT)   ||
	     (oldtype == TY_LONG)) && (newtype == TY_REAL) ){
    # get info about old param - we want the comment!
	    # mark the stack
	    call smark(sp)
	    # allocate space for param info
	    call salloc(datatype, SZ_LINE, TY_CHAR)
	    call salloc(comment, SZ_LINE, TY_CHAR)
	    junk = qp_queryf(im, param, Memc[datatype], maxelem,
		 	     Memc[comment], flags)

    ##JCC(8/7/97) - print out COMMENT field from qpoe
            call printf("xqppstr:  param=%sk\n")
            call pargstr(param)
            call printf("xqppstr:  comment=%sk\n")
            call pargstr(Memc[comment])

	    # delete the old param
	    call qp_deletef(im, param)
	    # add the new param definition
	    switch(newtype){
	    case TY_BOOL:
		call qpx_addf (im, param, "b", 1, Memc[comment], 0)
	    case TY_SHORT:
		call qpx_addf (im, param, "s", 1, Memc[comment], 0)
	    case TY_INT:
		call qpx_addf (im, param, "i", 1, Memc[comment], 0)
	    case TY_LONG:
		call qpx_addf (im, param, "l", 1, Memc[comment], 0)
	    case TY_REAL:
		call qpx_addf (im, param, "r", 1, Memc[comment], 0)
	    case TY_DOUBLE:
		call qpx_addf (im, param, "d", 1, Memc[comment], 0)
	    case TY_COMPLEX:
		call qpx_addf (im, param, "x", 1, Memc[comment], 0)
	    default:
	        nchars = max(strlen(cval), SZ_LINE)
		call qpx_addf (im, param, "c", nchars, Memc[comment], 0)
	    }
	# free up stack space
	call sfree(sp)
	}

	# add the new param value
	iptr = 1
	switch(newtype){
	case TY_BOOL:
#  it should be yes/no 
	    if( cval[1] == 'T' )
		bval = true
	    else if( cval[1] == 'F' )
		bval = false
	    else if( streq(cval,"yes") )
		bval = true
	    else
		bval = false
	    call qp_putb(im, param, bval)
	case TY_SHORT, TY_INT, TY_LONG:
	    junk = ctoi(cval, iptr, ival)
	    call qp_puti(im, param, ival)
	case TY_REAL:
	    junk = ctod(cval, iptr, dval)
	    rval = dval
	    call qp_putr(im, param, rval)
	case TY_DOUBLE, TY_COMPLEX:
	    junk = ctod(cval, iptr, dval)
	    call qp_putd(im, param, dval)
	default:
	    call qp_pstr(im, param, cval)
	}
#        call mfree (o, TY_STRUCT)
end

# ximdelf -- del a param
procedure ximdelf (im, param)
int	im				# i: image handle
char	param[ARB]			# i: param
include "qphedit.com"
begin
	if( isqpoe == YES ){
	    if( qpupdate == NO )
		return
	    call qp_deletef(im, param)
	}
	else
	    call imdelf(im, param)
end

# ximgftype -- get param type
int procedure ximgftype (im, param)
int	im				# i: image handle
char	param[ARB]			# i: param
int	junk				# l: temp return value
pointer	sp				# l: stack pointer
pointer	datatype			# l: from qp_queryf
pointer	comment				# l: from qp_queryf
int	maxelem				# l: from qp_queryf
int	flags				# l: from qp_queryf
int	qp_queryf()			# l: qp_queryf
int	imgftype()
include "qphedit.com"
begin
	if( isqpoe == YES ){
	    call smark(sp)
	    call salloc(datatype, SZ_LINE, TY_CHAR)
	    call salloc(comment, SZ_LINE, TY_CHAR)
	    junk = qp_queryf(im, param, Memc[datatype], maxelem,
			     Memc[comment], flags)
	    switch(Memc[datatype]){
	    case 'b':
		return(TY_BOOL)
	    case 'c':
		return(TY_CHAR)
	    case 's':
		return(TY_SHORT)
	    case 'i':
		return(TY_INT)
	    case 'l':
		return(TY_LONG)
	    case 'r':
		return(TY_REAL)
	    case 'd':
		return(TY_DOUBLE)
	    case 'x':
		return(TY_COMPLEX)
	    default:
		return(0)
	    }
	    call sfree(sp)
	}
	else
	    return(imgftype(im, param))
end

# ximofnlu - open an unsorted param list
int procedure ximofnlu (im, fields)
int	im				# i: image handle
char	fields[ARB]			# i: field list
int	qp_ofnlu(), imofnlu()
include "qphedit.com"
begin
	if( isqpoe == YES )
	    return(qp_ofnlu(im, fields))
	else
	    return(imofnlu(im, fields))
end

# ximgnfn -- get next field 
int procedure ximgnfn (flist, field, len)
int	flist				# i: file list
char	field[ARB]			# o: field list
int	len				# i: length of field str
int	qp_gnfn(), imgnfn()
include "qphedit.com"
begin
	if( isqpoe == YES )
	    return(qp_gnfn(flist, field, len))
	else
	    return(imgnfn(flist, field, len))
end

# ximcfnl -- close file name list
procedure ximcfnl (flist)
int	flist				# i: file list
include "qphedit.com"
begin
	if( isqpoe == YES )
	    call qp_cfnl(flist)
	else
	    call imcfnl(flist)
end
