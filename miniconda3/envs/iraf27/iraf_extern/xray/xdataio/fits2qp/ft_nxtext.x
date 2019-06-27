#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_nxtext.x,v 11.0 1997/11/06 16:35:36 prosb Exp $
#$Log: ft_nxtext.x,v $
#Revision 11.0  1997/11/06 16:35:36  prosb
#General Release 2.5
#
#Revision 9.7  1997/09/18 22:52:01  prosb
#JCC(9/16/97) - add a new flag isAXAF. If it is not an AXAF data,
#               "call ft_addparam" for cases "200-220".
#               [ Correct OPTAXISX/Y, XS-INPXX / XS-INPXY for rosat ]
#
#Revision 9.6  1997/09/15 21:47:16  prosb
#JCC(9/15/97)- same as revision9.3.
#
#Revision 9.3  1997/05/07 18:16:48  prosb
#JCC(5/7/97) - add comments.
#
#Revision 9.2  1997/05/07  15:11:14  prosb
# MC added 2 more flags for XRCF/format=3  7/26/96
# 
#Revision 9.1  1996/07/02  20:11:49  prosb
############################################################################
# JCC - Updated to run fits2qp & qp2fits for AXAF data.
#
# (5/7/96) - skip some keywords for acis data :
#
#      - * Commented out "call ft_addparam" for cases 200-220
#      - * Added A new case 3002 for "format" : if "format" exists in a card
#          file, then set format (QP_FORMAT) to 3.
#      - * Added a new case 3003 for "TELESCOP" : if "TELESCOP" exists in a
#          card file and its value is equal to "XRCF-HRMA" in the fits
#          header, then set format (QP_FORMAT) to 3.
#      - * Added a conditional statement to skip "call assign_wcs_ratfits"
#          for acis/hrc_lev0 data
#
#  (6/6/96) - Updated case 3002 & 3003 :
#      Delete the keyword FORMAT from the qpoe file if it is found. 
############################################################################
#Revision 9.0  1995/11/16  18:59:29  prosb
#General Release 2.4
#
#Revision 8.5  1995/02/16  21:21:14  prosb
#Modified FITS2QP to correctly apply TSCAL/TZERO on extensions with
#columns which contain an array of values.  Also modified FITS2QP to
#not be so picky as to force the final index number to match the number
#of fields in an extension.  (I.e., if an extension has 8 columns, and
#TFIELD is set to 8, we can have "TUNIT5" as the final header card.)
#
#Revision 8.4  94/09/30  16:53:17  dvs
#Only write out unknown headers to QPOE if we think we're in the
#EVENT header.
#
#Revision 8.3  94/09/16  16:37:57  dvs
#Modified code to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.2  94/06/30  16:53:09  mo
#MC	6/30/94		Update to recognise BINTABLE/WCS with TCD matrix
#
#Revision 8.0  94/06/27  15:21:15  prosb
#General Release 2.3.1
#
#Revision 7.2  94/03/02  14:16:06  mo
#MC	3/2/94		no changes
#
#Revision 7.1  94/02/25  11:10:42  mo
#MC	2/25/94		Clean up memory allocation, so that alloc/frees
#			can always be paired.  Remove 'knowncards' from
#			this routine since it is called in a loop - added
#			to fits2qp main task
#
#Revision 7.0  93/12/27  18:40:44  prosb
#General Release 2.3
#
#Revision 6.4  93/12/14  18:05:19  mo
#MC	12/13/93		Add TLMIN/TLMAX keyword support (ASCA)
#
#Revision 6.3  93/12/08  13:19:47  mo
#MC	12/8/93		Update with display argument and FORMAT flag
#			so it recognises REVISION =0 (or none) files
#			with new WCS keywords
#
#Revision 6.2  93/11/29  16:29:31  mo
#MC		11/29/93		Add RDF support for WCS stuff
#
#Revision 6.1  93/09/03  15:05:13  mo
#JMORAN/MC	9/3/93		Updates for RDF and DIFEVENTS
#
#Revision 5.0  92/10/29  21:37:31  prosb
#General Release 2.1
#
#Revision 1.3  92/10/01  15:12:40  jmoran
#JMORAN added support for mpe instrument
#
#Revision 1.2  92/09/23  11:36:32  jmoran
#JMORAN - MPE ASCII FITS changes
#and blank value and keyword changes
#
#Revision 1.1  92/07/13  14:10:35  jmoran
#Initial revision
#
#
# Module:       ft_nxtext.x
# Project:      PROS -- ROSAT RSDC
# Purpose:
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:
#               {n} <who> -- <does what> -- <when>
#
include <mach.h>
include <ctype.h>
include <math.h>
include <evmacro.h>
include <wfits.h>
include <coords.h>
include "cards.h"
include "fits2qp.h"
include "mpefits.h"
include "ftwcs.h"

