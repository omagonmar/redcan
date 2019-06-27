#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_mpe_head.x,v 11.0 1997/11/06 16:34:41 prosb Exp $
#$Log: ft_mpe_head.x,v $
#Revision 11.0  1997/11/06 16:34:41  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:22  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:05  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/27  13:06:20  mo
#MC	5/27/94		calc_qpmjdtime library has changed calling sequence
#			It now needs a QPHEAD struct - so alloced one
#			and added the 3 needed MJD entries before calling
#			this routine.  MJD-OBS now works, and therefore
#			PSPC-subinstrument is correct
#
#Revision 7.1  94/02/25  11:11:51  mo
#MC	2/25/94		Remove memory allocation from this routine - localized
#			in ft_header
#
#Revision 7.0  93/12/27  18:40:35  prosb
#General Release 2.3
#
#Revision 6.1  93/12/14  18:21:17  mo
#MC	12/13/93		Add display parameter
#
#Revision 6.0  93/05/24  16:25:24  prosb
#General Release 2.2
#
#Revision 5.1  93/03/03  14:06:12  mo
#MC	3/3/93		Add the XS-RAPT and XS-DECPT header values
#			since MAKEVIG needs them to be match RA and DEC
#
#Revision 5.0  92/10/29  21:37:24  prosb
#General Release 2.1
#
#Revision 1.6  92/10/15  16:25:56  jmoran
#*** empty log message ***
#
#Revision 1.5  92/10/06  16:18:20  jmoran
#*** empty log message ***
#
#Revision 1.4  92/10/06  15:29:11  jmoran
#JMORAN more debug statements removed
#
#Revision 1.3  92/10/05  14:46:22  jmoran
#JMORAN removed debug statements
#
#Revision 1.2  92/10/01  15:12:15  jmoran
#JMORAN comments
#
#Revision 1.1  92/09/23  11:35:13  jmoran
#Initial revision
#

include <ctype.h>
include <mach.h>
include <evmacro.h>
include <fset.h>
include <coords.h>
include <rosat.h>
include <qpoe.h>
include "cards.h"
include "ftwcs.h"
include "fits2qp.h"
include "mpefits.h"


procedure mpe_parse_gtis(mpe_gti, in_str)

pointer mpe_gti				# GTI structure pointer
char	in_str[ARB]

bool    got_a_record
int     idx
int     strlen()
int     parse_len

begin

	
	got_a_record = false
        parse_len = strlen(in_str)
        idx = 1
        while (idx <= parse_len && !got_a_record && !(PARSED_GTIS(mpe_gti))) 
        {
           if (IS_WHITE(in_str[idx]))
              idx = idx + 1
           else
           {
              if (IS_DIGIT(in_str[idx]))
                 got_a_record = true
              else
                 PARSED_GTIS(mpe_gti) = true
           }
	
        } # end while

        if (got_a_record)
        {
	  call mpe_assign_gtis(in_str, parse_len, mpe_gti)
        } 

end


procedure mpe_assign_gtis(in_str, parse_len, mpe_gti)

char    in_str[ARB]
int     parse_len
pointer mpe_gti

double  dbuf
int     sscan()
int     stat
int     offset
bool    done

begin
	
        offset = 1
        done = false
        while (!done)
        {
	   #-----------------------------------------------------
	   # Skip over leading whitespace - if the end of line is
	   # reached, that's all for this line
	   #-----------------------------------------------------
           if (IS_WHITE(in_str[offset]))
           {
              offset = offset + 1
              if (offset == parse_len)
                 done = true
           }
           else
           {
	      #------------
	      # Found a GTI
	      #------------
              stat = sscan (in_str[offset])
              call gargd(dbuf)

	      #--------------------
	      # Increment GTI count
	      #--------------------
	      COUNT_GTIS(mpe_gti) = COUNT_GTIS(mpe_gti) + 1

	      #------------------------------------------------------------
	      # Check to see if the arbitrary buffer size has been exceeded
	      # and if so, up the buffer size and reallocate the memory
	      #------------------------------------------------------------
	      if (COUNT_GTIS(mpe_gti) > GTI_BUFSZ(mpe_gti))
	      {
		 GTI_BUFSZ(mpe_gti) = GTI_BUFSZ(mpe_gti) + MAX_GTIS
	         call realloc (GTI_PTR(mpe_gti), GTI_BUFSZ(mpe_gti), TY_DOUBLE)
	      }

	      #----------------------------------------------
	      # Assign the GTI to the allocated memory buffer
	      #----------------------------------------------
	      Memd[GTI_PTR(mpe_gti) + COUNT_GTIS(mpe_gti) - 1] = dbuf

              #---------------------------------------------------
	      # Find the next whitespace (which is considered the 
	      # separator for the GTI recs) or stop if end of line
	      # is reached
	      #---------------------------------------------------
              while (!IS_WHITE(in_str[offset]) && !done)
              {
                 offset = offset + 1
                 if (offset == parse_len)
                    done = true
              } # end while

          } # end else
       } # end while
