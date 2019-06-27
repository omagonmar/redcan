#$Header: /home/pros/xray/xtiming/RCS/timplot.cl,v 11.0 1997/11/06 16:46:04 prosb Exp $
#$Log: timplot.cl,v $
#Revision 11.0  1997/11/06 16:46:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:32:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:37:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:04:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:55:06  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:06:48  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:30:28  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/23  18:05:23  janet
#updated timplot parameters.
#
#Revision 3.0  91/08/02  02:00:00  prosb
#General Release 1.1
#
#Revision 2.2  91/07/21  16:21:03  janet
#*** empty log message ***
#
#Revision 2.1  91/07/21  16:17:53  janet
#gclose default changed to yes
#
#Revision 2.0  91/03/06  22:32:26  pros
#General Release 1.0
#
# -----------------------------------------------------------------------
# Module:	timplot.cl
# Description:  run the timing plot task with the option of a hardcopy.
#		Stplot package task sgikern is called to print the plot file.
#		Filename is input & existing file may be overwritten if 
#		clobber is set to yes
# -----------------------------------------------------------------------
procedure timplot(table, column)
    string  table	{prompt="Input Table File",mode="a"}
    string  column      {prompt="Plot data column name",mode="a"}
    string  plot_type   {"histo",min="histo|bar",prompt="Plot type",mode="h"}
    string  ecolumn     {"",prompt="Error column name",mode="h"}
    string  plot_title  {"", prompt="Plot Title",mode="h"}
    string  x_title     {"", prompt="X-Axis Title",mode="h"}
    string  y_title     {"", prompt="Y-Axis Title",mode="h"}
    bool    hdcopy      {no,prompt="Output to Printer?", mode="h"}
    bool    gclose      {no,prompt="Close Graph window after plot?", mode="h"}
    string  outplt      {prompt="Plot output file", mode="a"}
    int	    num_plots   {1, prompt="number of plots",mode="h"}
    string  x_units     {"bin", prompt="X axis - bin|seconds|freq|phase",mode="h"}
    real    x_tics      {4., prompt="num x labels",mode="h"}
    real    y_tics       {4., prompt="num y labels",mode="h"}
    real    label_size  {.75, prompt="labels format",mode="h"}
    real    tlabel_size {.5, prompt="tic labels format",mode="h"}
    string  x_range  {"auto",prompt="x_range - auto|input limits",mode="h"}
    string  y_range  {"auto",prompt="y_range - auto|input limits",mode="h"}
    bool    clobber  {no, prompt="Overwrite existing plot?",mode="h"}	
    string  cursor   {"", prompt="Graphics cursor input",mode="h"}	

begin

    string  ecol	# table error column name
    string  oplt	# output plot filename
    string  ptype	# type of plot: histo | point
    string  tbl		# input table filename
    string  ycol	# table data column name

#
# Input parameters to run task 

#   Check if the user wants a Hardcopy of the Plot
#
    if( hdcopy ) {

# make sure stplot is already loaded 
        if ( !deftask ("sgikern") )
          error (1, "Requires plot to be loaded!")

        tbl=table
        ptype=plot_type
        ycol=column
        ecol=ecolumn
#
#       Get the Plot Filename & Check if it Exists and the status of Clobber
        oplt=outplt
	if( access(oplt) && !clobber ) 
	   error (1,"Output file already exists!!")
	else if (access(oplt) && clobber )
	   delete (oplt)
#
#       Run the Timing Plot Task WITH the file output option set
        _timplot (tbl, ycol, plot_type=ptype, ecol=ecol, 
             num_plots=num_plots, x_units=x_units,x_tics=x_tics,
             gclose=yes, y_tics=y_tics, plot_title=plot_title,
             x_title=x_title, y_title=y_title, label_size=label_size, 
             tlabel_size=tlabel_size, x_range=x_range, y_range=y_range, 
             cursor=cursor, >G oplt)
#
#       Load the Stplot package and print the plot file
        sgikern (oplt, device="stdplot", generic=no, debug=no, 
		    verbose=no, gkiunits=no)
        bye

    } else
        tbl=table
        ptype=plot_type
        ycol=column
        ecol=ecolumn
#
#       Run the Timing Plot Task WITHOUT the file output option set
        _timplot (tbl, ycol, plot_type=ptype, ecol=ecol, 
             num_plots=num_plots, x_units=x_units,x_tics=x_tics,
             gclose=gclose, y_tics=y_tics, plot_title=plot_title,
             x_title=x_title, y_title=y_title, label_size=label_size,
             tlabel_size=tlabel_size, x_range=x_range, y_range=y_range, 
             cursor=cursor) 
end