#
#  FT_NXTEXT -- get next auxiliary extension
#  if we find the event extension, we save our place and go on
#
int procedure ft_nxtext(fd, display, name, itype, otype, ptype, 
                 nrecs, bytes, fptr, wcs, qp, ext, scale,
		 mpe_ptr, mpe_gti, mpe_instr, mpe_table, 
		 wcs_rat, wcs_rat_found, key_x, key_y,
		 revision, format, skipname, isAXAF ) 

int     fd                              # i: FITS handle
int	display				# i: display level
char    name[ARB]                       # o: name of extension
char    itype[ARB]                      # o: type definition (input)
char    otype[ARB]                      # o: type definition (output)
char    ptype[ARB]                      # o: pros type definition
int     nrecs                           # o: number of records
int     bytes                           # o: bytes per record
int     fptr                            # o: pointer to data
pointer wcs                             # o: pointer to fits wcs
pointer qp                              # i: qpoe handle
pointer ext                             # i: pointer to extension info recs
bool	scale				# i: applying TZERO/TSCAL scaling?
pointer	mpe_ptr				# o: mpe table struct pointer
bool	mpe_table			# i: is this an MPE table? 
pointer mpe_gti				# i/o: gti structure pointer
int	mpe_instr			# i: MPE ASCII instrument
pointer	wcs_rat				# i/o: wcs ratfits struct ptr
bool	wcs_rat_found			# i/o: wcs ratfits bool
char    key_x[SZ_LINE]			# i: x-index key
char    key_y[SZ_LINE]			# i: y-index key
int	revision                        # o
int	format	                        # o
char	skipname[ARB]                   #

#  MC added 2 more flags for XRCF/format=3  7/26/96
int     newformat                       # l: file's version of format
int     findwcs                         # l: is there a wcs ?

int     rtype                           # l: return type for procedure
int     ncards                          # l: number of cards read
int     extno                           # l: current extension
int     max_extno                       # l: max. extension encountered
int     i                               # l: loop counter
pointer card                            # l: card info structure
pointer cur_ext				# l: current EXT record in EXT struct
pointer sp                              # l: stack pointer
int     nextcard()                      # l: get next card
int     note()                          # l: get file position
bool    strne()                         # l: string compare
bool    streq()                         # l: string compare

int     ctoi, junk, j, k, l
int     retval,retval1,retval2
bool    blank_key
int	blank_cards

char    keyword[SZ_CARDVSTR]
char	ch
bool	key_found
int	len
int	stridx()

char    tmpname                  #JCC
int     qp_accessf()             #JCC
bool    isAXAF

include "fits2qp.com"

begin

        # mark the stack
        call smark(sp)
        # allocate card structure
        call salloc(card, SZ_CARDINFO, TY_STRUCT)
        call salloc(CARDNA(card), SZ_CARDNA, TY_CHAR)
        call salloc(CARDCO(card), SZ_CARDVSTR, TY_CHAR)
        call salloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)

        findwcs=0                # MC  7/26/96
        # allocate some space for a WCS
	if( wcs == NULL )
	{
       call calloc(wcs, LEN_FTWCS, TY_STRUCT) #JCC LEN_FTWCS=320,TY_STRUCT=10
	    do i=1,2
	        call calloc(IW_CTYPE(wcs, i), SZ_CARDVSTR, TY_CHAR)
	}

        # init variables
        name[1] = EOS
        itype[1] = EOS
        otype[1] = EOS
        nrecs = 0
        bytes = 0
        rtype = AUX
        extno = 0
	max_extno = 0

        ncards = 0
	blank_cards = 0

	key_found = false

