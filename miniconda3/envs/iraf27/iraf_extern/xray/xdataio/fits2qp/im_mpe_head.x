# $Header: /home/pros/xray/xdataio/fits2qp/RCS/im_mpe_head.x,v 11.0 1997/11/06 16:35:31 prosb Exp $
# $Log: im_mpe_head.x,v $
# Revision 11.0  1997/11/06 16:35:31  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:59:45  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:36  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/20  15:25:08  mo
#MC	5/20/94		Add dummy header keyword to recover missing 'CTYPE1'
#
#Revision 7.0  93/12/27  18:41:06  prosb
#General Release 2.3
#
#Revision 6.1  93/12/14  15:11:00  mo
#MC	12/14/93	Fix type in XS-ONTI (ONTM) keyword
#
#Revision 6.0  93/05/24  16:25:58  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:48  prosb
#General Release 2.1
#
#Revision 1.2  92/10/15  16:26:10  jmoran
#*** empty log message ***
#
#Revision 1.1  92/10/15  09:32:20  jmoran
#Initial revision
#
#
# Module:       im_mpe_head.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      Read the FITS IMAGE header cards for MPE/MIDAS ROSAT fits files
# External:     < routines which can be called by applications>
# Local:        mpe_imhead_const, mpe_imhead_parse
# Description:  This routine was adapted DIRECTLY from ft_mpe_head.x for
#		TABLE/QPOE Files, so should be kept in sync - the output
#		routines differ for each case as do the magic constants
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JMORAN initial version for TABLES/QPOS	   Sept. 92 
#               {1} MC	 -- adapted for IMAGE FITS  -- 		   Oct.  92

include <ctype.h>
include <mach.h>
include <evmacro.h>
include <fset.h>
include <coords.h>
include <rosat.h>
include <clk.h>
include "cards.h"
#include "ftwcs.h"
include "fits2qp.h"
include "mpefits.h"
include	"rfits.h"
include	"wfits.h"
include "cards.h"
	
define  IS_POINT        ($1=='.')

procedure mpe_imhead_const(fd_usr, card)

pointer fd_usr			# i: image file handle
char 	card[ARB]		# o: output FITS formated card
#pointer wcs			# o: completed MWCS structure
int	maxch			# l: length of 'card' array
int	itemp
double	temp
int	strlen()
begin

# COMMENT
	maxch = 15
	call wft_encodec ("COMMENT", "WCS static info" , maxch, 
			   card,"") 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)
#       IW_ISKY(wcs) = 1


# CTYPE1
#       call strcpy(CTYPE1, Memc[CARDVSTR(card)], SZ_CARDVSTR)
#       call malloc(IW_CTYPE(wcs, 1), SZ_CARDVSTR, TY_CHAR)
#	maxch = SZ_CARDVSTR
	maxch = strlen(CTYPE1)
	call wft_encodec ("CTYPE1", CTYPE1, maxch, card,"") 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)
#       IW_ISKY(wcs) = 1


# CTYPE2
#       call malloc(IW_CTYPE(wcs, 2), SZ_CARDVSTR, TY_CHAR)
#	maxch = SZ_CARDVSTR
	maxch = strlen(CTYPE2)
	call wft_encodec ("CTYPE2", CTYPE2, maxch, card,"") 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)

# TELESCOP
#	maxch = SZ_CARDVSTR
	maxch = strlen(TELESCOP)
	call wft_encodec ("TELESCOP", TELESCOP, maxch, card,"") 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)

# RADECSYS
#	maxch = SZ_CARDVSTR
	maxch = strlen(RADECSYS)
	call wft_encodec ("RADECSYS", RADECSYS, maxch, card,"") 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)

# EQUINOX
	call wft_encoder ("EQUINOX", ROSAT_EQUINOX, card,"",NDEC_REAL) 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)


# XS-MODE
	call wft_encodei ("XS_MODE", XS_MODE, card,"") 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)

# XS-CNTRY
#	maxch = SZ_CARDVSTR
	maxch = strlen(XS_CNTRY)
	call wft_encodec ("XS_CNTRY", XS_CNTRY, maxch, card,"") 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)

# XS-MJDRF
	itemp = ROSAT_MJDRDAY
	call wft_encodei ("XS_MJDRD",itemp, card,"") 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)
#	maxch = SZ_CARDVSTR
	maxch = strlen(temp)
	temp = ROSAT_MJDRFRAC
	call wft_encoded ("XS_MJDRF",temp, card,"",NDEC_DOUBLE) 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)

