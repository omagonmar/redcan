#$Header: /home/pros/xray/lib/pros/RCS/date_convert.x,v 1.1 1999/09/20 19:12:14 prosb Exp $
#$Log: date_convert.x,v $
#Revision 1.1  1999/09/20 19:12:14  prosb
#Initial revision
#
#
# (7/98) - initial version
#         Function RDF_PROCDATE converts RDF_DATE and PROCDATE
#         from '27-APR-1995'  to '1995-04-27',  and
#         from '17-APR-1995 14:59:56' to '1995-04-17 14:59:56'
# (9/99) - remove 'printf' statements
#
include <ctype.h>   # for IS_DIGIT
#include <mach.h> <evmacro.h> <fset.h> "cards.h" "ftwcs.h" "fits2qp.h"
#include "mpefits.h"

#----------------------------------------------------------------------
# in_str '27-APR-1995' or '27-APR-95' --> out_date = '1995-04-27'
# in_str = '27-APR-1995 14:59:56' --> out_date = '1995-04-27 14:59:56'
#----------------------------------------------------------------------
procedure rdf_procdate(in_str, out_date)

char	in_str[ARB]
char    out_date[ARB]
char    all_months[SZ_LINE]
char    month_str[3]
char	temp_str[2], temp1
int     int_month
int     month_idx
int	stat
int	strsearch()
int     itoc()
int	strlen()
int	len
bool    streq() 

begin

#---    call printf("rdf_procdate\n")
#---    call printf("strlen(in_str)=%d, in_str=%s\n")
#---    call pargi(strlen(in_str))
#---    call pargstr(in_str)
#--------------------------
# Strip trailing whitespace
#--------------------------
	len = strlen(in_str)