#-------------------------------------------
# Write out the "fixed" values for MPE ASCII
#-------------------------------------------
	if (mpe_table)
	{
           call mpe_head_const(qp, card, wcs, display)
	}
	
        while( true)
        {
            blank_key = false

            retval = nextcard(fd, card, mpe_table)   
            #this retval is same as CARDID(card)          #JCC
            #call eprintf("ft_nxtext: retval = %d  \n ")  
            #call pargi(retval)   #JCC

            switch (retval)
            {   
                case -2:
                  blank_key = true
		  blank_cards = blank_cards + 1

                case -1:
                   if (ncards == 0)
		   {
		     call sfree(sp)
                     return(END)
		   }

                   else
                      call error(1, "unexpected EOF reading FITS ext. header")

                default:
                   ncards = ncards + 1
            }


            if (!blank_key)
            {
            # process the card type
            
            #CARDID(card) is actually from retval=nextcard() before #JCC
            #call eprintf("ft_nxtext:  CARDID(card)=case= %d  \n")
            #call pargi(CARDID(card))

            switch ( CARDID(card) ) {

            case 1:                                     # XTENSION
                if( strne(Memc[CARDVSTR(card)], "A3DTABLE") &&
                    strne(Memc[CARDVSTR(card)], "BINTABLE") &&
                    strne(Memc[CARDVSTR(card)], "TABLE") ){
                    call printf("unknown extension type (%s) - skipping\n")
                    call pargstr(Memc[CARDVSTR(card)])
                    rtype = SKIP
                }
            case 2:                                     # NAXIS
                if( rtype != SKIP ){
                    if( CARDVI(card) != 2 ){
                        call printf("wrong number of axes (%d) - skipping\n")
                        call pargi(CARDVI(card))
                        rtype = SKIP
                    }
                }
            case 3:                                     # BITPIX
                if( rtype != SKIP ){
                    if( CARDVI(card) != 8 ){
                        call printf("wrong bits/pixel (%d) - skipping\n")
                        call pargi(CARDVI(card))
                        rtype = SKIP
                    }
                }
                bitpix = CARDVI(card)
            case 4:                                     # NAXIS1
                bytes = CARDVI(card)
            case 5:                                     # NAXIS2
                nrecs = CARDVI(card)
            case 6:                                     # PCOUNT
                if( rtype != SKIP ){
                    if( CARDVI(card) != 0 ){
                        call printf("wrong PCOUNT (%d) - skipping\n")
                        call pargi(CARDVI(card))
                        rtype = SKIP
                    }
                }
            case 7:                                     # GCOUNT
                if( rtype != SKIP ){
                    if( CARDVI(card) != 1 ){
                        call printf("wrong GCOUNT (%d) - skipping\n")
                        call pargi(CARDVI(card))
                        rtype = SKIP
                    }
                }
            case 8:                                     # TFIELDS
                tfields = CARDVI(card)
                # allocate space for extension info records
                call salloc(ext, tfields*SZ_EXT, TY_STRUCT)
                # allocate space for char strings
                do i=1, tfields{
		    cur_ext=EXT(ext,i)
                    call salloc(EXT_FORM(cur_ext), SZ_LINE, TY_CHAR)
                    call salloc(EXT_TYPE(cur_ext), SZ_LINE, TY_CHAR)
                    call salloc(EXT_UNIT(cur_ext), SZ_LINE, TY_CHAR)
		    EXT_ZERO(cur_ext)=0.0d0
		    EXT_SCALE(cur_ext)=1.0d0
		    EXT_IS_EV_INDEX(cur_ext)=NO
		    EXT_IS_EV_INDEX(cur_ext)=NO
		    EXT_REPCNT(cur_ext)=1
                }

		call alloc_wcs_ratfits(wcs_rat, tfields)


            case 9:                                     # EXTNAME
                call strcpy(Memc[CARDVSTR(card)], name, SZ_LINE)

		if (streq(name, evname))
		{
		    rtype = EVENT
		}
		else
		   if (streq(name, skipname))
		        rtype = SKIP

            case 10:                                    # EXTVER
                ;
            case 11:                                    # TFORM<n>
                # get column number
                call ft_extno(Memc[CARDNA(card)], extno)
                # copy data type
		if( extno > 0 && extno <= tfields )
                {
		   cur_ext=EXT(ext,extno)
		   call strcpy(Memc[CARDVSTR(card)], Memc[EXT_FORM(cur_ext)],
                            SZ_LINE)
		   if (!wcs_rat_found)
		   {
		        call strcpy(Memc[CARDVSTR(card)], 
				Memc[TFORM(wcs_rat, extno)], SZ_CARDVSTR)
		   }
		}
		else
		{
		    call eprintf("WARNING: extno = 0 for card: %s")
		        call pargstr(Memc[CARDNA(card)])
		}

            case 12:                                    # TTYPE<n>
                # get column number
                call ft_extno(Memc[CARDNA(card)], extno)
                # get column name
		if( extno > 0 && extno <= tfields )
                {
		  cur_ext=EXT(ext,extno)
                  call strcpy(Memc[CARDVSTR(card)], Memc[EXT_TYPE(cur_ext)],
                            SZ_LINE)

		  # convert EXT_TYPE to lowercase
		  call strlwr(Memc[EXT_TYPE(cur_ext)])

		  # set EXT_IS_EV_INDEX if it is an event record and the
		  # name of the extension matches one of the index keys.
		  if (rtype==EVENT && ((streq(Memc[EXT_TYPE(cur_ext)],key_x)) ||
				       (streq(Memc[EXT_TYPE(cur_ext)],key_y))))
		  {
		    EXT_IS_EV_INDEX(cur_ext)=YES
		  }

		  if (!wcs_rat_found)
		  {
		    call strcpy(Memc[CARDVSTR(card)], 
				Memc[TTYPE(wcs_rat, extno)], SZ_CARDVSTR)
		  }
		}
		else
		{
		    call eprintf("WARNING: extno = 0 for card: %s")
		        call pargstr(Memc[CARDNA(card)])
		}

            case 13:                                    # TUNIT<n>
                # get column number
                call ft_extno(Memc[CARDNA(card)], extno)
                # get the units
		if( extno > 0 && extno <= tfields )
                {
		  cur_ext=EXT(ext,extno)
                  call strcpy(Memc[CARDVSTR(card)], Memc[EXT_UNIT(cur_ext)],
                            SZ_LINE)
		  if (!wcs_rat_found)
		  {
		    call strcpy(Memc[CARDVSTR(card)], 
				Memc[TUNIT(wcs_rat, extno)], SZ_CARDVSTR)
		  }
		}
		else
		{
		    call eprintf("WARNING: extno = 0 for card: %s")
		        call pargstr(Memc[CARDNA(card)])
		}

	    case 14:					#HISTORY
		if (mpe_table)
		{
                   #----------------------------------------------------
		   # Parse the MPE ASCII HISTORY record for keywords and
		   # values (including GTIs)
		   #----------------------------------------------------
		   call mpe_head_parse(qp, card, wcs, mpe_gti, 
				 	key_found, keyword, mpe_instr,display) 
		} 

	    case 16:   # TSCAL
                # get column number
                call ft_extno(Memc[CARDNA(card)], extno)
                # get the scale
                if( extno > 0 && extno <= tfields )
                {      
                   cur_ext=EXT(ext,extno)
                   EXT_SCALE(cur_ext) = CARDVD(card)
                }
                else
                {
                   call eprintf("WARNING: extno = 0 for card: %s")
                        call pargstr(Memc[CARDNA(card)])
                }
 
            case 17:   # TZERO
                # get column number
                call ft_extno(Memc[CARDNA(card)], extno)
                # get the offset
                if( extno > 0 && extno <= tfields )
                {       
                   cur_ext=EXT(ext,extno)
                   EXT_ZERO(cur_ext) = CARDVD(card)
                }
                else
                {
                   call eprintf("WARNING: extno = 0 for card: %s")
                        call pargstr(Memc[CARDNA(card)])
                }
  
            case 999:                                   # END
                break

    # WCS Cards

            # /CTYPE?/
            case 100:
                l = 6
                junk = ctoi(Memc[CARDNA(card)], l, k)

		call strcpy(Memc[CARDVSTR(card)], Memc[IW_CTYPE(wcs, k)],
			    SZ_CARDVSTR)
                IW_ISKY(wcs) = 1
            # /CDELT?/
            case 101:
                l = 6
                junk = ctoi(Memc[CARDNA(card)], l, k)
                IW_CDELT(wcs, k) = CARDVD(card)
                IW_ISKY(wcs) = 1
            # CROTA
            case 102:
                IW_CROTA(wcs) = DEGTORAD(CARDVD(card))
                IW_ISKY(wcs) = 1
            # /CRPIX?/
            case 103:
                l = 6
                junk = ctoi(Memc[CARDNA(card)], l, k)
                IW_CRPIX(wcs, k) = CARDVD(card)
                IW_ISKY(wcs) = 1
            # /CRVAL?/
            case 104:
                l = 6
                junk = ctoi(Memc[CARDNA(card)], l, k)
                IW_CRVAL(wcs, k) = CARDVD(card)
                        IW_ISKY(wcs) = 1
            # /CD?_?/
            case 105:
                l = 3
                junk = ctoi(Memc[CARDNA(card)], l, k)
                l = 5
                junk = ctoi(Memc[CARDNA(card)], l, j)
                IW_CD(wcs, k, j) = CARDVD(card)
                IW_ISCD(wcs) = 1
            # /LTV?/
            case 106:
                l = 4
                junk = ctoi(Memc[CARDNA(card)], l, k)
                IW_LTV(wcs, k) = CARDVD(card)
                IW_ISLV(wcs) = 1
            # /LTM?_?/
            case 107:
                l = 4
                junk = ctoi(Memc[CARDNA(card)], l, k)
                l = 6
                junk = ctoi(Memc[CARDNA(card)], l, j)
                IW_LTM(wcs, k, j) = CARDVD(card)
                IW_ISLM(wcs) = 1

# JCC(9/15/97) - don't comment out "call ft_addparam" for cases 200-22
#                rosat needs them.
# JCC(4/96) - Commented out "call ft_addparam" for cases 200-22
# MC(7/26/96) - added the findwcs key - so we still know if these 
#               keywords existed
	    # RATFITS: /TCTYP?*/
	    case 200:
	        len = 6
	        junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
                   call strcpy(Memc[CARDVSTR(card)], 
			       Memc[TCTYP(wcs_rat, retval)], SZ_CARDVSTR)
                   IW_ISKY(wcs) = 1
		}
		if (format != 3) format = 1     #JCC - add "if" statement
                else
                        findwcs = 1

	    # RATFITS: /TCRPX?*/
	    case 201:
#  Note case 211,212 INCLUDES case 201 - for now this code is DUPLICATED in
#	case 211 - please change in BOTH places
	        len = 6
		junk = ctoi(Memc[CARDNA(card)], len, retval)
		if (retval <= tfields)
		{
		   TCRPX(wcs_rat, retval) = CARDVD(card)
                   IW_ISKY(wcs) = 1
	        }
		if (format != 3) format = 1     #JCC - add "if" statement
                else
                        findwcs = 1

	    # RATFITS: /TCRVL?*/
	    case 202:
	        len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
		if (retval <= tfields)
                {
                   TCRVL(wcs_rat, retval) = CARDVD(card)
                   IW_ISKY(wcs) = 1
	        }
                if (format != 3) format = 1     #JCC - add "if" statement
                else
                        findwcs = 1

            # RATFITS: /TCDLT?*/
	    case 203:
		len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
		if (retval <= tfields)
                {
                   TCDLT(wcs_rat, retval) = CARDVD(card)
		   IW_ISKY(wcs) = 1
		}
                if (format != 3) format = 1     #JCC - add "if" statement
                else
                        findwcs = 1

            # RATFITS: /TCROT?*/
	    case 204:
                len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
                   TCROT(wcs_rat, retval) = DEGTORAD(CARDVD(card))
                   IW_ISKY(wcs) = 1
		}
                if (format != 3) format = 1     #JCC - add "if" statement
                else
                        findwcs = 1

            # RATFITS: /TALEN?*/
#  Note case 215,216 INCLUDES case 205 - for now this code is DUPLICATED in
#	case 215,16 - please change in BOTH places
	    case 205:
                len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
		   TALEN(wcs_rat, retval) = CARDVI(card)
		}
                if (!isAXAF) 
                   call ft_addparam(qp,card,display)  # 9/15/97
	       
	    case 206:
                len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
		   TLMIN(wcs_rat, retval) = CARDVI(card)
		}
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
	       
	    case 207:
                len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
		   TLMAX(wcs_rat, retval) = CARDVI(card)
		}
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
	       
            # RATFITS: /TCD?_?/
            case 208:
		call strcpy(Memc[CARDNA(card)],keyword,10)
		if( display >= 5)
		{
		    call printf("%s\n")
		        call pargstr(Memc[CARDNA(card)])
		}
                len = 4 
                junk = ctoi(Memc[CARDNA(card)], len, retval1)
		ch = '_'
		len = stridx(ch,Memc[CARDNA(card)]) + 1
                junk = ctoi(Memc[CARDNA(card)], len, retval2)
                if (retval1 <= tfields && retval2 <= tfields &&
		    retval1 >= 1       && retval2 >= 1 )
                {
                   TCDM(wcs_rat, retval1, retval2) = CARDVD(card)
                   IW_ISCD(wcs) = 1
		}

	    case 211:
