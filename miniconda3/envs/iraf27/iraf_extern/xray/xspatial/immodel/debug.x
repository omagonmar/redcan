#$Header: /home/pros/xray/xspatial/immodel/RCS/debug.x,v 11.0 1997/11/06 16:30:20 prosb Exp $
#$Log: debug.x,v $
#Revision 11.0  1997/11/06 16:30:20  prosb
#General Release 2.5
#
#Revision 2.0  1991/03/06 23:15:38  pros
#General Release 1.0
#
# ifdef DEBUG

# dps,dpl,dpr
#
# routines that can be accessed from the debugger, e.g. "print dpl(scan)"
# to display entire scan link-list, region overlap check table, region list


include	<error.h>
include <xwhen.h>

int procedure dai ( arr, n )
int arr[ARB]
int n
int	i
begin
	do i = 1, n {
	    call printf("%d: %d,")
		call pargi (i)
		call pargi (arr[i])
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

int procedure dar ( arr, n )
real arr[ARB]
int n
int	i
begin
	do i = 1, n {
	    call printf("%d: %f,")
		call pargi (i)
		call pargr (arr[i])
	    call flush (STDOUT)
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

int procedure dac ( arr )
char arr[ARB]
begin
	call printf("%s\n")
	    call pargstr (arr)
	call flush (STDOUT)
	return (1)
end

int procedure dcr ( ptr, strt, n )
pointer ptr
int strt, n
int	i, j
begin
	j = 0
	do i = 0, n-1 {
	    call printf("%d: %f,")
	     call pargi (strt + i)
	     call pargr (Memr[ptr+strt+i])
	    j = j + 1
	    if(j > 10) {
		call printf("\n")
		j = 1
	    }
	    call flush (STDOUT)
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

int procedure dcrn ( ptr, width, line, strt, n )
pointer ptr
int width, line
int strt, n
int	i, j, offset
begin
	offset = line * width
	call printf("line %d (offset: %d)\n")
	 call pargi(line)
	 call pargi(offset)
	j = 0
	do i = 0, n-1 {
	    call printf("%d: %f,")
	     call pargi (strt + i)
	     call pargr (Memr[ptr+offset+strt+i])
	    j = j + 1
	    if(j > 10) {
		call printf("\n")
		j = 1
	    }
	    call flush (STDOUT)
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end
