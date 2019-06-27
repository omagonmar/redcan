#$Header: /home/pros/xray/xdataio/fits2qp/RCS/nextcard.x,v 11.0 1997/11/06 16:34:28 prosb Exp $
#$Log: nextcard.x,v $
#Revision 11.0  1997/11/06 16:34:28  prosb
#General Release 2.5
#
#Revision 9.2  1997/06/06 20:10:41  prosb
##JCC(6/6/97) - updated valpar() to fix the exponential pattern for
#               ONTIME (E+03).
#
#Revision 9.1  1997/05/07 18:27:37  prosb
#JCC(5/7/97) - add comments.
#
#Revision 9.0  1995/11/16  18:59:53  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:51  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:08:22  mo
#MC	2/25/94		Memory allocation removed from this routine
#			so it can be centralized (ft_nxtext and ft_header)
#
#Revision 7.0  93/12/27  18:41:20  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  15:07:09  mo
#MC	7/2/93		Correct boolean initializations from YES/NO to TRUE/FALSE
#
#Revision 6.0  93/05/24  16:26:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:32:27  prosb
#General Release 2.1
#
#Revision 4.3  92/09/23  11:37:48  jmoran
#JMORAN - MPE ASCII FITS changes
#and blank value and keyword changes
#
#Revision 4.2  92/07/13  14:06:52  jmoran
#JMORAN added code to allow single quotes in header strings
#
#Revision 4.1  92/05/27  15:29:41  jmoran
#JMORAN changed the pattern for boolean patterns from "#[TF]#" to
#"[#]*[TF][#]*"
#
#Revision 4.0  92/04/27  15:01:58  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:14:02  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:01  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Purpose:      Read the next card from a FITS file
# External:     NONE
# Local:        nextcard(),lookup(),matchcard(),valpar()
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM   -- initial version  1990
#               {1}  MC   -- Fixed valpar for 'unknown' cards and fixed
#			        END case for non-EVENT fits file
#							-- 1/91
#               {n} <who> -- <does what> -- <when>


# The subroutine handles cards in an intellegent fashion.  Each FITS defined
# card is returned with a unique integer id.  All cards are returned with the
# card name, data type and converted data.  Data type hints and name
# translations are provided by *.cards files read in by the knowncards().  


include <ctype.h>
include "cards.h"

int procedure nextcard(fits, info, mpe_table)

int	fits				# i: open file pointer for FITS file
pointer	info				# o: card information structure
bool	mpe_table
#--

char	card[81]			# l: card input buffer
char	name[10]
#char   valstring[73]
char    valstring[SZ_CARDVSTR+1]

int	ptr
int	i
int	base
int	read(), ctoi(), ctod(), strlen()
int	stridx()
bool	lookup()
bool	streq()
bool	dummy_bool

char    outstr[SZ_CARDVSTR]
int     pos

char    ch


begin

        if (read(fits, card, 40) == EOF ) 
	   return -1

        call chrupk(card, 1, card, 1, 80)
        card[81] = EOS
        call sscan(card)                        # Get the Key Word
        call gargwrd(name, 8)

	if (IS_WHITE(name[1]) || name[1] == EOS)
	   return -2
#---------------------------------------------------------------------------
# RETURNS THE FIRST WHITESPACE DELIMITED TOKEN OR QUOTED STRING FROM THE
# SCAN BUFFER
#---------------------------------------------------------------------------
        call sscan(card[10])                    # Get the value string
        call gargwrd(valstring, SZ_CARDVSTR)


        if (info  == NULL )
#           call calloc(info, SZ_CARDINFO, TY_STRUCT)
	    call error(1,"INFO not alloced")

        if (CARDNA(info) == NULL)
#           call calloc(CARDNA(info), SZ_CARDNA, TY_CHAR)
	    call error(1,"CARDNA not alloced")

        if (CARDCO(info) == NULL)
#           call calloc(CARDCO(info), SZ_CARDVSTR, TY_CHAR)
	    call error(1,"CARDNA not alloced")

        if (CARDVSTR(info) == NULL)
#           call calloc(CARDVSTR(info), strlen(card[10]), TY_CHAR)
	    call error(1,"CARDVSTR not alloced")
#---------------------------------------------------------------------------
# NEW
#---------------------------------------------------------------------------

	if (streq(name, "HISTORY") && (mpe_table))
	{
	   dummy_bool = lookup(name, info)
#           call calloc(CARDVSTR(info), strlen(card[10]), TY_CHAR)
##	   call calloc(CARDVSTR(info), strlen(card[10]) + 1, TY_CHAR)
           call strcpy(card[10], Memc[CARDVSTR(info)], SZ_CARDVSTR)

           return CARDID(info)
	}

