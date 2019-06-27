# datarep.y
#
# The template to code text parser for Datarep.


%{

include <ctype.h>
include "datarep.h"

define	YYMAXDEPTH	200
define	YYOPLEN		LEN_SYMBOL

define	DRPP		-100
%}


%token	STRUCT IDENTIFIER
%token	PRIMARY
%token	INTEGER
%token	YYEOF

%%

file	: deflist YYEOF
		{
			call compile(0)
			return
		}
	| error
		{
			call dataer("")
		}
	;

deflist	:
	| struct deflist
	| data	 deflist
	;

struct	: STRUCT IDENTIFIER
		{	call pshtext(S_TEXT($2))	}
	  '{' datlist '}'
		{	call poptext()			}
	| error
		{
			call dataer("in structure definition")
		}
	;

datlist	: # empty
	| data datlist
	;

data	: PRIMARY
		{	
			call compile(S_FUNC($1))
			if ( S_TEXT($1) != NULL )
				call compile(S_TEXT($1))
		}
	| array
		{	call compilerep(S_REPT($1))
			call compile(S_FUNC($1))
			if ( S_TEXT($1) != NULL )
				call compile(S_TEXT($1))
		}
	;

array	: PRIMARY '[' index ']'
		{	
			S_FUNC($$) = S_FUNC($1)
			S_TEXT($$) = S_TEXT($1)
			S_REPT($$) = S_REPT($3)
		}
	| error
		{
			call dataer("in array index definition")
		}
	;


index	: INTEGER
	| INTEGER ',' index
		{	S_REPT($$) = S_REPT($1) * S_REPT($3)	}
	;

%%

# The main compiler procedure.
#
pointer procedure datacom(template)

char	template[ARB]
#--

pointer	text, junk

pointer	psh(), pop()
int	yyparse()
extern datalex()

include	"datapar.com"

begin
	call malloc(text, 1000, TY_INT)
	textstack = psh(0, text)
	filestack = psh(0, template)

	junk = yyparse(template, 0, datalex)
	junk = pop(textstack)

	return text
end

procedure datainit()
#--

pointer	stopen()

int	locpr()
extern  rreeppeeaatt()
extern  jumpinto()
extern  jumpret()

include	"datapar.com"

extern pshfile()

begin
	symbols = stopen("datarep", 256, 4096, 4096)

	call enter("struct",	STRUCT,	 0)
#	call enter("include",	DRPP,	 pshfile)

        op_loop = locpr(rreeppeeaatt)
        op_call = locpr(jumpinto)
        op_ret =  locpr(jumpret)

	line = 1
end


procedure enter(str, token, func)

char	str[ARB]
int	token
pointer func
#--

include "datapar.com"
pointer	sym, stenter()
int	locpr()

begin
	sym = stenter(symbols, str, LEN_SYMBOL)

	 call pargstr(str)
	 call pargi(func)

	if ( func != 0 ) S_FUNC(sym)  = locpr(func)
	S_TOKEN(sym) = token
	S_REPT(sym)  = 1
	S_TEXT(sym)  = 0
end


procedure datatype(str, func)

char	str[ARB]
int	func
#--

begin
	call enter(str, PRIMARY, func)
end


int procedure datalex(fs, rp)

int	fs
pointer	rp				# return pointer
#--

int	i
char	ch, junk
char	token[SZ_LINE]
pointer	sym

pointer	str

char	getc()
pointer	pop(), stfind()

include	"datapar.com"

define TOP	ST_VALUE(filestack)
define again	91

begin

