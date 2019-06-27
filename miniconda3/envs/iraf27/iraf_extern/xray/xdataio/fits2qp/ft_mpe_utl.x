#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_mpe_utl.x,v 11.1 1999/09/21 15:08:37 prosb Exp $
#$Log: ft_mpe_utl.x,v $
#Revision 11.1  1999/09/21 15:08:37  prosb
#JCC(6/98) - Updated mpe_get_month to put CENTURY for year
#
#Revision 11.0  1997/11/06 16:34:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:24  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:39  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:28  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:26  prosb
#General Release 2.1
#
#Revision 1.3  92/10/15  16:26:03  jmoran
#*** empty log message ***
#
#Revision 1.2  92/10/05  14:46:26  jmoran
#JMORAN removed debug statements
#
#Revision 1.1  92/09/23  11:35:21  jmoran
#Initial revision
#

include <ctype.h>
include <mach.h>
include <evmacro.h>
include <fset.h>
include "cards.h"
include "ftwcs.h"
include "fits2qp.h"
include "mpefits.h"


double procedure mpe_ra2deg(in_str)

char 	in_str[ARB]
int	stat
int	sscan()
int	stridx()
char 	ch
int	pos
double	sum
double	dbuf

begin

#---------------------------------------------------------------
# This routine assumes that the input string is of the following
# form:  [0-23]H[0-59]M[0-59.[0-9]*]S
#
# For example:   14H23M43.8S
#
# The calculation is:
# 	
#	sum = 15 * (hours + minutes/60 + seconds/3600)
#---------------------------------------------------------------

#-----------------------------------
# Make sure the string is upper case
#-----------------------------------
        call strupr(in_str)

#--------------
# Get the hours 
#-------------- 
        stat = sscan(in_str)
        call gargd(dbuf)
        sum = dbuf

#------------------
# Jump over the 'H'
#------------------
        ch = 'H'
        pos = stridx(ch, in_str)

#----------------
# Get the minutes
#----------------
        stat = sscan(in_str[pos + 1])
        call gargd(dbuf)
        sum = sum + dbuf/60.D0

#------------------
# Jump over the 'M'
#------------------
        ch = 'M'
        pos = stridx(ch, in_str)

#----------------
# Get the seconds
#----------------
        stat = sscan(in_str[pos + 1])
        call gargd(dbuf)
        sum = sum + dbuf/3600.D0

#------------------
# Change to degrees
#------------------
        sum = 15.D0 * sum

#---------------------------
# Return the converted value
#---------------------------
	return sum

end


double procedure mpe_dec2deg(in_str)

char    in_str[ARB]
int     stat
int     sscan()
int     stridx()
char    ch
int     pos
double  sum
double  dbuf
int     sign_pos
bool    neg_bool
char    deg_str[3]

begin

#---------------------------------------------------------------
# This routine assumes that the input string is of the following
# form:  [-|+][0-90]H[0-59]M[0-59.[0-9]*]S
#
# For example:   -75D23M43.8S
#
# The calculation is:
#
#       sum = sign * (hours + minutes/60 + seconds/3600)
#---------------------------------------------------------------

#-----------------------------------
# Make sure the string is upper case
#-----------------------------------
        call strupr(in_str)

#-------------------------------------------
# Determine whether there is a negative sign
#-------------------------------------------
	neg_bool = false
	ch = '-'
	if (stridx(ch, in_str) != 0)
	   neg_bool = true

#------------------------------------
# Jump over positive or negative sign
#------------------------------------
	sign_pos = 1
	while (!IS_DIGIT(in_str[sign_pos]))
	  sign_pos = sign_pos + 1

#------------- 
# Find the 'D'
#-------------
	ch = 'D'
	pos = stridx(ch, in_str)

#-----------------------------------------------------------------
# Copy from the first number after the pos/neg sign to the last
# number before the 'D'.  This is necessary because the "sscan"
# and "garg[]" fucntions will interpret the 'D' as an expontential
# notation signifier.  e.g. 45D36M20S will be interpreted as
# 4.5e37
#-----------------------------------------------------------------
	call strcpy(in_str[sign_pos], deg_str, pos - sign_pos)
	stat = sscan(deg_str)
	call gargd(dbuf)
	sum = dbuf

#----------------
# Get the minutes
#----------------
	stat = sscan(in_str[pos + 1])
	call gargd(dbuf)
	sum = sum + dbuf/60.D0

#------------------
# Jump over the 'M'
#------------------
	ch = 'M'
	pos = stridx(ch, in_str)

#----------------
# Get the seconds
#----------------
	stat = sscan(in_str[pos + 1])
	call gargd(dbuf)
	sum = sum + dbuf/3600.D0

#--------------------------------
# If negative sign, make negative
#--------------------------------
	if (neg_bool)
   	   sum = -1 * sum

#---------------------------
# Return the converted value
#---------------------------
        return sum

end


procedure mpe_get_month(in_str, out_date)

char	in_str[ARB]
char    out_date[ARB]
char    all_months[SZ_LINE]
char    month_str[3]
char	temp_str[2]
int     int_month
int     month_idx
int	stat
int	strsearch()
int     itoc()
int	strlen()
int	len

begin

        call printf("mpe_get_month\n")   # jcc (6/98)
#--------------------------
# Strip trailing whitespace
#--------------------------
	len = strlen(in_str)
	while (!IS_DIGIT(in_str[len]))
	  len = len - 1

	in_str[len + 1] = EOS

#---------------------------------------------------------------------
# NOTE: This routine does not purport to be a general or generic date
# conversion routine.  It does one thing only.  Takes dates in this
# format: "DD-MMM-YYYY" OR "DD-MMM-YY" and turns it into this 
# format: "DD/MM/YY"  (eg.  "27-APR-1950" -> "27/04/50" )
#
#JCC(6/98) - output date with format DD/MM/YYYY
#---------------------------------------------------------------------
	call strcpy("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC",all_months,SZ_LINE)

#------------------------------
# Assign the numerical DAY part
#------------------------------
        out_date[1] = in_str[1]
	out_date[2] = in_str[2]

#----------------------
# Assign the separators
#----------------------
	out_date[3] = '/'
	out_date[6] = '/'

#--------------------------------
# Assign the last two year digits
#
#JCC(6/98) - new format for out_date ( DD/MM/YY  -> YYYY/MM/DD )
#--------------------------------
        ###### in_str =DD-MMM-YYYY ; new out_date=YYYY 
	if (strlen(in_str) == 11)    #ie. in_str =DD-MMM-YYYY
	{
	   #jcc- out_date[7] = in_str[10]
	   #jcc- out_date[8] = in_str[11]
	   out_date[7]  = in_str[8]
	   out_date[8]  = in_str[9]
	   out_date[9]  = in_str[10]
	   out_date[10] = in_str[11]
	}
        ###### in_str =DD-MMM-YY;  new out_date=19YY
	else            
	{                    
           #jcc- out_date[7] = in_str[8]
           #jcc- out_date[8] = in_str[9]
           call strcpy("1", out_date[7], 1)
           call strcpy("9", out_date[8], 1)
           out_date[9]  = in_str[8]
           out_date[10] = in_str[9]
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
	   out_date[4] = '0'
	   out_date[5] = temp_str[1]
        }
	else
	{
	   out_date[4] = temp_str[1]
	   out_date[5] = temp_str[2]
	}
end
