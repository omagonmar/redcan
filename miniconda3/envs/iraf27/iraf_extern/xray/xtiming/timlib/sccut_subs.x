# $Header: /home/pros/xray/xtiming/timlib/RCS/sccut_subs.x,v 11.0 1997/11/06 16:45:07 prosb Exp $
# $Log: sccut_subs.x,v $
# Revision 11.0  1997/11/06 16:45:07  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:34:59  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:29  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/20  14:17:00  janet
#jd - updated warning statement in sccut2_init to a message.
#
#Revision 7.0  93/12/27  19:03:02  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:59:14  prosb
#General Release 2.2
#
#Revision 5.2  93/05/07  14:45:35  jmoran
#JMORAN fixed array subscript for SCCADD
#
#Revision 5.1  93/04/27  18:02:12  jmoran
#JMORAN added Tomaso Changes (4/26/93)
#
#Revision 5.0  92/10/29  23:05:47  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:36:44  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/03/25  17:36:18  mo
#MC	Fix the header comment field
#
#Revision 1.1  92/03/25  15:48:48  jmoran
#Initial revision
#
#
# Module:       sccut_subs.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      < opt, brief description of whole family, if many routines>
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MPE initial version 1/1/92
#		{1} JM  ported to SPP   3/25/92
#
#               {n} <who> -- <does what> -- <when>
#
include <tbset.h>
include <error.h>
include <bary.h>

procedure sccut2_init(tbl_fname)

long    partyp[NCOMP]
long    i
long    j
char    tbl_fname[ARB]
int     tbtacc()
int     tbpsta()
pointer tbtopn()
pointer tp                              # table pointer
pointer cp[NUM_CP]
pointer gen_cp
pointer tbcnum()

include "sccut2.com"

begin
#-------------------------------------------
#        open the scc--utc calibration table
#-------------------------------------------
        if (tbtacc(tbl_fname) == YES)
           tp = tbtopn (tbl_fname, READ_ONLY, 0)
        else
           call error(EA_FATAL, "Correction table not found.")

#----------------------
# Check for empty table
#----------------------
        sc_nrows = tbpsta (tp, TBL_NROWS)

        if (sc_nrows <= 0)
           call error (EA_FATAL, "Table file empty.")

#-------------------------------------------------------
#        check if it's a valid scc--utc correction table
#-------------------------------------------------------
#################################################################
# ADD CHECK FOR VALID TABLE LATER
#################################################################
#         if(ftype(1:3) != 'utc')
#           call error(EA_FATAL, "Not a valid correction table")
#################################################################

        call tim_initcol(tp, START_NAME,  cp[1])
        call tim_initcol(tp, END_NAME,    cp[2])
        call tim_initcol(tp, TYPE_NAME,   cp[3])
        call tim_initcol(tp, NCOEFF_NAME, cp[4])
        call tim_initcol(tp, REFTIM_NAME, cp[5])
        call tim_initcol(tp, SCCADD_NAME, cp[6])

#-------------------------------
#           read in coefficients
#-------------------------------
        do i = 1, sc_nrows
        {
           #-------------------------------
           # start time of the ith interval
           #-------------------------------
           call tbegtd(tp, cp[1], i, startt[i])

           #------------------------------
           # end  time of the ith interval
           #------------------------------
           call tbegtd(tp, cp[2], i, endt[i])

           #--------------------------------------------
           # type of function of interpolation:
           #   (1) polynomial (only one in this version)
           #--------------------------------------------
           call tbegti(tp, cp[3], i, partyp[i])

           #-----------------------------------------
           # number of coefficients for this interval
           #-----------------------------------------
           call tbegti(tp, cp[4], i, ncoeff[i])

           #--------------------
           # actual coefficients
           #--------------------
           do j = 1, ncoeff[i]
           {
              gen_cp = tbcnum(tp, 4 + j)
              call tbegtd(tp, gen_cp, i, matrix[i,j])
           }
           call tbegtd(tp, cp[5], i, reftim[i])
           call tbegtd(tp, cp[6], i, sccadd[i])
        }

#---------
# Close up
#---------
        call tbtclo(tp)

#-----------------------------------------------------------
#        terminal output for range of correction application
#-----------------------------------------------------------
        call printf("\nSCC->UTC conversion table is calibrated to SCC %.4f\n\n")
        call pargd(endt[sc_nrows])
        call flush(STDOUT)

end

 


procedure sccut2(scc,utci,utcr)

double  utcr
double  scc
double  dref
double  uth
double  ref
double	timadd
long    utci
long    i
long    j
bool    done

include "sccut2.com"

begin

#-----------------------------------------------------------------
#     compute time in seconds after midnight dec 31,89 -> jan 1,90
#-----------------------------------------------------------------
#-------------------------------------------------
#     loop over the components to find current one
#-------------------------------------------------
        uth = 0.0D0
        done = false
        do i = 1, sc_nrows
        {
           if ((scc >= startt[i])  && (scc <= endt[i]))
           {
              done = true
	      ref = reftim[i]
              timadd = sccadd[i]

              do j = 1, ncoeff[i]
              {
                 uth = uth + matrix[i,j]*((scc-timadd)**(j-1))
              }
            }
         }

#-----------------------------------------------
#     if time is after last calibration point...
#       you're extrapolating...
#-----------------------------------------------
        if (!done)
        {
	   ref = reftim[sc_nrows]
	   timadd = sccadd[sc_nrows]
           do j = 1, ncoeff[sc_nrows]
           {
               uth = uth + matrix[sc_nrows,j]*((scc-timadd)**(j-1))
           }
        }

#--------------------------------------------------
#     get days since midnight dec 31,89 -> jan 1,90
#--------------------------------------------------
        dref = uth / SECS_IN_DAY

#---------------------
#     get integer part
#---------------------
        utci = int(dref)

#------------------------
#     get fractional part
#------------------------
        utcr = dref - utci

#----------------------------------------
#     check if it's going to the next day
#----------------------------------------
        utcr = utcr + 0.5D0
        if (utcr >= 1.0D0)
        {
           utcr = utcr - 1.0D0
           utci = utci + 1
        }

#-----------------------------------------------------------
#     add reference date
#      warning! the 0.5 is lost while converting to integer,
#      but this is taken into account above (15-may-1991)
#-----------------------------------------------------------
        utci = ref + utci

end


