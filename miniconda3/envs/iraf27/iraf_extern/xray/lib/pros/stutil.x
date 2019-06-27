#$Header: /home/pros/xray/lib/pros/RCS/stutil.x,v 11.0 1997/11/06 16:21:11 prosb Exp $
#$Log: stutil.x,v $
#Revision 11.0  1997/11/06 16:21:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:44  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:54:13  prosb
#General Release 2.2
#
#Revision 1.1  93/05/19  17:11:52  mo
#Initial revision
#

procedure strclr(str)

char	str[ARB]

int	i
int	len
int	strlen()

begin

	len = strlen(str)
	if (len > 0) 
	   for (i=1; i<=len; i=i+1)
	      str[i] = EOS
end

include	<ctype.h>

#-------------------------------------------------------------------
# PROCEDURE: strip_whitespace(str)
#
# 	This procedure takes as input a string of any length and
# returns (in the same string variable) that string stripped of
# whitespace.  The whitespace is stripped off the beginning and 
# end of the string.  It does not affect the whitespace within
# the string.  For example:
#
#				     becomes
# 	"    Hello World        "    ------->    "Hello World"
#
#	whereas the string:
#	"Hello 	World 	    Again Once     More"  is not changed.
# 	
#	and the string:
#	"		"	     ------->    ""
#
#-------------------------------------------------------------------

procedure strip_whitespace(str)

char	str[ARB]		#i/o: input and output string

int	idx			#l: loop index
int	len			#l: length of output string
int	start_str		#l: index of start of non-whitespace
int	end_str			#l: index of end of non-whitespace
int	new_str			#l: index for output string
int	strlen()		#l: string length function
pointer	tempstr			#l: temporary string
pointer sp			#l: stack pointer

begin
	call smark(sp)

	#----------------------------------
	# get string length of input string
        #----------------------------------
	len = strlen(str)

	#---------------------
	# initialize variables
	#---------------------
	start_str = 1
	end_str = len
	new_str = 0

	#--------------------------
	# find first non-whitespace
	#--------------------------
	while (IS_WHITE(str[start_str]))
	{
	  start_str = start_str + 1
	}

	#-------------------------
	# find last non-whitespace
	#-------------------------
	while (IS_WHITE(str[end_str]))
	{
	  end_str = end_str - 1
	}

	#--------------------------------------------------------------
	# if (end_str < start_str) means that the string is composed of
	# all whitespace, so clear it out.
	#-------------------------------------------------------------- 
	if (end_str < start_str)
	{
	   call strclr(str)
	}
	else
	{
	   #-----------------------------
	   # find length of output string
	   #-----------------------------
	   len = end_str - start_str + 1

	   #-------------------------------
	   # allocate space for temp string
	   #-------------------------------
	   call salloc(tempstr, len, TY_CHAR)

	   #----------------------------------------------------
	   # copy the non-whitespace string into the temp string
	   #----------------------------------------------------
	   for (idx = start_str; idx <= end_str; idx = idx + 1)
	   {
	      Memc[tempstr + new_str] = str[idx]
	      new_str = new_str + 1
	   }

	   #----------------------------------------------------
	   # copy the temp string into the original input string
	   #----------------------------------------------------
	   call strcpy(Memc[tempstr], str, len)

	}
	call sfree(sp)
end
