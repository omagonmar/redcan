#$Header: /home/pros/xray/xproto/RCS/tabfilter.cl,v 11.0 1997/11/06 16:39:11 prosb Exp $
#$Log: tabfilter.cl,v $
#Revision 11.0  1997/11/06 16:39:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:26:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:25:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:50:35  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  13:22:25  janet
#jd - added format param.
#
#Revision 6.0  93/05/24  16:43:12  prosb
#General Release 2.2
#
#Revision 1.1  93/05/21  18:34:32  mo
#Initial revision
#
# ----------------------------------------------------------------------------
# Module:       tabfilter.cl
# Description:  tabfilter runs the EUV.EUVRED task dqselect.  It is included 
#               in xproto as a convenient place for users to find a task that
#               creates filters from table files.  
# ----------------------------------------------------------------------------
procedure tabfilter (tables)

string tables {prompt="Monitor Tables", mode="a"}
string limits {"", prompt="Limits Tables", mode="h"}
int    gap    {5, prompt="Time Gap", mode="h"}
string imode  {"line", prompt="Input mode", mode="h"}
string format {"f", prompt="Interval format control", mode="h"}
string device {"stdgraph", prompt="Graphics device", mode="h"}

begin

	if( !defpac("euv") ){
   	   error (1,"requires euv package to be installed & loaded")
	}
	;

	printf("")
	if( !defpac("euvred") ){
	   error (1,"requires euvred package to be loaded")
	}
	;

   dqselect (tables, 
             limits=limits, gap=gap, imode=imode, format=format, device=device)

end
