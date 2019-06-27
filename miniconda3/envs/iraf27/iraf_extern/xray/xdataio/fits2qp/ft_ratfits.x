# $Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_ratfits.x,v 11.0 1997/11/06 16:34:45 prosb Exp $
# $Log: ft_ratfits.x,v $
# Revision 11.0  1997/11/06 16:34:45  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:59:32  prosb
# General Release 2.4
#
#Revision 8.2  1994/09/16  16:39:09  dvs
#Modified code to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.1  94/06/30  16:53:37  mo
#MC	6/30/94		Update to recognise BINTABLE/WCS with TCD matrix
#
#Revision 8.0  94/06/27  15:21:18  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:09:51  mo
#MC	2/25/94		Remove memory allocation from here and remove
#			initializations as well
#
#Revision 7.0  93/12/27  18:40:48  prosb
#General Release 2.3
#
#Revision 1.2  93/12/14  18:19:54  mo
#MC	12/13/93		Add support to calculate TALEN from TLMIN/MAX
#
#Revision 1.1  93/12/08  13:27:56  mo
#Initial revision
#
include "fits2qp.h"
include	"cards.h"
include	"ftwcs.h"


procedure alloc_wcs_ratfits(ptr, tfields)

pointer ptr
int     tfields
int     idx

begin

        call calloc(ptr, tfields*SZ_WCS_STRUCT, TY_STRUCT)
        do idx = 1, tfields
        {
           call calloc(TFORM(ptr, idx), SZ_CARDVSTR, TY_CHAR)
           call calloc(TTYPE(ptr, idx), SZ_CARDVSTR, TY_CHAR)
           call calloc(TUNIT(ptr, idx), SZ_CARDVSTR, TY_CHAR)
           call calloc(TCTYP(ptr, idx), SZ_CARDVSTR, TY_CHAR)
        }

	TNAXES(ptr) = tfields
        call calloc(TCDPT(ptr), tfields*tfields, TY_DOUBLE)

end

procedure assign_wcs_ratfits(wcs, wcs_rat, tfields, key_x, key_y,
				axlen1, axlen2, naxlen, display) 

pointer wcs			# i/o: IMAGE wcs structure
pointer wcs_rat			# i  : QPOE/RATFITS wcs structure
int     tfields			# i  : number of dimensions for wcs_rat
char    key_x[SZ_LINE] 		# i: index x key
char    key_y[SZ_LINE] 		# i: index y key
int	axlen1, axlen2		# o  : axis length for x,y
int	naxlen			# i  : number of axes (x,y) found
int	display			# i  : display level

char 	temp[SZ_CARDVSTR]
int	idx
int	xin,yin			# indices found for x and y values
int	len

int	strlen()
bool	streq()

