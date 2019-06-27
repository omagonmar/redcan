# $Header: /home/pros/xray/xtiming/timcor/apply_bary/RCS/appbary_subs.x,v 11.0 1997/11/06 16:45:33 prosb Exp $
# $Log: appbary_subs.x,v $
# Revision 11.0  1997/11/06 16:45:33  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:35:57  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:43:59  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/18  18:23:13  janet
#jd - see notes in apply_bary.x 
#
#Revision 7.1  94/03/25  12:32:57  mo
#MC	3/25/94		Move gti_update to LIB/PROS/times.x
#
#Revision 7.0  93/12/27  19:05:04  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:10:42  janet
#jd - updated keywords to rdf names.
#
#Revision 6.0  93/05/24  17:00:39  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:16:41  mo
#MC	5/2093		Move qp_check_sorted to TiMLIB
#
#Revision 5.0  92/10/29  23:07:10  prosb
#General Release 2.1
#
#Revision 4.3  92/10/15  16:18:47  jmoran
#JMORAN fixed code to adjust for new GTI library code
#
#Revision 4.2  92/07/21  17:36:58  jmoran
#JMORAN added J.D. to display first/last times
#
#Revision 4.1  92/06/16  12:20:54  jmoran
#JMORAN changed calculation of QP_LIVETIME from: 
#QP_LIVETIME(qphead) = duration / QP_DEADTC(qphead)
#to:
#QP_LIVETIME(qphead) = duration * QP_DEADTC(qphead)
#
#Revision 4.0  92/04/27  15:39:44  prosb
#General Release 2.0:  April 1992
#
#Revision 1.3  92/04/13  16:05:56  jmoran
#JMORAN removed debug lines
#
#Revision 1.2  92/04/08  15:02:13  jmoran
#*** empty log message ***
#
#Revision 1.1  92/03/26  13:26:17  prosb
#Initial revision
#
#
# Module:       < file name >
# Project:      PROS -- ROSAT RSDC
# Purpose:      < opt, brief description of whole family, if many routines>
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>
#               {n} <who> -- <does what> -- <when>
#
include <tbset.h>
include	<error.h>
include <math.h>
include <qpoe.h>
include <bary.h>

procedure gti_correct()

double  photon
double  utc_photon
double  corr_photon
long    utci
int     i
int	maxloop
bool	outside_range

int	outcnt
bool    first

include "apply_bary.com"

begin

#-----------------------------
# read in first orbit interval
#-----------------------------
        row = 1
        call orb_interval(tp, cp, orb_int[1], orb_real[1],
                          corr_int[1], corr_real[1], row)

        row = row + 1
        call orb_interval(tp, cp, orb_int[2], orb_real[2],
                          corr_int[2], corr_real[2], row)

#----------------------------------
# save the integer parts as offsets
#----------------------------------
        orb_offset = orb_int[1]
        corr_offset = corr_int[1]

#----------------
# subtract offset
#----------------
        orb_real[2] = orb_real[2] + (orb_int[2] - orb_offset)
        corr_real[2] = corr_real[2] + (corr_int[2] - corr_offset)

#--------------------------------
# get the slope and the intercept
#--------------------------------
	call lin_interpol(orb_real, corr_real, a, b)

