# $Header: /home/pros/xray/xspectral/RCS/intrinsicspecplot.cl,v 11.0 1997/11/06 16:43:46 prosb Exp $
# $Log: intrinsicspecplot.cl,v $
# Revision 11.0  1997/11/06 16:43:46  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:27:46  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:28:07  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:59:13  prosb
#General Release 2.3
#
#Revision 6.2  93/11/15  09:54:20  mo
#MC	11/15/93		Update with new SGRAPH parameters
#				also CAN'T specify the 'AXIS' parameter
#				because it conflicts with 'axispars'
#
#Revision 6.1  93/11/12  09:42:04  mo
#MC	11/12/93		Update with the new sgraph/axispar parameter names
#
#Revision 6.0  93/05/24  16:46:34  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:47:16  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:26:08  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/23  17:58:26  mo
#MC	4/24/92		Add the 'pltpar' parameter defaults
#
#Revision 3.1  91/09/27  15:40:56  mo
#MC	9/27/91		Fix the comment character problem in RCS header
#
#;;; Revision 3.0  91/08/02  01:52:43  prosb
#;;; General Release 1.1
#;;; 
#
# Module:       INSTRINSICSPECPLOT.CL
# Project:      PROS -- ROSAT RSDC
# Purpose:      Do a plot of emitted and observed spectrum
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} TK       initial version    7/91
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
      procedure intrinsicspecplot(intrinsic,print_plot)
# ======================================================================

  string intrinsic="root_int.tab"   {prompt="intrinsic spectrum"}
  bool print_plot=no	           {prompt="plot hardcopy"}

  begin

# Declare the intrinsic parameters:
 
	string intrins			# intrinsic spectrum
	bool print_plt		 	# print plot?
	string inp			# input string to sgraph
	string plotdev			# where to print graph
	
# make sure packages are loaded

        if ( !deftask ("sgraph") )
          error (1, "Requires tables or stsdas/stplot to be loaded!")

# Get query parameters:
	
# Force the extension
        _rtname(intrinsic,"","_int.tab")

#	intrins = s1
	print_plt = print_plot
	

# do plot
	
        if (print_plt) 
	  plotdev="stdplot"
	else
	  plotdev="stdgraph"

	inp = s1//" energy emitted"
	sgraph(inp,xlabel="log energy (keV)",
	           ylabel = "log fd (keV/cm**2/s/keV)",
	           title = "Best-fit model: Emitted and Incident Spectra",
	           device = plotdev,
#	stack=no, axis=1, pointmode=no, marker="box", szmarker=0.005, erraxis=0,
	stack=no, pointmode=no, marker="box", szmarker=0.005, erraxis=0,
	errtype="bartck", pattern="solid", crvstyle="straight", rejectlog=yes,
	barpat="hollow", crvcolor=INDEF, color=INDEF, cycolor=no,
	wl=0., wr=0., wb=0., wt=0., logx=no, logy=no, xflip=no, yflip=no, 
	transpose=no, majrx=5, minrx=5, majry=5, minry=5, round=no, 
	margin=INDEF, lintran=no, p1=0., p2=0., q1=0., q2=1., box=yes, grid=no,
	ticklabels=yes, sysid=yes, 
	append=no, left=0., right=1., bottom=0., top=1., fill=yes, coords="",
	image_coord="", version="20Jul93")

#  	stack=no, wl=0., wr=0., wb=0., wt=0., xflip=no, yflip=no, axis=1, 
#	transpose=no, pointmode=no, marker="box", szmarker=0.005, erraxis=0, 
#	errcolumn="", errtype="bartck", pattern="solid", crvstyle="straight", 
#	logx=no, logy=no, rejectlog=yes, box=yes, ticklabels=yes, grid=no, 
#	sysid=yes, lintran=no, p1=0., p2=0., q1=0., q2=1., vx1=0.,
# 	vx2=0., vy1=0., vy2=0., majrx=5, minrx=5, majry=5, minry=5, round=no,
#	margin=INDEF, fill=yes)

	inp = s1//" energy incident"

	sgraph(inp, device = plotdev, append+,
#	stack=no, axis=1, pointmode=no, marker="box", szmarker=0.005, erraxis=0,
	stack=no, pointmode=no, marker="box", szmarker=0.005, erraxis=0,
	errtype="bartck", pattern="solid", crvstyle="straight", rejectlog=yes,
	barpat="hollow", crvcolor=INDEF, color=INDEF, cycolor=no,
	wl=0., wr=0., wb=0., wt=0., logx=no, logy=no, xflip=no, yflip=no, 
	transpose=no, majrx=5, minrx=5, majry=5, minry=5, round=no, 
	margin=INDEF, lintran=no, p1=0., p2=0., q1=0., q2=1., box=yes, grid=no,
	ticklabels=yes, sysid=yes, 
	append=no, left=0., right=1., bottom=0., top=1., fill=yes, coords="",
	image_coord="", version="20Jul93")

#	stack=no, wl=0., wr=0., wb=0., wt=0., xflip=no, yflip=no, axis=1, 
#	transpose=no, pointmode=no, marker="box", szmarker=0.005, erraxis=0, 
#	errcolumn="", errtype="bartck", pattern="solid", crvstyle="straight", 
#	logx=no, logy=no, rejectlog=yes, box=yes, ticklabels=yes, grid=no, 
#	xlabel="", ylabel="", title="imtitle", sysid=yes, lintran=no, p1=0., 
#	p2=0., q1=0., q2=1., vx1=0., vx2=0., vy1=0., vy2=0., majrx=5, minrx=5, 
#	majry=5, minry=5, round=no, margin=INDEF, fill=yes)
#
  end




