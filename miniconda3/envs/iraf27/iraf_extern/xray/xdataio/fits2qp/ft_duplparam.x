#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_duplparam.x,v 11.0 1997/11/06 16:34:35 prosb Exp $
#$Log: ft_duplparam.x,v $
#Revision 11.0  1997/11/06 16:34:35  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:14  prosb
#General Release 2.3
#
#Revision 6.1  93/12/14  18:18:35  mo
#MC	12/13/93		Add checks for duplicate parameters and
#				a display parameter to suppress them
#				when necessary
#
#Revision 5.0  92/10/29  21:37:07  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:22  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:11  jmoran
#Initial revision
#
#
# Module:       ft_duplparam.x
# Project:      PROS -- ROSAT RSDC
# Purpose:
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:
#               {n} <who> -- <does what> -- <when>
#

include "cards.h"

procedure ft_duplparam(qp, card, display)

pointer qp		# i:
pointer card		# i: 
int	display		# i:

bool    fp_equald()
bool    fp_equalr()
bool    warning
int     strncmp()

char    tempstr[SZ_CARDVSTR]
bool    bval, qp_getb()
short   sval, qp_gets()
int     ival, qp_geti()
long    lval, qp_getl()
real    rval, qp_getr()
double  dval, qp_getd()
complex xval, qp_getx()
int     dummy, qp_gstr()

int	val, len, flag
int	qp_queryf()
char	type[SZ_LINE]
char	str[SZ_LINE]

begin

#--------------------------------------------------------------------------
# This routine is called only when a duplicate card is found that is not
# a COMMENT or HISTORY card.  The card type is determined and the existing
# card value is retrieved.  The retrieved value is compared with the
# current value.  If the values are the same, no warning message is
# given.  If the values are different, a warning message is issued.
#--------------------------------------------------------------------------
        warning = FALSE
        switch (CARDTY(card))
        {
            case TY_BOOL:
	    val = qp_queryf(qp, Memc[CARDNA(card)], type, len, str, flag)
	    if (type[1] == 'b')
	    { 
                bval = qp_getb(qp, Memc[CARDNA(card)])
                if( (bval && CARDVB(card)) || !(bval && CARDVB(card)) )
		{
		if( display >= 2 )
        	{
		    call printf("WARNING: data types differ for card *%s*\n")
		    call pargstr(Memc[CARDNA(card)])
		}
		}
	    }
	    else
	    {
                   warning = TRUE
	    }

            case TY_SHORT:
            val = qp_queryf(qp, Memc[CARDNA(card)], type, len, str, flag)
            if (type[1] == 's')
            {
                sval = qp_gets(qp, Memc[CARDNA(card)])
                if (sval != CARDVS(card))
                   warning = TRUE
            }
            else
            {
		if( display >= 2 )
        	{
                call printf("WARNING: data types differ for card *%s*\n")
                call pargstr(Memc[CARDNA(card)])
		}
            }


            case TY_INT:
            val = qp_queryf(qp, Memc[CARDNA(card)], type, len, str, flag)
            if (type[1] == 'i')
            {
                ival = qp_geti(qp, Memc[CARDNA(card)])
                if (ival != CARDVI(card))
                   warning = TRUE
            }
            else
            {
		if( display >= 2 )
        	{
                call printf("WARNING: data types differ for card *%s*\n")
                call pargstr(Memc[CARDNA(card)])
		}
            }

            case TY_LONG:
            val = qp_queryf(qp, Memc[CARDNA(card)], type, len, str, flag)
            if (type[1] == 'l')
            {
                lval= qp_getl(qp, Memc[CARDNA(card)])
                if (lval != CARDVL(card))
                   warning = TRUE
            }
            else
            {
		if( display >= 2 )
        	{
                call printf("WARNING: data types differ for card *%s*\n")
                call pargstr(Memc[CARDNA(card)])
		}
            }

            case TY_REAL:
            val = qp_queryf(qp, Memc[CARDNA(card)], type, len, str, flag)
            if (type[1] == 'r')
            {
                rval = qp_getr(qp, Memc[CARDNA(card)])
                if (!(fp_equalr(rval, CARDVR(card))))
                   warning = TRUE
            }
            else
            {
		if( display >= 2 )
        	{
                call printf("WARNING: data types differ for card *%s*\n")
                call pargstr(Memc[CARDNA(card)])
		}
            }

            case TY_DOUBLE:
            val = qp_queryf(qp, Memc[CARDNA(card)], type, len, str, flag)
            if (type[1] == 'd')
            {
                dval = qp_getd(qp, Memc[CARDNA(card)])
                if (!(fp_equald(dval, CARDVD(card))))
                   warning = TRUE
            }
            else
            {
		if( display >= 2 )
        	{
                call printf("WARNING: data types differ for card *%s*\n")
                call pargstr(Memc[CARDNA(card)])
		}
            }

            case TY_COMPLEX:
            val = qp_queryf(qp, Memc[CARDNA(card)], type, len, str, flag)
            if (type[1] == 'x')
            {
                xval = qp_getx(qp, Memc[CARDNA(card)])
                if (xval != CARDVX(card))
                   warning = TRUE
            }
            else
            {
		if( display >= 2 )
        	{
                call printf("WARNING: data types differ for card *%s*\n")
                call pargstr(Memc[CARDNA(card)])
		}
            }

            case TY_CHAR:
            val = qp_queryf(qp, Memc[CARDNA(card)], type, len, str, flag)
            if (type[1] == 'c')
            {
                dummy = qp_gstr(qp, Memc[CARDNA(card)], tempstr, SZ_CARDVSTR)
                call strupr(tempstr)
                call strupr(Memc[CARDVSTR(card)])
                if (strncmp(tempstr, Memc[CARDVSTR(card)], SZ_CARDVSTR) != 0)
                  warning = TRUE
            }
            else
            {
		if( display >= 2 )
        	{
	        call printf("WARNING: data types differ for card *%s*\n")
                call pargstr(Memc[CARDNA(card)])
		}
	    }

            default:
                call errori("bad FITS card type", CARDTY(card))
        }

        if (warning && display >= 2)
        {
           call printf("warning: card %s exists and has different value.\n")
           call pargstr(Memc[CARDNA(card)])
           call printf("The existing card is being overwritten.\n")
           call flush(STDOUT)
        }
end