#------------------------
# main loop over the GTIS
#------------------------
        first=true
        outcnt=0

	maxloop = 2*ngti
	do i = 1, maxloop
        {
           #------------------
           # read in next time
           #------------------
	   if (mod(i, 2) == 1)
	      photon = Memd[blist + ((i+1)/2) - 1]
	   else
	      photon = Memd[elist + (i/2) - 1]

           #------------------
           # convert it to UTC
           #------------------
           call sccut2(photon,utci,utc_photon)

           #----------------
           # subtract offset
           #----------------
           utc_photon = utc_photon + (utci - orb_offset)

           #--------------------------------------------------------
           # check whether the photon is inside the current interval
           # if it isn't, find the interval it falls within.
           #--------------------------------------------------------
           if (utc_photon > orb_real[2])
	   {           
              call find_interval(tp, cp, orb_real, corr_real, orb_int, 
				 corr_int, utc_photon, a, b, orb_offset,
                                 corr_offset, row, nrows, outside_range)
	   }
           if (outside_range) {
              if (first) {
                 call eprintf(
                    "\n** Warning! GTI: SCC %.6f is outside range of correction table -\n")
                    call pargd(photon)
                 call eprintf(
                 "            Extrapolating from last two orbit recs.\n")
                    call flush(STDERR)
                 first = false
               } else {
                 outcnt = outcnt+1
               }
           } else { 
               if (!outside_range && !first) {
                call eprintf("            -- Repeated for %d gti records!!\n\n")
                    call pargi(outcnt)
                    call flush(STDERR)
                first = true
                outcnt = 0
               }
           }

           #---------------
           # Correct photon 
           #---------------
           corr_photon = a*utc_photon + b

           #----------------------
           # Convert it to seconds
           #----------------------
           corr_photon = corr_photon * SECS_IN_DAY

           #----------------------------------------
           # Update GTI buffer with corrected photon
           #----------------------------------------
           if (mod(i, 2) == 1)
              Memd[blist + ((i+1)/2) - 1] = corr_photon
           else
              Memd[elist + (i/2) - 1] = corr_photon

        } # end loop

        if (outside_range && !first) {
           call eprintf("            -- Repeated for %d gti records!!\n\n")
              call pargi(outcnt)
           call flush(STDERR)
        }
end

# ----------------------------------------------------------------------------
procedure find_interval(tp, cp, orb_real, corr_real, orb_int, corr_int, 
			utc_photon, a, b, orb_offset, corr_offset, row, nrows, 
			outside_range)
pointer tp
pointer cp[ARB]
double  orb_real[2]		# i/o: 
double  corr_real[2]		# i/o:
long	orb_int[2]
long	corr_int[2]
double  utc_photon
double  a
double  b
long    orb_offset
long    corr_offset
long    row
long	nrows
bool	outside_range

bool	isitin
double	diff
double	old_a
double	old_b

begin
        isitin = false
	outside_range = false

        while (!isitin && !outside_range)
        {
	   #-------------------------------------------------------------
	   # save slope and intercept in case we need to extrapolate from
	   # the previous two orbit records because of an orbit gap
	   #-------------------------------------------------------------
	   old_a = a
	   old_b = b

           #-----------------
           # move to the next
           #-----------------
           orb_real[1] = orb_real[2]
           corr_real[1] = corr_real[2]
           row = row + 1
	   
	   if (row > nrows)
	   {
	      outside_range = true
	   }
	   else
	   {
              call orb_interval(tp, cp, orb_int[2], orb_real[2],
                                corr_int[2], corr_real[2], row)

              #-----------------------
              # subtract actual offset
              #-----------------------
              orb_real[2] = orb_real[2] + (orb_int[2] - orb_offset)
              corr_real[2] = corr_real[2] + (corr_int[2] - corr_offset)

              call lin_interpol(orb_real, corr_real, a, b)

	      diff = (orb_real[2] - orb_real[1])*SECS_IN_DAY

              #---------------------------------
              # check whether the current photon
              # is inside the new orbit period
              #---------------------------------
              if (utc_photon <= orb_real[2])
              {
                 isitin = true
		 if (diff > ORBIT_GAP_VALUE)
		 {
		    a = old_a
		    b = old_b
		 }
              }

	    } # end "row > nrows" conditional
         } # end "while (!isitin)" loop

end


# ---------------------------------------------------------------------------
procedure lin_interpol(orb_real, corr_real, a, b)

double	orb_real[2]
double	corr_real[2]
double	a
double	b

double  orb_diff

begin
        orb_diff = orb_real[1] - orb_real[2]
        b = (orb_real[1]*corr_real[2] - orb_real[2]*corr_real[1])/orb_diff
        a = (corr_real[1] - corr_real[2])/orb_diff
end


# ---------------------------------------------------------------------------
bool procedure times_compatible(tp, blist, elist, ngti, nrows, int_cp, real_cp)

pointer tp
pointer blist
pointer elist
int     ngti
long	nrows
pointer int_cp
pointer real_cp

double  s_binu
double  e_binu
long	s_bini
long	e_bini
double  s_time
double  e_time
long	e_date
long	s_date
double  first
double  last

begin

#---------------------------------------------------------
# Get the int part of the time from the first row of table
#---------------------------------------------------------
        call tbegti(tp, int_cp, 1, s_date)

#----------------------------------------------------------
# Get the real part of the time from the first row of table
#----------------------------------------------------------
	call tbegtd(tp, real_cp, 1, s_time)