#  Note case 211 INCLUDES case 201 - for now this code is DUPLICATED in
#	case 211 - please change in BOTH places
#		QP_INSTPXX(qphead) = CARDVD(card)
#JCC(9/15/97)-comment:
#             211 in wcshri.cards is OPTAXISX which will be same in qpoe hdr.
#
	        len = 6
		junk = ctoi(Memc[CARDNA(card)], len, retval)
		if (retval <= tfields)
		{
		   TCRPX(wcs_rat, retval) = CARDVD(card)
	        }
		call strcpy("OPTAXISX",Memc[CARDNA(card)],SZ_CARDNA)
#		call printf("name %s\n")
#		    call pargstr(Memc[CARDNA(card)])
#		call printf("value %.2f\n")
#		    call pargd(CARDVD(card))
                if (!isAXAF)
		   call ft_addparam(qp, card,display)   # 9/15/97

	    case 212:
#  Note case 212 INCLUDES case 201 - for now this code is DUPLICATED in
#	case 211&201 - please change in BOTH places
#		INSTPXY(qphead) = CARDVD(card)
#JCC(9/15/97)-comment:
#  212 in wcshri.cards is OPTAXISY which will be same in qpoe hdr.
#
	        len = 6
		junk = ctoi(Memc[CARDNA(card)], len, retval)
		if (retval <= tfields)
		{
		   TCRPX(wcs_rat, retval) = CARDVD(card)
	        }
		call strcpy("OPTAXISY",Memc[CARDNA(card)],SZ_CARDNA)
                if (!isAXAF)
		   call ft_addparam(qp, card,display)   # 9/15/97

	    case 213:
