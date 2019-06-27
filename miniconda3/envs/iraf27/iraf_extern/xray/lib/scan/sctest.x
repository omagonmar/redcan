#$Header: /home/pros/xray/lib/scan/RCS/sctest.x,v 11.0 1997/11/06 16:23:48 prosb Exp $
#$Log: sctest.x,v $
#Revision 11.0  1997/11/06 16:23:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:59  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:19  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:16  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:46  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:14  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:10:05  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:36  pros
#General Release 1.0
#
# Package task statement for the MODEL package.

task	add		= sc_atest,
	merge		= sc_mtest,
	paint		= sc_ptest

include <scset.h>

procedure sc_mtest ()

pointer line

int	start_x
int	stop_x
int	val

pointer	sc_buildline()
int	clgeti()

begin
	line = sc_buildline()
	start_x = clgeti("start")
	stop_x = clgeti("stop")
	val = clgeti("val")
	call sc_merge (line, start_x, stop_x, val)
	call sc_list (line)
end

procedure sc_ptest ()

pointer line

int	start_x
int	stop_x
int	val

pointer	sc_buildline()
int	clgeti()

begin
	line = sc_buildline()
	start_x = clgeti("start")
	stop_x = clgeti("stop")
	val = clgeti("val")
	call sc_paint (line, start_x, stop_x, val)
	call sc_list (line)
end


procedure sc_atest ()

pointer line

int	start_x
int	stop_x
int	val

pointer	sc_buildline()
int	clgeti()

begin
	line = sc_buildline()
	start_x = clgeti("start")
	stop_x = clgeti("stop")
	val = clgeti("val")
	call sc_add (line, start_x, stop_x, val)
	call sc_list (line)
end


pointer procedure sc_buildline ()

pointer line
int	start_x
int	stop_x
int	val

int	clgeti()
pointer	sc_newedge()

begin
	call printf ("Make base line back to front until start=0\n")
	line = SCNULL
	repeat {
	    start_x = clgeti("start")
	    if( start_x > 0 ) {
		stop_x = clgeti("stop")
		val = clgeti("val")
		line = sc_newedge(stop_x, val, SCSTOP, line)
		line = sc_newedge(start_x, val, SCSTART, line)
	    } else if( start_x == -1 ) {
		line = sc_newedge(20, 10, SCSTOP, line)
		line = sc_newedge(10, 10, SCSTART, line)
	    } else if( start_x == -2 ) {
		line = sc_newedge(40, 10, SCSTOP, line)
		line = sc_newedge(30, 10, SCSTART, line)
		line = sc_newedge(20, 10, SCSTOP, line)
		line = sc_newedge(10, 10, SCSTART, line)
	    } else if( start_x == -3 ) {
		line = sc_newedge(60, 10, SCSTOP, line)
		line = sc_newedge(50, 10, SCSTART, line)
		line = sc_newedge(40, 10, SCSTOP, line)
		line = sc_newedge(30, 10, SCSTART, line)
		line = sc_newedge(20, 10, SCSTOP, line)
		line = sc_newedge(10, 10, SCSTART, line)
	    }
	} until( start_x <= 0 )
	call printf("\n")
	call sc_list (line)
	call sc_check(line,1000,1,1)
	call printf("\n")
	return( line )
end
