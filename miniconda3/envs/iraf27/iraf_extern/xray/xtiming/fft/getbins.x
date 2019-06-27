#$Header: /home/pros/xray/xtiming/fft/RCS/getbins.x,v 11.0 1997/11/06 16:44:37 prosb Exp $
#$Log: getbins.x,v $
#Revision 11.0  1997/11/06 16:44:37  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:25  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/13  14:24:07  mo
#MC	4/12/94		Update TOTCNTS to real (not integer) since
#			not all data is integer
#
#Revision 7.0  93/12/27  19:01:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:22  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  08:47:14  mo
#MC/JD	5/20/93		More updates for d,p. exposure time
#
#Revision 5.1  92/12/18  12:35:39  janet
#changed binlen to double, forced type conversion to real in assignment.
#
#Revision 5.0  92/10/29  22:49:01  prosb
#General Release 2.1
#
#Revision 4.2  92/09/29  14:09:03  mo
#MC 	9/29/92		Updated calling sequence for begs and ends rather
#			than 2 dimensional GTIs/
#
#Revision 4.1  92/09/04  17:38:46  mo
#MC	9/4/92		Fix to set exposure time = bin time, if there
#			is no exposure column in the data file
#			( This can be true for foreign files )
#
#Revision 4.0  92/04/27  15:32:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/02/20  17:40:34  mo
#MC	2/20/92		Add start and stop values retrieved from input
#			table option
#
#Revision 3.2  91/12/18  15:17:51  mo
#MC	12/18/91	ADd code to sum all input values 
#
#Revision 3.1  91/09/25  17:22:58  mo
#9/23/91	JD/MC		Add the background file to the
#				calling sequences for the QPOE option
#				input type
#
#Revision 2.1  91/07/21  17:47:24  mo
#MC	7/21/91		Fix bad calling sequence for fft_filehdr htat
#			caused segmentation violation
#			Better headers for _ftp.tab output file
#
#Revision 2.0  91/03/06  22:44:03  pros
#General Release 1.0
#

include <tbset.h>
#include "filelist.h"
define  FFT_FATAL       1
include "ltcio.h"
include	"fft.h"
include	"../timlib/timing.h"
include	"binpars.h"
include	"ext.h"

#  ------------------------------------------------------------------------

int procedure read_bin(display,binpars, currec, expthresh,
                        datacol, source_bins,no_bins,segno,binsperseg,sumcts,exp)

int	display			# i: display level
char	datacol[ARB]		# i: name of data column
int	currec			# i/o: 
pointer	binpars
int	no_bins			# i: number of photons expected
int	segno			# i: current segment number
real	expthresh		# i: exposure threshold for accepting bin
real	cur_exp			# l: current exposure value for bin
double	exp			# i/o: sum of exposure times
real	source_bins[ARB]	# i/o: current data bins

int	binsperseg		# i: number of bins per segment
real	sumcts			# i/o: total input counts
int	i			# l: loop counter
int	currow			# l: row number in input table
int	lastrow			# l: last row of input table

include	"qpinput.cmn"
begin

# First time, find the appropriate table column
	if( currec == 1 ) {
	    currow = 1
	}
	i=1
#  If we are taking segments from one file currow has been reset to 1 
	if( no_bins != binsperseg && currow == 1) 
	    currow = (segno-1) * binsperseg + (currec-1)*NELEM+i
#  otherwise the currow is wherever we left off last time
	lastrow = segno * binsperseg
	exp = 0.0D0	# In case rd_bins doesn't get called
	while( i <= NELEM && currow <= no_bins && currow <= lastrow) {
	    if( TYPE(ltcio) == TABLE )
		call tb_rd_bins(TP(ltcio),colptr,source_bins[i],currow,expptr,
				cur_exp)
	    else if( TYPE(ltcio) == QPOE )
		call qp_rd_bins(display,ltcio,binpars,currow,gbegs,gends,num_gintvs,
				datacol,minmax,source_bins[i],cur_exp)
	    if( expptr != NULL || TYPE(ltcio) == QPOE ){  # if there is an exposure data column - always OK with QPOE
	        if( cur_exp < expthresh ) {
	           cur_exp = 0.0E0
	           source_bins[i]=0.0E0
		}
	    } else {
                # otherwise force full exposure
		cur_exp = real (BINLENGTH(binpars))	
            }
            call fill_gap(cur_exp,source_bins,currow,i)
            currow = currow+1
	    exp = exp + cur_exp
	    sumcts = sumcts + source_bins[i]
	    i=i+1
	}
	if( currow > no_bins && i == 1 && currow > lastrow)
	    call finish_gap(source_bins,currow,i)
	return(i-1)