end


procedure mpe_head_const(qp, card, wcs, display)

pointer qp
pointer card
pointer wcs
int	display		# i: display level

begin

# CTYPE1
#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)
       call strcpy("CTYPE1", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR
       call strcpy(CTYPE1, Memc[CARDVSTR(card)], SZ_CARDVSTR)
       call malloc(IW_CTYPE(wcs, 1), SZ_CARDVSTR, TY_CHAR)
       call strcpy(Memc[CARDVSTR(card)], Memc[IW_CTYPE(wcs, 1)],
                   SZ_CARDVSTR)

       IW_ISKY(wcs) = 1


# CTYPE2
#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)
       call strcpy("CTYPE2", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR
       call strcpy(CTYPE2, Memc[CARDVSTR(card)], SZ_CARDVSTR)
       call malloc(IW_CTYPE(wcs, 2), SZ_CARDVSTR, TY_CHAR)
       call strcpy(Memc[CARDVSTR(card)], Memc[IW_CTYPE(wcs, 2)],
                   SZ_CARDVSTR)

# TELESCOP
#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)
       call strcpy("TELESCOP", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR
       call strcpy(TELESCOP, Memc[CARDVSTR(card)], SZ_CARDVSTR)
       call ft_addparam(qp, card, display)

# RADECSYS
#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)
       call strcpy("RADECSYS", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR
       call strcpy(RADECSYS, Memc[CARDVSTR(card)], SZ_CARDVSTR)
       call ft_addparam(qp, card, display)

# EQUINOX
       call strcpy("EQUINOX", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_REAL
       CARDVR(card) = ROSAT_EQUINOX
       call ft_addparam(qp, card, display)

# XS-MJDRD
       call strcpy("XS-MJDRD", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_INT
       CARDVI(card) = ROSAT_MJDRDAY
       call ft_addparam(qp, card, display)

# XS-MODE
       call strcpy("XS-MODE", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_INT
       CARDVI(card) = XS_MODE
       call ft_addparam(qp, card, display)

# XS-CNTRY
#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)
       call strcpy("XS-CNTRY", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR
       call strcpy(XS_CNTRY, Memc[CARDVSTR(card)], SZ_CARDVSTR)
       call ft_addparam(qp, card, display)

# XS-MJDRF
       call strcpy("XS-MJDRF", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_DOUBLE
       CARDVD(card) = ROSAT_MJDRFRAC
       call ft_addparam(qp, card, display)

# CDELT1
	IW_CDELT(wcs, 1) = CDELT1

# CDELT2
	IW_CDELT(wcs, 2) = CDELT2


end


procedure mpe_head_parse(qp, card, wcs, mpe_gti, key_found, keyword, mpe_instr,display)

pointer qp
pointer card
pointer wcs
pointer mpe_gti
bool    key_found
char    keyword[ARB]
int	mpe_instr
int	display

int     idx
int	i
int     len
int     stridx()
char	in_str[SZ_CARDVSTR]
char    ch
char	colon
int     strncmp()

real    rbuf
int     stat
int     sscan()
int     strlen()
int     cnt
double  sum
double	dbuf
double	mjd
real	r_mjd
double  mpe_ra2deg()
double  mpe_dec2deg()
pointer	qphead

char	temp_str[SZ_CARDVSTR]

begin
	colon = ':'

#--------------------------------------------------------
# Skip over any whitespace in the beginning of the string
#--------------------------------------------------------
        idx = 0
        while (IS_WHITE(Memc[CARDVSTR(card) + idx]))
           idx = idx + 1

	call strcpy(Memc[CARDVSTR(card) + idx], in_str, SZ_CARDVSTR)

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

    	   if (strncmp(keyword, "TIM_SEL", 7) == 0)
    	   {
              FOUND_GTIS(mpe_gti) = true
    	   }

	   #---------
	   # XS-XDOPT
	   #---------
    	   if (strncmp(keyword, "DET_CEN_X", 9) == 0)
    	   {
       	      stat = sscan (in_str)
       	      call gargr (rbuf)

       	      call strcpy("XS-XDOPT", Memc[CARDNA(card)], SZ_CARDNA)
              CARDTY(card) = TY_REAL
              CARDVR(card) = rbuf

              call ft_addparam(qp, card, display)
    	   } # XS-XDOPT

           #---------
           # XS-ONTI
           #---------
           if (strncmp(keyword, "OBS_DUR_SEC", 11) == 0)
           {
              stat = sscan (in_str)
              call gargd (dbuf)

              call strcpy("XS-ONTI", Memc[CARDNA(card)], SZ_CARDNA)
              CARDTY(card) = TY_DOUBLE
              CARDVD(card) = dbuf

              call ft_addparam(qp, card, display)
           } # XS-ONTI

#----------
# DET_CEN_Y
#----------
    	if (strncmp(keyword, "DET_CEN_Y", 9) == 0)
    	{

       	   stat = sscan (in_str)
       	   call gargr (rbuf)

       call strcpy("XS-YDOPT", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_REAL
       CARDVR(card) = rbuf

       call ft_addparam(qp, card, display)
    }

#------------------------------------------------
# XS-INPXX and XS-INPXY
# Read value as arc-secs and write out as degrees
#------------------------------------------------
    if (strncmp(keyword, "DET_PIX_SIZE", 12) == 0)
    {
       stat = sscan (in_str)
       call gargr (rbuf)

       call strcpy("XS-INPXX", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_REAL
       CARDVR(card) = SATODEG(rbuf)

       call ft_addparam(qp, card, display)

       call strcpy("XS-INPXY", Memc[CARDNA(card)], SZ_CARDNA)
       call ft_addparam(qp, card, display)

    }

#--------
# MJD-OBS
#--------
	if (strncmp(keyword, "OBS_CLOCK", 9) == 0)
    	{

       stat = sscan (in_str)
       call gargd (dbuf)

	call calloc(qphead,SZ_QPHEAD,TY_STRUCT)
	QP_MJDRDAY(qphead) = ROSAT_MJDRDAY
	QP_MJDRFRAC(qphead) = ROSAT_MJDRFRAC
	QP_EVTREF(qphead) = 0
	
	call calc_qpmjdtime(qphead, dbuf, mjd)
	call mfree(qphead,TY_STRUCT)

	r_mjd = real(mjd)

       call strcpy("MJD-OBS", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_REAL
       CARDVR(card) = r_mjd

       call ft_addparam(qp, card, display)

    }

	   #---------
	   # XS-FILTR
	   #---------
	   if (strncmp(keyword, "FILTER_ID", 9) == 0)
	   {

	      call strcpy("XS-FILTR", Memc[CARDNA(card)], SZ_CARDNA)
	      CARDTY(card) = TY_INT

	      call strupr(in_str)

	      if (strncmp(in_str, "OFF", 3) == 0)
	      {
	         CARDVI(card) = 0
	      }
	      else
	      {
	         CARDVI(card) = 1
	      }

       	      call ft_addparam(qp, card, display)

	   } # XS-FILTR


#---------
# XS-OBSID
#---------
    if (strncmp(keyword, "OBS_ID", 6) == 0)
    {

       call strcpy("XS-OBSID", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR
       call strcpy(in_str, Memc[CARDVSTR(card)], SZ_CARDVSTR)

       call ft_addparam(qp, card, display)

    }

#---------
# INSTRUME
#---------
    if (strncmp(keyword, "DETECTOR_ID", 11) == 0)
    {
       call strupr(in_str)

       if (strncmp(in_str, "HRI", 3) == 0)
       {
	 mpe_instr = ROSAT_HRI
         # CRPIX1
         IW_CRPIX(wcs, 1) = MH_CRPIX1

         # CRPIX2
         IW_CRPIX(wcs, 2) = MH_CRPIX2

       	 # XS-SUBIN
       	 call strcpy("XS-SUBIN", Memc[CARDNA(card)], SZ_CARDNA)
         CARDTY(card) = TY_INT
         CARDVI(card) = 0
         call ft_addparam(qp, card, display)
       }
       else
       {
	   if (strncmp(in_str, "PSPC", 4) == 0)
	   {
	      mpe_instr = ROSAT_PSPC

   	      # CRPIX1
   	      IW_CRPIX(wcs, 1) = MP_CRPIX1

   	      # CRPIX2
              IW_CRPIX(wcs, 2) = MP_CRPIX2

	      ch = 'B'
	      if (in_str[5] == ch)
	      {
	          CARDVI(card) = 2
	          in_str[5] = EOS
	      }
	      else
		  CARDVI(card) = 1

              # XS-SUBIN
              call strcpy("XS-SUBIN", Memc[CARDNA(card)], SZ_CARDNA)
              CARDTY(card) = TY_INT
              call ft_addparam(qp, card, display)
	   }
       }

#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)

       call strcpy("INSTRUME", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR
       call strcpy(in_str, Memc[CARDVSTR(card)], SZ_CARDVSTR)

       call ft_addparam(qp, card, display)

    }

#-------------------------------------
# CRVAL1
#
# Parse RA (otherwise known as CRVAL1)
#-------------------------------------
        if (strncmp(keyword, "POINT_LONG", 10) == 0)
        {
           sum = mpe_ra2deg(in_str)

        IW_CRVAL(wcs, 1) = sum
        IW_ISKY(wcs) = 1
       call strcpy("XS-RAPT", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_REAL
       CARDVR(card) = sum
       call ft_addparam(qp, card, display)
      }

#--------------------------------------
# CRVAL2
#
# Parse DEC (otherwise known as CRVAL2)
#--------------------------------------
    if (strncmp(keyword, "POINT_LAT", 9) == 0)
    {
       sum = mpe_dec2deg(in_str)

        IW_CRVAL(wcs, 2) = sum
        IW_ISKY(wcs) = 1
       call strcpy("XS-DECPT", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_REAL
       CARDVR(card) = sum
       call ft_addparam(qp, card, display)

    }

#-------
# OBJECT
#-------
    if (strncmp(keyword, "OBS_TITLE", 9) == 0)
    {
       call strcpy("OBJECT", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR
       call strcpy(in_str, Memc[CARDVSTR(card)], SZ_CARDVSTR)

       call ft_addparam(qp, card, display)

       #  IRAF needs the special 'title' card
#----------------------------------------------------------------
# Must allocate space again because ft_addparam frees it (this is
# because we are calling ft_addparam twice in row without calling
# nextcard where the space is normally allocated)
#----------------------------------------------------------------
#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)
       call strcpy(in_str, Memc[CARDVSTR(card)], SZ_CARDVSTR)
       call strcpy("title", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR

       call ft_addparam(qp, card, display)
    }

#----------------------
# DATE-OBS and DATE-END
#----------------------
    if (strncmp(keyword, "OBS_DATE", 8) == 0)
    {

       call strcpy("DATE-OBS", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR

       len = strlen(in_str)

       cnt = 1
       while (cnt <= len && !IS_WHITE(in_str[cnt]))
          cnt = cnt + 1

       call strcpy(in_str, Memc[CARDVSTR(card)], cnt)

       call mpe_get_month(Memc[CARDVSTR(card)], temp_str)

       call strcpy(temp_str, Memc[CARDVSTR(card)], strlen(temp_str))

       call ft_addparam(qp, card, display)

#----------------------------------------------------------------
# Must allocate space again because ft_addparam frees it (this is
# because we are calling ft_addparam twice in row without calling
# nextcard where the space is normally allocated)
#----------------------------------------------------------------
#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)
       temp_str[1] = EOS

       call strcpy("DATE-END", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR

       while (IS_WHITE(in_str[cnt]))
          cnt = cnt + 1

       call strcpy(in_str[cnt], Memc[CARDVSTR(card)], SZ_CARDVSTR)

       call mpe_get_month(Memc[CARDVSTR(card)], temp_str)

       call strcpy(temp_str, Memc[CARDVSTR(card)], strlen(temp_str))

       call ft_addparam(qp, card, display)
    }

#----------------------
# TIME-OBS and TIME-END
#----------------------
    if (strncmp(keyword, "OBS_UT", 6) == 0)
    {

       call strcpy("TIME-OBS", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR

       len = strlen(in_str)

        for (i = 2; i <= len; i = i + 1)
        {
            if (in_str[i - 1] == colon && IS_WHITE(in_str[i]))
               in_str[i] = '0'
        }

       cnt = 1

       while (cnt <= len && !IS_WHITE(in_str[cnt]))
          cnt = cnt + 1

       call strcpy(in_str, Memc[CARDVSTR(card)], cnt)

       call ft_addparam(qp, card, display)

#----------------------------------------------------------------
# Must allocate space again because ft_addparam frees it (this is
# because we are calling ft_addparam twice in row without calling
# nextcard where the space is normally allocated)
#----------------------------------------------------------------
#       call calloc(CARDVSTR(card), SZ_CARDVSTR, TY_CHAR)

       call strcpy("TIME-END", Memc[CARDNA(card)], SZ_CARDNA)
       CARDTY(card) = TY_CHAR

       while (IS_WHITE(in_str[cnt]))
          cnt = cnt + 1

       call strcpy(in_str[cnt], Memc[CARDVSTR(card)], SZ_CARDVSTR)

       call ft_addparam(qp, card, display)

    }

} # end if (key_found)

#----------------------------------------------------------------------
# If the GTI keyword has been found and the we haven't finished parsing
# the GTI data, then continue the parse
#----------------------------------------------------------------------
	if (FOUND_GTIS(mpe_gti) && !(PARSED_GTIS(mpe_gti)))
	{
   	   call mpe_parse_gtis(mpe_gti, in_str)
	}

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
