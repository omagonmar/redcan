#$Header: /home/pros/xray/xtiming/RCS/fftplot.cl,v 11.0 1997/11/06 16:45:28 prosb Exp $ 
#$Log: fftplot.cl,v $
#Revision 11.0  1997/11/06 16:45:28  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:32:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:37:13  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:04:08  prosb
#General Release 2.3
#
#Revision 6.1  93/11/03  14:29:33  janet
#jd - added default naming, update default x-axis to normpower.
#
#Revision 6.0  93/05/24  16:54:35  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:06:31  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:29:59  prosb
#General Release 2.0:  April 1992
#
#Revision 1.3  92/04/23  18:03:20  janet
#put in final form.
#
#Revision 1.2  91/10/07  17:26:42  janet
#*** empty log message ***
#
#Revision 1.1  91/10/07  17:24:57  janet
#Initial revision
#
#
# -----------------------------------------------------------------------
# Module:	fftplot.cl
# Description:  run the timing plot task with the default params for fft table.
# -----------------------------------------------------------------------
procedure fftplot(table)
    string  table     {prompt="Input Table File",mode="a"}
    string  column    {"normpower",prompt="Plot data column name",mode="h"}
    string  plot_type {"histo",min="histo|bar",prompt="Plot type - histo|bar",mode="h"}
    string  ecolumn   {"",prompt="Error column name",mode="h"}
    string  plot_title {"Power Spectrum :", prompt="Plot Title",mode="h"}
    string  x_title   {"frequency (Hz)", prompt="Plot Title",mode="h"}
    string  y_title   {"", prompt="Plot Title",mode="h"}
    bool    hdcopy    {no,prompt="Output to Printer?", mode="h"}
    bool    gclose    {no,prompt="Close Graph window after plot?", mode="h"}
    string  outplt    {prompt="Plot output file", mode="a"}
    int	    num_plots {1, prompt="number of plots",mode="h"}
    string  x_units   {"freq", prompt="X axis units - seconds | col name",mode="h"}
    real    x_tics     {4., prompt="num x labels",mode="h"}
    real    y_tics     {4., prompt="num y labels",mode="h"}
    real    label_size  {.75, prompt="labels format",mode="h"}
    real    tlabel_size {.5, prompt="tic labels format",mode="h"}
    string  x_range   {"auto",prompt="x_range - auto|input limits",mode="h"}
    string  y_range   {"auto",prompt="y_range - auto|input limits",mode="h"}
    bool    clobber   {no, prompt="Overwrite existing plot?",mode="h"}	
    string  cursor    {"", prompt="Graphics cursor input",mode="h"}	

begin

    string  ecol	# table error column name
    string  oplt	# output plot filename
    string  ptype	# type of plot: histo | point
    string  tbl		# input table filename
    string  tb		# input table filename

#
# Input parameters to run task 

#   Check if the user wants a Hardcopy of the Plot
#
    if( hdcopy ) {

# make sure stplot is already loaded 
        if ( !deftask ("sgikern") )
          error (1, "Requires plot to be loaded!")

        tb=table
        _rtname(tb,tb,"_fft.tab")
        tbl=s1

        ptype=plot_type
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
        _timplot (tbl, column=column, plot_type=ptype, ecol=ecol, 
	     num_plots=num_plots,
             x_units=x_units,x_tics=x_tics,gclose=yes, y_tics=y_tics, 
             plot_title=plot_title,x_title=x_title, y_title=y_title,
	     label_size=label_size, tlabel_size=tlabel_size, x_range=x_range, 
	     y_range=y_range, cursor=cursor, >G oplt)
#
#       Load the Stplot package and print the plot file
        sgikern (oplt, device="stdplot", generic=no, debug=no, 
		    verbose=no, gkiunits=no)
        bye

    } else
        tb=table
        _rtname(tb,tb,"_fft.tab")
        tbl=s1

        ptype=plot_type
        ecol=ecolumn
#
#       Run the Timing Plot Task WITHOUT the file output option set
        _timplot (tbl, column=column, plot_type=ptype, ecol=ecol, 
	     num_plots=num_plots,
             x_units=x_units,x_tics=x_tics,gclose=gclose, y_tics=y_tics, 
             plot_title=plot_title,x_title=x_title, y_title=y_title,
	     label_size=label_size,tlabel_size=tlabel_size, x_range=x_range, 
	     y_range=y_range, cursor=cursor) 
end
