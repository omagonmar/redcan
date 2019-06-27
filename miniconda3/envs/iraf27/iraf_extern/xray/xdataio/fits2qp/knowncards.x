#$Header: /home/pros/xray/xdataio/fits2qp/RCS/knowncards.x,v 11.0 1997/11/06 16:35:32 prosb Exp $
#$Log: knowncards.x,v $
#Revision 11.0  1997/11/06 16:35:32  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:46  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:40  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:07:54  mo
#MC	2/25/94		just some debugging statements - commented out now
#
#Revision 6.2  93/12/14  18:13:25  mo
#MC	12/13/93		Install change to 'eprintf' messages
#
#Revision 6.1  93/07/02  15:06:23  mo
#MC	7/2/93		Correct boolean initializations from YES/NO to TRUE/FALSE
#
#Revision 6.0  93/05/24  16:26:03  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:51  prosb
#General Release 2.1
#
#Revision 4.2  92/09/23  11:41:03  jmoran
#JMORAN - no changes
#
#Revision 4.1  92/07/13  14:08:01  jmoran
#*** empty log message ***
#
#Revision 4.0  92/04/27  15:01:47  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:14:00  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:26:43  pros
#General Release 1.0
#

# KNOWNCARDS.X
#
##

# Set up the known fits cards symbol table.
#
#  knowncards(file)				# read the file of known cards
#  zapknown()					# kill the known cards symtab
#  addcard(name, translation, type, id)		# add a cards to the symtab
#  xtype(type)					# return an integer type


include "cards.h"
include <ctype.h>


bool procedure knowncards(file)

char	file[ARB]			# i: name of card ,description file
#--

char	line[132]
int	fd
int	i

pointer	name
pointer	xlat
char	type[10]
int	id, ty
bool	flag

bool	access(), streq(), addpatt(), addcard()
int	open(), getline(), nscan(), xtype()

begin
	if ( !access(file, READ_ONLY, TEXT_FILE) ) {
		call eprintf("knowncards can't access definitions file: %s\n")
		  call pargstr(file)
		return  FALSE
	}

	fd = open(file, READ_ONLY, TEXT_FILE)
	if ( fd == -1 ) {
		call eprintf("knowncards can't open definitions file: %s\n")
		  call pargstr(file)
		return FALSE
	}

	flag = TRUE
	call calloc(name, SZ_LINE, TY_CHAR)

	for ( i = 1; getline(fd, line) != EOF; i = i + 1 ) {

		if ( !IS_ALNUM(line[1]) && line[1] != '/' ) next 	# skip

		call calloc(xlat, SZ_CARDNA, TY_CHAR)
#		call printf("alloc xlat: %d\n")
#			call pargl(xlat)

		call sscan(line)
		  call gargwrd(Memc[name], SZ_LINE)
		  call gargwrd(Memc[xlat], SZ_CARDNA)
		  call gargwrd(type, 10)
		  call gargi(id)

		
		if ( nscan() != 4 ) {
			call eprintf("knowncards can't parse line %i in file %s\n")
			  call pargi(i)
			  call pargstr(file)
			flag = FALSE
		}
		
		ty = xtype(type)

		if ( ty == 0 ) {
		    call eprintf("knowncards can't convert Type from line %d in file %s\n")
		      call pargi(i)
		      call pargstr(file)
		    flag = FALSE
		}

		if ( streq(Memc[xlat], ".") ) 
		{
#			call printf("free xlat: %d\n")
#			call pargl(xlat)
			call mfree(xlat, TY_CHAR)
		        xlat = NULL
		}

		if ( line[1] == '/' ) {
		    if ( addpatt(Memc[name], xlat, ty, id) ) {
#			call eprintf("knowncards can't add card at line %d in file %s\n")
#		      	 call pargi(i)
#		      	 call pargstr(file)
		    };
		} else
		    if ( addcard(Memc[name], xlat, ty, id) ) {
#		        call eprintf("knowncards can't add card at line %d in file %s\n")
#		         call pargi(i)
#		         call pargstr(file)
		    }
		if( xlat != NULL)
		{
#			call printf("def free xlat: %d\n")
#			call pargl(xlat)
			call mfree(xlat, TY_CHAR)
			xlat = NULL
		}
	}

	call mfree(name, TY_CHAR)