#JCC- in_str is not NULL
if (len != 0)
{
	while (!IS_DIGIT(in_str[len]))
	  len = len - 1

	in_str[len + 1] = EOS

#---------------------------------------------------------------------
# JCC(7/98) - 
#    Copy in_str to out_date if in_str is NOT in any of OLD foramt.
#
#    OLD format includes :
#         "27-APR-50"             (len=9)
#         "27-APR-1950"           (len=11)
#         "27-APR-50 14:59:56"    (len=18)
#         "27-APR-1950 14:59:56"  (len=20)
#
#    NEW format includes :
#         "1950-04-27"              (len==10)
#         "1950-04-27T14:59:56"     (len==19)
#---------------------------------------------------------------------
#if ((len==10)||(len==19))         #if in_str is new format (same as below)
 if ((len !=9)&&(len!=11)&&(len!=18)&&(len!=20)) #in_str is NOT old format
    call strcpy(in_str[1], out_date[1], len)     #in_str -> out_date
 else
 {    # begin the DATE format conversion to NEW one

#---------------------------------------------------------------------
# JCC (7/98) 
# NOTE: This routine does not purport to be a general or generic date
# conversion routine.  It does one thing only.  Takes dates in this
# format: "DD-MMM-YYYY" OR "DD-MMM-YY" and turns it into this 
# format: "YYYY-MM-DD" (eg. "27-APR-1950" -> "1950-04-27" )
#                      (eg. "27-APR-50"   -> "1950-04-27" )
# or   "DD-MMM-YY hh:mm:ss"    --> "YYYY-MM-DDThh:mm:ss"
# or   "DD-MMM-YYYY hh:mm:ss"  --> "YYYY-MM-DDThh:mm:ss"
#---------------------------------------------------------------------
	call strcpy("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC",all_months,SZ_LINE)

#------------------------------
# Assign the numerical DAY part
#------------------------------
#---    call printf("in_str[1]=%sjcc\n")
#---    call pargstr(in_str[1])

        #JCC - for the case " 7-APR-50"  =>  1950-04-07  
        call strcpy (in_str[1], temp1, 1)  #in_str -> temp1 
        if (streq(" ", temp1))  
           out_date[9] = '0'               
        else
           out_date[9] = in_str[1]
	out_date[10] = in_str[2]

#----------------------
# Assign the separators "-" for y2k
#----------------------
	out_date[5] = '-'
	out_date[8] = '-'

#--------------------------------
# Assign the last two year digits
#
#JCC(6/98) - new format for out_date ( DD/MM/YY  -> YYYY/MM/DD )
#--------------------------------
        ###### in_str   "DD-MMM-YYYY"  ("27-APR-1950")
        ###### out_date "YYYY-MM-DD"
	if (strlen(in_str) == 11)  
	{
           out_date[1] = in_str[8]
           out_date[2] = in_str[9]
           out_date[3] = in_str[10]
           out_date[4] = in_str[11]
	}
        ###### in_str   "DD-MMM-YY"     ("27-APR-50")
        ###### out_date "YYYY-MM-DD"
	else if (strlen(in_str) == 9 )
	{                    
           call strcpy (in_str[8], temp1, 1)  #in_str -> temp1
           if  (streq("0",temp1)||streq("1",temp1)||streq("2",temp1)
               ||streq("3",temp1) )
           {  out_date[1] = '2'
              out_date[2] = '0'
           }
           else
           { 
              out_date[1] = '1'
              out_date[2] = '9'
           }
           out_date[3] = in_str[8]
           out_date[4] = in_str[9]
	}
        ###### in_str   "DD-MMM-YY hh:mm:ss"  ("27-APR-50 14:59:56")
        ###### out_date "YYYY-MM-DDThh:mm:ss"
        else if (strlen(in_str) == 18 )
        {
           ## copy "YYYY" to out_date
           ##
           call strcpy (in_str[8], temp1, 1)  #in_str -> temp1
           if  (streq("0",temp1)||streq("1",temp1)||streq("2",temp1)
               ||streq("3",temp1) )
           {  out_date[1] = '2'
              out_date[2] = '0'
           }
           else
           {  out_date[1] = '1'
              out_date[2] = '9' 
           }
           out_date[3] = in_str[8] 
           out_date[4] = in_str[9] 

           out_date[11] = 'T'       # "YYYY-MM-DDThh:mm:ss"

           ## copy "hh:mm:ss" to out_date
           ##
           out_date[12] = in_str[11]
           out_date[13] = in_str[12]
           out_date[14] = in_str[13]
           out_date[15] = in_str[14]
           out_date[16] = in_str[15]
           out_date[17] = in_str[16]
           out_date[18] = in_str[17]
           out_date[19] = in_str[18]
        }
        ###### in_str   "DD-MMM-YYYY hh:mm:ss"  ("27-APR-1950 14:59:56")
        ###### out_date "YYYY-MM-DD hh:mm:ss"
	else if (strlen(in_str) == 20 )
        {
           ## copy "YYYY" to out_date
           out_date[1] = in_str[8]
           out_date[2] = in_str[9]
           out_date[3] = in_str[10]
           out_date[4] = in_str[11]

           out_date[11] = 'T'       # "YYYY-MM-DDThh:mm:ss"
 
           ## copy "hh:mm:ss" to out_date
           out_date[12] = in_str[13]
           out_date[13] = in_str[14]
           out_date[14] = in_str[15]
           out_date[15] = in_str[16]
           out_date[16] = in_str[17]
           out_date[17] = in_str[18]
           out_date[18] = in_str[19]
           out_date[19] = in_str[20]
        }
#-----------------------------------------------------
# Copy the input month 3 letter string into a temp var
#-----------------------------------------------------
	call strcpy(in_str[4], month_str, 3)

#-------------------------------------------------------------------
# month_idx will be set to the char following the last char in the 
# input month, e.g. if month_str is FEB, month_idx = 7, if month_str
# is APR, month_idx = 14 (this is the index into the all_months str)
#-------------------------------------------------------------------
	month_idx = strsearch(all_months, month_str)

#---------------------------------------
# int_month is 1 for Jan, 12 for Dec
#---------------------------------------
	int_month = (month_idx + 2)/3 - 1

#------------------------------
# Translate the int val to char
#------------------------------
	stat = itoc(int_month, temp_str, 2)

#----------------------------------------------
# Assign the two month digits to the out string
#----------------------------------------------
	if (int_month < 10)
	{
	   out_date[6] = '0'
	   out_date[7] = temp_str[1]
        }
	else
	{
	   out_date[6] = temp_str[1]
	   out_date[7] = temp_str[2]
	}
   }   # end of [ if ((len !=9)&&(len!=11)&&(len!=18)&&(len!=20)) ]
} 
# if in_str is NULL, assign out_date='YYYY-MM-DD'
else 
{   
       call strcpy("YYYY-MM-DD", out_date[1], 10)
}     # end of [ if (len != 0) ]

