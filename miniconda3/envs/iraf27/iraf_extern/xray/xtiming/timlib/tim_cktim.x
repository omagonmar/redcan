#$Header: /home/pros/xray/xtiming/timlib/RCS/tim_cktim.x,v 11.0 1997/11/06 16:45:08 prosb Exp $
#$Log: tim_cktim.x,v $
#Revision 11.0  1997/11/06 16:45:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:05  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:38  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:11  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:59:24  prosb
#General Release 2.2
#
#Revision 1.1  93/05/20  08:43:38  mo
#Initial revision
#
#------------------------------------------------------------------
#
# Function:     tim_cktime
# Purpose:      Verify that the current QPOE file has time entries defined as
#               double precision in the events and that is has an XS-SORT
#		'time' entry
# Uses:         /pros library
# Pre-cond:     A file handle to the active main QPOE file
# Post-cond:    Either a fatal error abort OR
#                  the offset of the time attribute that it found
#
# -------------------------------------------------------------------------
 
include <qpioset.h>
include <bary.h>

procedure tim_cktime(qp,qptype,offset)
pointer qp              # i: qpoe file handle
pointer qptype          # i: input file type (source/bkgd)
int     offset          # o: offset of "time" photon attribute
int     type            # l: variable data type
pointer sp              # l: stack pointer
#pointer io
int     ev_lookup()             # lookup type and offset of named parameter
#int     qpio_open()
#int     noindex
#int     qpio_stati()
bool	timsort
bool	qp_time_sorted()
pointer sbuf
 
begin
        call smark(sp)
        call salloc( sbuf, SZ_LINE, TY_CHAR)
# Make sure time is in the src event struct (and save offset of event element)
        if( ev_lookup(qp, "time", type, offset) == NO ){
            call sprintf(sbuf,SZ_LINE,"%s event structure (qp) must have 'time' defined\n")
                call pargstr(char[qptype])
            call error(1, sbuf)
        }
        else
            if( type != TY_DOUBLE ){
                call sprintf(sbuf,SZ_LINE,"%s 'time' must be TY_DOUBLE\n")
                    call pargstr(char[qptype])
                call error(1, sbuf)
            }
	timsort = qp_time_sorted(qp)
#        io = qpio_open(qp,"",READ_ONLY)
#        noindex = qpio_stati(io,QPIO_NOINDEX)
#        if( noindex != YES)
        if( !timsort )
            call error(1, "QPOE file must be sorted by TIME (XS-SORT)")
#        {
#            call sprintf(sbuf,SZ_LINE,"%s QPOE file must be sorted by TIME\n")
#                call pargstr(char[qptype])
#            call eprintf(sbuf)
#        }
#        call qpio_close(io)
        call sfree(sp)
end

bool procedure qp_time_sorted(qp)
pointer qp
int     qp_gstr()               # l: QPOE get string function
pointer buf                     # l: pointer to input line
pointer sp                      # l: stack pointer
bool    ret                     # o: return value 
int     strncmp()               # l: string n compare function

begin
        call smark(sp)
        call salloc(buf, SZ_LINE, TY_CHAR)

        ret = false

        if (qp_gstr(qp, QP_SORT_PARAM, Memc[buf], SZ_LINE) <= 0)
        {       
           call eprintf("Parameter %s not found in QPOE file.\n")
           call pargstr(QP_SORT_PARAM)
           call flush(STDERR)
        }
        else
        {
           call strupr(Memc[buf])
           if (strncmp(Memc[buf], "TIME", 4) == 0)
              ret = true
        }

        call sfree(sp)
        return ret 
end


