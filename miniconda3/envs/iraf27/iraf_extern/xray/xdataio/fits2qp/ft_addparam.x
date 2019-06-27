#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_addparam.x,v 11.0 1997/11/06 16:35:49 prosb Exp $
#$Log: ft_addparam.x,v $
#Revision 11.0  1997/11/06 16:35:49  prosb
#General Release 2.5
#
#Revision 9.2  1997/06/11 18:39:25  prosb
#JCC(6/11/97) - commented out "printf" for ONTIME.
#
#Revision 9.0  1995/11/16  18:58:59  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:43  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:14:54  mo
#MC	2/25/94		Remove memory freeing - localized in ft_header
#			and ft_nxtext where it is alloced.
#
#Revision 7.0  93/12/27  18:40:12  prosb
#General Release 2.3
#
#Revision 6.2  93/12/14  18:18:01  mo
#MC	12/13/93	add display parameter
#
#Revision 6.1  93/11/29  16:15:05  mo
#MC	11/29/93		update from qp_addf to qpx_addf
#
#Revision 6.0  93/05/24  16:24:58  prosb
#General Release 2.2
#
#Revision 5.1  92/11/20  15:39:36  mo
#MC	11/06/92	Recognise the 'OBJECT' FITS card for QPOE/title
#
#Revision 5.0  92/10/29  21:37:04  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:33:30  jmoran
#JMORAN - cleaned up old commented out code
#
#Revision 1.1  92/07/13  14:09:31  jmoran
#Initial revision
#
#
# Module:	ft_addparam.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include "cards.h"

#
#  FT_ADDPARAM -- add a fits param to a qpoe file
#
procedure ft_addparam(qp, card, display)

pointer	qp				# i: qpoe handle
pointer	card				# i: card structure
int	display				# i: display level
int	len				# l: length of string param
int	qp_accessf()			# l: qpoe param access
int	strlen()			# l: string length
bool	streq()				# string compare
bool	strne()				# string compare

begin


#  Let's agree to make ALL QPOE parameters UPPER CASE
	call strupr(Memc[CARDNA(card)])
#  The FITS/OBJECT keyword should become the QPOE/title keyword
        if(streq(Memc[CARDNA(card)],"OBJECT") )
	    call strcpy("TITLE",Memc[CARDNA(card)],SZ_CARDNA)
#  It appears that TITLE must be lower case for IRAF compatibility
	if( streq(Memc[CARDNA(card)],"TITLE") ){
	    call strlwr(Memc[CARDNA(card)])
	    call strlwr(Memc[CARDCO(card)])
	}

# JCC(6/5/97) - check ONTIME, LIVETIME
        #if( streq(Memc[CARDNA(card)],"ONTIME"))
        #{   
            #call printf("ft_addparam:  CARDNA=%15s   CARDTY=%4d\n")
            #call pargstr(Memc[CARDNA(card)])
            #call pargi(CARDTY(card))
        #}


        if (qp_accessf(qp, Memc[CARDNA(card)]) == YES)
        {
            if (strne(Memc[CARDNA(card)],"HISTORY") &&
                strne(Memc[CARDNA(card)],"COMMENT"))
            {
                call ft_duplparam(qp, card, display)
            }
            call qp_deletef(qp, Memc[CARDNA(card)])

        }

	switch ( CARDTY(card) ) {
	    case TY_BOOL:
		call qpx_addf(qp, Memc[CARDNA(card)], "b", 1,
				 Memc[CARDCO(card)], 0)
		call qp_putb(qp, Memc[CARDNA(card)], CARDVB(card))
	    case TY_SHORT:
		call qpx_addf(qp, Memc[CARDNA(card)], "s", 1,
				 Memc[CARDCO(card)], 0)
		call qp_puts(qp, Memc[CARDNA(card)], CARDVS(card))
	    case TY_INT:
		call qpx_addf(qp, Memc[CARDNA(card)], "i", 1,
				 Memc[CARDCO(card)], 0)
		call qp_puti(qp, Memc[CARDNA(card)], CARDVI(card))
	    case TY_LONG:
		call qpx_addf(qp, Memc[CARDNA(card)], "l", 1,
				 Memc[CARDCO(card)], 0)
		call qp_putl(qp, Memc[CARDNA(card)], CARDVL(card))
	    case TY_REAL:
		call qpx_addf(qp, Memc[CARDNA(card)], "r", 1,
				 Memc[CARDCO(card)], 0)
		call qp_putr(qp, Memc[CARDNA(card)], CARDVR(card))
	    case TY_DOUBLE:
		call qpx_addf(qp, Memc[CARDNA(card)], "d", 1,
				 Memc[CARDCO(card)], 0)
		call qp_putd(qp, Memc[CARDNA(card)], CARDVD(card))
	    case TY_COMPLEX:
		call qpx_addf(qp, Memc[CARDNA(card)], "x", 1,
				 Memc[CARDCO(card)], 0)
		call qp_putx(qp, Memc[CARDNA(card)], CARDVX(card))
	    case TY_CHAR:
		len = max(SZ_LINE, strlen(Memc[CARDVSTR(card)]))
		call qpx_addf(qp, Memc[CARDNA(card)], "c", len,
				 Memc[CARDCO(card)], 0)
		call qp_pstr(qp, Memc[CARDNA(card)], Memc[CARDVSTR(card)])
#		call mfree(CARDVSTR(card), TY_CHAR)
	    default:
	        call errori("bad FITS card type", CARDTY(card))
	}

end

