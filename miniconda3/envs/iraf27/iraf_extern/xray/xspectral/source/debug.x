#$Header: /home/pros/xray/xspectral/source/RCS/debug.x,v 11.0 1997/11/06 16:41:56 prosb Exp $
#$Log: debug.x,v $
#Revision 11.0  1997/11/06 16:41:56  prosb
#General Release 2.5
#
#Revision 2.1  1991/04/15 17:42:05  john
#Add the ss routine to print out the stack level.
#
#Revision 2.0  91/03/06  23:02:11  pros
#General Release 1.0
#
int procedure dps ( arr, n )
pointer	arr
int	n
int	i
begin
	do i = 1, n {
	    call printf("%d: %d,")
		call pargi(i)
		call pargs(Mems[arr+i-1])
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
		call pargi(i)
		call pargi(Memi[arr+i-1])
	}
	call printf("\n")
	call flush (STDOUT)
	return (1)
end

int procedure dpr ( arr, n )
pointer	arr
int	n
int	i, j
begin
	j = 1
	do i = 1, n {
	    call printf("%d: %f,")
		call pargi(i)
		call pargr(Memr[arr+i-1])
	    call flush(STDOUT)
	    if( j >= 3 )
	    {
		call printf("\n")
		j = 1
	    }
	    else
		j = j + 1
	}
	call printf("\n")
	call flush(STDOUT)
	return (1)
end

int procedure dpd ( arr, n )
pointer	arr
int	n
int	i, j
begin
	j = 1
	do i = 1, n {
	    call printf("%d: %f,")
		call pargi(i)
		call pargd(Memd[arr+i-1])
	    if( j >= 3 )
	    {
		call printf("\n")
		j = 1
	    }
	    else
		j = j + 1
	    call flush(STDOUT)
	}
	call printf("\n")
	call flush(STDOUT)
	return (1)
end

int procedure dpc ( arr )
pointer arr
begin
	call printf("%s\n")
	    call pargstr(Memc[arr])
	call flush(STDOUT)
	return (1)
end

int procedure das ( arr, n )
short arr[ARB]
int n
int	i
begin
	do i = 1, n {
	    call printf("%d: %d,")
		call pargi(i)
		call pargs(arr[i])
	}
	call printf("\n")
	call flush(STDOUT)
	return (1)
end

int procedure dai ( arr, n )
int arr[ARB]
int n
int	i
begin
	do i = 1, n {
	    call printf("%d: %d,")
		call pargi(i)
		call pargi(arr[i])
	}
	call printf("\n")
	call flush(STDOUT)
	return (1)
end

int procedure dar ( arr, n )
real arr[ARB]
int n
int i, j
begin
	j = 1
	do i = 1, n {
	    call printf("%d: %f,")
		call pargi(i)
		call pargr(arr[i])
	    call flush(STDOUT)
	    if( j >= 3 )
	    {
		call printf("\n")
		j = 1
	    }
	    else
		j = j + 1
	}
	call printf("\n")
	call flush(STDOUT)
	return (1)
end

int procedure dad ( arr, n )
double arr[ARB]
int n
int i, j
begin
	j = 1
	do i = 1, n {
	    call printf("%d: %f,")
		call pargi(i)
		call pargd(arr[i])
	    call flush(STDOUT)
	    if( j >= 3 )
	    {
		call printf("\n")
		j = 1
	    }
	    else
		j = j + 1

	}
	call printf("\n")
	call flush(STDOUT)
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

# routines to sum values in an array

double procedure dbds ( arr, n )
double arr[ARB]
int n
double sum
int i
begin
	sum = 0.0d0
	do i = 1, n
	    sum = sum + arr[i]
	return( sum )
end

double procedure dbrs ( arr, n )
real arr[ARB]
int n
double sum
int i
begin
	sum = 0.0d0
	do i = 1, n
	    sum = sum + double(arr[i])
	return( sum )
end

double procedure pdds ( arr, n )
pointer arr
int n
double sum
int i
begin
	sum = 0.0d0
	do i = 1, n
	    sum = sum + Memd[arr+i-1]
	return( sum )
end

double procedure pdrs ( arr, n )
pointer arr
int n
double sum
int i
begin
	sum = 0.0d0
	do i = 1, n
	    sum = sum + double(Memr[arr+i-1])
	return( sum )
end

int procedure ss()
pointer sp
pointer temp
begin
	call smark(sp)
	temp = sp
	call sfree(sp)
	return(temp)
end

