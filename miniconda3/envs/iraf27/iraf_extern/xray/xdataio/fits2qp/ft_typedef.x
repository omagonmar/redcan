#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_typedef.x,v 11.0 1997/11/06 16:34:49 prosb Exp $
#$Log: ft_typedef.x,v $
#Revision 11.0  1997/11/06 16:34:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:42  prosb
#General Release 2.4
#
#Revision 8.3  1995/02/23  17:17:26  prosb
#The input & output buffers were mixed up when the column was
#an array.  Separated the two types of buffers.
#
#Revision 8.2  1995/02/16  21:21:14  prosb
#Modified FITS2QP to correctly apply TSCAL/TZERO on extensions with
#columns which contain an array of values.  Also modified FITS2QP to
#not be so picky as to force the final index number to match the number
#of fields in an extension.  (I.e., if an extension has 8 columns, and
#TFIELD is set to 8, we can have "TUNIT5" as the final header card.)
#
#Revision 8.1  94/09/16  16:39:25  dvs
#Modified code to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.0  94/06/27  15:21:30  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:41:00  prosb
#General Release 2.3
#
#Revision 6.1  93/12/14  18:21:49  mo
#MC	12/13/93		Add support for BOOLEAN
#
#Revision 6.0  93/05/24  16:25:52  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:43  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:41:00  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:49  jmoran
#Initial revision
#
#
# Module:	ft_typedef.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <ctype.h>
include <evmacro.h>
include "fits2qp.h"

#
#  FT_TYPEDEF -- add typedef information from TFORM to the typedef
#
procedure ft_typedef(ext, tfields, key_x, key_y,
			rtype, scale, itype, otype, ptype)

pointer	ext				# i: extension information
int	tfields				# i: number of ext records
char    key_x[SZ_LINE]    		# i: index x key
char    key_y[SZ_LINE]    		# i: index y key
int	rtype				# i: event or aux or none
bool	scale				# i: applying TZERO/TSCAL scaling?
char	itype[ARB]			# o: typedef string (input)
char	otype[ARB]			# o: typedef string (output)
char	ptype[ARB]			# o: pros eventdef string

char	tbuf[SZ_TYPEDEF]		# l: temp char buffer
char	tibuf[SZ_TYPEDEF]		# l: temp input char buffer
char	tobuf[SZ_TYPEDEF]		# l: temp output char buffer
char	tform[SZ_LINE]			# l: temp tform
char	ttype[SZ_LINE]			# l: temp ttype
int	i				# l: counter
int	j				# l: counter
int	k				# l: counter
int	ip				# l: index for ctoi
int	repcnt				# l: repeat count
int	junk				# l: junk return from ctoi()
int	ctoi()				# l: convert char to int
int	strlen()			# l: string length
bool	streq()				# l: string compare
bool	is_vector
pointer cur_ext				# l: ptr to current EXT record

char 	tempbuf[SZ_LINE]

char	conv_type()

begin
    # begin with open brace
    call strcpy("{", itype, SZ_TYPEDEF)
    call strcpy("{", otype, SZ_TYPEDEF)
    call strcpy("{", ptype, SZ_TYPEDEF)
    # loop through all columns
    do k=1, tfields{

	is_vector = false

	# put form and type in easier to manage arrays
	cur_ext=EXT(ext,k)
	call strcpy(Memc[EXT_FORM(cur_ext)], tform, SZ_LINE)
	call strcpy(Memc[EXT_TYPE(cur_ext)], ttype, SZ_LINE)
	# grab the repeat count
	i = 1
	while( IS_DIGIT(tform[i]) ){
	    tbuf[i] = tform[i]
	    i = i+1
	}
	#  if we have no repeat count, assume 1
	if( i == 1 ){
	    repcnt = 1
	}
	else{
	    # null terminate
	    tbuf[i] = EOS
	    # convert to integer
	    ip = 1
	    junk = ctoi(tbuf, ip, repcnt)
	}

	# Save repeat count
	EXT_REPCNT(cur_ext)=repcnt

	#--------------------------------------------------------
	# if the repeat count variable is a vector, then set flag
	#--------------------------------------------------------
	if (repcnt > 1)
	{
   	   is_vector = true
	}

	# convert FITS typedef to our typedef (QPOE)
	switch(tform[i]){
	case 'B':
	    call strcpy("t", tibuf, SZ_TYPEDEF)	# This needs converting later
						# to 's' for short (from byte)
	case 'L':
	    call strcpy("b", tibuf, SZ_TYPEDEF)
	case 'X':
	    call printf("bit array not yet implemented - skipping\n")
	    rtype = SKIP
	    itype[1] = EOS
	    otype[1] = EOS
	    ptype[1] = EOS
	    return
	case 'I':
	    call strcpy("s", tibuf, SZ_TYPEDEF)
	case 'J':
	    call strcpy("i", tibuf, SZ_TYPEDEF)
	case 'A':
	    call printf("char strings not yet implemented - skipping\n")
	    rtype = SKIP
	    itype[1] = EOS
	    otype[1] = EOS
	    ptype[1] = EOS
	    return
	case 'E':
	    call strcpy("r", tibuf, SZ_TYPEDEF)
	case 'D':
	    call strcpy("d", tibuf, SZ_TYPEDEF)
	default:
	    call printf("unknown TFORM type (%s) - skipping\n")
	    call pargstr(tform)
	    itype[1] = EOS
	    otype[1] = EOS
	    ptype[1] = EOS
	    rtype = SKIP
	    return
	}
	# add the required number of typedefs

	# calculate output data type
        tobuf[1]=conv_type(EXT(ext,k),tibuf,scale)
	tobuf[2]=EOS

	do j=1, repcnt{
	    # add the input data type to itype
	    call strcat(tibuf, itype, SZ_TYPEDEF)

	    # add the output data type to otype & ptype
	    call strcat(tobuf, otype, SZ_TYPEDEF)
	    call strcat(tobuf, ptype, SZ_TYPEDEF)

	    # add x or y identifier for events
	    if( (rtype == EVENT) && (j==1) ){

		if( streq(key_x, ttype))
		    call strcat(":x", otype, SZ_TYPEDEF)
		else if( streq(key_y, ttype))
		    call strcat(":y", otype, SZ_TYPEDEF)
		# add the identifier for the pros event def
	    }
	    call strcat(":", ptype, SZ_TYPEDEF)
	    ttype[9] = EOS
	    call strcat(ttype, ptype, SZ_TYPEDEF)

	    #---------------------------------------------------------
	    # if vector, then concatenate the index to the end of the
	    # PROS type macro name
	    #--------------------------------------------------------- 
	    if (is_vector)
	    {
		call sprintf(tempbuf, SZ_LINE, "%d")
		call pargi(j)
		call strcat(tempbuf, ptype, SZ_TYPEDEF)
	    }

	    # add a separator
	    call strcat(",", itype, SZ_TYPEDEF)
	    call strcat(",", otype, SZ_TYPEDEF)
	    call strcat(",", ptype, SZ_TYPEDEF)
	}
    }
    # over-write the last comma with a "}"
    call strcpy("}", itype[strlen(itype)], SZ_TYPEDEF)
    call strcpy("}", otype[strlen(otype)], SZ_TYPEDEF)
    call strcpy("}", ptype[strlen(ptype)], SZ_TYPEDEF)
    # convert to lower case
    call strlwr(itype)
    call strlwr(otype)
    call strlwr(ptype)

end