end


pointer procedure open_input(display,datacol,type,binpars,infile,bkfile,no_bins)
int	display		# i: display level
char	datacol[ARB]
int	type
char	infile[ARB]	# i: input file
char	bkfile[ARB]	# i: input bk file
pointer	binpars
int	no_bins		# o: number of input bins
double  area		# o: area of photon selection region


#char	bk_file[SZ_PATHNAME]	# l: bkgd file
#char	photon_file[SZ_PATHNAME]	# l: bkgd file
double	duration
pointer	td
#int	tbtacc()
#bool	none

pointer	tbtopn()
include	"qpinput.cmn"
begin
	call calloc(ltcio,SZ_LTCIO,TY_STRUCT)
	TYPE(ltcio) = type
	if( TYPE(ltcio) == QPOE ){
	    call calloc(minmax,LEN_MMM,TY_STRUCT)
	    call qp_rd_hd(display,infile,bkfile,datacol,ltcio,
                        binpars,no_bins,gbegs,gends,num_gintvs,
			duration, minmax,TOTEXP(ltcio))
	    area = SRC_AREA(ltcio)
	    td = SQP(ltcio)
	}
	else{
	    TP(ltcio)= tbtopn(infile,READ_ONLY,NULL)
	    call tb_rd_hd(display,no_bins,BINLENGTH(binpars),START(binpars),
			  STOP(binpars),area,TP(ltcio),
			  datacol,colptr,expptr)
	    td = TP(ltcio)
	}
       if( display > 1 ){
            call printf("Expect to read %d bins from ltcurv file: %s\n")
               call pargi (no_bins)
               call pargstr (infile)
            call printf( "Area of photon collection is %f \n")
               call pargd(area)
            call flush(STDOUT)
       }
        call fft_filehdr(SQP(ltcio),BQP(ltcio),DOBKGD(ltcio),
			START(binpars),STOP(binpars),BINLENGTH(binpars),
			no_bins,SRC_AREA(ltcio),BK_AREA(ltcio))
        call ftp_filehdr(SQP(ltcio),BQP(ltcio),DOBKGD(ltcio),
			START(binpars),STOP(binpars),BINLENGTH(binpars),
			no_bins,SRC_AREA(ltcio),BK_AREA(ltcio))
        call pwr_filehdr(SQP(ltcio),BQP(ltcio),DOBKGD(ltcio),
			START(binpars),STOP(binpars),BINLENGTH(binpars),
			no_bins,SRC_AREA(ltcio),BK_AREA(ltcio))
	return (td)
end

procedure inclose()
include	"qpinput.cmn"
begin
	if( TYPE(ltcio) == QPOE )
	    call qp_cls_bin(ltcio)
	else
	    call tb_cls_bin(TP(ltcio))
	call mfree(ltcio,TY_STRUCT)
	call mfree(minmax,TY_STRUCT)
end

pointer procedure get_bktab()
include "qpinput.cmn"
begin
#	type = TYPE(ltcio)
	if( TYPE(ltcio) == QPOE )
	    return(BQP(ltcio))
	else if( TYPE(ltcio) == TABLE )
	    return(TP(ltcio))
end

pointer procedure get_intab(type)
int	type
include "qpinput.cmn"
begin
	type = TYPE(ltcio)
	if( TYPE(ltcio) == QPOE )
	    return(SQP(ltcio))
	else if( TYPE(ltcio) == TABLE )
	    return(TP(ltcio))
end
