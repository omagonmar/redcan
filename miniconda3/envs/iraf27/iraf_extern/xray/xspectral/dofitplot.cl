# $Header: /home/pros/xray/xspectral/RCS/dofitplot.cl,v 11.0 1997/11/06 16:43:44 prosb Exp $
# $Log: dofitplot.cl,v $
# Revision 11.0  1997/11/06 16:43:44  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:27:39  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:27:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:59:03  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:46:26  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:47:11  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:25:58  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/20  13:07:08  prosb
#jso - changed default file to null string.
#
#Revision 3.1  91/09/27  15:47:51  mo
#MC	9/27/91		Add the comment character to the RCS header
#
#;;; Revision 3.0  91/08/02  01:52:41  prosb
#;;; General Release 1.1
#;;; 
#
# Module:       dofitplot.cl
# Project:      PROS -- ROSAT RSDC
# Purpose:      Do a fit and then a plot (counts_plot) sequentially
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} TK	initial version 7/91
#               {n} <who> -- <does what> -- <when>
#
# ======================================================================
procedure dofitplot(observed,model,print_table,print_plot)
# ======================================================================

  string observed=""		   {prompt="observed spectrum [root_obs.tab]"}
  string model=""		   {prompt="model descriptor"}
  bool print_table=no    	   {prompt="table hardcopy"}
  bool print_plot=no	           {prompt="plot hardcopy"}

  begin

# Declare the intrinsic parameters:
 
	string obs			# observed spectrum
	string mod			# model descriptor
	bool print_tab	        	# print table?
	bool print_plt		 	# print plot?
        string prd                      # prd file name

# make sure packages are loaded
        if ( !deftask ("fit") )
          error (1, "Requires xspectral to be loaded!")
        if ( !deftask ("counts_plot") )
          error (1, "Requires xspectral to be loaded!")

# Get query parameters:
	
	obs = observed
	mod = model
	print_tab = print_table
	print_plt = print_plot
	
# run fit
	fit (observed=obs, model=mod, mode="h")

# if desired, print table
	if (print_tab) {
          prd=""
          _rtname(obs,prd,"_prd.tab")
	  tprint(s1,mode="h") | lpr
        }


# if desired, plot counts
        if (print_plt) 
          counts_plot(observed=obs, device="stdplot", mode="h")
        else
          counts_plot(observed=obs, device="stdgraph", mode="h")

        end