end   #(end of rdf_procdate)


##############################################################
# in_str = 'DD/MM/YY'   --> out_date = 'YYYY-MM-DD'
# eg.      '27/04/95'                  '1995-04-27'
##############################################################
procedure format_date(in_str, out_date)

char	in_str[ARB]
char    out_date[ARB]
int	strlen()
int     len
char    temp1, temp2
bool    streq()

begin

##      call printf("format_date\n")

#--------------------------
# Strip trailing whitespace
#--------------------------
	len = strlen(in_str)

if (len != 0)
{
	while (!IS_DIGIT(in_str[len]))
	  len = len - 1

	in_str[len + 1] = EOS

#---------------------------------------------------------------------
# JCC (7/98) 
# NOTE: This routine does not purport to be a general or generic date
# conversion routine.  It does one thing only.  Takes dates in this
# format: "DD/MM/YY" and turns it into this format: "YYYY-MM-DD" 
# (eg. "27/04/50" -> "1950-04-27" )
#---------------------------------------------------------------------

        ###### in_str   "DD/MM/YY"   ("27/04/50")
        ###### out_date "YYYY-MM-DD" ("1950-04-27")
	if (strlen(in_str) == 8)    # in_str is "DD/MM/YY"
	{
           #------------------------------
           # Assign the numerical DAY part
           #------------------------------
           out_date[9] = in_str[1]
	   out_date[10] = in_str[2]

           #----------------------
           # Assign the separators "-" for y2k
           #----------------------
	   out_date[5] = '-'
	   out_date[8] = '-'

           #----------------------
           # Assign year (YYYY)
           # DD/MM/YY  -> CCYY-MM-DD
           # if (YY >= 40)  CC = 19
           # else    CC=20
           #----------------------
           ##call strcpy("1", out_date[1], 1)
           ##call strcpy("9", out_date[2], 1)
           call strcpy (in_str[7], temp1, 1)  #in_str -> temp1
           if  (streq("0",temp1)||streq("1",temp1)||streq("2",temp1)
               ||streq("3",temp1) )
           {   out_date[1] = '2'
               out_date[2] = '0'
           }
           else
           {   out_date[1] = '1'
               out_date[2] = '9'
           }
	   out_date[3]  = in_str[7]
	   out_date[4]  = in_str[8]

           #----------------------
           # Assign month
           #----------------------
	   out_date[6] = in_str[4]
	   out_date[7] = in_str[5]
	}
        #### tricky: in_str could be NEW 'YYYY-MM-DD' or OLD 'DD/MM/YYYY'
        ####
        else if (strlen(in_str) == 10)
        {
           call strcpy (in_str[7], temp1, 1)  #in_str -> temp1    
           call strcpy (in_str[8], temp2, 1)  #in_str -> temp2

           ##check DD/MM/19YY -> then it's OLD format, convert to NEW
           ##check DD/MM/20YY -> then it's OLD format, convert to NEW
           if ( (streq("1",temp1)&&streq("9",temp2))
              || (streq("2",temp1)&&streq("0",temp2)) )
           {
              out_date[1] = in_str[7]   #year
              out_date[2] = in_str[8]
              out_date[3] = in_str[9]
              out_date[4] = in_str[10]
              out_date[5] = '-'
              out_date[6] = in_str[4]    #month
              out_date[7] = in_str[5]
              out_date[8] = '-'
              out_date[9] = in_str[1]    #day
              out_date[10] = in_str[2]
           }
           else   ### assume in_str is NEW format
           {
              call strcpy(in_str[1], out_date[1], 10)
           }
        }  # end of (strlen(in_str) == 10)
        else   # out_date will be same as in_str
        {
           call strcpy(in_str[1], out_date[1], len)
        }
}  
else  # if in_str is NULL string, assign out_date='YYYY-MM-DD'
{
   call strcpy("YYYY-MM-DD",out_date[1], 10)
   out_date[11] = EOS
}   # end of (if (len!=0))
end  #end of format_date
