#$Header: /home/pros/xray/xproto/imdetect/RCS/get_snrcoeff.x,v 11.0 1997/11/06 16:39:57 prosb Exp $
#$Log: get_snrcoeff.x,v $
#Revision 11.0  1997/11/06 16:39:57  prosb
#General Release 2.5
#
#Revision 1.1  1997/10/06 15:18:55  prosb
#Initial revision
#
#Revision 1.1  1997/10/06 15:12:16  prosb
#Initial revision
#
#Revision 1.3  1997/03/03 20:19:43  prosb
#JCC(3/3/97) - cell_area is no longer forced to be 144, add more options
#              to imdetect.par.
#
#Revision 1.2  1997/02/10  21:57:43  prosb
#JCC(1/27/97) : always search for "num_144_snr*" in imdetect.par 
#               (ie.  cell_area=144 )
#
#Revision 1.1  1996/11/04  21:50:19  prosb
#Initial revision
#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/imdetect.x (rev9.0)
#
procedure get_snrcoeff(cell_area,num_coeffs, snr_coeffs, snr_thresh_min)

int     cell_area               #o: area of a subcell in arc seconds
int     num_coeffs              #o: of snr cooefs for the cell

real    snr_coeffs[0:*]         #o: snr cooefs for the cell
real    snr_thresh_min          #o: snr thresh lower limit

#char  bk_min[80]                #string for min bkdensity
#char  cell_id[80]               #string of the cell area
char   num_snr_coeffs[SZ_LINE]   #rdpar string for # snr coeffs
char   snr_cell_coeffs[SZ_LINE]  #rdpar string for snr coeffs
char   snr_min[SZ_LINE]          #string for min snr value
 
int	ii
real	clgetr()

begin

#    build snr cooeficients parameter names
#       call build_name('num_', cell_area, cell_id)
#       num_snr_coeffs = cell_id(1:stlen(cell_id)) // '_snr_coeffs'

#JCC(1/27/97) - set cell_area=144  
#       cell_area = 144     # JCC (3/3/97)
	call sprintf( num_snr_coeffs,SZ_LINE,"num_%d_snr_coeffs")
	call pargi( cell_area )
#       call build_name ('snr_coeffs_', cell_area, snr_cell_coeffs)
#       call sprintf(snr_cell_coeffs,SZ_LINE,"snr_coeffs_%d")
#       call pargi( cell_area )

#       call build_name('snr_thresh_min_',cell_area, snr_min)
	call sprintf(snr_min,SZ_LINE,"snr_%d_thresh_min")
        call pargi( cell_area )

#    read from system parameter file
        num_coeffs = clgetr(num_snr_coeffs)
	do ii=1,num_coeffs
	{
            call sprintf(snr_cell_coeffs,SZ_LINE,"snr_%d_%d_coeffs")
            call pargi( cell_area )
	    call pargi(ii)
	    snr_coeffs[ii-1] = clgetr(snr_cell_coeffs)
	}
	snr_thresh_min = clgetr(snr_min)
end     
