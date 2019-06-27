#$Header: /home/pros/xray/xspectral/source/RCS/ct_chans.x,v 11.0 1997/11/06 16:41:54 prosb Exp $
#$Log: ct_chans.x,v $
#Revision 11.0  1997/11/06 16:41:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:08  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:11  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:42  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:39  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/25  11:23:30  orszak
#jso - no change for first installation of new qpspec
#
#Revision 3.1  91/09/22  19:05:25  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:58  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:37:28  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:02:03  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
include <spectral.h>

#
#  CT_CHANS -- Determine the number of channels used in fit
#
int  procedure  ct_chans(fp)

pointer fp                              # i: parameter data structure

int     i, j				# l: loop counters
pointer	ds				# l: data set pointer
pointer flags				# l: pointer to channel flags
int	nbins				# l: number of bins in data set
int     count                           # l: number of channels

begin
	count = 0
	do i = 1, FP_DATASETS(fp){
	    ds = FP_OBSERSTACK(fp,i)
	    nbins = DS_NPHAS(ds)
	    flags = DS_CHANNEL_FIT(ds)
	    do j=1, nbins{
		if( Memi[flags+j-1] !=0 )
		    count = count + 1
	    }
	}
        return (count)
end

