#$Header: /home/pros/xray/xproto/qpcalc/RCS/evvar.x,v 11.0 1997/11/06 16:38:54 prosb Exp $
#$Log: evvar.x,v $
#Revision 11.0  1997/11/06 16:38:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:26:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:25:56  prosb
#General Release 2.3.1
#
#Revision 7.1  94/03/25  12:36:04  mo
#MC		3/25/94		Fix move of mismatched data types
#				Add routine for fetching GTIs
#

include	<iraf.h>
include	<mach.h>
#
#  QPEVVAR -- Retrieve a table column given its name
#

procedure qpevvar(stack,colname)
pointer	stack
char	colname[ARB]
include	"qpcalc.com"	# (nevc,evc,evlen,nullval)
pointer	buffer
int	i
int	coltype
int	offset
int	ttype
int	qpc_lookup()
pointer	stk_alloc()
begin
        if( qpc_lookup(colname,coltype, offset) == NO )
	    call error(1,"QPEVVAR - can't find requested column (qpc_lookup)")

	if( coltype == TY_SHORT)
	    ttype = TY_INT
	else if( coltype == TY_REAL )
	    ttype = TY_DOUBLE
	else
	    ttype = coltype

        buffer = stk_alloc (stack, nevc, ttype)

        # Copy the table column into the buffer
        # Substitute the user supplied vales for nulls

	nullval = nullval
	do i=1,nevc
	{
	    switch(coltype)
	    {
	    case TY_SHORT:
                Memi[buffer+i-1] = Mems[evc+(i-1)*evlen+offset]
	    case TY_INT:
	        Memi[buffer+i-1] = Memi[(evc+(i-1)*evlen+offset-1)/SZ_INT+1]
	    case TY_LONG:
	        Meml[buffer+i-1] = Meml[(evc+(i-1)*evlen+offset-1)/SZ_LONG+1]
	    case TY_REAL:
	        Memd[buffer+i-1] = Memr[(evc+(i-1)*evlen+offset-1)/SZ_REAL+1]
	    case TY_DOUBLE:
	        Memd[buffer+i-1] = Memd[(evc+(i-1)*evlen+offset-1)/SZ_DOUBLE+1]
	    default:
		call error(1,"Invalid data type in QPCALC")
	    }
	}
end

#
#  FLTEVVAR -- Retrieve a table column given its name
#

procedure fltevvar(stack,colname)
pointer	stack
char	colname[ARB]
include	"qpcalc.com"	# (nevc,evc,evlen,nullval)
pointer	buffer
int	i
int	ttype
pointer	stk_alloc()
begin
	ttype = TY_DOUBLE
        buffer = stk_alloc (stack, nevc, ttype)

        # Copy the table column into the buffer
        # Substitute the user supplied vales for nulls

	nullval = nullval
	do i=1,nevc
	{
	        Memd[buffer+i-1] = Memd[(evc+i-1)]
	}
end