#--------------------------------------------------------
# Get the int part of the time from the last row of table
#--------------------------------------------------------
        call tbegti(tp, int_cp, nrows, e_date)

#---------------------------------------------------------
# Get the real part of the time from the last row of table
#---------------------------------------------------------
        call tbegtd(tp, real_cp, nrows, e_time)

#------------------------------------------------
# assemble start and end times for the correction
#------------------------------------------------
        s_time = s_date * 1.0D0 + s_time
        e_time = e_date * 1.0D0 + e_time

#---------------------------------------
# convert first and last photon into utc
#---------------------------------------
        first = Memd[blist + 0]
        last  = Memd[elist + ngti - 1]
	
	call sccut2(first, s_bini, s_binu)
        call sccut2(last, e_bini, e_binu)

        s_binu = s_bini + s_binu
        e_binu = e_bini + e_binu

#------------------
# compare the times
#------------------
	call printf("first qpoe gti time   = J.D. %.8f,  SCC %.8f\n")
	call pargd(s_binu)
	call pargd(first)
	call printf("last qpoe gti time    = J.D. %.8f,  SCC %.8f\n")
	call pargd(e_binu)
	call pargd(last)
	call printf("first corr table time = J.D. %.8f\n")
	call pargd(s_time)
	call printf("last corr table time  = J.D. %.8f\n")
	call pargd(e_time)
	call flush(STDOUT)

# -------------------------------------------------------------------
# we add a tolerance of 1 minute sonce the orbit records are the
# beginning of 1 minute intervals for ROSAT, even if 60 secs is 
# unaccurate for other missions, the result is only a warning, along
# with clearly stated start and stop times above.
# -------------------------------------------------------------------
        if (s_binu > s_time && e_binu < e_time+60.0D0 )
	  return true
	else
	  return false

end


# ---------------------------------------------------------------------------
double procedure angle_sep(tp, qphead, display, alphac, deltac)

pointer tp
pointer qphead
int	display
double  alphac
double  deltac

double  cra,cdec
double  alphaq
double  deltaq
double  d_tet
double  tbhgtd()

bool    gotit

begin

#-------------------------------------------
# Read ra/dec from tcor header if they exist
#-------------------------------------------
        alphac=0.0D0; deltac=0.0D0
        alphaq=0.0D0; deltaq=0.0D0
        gotit=true
        d_tet=0.0D0

        iferr (cra = tbhgtd(tp, "ALPHA_SOURCE")) {
	   gotit=false
 	}
 	iferr (cdec = tbhgtd(tp, "DELTA_SOURCE")) {
	   gotit=false
 	}

	if ( gotit ) {
           #---------------------------------------
           # Convert the alpha and delta to radians
           #---------------------------------------
	   alphac = DEGTORAD(cra*15.0D0) 
	   deltac = DEGTORAD(cdec)

	   if (display >= 2 ) {
	      call printf ("ra/dec from cor.tab -> %.2f  %.2f in radians\n")
	        call pargd(alphac)
	        call pargd(deltac)
	   }
#------------------------------------
# Read ra/dec center from qpoe header 
#------------------------------------
           alphaq = DEGTORAD(QP_CRVAL1[qphead])
           deltaq = DEGTORAD(QP_CRVAL2[qphead])

	   if (display >= 2 ) {
	      call printf ("ra/dec from Qpoe -> %.2f  %.2f in radians\n")
	        call pargd(alphaq)
	        call pargd(deltaq)
	   }
#----------------------------------------------------------
# Calculate the separation angle between the two sources.
# This is the dot product between the two source vectors in 
# spherical coordinates.   
#----------------------------------------------------------
           d_tet = dcos(deltaq)*dsin(alphaq)* dcos(deltac)*dsin(alphac)+
                   dcos(deltaq)*dcos(alphaq)* dcos(deltac)*dcos(alphac)+
                   dsin(deltaq)*dsin(deltac)

           d_tet = dacos(d_tet)
	   d_tet = RADTODEG(d_tet)
           d_tet = d_tet * 3600.0
        }
	return d_tet 
end

# --------------------------------------------------------------------------
bool procedure already_corrected(qp)

pointer qp
bool	streq()
int	qp_accessf()
char	timeref[SZ_LINE]
bool	ret

