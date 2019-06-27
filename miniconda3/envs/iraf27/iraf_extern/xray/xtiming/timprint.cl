#$Header: /home/pros/xray/xtiming/RCS/timprint.cl,v 11.0 1997/11/06 16:46:05 prosb Exp $
#$Log: timprint.cl,v $
#Revision 11.0  1997/11/06 16:46:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:32:41  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:37:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:04:36  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:55:09  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:06:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:30:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:00:01  prosb
#General Release 1.1
#
#Revision 2.1  91/08/01  22:09:46  mo
#JD	Change package loading requirements
#
#Revision 2.0  91/03/06  22:32:27  pros
#General Release 1.0
#
# -----------------------------------------------------------------------
# Module:	timprint.cl
# Description:  Display tables created from timing tasks with tprint.  
#		Parameters set to accomodate header display, 132 character 
#		page width, and output of all the table rows.
# -----------------------------------------------------------------------
procedure timprint(table)
    string	table   {prompt="> table file name",mode="a"}
    bool	prparam {yes, prompt="> Print Table Header?",mode="h"}
    string	rows    {"-", prompt="> Range of rows to print",mode="a"}

begin

  if ( !deftask ("tprint") )
      error (1, "Requires stsdas/ttools or tables to be loaded to find tprint!")

# Load the Ttools package & task tprint w/ params set for timing tables display
    set ttyncols = 132
    tprint (table, prparam=prparam, prdata=yes, pwidth=132, plength=0, 
	    showrow=yes, showhdr=yes, columns="", rows=rows, option="plain", 
	    align=yes, sp_col="", lgroup=0)

bye
end