#  Note case 211 INCLUDES case 201 - for now this code is DUPLICATED in
#	case 211 - please change in BOTH places
#JCC(9/15/97)-comment:
#  213 in wcshri.cards is TCDLT1 which will be XS-INPXX in qpoe hdr.
#
	        len = 6
#		call printf("value %.2d\n")
#		    call pargd(CARDVD(card))
		junk = ctoi(Memc[CARDNA(card)], len, retval)
		if (retval <= tfields)
		{
		   TCDLT(wcs_rat, retval) = CARDVD(card)
	        }
		call strcpy("XS-INPXX",Memc[CARDNA(card)],SZ_CARDNA)
#		call printf("name %s\n")
#		    call pargstr(Memc[CARDNA(card)])
#		call printf("value %.2f\n")
#		    call pargd(CARDVD(card))
                if (!isAXAF)
		   call ft_addparam(qp, card,display)   # 9/15/97

	    case 214:
#  Note case 214 INCLUDES case 204 - for now this code is DUPLICATED in
#	case 204 - please change in BOTH places
#JCC(9/15/97)-comment:
#  214 in wcshri.cards is TCDLT2 which will be XS-INPXY in qpoe hdr.
#
	        len = 6
#		call printf("value %.2d\n")
#		    call pargd(CARDVD(card))
		junk = ctoi(Memc[CARDNA(card)], len, retval)
		if (retval <= tfields)
		{
		   TCDLT(wcs_rat, retval) = CARDVD(card)
	        }
		call strcpy("XS-INPXY",Memc[CARDNA(card)],SZ_CARDNA)
                if (!isAXAF)
		   call ft_addparam(qp, card,display)   # 9/15/97

	    case 215:
                len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
		   TALEN(wcs_rat, retval) = CARDVI(card)
		}
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
		call strcpy("PHACHANS",Memc[CARDNA(card)],SZ_CARDNA)
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
		call strcpy("MAXPHA",Memc[CARDNA(card)],SZ_CARDNA)
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
		call strcpy("MINPHA",Memc[CARDNA(card)],SZ_CARDNA)
		CARDVI(card) = 1
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
	       
	    case 216:
                len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
		   TALEN(wcs_rat, retval) = CARDVI(card)
		}
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
		call strcpy("PICHANS",Memc[CARDNA(card)],SZ_CARDNA)
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
		call strcpy("MAXPI",Memc[CARDNA(card)],SZ_CARDNA)
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
		call strcpy("MINPI",Memc[CARDNA(card)],SZ_CARDNA)
		CARDVI(card) = 1
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
	       
	    case 217:
                len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
		   TALEN(wcs_rat, retval) = CARDVI(card)
		}
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
		call strcpy("XS-XDET",Memc[CARDNA(card)],SZ_CARDNA)
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
	       
	    case 218:
                len = 6
                junk = ctoi(Memc[CARDNA(card)], len, retval)
                if (retval <= tfields)
                {
		   TALEN(wcs_rat, retval) = CARDVI(card)
		}
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
		call strcpy("XS-YDET",Memc[CARDNA(card)],SZ_CARDNA)
                if (!isAXAF)
                   call ft_addparam(qp, card,display)   # 9/15/97
	       
            # Sampled Coordinate vector
            # qpoe dimension info => this is the event table
            case 2001:
                naxlen = CARDVI(card)
                IW_NDIM(wcs) = naxlen
            case 2002:
                axlen1 = CARDVI(card)
            case 2003:
                axlen2 = CARDVI(card)

	    case 2004:
                revision = CARDVI(card)
                call ft_addparam(qp, card,display)

	    case 2005:
