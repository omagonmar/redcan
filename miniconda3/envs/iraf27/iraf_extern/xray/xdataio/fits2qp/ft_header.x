#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_header.x,v 11.0 1997/11/06 16:35:33 prosb Exp $
#$Log: ft_header.x,v $
#Revision 11.0  1997/11/06 16:35:33  prosb
#General Release 2.5
#
#Revision 9.1  1997/06/06 20:53:48  prosb
#JCC(6/6/97)- fits2qp reads fits & qpoe cards before the call to
#             ft_header.  So we need to add case 2005.
#
#Revision 9.0  1995/11/16 18:59:08  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:53  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:12:36  mo
#MC	2/25/94		REmove 'knowncards' from here and put in
#			main routine.  Put all memory allocation on
#			stack at beginning of routine.
#
#Revision 7.0  93/12/27  18:40:23  prosb
#General Release 2.3
#
#Revision 6.2  93/12/14  18:19:21  mo
#MC	12/13/92		Add display parameter
#
#Revision 6.1  93/11/29  16:22:33  mo
#MC	11/29/93		Add case 2004 for RDF and update qpx_addf
#
#Revision 5.0  92/10/29  21:37:14  prosb
#General Release 2.1
#
#Revision 1.3  92/09/23  14:00:44  prosb
#JMORAN - clobber was wrong type 
#
#Revision 1.2  92/09/23  11:34:13  jmoran
#JMORAN - MPE ASCII FITS changes
# and blank value and keyword changes
#
#Revision 1.1  92/07/13  14:10:24  jmoran
#Initial revision
#
#
# Module:	ft_header.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <mach.h>
include <evmacro.h>
include <wfits.h>
include "fits2qp.h"
include "cards.h"

#
#  FT_HEADER -- process the FITS header, putting params to a qpoe file
#
procedure  ft_header(fd, qp, qpname, clobber, mpe_table, display)

int	fd				# i: FITS file handle
int	qp				# i: QPOE file handle
char	qpname[ARB]			# i: input QPOE file name
bool	clobber				# i: OK to clobber output file?
bool 	mpe_table
int	display				# i: display level
int	ncards				# number of cards read
#char	name[SZ_PATHNAME]		# name of defs file
char	foo[SZ_PATHNAME]		# dummy temp name
char	goo[SZ_PATHNAME]		# dummy temp name
pointer	card				# card info structure
pointer	sp				# stack pointer
int	nextcard()			# get next card
#bool	knowncards()			# define known cards
bool	strne()
int	fnroot(),tf

int     retval
bool    blank_key
int	blank_cards

include "fits2qp.com"

begin
	# mark the stack
	call smark(sp)
	# allocate card structure
	call salloc(card, SZ_CARDINFO, TY_STRUCT)
	call salloc(CARDNA(card), SZ_CARDNA, TY_CHAR)
	call salloc(CARDCO(card), SZ_CARDVSTR, TY_CHAR)
	call salloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)

