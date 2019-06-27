#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcisqpoe.x,v 11.0 1997/11/06 16:21:59 prosb Exp $
#$Log: qpcisqpoe.x,v $
#Revision 11.0  1997/11/06 16:21:59  prosb
#General Release 2.5
#
#Revision 9.1  1997/03/27 17:45:34  prosb
#*** empty log message ***
#
#
# MO/JCC (10/8/96) - replaced with the one in qpappend/qpc_subs.x
#
#Revision 9.0  1995/11/16  18:29:30  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:05  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:20  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:20:48  mo
#MC	no changes
#
#Revision 5.0  92/10/29  21:18:47  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:16  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:18  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:03  pros
#General Release 1.0
#
include "qpcreate.h" 

#
#	QPC_ISQPOE - determine if a file is a qpoe file
#
int procedure qpc_isqpoe(fname)

char    fname[ARB]                      # i: file name
int     got                             # l: got a qpoe file?
int     len                             # l: length of file name
int     index                           # l: index for "["
pointer temp                            # l: temp file name
pointer sp                              # l: stack pointer
int     qp_access()                     # l: test for qpoe existence
int     strlen()                        # l: length of string
int     stridx()                        # l: index into string

begin
        # mark the stack
        call smark(sp)
        call strip_whitespace(fname)
        if( fname[1] != '@' )
        {
          # get length of string
          len = strlen(fname)
          # make a copy
          call salloc(temp, len+1, TY_CHAR)
          call strcpy(fname, Memc[temp], len)
          # look for a "["
          index = stridx("[", Memc[temp])
          # cut out any filter
          if( index !=0 )
            Memc[temp+index-1] = EOS
          # now look for a qpoe file
          got = qp_access(Memc[temp], 0)
          # release stack space
          call sfree(sp)
          # and return the news
        }
        else
          got = YES
        return(got)
end