#           format = CARDVI(card)     # MC - replaced with following
#  MC (7/26/96) -
#  Check the result from case 3003 before overriding
#       XRCF-AXAF FORCES format = 3 to eliminate ROSAT keys
                newformat = CARDVI(card)
                call printf("format: %d newformat: %d\n")
                    call pargi(format)
                    call pargi(newformat)
                #JCC (8/5/96)  if( newformat > format)
                 if(( newformat > format)&&(newformat==3 ))
                {
                    format = newformat
                    #CARDVI(card) = format
                }                     # end 
                else
                {   format =  3            }
                    # CARDVI(card) = format   }     #JCC - 8/5/96

                CARDVI(card) = format    #JCC added
                call ft_addparam(qp, card,display)   # put it back JCC 8/5/96 ?

# JCC 8/5/96 - try to add FORMAT to qpoe header 
#JCC              if( qp_accessf(qp,"FORMAT") == YES )
#JCC                  call qp_deletef(qp, "FORMAT")
#JCC               call qpx_addf(qp, "FORMAT","i",1,"AXAF lab data",0)
#JCC               call qp_puti(qp, "FORMAT", format)

	    case 3000:

            # add unknown cards as parameters

	    case 3001:
#               call eprintf("case 3001, format=2  \n")
                format = 2 
                call ft_addparam(qp, card,display)