#---------------------------------------------------------------------------
# NEW
#---------------------------------------------------------------------------

        if (card[11] == '\'')
        {
           #---------------------
           # Clear out the string
           #---------------------
           for (i = 1; i <= SZ_CARDVSTR; i = i + 1)
           {
              outstr[i] = EOS
           }

           #------------------------------------------------------------
           # Parse the string, allowing for two successive single quotes
           #------------------------------------------------------------
           call parse_string(card[12], outstr, pos)

           #---------------------------------------------
           # Copy the parsed string into the value string
           #---------------------------------------------
           call strcpy(outstr, valstring, SZ_CARDVSTR)

           #------------------------------------------------------------
           # Set the start position of the comment to the value returned
           # by parse_string
           #------------------------------------------------------------
           base = pos
        }
        else
        {
           base = 11
        }


        # Get the comment
        ch = '/'
        i = stridx(ch, card[base])

	if ( i != 0 ) {
	   # skip white space
	   i = i + base
	   while(IS_WHITE(card[i]))
		i = i + 1
	   # save the comment
	   call strcpy(card[i], Memc[CARDCO(info)], SZ_CARDVSTR)
	}
	else
	    Memc[CARDCO(info)] = EOS

	if ( !lookup(name, info) ) {
	    call strcpy(name, Memc[CARDNA(info)], SZ_CARDNA)
	    CARDTY(info) = TY_GUESS
	    CARDID(info) = 0
	}

	if ( CARDTY(info) == TY_GUESS && CARDID(info) !=999 ){
	    call valpar(valstring, CARDTY(info))

#	    if( streq(valstring, NULL ) )     # NO PARAMETER name of value found
#		CARDID(info) = -1	      # probably no extensions in
					      #    this FITS file
	}

	ptr = 1
	switch ( CARDTY(info) ) {

	case TY_VOID:
		# Do not convert
		CARDVI(info) = 0

	case TY_BOOL:
	         if ( valstring[1] == 'T' ) CARDVB(info) = TRUE
	    else if ( valstring[1] == 'F' ) CARDVB(info) = FALSE
	    else call error(1, "can't crunch a boolean")

	case TY_INT:
            #call printf("nextcard.x:  valstring1 = %s \n")
            #call pargstr(valstring)

            #JCC: the following condition checking prevents from writing an
            # character string when it should be an integer data type

	    if ( strlen(valstring) != ctoi(valstring, ptr, CARDVI(info)) )
  {
            #call printf("nextcard.x:  bad valstring = %s \n")
            #call pargstr(valstring)

            #call printf("nextcard.x:  ptr, CARDVI = %d  %d\n")
            #call pargi(ptr)
            #call pargi(CARDVI(info))

	    call errstr(1, "can't crunch a integer", valstring)
  }

	case TY_REAL:
	    if ( strlen(valstring) != ctod(valstring, ptr, CARDVD(info)) )
		call errstr(1, "can't crunch a real",valstring)
	    CARDVR(info) = CARDVD(info)

	case TY_DOUBLE:
	    if ( strlen(valstring) != ctod(valstring, ptr, CARDVD(info)) )
		call errstr(1, "can't crunch a double", valstring)

	case TY_CHAR:
	    i = strlen(valstring)				# kill trailers
	    while ( valstring[i] == ' ' ) i = i - 1
	    valstring[i + 1] = EOS

#	    call calloc(CARDVSTR(info), strlen(valstring) + 1, TY_CHAR)
	    call strcpy(valstring, Memc[CARDVSTR(info)], SZ_CARDVSTR)
	default:
	    call error(1, "unknown data type of card")
	}

	return CARDID(info)
end

#***********************************************************************
# Called only if value is a string, and passed in one pos past initial
# single quote
#***********************************************************************
procedure parse_string(instr, outstr, comment_pos)

char    instr[ARB]
char    outstr[ARB]
int     comment_pos

bool    done
char    single_quote
int     in_idx
int     out_idx

begin
        done = false
        single_quote = '\''
        out_idx = 1
        in_idx = 1

#----------------------------------------------------------------------
# The original string is already offset by 11 spaces when it was passed
# to this routine
#----------------------------------------------------------------------
        comment_pos = 11

#------------------------------------------------------------------
# Loop through the input string, copying over to the output string
# until a single quote is found that is NOT followed by another
# single quote.  (The FITS standard allows strings to have single
# quotes, but they must be doubled up)
#------------------------------------------------------------------
        while ((!done) && (in_idx <= SZ_CARDVSTR))
        {
           outstr[out_idx] = instr[in_idx]

           if (instr[in_idx] == single_quote)
           {
              if (instr[in_idx + 1] == single_quote)
              {
                  out_idx = out_idx + 1
                  in_idx = in_idx + 1
                  outstr[out_idx] = instr[in_idx]
              }
              else
              {
                  done = true
              }
           }

           if (!done)
           {
              in_idx = in_idx + 1
              out_idx = out_idx + 1
           }
        } # end while loop

