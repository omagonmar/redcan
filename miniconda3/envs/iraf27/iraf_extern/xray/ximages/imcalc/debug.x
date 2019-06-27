#$Header: /home/pros/xray/ximages/imcalc/RCS/debug.x,v 11.0 1997/11/06 16:26:58 prosb Exp $
#$Log: debug.x,v $
#Revision 11.0  1997/11/06 16:26:58  prosb
#General Release 2.5
#
#Revision 2.0  1991/03/06 23:30:58  pros
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

