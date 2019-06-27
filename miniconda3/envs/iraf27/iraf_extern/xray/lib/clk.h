#$Header: /home/pros/xray/lib/RCS/clk.h,v 11.0 1997/11/06 16:24:46 prosb Exp $
#$Log: clk.h,v $
#Revision 11.0  1997/11/06 16:24:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:18  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:42:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:36:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:42  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:06:23  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:46:23  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:02:24  pros
#General Release 1.0
#
define	MJDREFYEAR	1975
define	MJDREFDAY	  87
define	MJDREFOFFSET	42499.5D0   # True MJD for noon of the above day
				    #  => add this to the result of mutjd
				    #     or subtract from jd before mjdut

# define the refclk structure
define	LEN_CLK		10          # oops - two names for this
define	SZ_CLK		LEN_CLK	    # 
define	FRACSEC		Memd[P2D($1+0)]	
define	SECOND		Memi[$1+2]	
define	MINUTE		Memi[$1+3]	
define	HOUR		Memi[$1+4]	
define	DAY		Memi[$1+5]	
define	MDAY		Memi[$1+6]
define	WDAY		Memi[$1+7]
define	MONTH		Memi[$1+8]
define	YEAR	 	Memi[$1+9]	