begin
	do idx = 1, tfields
        {

	   #----------------------------------------
	   # Check for TTYPE being x or y index key
	   #----------------------------------------
	   len = strlen(Memc[TTYPE(wcs_rat, idx)])
	   call strclr(temp)
	   call strcpy(Memc[TTYPE(wcs_rat, idx)], temp, len)
	   call strlwr(temp)
	   call strip_whitespace(temp)

	   if (streq(temp,key_x))
	   {
	          call strcpy(Memc[TCTYP(wcs_rat, idx)],
		      Memc[IW_CTYPE(wcs, 1)], SZ_CARDVSTR)
                  IW_CDELT(wcs, 1) = TCDLT(wcs_rat, idx)
                  IW_CRVAL(wcs, 1) = TCRVL(wcs_rat, idx)
		  IW_CRPIX(wcs, 1) = TCRPX(wcs_rat, idx)
		  IW_CROTA(wcs) = TCROT(wcs_rat, idx)
		  if( TALEN(wcs_rat,idx) == 0 )
			TALEN(wcs_rat,idx) = TLMAX(wcs_rat,idx) 
		  axlen1 	   = TALEN(wcs_rat, idx)
		  xin = idx
	   }

	   if (streq(temp,key_y))
           {
                  call strcpy(Memc[TCTYP(wcs_rat, idx)],
                              Memc[IW_CTYPE(wcs, 2)], SZ_CARDVSTR)
                  IW_CDELT(wcs, 2) = TCDLT(wcs_rat, idx)
                  IW_CRVAL(wcs, 2) = TCRVL(wcs_rat, idx)
                  IW_CRPIX(wcs, 2) = TCRPX(wcs_rat, idx)
                  IW_CROTA(wcs)    = TCROT(wcs_rat, idx)
		  if( TALEN(wcs_rat,idx) == 0 )
			TALEN(wcs_rat,idx) = TLMAX(wcs_rat,idx) 
	          axlen2           = TALEN(wcs_rat, idx)
		  yin = idx
           }
	} # end loop

	if( IW_ISCD(wcs) == YES)
	{
	     IW_CD(wcs,1,1) = TCDM(wcs_rat,xin,xin)
	     IW_CD(wcs,1,2) = TCDM(wcs_rat,xin,yin)
	     IW_CD(wcs,2,1) = TCDM(wcs_rat,yin,xin)
	     IW_CD(wcs,2,2) = TCDM(wcs_rat,yin,yin)
	}
	IW_NDIM(wcs) = naxlen
	if( display > 4)
	{
	    call print_wcs_ratfits(wcs_rat,tfields)
	    call pr_cdwcs_ratfits(wcs_rat,xin,yin)
	}
end

procedure pr_cdwcs_ratfits(ptr, xf, yf)

pointer ptr
int     xf,yf

begin
           call printf("\n**************************************************\n")
           call printf("TCD[%2d,%2d]: %.16f\n")
		call pargi(xf)
		call pargi(xf)
		call pargd(TCDM[ptr,xf,xf])
           call printf("TCD[%2d,%2d]: %.16f\n")
		call pargi(xf)
		call pargi(yf)
		call pargd(TCDM[ptr,xf,yf])
           call printf("TCD[%2d,%2d]: %.16f\n")
		call pargi(yf)
		call pargi(xf)
		call pargd(TCDM[ptr,yf,xf])
           call printf("TCD[%2d,%2d]: %.16f\n")
		call pargi(yf)
		call pargi(yf)
		call pargd(TCDM[ptr,yf,yf])
end

procedure print_wcs_ratfits(ptr, tfields)

pointer ptr
int     tfields
int     idx

begin
        do idx = 1, tfields
        {
           call printf("\n**************************************************\n")
           call printf("idx: *%d*\nTCRPX: *%16.16f*\nTCRVL: *%16.16f*\nTCDLT: *%16.16f*\nTCROT: *%16.16f*\nTALEN: *%d*\nTFORM: *%s*\nTTYPE: *%s*\nTUNIT: *%s*\nTCTYP: *%s*\n")
           call pargi(idx)
           call pargd(TCRPX(ptr, idx))
           call pargd(TCRVL(ptr, idx))
           call pargd(TCDLT(ptr, idx))
           call pargd(TCROT(ptr, idx))
           call pargi(TALEN(ptr, idx))
           call pargstr(Memc[(TFORM(ptr, idx))])
           call pargstr(Memc[(TTYPE(ptr, idx))])
           call pargstr(Memc[(TUNIT(ptr, idx))])
           call pargstr(Memc[(TCTYP(ptr, idx))])

           call flush(STDOUT)
        }

end

procedure free_wcs_ratfits(ptr, tfields)

pointer ptr
int     tfields
int     idx

begin

        do idx = 1, tfields
        {
           call mfree(TFORM(ptr, idx), TY_CHAR)
           call mfree(TTYPE(ptr, idx), TY_CHAR)
           call mfree(TUNIT(ptr, idx), TY_CHAR)
           call mfree(TCTYP(ptr, idx), TY_CHAR)
        }

	call mfree(TCDPT(ptr), TY_DOUBLE)
        call mfree(ptr, TY_STRUCT)

end