end


procedure mpe_imhead_parse(fd_usr, card, value, key_found, keyword, mpe_instr)

pointer fd_usr 			# i: image handle
char	card[ARB]		# i: pointer to card structure ( unalloced)
char	value[ARB]		# i: pointer to card structure ( unalloced)
#pointer wcs			# i/o: pointer to WCS structure
bool    key_found		# i/o: toggle switch for the history entry
				#  which comes in 2 parts KEYWORD and then VALUE
char    keyword[ARB]		# i: 
int	mpe_instr		# i:

int     idx
int	i
int     len
int	temp
int     stridx()
int	maxch
char	in_str[SZ_CARDVSTR]
char    ch
char	colon
int     strncmp()

real    rbuf
int	ibuf	
int     stat
int     sscan()
int     strlen()
int     cnt
double  sum
double	mjd
int	jdref
double	dbuf
double	jdoff
double	jd
double  mpe_ra2deg()
double  mpe_dec2deg()
double  mutjd()
double	val1,val2,val3,val4
real	blockf

pointer	utclk,refclk
char	temp_str[SZ_CARDVSTR]
char	ntemp_str[SZ_CARDVSTR]

begin
	colon = ':'

#--------------------------------------------------------
# Skip over any whitespace in the beginning of the string
#--------------------------------------------------------
        idx = 0
        while (IS_WHITE(value[idx+1]))
           idx = idx + 1

	call strcpy(value[1+idx], in_str, SZ_CARDVSTR)

#-------------------------
# Kill trailing whitespace
#-------------------------
	len = strlen(in_str)
	while (IS_WHITE(in_str[len]))
           len = len - 1
	in_str[len + 1] = EOS

	if (key_found)
	{
    	   key_found = false


	   #---------
	   # XS-XDOPT
	   #---------
    	   if (strncmp(keyword, "DET_CEN_X", 9) == 0)
    	   {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

       	      stat = sscan (in_str)
       	      call gargr (rbuf)

            call wft_encoder ("XS-XDOPT", rbuf, card,"",NDEC_REAL)
            card[LEN_CARD+1] = '\n'
            card[LEN_CARD+2] = EOS
            call putline(fd_usr,card)
    	   } # XS-XDOPT

           if (strncmp(keyword, "OBS_DUR_SEC", 11) == 0)
           {
              stat = sscan (in_str)
              call gargd (dbuf)

            call wft_encoded ("XS-ONTI", dbuf, card,"",NDEC_DOUBLE)
            card[LEN_CARD+1] = '\n'
            card[LEN_CARD+2] = EOS
            call putline(fd_usr,card)
           } # XS-ONTI

#----------
# DET_CEN_Y
#----------
    	if (strncmp(keyword, "DET_CEN_Y", 9) == 0)
    	{
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

       	   stat = sscan (in_str)
       	   call gargr (rbuf)

        call wft_encoder ("XS-YDOPT", rbuf, card,"",NDEC_REAL)
            card[LEN_CARD+1] = '\n'
            card[LEN_CARD+2] = EOS
       	call putline(fd_usr,card)
    }

#------------------------------------------------
# XS-INPXX and XS-INPXY
# Read value as arc-secs and write out as degrees
#------------------------------------------------
    if (strncmp(keyword, "DET_PIX_SIZE", 12) == 0)
    {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

       stat = sscan (in_str)
       call gargr (rbuf)

        call wft_encoder ("XS-INPXX", SATODEG(rbuf),  card,"",NDEC_REAL)
            card[LEN_CARD+1] = '\n'
            card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
        call wft_encoder ("XS-INPXY", SATODEG(rbuf), card,"",NDEC_REAL)
        card[LEN_CARD+1] = '\n'
        card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
    }

#------------------------------------------------
# XS-MINCH and XS-MAXCH
#------------------------------------------------
    if (strncmp(keyword, "RAW_SEL", 7) == 0)
    {
        stat = sscan (in_str)
        call gargr (rbuf)

	ibuf = int(rbuf+.5E0)
        call wft_encodei ("XS-MINCH", ibuf,  card,"")
        card[LEN_CARD+1] = '\n'
        card[LEN_CARD+2] = EOS

        call putline(fd_usr,card)

        call gargr (rbuf)

	ibuf = int(rbuf+.5E0)
        call wft_encodei ("XS-MAXCH", ibuf,  card,"")
        card[LEN_CARD+1] = '\n'
        card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
    }

#--------
# MJD-OBS
#--------
	if (strncmp(keyword, "OBS_CLOCK", 9) == 0)
    	{
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

       stat = sscan (in_str)
       call gargd (dbuf)
 	call calloc(refclk,SZ_CLK,TY_STRUCT)  # or salloc
        call calloc(utclk,SZ_CLK,TY_STRUCT)   # or salloc

        jdref = ROSAT_MJDRDAY
        jdoff = ROSAT_MJDRFRAC
        jd = 0.0D0 + double(jdref)+double(jdoff)- MJDREFOFFSET
# all computations are done relative to a newer reference point to maintain
#       precision
        call mjdut(MJDREFYEAR,MJDREFDAY,jd,refclk)

        call sclk_to_ut(dbuf,refclk,utclk)
        mjd = mutjd(MJDREFYEAR,MJDREFDAY,utclk) + MJDREFOFFSET
        call mfree(refclk,TY_STRUCT)
        call mfree(utclk,TY_STRUCT)
        call wft_encoded ("MJDOBS", mjd,  card,"", NDEC_DOUBLE)
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)

##r_mjd = real(mjd) + ROSAT_SC_MJDRD + ROSAT_SC_MJDRF
#r_mjd = real(mjd)

    }

	   #---------
	   # XS-FILTR
	   #---------
	   if (strncmp(keyword, "FILTER_ID", 9) == 0)
	   {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)


	      call strupr(in_str)

	      if (strncmp(in_str, "OFF", 3) == 0)
	      {
	         temp = 0
	      }
	      else
	      {
	         temp = 1
	      }

        	call wft_encodei ("XS-FILTR", temp, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        	call putline(fd_usr,card)

	   } # XS-FILTR


