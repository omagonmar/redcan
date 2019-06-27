# $Header: /home/pros/xray/xproto/qpcalc/RCS/qpcalcsubs.x,v 11.0 1997/11/06 16:38:56 prosb Exp $
# $Log: qpcalcsubs.x,v $
# Revision 11.0  1997/11/06 16:38:56  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:39  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:26:11  prosb
#General Release 2.3.1
#
#Revision 1.2  94/03/30  11:18:45  mo
#MC	3/30/04		Fix buffer so that it gets correctly
#			reinitialized for each run
#
#Revision 1.1  94/03/25  12:34:57  mo
#Initial revision
#

include	<iraf.h>
include <qpoe.h>
include <qpc.h>
include <qpset.h>

DEFINE	SZ_EVDEF	12

procedure ev_adddef(name,stype,prosdef,type,offset,display)
char	name[ARB]	# i:  name of new event attribute
char    stype[ARB]	# i:  data-type for new attribute
char	prosdef[ARB]	# i/o: PROS event-defintion string
int	offset		# o: offset of new attribute
int	type		# o: datatype code for new attribyte
int	display		# i: display code

char	tbuf[SZ_EVDEF]	# l: local string buffer
int	len
int	nmacros
pointer	msymbols, mvalues
int	ev_lookuplist(),strlen()
	
begin
#		call strcpy("{",tbuf,SZ_EVDEF)
#                tbuf[1]='{'
#                tbuf[2]=EOS
		tbuf[1] = EOS
                stype[2]=EOS
                call strcpy(stype[1],tbuf,SZ_EVDEF)
                call strcat(":",tbuf,SZ_EVDEF)
                call strcat(name,tbuf,SZ_EVDEF)
                call strcat("}",tbuf,SZ_EVDEF)
                len = strlen(prosdef)
                prosdef[len] = ','
                call strcat(tbuf,prosdef,SZ_LINE)
                if( display > 1 ) 
                {
                    call printf("new eventdef: %s\n") 
                        call pargstr(prosdef)
                    call flush(STDOUT)
                }
                call ev_crelist(prosdef,msymbols,mvalues,nmacros)
                len = ev_lookuplist(name,
                                    msymbols,mvalues,nmacros,type, offset) 
                call ev_destroylist(msymbols, mvalues, nmacros)
end


procedure vex_evalflt(qp,evlist,qphead,display,pcode,blist,elist,ngti)
pointer	qp		# i: file handle to input QPOE
char	evlist[ARB]	# i: user qpoe filter string
pointer qphead		# i/o: qpoe header structure
int	display		# i: display level
pointer pcode		# i:  pointer to compiled equations
pointer blist		# o:  pointer to list of good start times
pointer	elist		# o:  pointer to list of good end times
int	ngti		# o:  number of intervals

int	exptype		# l
int	len
double	duration	# l: duration of good time intervals
pointer	sp		# l: stack pointer
pointer	filtstr		# l: pointer for filter string
pointer filtkey		# l: pointer for filter keyword

include	"qpcalc.com"    # l: common for vex_eval/evvar routines
			#  evc,offset
int	qp_accessf()
int	strlen()
extern	fltevvar
begin
#------------------------
# Get good time intervals
#------------------------
	call smark(sp)
	call salloc(filtkey,SZ_FNAME,TY_CHAR)
        call get_goodtimes(qp, evlist, display, blist, elist,  
                           ngti, duration)

#-----------------
# Correct the GTIs
#-----------------
	exptype = 0
	nullval = 0.0D0
	nevc = ngti
	evc = blist
	call vex_eval(pcode,fltevvar,nullval,exptype)
        call vex_copyd(pcode, INDEFD, Memd[blist], ngti)
	evc = elist
	call vex_eval(pcode,fltevvar,nullval,exptype)
        call vex_copyd(pcode, INDEFD, Memd[elist], ngti)

#----------------
# Update the GTIs
#----------------
        call gti_update(qp, qphead, blist, elist, ngti)
#	call qp_close(qp_out)

#------------------------------------------------------------------
# Check if the qpoe param "deffilt" exists in the OUTPUT qpoe, 
# if it does, delete it.  When "updeffilt" is called, the param
# will be recreated from the corrected gtis.  If this parameter 
# exists when updeffilt is called, the data in it will override the
# corrected gtis.  Apparently, "deffilt" is inherited from the
# input qpoe file.
#------------------------------------------------------------------
	if (qp_accessf(qp,"deffilt") == YES)
	{
	   call qp_deletef(qp, "deffilt")
	   call strcpy("deffilt",Memc[filtkey],SZ_FNAME)
	}
	else
	   call strcpy("XS-FHIST",Memc[filtkey],SZ_FNAME)

#-------------------------------------------------------------------
# Call "updeffilt" and then set the param "QPOE_NODEFFILT" so that
# "qpcreate" won't write over the changes to the filter and the GTIs
#-------------------------------------------------------------------
#	call updeffilt(qp_out, qp_out, empty_ptr, "deffilt", qphead)
        call put_gtifilt(blist,elist,ngti,filtstr)
        len=strlen(Memc[filtstr])
        if( qp_accessf(qp, Memc[filtkey]) == NO ){
#                    call qp_addf (qp, Memc[filtkey], "c", len+SZ_LINE,
#                                  "standard time filter", QPF_NONE)
             call qpx_addf (qp, Memc[filtkey], "c", len+SZ_LINE,
                           "standard time filter", QPF_INHERIT)
        }
        call qp_pstr(qp, Memc[filtkey], Memc[filtstr])

	call qp_seti(qp, QPOE_NODEFFILT, YES)

	call sfree(sp)
end