#	# define known cards
#	call clgstr("fits_cards", name, SZ_PATHNAME)
#	if( !knowncards(name) )
#	    call errstr(1, "can't open fits defs file", name)
#	call clgstr("wcs_cards", name, SZ_PATHNAME)
#	if( !knowncards(name) )
#	    call errstr(1, "can't open wcs defs file", name)
#	call clgstr("qpoe_cards", name, SZ_PATHNAME)
#	if( !knowncards(name) )
#	    call errstr(1, "can't open qpoe defs file", name)
#
	# init total dimensions of all axis (for skipping image)
	tnaxis = 0

	# process the FITS header
	ncards = 0
	blank_cards = 0
	while( true ) 
	{
	    blank_key = false
            retval = nextcard(fd, card, mpe_table)

            switch (retval)
            {
                case -2:
                  blank_key = true
		  blank_cards = blank_cards + 1

                case -1:
                      call error(1, "unexpected EOF reading FITS header")

                default:
                   ncards = ncards + 1
            }


            if (!blank_key)
            {
            if ( ncards == 1 && CARDID(card) != 1 )
                call error(1,"SIMPLE is not the 1st card! Not standard FITS")

	    # process the card type
	    switch ( CARDID(card) ) {
	    # SIMPLE
	    case 1:
		if ( ncards != 1  )
		  call error(1,"SIMPLE is not the 1st card! Not standard FITS")
	    # NAXIS
	    case 2:
		naxis  = CARDVI(card)
	    # NAXIS<n>
	    case 3:
		tnaxis = tnaxis + CARDVI(card)
	    # BITPIX
	    case 4:
		bitpix = CARDVI(card)
	    # EXTEND
	    case 5:
		if( !CARDVB(card) )
		    call error(1, "EXTEND must be TRUE to have extensions!")
	    # DATE
	    case 10:
		;
	    # HISTORY
	    case 11:
		call ft_addparam(qp, card, display)
	    # TITLE
	    case 12:
		call ft_addparam(qp, card, display)
	    # IRAFNAME
	    case 13:
		call ft_addparam(qp, card, display)
	    # QPOENAME
	    case 14:
	    {
		call strcpy( Memc[CARDVSTR(card)], qpoename, SZ_CARDVSTR)
		call strlwr(qpoename)
#		if( qpoe )
		if( qpoe ){
#  Take the pathname off the user name and prepend to the INTERNAL FITS QPOENAME
#		    call printf("fits_rename\n")
#		    call flush(STDOUT)
		    call fits_rename(qpoename,qpname)
#		    call printf("fnroot\n")
#		    call flush(STDOUT)
		    tf = fnroot(qpoename, foo, SZ_PATHNAME)
#		    call printf("fnroot\n")
#		    call flush(STDOUT)
		    tf = fnroot(qpname, goo, SZ_PATHNAME)
#		    call printf("clobbername\n")
#		    call flush(STDOUT)
		    if( strne(foo, goo) )
	    	        call clobbername(qpoename, foo, clobber, SZ_PATHNAME)
		    else
		        qpoe = FALSE  # If filenames are =, don't rename at end
		}
#		call printf("addparam\n")
#		call flush(STDOUT)
		call ft_addparam(qp, card, display)
	    }
	    # TFORM
	    case 21:
#		call ft_addparam(qp, card, display)
	    # TTYPE
	    case 22:
#		call ft_addparam(qp, card, display)
	    # TUNIT
	    case 23:
#		call ft_addparam(qp, card, display)
	    # END
	    case 999:
		break

	    # WCS cards (Skip)
	    case 100, 101, 102, 103, 104, 105, 106, 107:
		next

	    # event table name
	    case 1000:
		call strcpy(Memc[CARDVSTR(card)], evname, SZ_CARDVSTR)
#		call mfree(CARDVSTR(card), TY_CHAR)
	    # card is unknown - add it as a parameter
	    case 0, 1001:
		call ft_addparam(qp, card, display)
#  If there are QPOE axis dimensions in the main header, they can be skipped
#	they are not useful here
	    case 2001, 2002, 2003, 2004, 2005:
		next
	    case 3000:
#                call strcpy("OBSID",Memc[CARDNA(card)],SZ_CARDNA)
#                call ft_addparam(qp, card, display)

	    # this should never happen!
	    default:
		call errori(1, "internal card error: unknown card type",
				CARDID(card))
	    } # switch statement
	    } # if statement
	} # while statement

        call qpx_addf(qp, "defattr1", "c", SZ_LINE,
                        "exposure time (seconds)",0)
        call qp_pstr(qp, "defattr1", "EXPTIME = integral time:d")
 
#        call mfree(CARDVSTR(card), TY_CHAR)
	# skip to end of header
	call ft_skip(fd, (blank_cards + ncards)*LEN_CARD/SZB_CHAR, YES)

	# zap all symbol table space
#	call zapknown()

	# free up stack space
	call sfree(sp)

end

