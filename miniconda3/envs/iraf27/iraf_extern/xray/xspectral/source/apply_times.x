#$Header: /home/pros/xray/xspectral/source/RCS/apply_times.x,v 11.0 1997/11/06 16:41:48 prosb Exp $
#$Log: apply_times.x,v $
#Revision 11.0  1997/11/06 16:41:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:28:53  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:29:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:07  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:48:36  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:19  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:12:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  18:36:25  wendy
#added copyright
#
#Revision 3.0  91/08/02  01:57:48  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:30:14  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:01:25  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright

include  <spectral.h>


#  ----------------------------------------------------------------------------

#  Routine to apply the live times to the PHA spectra and yield predicted
#  spectra.

procedure  apply_live_time ( fp )

pointer	fp		# parameter structure
pointer	spectrum	# predicted spectrum
int	dataset		# data set index
int	nphas		# number of pha channels
real	live_time	# live time

begin
	dataset    = FP_CURDATASET(fp)
	live_time  = DS_LIVETIME( FP_OBSERSTACK(fp,dataset) )
	nphas      = DS_NPHAS( FP_OBSERSTACK(fp,dataset) )
	spectrum   = DS_PRED_DATA( FP_OBSERSTACK(fp,dataset) )
	call amulkr ( Memr[spectrum], live_time, Memr[spectrum], nphas)
end