#---------
# XS-OBSID
#---------
    if (strncmp(keyword, "OBS_ID", 6) == 0)
    {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

#        maxch = SZ_CARDVSTR
        maxch = strlen(instr)
        call wft_encodec ("XS-OBSID", instr, maxch, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)

    }

#---------
# INSTRUME
#---------
    if (strncmp(keyword, "DETECTOR_ID", 11) == 0)
    {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

       call strupr(in_str)

       if (strncmp(in_str, "HRI", 3) == 0)
       {
	 mpe_instr = ROSAT_HRI
         # CRPIX1
	 val1 = (MH_CRPIX1-0.5D0)/16.0D0 + 0.5D0
	 val2 = (MH_CRPIX2-0.5D0)/16.0D0 + 0.5D0
	 val3 = MH_CDELT1
	 val4 = MH_CDELT2
	 blockf = 1/16.0D0

       	 # XS-SUBIN
	 temp = 0
#        maxch = SZ_CARDVSTR
        maxch = strlen(temp)
        call wft_encodec ("XS-SUBIN", temp, maxch, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
       }
       else
       {
	   if (strncmp(in_str, "PSPC", 4) == 0)
	   {
	      mpe_instr = ROSAT_PSPC

	      val1 = (MP_CRPIX1-0.5D0)/30.0D0+0.5D0 
	      val2 = (MP_CRPIX2-0.5D0)/30.0D0+0.5D0 
	      val3 = MP_CDELT1
	      val4 = MP_CDELT2
	      blockf = 1/30.0D0

	      ch = 'B'
	      if (in_str[5] == ch)
	      {
	          temp = 2
	          in_str[5] = EOS
	      }
	      else
		  temp = 1

              # XS-SUBIN
              call wft_encodei ("XS-SUBIN", temp, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
              call putline(fd_usr,card)
	   }
        call wft_encoded ("CRPIX1", val1,  card,"", NDEC_DOUBLE)
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
        call wft_encoded ("CRPIX2", val2, card, "",NDEC_DOUBLE)
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
        call wft_encoded ("CDELT1", val3, card, "",NDEC_DOUBLE)
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
        call wft_encoded ("CDELT2", val4, card, "", NDEC_DOUBLE)
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
        call wft_encoder("LTM1_1", blockf, card,  "",NDEC_REAL)
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
        call wft_encoder("LTM2_2", blockf, card,  "",NDEC_REAL)
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
#	maxch = SZ_CARDVSTR
	maxch = 15
        call wft_encodec("WAT0_001", "system=physical", card, maxch, "")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
       }

#        maxch = SZ_CARDVSTR
        maxch = strlen(instr)
        call wft_encodec ("INSTRUME", instr, maxch, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)

    }

#-------------------------------------
# CRVAL1
#
# Parse RA (otherwise known as CRVAL1)
#-------------------------------------
        if (strncmp(keyword, "POINT_LONG", 10) == 0)
        {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

           sum = mpe_ra2deg(in_str)

	call wft_encoded ("CRVAL1", sum, card,"",NDEC_DOUBLE) 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)
        }

#--------------------------------------
# CRVAL2
#
# Parse DEC (otherwise known as CRVAL2)
#--------------------------------------
    if (strncmp(keyword, "POINT_LAT", 9) == 0)
    {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

       sum = mpe_dec2deg(in_str)

	call wft_encoded ("CRVAL2", sum, card,"",NDEC_DOUBLE) 
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
	call putline(fd_usr,card)

    }

#-------
# OBJECT
#-------
    if (strncmp(keyword, "OBS_TITLE", 9) == 0)
    {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

#        maxch =  SZ_CARDVSTR
        maxch =  strlen(in_str)
        call wft_encodec ("OBJECT", in_str, maxch, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
       #  IRAF needs the special 'title' card
    }

#----------------------
# DATE-OBS and DATE-END
#----------------------
    if (strncmp(keyword, "OBS_DATE", 8) == 0)
    {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)

       len = strlen(in_str)

       cnt = 1
       while (cnt <= len && !IS_WHITE(in_str[cnt]))
          cnt = cnt + 1

       call strcpy(in_str, temp_str, cnt)
	call aclrc(ntemp_str,SZ_CARDVSTR)
	
       call mpe_get_month(temp_str, ntemp_str)

	call aclrc(card,LEN_CARD+10)
        maxch = strlen(ntemp_str)

        call wft_encodec ("DATE-OBS", ntemp_str, maxch, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)

	call aclrc(card,LEN_CARD+10)
       temp_str[1] = EOS


       while (IS_WHITE(in_str[cnt]))
          cnt = cnt + 1

#	len = cnt
#        while (!IS_WHITE(in_str[len]))
#          len = len + 1

#	len = len - cnt
	call aclrc(temp_str,SZ_CARDVSTR)
        call mpe_get_month(in_str[cnt], temp_str)
#call printf("TIME_OBS VALUE: *%s*\n")
#call pargstr(temp_str)
#        maxch = len
        maxch = strlen(temp_str)
        call wft_encodec ("DATE-END", temp_str, maxch, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
    }

#----------------------
# TIME-OBS and TIME-END
#----------------------
    if (strncmp(keyword, "OBS_UT", 6) == 0)
    {
#call printf("KEYWORD: *%s*\nKEYVAL:  *%s*\n")
#call pargstr(keyword)
#call pargstr(in_str)


	temp_str[1]=EOS
       len = strlen(in_str)

        for (i = 2; i <= len; i = i + 1)
        {
            if (in_str[i - 1] == colon && IS_WHITE(in_str[i]))
               in_str[i] = '0'
        }

       cnt = 1

       while (cnt <= len && !IS_WHITE(in_str[cnt]))
          cnt = cnt + 1

       call strcpy(in_str, temp_str, cnt)

#call printf("TIME_OBS VALUE: *%s*\n")
#call pargstr(temp_str)

	call aclrc(card,LEN_CARD+10)
#        maxch = SZ_CARDVSTR
        maxch = strlen(temp_str)
        call wft_encodec ("TIME-OBS", temp_str, maxch, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
#----------------------------------------------------------------
# Must allocate space again because ft_addparam frees it (this is
# because we are calling ft_addparam twice in row without calling
# nextcard where the space is normally allocated)
#----------------------------------------------------------------

       while (IS_WHITE(in_str[cnt]))
          cnt = cnt + 1

#call printf("TIME_END VALUE: *%s*\n")
#call pargstr(in_str[cnt])
#
	call aclrc(card,LEN_CARD+10)
#        maxch = SZ_CARDVSTR
        maxch = strlen(in_str[cnt])
        call wft_encodec ("TIME-END", in_str[cnt], maxch, card,"")
                card[LEN_CARD+1] = '\n'
                card[LEN_CARD+2] = EOS
        call putline(fd_usr,card)
    }

} # end if (key_found)

#--------------------------------------------------------------------
# Look for a single quote after any whitespace, this signifies the
# start of a keyword.  Get the keyword and set the boolean var "true"
#--------------------------------------------------------------------
        idx = 1

        ch = '\''
        if (in_str[idx] == ch)
        {
           idx = idx + 1
           len = stridx(ch, in_str[idx]) - 1
           call strcpy(in_str[idx], keyword, len)
           key_found = true
        }

end
