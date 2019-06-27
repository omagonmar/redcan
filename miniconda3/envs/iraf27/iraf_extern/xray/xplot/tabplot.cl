# $Header: /home/pros/xray/xplot/RCS/tabplot.cl,v 11.0 1997/11/06 16:38:28 prosb Exp $
# $Log: tabplot.cl,v $
# Revision 11.0  1997/11/06 16:38:28  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:04:38  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:13  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/15  11:52:12  janet
#jd - update strfits after st param change to task.
#
#Revision 7.0  93/12/27  18:47:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:00  prosb
#General Release 2.2
#
#Revision 1.1  93/05/13  11:27:01  janet
#Initial revision
#
# ----------------------------------------------------------------------------
# Module:       tabplot.cl
# Description:  tabplot runs the TABLES task sgraph.  It is included in
#               xplot as a convenient place for users to find a task that
#		plots tables.  No special parameters are set to non-default
#               values of sgraph.
# -----------------------------------------------------------------------
procedure tabplot (input)

string input  {prompt="list of images, tables, or list files to graph",mode="a"}
string errcolumn {"",prompt="errors table column", mode="h"}
pset   dvpar     {prompt ="Device parameters", mode="h"}
pset   pltpar    {prompt ="Plot attributes", mode="h"}
pset   axispar   {prompt ="Scaling attributes", mode="h"}
string version   {"16Jul92",prompt="Date of sgraph installation", mode="h"}

begin

    sgraph (input, errcolumn=errcolumn, version=version)


end
