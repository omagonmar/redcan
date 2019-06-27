#$Header: /home/pros/xray/xspectral/RCS/x_xspectral.x,v 11.0 1997/11/06 16:43:52 prosb Exp $
#$Log: x_xspectral.x,v $
#Revision 11.0  1997/11/06 16:43:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:27:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:28:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:59:32  prosb
#General Release 2.3
#
#Revision 6.2  93/11/20  04:28:06  dennis
#Added downspecrdf task
#
#Revision 6.1  93/09/25  02:01:31  dennis
#Added upspecrdf task.
#
#Revision 6.0  93/05/24  16:46:59  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:47:31  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:26:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:52:59  prosb
#General Release 1.1
#
#Revision 2.1  91/06/24  18:10:39  mo
#MC	6/24/91		PROS restructuring
#
#Revision 2.0  91/03/06  23:13:34  pros
#General Release 1.0
#
# Executables for the spectral package.

task    fit             = t_fit,
	search_grid     = t_gridfit,
	counts_plot	= t_photplt,
	flux_plot       = t_pltflux,
	grid_plot       = t_pltgrid,
	bal_plot        = t_balplot,
	qpspec          = t_qpspec,
	show_models     = t_smodels,
	singlefit       = t_singlef,
	xflux           = t_xflux,
	upspecrdf	= t_upspecrdf,
	downspecrdf	= t_downspecrdf