#---------------------------------------
# Put an EOS over the final single quote
#---------------------------------------
        outstr[out_idx] = EOS

#-------------------------------------------------------------------
# Assign the position to begin looking for the comment.
# This calculation is the original offset of the string when it
# was passed to this routine, plus the length of the input string
# from 1 -> position of last single quote.  The string is offset
# by one more position to get beyond the last single quote.
#-------------------------------------------------------------------
        comment_pos = comment_pos + in_idx + 1

end



bool procedure lookup(name, info)

char	name[ARB]
pointer info
#--

pointer	sym, stfind()
bool 	matchcard()

include "cards.com"

begin
#	call printf("Look : \"%s\"\n")
#	 call pargstr(name)

	if ( stp == NULL )
	    return FALSE

	sym = stfind(stp, name)

	if ( sym == NULL )
	     return matchcard(name, info)

	if ( CARDNA(sym) != NULL )
	    call strcpy(Memc[CARDNA(sym)], Memc[CARDNA(info)], SZ_CARDNA)
	else
	    call strcpy(name, Memc[CARDNA(info)], SZ_CARDNA)

	CARDTY(info) = CARDTY(sym)
	CARDID(info) = CARDID(sym)

#	call eprintf("Found: %15s ty= %10d in= %10d\n")
#	  call pargstr(Memc[CARDNA(info)])
#	  call pargi(CARDTY(info))
#	  call pargi(CARDID(info))

	return TRUE
end



bool procedure matchcard(name, info)

char	name[ARB]
pointer info
#--

pointer	pattern
int	first, last
int	length, junk

int	strlen(), gpatmatch()

include "cards.com"

begin
	pattern = pap
	length  = strlen(name)

	while ( pattern != NULL ) {
	    junk = gpatmatch(name, Memc[PATTNA(pattern)], first, last)

	    if ( junk > 0 && first == 1 && last == length ) {
		CARDTY(info) = PATTTY(pattern)
		CARDID(info) = PATTID(pattern)

		if ( PATTXL(pattern) == NULL ) 
		    call strcpy(name, Memc[CARDNA(info)], SZ_CARDNA)
		else
		    call strcpy(Memc[PATTXL(pattern)], 
				Memc[CARDNA(info)], SZ_CARDNA)

#			call eprintf("Match: %15s ty= %10d in= %10d\n")
#	  		 call pargstr(Memc[CARDNA(info)])
#	  		 call pargi(CARDTY(info))
#	  		 call pargi(CARDID(info))

		return TRUE
	    }

	    pattern = PATTNX(pattern)
	}

	return FALSE
end



procedure valpar(str, type)

char	str[ARB]
int	type
#--

int	first, last, junk, length, strlen()
int	foo, patmake(), gpatmatch()
char	int_pattern[80]
char	dbl_pattern[80]
char	exp_pattern[80]
char	bol_pattern[80]

begin

	foo = patmake("[+-0-9][0-9]*"       , int_pattern, 80)

#JCC(6/6/97) - updated for ONTIME in reject events
        #foo =patmake("[+-0-9][0-9]*.[0-9]*[ED][0-9][0-9]*", exp_pattern,80)
	foo = patmake("[+-0-9][0-9]*.[0-9]*[ED][+-0-9][0-9]*",exp_pattern,80)

	foo = patmake("[+-0-9][0-9]*.[0-9]*", dbl_pattern, 80)
	foo = patmake("[#]*[TF][#]*"    , bol_pattern, 80)

	length = strlen(str)

	junk = gpatmatch(str, int_pattern, first, last)
	if ( junk > 0 && first == 1 && last == length ) {
	    type = TY_INT
	} else {
	    junk = gpatmatch(str, dbl_pattern, first, last)
	    if ( junk > 0 && first == 1 && last == length )
		type = TY_DOUBLE
	    else {
		junk = gpatmatch(str, exp_pattern, first, last)
	    	if ( junk > 0 && first == 1 && last == length )
		    type = TY_DOUBLE
		else{
		    junk = gpatmatch(str, bol_pattern, first, last)
	    	    if ( junk > 0 && first == 1 && last == length )
		        type = TY_BOOL
		    else
	    	        type = TY_CHAR
		}
	    }
	}

	#  Catch the special case where there is only a single character
	#	that is a sign ( +/- )  since we can't build this pattern
	if( (type== TY_INT || type == TY_DOUBLE) && 
	     length== 1 && !IS_DIGIT(str[1]) )  
		type = TY_CHAR
#	call printf("Parse a value \"%s\" = %d\n")
#	 call pargstr(str)
#	 call pargi(type)

end
