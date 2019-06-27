#$Header: /home/pros/xray/xdataio/datarep/RCS/datarun.x,v 11.0 1997/11/06 16:33:56 prosb Exp $
#$Log: datarun.x,v $
#Revision 11.0  1997/11/06 16:33:56  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:39  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:48  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:26  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:56  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:35:55  pros
#General Release 1.0
#
# datarun.x
#
# run the compiled datarep file
#

include	"datarep.h"


define BufferSize	8096

procedure datarun(code, in, ot)

pointer	code
int	in
int	ot
#--

pointer	ibase
pointer	obase
pointer	rwbuf

int	iindex
int	oindex
int	left
int	need
int	dump

include "datarun.com"
pointer	sp

pointer	psh()
int	red, read()

define	done	91

begin
	call smark(sp)
	call salloc(ibase, ( BufferSize + maxrep ) / 2, TY_SHORT)
	call salloc(obase, ( BufferSize + maxrep ) / 2, TY_SHORT)
	call salloc(rwbuf , ( BufferSize + maxrep ) / 2, TY_SHORT)

	rp = psh(0, 1)
	ip = psh(0, code)
	iindex = 1
	oindex = 1
	red    = 0

	while ( TRUE ) {
	    if ( Memi[ST_VALUE(ip)] != 0 ) {	# if there are instructions
		instruction = ST_VALUE(ip)	# go on to the next one
		ST_VALUE(ip) = ST_VALUE(ip) + 1
	    }
	    ST_VALUE(rp) = 1

	    for ( ; ST_VALUE(rp) > 0; ST_VALUE(rp) = ST_VALUE(rp) - 1 ) {

		if ( iindex - 1 + maxrep > red ) {
			left = red - (iindex - 1)
			need = (( BufferSize - left ) / 2 ) * 2

			red = read(in,  Mems[rwbuf], need /2)
			call bytmov(Mems[ibase], iindex, Mems[ibase], 1, left)
			call bytmov(Mems[rwbuf], 1,
				    Mems[ibase], left + 1, red * 2)
			
			if ( red <= 0 ) red = left
			else		red = red * 2 + left

			if ( red <= 0 )
				goto done

			iindex = 1
		}
		if ( (oindex - 1) + maxrep > BufferSize ) {
			dump = (( oindex - 1 ) / 2 ) * 2
			left =  ( oindex - 1 ) - dump

			call bytmov(Mems[obase], 1, Mems[rwbuf], 1, dump)
			call bytmov(Mems[obase], dump + 1 ,
				    Mems[obase],	1 , left)
			
			call write(ot, Mems[rwbuf], dump /2)
			oindex = 1 + left
		}

		call zcall4(Memi[instruction],	Mems[ibase], iindex,
						Mems[obase], oindex)
	    }
	}

  done
	dump = (( oindex - 1 ) / 2 ) * 2
	left =  ( oindex - 1 ) - dump

	call bytmov(Mems[obase], 1, Mems[rwbuf], 1, dump)
	call write(ot, Mems[rwbuf], dump /2)

	if ( left > 0 ) {
		call bytmov(Mems[obase], dump + 1, Mems[rwbuf], 1, left)
		call write(ot, Mems[rwbuf], (left + 1) /2)
	}
		
	call sfree(sp)
end



# The Jump opcodes 
#
procedure jumpinto(b1, i1, b2, i2)

int	b1, i1, b2, i2
#--

int	text
include "datarun.com"
pointer	psh()

begin
	text = Memi[instruction + 1]
	ST_VALUE(ip) = instruction + 2
	ip = psh(ip, text)
	rp = psh(rp, 1)
	instruction = ST_VALUE(ip)
end


procedure jumpret(b1, i1, b2, i2)

int	b1, i1, b2, i2
#--
include "datarun.com"
pointer	pop()

begin
	rp = pop(rp)
	ip = pop(ip)
	instruction = ST_VALUE(ip) - 2
end


procedure rreeppeeaatt(b1, i1, b2, i2)

int	b1, i1, b2, i2
#--
include "datarun.com"

begin
	ST_VALUE(rp) = I_REPT(ST_VALUE(ip)) + 1
	instruction = ST_VALUE(ip) + 1
	ST_VALUE(ip) = ST_VALUE(ip) + 2
end





# Psh and Pop
#
# all the datarep stacks are linked lists of 1 value
#

pointer procedure psh(stack, value)

pointer	stack
int	value
#--

pointer	newnode

begin
	call malloc(newnode, 2, TY_STRUCT)
	ST_NEXT(newnode) = stack
	ST_VALUE(newnode) = value

	return newnode
end

pointer procedure pop(stack)

pointer	stack
#--

pointer	top

begin
	if ( stack == NULL ) return NULL

	top = ST_NEXT(stack)

	call mfree(stack, TY_STRUCT)

	return top
end



procedure setmaxrep(n)

int	n
#--

include "datarun.com"

begin
	maxrep = n
end