#	call mfree(xlat, TY_CHAR)
	call close(fd)

	return flag
end




procedure zapknown
#--

pointer sym, t
pointer sthead(), stnext()

include "cards.com"

begin
	if ( stp != NULL ) {
	    for ( sym = sthead(stp); sym != NULL; sym = stnext(stp, sym) )
	    {
	    call mfree(CARDNA(sym), TY_CHAR)
#	    call printf("free CARDNA: %d\n")
#		call pargl(CARDNA(sym))
	    }
	    call stclose(stp)
	}

	if ( typ != NULL ) 
	    call stclose(typ)

	while ( pap != NULL ) {
	    t = PATTNX(pap)

#		call printf("free PATTNA: %d\n")
#		call pargl(PATTNA(pap))
#		call printf("free pap(temp): %d\n")
# 		call pargl(pap)
	    call mfree(PATTNA(pap), TY_CHAR)
	    if ( PATTXL(pap) != NULL ) call mfree(PATTXL(pap), TY_CHAR)
	    call mfree(pap, TY_STRUCT)

	    pap = t
	}

	stp = NULL
	typ = NULL
	pap = NULL
end


bool procedure addcard(name, xlat, type, id)

char	name[ARB]
pointer	xlat
int	type
int	id
#--

pointer sym, stopen(), stenter()

include "cards.com"

begin
	if ( stp == NULL ) {
	    stp = stopen("", 256, 4096, 4096)
	}

	sym = stenter(stp, name, SZ_SYM)

	CARDNA(sym) = xlat
	CARDTY(sym) = type
	CARDID(sym) = id

	return TRUE
end


bool procedure addpatt(name, xlat, type, id)

char	name[ARB]
pointer	xlat
int	type
int	id
#--


int	i, junk
pointer	temp
char	tstr[SZ_CARDNA]

int	patmake()

include "cards.com"

begin
	call calloc(temp, SZ_PATTERN, TY_STRUCT)
	call calloc(PATTNA(temp), SZ_CARDNA, TY_CHAR)
#	call printf("alloc temp: %d\n")
#	call pargl(temp)
#	call printf("alloc PATTNA: %d\n")
#	call pargl(PATTNA(temp))

	# Copy the Pattern str
	for ( i = 2; name[i] != '/' && i < SZ_CARDNA; i = i + 1 )
	    tstr[i - 1] = name[i]

	if ( i == SZ_CARDNA ) return TRUE 

	tstr[i - 1] = EOS

	junk = patmake(tstr, Memc[PATTNA(temp)], SZ_CARDNA) 

	PATTXL(temp) = xlat
	PATTTY(temp) = type
	PATTID(temp) = id

	PATTNX(temp) = pap				# Link the list
	pap = temp

	return FALSE
end


int procedure xtype(type)

char	type[ARB]
#--

pointer	sym, stopen(), stfind(),  stenter()

include "cards.com"

begin
	if ( typ == NULL ) {
	    typ = stopen("", 64, 64, 512)

	    Memi[stenter(typ,   "TY_VOID", 4)] = TY_VOID
	    Memi[stenter(typ,   "TY_BOOL", 4)] = TY_BOOL
	    Memi[stenter(typ,  "TY_SHORT", 4)] = TY_SHORT
	    Memi[stenter(typ,    "TY_INT", 4)] = TY_INT
	    Memi[stenter(typ,   "TY_LONG", 4)] = TY_LONG
	    Memi[stenter(typ,   "TY_REAL", 4)] = TY_REAL
	    Memi[stenter(typ, "TY_DOUBLE", 4)] = TY_DOUBLE
	    Memi[stenter(typ,    "TY_CHAR", 4)] = TY_CHAR
	    Memi[stenter(typ,  "TY_GUESS", 4)] = TY_GUESS

#	    call stinfo(typ, STDERR, YES)
	}


	sym = stfind(typ, type)
	if ( sym == NULL ) 
		return 0
	else
		return Memi[sym]
end
