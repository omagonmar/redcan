#$Header: /home/pros/xray/xspatial/improj/RCS/debug.x,v 11.0 1997/11/06 16:30:15 prosb Exp $
#$Log: debug.x,v $
#Revision 11.0  1997/11/06 16:30:15  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:01  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:13  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:11:41  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:16  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:36:28  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:34  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:18:52  pros
#General Release 1.0
#
int procedure dps ( arr, n )
pointer	arr
int	n
int	i
begin
	do i = 1, n {
	    call printf("%d: %d,")
		call pargi (i-1)
		call pargs (Mems[arr+i-1])
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

int procedure dpi ( arr, n )
pointer	arr
int	n
int	i
begin
	do i = 1, n {
	    call printf("%d: %d,")
		call pargi (i-1)
		call pargi (Memi[arr+i-1])
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

int procedure dpr ( arr, n )
pointer	arr
int	n
int	i
begin
	do i = 1, n {
	    call printf("%d: %f,")
		call pargi (i-1)
		call pargr (Memr[arr+i-1])
	    call flush (STDOUT)
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

int procedure dpd ( arr, n )
pointer	arr
int	n
int	i
begin
	do i = 1, n {
	    call printf("%d: %f,")
		call pargi (i-1)
		call pargd (Memd[arr+i-1])
	    call flush (STDOUT)
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

int procedure dpc ( arr )
pointer arr
begin
	call printf("%s\n")
	    call pargstr (Memc[arr])
	call flush (STDOUT)
	return (1)
end

int procedure das ( arr, n )
short arr[ARB]
int n
int	i
begin
	do i = 1, n {
	    call printf("%d: %d,")
		call pargi (i)
		call pargs (arr[i])
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

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

int procedure dad ( arr, n )
double arr[ARB]
int n
int	i
begin
	do i = 1, n {
	    call printf("%d: %f,")
		call pargi (i)
		call pargd (arr[i])
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

