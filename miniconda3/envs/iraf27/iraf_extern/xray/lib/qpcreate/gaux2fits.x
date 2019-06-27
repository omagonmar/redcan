#$Header: /home/pros/xray/lib/qpcreate/RCS/gaux2fits.x,v 11.0 1997/11/06 16:21:30 prosb Exp $
#$Log: gaux2fits.x,v $
#Revision 11.0  1997/11/06 16:21:30  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:04  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:32:42  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:51  prosb
#General Release 2.3
#
include <mach.h>
include <rosat.h>
include <qpoe.h>
include <qpc.h>
include <einstein.h>

# number of tsi records in a buffer increment
define BUFINC	1000

procedure gaux2fits()
pointer	sp
pointer	temp
pointer	auxdef
pointer	auxrec
pointer number
pointer	auxstr

begin
        call smark(sp)
        call salloc(number,SZ_LINE,TY_CHAR)
        call salloc(temp,SZ_LINE,TY_CHAR)
        call salloc(auxdef,SZ_LINE,TY_CHAR)
        call salloc(auxrec,SZ_LINE,TY_CHAR)
        call calloc(auxstr,SZ_EXPR,TY_CHAR)

        call strcpy("N",Memc[number],SZ_LINE)
        call strcat(auxname,Memc[number],SZ_LINE)
        call strcpy(auxname,Memc[auxstr],SZ_LINE)
        call strcpy("REC",Memc[temp],SZ_LINE)
        call strcat(Memc[temp],Memc[auxstr],SZ_LINE)
# Save this guy for later
        call strcpy(Memc[auxstr],Memc[auxrec],SZ_LINE)
        call strcpy("XS-",Memc[auxdef],SZ_EXPR)
        call strcat(Memc[auxstr],Memc[auxdef],SZ_EXPR)
        # return 0 if no records
        if( qp_accessf(qp, Memc[number]) == NO )
            nrecs = 0
        else
        # get number of aux records
            nrecs = qp_geti(qp, Memc[number])
        if( nrecs == 0)
            return
                
        call qp_gstr(qp,Memc[auxdef],Memc[auxstr],SZ_EXPR)
        #---------------------------------------------------
        #  Determine length of records by parsing descriptor
        call smark(sp)
        #---------------------------------------------------
        call strlwr(Memc[auxstr])

        #-------------------------
        # Check/expand the aliases
        #-------------------------
        call ev_alias(Memc[auxstr], Memc[auxstr], SZ_EXPR)



procedure auxtab(aux_root,prosdef,qpaux,nbytes,nrecs,nelem)
char	aux_root[ARB]		# i: root name for QPOE extension
char	prosdef[ARB]		# i: PROS/QPOE string
pointer	qpaux			# i: pointer to aux records
int	nbytes			# i: number of bytes/record
int	nrecs			# i: number of records
int	nelem			# i: number of elements in record
int	j			# l: index in definition

begin
        call a3d_table_header(qp, aux_root, bytes, ntsi, nelem, 1)
	j=1
	while( prosdef[j] != EOS )
	    switch(prosdef[j])
	    case: '{`
		;
	    case: '}'
		;
	    case: ','
		;
	    case: ':'
            call a3d_table_entry(qp, "1D", "TSTART", "seconds")
            call a3d_table_entry(qp, "1J", "FAILED", "bit-encoded" )
            call a3d_table_entry(qp, "1J", "LOGICALS", "bit-encoded" )
            call a3d_table_entry(qp, "1J", "RMB", "levels" )
            call a3d_table_entry(qp, "1J", "DFB", "levels" )
            call a3d_table_end(qp)
            call miistruct(Memi[qptsi], Memi[qptsi], ntsi, RPTSIREC )
            call a3d_write_data(qp, Memi[qptsi], ntsi*bytes/SZB_CHAR)