#JCC (4/96)*********************begin ***************
#JCC(4/96)- Added a  new case for "format" : if "format" exists in a card 
#JCC      - file, then set format (QP_FORMAT) to 3.
	    case 3002:   
                #call eprintf("case 3002, format=3  \n")  
                format = 3
#JCC(4/96)- Add keyword "FORMAT" to qpoe file, QP_FORMAT = format = 3
                #if( qp_accessf(qp,"format")==NO )
                #{ call qpx_addf(qp, "format","i",1,"AXAF lab data",0)
                #  call qp_puti(qp, "format", format)   }
                if( qp_accessf(qp,"FORMAT") == YES )
                   call qp_deletef(qp, "FORMAT")
                call qpx_addf(qp, "FORMAT","i",1,"AXAF lab data",0)
                call qp_puti(qp, "FORMAT", format)


#JCC(4/96)- Added a new case for "TELESCOP" : if "TELESCOP" exists in a 
#JCC      - card file and its value is equal to "XRCF-HRMA" in the fits 
#JCC      - header, then set format (QP_FORMAT) to 3.
	    case 3003:   
                #JCC- tmpname=Memc[CARDNA(card)]=TELESCOP
                call strcpy(Memc[CARDNA(card)], tmpname, SZ_CARDNA)

                # get the value of TELESCOP : it should be "XRCF-HRMA"
                call strcpy(Memc[CARDVSTR(card)], name, SZ_LINE)

                #JCC - print out the value of TELESCOP
                #call printf("ft_nxtext.x:  value of TELESCOP=  (%s)\n")
                #call pargstr(name)

                #************************************
                #JCC- TELESCOP== "XRCF-HRMA" for acis/hrc data
                #************************************
                if (streq(name, "XRCF-HRMA"))
                {  format = 3 
                   #call eprintf("\nft_nxtext.x: case3003 format=3\n")

                #if( qp_accessf(qp,"format")==NO )
                #{ call eprintf("qp_accessf(FORMAT)\n " )
                #  call qpx_addf(qp, "format","i",1,"AXAF lab data",0)
                #  call qp_puti(qp, "format", format)  }
                   if( qp_accessf(qp,"FORMAT") == YES )
                      call qp_deletef(qp, "FORMAT")
                   call qpx_addf(qp, "FORMAT","i",1,"AXAF lab data",0)
                   call qp_puti(qp, "FORMAT", format)
                }
                #call eprintf(" ft_nxtext.x: Memc[CARDNA(card)]== %s \n  " )
                #call pargstr(Memc[CARDNA(card)])
