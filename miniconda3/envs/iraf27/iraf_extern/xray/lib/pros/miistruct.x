#$Header: /home/pros/xray/lib/pros/RCS/miistruct.x,v 11.0 1997/11/06 16:20:37 prosb Exp $
#$Log: miistruct.x,v $
#Revision 11.0  1997/11/06 16:20:37  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:53  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  15:54:22  dvs
#Removed miiustruct, miiauxstruct, miiauxustruct (obsoleted).
#Modified miistruct to add correct padding at end of record.
#
#Revision 8.0  94/06/27  13:46:28  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/14  09:45:45  mo
#MC	4/14/94		Added code to handle unaligned data entries
#			in aux records (ASCA/SIS/HOT_PIXELS)
#
#Revision 7.0  93/12/27  18:09:48  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:37:17  mo
#MC		12/1/93		Update for alignment maitenance and can't
#				do in-place.  Also add 'bool' support
#
#Revision 6.0  93/05/24  15:44:59  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:56  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:48:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:00:49  wendy
#General
#
#Revision 2.0  91/03/07  00:07:07  pros
#General Release 1.0
#
#
#  MIISTRUCT -- pack a struct into mii format 
#
include <mach.h>
include <mii.h>
include <iraf.h>

procedure miistruct(ibuf, obuf, nrecs, struct)

char	ibuf[ARB]               # i: array of structs
char	obuf[ARB]               # o: array of structs
int     nrecs                   # i: number of records
char	struct[ARB]		# i: structure definition

short	temp[4]			# l: temp to hold up to 8 bytes
short	temp2[4]		# l: temp to hold up to 8 bytes
int	i, j			# l: loop counters
int	cur			# l: current offset in ibuf - in bytes
int	ocur			# l: current offset in obuf - in SPP chars
int	maxtypelen		# l: max. length of type in record.

begin

	maxtypelen = SZ_INT   # (see sz_typedef())
	cur = 1
	ocur = 1
	# for each record in the array of records
	do i=1, nrecs{
	    j = 1
	    # convert each element of the struct descriptor
	    while( struct[j] != EOS ){
		switch(struct[j]){
		case '{' , '}' , ',' , ' ':
		    ;
		case ':':
		    j = j + 1

		case 's':
		    call bytmov (ibuf, cur, temp, 1, SZ_SHORT*SZB_CHAR)
		    call miipak16(temp, obuf[ocur], 1, TY_SHORT)

		    cur = cur + SZ_SHORT*SZB_CHAR
		    ocur = ocur + SZ_SHORT
	  	    maxtypelen=max(maxtypelen,SZ_SHORT)
		case 'i':
		    while( ((cur-1) / (SZ_INT*SZB_CHAR)) * SZ_INT*SZB_CHAR
					 != (cur-1) )
			    cur = cur + SZB_CHAR			

		    call bytmov (ibuf, cur, temp, 1, SZ_INT*SZB_CHAR)
		    call miipak32(temp, temp2, 1, TY_INT)
		    call bytmov(temp2, 1, obuf[ocur], 1, TY_INT)
		
		    cur = cur + SZ_INT * SZB_CHAR
		    ocur = ocur + SZ_INT
	  	    maxtypelen=max(maxtypelen,SZ_INT)
		case 'l':
		    while( ((cur-1) / (SZ_LONG*SZB_CHAR)) * 
					SZ_LONG*SZB_CHAR != (cur-1) )
			    cur = cur + SZB_CHAR			

		    call bytmov (ibuf, cur, temp, 1, SZ_LONG*SZB_CHAR)
		    call miipak32(temp, temp2, 1, TY_LONG)
		    call bytmov(temp2, 1, obuf[ocur], 1, TY_LONG)

		    cur = cur + SZ_LONG * SZB_CHAR
		    ocur = ocur + SZ_LONG
	  	    maxtypelen=max(maxtypelen,SZ_LONG)
		case 'r':
		    while( ((cur-1) / (SZ_REAL*SZB_CHAR)) * 
					SZ_REAL*SZB_CHAR != (cur-1) )
			    cur = cur + SZB_CHAR			

	 	    call bytmov (ibuf, cur, temp, 1, SZ_REAL*SZB_CHAR)
		    call miipakr(temp, obuf[ocur], 1, TY_REAL)

		    cur = cur + SZ_REAL * SZB_CHAR
		    ocur = ocur + SZ_REAL
	  	    maxtypelen=max(maxtypelen,SZ_REAL)
		case 'd':
		    while( ((cur-1) / (SZ_DOUBLE*SZB_CHAR)) * 
				    SZ_DOUBLE*SZB_CHAR != (cur-1) )
			    cur = cur + SZB_CHAR			

		    call bytmov (ibuf, cur, temp, 1, SZ_DOUBLE*SZB_CHAR)
		    call miipakd(temp, obuf[ocur], 1, TY_DOUBLE)

		    cur = cur + SZ_DOUBLE*SZB_CHAR
		    ocur = ocur + SZ_DOUBLE

	  	    maxtypelen=max(maxtypelen,SZ_DOUBLE)
		case 'x':
		    while( ((cur-1) / (SZ_REAL*SZB_CHAR)) * 
					SZ_REAL*SZB_CHAR != (cur-1) )
			    cur = cur + SZB_CHAR			

		    call bytmov (ibuf, cur, temp, 1, SZ_REAL*SZB_CHAR)
		    call miipakr(temp, obuf[ocur], 1, TY_REAL)

		    cur = cur + SZ_REAL * SZB_CHAR
		    ocur = ocur + SZ_REAL

		    call bytmov (ibuf, cur, temp, 1, SZ_REAL*SZB_CHAR)
		    call miipakr(temp, obuf[ocur], 1, TY_REAL)

		    cur = cur + SZ_REAL * SZB_CHAR
		    ocur = ocur + SZ_REAL

	  	    maxtypelen=max(maxtypelen,SZ_REAL)

		default:
		    call errstr(1, "miistruct - illegal character in eventdef",
				    struct)
	 	}
		j = j + 1


	    }
	    # move to next record.
	    while( ((cur-1) / maxtypelen) * maxtypelen != (cur-1) )
		    cur = cur + SZB_CHAR			
	}
end