begin
	ret = false
	if (qp_accessf(qp, "TIMEREF") == YES)  
	{ 
           call qp_gstr(qp, "TIMEREF",timeref,SZ_LINE)
	   call strupr(timeref)
	   if(streq(timeref,"SOLARSYSTEM") )
		ret = true
	}

        return ret 
end


# --------------------------------------------------------------------------
procedure col_pointers(tp, i1_name, r1_name, i2_name, r2_name, cp)

pointer tp
char	i1_name[ARB]
char	r1_name[ARB]
char 	i2_name[ARB]
char	r2_name[ARB]
pointer cp[ARB]

begin

#----------------------------------------------
# Get the column pointers from the column names
#----------------------------------------------
        call tim_initcol (tp, i1_name, cp[1])
        call tim_initcol (tp, r1_name, cp[2])
        call tim_initcol (tp, i2_name, cp[3])
        call tim_initcol (tp, r2_name, cp[4])

end


# --------------------------------------------------------------------------
procedure orb_interval(tp, cp, i1, r1, i2, r2, row)

pointer	tp
pointer cp[ARB] 
long	i1
double  r1
long	i2
double	r2
long	row

begin

        call tbegti(tp, cp[1], row, i1)
        call tbegtd(tp, cp[2], row, r1)
        call tbegti(tp, cp[3], row, i2)
        call tbegtd(tp, cp[4], row, r2)

end


# --------------------------------------------------------------------------
procedure print_com()

include "apply_bary.com"


begin
	call printf("\n****************************************************\n")

	call printf("a: %20.16f\n")
	call pargd(a)

	call printf("b: %20.16f\n")
	call pargd(b)

	call printf("alpha: %20.16f\n")
	call pargd(alpha)

	call printf("delta: %20.16f\n")
	call pargd(delta)

	call printf("orb_real[1]: %20.16f\n")
	call pargd(orb_real[1])

	call printf("orb_real[2]: %20.16f\n")
        call pargd(orb_real[2])

	call printf("corr_real[1]: %20.16f\n")
        call pargd(corr_real[1])

	call printf("corr_real[2]: %20.16f\n")
        call pargd(corr_real[2])

	call printf("row: %d\n")
	call pargl(row)

	call printf("nrows: %d\n")
	call pargl(nrows)

	call printf("toffset: %d\n")
	call pargi(toffset)

	call printf("ngti: %d\n")
	call pargi(ngti)

	call printf("orb_int[1]: %d\n")
	call pargi(orb_int[1])

	call printf("orb_int[2]: %d\n")
        call pargi(orb_int[2])

	call printf("corr_int[1]: %d\n")
        call pargi(corr_int[1])

	call printf("corr_int[2]: %d\n")
        call pargi(corr_int[2])

	call printf("cp[1]: %d\n")
        call pargi(cp[1])

	call printf("cp[2]: %d\n")
        call pargi(cp[2])

	call printf("cp[3]: %d\n")
        call pargi(cp[3])

	call printf("cp[4]: %d\n")
        call pargi(cp[4])

	call printf("tp: %d\n")
        call pargi(tp)

	call printf("qp_out: %d\n")
        call pargi(qp_out)

	call printf("Memc[tbl_r1]: %s\n")
	call pargstr(Memc[tbl_r1])

	call printf("Memc[tbl_r2]: %s\n")
        call pargstr(Memc[tbl_r2])

	call printf("Memc[tbl_i1]: %s\n")
        call pargstr(Memc[tbl_i1])

	call printf("Memc[tbl_i2]: %s\n")
        call pargstr(Memc[tbl_i2])

	call printf("Memc[tbl_fname]: %s\n")
        call pargstr(Memc[tbl_fname])

	call printf("Memc[s2u_fname]: %s\n")
	call pargstr(Memc[s2u_fname])

        call printf("****************************************************\n\n")

	call flush(STDOUT)

end

# ----------------------------------------------------------------------------
procedure init_common()

int     i

include "apply_bary.com"

begin
	a=0.0d0
	b=0.0D0
	alpha=0.0D0
	delta=0.0D0
	row=0
	toffset=0
	ngti=0
	orb_offset=0
	corr_offset=0
	nrows=0
	blist=0
	elist=0

	do i = 1, 2 {
  	  orb_real[i]=0.0D0
  	  corr_real[i]=0.0D0
  	  orb_int[i]=0
  	  corr_int[i]=0
	}
end