#JCC (4/96)********************** end ***************

            case 0, 1001:
                #call eprintf("case 0,1001, TELESCOP\n")

                if (rtype==EVENT)
		{
                    call ft_addparam(qp, card,display)
		}
            # this should never happen!
            default:
                call errori(1, "internal card error: unknown card type",
                                CARDID(card))
            }   # switch statement
	    max_extno = max(max_extno, extno)

            }   # if statement
        }       # while statement


#-----------------------------------------------------------------------
# If the value "naxlen" was set in the parameter file, override what was
# written in the header.  This parameter should be set in the parameter
# file for MPE ASCII files, else "IW_NDIM" won't be set at all which
# will cause problems for the "mwcs" routines
#-----------------------------------------------------------------------
        if (naxlen > 0)
        {
           IW_NDIM(wcs) = naxlen
        }

        # make sure we have the right number of fields
        if( max_extno != tfields )
            call error(1, "tfields does not match number of fields in ext")
	
        # make up the type def string
        if ( tfields !=0 )
	{
	    if (mpe_table)
	      call mpe_typedef(ext, tfields, key_x, key_y, rtype, 
				itype, otype, ptype, mpe_ptr)
	    else	
              call ft_typedef(ext, tfields, key_x, key_y, rtype,
				 scale, itype, otype, ptype)
	}	


        # skip to end of header
        call ft_skip(fd, (ncards + blank_cards)*LEN_CARD/SZB_CHAR, YES)

        # get current file position, in case this is the event table
        fptr = note(fd)

        # free up stack space
        call sfree(sp)

#---------------------------------------------------------------
# If this is a Revision 1 file (Rationalized FITS), then assign
# the wcs_rat structure to the "IW" wcs structure IF the return
# type is EVENT.  The variable wcs_rat_found is VERY important
# here.  It is operating like a single tape Turing machine that
# can't look ahead, so the wcs space is alloc'ed every time
# through this routine (ft_nxtext) and freed as long as the type 
# isn't EVENT.  Don't alter the following logic until you trace it
# through and fully understand the implications.       
#---------------------------------------------------------------
	if (revision >= REV1_VAL  || format >= REV1_VAL )
	{  

        #JCC- axlen1, axlen2, naxlen=1024,1024, 2   for  acis level 0
        #JCC- axlen1, axlen2, naxlen=64,64,3        for  hrc  level 0
        #JCC - Added a conditional statement to skip the following 
        #JCC - if it is acis/hrc_lev0 data.

#       if ((format != 3) || (axlen1 <= 0) || (axlen2<= 0))  #JCC added
        if ( (format >= REV1_VAL) || (findwcs==1) || (axlen1 <= 0) || (axlen2<=
0))  #JCC added - MC changes format!=3 -> format >=REV1_VAL and findwcs==1
	{                
           if (rtype == EVENT) 
	   {  
              #call eprintf("format >= 1, rtype==EVENT \n") #JCC

	      wcs_rat_found = true
              if ((IW_NDIM(wcs) <= 0) && (naxlen <= 0))
	      {
	          naxlen = DEFAULT_AXLEN
                  #call eprintf(" naxlen = DEFAULT_AXLEN \n") #JCC
	      }

              call assign_wcs_ratfits(wcs, wcs_rat, tfields, key_x, key_y,
                                      axlen1, axlen2, naxlen, display)
	   }
        }
 #call eprintf("\nft_nxtext.x: axlen1= %d, axlen2 =%d,naxlen=%d \n") #JCC
 #call pargi(axlen1)     #JCC
 #call pargi(axlen2)     #JCC
 #call pargi(naxlen)     #JCC

 #call eprintf("\nft_nxtext.x: IW_ISKY(wcs) = %d \n") #JCC
 #call pargi(IW_ISKY(wcs))     #JCC
	}

        call free_wcs_ratfits(wcs_rat, tfields)
        # return the type
        return(rtype)
end