again
	repeat {
		ch = getc(TOP, junk)
		if ( ch == '\n' ) line = line + 1
	} until ( IS_WHITE(ch) != TRUE && ch != '\n' )

	switch ( ch ) {
	 case EOF: {
		filestack = pop(filestack)
		if ( filestack != NULL ) goto again
		else			 return YYEOF
	 }
	 case '#': {
		while ( ch != '\n' ) ch = getc(TOP, junk)
		line = line + 1
		goto again
	 }
	 case '{':	return '{'
	 case '}':	return '}'
	 case '[':	return '['
	 case ']':	return ']'
	 case ',':      return ','
	 default:
	}

	# Must be a word

	token[1] = ch
	i = 1
	repeat { i = i + 1
		 token[i] = getc(TOP, junk)
	} until ( !IS_ALNUM(token[i])		&&
			    token[i] != '_'	&&
			    token[i] != '$'	||
				 i >= MAXTOKEN )

	call ungetc(TOP, token[i])
	token[i] = EOS

	sym = stfind(symbols, token)
	if ( sym == NULL ) {
		switch ( token[1] ) {
		 case '1', '2', '3', '4', '5', '6', '7', '8', '9', '0': {
			i = 1
			call ctoi(token, i, S_REPT(rp))
			return INTEGER
		 }
		 default:
			call malloc(str, i, TY_CHAR)
			call strcpy(token, Memc[str], i)
			S_TEXT(rp) = str
			return IDENTIFIER
		}
	}

	# Is the word a datarep preprecessor symbol ?
	#
	if ( S_TOKEN(sym) == DRPP ) {
		ch = getc(TOP, junk)
		while ( IS_WHITE(ch) || ch == '\n' ) ch = getc(TOP, junk)

		token[1] = ch
		i = 1
		repeat { i = i + 1
			 token[i] = getc(TOP, junk)
		} until ( token[i] == '\n' || i > SZ_LINE )

		call zcall1(S_FUNC(sym), token)
		goto again
	}

	S_FUNC(rp) = S_FUNC(sym)
	S_TEXT(rp) = S_TEXT(sym)
	S_REPT(rp) = 1
	return S_TOKEN(sym)
end


procedure dataer(str)

char	str[ARB]

#--

include "datapar.com"

begin

	call printf("syntax error %s - at line %d\n")
	 call pargstr(str)
	 call pargi(line)
	call error(1, "datarep")
end


procedure pshtext(str)

pointer	str
#--

pointer	sym

include	"datapar.com"

pointer	stenter(), psh()

begin
	sym = stenter(symbols, Memc[str], LEN_SYMBOL)
	
	S_FUNC(sym) = op_call
	S_REPT(sym) = 1
	call malloc(S_TEXT(sym), 1000, TY_INT)
	S_TOKEN(sym) = PRIMARY

	call mfree(str, TY_CHAR)

	textstack = psh(textstack, S_TEXT(sym))
end


procedure poptext()
#--

pointer	pop()

include	"datapar.com"

begin
	call compile(op_ret)

	textstack = pop(textstack)
end


pointer procedure pshfile(filestack, name)

pointer	filestack
char	name[ARB]
#--

pointer	open(), psh()

begin
	return psh(filestack, open(name))
end



procedure compile(op)

int	op
#--

include	"datapar.com"

begin
	I_FUNC(ST_VALUE(textstack)) = op

	ST_VALUE(textstack) = ST_VALUE(textstack) + 1
end


procedure compilerep(n)

int	n
#--

include "datapar.com"

begin
	call compile(op_loop)
	call compile(n)
end


procedure datazap(text)

pointer	text			# a piece of text to free
#--

pointer	sym, sthead(), stnext()

include "datapar.com"

begin
	call mfree(text, TY_STRUCT)

	if ( symbols != NULL ) {
		for ( sym = sthead(symbols); sym != NULL; sym = stnext(symbols, sym) )
			call mfree(S_TEXT(sym), TY_STRUCT)

		call stclose(symbols)
	}
end



# Datarep PreProcessor "include" statement is unimplimented
#
#  the argument to this function is the rest of a line from the 
#  input line "include..."
#
#  To impliment this command open the file and push the file stack.
#
#
procedure inc_file(line)

char	line[ARB]
#--

#int	idx
#char	name[SZ_LINE]

begin

end
