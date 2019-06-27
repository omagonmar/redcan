# $Header: /home/pros/xray/xtiming/timcor/calc_bary/RCS/jdleap_init.x,v 11.0 1997/11/06 16:45:39 prosb Exp $
# $Log: jdleap_init.x,v $
# Revision 11.0  1997/11/06 16:45:39  prosb
# General Release 2.5
#
# Revision 9.2  1997/09/24 18:45:12  prosb
# JCC(9/97) - Change the column name from JDLEAP to JD.
#
# Revision 9.1  1997/07/21 21:14:19  prosb
# JCC(7/21/97) - data type in jdleap.tab is changed from int to double
#              - jdleap: int -> double
#              - tbegti -> tbegtd
#              - pargi  -> pargd
#
# Revision 9.0  1995/11/16 19:36:10  prosb
# General Release 2.4
#
#Revision 1.1  1995/09/18  19:34:15  prosb
#Initial revision
#
# JCC(9/15/95) - Open the jdleap calibration table (jdleap.tab) and 
#                read the column (JD) from it.
#
# Module:       jdleap_init.x
# Project:      PROS -- ROSAT RSDC
# Modified:     {0} JCC initial version  9/15/95 

include <tbset.h>
include <error.h>
include <bary.h>

procedure jdleap_init(tbl_fname,jdleap,NLEAPS,display)

#long   jdleap[LEAPMAX]     # array for the column "JD" in jdleap.tab
double  jdleap[LEAPMAX]     # array for the column "JD" in jdleap.tab

long    NLEAPS              # total row# in jdleap.tab

char    tbl_fname[ARB]

pointer tb_ptr                 # table pointer
pointer col_ptr                # table-column pointer
pointer tbtopn()

int     ii, display
int     tbtacc(), tbpsta()

begin
#-------------------------------------------
#        open the jdleap calibration table
#-------------------------------------------
        if (tbtacc(tbl_fname) == YES)
           tb_ptr = tbtopn (tbl_fname, READ_ONLY, 0)
        else
           call error(EA_FATAL,"jdleap correction table not found.")

#----------------------
# Check for empty table
#----------------------
        NLEAPS = tbpsta (tb_ptr, TBL_NROWS)

        if (NLEAPS <= 0)
           call error (EA_FATAL, "Table file empty.")
        else if ( display >= 2 )  {
           call printf ("NLEAPS = %d\n")
           call pargi (NLEAPS)
        }

#--------------------------------------------
#       read column(: JD) from jdleap.tab 
#--------------------------------------------
# column name in jdleap.tab is changed from JDLEAP to JD.
        call tim_initcol(tb_ptr, "JD", col_ptr)     # was JDLEAP 

        do ii = 1, NLEAPS {
           ###call tbegti(tb_ptr, col_ptr, ii, jdleap[ii])    #JCC(7/21/97)
           call tbegtd(tb_ptr, col_ptr, ii, jdleap[ii])

           if ( display >= 2 ) {
              #call printf ("row#=%d, jdleap=%d \n") 
              call printf ("row#=%d, jdleap=%13.2f \n") 
              call pargi (ii)
              #call pargi (jdleap[ii])
              call pargd (jdleap[ii])
           }
        }

#---------
# Close up
#---------
        call tbtclo(tb_ptr)
        call flush(STDOUT)
end
